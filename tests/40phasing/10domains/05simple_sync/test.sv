//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
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

// This test creates a simple hierarchy where three leaf cells belong
// to three different domains. The environment puts the three
// domains into lockstep to make sure they are phased together.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;
  bit phase_run[uvm_phase];

  class comp_type extends uvm_component;
    time start_reset, start_main, start_shutdown;
    time end_reset, end_main, end_shutdown;

    time del = 200;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task reset_phase(uvm_phase phase);
      `uvm_info("RESET", "Starting Reset", UVM_NONE)
      phase.raise_objection(this,"start reset");
      #del;
      `uvm_info("RESET", "Ending Reset", UVM_NONE)
      phase.drop_objection(this,"start reset");
    endtask
    task main_phase(uvm_phase phase);
      `uvm_info("MAIN", "Starting Main", UVM_NONE)
      phase.raise_objection(this,"start main");
      #del;
      `uvm_info("MAIN", "Ending Main", UVM_NONE)
      phase.drop_objection(this,"start main");
    endtask
    task shutdown_phase(uvm_phase phase);
      `uvm_info("SHUTDOWN", "Starting Shutdown", UVM_NONE)
      phase.raise_objection(this,"start shutdown");
      #del;
      `uvm_info("SHUTDOWN", "Ending Shutdown", UVM_NONE)
      phase.drop_objection(this,"start shutdown");
    endtask
    function void phase_started(uvm_phase phase);
      case (1)
        phase.is(uvm_reset_phase::get()): start_reset = $time;
        phase.is(uvm_main_phase::get()): start_main = $time;
        phase.is(uvm_shutdown_phase::get()): start_shutdown = $time;
      endcase
    endfunction
    function void phase_ended(uvm_phase phase);
      case (1)
        phase.is(uvm_reset_phase::get()): end_reset = $time;
        phase.is(uvm_main_phase::get()): end_main = $time;
        phase.is(uvm_shutdown_phase::get()): end_shutdown = $time;
      endcase
    endfunction
  endclass

  class test extends uvm_component;
    comp_type l1, l2;
    uvm_domain domain1=new("domain1"), domain2=new("domain2");

    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      l1 = new("l1", this);
      l2 = new("l2", this);
      l2.del = 250;
      l1.set_domain(domain1);
      l2.set_domain(domain2);

      //Sync domain2 start of main with domain1 start of post_reset_ph
      domain1.sync(domain2, uvm_main_phase::get(), uvm_post_reset_phase::get());
    endfunction

    // This needs to be fixed. Right now it is needed.
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
      $display("l1  reset: %0t  -- %0t", l1.start_reset, l1.end_reset);
      $display("l1  main: %0t  -- %0t", l1.start_main, l1.end_main);
      $display("l1  shutdown: %0t  -- %0t", l1.start_shutdown, l1.end_shutdown);
      $display("l2  reset: %0t  -- %0t", l2.start_reset, l2.end_reset);
      $display("l2  main: %0t  -- %0t", l2.start_main, l2.end_main);
      $display("l2  shutdown: %0t  -- %0t", l2.start_shutdown, l2.end_shutdown);

      if( l1.start_reset != 0  || l1.end_reset != 200) begin
        $display("*** UVM TEST FAILED, l1 reset %0t-%0t, expected 0-200 ***", l1.start_reset, l1.end_reset);
        failed = 1;
      end
      // Since synced with l2, the mains start at the same time
      if( l1.start_main != 250  || l1.end_main != 450) begin
        $display("*** UVM TEST FAILED, l1 main %0t-%0t, expected 250-450 ***", l1.start_main, l1.end_main);
        failed = 1;
      end
      if( l1.start_shutdown != 450  || l1.end_shutdown != 650) begin
        $display("*** UVM TEST FAILED, l1 shutdown %0t-%0t, expected 450-650 ***", l1.start_shutdown, l1.end_shutdown);
        failed = 1;
      end
      if( l2.start_reset != 0  || l2.end_reset != 250) begin
        $display("*** UVM TEST FAILED, l2 reset %0t-%0t, expected 0-250 ***", l2.start_reset, l2.end_reset);
        failed = 1;
      end
      // Since synced with l2, the mains start at the same time
      if( l2.start_main != 250  || l2.end_main != 500) begin
        $display("*** UVM TEST FAILED, l2 main %0t-%0t, expected 250-500 ***", l2.start_main, l2.end_main);
        failed = 1;
      end
      if( l2.start_shutdown != 500  || l2.end_shutdown != 750) begin
        $display("*** UVM TEST FAILED, l2 shutdown %0t-%0t, expected 500-750 ***", l2.start_shutdown, l2.end_shutdown);
        failed = 1;
      end
 
      if(!failed) 
        $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial run_test();
endmodule
