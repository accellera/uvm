//----------------------------------------------------------------------
//   Copyright 2010-2011 Cadence Design Systems, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

/*
   This test demoes how a sequence can access registers backsdoor or frontdoor
   This test-sequence does the fllowing :

   A ) Frontdoor write all registers with directed values
   B ) Reset DUT. Frontdoor read all registers
   Ca) Backdoor write all registers with directed values
   Cb) Backdoor read all registers
   Da) Randomize full block. Backdoor update block
   Db) Backdoor mirror block. Expect no error
   E ) Reset DUT & shadow with different values. Frontdoor mirror block. Post-mirror, check registers
*/

`include "rdb.sv"
`include "uvc_pkg.sv"
`include "top.sv"

module test();

  import uvm_pkg::*;
  import my_pkg::*;
  import uvc_pkg::*;

  // User register sequence
  class test_seq extends uvm_reg_sequence;
     // The register model on which the sequence work 
     uvm_reg_block model;
     uvm_reg r[$];
     byte cur_value;

     // Drive all registers inside model
     virtual task body();
       uvm_status_e status;
       bit [63:0] data;
       // Raising one uvm_test_done objection
       uvm_test_done.raise_objection(this);
       model.get_registers(r);

       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", "  Starting Test Sequence", UVM_LOW)
       `uvm_info("TEST_SEQ", $sformatf("  Number of Registers = %0d", r.size()), UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>\n", UVM_LOW)

       `uvm_info("TEST_SEQ", "<><><><><><><><><- PART A -><><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", " Frontdoor write all registers with directed values", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       foreach(r[i]) begin
         for(int j=0; j<r[i].get_n_bytes(); j++) data[j*8+:8]=cur_value++;
         r[i].write(status, data, .parent(this));
       end
       check_regs();

       `uvm_info("TEST_SEQ", "<><><><><><><><><- PART B -><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", " Reset DUT. Frontdoor read all registers", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       top.reset_dut();
       foreach(r[i]) 
         r[i].read(status, data, .parent(this));
       check_regs();

       `uvm_info("TEST_SEQ", "<><><><><><><><><- PART Ca -><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", " Backdoor write all registers with directed values", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       foreach(r[i]) begin
         for(int j=0; j<r[i].get_n_bytes(); j++) data[j*8+:8]=cur_value++;
         r[i].write(status, data, UVM_BACKDOOR, .parent(this));
       end
       check_regs();

       `uvm_info("TEST_SEQ", "<><><><><><><><><- PART Cb -><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", " Backdoor read all registers", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       foreach(r[i])
         r[i].read(status, data, UVM_BACKDOOR, .parent(this));
       check_regs();

       `uvm_info("TEST_SEQ", "<><><><><><><><><- PART Da -><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", " Randomize full block. Backdoor update block", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       void'(model.randomize());
       // Cover the block
       model.sample_values();
       foreach(r[i])
         r[i].update(status, UVM_BACKDOOR, .parent(this));
       check_regs();

       `uvm_info("TEST_SEQ", "<><><><><><><><><- PART Db -><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", " Backdoor mirror block. Expect no error", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       foreach(r[i])
         r[i].mirror(status, UVM_CHECK, UVM_BACKDOOR, .parent(this));
       check_regs();

       `uvm_info("TEST_SEQ", "<><><><><><><><><- PART E -><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", " Frontdoor mirror block. Expect mismatch info", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)

       top.reset_dut(1);
       model.reset();
       `uvm_info("TEST_SEQ", "DUT and shadow reset. Block mirror. Expect NO mismatch", UVM_LOW)
       model.mirror(status, UVM_CHECK, .parent(this));
       check_regs();
       
       uvm_test_done.drop_objection(this);
     endtask : body
     
     task check_regs();
       uvm_reg_data_t data; int status;
       foreach(r[i])
       begin
         r[i].peek(status, data);
         if(r[i].get()!==data)
           `uvm_error("TEST_SEQ", $sformatf(
             "Registers mismatched. [%s] Shadow=0x%0x, DUT=0x%0x\n", 
               r[i].get_name(), r[i].get(), data))
         else
           `uvm_info("TEST_SEQ", $sformatf("Registers matched. [%s] Shaodow=0x%0x DUT=0x%0x", 
             r[i].get_name(), r[i].get(), data), UVM_LOW)
       end
       $display();
       $display();
       cur_value=0;
     endtask

     `uvm_object_utils(test_seq)
     function new(string name="test_seq");
       super.new(name);
     endfunction : new
  endclass : test_seq

  class reg2uvc_adapter extends uvm_reg_adapter;
  
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      uvc_pkg::transaction txn = transaction::type_id::create("txn");
      txn.dir = rw.kind;
      txn.addr = rw.addr;
      txn.data = rw.data;
      return txn;
    endfunction
  
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      uvc_pkg::transaction txn;
      if (!$cast(txn,bus_item)) begin 
        `uvm_fatal("NOT_TXN_TYPE","Provided bus_item not correct type")
        return;
      end
      rw.kind = txn.dir;
      rw.addr = txn.addr;
      rw.data = txn.data;
      rw.status = UVM_IS_OK;
    endfunction
    `uvm_object_utils(reg2uvc_adapter)

  function new(string name="reg2uvc_adapter");
     super.new(name);
  endfunction

  endclass

  class test extends uvm_test;
  
    mmap0_t model; 
    test_seq seq;
    uvc_pkg::uvc_env#(virtual uvc_intf) uenv;
    uvm_reg_predictor#(uvc_pkg::transaction) predictor;
  
    virtual function void build();
      set_config_int("uenv.seqr", "count", 0);
      uvm_reg::include_coverage("*", UVM_CVR_ALL);
      super.build();
      // Create register model
      model = mmap0_t::type_id::create("model",this);
      model.build();
      // Create UVC
      uenv = uvc_pkg::uvc_env#(virtual uvc_intf)::type_id::create("uenv", this);
      // Create predictor
      predictor = uvm_reg_predictor#(uvc_pkg::transaction)::type_id::create("predictor", this);
    endfunction
  
    virtual function void connect();
      // Set model's sequencer and adapter sequence
      reg2uvc_adapter reg2uvc = new;
      model.default_map.set_sequencer(uenv.seqr, reg2uvc);
      uenv.drv.vif=top.pif;
      // Predictor part
      predictor.map=model.default_map;
      predictor.adapter=reg2uvc;
      uenv.drv.item_collected_port.connect(predictor.bus_in);
      // Dsiable prediction inside sequence
      model.default_map.set_auto_predict(0);
    endfunction

    function void end_of_elaboration();
      model.reset();
      uvm_default_printer=uvm_default_tree_printer;
      this.print();
      model.print();
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      // Create register sequence
      seq=test_seq::type_id::create("test_seq", this);
      // Set sequence's container
      seq.model=model;
      // Procedurally start sequence
      seq.start(null);
      phase.drop_objection(this);
    endtask

    `uvm_component_utils(test)
    function new(string name, uvm_component parent=null);
       super.new(name,parent);
    endfunction
  endclass

  initial run_test("test");
  final
  begin
    uvm_report_server svr;
    svr = _global_reporter.get_report_server();
    svr.summarize();
    if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) == 0)
      $write("** UVM TEST PASSED **\n");
    else
      $write("!! UVM TEST FAILED !!\n");
  end

  // Controlling messages
  // Make library mismatch error a warning. Because errors are deliberate
  class my_catcher extends uvm_report_catcher;
     static int seen = 0;
     virtual function action_e catch();
       string txt = get_message();
       if (get_severity() == UVM_ERROR && get_id() == "RegModel") begin
         if(!uvm_re_match(".*does not match mirrored value.*", txt)) begin
            set_severity(UVM_INFO);
            set_action(UVM_DISPLAY);
            return THROW;
         end
       end
       return THROW;
     endfunction
  endclass

  my_catcher c = new;
  initial uvm_report_cb::add(null, c);
endmodule
