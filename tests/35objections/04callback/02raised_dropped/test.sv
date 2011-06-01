//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
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

module test;

  // This is an example of the raised and dropped callbacks. 
  // this scenario we will have:
  //   1.  A sequence, silly_sequence, that:
  //         a.  when it starts up, raises a test done objection
  //         b.  when it finishes, drops a test done objection
  //         c.  sends 10 packets that are #10 apart temporally
  //   2.  A sequencer that:
  //         a.  is set to start the silly_sequence as the default_sequence
  //   3.  A driver that just takes the packets and does nothing but keeps
  //       traffic coming (burns #10).
  //   4.  An agent that:
  //         a.  contains two drivers and the two sequencers
  //   5.  A test that:
  //         a.  contains the agent
  //         b.  sets up raised and dropped callbacks 
  //            

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class simple_item extends uvm_sequence_item;
    `uvm_object_utils(simple_item)
    function new (string name="simple_item");
      super.new(name);
    endfunction : new
  endclass : simple_item

  class simple_sequencer extends uvm_sequencer #(simple_item);
    `uvm_sequencer_utils(simple_sequencer)
    function new (string name, uvm_component parent);
      super.new(name, parent);
      `uvm_update_sequence_lib_and_item(simple_item)
    endfunction : new
  endclass : simple_sequencer

  class simple_seq extends uvm_sequence #(simple_item);
    function new(string name="simple_seq");
      super.new(name);
    endfunction
    `uvm_sequence_utils(simple_seq, simple_sequencer)    
    virtual task body();
      p_sequencer.uvm_report_info("SEQ_BODY", "simple_seq body() is starting...", UVM_LOW);
      #50;
      // Raising one uvm_test_done objection
      uvm_test_done.raise_objection(this, "foo",3);
      for (int i = 0; i < 10; i++) begin
        `uvm_do(req)
        #10;
      end
      uvm_test_done.drop_objection(this,"bar",3);
      p_sequencer.uvm_report_info("SEQ_BODY", "simple_seq body() is ending...", UVM_LOW);
    endtask
  endclass : simple_seq

  class simple_driver extends uvm_driver #(simple_item);
    int i = 0;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(simple_driver)
    task run();
      while(1) begin
        seq_item_port.get_next_item(req);
        uvm_report_info("DRV_RUN", $sformatf("driver item %0d...", i), UVM_LOW);
        i++;
        #10;
        seq_item_port.item_done();
      end
    endtask: run
  endclass : simple_driver

  class simple_agent extends uvm_agent;
    simple_sequencer sequencer;
    simple_driver driver;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(simple_agent)
    function void build();
      super.build();
      sequencer = simple_sequencer::type_id::create("sequencer", this);
      driver = simple_driver::type_id::create("driver", this);
    endfunction
    function void connect();
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction 
  endclass : simple_agent

  class test extends uvm_test;
    int rcnt = 0, dcnt = 0;
    bit failed = 0;
    simple_agent agent1, agent2;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(test)
    function void build();
      super.build();
      set_config_string("agent?.sequencer", "default_sequence", "simple_seq");
      agent1 = simple_agent::type_id::create("agent1", this);
      agent2 = simple_agent::type_id::create("agent2", this);
    endfunction
    function void start_of_simulation();
      this.print();
    endfunction
    task run();
      uvm_test_done.raise_objection(this);
      #200 uvm_test_done.drop_objection(this);  
    endtask
    virtual function void raised (uvm_objection objection, 
      uvm_object source_obj, string description, int count);

      cb("RAISED", objection, source_obj, count);
      rcnt+=count;
      if(source_obj != this && description != "foo") begin
         failed = 1;
         $display("** UVM TEST FAILED **");
      end
    endfunction
    virtual function void dropped (uvm_objection objection, 
      uvm_object source_obj, string description, int count);

      cb("DROPPED", objection, source_obj, count);
      dcnt += count;
      if(source_obj != this && description != "bar") begin
         failed = 1;
         $display("** UVM TEST FAILED **");
      end
    endfunction
    function void report();
      if(failed) return;
      //two seqs run and raise/drop 3 each, plus the env raises/drops 1.
      if(rcnt != 7) $display("** UVM TEST FAILED rcnt: %0d  exp: %0d **", rcnt, 7);
      if(dcnt != 7) $display("** UVM TEST FAILED dcnt: %0d  exp: %0d **", dcnt, 7);
      $display("** UVM TEST PASSED **");
    endfunction 
    virtual function void cb (string tp, uvm_objection objection, 
      uvm_object source_obj, int count);
      
      uvm_report_info(tp, $sformatf("Got callback from %s: objection count is: %0d  total count is: %0d", source_obj.get_full_name(), objection.get_objection_count(this), objection.get_objection_total(this)), UVM_NONE);
    endfunction
  endclass : test

  initial
    run_test("test");

endmodule
