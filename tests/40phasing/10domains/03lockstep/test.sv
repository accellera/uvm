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

  class base extends uvm_component;
    time localdelay = 100;
    time domaindelay = 300;

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    function void build;
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
      #localdelay;
      `uvm_info("RESET", "Ending Reset", UVM_NONE)
      phase.drop_objection(this);
    endtask
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase_run[uvm_main_phase::get()] = 1;
      `uvm_info("MAIN", "Starting Main", UVM_NONE)
      if($time != domaindelay)  begin
        failed = 1;
        `uvm_error("MAIN", $sformatf("Expected Main start time of %0t",domaindelay))
      end
      #localdelay;
      `uvm_info("MAIN", "Ending Main", UVM_NONE)
      phase.drop_objection(this);
    endtask
    task shutdown_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase_run[uvm_shutdown_phase::get()] = 1;
      `uvm_info("SHUTDOWN", "Starting Shutdown", UVM_NONE)
      if($time != (2*domaindelay))  begin
        failed = 1;
        `uvm_error("SHUTDOWN", $sformatf("Expected Shutdown start time of %0t",2*domaindelay))
      end
      #localdelay;
      `uvm_info("SHUTDOWN", "Ending Shutdown", UVM_NONE)
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
      #(5*localdelay);
      `uvm_info("RUN", "Ending Run", UVM_NONE)
      phase.drop_objection(this);
    endtask
    function void extract;
      phase_run[uvm_extract_phase::get()] = 1;
      `uvm_info("EXTRACT", "Starting Extract", UVM_NONE)
      if($time != 5*domaindelay)  begin
        failed = 1;
        `uvm_error("extract", $sformatf("Expected extract start time of %0t",5*domaindelay))
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
    leaf l1, l2, l3; 
    uvm_domain domain1=new("domain1"), domain2=new("domain2"), domain3=new("domain3");

    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      l1 = new("l1", this);
      l2 = new("l2", this);
      l3 = new("l3", this);
      l3.localdelay = 250;
      l1.localdelay = l1.domaindelay;
      set_domain(domain1);
      //l1.set_domain(domain1);
      l2.set_domain(domain2);
      l3.set_domain(domain3);

      //Lockstep the domains
      l2.domaindelay = l1.domaindelay;
      l3.domaindelay = l1.domaindelay;
      domain1.sync(domain2);
      domain1.sync(domain3);
    endfunction
//    task run_phase(uvm_phase phase);
//      phase.raise_objection(this);
//      phase.drop_objection(this);
//    endtask
    function void report();
      phase_run[uvm_report_phase::get()] = 1;
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
