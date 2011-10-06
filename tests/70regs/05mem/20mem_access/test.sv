//----------------------------------------------------------------------
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010-2011 Mentor Graphics Corporation
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


module tbtest();

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //-------------- Register Definitions ----------------
  class mem_type extends uvm_mem;
  
    virtual function void build();
    endfunction
  
    `uvm_register_cb(mem_type, uvm_reg_cbs) 
    `uvm_set_super_type(mem_type, uvm_mem)
    `uvm_object_utils(mem_type)
    function new(input string name="unnamed-mem_type");
      super.new(name, 'h8, 64, "RW", UVM_NO_COVERAGE);
    endfunction : new
  endclass : mem_type

  class mmap_type extends uvm_reg_block;
  
    rand mem_type mem;
  
    function void build();
      // Now define address mappings
      default_map = create_map("default_map", 0, 8, UVM_LITTLE_ENDIAN);
      mem = mem_type::type_id::create("mem");
      mem.build();
      mem.configure(this, "mem");
      default_map.add_mem(mem, 'h100, "RW");
      set_hdl_path_root("tbtest.top.dut");
      this.lock_model();
    endfunction
  
    `uvm_object_utils(mmap_type)
    function new(input string name="unnamed-mmap_type");
      super.new(name, UVM_NO_COVERAGE);
    endfunction
  endclass : mmap_type
  //-------------- Register Definition Ends Here ----------------

  // User register sequence
  class user_test_seq extends uvm_reg_sequence;
     // The register model on which the sequence work 
     mmap_type model;

     // Drive all registers inside model
     virtual task body();
       uvm_status_e status;
       uvm_reg r[$];
       bit [63:0] data;
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>", UVM_LOW)
       `uvm_info("TEST_SEQ", "  Starting Test Sequence", UVM_LOW)
       `uvm_info("TEST_SEQ", "<><><><><><><><><><><><><><><><><><><><><><><>\n", UVM_LOW)
       // Drive all memory elements frontdoor
       for(int idx=0; idx<8; idx++) begin
         for(int j=0; j<8; j++) 
		data[j*8+:8]=(idx*8)+j;
         model.mem.write(status, idx, data, UVM_FRONTDOOR, .parent(this));
       end
       top.dut.print_mem();
       top.dut.reset();
       // Drive all memory elements backdoor
       for(int idx=0; idx<8; idx++) begin
         for(int j=0; j<8; j++) 
		data[j*8+:8]=(idx*8)+j;
         model.mem.write(status, idx, data, UVM_BACKDOOR, .parent(this));
       end
     endtask : body
     
     `uvm_object_utils(user_test_seq)
     function new(string name="user_test_seq");
       super.new(name);
     endfunction : new
  endclass : user_test_seq

  // OVC Stuff...
  class user_transaction extends uvm_sequence_item;
    rand bit[31:0] addr;
    rand bit[63:0] data;
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
    task run();
      while(1) begin
        seq_item_port.get_next_item(req);
        #1 `uvm_info("USRDRV", $sformatf("Received following transaction :\n%0s",
          req.sprint()), UVM_LOW)
        if(!req.r_wn)
          tbtest.top.dut.mem[(req.addr-'h100)/8]=req.data;
        else
          req.data=tbtest.top.dut.mem[(req.addr-'h100)/8];
        seq_item_port.item_done();
      end
    endtask
    `uvm_component_utils(user_ovc_driver)
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
  endclass

  class reg2ovc_adapter extends uvm_reg_adapter;
  
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
    `uvm_object_utils(reg2ovc_adapter)

  function new(string name="reg2ovc_adapter");
     super.new(name);
  endfunction

  endclass

  class test extends uvm_test;
  
    mmap_type model;
    user_ovc_sequencer uos;
    user_ovc_driver uod;
    user_test_seq seq;
  
    virtual function void build();
      set_config_int("uos", "count", 0);
      super.build();
      // Create register model
      model = mmap_type::type_id::create("model",this);
      model.build();
      // Create OVC sequencer
      uos = user_ovc_sequencer::type_id::create("uos", this);
      // Create OVC driver
      uod = user_ovc_driver::type_id::create("uod", this);
    endfunction
  
    virtual function void connect();
      // Set model's sequencer and adapter sequence
      reg2ovc_adapter reg2ovc = new;
      model.default_map.set_sequencer(uos, reg2ovc);
      uod.seq_item_port.connect(uos.seq_item_export);
    endfunction

    function void end_of_elaboration();
      uvm_default_printer=uvm_default_tree_printer;
      this.print(); 
      model.print();   
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      // Create register sequence
      seq=user_test_seq::type_id::create("user_test_seq", this);
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

   virtual function void report();
	uvm_report_server svr =  _global_reporter.get_report_server();
   if (svr.get_severity_count(UVM_FATAL) +
       svr.get_severity_count(UVM_ERROR) +
       svr.get_severity_count(UVM_WARNING) == 1)
       // accounts for deprecated WARNING for usage of 'count' variable in build()
      $write("** UVM TEST PASSED **\n");
   else
      $write("!! UVM TEST FAILED !!\n");
   endfunction
  endclass

  initial begin
    run_test();
  end 

  top top();
endmodule

module top;
  dut dut();
endmodule

module dut;
  // Dummy Registers
  logic [63:0] mem[0:7];
  initial begin
    bit [63:0] m;
    foreach(mem[i])
    begin
      void'(std::randomize(m));
      mem[i]=m;
      $display("Mem[%0d] = %x", i, mem[i]);
    end
  end
  function void print_mem();
    foreach(mem[i]) $display("Mem[%0d] = %x", i, mem[i]);
  endfunction
  function void reset();
    foreach(mem[i]) mem[i]='x;
  endfunction
  final print_mem();
endmodule
