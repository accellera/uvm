//---------------------------------------------------------------------- 
//   Copyright 2010 Cadence Design Systems, Inc.
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

// This test creates a simple hierarchy where two leaf cells belong
// to two different domains. It verifies that the domains run
// independently in the runtime phases but togehter in the common
// phases.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;
  bit phase_run[uvm_phase_imp];

  class base extends uvm_component;
    bit dodelay=1;
    time thedelay = 300;
    time maxdelay = 5*thedelay;

    function new(string name, uvm_component parent);
      super.new(name,parent);
      set_phase_schedule("uvm");
    endfunction
    function void build_phase;
      phase_run[uvm_build_ph] = 1;
      `uvm_info("BUILD", "Starting Build", UVM_NONE)
      if($time != 0)  begin
        failed = 1;
        `uvm_error("BUILD", "Expected Build start time of 0")
      end
      `uvm_info("BUILD", "Ending Build", UVM_NONE)
    endfunction
    task reset_phase(uvm_phase_schedule phase);
      phase.raise_objection(this,"start reset");
      phase_run[uvm_reset_ph] = 1;
      `uvm_info("RESET", "Starting Reset", UVM_NONE)
      if($time != 0)  begin
        failed = 1;
        `uvm_error("RESET", "Expected Reset start time of 0")
      end
      if(dodelay) #thedelay;
      `uvm_info("RESET", "Ending Reset", UVM_NONE)
      phase.drop_objection(this,"end reset");
    endtask
    task main_phase(uvm_phase_schedule phase);
      phase.raise_objection(this,"start main");
      phase_run[uvm_main_ph] = 1;
      `uvm_info("MAIN", "Starting Main", UVM_NONE)
      if($time != thedelay)  begin
        failed = 1;
        `uvm_error("MAIN", $sformatf("Expected Main start time of %0t",thedelay))
      end
      if(dodelay) #thedelay;
      `uvm_info("MAIN", "Ending Main", UVM_NONE)
      phase.drop_objection(this,"end main");
    endtask
    task shutdown_phase(uvm_phase_schedule phase);
      phase.raise_objection(this,"start shutdown");
      phase_run[uvm_shutdown_ph] = 1;
      `uvm_info("SHUTDOWN", "Starting Shutdown", UVM_NONE)
      if($time != (2*thedelay))  begin
        failed = 1;
        `uvm_error("SHUTDOWN", $sformatf("Expected Shutdown start time of %0t",2*thedelay))
      end
      if(dodelay) #thedelay;
      `uvm_info("SHUTDOWN", "Ending Shutdown", UVM_NONE)
      phase.drop_objection(this,"end shutdown");
    endtask
    task run_phase(uvm_phase_schedule phase);
      phase.raise_objection(this,"start run");
      phase_run[uvm_run_ph] = 1;
      `uvm_info("RUN", "Starting Run", UVM_NONE)
      if($time != 0)  begin
        failed = 1;
        `uvm_error("RUN", "Expected Run start time of 0")
      end
      if(dodelay) #(5*thedelay);
      `uvm_info("RUN", "Ending Run", UVM_NONE)
      phase.drop_objection(this,"end run");
    endtask
    function void extract_phase;
      phase_run[uvm_extract_ph] = 1;
      `uvm_info("EXTRACT", "Starting Extract", UVM_NONE)
      if($time != maxdelay)  begin
        failed = 1;
        `uvm_error("extract", $sformatf("Expected extract start time of %0t",maxdelay))
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
      l1.thedelay = 150;
      l1.maxdelay = 1500;
      l2 = new("l2", this);
      l1.set_phase_domain("domain1");
      l2.set_phase_domain("domain2");
    endfunction
    function void report_phase();
      phase_run[uvm_report_ph] = 1;
      if(phase_run.num() != 7) begin
        failed = 1;
        `uvm_error("NUMPHASES", $sformatf("Expected 6 phases, got %0d", phase_run.num()))
      end
      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial run_test();
endmodule
