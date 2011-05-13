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

// Test for mantis 3532, calling phase.jump() for a forward jump
// marks all successors as done, not just the successors in the forward
// path. This causes, for example, simulation to end if the run
// phase is already waiting for end and a jump forward happens in
// the runtime phases.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit main_run=0, shutdown_run=0, post_shutdown_run = 0;
  bit failed = 0;
  class comp extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    task reset_phase(uvm_phase phase);
      phase.raise_objection(this); 
      `uvm_info("RESET","Start reset...",UVM_NONE);
      #10
      `uvm_info("RESET","End reset...",UVM_NONE);
      phase.drop_objection(this); 
    endtask

    task main_phase(uvm_phase phase);
      phase.raise_objection(this); 
      `uvm_info("MAIN","Start main...",UVM_NONE);
      #10
      main_run = 1;
      `uvm_info("MAIN","End main...",UVM_NONE);
      phase.drop_objection(this); 
    endtask

    task shutdown_phase(uvm_phase phase);
      phase.raise_objection(this); 
      `uvm_info("SHUTDOWN","Start shutdown...",UVM_NONE);
      #10
      shutdown_run = 1;
      `uvm_info("SHUTDOWN","End shutdown...",UVM_NONE);
      phase.drop_objection(this); 
    endtask

    task post_shutdown_phase(uvm_phase phase);
      phase.raise_objection(this); 
      `uvm_info("POSTSHUTDOWN","Start post_shutdown...",UVM_NONE);
      #10
      post_shutdown_run = 1;
      `uvm_info("POSTSHUTDOWN","End post_shutdown...",UVM_NONE);
      phase.drop_objection(this); 
    endtask
  endclass

  class test extends uvm_component;
    comp c1, c2;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      c1 = new("c1", this);
      c2 = new("c2", this);
    endfunction

    task reset_phase(uvm_phase phase);
      uvm_domain dom = phase.get_domain();
      uvm_phase shutdown = dom.find(uvm_shutdown_phase::get());
      phase.raise_objection(this); 
      #5 `uvm_info("DOJUMP", "Jumping to shutdown...", UVM_NONE)
      phase.jump(shutdown);
      phase.drop_objection(this); 
    endtask

    task run_phase(uvm_phase phase);
      phase.raise_objection(this); 
      phase.drop_objection(this); 
    endtask

    function void phase_ended(uvm_phase phase);
       $display("#### %0t: PHASED ENDED FOR %s", $time, phase.get_name());
       if ((phase.get_name() == "run") && ($time != 25)) begin
          $display("*** UVM TEST FAILED : Expected run to finish at time 25, got time %0t", $time);
          failed = 1;
       end
    endfunction : phase_ended

    task shutdown_phase(uvm_phase phase);
      uvm_domain dom = phase.get_domain();
      uvm_phase post_shutdown = dom.find(uvm_post_shutdown_phase::get());
      uvm_phase_state state = post_shutdown.get_state();
      if(state != UVM_PHASE_DORMANT) begin
        $display("**** UVM TEST FAILED : In shutdown phase, expect post_shutdown state to be UVM_PHASE_DORMANT, but got %s", state.name());
        failed = 1;
      end
    endtask

    function void report_phase(uvm_phase phase);
      `uvm_info("REPORT", "In report phase!!!!", UVM_NONE)
      if($time != 25) begin
        $display("*** UVM TEST FAILED : Expected finish at time 25, got time %0t", $time);
        failed = 1;
      end
      if(main_run == 1) begin
        $display("*** UVM TEST FAILED : Expected the main phase to be skipped, but it ran");
        failed = 1;
      end
      if(shutdown_run == 0) begin
        $display("*** UVM TEST FAILED : Expected the shutdown phase to be run, but it was skipped");
        failed = 1;
      end
      if(post_shutdown_run == 0) begin
        $display("*** UVM TEST FAILED : Expected the post_shutdown phase to be run, but it was skipped");
        failed = 1;
      end


      if(!failed)
        $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial run_test();
endmodule
