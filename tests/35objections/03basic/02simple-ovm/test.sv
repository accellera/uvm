//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
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

module test;

  // This is an example of the most basic usage of the objection mechanism.  In
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
  //         a.  contains the driver and the sequencer
  //   5.  A test that:
  //         a.  contains the agent
  //         b.  sets the drain time for uvm_test_done to 93 for the agent

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
      uvm_test_done.raise_objection(this);
      p_sequencer.uvm_report_info("SEQ_BODY", "simple_seq body() is starting...", UVM_LOW);
      #50;
      // Raising one uvm_test_done objection
      for (int i = 0; i < 10; i++) begin
        `uvm_do(req)
        #10;
      end
      uvm_test_done.drop_objection(this);
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
    simple_agent agent;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(test)
    function void build();
      super.build();
      set_config_string("agent.sequencer", "default_sequence", "simple_seq");
      agent = simple_agent::type_id::create("agent", this);
      uvm_test_done.set_drain_time(this, 93);
    endfunction
    function void start_of_simulation();
      this.print();
    endfunction
    function void report();
      //time should get to 343, 150 for the sequence, 100 for the driver and 93 
      //for the drain-off.
      if($time == 343) $display("** UVM TEST PASSED **");
      else $display("** UVM TEST FAILED **");
      $display("Time=%0t",$time);
    endfunction 
  endclass : test

  initial
    run_test("test");

endmodule
