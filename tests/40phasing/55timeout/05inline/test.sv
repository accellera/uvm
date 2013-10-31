//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
//   Copyright 2013 Synopsys, Inc.
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

// This test verifies that a timeout can be set from within the phase

`define UVM_DEFAULT_TIMEOUT 9200s
module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit aborted = 0;

  class catcher extends uvm_report_catcher;
     virtual function action_e catch();
        if(get_severity() == UVM_FATAL &&
           get_id() == "PH_TIMEOUT")
        begin
          aborted = 1;
          set_severity(UVM_INFO);
          set_action(UVM_DISPLAY);
          return THROW;
        end
        else
          return THROW;
     endfunction
  endclass

  class test extends uvm_component;
    `uvm_component_utils(test)
    catcher ctch = new;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      uvm_report_cb::add(null,ctch);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #500;
      phase.set_timeout(1000, 0);
      #(`UVM_DEFAULT_TIMEOUT * 2);
    endtask

    function void report();
      uvm_report_server svr;
      svr = uvm_coreservice.get_report_server();
      
      if (!aborted && $time != 1500 &&
          svr.get_severity_count(UVM_FATAL) == 0 &&
          svr.get_severity_count(UVM_ERROR) == 0)
        $display("*** UVM TEST FAILED ***\n");
      else
        $display("*** UVM TEST PASSED ***\n");
    endfunction
  endclass

  initial run_test();
endmodule
