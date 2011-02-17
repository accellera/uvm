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

// This test verifies that a fatal error is emitted if the simulation
// is started after simulation time 0.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 1;

  class catcher extends uvm_report_catcher;
     virtual function action_e catch();
        if(get_severity() == UVM_FATAL &&
           get_id() == "RUNPHSTIME")
        begin
          failed = 0;
          set_severity(UVM_INFO);
          set_action(UVM_DISPLAY);
          return THROW;
        end
        else
          return THROW;
     endfunction
  endclass

  class test extends uvm_component;
    catcher ctch = new;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      uvm_report_cb::add(null,ctch);
    endfunction
    `uvm_component_utils(test)
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase.drop_objection(this);
    endtask
    function void report();
      if(failed == 0)
        $display("*** UVM TEST PASSED ***");
      else
        $display("*** UVM TEST FAILED ***");
    endfunction
  endclass

  initial #1 run_test();
endmodule
