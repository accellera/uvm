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

// Test for mantis 3533, calling phase.jump() from a future phase causes
// the jump to occur in the future without warning.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  time warn_time, info_time;
  class catcher extends uvm_report_catcher;
     virtual function action_e catch();
        if(get_id() == "JMPPHIDL" && get_severity() == UVM_ERROR) begin
          warn_time = $time;
          set_severity(UVM_WARNING);
        end
        if(get_id() == "PH_JUMP" && get_severity() == UVM_INFO)
          info_time = $time;
        return THROW;
     endfunction
  endclass

  class comp extends uvm_component;
    function new(string name, uvm_component parent);
      catcher ctchr = new;
      super.new(name,parent);
      uvm_report_cb::add(null,ctchr);
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
      `uvm_info("MAIN","End main...",UVM_NONE);
      phase.drop_objection(this); 
    endtask

    task shutdown_phase(uvm_phase phase);
      phase.raise_objection(this); 
      `uvm_info("SHUTDOWN","Start shutdown...",UVM_NONE);
      #10
      `uvm_info("SHUTDOWN","End shutdown...",UVM_NONE);
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

    task run_phase(uvm_phase phase);
      uvm_domain uvm = uvm_domain::get_uvm_domain();
      uvm_phase shutdown_ph = uvm.find(uvm_shutdown_phase::get());
      uvm_phase reset_ph = uvm.find(uvm_reset_phase::get());
      phase.raise_objection(this); 
      #15 `uvm_info("DO_RST", "Doing reset from shutdown phase!", UVM_NONE);
      shutdown_ph.jump(reset_ph);
      phase.drop_objection(this); 
    endtask

    function void report_phase(uvm_phase phase);
      bit failed = 0;
      `uvm_info("REPORT", "In report phase!!!!", UVM_NONE)

      if(warn_time != 15) begin
        $display("*** UVM TEST FAILED : Expected warning at time 15, warn time is: %0t", warn_time);
        failed = 1;
      end
      if(info_time != 30) begin
        $display("*** UVM TEST FAILED : Expected jump message at time 30, info time is: %0t", info_time);
        failed = 1;
      end
      if(!failed)
        $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial run_test();
endmodule
