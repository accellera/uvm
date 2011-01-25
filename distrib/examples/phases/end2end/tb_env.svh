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

   // ToDo: Self-checking

   `uvm_component_utils(tb_env)

   local uvm_status_e status;
   local uvm_reg_data_t data;

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
   endfunction

   function void connect_phase(uvm_phase phase);
      if (regmodel.get_parent() == null) begin
         reg2apb_adapter reg2apb = new;
         regmodel.default_map.set_sequencer(apb.sqr,reg2apb);
         regmodel.default_map.set_auto_predict(1);
      end
   endfunction

   
   task pre_reset_phase(uvm_phase phase);
      wait (vif.rst !== 1'bx);
   endtask


   task reset_phase(uvm_phase phase);
      regmodel.reset();
      vip.drv.do_reset();
      repeat (10) @(posedge vif.clk);
      vif.rst = 1'b0;
   endtask


   task pre_configure_phase(uvm_phase phase);
      repeat (10) @(posedge vif.clk);
   endtask


   task configure_phase(uvm_phase phase);
      regmodel.IntMask.SA.set(1);
      
      regmodel.TxStatus.TxEn.set(1);
      regmodel.RxStatus.RxEn.set(1);
      
      regmodel.update(status);

      vip.drv.resume();
   endtask

   task pre_main_phase(uvm_phase phase);
      // Wait until the VIP has acquired symbol sync

      // Wait until the DUT has acquired symbol sync
      data = 0;
      while (data[1] != 1) begin
         wait (vif.intr);
         regmodel.IntSrc.write(status, 'h100);
         regmodel.RxStatus.read(status, data);
      end
      
   endtask

   task main_phase(uvm_phase phase);
      fork
         begin
            bit can_kill = 0;
            
            fork
               TxRxSide(can_kill);
            join_none

            // Send a sentence to DUT
            begin
               // ToDo: replace with sequence
               vip_tr tr;
               repeat (10) begin
                  tr = new;
                  tr.randomize();
                  `uvm_info("RX/CHR", $sformatf("RX->DUT: 0x%h...\n", tr.chr),
                            UVM_MEDIUM);
                  vip.sqr.execute_item(tr);
               end
            end
      
            wait (can_kill);
            disable fork;
         end
      join
   endtask


   task shutdown_phase(uvm_phase phase);
      // Flush the RxFIFO
      regmodel.IntSrc.read(status, data);
      while (!data[4]) begin
         uvm_reg_data_t rx;
         regmodel.TxRx.read(status, rx);
         `uvm_info("RX/CHR", $sformatf("Rx: 0x%h", rx[7:0]), UVM_LOW)
         regmodel.IntSrc.read(status, data);
      end

      if (!data[0]) begin
         // Wait for TxFIFO to be empty
         regmodel.IntMask.write(status, 'h001);
         wait(vif.intr);
      end
      // Make sure the last symbol is transmitted
      repeat (16) @(posedge vif.sclk);
   endtask

   
   task post_shutdown_phase(uvm_phase phase);
      global_stop_request();
   endtask

   
   task TxRxSide(ref bit ready_to_kill);
      regmodel.IntMask.TxLow.set(1);
      regmodel.IntMask.RxHigh.set(1);
      regmodel.update(status);
                  
      forever begin
         bit do_rx, do_tx;
         
         ready_to_kill = 1;
         wait (vif.intr);
         ready_to_kill = 0;
                     
         regmodel.IntSrc.read(status, data);
         regmodel.IntSrc.write(status, data);
         if (data[8]) begin
            `uvm_error("TB/SYNC/LOST", "DUT has lost symbol sync")
            // Recover sync
            // ToDo
         end

         do_tx = data[1];
         do_rx = data[5];
         while ((do_tx && !data[2]) ||
                (do_rx && !data[4])) begin
            if (do_tx && !data[2]) begin
               // Tx FIFO is getting empty
               vip_tr tr = new; // Should be pulling from a sequencer
               tr.randomize();
               `uvm_info("TX/CHR", $sformatf("DUT->TX: 0x%h...", tr.chr),
                         UVM_LOW);
               regmodel.TxRx.write(status, tr.chr);
            end
                
            if (do_rx && !data[4]) begin
               // Rx FIFO is getting full
               uvm_reg_data_t rx;
               regmodel.TxRx.read(status, rx);
               `uvm_info("RX/CHR", $sformatf("Rx: 0x%h", rx[7:0]), UVM_LOW)
            end

            regmodel.IntSrc.read(status, data);
         end
      end
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
