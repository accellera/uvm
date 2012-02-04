//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc. 
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



`include "uvm.sv"
import uvm_pkg::*;

//=======================================================================
class cust_data extends uvm_sequence_item;
  int prop;

  `uvm_object_utils_begin(cust_data)
    `uvm_field_int(prop, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="cust_data");
    super.new(name);
  endfunction

endclass

//=======================================================================
class cust_driver extends uvm_driver#(cust_data);
  `uvm_component_utils(cust_driver)

  function new(string name = "cust_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task get_and_display(int thread_id);
    REQ item;
    forever begin
      `uvm_info("get_and_display", $sformatf("thread_id=%0d top of loop", thread_id), UVM_LOW);
      seq_item_port.get_next_item(item);
      seq_item_port.item_done();
      item.print();
    end
  endtask

  virtual protected task run_phase(uvm_phase phase);
    super.run_phase(phase);

    // Starting two threads to manage the seq_item_port
    fork
      get_and_display(1);
      get_and_display(2);
    join_none
  endtask

endclass

//=======================================================================
typedef uvm_sequencer#(cust_data) cust_sequencer;

//=======================================================================
class cust_agent extends uvm_agent;
  `uvm_component_utils(cust_agent)

  cust_driver driver;

  cust_sequencer sequencer;

  function new(string name = "cust_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  protected function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = cust_driver::type_id::create("driver", this);
    sequencer = cust_sequencer::type_id::create("sequencer", this);
  endfunction

  protected function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass

//=======================================================================
class cust_data_sequence extends uvm_sequence#(cust_data);
  `uvm_object_utils(cust_data_sequence)

  function new(string name = "cust_data_sequence");
     super.new(name);
  endfunction

  virtual task pre_body();
    if (starting_phase!=null) starting_phase.raise_objection(this);
  endtask : pre_body

  virtual task body();
    `uvm_do(req);
  endtask

  virtual task post_body();
    if (starting_phase!=null) starting_phase.drop_objection(this);
  endtask : post_body

endclass

//=======================================================================
class fatal_catcher extends uvm_report_catcher;
  int seen = 0;
  virtual function action_e catch();
    if (get_severity() == UVM_FATAL && get_id() == "uvm_test_top.agent.sequencer" &&
        (get_message() == "Concurrent calls to send_request() not supported. Check your driver for concurrent calls to get_next_item()" || 
         get_message() == "Item_done() called with no outstanding requests. Each call to item_done() must be paired with a previous call to get_next_item().")) begin
      seen++;
      return CAUGHT;
    end else begin
      return THROW;
    end
  endfunction
endclass

//=======================================================================
class test extends uvm_test;

  `uvm_component_utils(test)

  cust_agent agent;

  fatal_catcher catcher;
  
  function new(string name = "cust_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    agent = cust_agent::type_id::create("agent", this);
    catcher = new;
    uvm_report_cb::add(null,catcher);
  endfunction

  virtual task main_phase(uvm_phase phase);
    cust_data_sequence seq1, seq2;
    super.main_phase(phase);

    seq1 = new("seq1");
    seq2 = new("seq2");

    phase.raise_objection(this);
    fork
      seq1.start(agent.sequencer);
      seq2.start(agent.sequencer);
    join_none
    phase.drop_objection(this);
  endtask

   function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0 && 
          catcher.seen == 2)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass

//=======================================================================
module test_top;
  initial run_test();
endmodule
