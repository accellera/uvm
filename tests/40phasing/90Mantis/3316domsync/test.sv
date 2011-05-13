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

// The test verifies that the phase_started and phase_ended callbacks
// are called for each component that participates in a phase.

//Use run_tests script on the following test.sv:

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;
// bit phase_run[uvm_phase];



  class base extends uvm_component;
    bit dodelay=1;
// int phase_count ;
    time thedelay = 300;
// time maxdelay = 5*thedelay;

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction



    task reset_phase(uvm_phase phase);
      phase.raise_objection(this, "start reset");
      if(dodelay) #thedelay;
      `uvm_info("RESET",$sformatf("Finished waiting %d",thedelay),UVM_NONE);
      phase.drop_objection(this, "start reset");
    endtask

    task main_phase(uvm_phase phase);
      phase.raise_objection(this, "start main");
      if(dodelay) #thedelay;
      `uvm_info("MAIN",$sformatf("Finished waiting %d",thedelay),UVM_NONE);
      phase.drop_objection(this, "start main");
    endtask

    task shutdown_phase(uvm_phase phase);
      phase.raise_objection(this, "start shutdown");
      if(dodelay) #thedelay;
      `uvm_info("SHUTDOWN",$sformatf("Finished waiting %d",thedelay),UVM_NONE);
      phase.drop_objection(this, "start shutdown");
    endtask

    task run_phase(uvm_phase phase);

// if(dodelay) #(5*thedelay);
    endtask


  endclass

  /////////////////////////////////////////

  class leaf extends base;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass

  /////////////////////////////////////////

  class hier extends base;
    leaf leaf1, leaf2 ;
    time phase_started_called[string];
    time phase_ended_called[string];
    int flag = 0 ;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      leaf1 = new("leaf1",this) ;
      leaf1.thedelay = 150 ;
      leaf2 = new("leaf2",this) ;
      leaf2.thedelay = 100 ;
      thedelay = 0 ;
    endfunction
    function void phase_started (uvm_phase phase);
      string pre_phase = "NONE", pre_phase2 = "NONE";
      time pre_phase_end_time=-1; 
      `uvm_info("PHASE",$sformatf("Starting %s",phase.get_name()),UVM_NONE);
      phase_started_called[phase.get_name()] = $time;
      case(phase.get_name())
        // Common phases
        "build": begin pre_phase = "NONE"; end
        "connect": begin pre_phase = "build"; end
        "end_of_elaboration": begin pre_phase = "connect"; end
        "start_of_simulation": begin pre_phase = "end_of_elaboration"; end
        "run": begin pre_phase = "start_of_simulation"; end
        "extract": begin pre_phase = "post_shutdown"; pre_phase2 = "run"; end
        "check": begin pre_phase = "extract"; end
        "report": begin pre_phase = "check"; end
        "final": begin pre_phase = "report"; end
        // RT phases
        "pre_reset": begin pre_phase = "start_of_simulation"; end
        "reset": begin pre_phase = "pre_reset"; end
        "post_reset": begin pre_phase = "reset"; end
        "pre_configure": begin pre_phase = "post_reset"; end
        "configure": begin pre_phase = "pre_configure"; end
        "post_configure": begin pre_phase = "configure"; end
        "pre_main": begin pre_phase = "post_configure"; end
        "main": begin pre_phase = "pre_main"; end
        "post_main": begin pre_phase = "main"; end
        "pre_shutdown": begin pre_phase = "post_main"; end
        "shutdown": begin pre_phase = "pre_shutdown"; end
        "post_shutdown": begin pre_phase = "shutdown"; end
      endcase
      //for concurrent join, take the longest
      if(phase_ended_called.exists(pre_phase))
         pre_phase_end_time = phase_ended_called[pre_phase];
      if(pre_phase2 != "NONE") begin
         if(!phase_ended_called.exists(pre_phase2))
           pre_phase_end_time = -1;
         else if(phase_ended_called[pre_phase2] > pre_phase_end_time)
           pre_phase_end_time = phase_ended_called[pre_phase2];
      end
      if (pre_phase != "NONE" && (pre_phase_end_time != $time) )
      begin
        `uvm_error("START_END", $sformatf("Missed preceding phase_ended for %s %s : expected time: %0t", pre_phase, pre_phase2, pre_phase_end_time));
        failed = 1 ;
      end
    endfunction

    function void phase_ended (uvm_phase phase);
      phase_ended_called[phase.get_name()] = $time;
      `uvm_info("PHASE",$sformatf("Ending %s",phase.get_name()),UVM_NONE);
    endfunction
  endclass

  /////////////////////////////////////////

  class test extends base;
    hier dom1, dom2;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      uvm_domain domain1, domain2;
      super.new(name,parent);
      thedelay = 0 ;
      dom1 = new("dom1", this);
      dom2 = new("dom2", this);
      dom2.leaf1.thedelay = 75 ;
      dom2.leaf2.thedelay = 50 ;
      domain1 = new("domain1");
      domain2 = new("domain2");
      dom1.set_domain(domain1);
      dom2.set_domain(domain2);
    endfunction

    function void final_phase(uvm_phase phase);
      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction

  endclass

  initial run_test();
endmodule
