//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
//   Copyright 2010-2011 Mentor Graphics Corporation
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

// This test creates a simple hierarchy and makes sure that a
// component can create objections to phase processing independent
// of the implicit objections.
//
// The top component executes a run phase that raises objections for
// three phases and drops the objections at desired times to let
// the phasing move forward.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;
  time phase_transition_time = 1000;
  bit phase_run[uvm_phase];

  class base extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    function void build_phase(uvm_phase phase);
      phase_run[uvm_build_phase::get()] = 1;
      `uvm_info("BUILD", "Starting Build", UVM_NONE)
      if($time != 0)  begin
        failed = 1;
        `uvm_error("BUILD", "Expected Build start time of 0")
      end
      `uvm_info("BUILD", "Ending Build", UVM_NONE)
    endfunction
    task reset_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase_run[uvm_reset_phase::get()] = 1;
      `uvm_info("RESET", "Starting Reset", UVM_NONE)
      if($time != 0)  begin
        failed = 1;
        `uvm_error("RESET", $sformatf("Expected Reset start time of 0, got %0t its now %0t", phase_transition_time, $time))
      end
      #100;
      `uvm_info("RESET", "Ending Reset", UVM_NONE)
      phase.drop_objection(this);
    endtask
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase_run[uvm_main_phase::get()] = 1;
      `uvm_info("MAIN", "Starting Main", UVM_NONE)
      // Even though there is not configure phase, the test is holding
      // up the configure phase.
      if($time != 2*phase_transition_time)  begin
        failed = 1;
        `uvm_error("MAIN", $sformatf("Expected main start time of %0t, got %0t", 2*phase_transition_time, $time))
      end
      #100;
      `uvm_info("MAIN", "Ending Main", UVM_NONE)
      phase.drop_objection(this);
    endtask
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase_run[uvm_run_phase::get()] = 1;
      `uvm_info("RUN", "Starting Run", UVM_NONE)
      if($time != 0)  begin
        failed = 1;
        `uvm_error("RUN", "Expected Run start time of 0")
      end
      #100;
      `uvm_info("RUN", "Ending Run", UVM_NONE)
      phase.drop_objection(this);
    endtask
    function void extract_phase(uvm_phase phase);
      phase_run[uvm_extract_phase::get()] = 1;
      `uvm_info("EXTRACT", "Starting Extract", UVM_NONE)
      if($time != 3*phase_transition_time)  begin
        failed = 1;
        `uvm_error("extract", $sformatf("Expected extract start time of %0t but got %0t", 3*phase_transition_time, $time))
      end
      `uvm_info("EXTRACT", "Ending Extract", UVM_NONE)
    endfunction
  endclass

  class leaf extends base;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass
  class test extends base;
    leaf l1, l2; 
    int phases_run = 0;

    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      l1 = new("l1", this);
      l2 = new("l2", this);
    endfunction
    function void connect_phase(uvm_phase phase);
    endfunction

    // Do objections to phases proceeding
    task run_phase(uvm_phase phase);
      uvm_domain uvm_d = uvm_domain::get_uvm_domain();
      uvm_phase reset_p = uvm_d.find(uvm_reset_phase::get());
      uvm_phase config_p = uvm_d.find(uvm_configure_phase::get());
      uvm_phase main_p = uvm_d.find(uvm_main_phase::get());

      `uvm_info("TEST_RUN","Setting up objections to certain phases",UVM_NONE)
      //Do the raise, wait, drop for each phase
      fork
        do_phase_test(reset_p);
        do_phase_test(config_p);
        do_phase_test(main_p);
      join
      `uvm_info("TEST_RUN","Ending run phase",UVM_NONE)
    endtask

    task do_phase_test(uvm_phase phase);
      //Raise the objection
      phase.raise_objection(this, {"test ", phase.get_name(), " objection"});
     
      //Wait for phase to be started
       phase.wait_for_state(UVM_PHASE_EXECUTING, UVM_EQ);

      //Wait for the desired time 
      #(phase_transition_time);

      //Drop the objection
      phase.drop_objection(this, {"test ", phase.get_name(), " objection"});
      ++phases_run;
    endtask

    function void report_phase(uvm_phase phase);
      phase_run[uvm_report_phase::get()] = 1;
      if(phase_run.num() != 6) begin
        failed = 1;
        `uvm_error("NUMPHASES", $sformatf("Expected 6 phases, got %0d", phase_run.num()))
      end
      if(phases_run != 3) begin
        failed = 1;
        `uvm_error("NUMOBJS", $sformatf("Expected 3 objection processes, got %0d", phases_run))
      end
      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial run_test();
endmodule
