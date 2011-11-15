//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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
//------------------------------------------------------------------------------

`include "rdb.sv"
`include "uvc_pkg.sv"

module testm();

  import uvm_pkg::*;
  import my_pkg::*;
  import uvc_pkg::*;

  class my_catcher extends uvm_report_catcher;
     static int seen = 0;
     virtual function action_e catch();
        set_severity(UVM_INFO);
        return THROW;
     endfunction
  endclass

  // User register sequence
  class test_seq extends uvm_reg_sequence;
     // The register model on which the sequence work 
     rfile0_t model;

     // Drive all registers inside model
     virtual task body();
       uvm_status_e status;
       int data;

       my_catcher catcher = new;
       uvm_report_cb::add(null,catcher);

       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", "  Starting Test Sequence", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>\n", UVM_LOW)

       void'(model.randomize());
       `uvm_info("TEST_SEQ", "Backdoor mirror the shadow. Expect mismatch errors", UVM_LOW)
       model.ureg0.mirror(status, UVM_CHECK, UVM_BACKDOOR, .parent(this));
     endtask : body
     
     `uvm_object_utils(test_seq)
     function new(string name="test_seq");
       super.new(name);
     endfunction : new
  endclass : test_seq

  class reg2ovc_adapter extends uvm_reg_adapter;
  
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
    `uvm_object_utils(reg2ovc_adapter)

  function new(string name="reg2ovc_adapter");
     super.new(name);
  endfunction

  endclass

  class test extends uvm_test;
  
    mmap0_type model; 
    test_seq seq;
    uvc_pkg::uvc_env#(virtual uvc_intf) uenv;
  
    virtual function void build();
      set_config_int("uenv.uos", "count", 0);
      super.build();
      uvm_reg::include_coverage("*", UVM_CVR_ALL);
      // Create register model
      model = mmap0_type::type_id::create("model",this);
      model.build();
      // Create UVC
      uenv = uvc_pkg::uvc_env#(virtual uvc_intf)::type_id::create("uenv", this);
    endfunction
  
    virtual function void connect();
      // Set model's sequencer and adapter sequence
      reg2ovc_adapter reg2ovc = new;
      model.default_map.set_sequencer(uenv.uos, reg2ovc);
      uenv.uod.vif=testm.pif;
    endfunction

    function void end_of_elaboration();
      model.reset();
      uvm_default_printer=uvm_default_tree_printer;
      this.print();
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      // Create register sequence
      seq=test_seq::type_id::create("test_seq", this);
      // Set sequence's container
      seq.model=model.rfile0;
      // Procedurally start sequence
      seq.start(null);
      phase.drop_objection(this);
    endtask

    `uvm_component_utils(test)
    function new(string name, uvm_component parent=null);
       super.new(name,parent);
    endfunction

   virtual function void report();
      $write("** UVM TEST PASSED **\n");
      $write("UVM TEST EXPECT 1 UVM_ERROR\n");
   endfunction

  endclass

  initial run_test();

  uvc_intf pif();
  dut dut(pif);
endmodule
