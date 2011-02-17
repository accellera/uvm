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

// This test creates a simple hierarchy and makes sure that phases
// start at the correct time. The env has no delays in it so all
// phase processed in the env end immediately.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;
  bit phase_run[uvm_phase];

  class base extends uvm_component;
    bit dodelay=1;
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
        `uvm_error("RESET", "Expected Reset start time of 0")
      end
      if(dodelay) #100;
      `uvm_info("RESET", "Ending Reset", UVM_NONE)
      phase.drop_objection(this);
    endtask
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase_run[uvm_main_phase::get()] = 1;
      `uvm_info("MAIN", "Starting Main", UVM_NONE)
      if($time != 100)  begin
        failed = 1;
        `uvm_error("MAIN", "Expected Main start time of 0")
      end
      if(dodelay) #100;
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
      if(dodelay) #1000;
      `uvm_info("RUN", "Ending Run", UVM_NONE)
      phase.drop_objection(this);
    endtask
    function void extract_phase(uvm_phase phase);
      phase_run[uvm_extract_phase::get()] = 1;
      `uvm_info("EXTRACT", "Starting Extract", UVM_NONE)
      if($time != 1000)  begin
        failed = 1;
        `uvm_error("extract", "Expected extract start time of 1000")
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
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      l1 = new("l1", this);
      l2 = new("l2", this);
      dodelay = 0;
    endfunction
    function void report_phase(uvm_phase phase);
      phase_run[uvm_report_phase::get()] = 1;
      if(phase_run.num() != 6) begin
        failed = 1;
        `uvm_error("NUMPHASES", $sformatf("Expected 6 phases, got %0d", phase_run.num()))
      end
      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial run_test();
endmodule
