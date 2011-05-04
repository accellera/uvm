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

// This test creates a simple hierarchy and makes sure that the
// phase_started and phase_ended callbacks are all called once per
// component and in the correct order.
//
// The order is:
//   build
//   connect
//   end_of_elaboration
//   start_of_simulation
//   run
//     pre_reset
//     reset
//     post_reset
//     pre_configure
//     configure
//     post_configure
//     pre_main
//     main
//     post_main
//     pre_shutdown
//     shutdown
//     post_shutdown
//  extract
//  check
//  report
//  final


module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;
  int counter = 0;

  class base extends uvm_component;
    int phase_count[string];
    string last_phase="";

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    //for parallel phase have two possible last phases
    function void check_phase_callback(uvm_phase phase, string last, string last2);
      string ph = phase.get_name();
      `uvm_info("CHECKER", "  Checking a phase...", UVM_NONE)
      if(last != last_phase && last2 != last_phase) begin
        `uvm_error("LAST_PH", $sformatf("Incorrect last phase, expected %s got %s", last, last_phase))
        failed = 1;
      end
      if(phase_count[ph] != phase.get_run_count()) begin
        `uvm_error("EXECUTED", $sformatf("Expected phase count %0d for %s, but got %0d", phase_count[ph], ph, phase.get_run_count()))
        failed = 1;
      end
      counter++;
      last_phase = ph;
    endfunction

    function void phase_started(uvm_phase phase);
      string last, last2;
      `uvm_info("STARTED", $sformatf("Phase started for phase %s", phase.get_name()), UVM_NONE)
      if(phase_count.exists(phase.get_name()))
        phase_count[phase.get_name()]++;
      else
        phase_count[phase.get_name()] = 1;

      case(phase.get_name())
        "build": last = "";
        "connect": last = "build";
        "end_of_elaboration": last = "connect";
        "start_of_simulation": last = "end_of_elaboration";
        "run": 
           begin 
              last = "start_of_simulation";
              //last2 = "pre_reset";
           end
        "pre_reset": 
           begin 
              last = "start_of_simulation";
              last2 = "run"; // account for race: if 'run' starts before 'pre_reset', it will be the last phase
           end
        "reset": begin
              last = "pre_reset";
              last2 = "main"; //from jump_back
           end
        "post_reset": last = "reset";
        "pre_configure": last = "post_reset";
        "configure": last = "pre_configure";
        "post_configure": last = "configure";
        "pre_main": last = "post_configure";
        "main": last = "pre_main";
        "post_main": last = "main";
        "pre_shutdown": last = "post_main";
        "shutdown": last = "pre_shutdown";
        "post_shutdown": last = "shutdown";
        "extract": 
           begin 
              last = "run";
              last2 = "post_shutdown";
           end
        "check": last = "extract";
        "report": last = "check";
        "final": last = "report";
      endcase
      if(last2 == "") last2 = last;
      check_phase_callback(phase, last, last2); 
    endfunction    

    function void phase_ended(uvm_phase phase);
      string last, last2;
      `uvm_info("ENDED", $sformatf("Phase ended for phase %s", phase.get_name()), UVM_NONE)
      case(phase.get_name())
        "build": last = "build";
        "connect": last = "connect";
        "end_of_elaboration": last = "end_of_elaboration";
        "start_of_simulation": last = "start_of_simulation";
        "run": 
           begin 
              last = "run";
              last2 = "post_shutdown";
           end
        "pre_reset": last = "pre_reset";
        "reset": last = "reset";
        "post_reset": last = "post_reset";
        "pre_configure": last = "pre_configure";
        "configure": last = "configure";
        "post_configure": last = "post_configure";
        "pre_main": last = "pre_main";
        "main": last = "main";
        "post_main": last = "post_main";
        "pre_shutdown": last = "pre_shutdown";
        "shutdown": last = "shutdown";
        "post_shutdown": 
           begin 
              last = "run";
              last2 = "post_shutdown";
           end
        "extract": last = "extract";
        "check": last = "check";
        "report": last = "report";
        "final": last = "final";
      endcase
      if(last2 == "") last2 = last;
      check_phase_callback(phase, last, last2); 
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
    endfunction

    task main_phase(uvm_phase phase);
      static bit first=1;
      phase.raise_objection(this);
      #10;
      if(first) begin
        first = 0;
        phase.jump (uvm_reset_phase::get());
      end
      phase.drop_objection(this);
    endtask
    function void final_phase(uvm_phase phase);
      // 21 calls per component for three components (63) for phase started
      // 20 calls for three components (60) for phase ended (since final is still going)
      //
      // Additional calls for jump back from main to reset means that reset, post_reset,
      //    pre_configure, configure, post_configure, pre_main and main all run again.
      //    So, add 7 more calls for each component (21) for both phase started and
      //    phase_ended: 84 for STARTED, 81 for ENDED
      // But, the ENDED callbacks for *this* final phase won't have been counted yet.
      // So we expect 84 for STARTED (fully counted, because it is a bottom-up phase),
      // and 81 for ENDED => 165
      if(counter != 165) begin
        failed = 1;
        `uvm_error("NUMPHASES", $sformatf("Expected 162 phases, got %0d", counter))
      end
      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial run_test();
endmodule
