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

// This test verifies that there can be no timeout

`define UVM_DEFAULT_TIMEOUT 9200s
module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class test extends uvm_component;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase.set_timeout(0, 0);
      #(`UVM_DEFAULT_TIMEOUT * 100);
      phase.drop_objection(this);
    endtask

    function void report();
      uvm_report_server svr;
      svr = uvm_coreservice.get_report_server();
      
      if ($time == 920000s &&
          svr.get_severity_count(UVM_FATAL) == 0 &&
          svr.get_severity_count(UVM_ERROR) == 0)
        $display("*** UVM TEST PASSED ***\n");
      else
        $display("*** UVM TEST FAILED ***\n");
    endfunction
  endclass

  initial run_test();
endmodule
