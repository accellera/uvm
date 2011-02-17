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

  // This is an example of some of the usages of the objection mechanism.  In
  // this scenario we will have:
  //   1.  A component, simple_component, that:
  //         a.  raises a test done objection at 10 ns
  //         b.  drops a test done objection at 110 ns (which will in this test
  //         start the agent's drain time of 93)
  //         c.  raises a test done objection at 200 ns (this will interrupt the
  //         shutdown)
  //         d.  drops a test done objection at 350 ns (this will let the test
  //         finish at 443 ns)
  //   2.  An agent that:
  //         a.  contains the component
  //         b.  has a drain time of #93 (odd on purpose!).
  //   3.  A test that:
  //         a.  contains the agent

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class simple_component extends uvm_component;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(simple_component)
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10 phase.raise_objection(this);
      #100 phase.drop_objection(this);
      #90 phase.raise_objection(this);
      #150 phase.drop_objection(this);
      phase.drop_objection(this);
    endtask
  endclass : simple_component

  class simple_agent extends uvm_agent;
    simple_component component;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    // Set the agent's drain time.
    task run_phase(uvm_phase phase);
      phase.phase_done.set_drain_time(this, 93);
    endtask
    `uvm_component_utils(simple_agent)
    function void build();
      super.build();
      component = simple_component::type_id::create("component", this);
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
      agent = simple_agent::type_id::create("agent", this);
    endfunction
    function void start_of_simulation();
      this.print();
    endfunction
    function void report();
      //component should reraise during drain, so it will run the
      //full 350 plus the final 93 drain
      if($time != 443) begin
        $display("** UVM TEST FAILED time: %0t  exp: 443", $time);
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction
  endclass : test

  initial begin
    //uvm_test_done.set_report_verbosity_level(UVM_FULL);
    run_test("test");
  end


endmodule
