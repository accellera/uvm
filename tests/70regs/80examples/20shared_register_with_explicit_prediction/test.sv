//----------------------------------------------------------------------
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Mentor Graphics Corporation
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

`include "rdb.sv" 

module testm();

  import uvm_pkg::*;
  import my_pkg::*;

  // UVC Stuff...
  class transaction extends uvm_sequence_item;
    rand bit[31:0] addr;
    rand bit[31:0] data;
    rand bit r_wn;
    `uvm_object_utils_begin(transaction)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(r_wn, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name="unnamed-transaction");
      super.new(name);
    endfunction
  endclass

  `uvm_blocking_put_imp_decl(_reg)
  
  class uvc_sequencer extends uvm_sequencer#(transaction);
    `uvm_sequencer_utils(uvc_sequencer)
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
  endclass : uvc_sequencer

  class uvc_driver extends uvm_driver#(transaction);
    uvm_analysis_port#(transaction) item_collected_port;
    task run();
      while(1) begin
        seq_item_port.get_next_item(req);
        if(req.r_wn) req.data=dut.srd;
        else dut.swr=req.data;
        #1;
        if(req.r_wn==0)
          `uvm_info("USRDRV", $sformatf("Write addr=0x%0x Data=0x%0x", req.addr, req.data), UVM_HIGH)
        else
          `uvm_info("USRDRV", $sformatf("Read addr=0x%0x Data=0x%0x", req.addr, req.data), UVM_HIGH)
          
        item_collected_port.write(req);
        
        seq_item_port.item_done();
      end
    endtask
    `uvm_component_utils(uvc_driver)
    function new (string name, uvm_component parent);
      super.new(name, parent);
      item_collected_port=new("item_collected_port", this);
    endfunction : new
  endclass

  class reg2uvc_adapter extends uvm_reg_adapter;
  
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      transaction txn = transaction::type_id::create("txn");
      txn.r_wn = (rw.kind == UVM_READ) ? 1 : 0;
      txn.addr = rw.addr;
      txn.data = rw.data;
      return txn;
    endfunction
  
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      transaction txn;
      if (!$cast(txn,bus_item)) begin 
        `uvm_fatal("NOT_TXN_TYPE","Provided bus_item not correct type")
        return;
      end
      rw.kind = txn.r_wn ? UVM_READ : UVM_WRITE;
      rw.addr = txn.addr;
      rw.data = txn.data;
      rw.status = UVM_IS_OK;
    endfunction
    `uvm_object_utils(reg2uvc_adapter)

  function new(string name="reg2uvc_adapter");
     super.new(name);
  endfunction

  endclass

  // User test sequence
  class test_seq extends uvm_sequence;
     // The register model on which the sequence work 
     my_rf_type model;
     transaction tx;

     function void check_regs();
       bit error;
      if(dut.swr!==model.swr_reg.get() || dut.srd!==model.srd_reg.get())
         `uvm_error("TEST_SEQ", $sformatf(
           "Registers mismatched. [SWR] DUT=0x%0x, Shadow=0x%0x : [SRD] DUT=0x%0x, Shadow=0x%0x\n", 
             dut.swr, model.swr_reg.get(), dut.srd, model.srd_reg.get()))
       else
         `uvm_info("TEST_SEQ", $sformatf("Register Matched. SWR=0x%0x SRD=0x%0x\n", dut.swr, dut.srd), UVM_LOW)
     endfunction

     virtual task body();
       uvm_status_e status;
       int data;
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", "  Starting Test Sequence", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>\n", UVM_LOW)

       // Part 1 : Bus-item (not register) transfer affecting shadow and DUT registers
       // ----------------------------------------------------------------------------
       // Write to address having shared registers.
       `uvm_info("TEST_SEQ", "PART1 :: Write to address having shared registers", UVM_LOW)
       `uvm_do_with(tx, {addr=='h1004; data=='h12345678; r_wn==0;})
       `uvm_do_with(tx, {addr=='h1004; data=='h0; r_wn==1;})
       check_regs();

       // Part 2 : Access registers procedurally
       `uvm_info("TEST_SEQ", "PART2 :: Frontdoor access to shared registers done", UVM_LOW)
       model.swr_reg.write(status, 'h87654321, .parent(this));
       model.srd_reg.read(status, data, .parent(this));
       check_regs();

       // Part 3 : Backdoor register access
       `uvm_info("TEST_SEQ", "PART 3 :: Backdoor access to shared registers", UVM_LOW)
       model.swr_reg.write(status, 'hdeadface, UVM_BACKDOOR, .parent(this));
       model.srd_reg.read(status, data, UVM_BACKDOOR, .parent(this));
       check_regs();
     endtask : body
     
     `uvm_sequence_utils(test_seq, uvc_sequencer)
     function new(string name="test_seq");
       super.new(name);
     endfunction : new
  endclass : test_seq

  class test extends uvm_test;
  
    my_map_type model; 
    uvc_sequencer seqr;
    uvc_driver drv;
    test_seq seq;
    uvm_reg_predictor#(transaction) predictor;
  
    virtual function void build();
      set_config_int("seqr", "count", 0);
      super.build();
      uvm_reg::include_coverage("*", UVM_CVR_ALL);
      // Create register model
      model = my_map_type::type_id::create("model",this);
      model.build();
      // Create uvc sequencer
      seqr = uvc_sequencer::type_id::create("seqr", this);
      // Create uvc driver
      drv = uvc_driver::type_id::create("drv", this);
      // Create predictor
      predictor = uvm_reg_predictor#(transaction)::type_id::create("predictor", this);
    endfunction
  
    virtual function void connect();
      // Set model's sequencer and adapter sequence
      reg2uvc_adapter reg2uvc = new;
      model.default_map.set_sequencer(seqr, reg2uvc);
      drv.seq_item_port.connect(seqr.seq_item_export);
      // Predictor part
      predictor.map=model.default_map;
      predictor.adapter=reg2uvc;
      // Short-cut. Ideally this would be done via monitor
      drv.item_collected_port.connect(predictor.bus_in);
      // Dsiable prediction inside sequence
      model.default_map.set_auto_predict(0);
    endfunction

    function void end_of_elaboration();
      model.reset();
      uvm_default_printer=uvm_default_tree_printer;
      this.print();
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      // Create register sequence
      seq=test_seq::type_id::create("test_seq");
      // Set sequence's container
      seq.model=model.my_rf;
      // Procedurally start sequence
      seq.start(seqr);
      phase.drop_objection(this);
    endtask

    `uvm_component_utils(test)
    function new(string name, uvm_component parent=null);
       super.new(name,parent);
    endfunction
  endclass

  initial run_test();
  dut dut();

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
endmodule

module dut;
  // Dummy Registers
  logic [31:0] swr;
  logic [31:0] srd='ha5a5a5a5;

  function void display();
    $display("DUT's swr=0x%0x srd=0x%0x", swr, srd);
  endfunction
endmodule
