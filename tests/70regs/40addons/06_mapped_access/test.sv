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

parameter NUM_REGS=`NUM_REGS;
`include "uvm_macros.svh"
module test();

  import uvm_pkg::*;
  `include "rdb.sv"

  // User register sequence
  class blk_seq extends uvm_reg_sequence;
     // The register model on which the sequence work 
     uvm_reg_block model;
     uvm_reg_map map;

     // Drive all registers inside model
     virtual task body();
       uvm_status_e status;
       uvm_reg r[$];
       int data;
       model.get_registers(r);
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", $sformatf("  Starting Blk Sequence. Container=%s", model.get_full_name()), UVM_LOW)
       `uvm_info("TEST_SEQ", $sformatf("  Number of Registers = %0d", r.size()), UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>\n", UVM_LOW)
       // Drive all register frontdoor
       foreach(r[i]) begin
	 r[i].print();
         r[i].write(status, i*2+1, .map(map), .parent(this));
	end

     endtask : body
     
     `uvm_object_utils(blk_seq)
     function new(string name="blk_seq");
       super.new(name);
     endfunction : new
  endclass : blk_seq

  class sub_system_seq extends uvm_reg_sequence;
  
     rfile_type model;
     blk_seq seq;
  
     virtual task body();
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", $sformatf("  Starting Sub-System Sequence. Container=%s", model.get_full_name()), UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>\n", UVM_LOW)
       for (int i=0; i < 2; i++) begin
          seq = blk_seq::type_id::create($sformatf("blk_seq%0d",i),,get_full_name());
          seq.model = model.uart_rf;
          seq.map=(i==0) ? model.ahb_map : model.apb_map;
          seq.start(null,this);
       end
     endtask
  
     `uvm_object_utils(sub_system_seq)
     function new(string name = "sub_system_seq");
        super.new(name);
     endfunction: new
  endclass

  // OVC Stuff...
  class user_transaction extends uvm_sequence_item;
    rand bit[31:0] addr;
    rand logic[31:0] data;
    rand bit r_wn;
    `uvm_object_utils_begin(user_transaction)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(r_wn, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name="unnamed-user_transaction");
      super.new(name);
    endfunction
  endclass

  `uvm_blocking_put_imp_decl(_reg)
  
  class user_ovc_sequencer extends uvm_sequencer#(user_transaction);
    `uvm_sequencer_utils(user_ovc_sequencer)
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
  endclass : user_ovc_sequencer

  class user_ovc_driver extends uvm_driver#(user_transaction);
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      while(1) begin
        seq_item_port.get_next_item(req);
        #1;
        if(req.r_wn) begin
          `uvm_info("USRDRV", $sformatf("Read addr=0x%0x", req.addr), UVM_LOW)
        end
        else begin
          `uvm_info("USRDRV", $sformatf("Write addr=0x%0x Data=0x%0x", req.addr, req.data), UVM_LOW)
        end
        seq_item_port.item_done();
      end
    endtask
    `uvm_component_utils(user_ovc_driver)
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
  endclass

  class reg2ahb_adapter extends uvm_reg_adapter;
  
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      user_transaction txn = user_transaction::type_id::create("txn");
      txn.r_wn = (rw.kind == UVM_READ) ? 1 : 0;
      txn.addr = rw.addr;
      txn.data = rw.data;
      return txn;
    endfunction
  
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      user_transaction txn;
      if (!$cast(txn,bus_item)) begin 
        `uvm_fatal("NOT_TXN_TYPE","Provided bus_item not correct type")
        return;
      end
      rw.kind = txn.r_wn ? UVM_READ : UVM_WRITE;
      rw.addr = txn.addr;
      rw.data = txn.data;
      rw.status = UVM_IS_OK;
    endfunction
    `uvm_object_utils(reg2ahb_adapter)

  function new(string name="reg2ahb_adapter");
     super.new(name);
  endfunction

  endclass : reg2ahb_adapter

  class reg2apb_adapter extends uvm_reg_adapter;
  
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      user_transaction txn = user_transaction::type_id::create("txn");
      txn.r_wn = (rw.kind == UVM_READ) ? 1 : 0;
      txn.addr = rw.addr;
      txn.data = rw.data;
      return txn;
    endfunction
  
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      user_transaction txn;
      if (!$cast(txn,bus_item)) begin 
        `uvm_fatal("NOT_TXN_TYPE","Provided bus_item not correct type")
        return;
      end
      rw.kind = txn.r_wn ? UVM_READ : UVM_WRITE;
      rw.addr = txn.addr;
      rw.data = txn.data;
      rw.status = UVM_IS_OK;
    endfunction
    `uvm_object_utils(reg2apb_adapter)

  function new(string name="reg2apb_adapter");
     super.new(name);
  endfunction

  endclass : reg2apb_adapter

  class test extends uvm_test;
  
    rfile_type model; 
    user_ovc_sequencer ahb_seqr;
    user_ovc_sequencer apb_seqr;
    user_ovc_driver ahb_drv;
    user_ovc_driver apb_drv;
    sub_system_seq seq;
  
    virtual function void build();
      set_config_int("ahb_seqr*", "count", 0);
      set_config_int("apb_seqr*", "count", 0);
      super.build();
      uvm_reg::include_coverage("*", UVM_CVR_ALL);
      // Create register model
      model = rfile_type::type_id::create("model",this);
      model.build();
      // Create OVC sequencer
      ahb_seqr = user_ovc_sequencer::type_id::create("ahb_seqr", this);
      apb_seqr = user_ovc_sequencer::type_id::create("apb_seqr", this);
      // Create OVC driver
      ahb_drv = user_ovc_driver::type_id::create("ahb_drv", this);
      apb_drv = user_ovc_driver::type_id::create("apb_drv", this);
    endfunction
  
    virtual function void connect_phase(uvm_phase phase);
      // Set model's sequencer and adapter sequence
      reg2ahb_adapter reg2ahb = new;
      reg2apb_adapter reg2apb = new;
      super.connect_phase(phase);
      ahb_drv.seq_item_port.connect(ahb_seqr.seq_item_export);
      apb_drv.seq_item_port.connect(apb_seqr.seq_item_export);
      model.ahb_map.set_sequencer(ahb_seqr, reg2ahb);
      model.apb_map.set_sequencer(apb_seqr, reg2apb);
      model.ahb_map.set_auto_predict(1);
      model.apb_map.set_auto_predict(1);
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
      seq=sub_system_seq::type_id::create("sub_system_seq", this);
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

  initial begin
    run_test("test");
  end 

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
  top dut();
endmodule

module top;
  rfile rfile0();
  rfile rfile1();
endmodule

module rfile;
  uart uart0();
  uart uart1();
endmodule

module uart;
  // Dummy Registers
  logic [31:0] ureg[NUM_REGS:1];
endmodule
