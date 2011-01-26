// 
// -------------------------------------------------------------
//    Copyright 2011 Synopsys, Inc.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
//


`include "reg_model.svh"


typedef virtual tb_ctl_if tb_ctl_vif;

class tb_env extends uvm_env;

   tb_ctl_vif vif;

   apb_agent  apb;
   reg_dut    regmodel;

   vip_agent  vip;

   sym_sb     ingress;  // VIP->DUT
   sym_sb     egress;   // DUT->VIP
   apb2txrx   adapt;

   `uvm_component_utils(tb_env)

   local uvm_status_e status;
   local uvm_reg_data_t data;
   local uvm_objection  m_isr;

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
      set_phase_domain("uvm");
   endfunction
      

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(tb_ctl_vif)::get(this, "", "vif", vif)) begin
         `uvm_fatal("TB/ENV/NOVIF", "No virtual interface specified for environment instance")
      end
      
      apb = apb_agent::type_id::create("apb", this);
      if (regmodel == null) begin
         regmodel = reg_dut::type_id::create("regmodel",,get_full_name());
         regmodel.build();
         regmodel.lock_model();
      end

      vip = vip_agent::type_id::create("vip", this);

      ingress = sym_sb::type_id::create("ingress", this);
      egress = sym_sb::type_id::create("egress", this);
      adapt = apb2txrx::type_id::create("adapt", this);

      m_isr = new({get_full_name(), ".isr"});

      uvm_config_db #(uvm_object_wrapper)::set(this, "vip.sqr.main_phase",
                                               "default_sequence",
                                               vip_sentence_seq::type_id::get());
   endfunction

   function void connect_phase(uvm_phase phase);
      if (regmodel.get_parent() == null) begin
         reg2apb_adapter reg2apb = new;
         regmodel.default_map.set_sequencer(apb.sqr,reg2apb);
         regmodel.default_map.set_auto_predict(1);
      end

      apb.mon.ap.connect(adapt.apb);

      vip.tx_mon.ap.connect(ingress.expected);
      vip.rx_mon.ap.connect(egress.observed);
      adapt.tx_ap.connect(egress.expected);
      adapt.rx_ap.connect(ingress.observed);
   endfunction


   local bit m_in_shutdown = 0;   
   function void phase_started(uvm_phase phase);
      case (phase.get_phase_name())
       "main":
          fork
             pull_from_RxFIFO(phase);
          join_none
       "shutdown":
          m_in_shutdown = 1;
      endcase
   endfunction
   

   task pre_reset_phase(uvm_phase phase);
      phase.raise_objection(this, "Waiting for reset to be valid");
      wait (vif.rst !== 1'bx);
      phase.drop_objection(this, "Reset is no longer X");
   endtask


   task reset_phase(uvm_phase phase);
      phase.raise_objection(this, "Asserting reset for 10 clock cycles");

      `uvm_info("TB/TRACE", "Resetting DUT...", UVM_NONE);
      
      regmodel.reset();
      vip.reset_and_suspend();
      repeat (10) @(posedge vif.clk);
      vif.rst = 1'b0;
      vip.resume();
      phase.drop_objection(this, "HW reset done");
   endtask


   task pre_configure_phase(uvm_phase phase);
      phase.raise_objection(this, "Letting the interfaces go idle");

      `uvm_info("TB/TRACE", "Configuring DUT...", UVM_NONE);

      repeat (10) @(posedge vif.clk);
      phase.drop_objection(this, "Ready to configure");
   endtask


   task configure_phase(uvm_phase phase);
      phase.raise_objection(this, "Programming DUT");
      regmodel.IntMask.SA.set(1);
      
      regmodel.TxStatus.TxEn.set(1);
      regmodel.RxStatus.RxEn.set(1);
      
      regmodel.update(status);

      phase.drop_objection(this, "Everything is ready to go");
   endtask

   task pre_main_phase(uvm_phase phase);
      phase.raise_objection(this, "Waiting for VIPs and DUT to acquire SYNC");

      `uvm_info("TB/TRACE", "Synchronizing interfaces...", UVM_NONE);

      fork
         begin
            repeat (100 * 8) @(posedge vif.sclk);
            `uvm_fatal("TB/TIMEOUT",
                       "VIP failed to acquire syncs")
         end
      join_none

      // Wait until the VIP has acquired symbol syncs
      while (!vip.rx_mon.is_in_sync()) begin
         vip.rx_mon.wait_for_sync_change();
      end
      while (!vip.tx_mon.is_in_sync()) begin
         vip.tx_mon.wait_for_sync_change();
      end

      // Wait until the DUT has acquired symbol sync
      regmodel.RxStatus.mirror(status);
      if (!regmodel.RxStatus.Align.get()) begin
         regmodel.IntMask.set('h000);
         regmodel.IntMask.SA.set('b1);
         regmodel.IntMask.update(status);
         wait (vif.intr);
      end
      regmodel.IntMask.write(status, 'h000);
      regmodel.IntSrc.write(status, -1);

      phase.drop_objection(this, "Everyone is in SYNC");
   endtask


   //
   // This task is a thread that will span the main and shutdown phase
   //
   task pull_from_RxFIFO(uvm_phase phase);
      uvm_phase shutdown_ph = phase.find_schedule("shutdown");
      shutdown_ph.raise_objection(this, "Pulling data from RxFIFO");
      
      regmodel.IntMask.SA.set(1);
      regmodel.IntMask.RxHigh.set(1);
      regmodel.IntMask.update(status);
      
      forever begin
         wait (vif.intr || m_in_shutdown);

         m_isr.raise_objection(this, "Servicing RxHigh");
               
         regmodel.IntSrc.mirror(status);
         if (regmodel.IntSrc.SA.get()) begin
            `uvm_fatal("TB/DUT/SYNCLOSS", "DUT has lost SYNC");
         end
         if (!regmodel.IntSrc.RxHigh.get() && !m_in_shutdown) begin
            m_isr.drop_objection(this, "RxHigh does not need service");
            m_isr.wait_for(UVM_ALL_DROPPED);
            continue;
         end
               
         // Stop reading data once it is empty
         while (!regmodel.IntSrc.RxEmpty.get()) begin
            regmodel.TxRx.mirror(status);
            regmodel.IntSrc.mirror(status);
         end
         m_isr.drop_objection(this, "RxHigh has been fully serviced");

         if (m_in_shutdown) begin
            shutdown_ph.drop_objection(this, "All data pulled from RxFIFO");
            break;
         end
      end
   endtask


   task main_phase(uvm_phase phase);

      `uvm_info("TB/TRACE", "Applying primary stimulus...", UVM_NONE);

      fork
         begin
            // ToDo: replace with phase sequence in sequencer?
            phase.raise_objection(this, "Applying ->DUT stimulus");
            repeat (100) begin
               vip_tr tr;
               tr = vip_tr::type_id::create("tr",,get_full_name());
               tr.randomize();
               vip.sqr.execute_item(tr);
            end
            phase.drop_objection(this, "Primary ->DUT stimulus applied");
         end
      
         begin
            uvm_objection ph_obj = phase.get_objection();
            
            phase.raise_objection(this, "Configuring ISR for DUT-> stimulus");
            regmodel.IntMask.TxLow.set(1);
            regmodel.IntMask.update(status);
                  
            forever begin
               phase.drop_objection(this, "ISR ready DUT-> stimulus");

               wait (vif.intr);

               // If the egress scoreboard is not objecting,
               // don't service the interrupt
               if (ph_obj.get_objection_total(egress) == 0) break;

               m_isr.raise_objection(this, "Servicing TxLow");
               phase.raise_objection(this, "Applying DUT-> stimulus");
               
               regmodel.IntSrc.mirror(status);
               if (!regmodel.IntSrc.TxLow.get()) begin
                  m_isr.drop_objection(this, "TxLow does not need service");
                  m_isr.wait_for(UVM_ALL_DROPPED);
                  continue;
               end
               
               // Stop supplying data once it is full
               // or the egress scoreboard has had enough
               while (!regmodel.IntSrc.TxFull.get() &&
                      ph_obj.get_objection_total(egress) > 0) begin
                  vip_tr tr = new; // Should be pulling from a sequencer
                  tr.randomize();
                  regmodel.TxRx.write(status, tr.chr);

                  regmodel.IntSrc.mirror(status);
               end
               m_isr.drop_objection(this, "TxLow has been fully serviced");
            end
            regmodel.IntMask.TxLow.set(0);
            regmodel.IntMask.update(status);
         end
      join
   endtask


   task shutdown_phase(uvm_phase phase);
      phase.raise_objection(this, "Draining the DUT");

      `uvm_info("TB/TRACE", "Draining the DUT...", UVM_NONE);

      if (!regmodel.IntSrc.TxEmpty.get()) begin
         // Wait for TxFIFO to be empty
         regmodel.IntMask.write(status, 'h001);
         wait (vif.intr);
      end
      // Make sure the last symbol is transmitted
      repeat (16) @(posedge vif.sclk);

      phase.drop_objection(this, "DUT is empty");
   endtask

   
   task post_shutdown_phase(uvm_phase phase);
      global_stop_request();
   endtask

   
   function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass
