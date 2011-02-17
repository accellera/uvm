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

module top;

  // This test is a variation on the late_raiser_example.sv that shows if you
  // try to raise an objection "too late" (after drain time expired) that the
  // simulation will stop per the expiration of the drain time).

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class simple_component extends uvm_component;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(simple_component)
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10; 
      #100 phase.drop_objection(this);
      #100 phase.raise_objection(this);
      #150 phase.drop_objection(this);
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
      //this time reraise happens after drain is complete so it is not seen.
      //So, this test will end at 203.
      if($time != 203) begin
        $display("** UVM TEST FAILED time: %0t  exp: 203", $time);
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction
  endclass : test

  initial
    run_test("test");

endmodule
