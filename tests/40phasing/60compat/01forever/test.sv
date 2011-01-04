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

// This test verifies the standard uvm 1.0 ea methodology of having
// a forever loop in some component. That component is passive and
// does not effect the end of test.
//
// For this example, the global stop request is used to indicate the
// run being done. But, this can also be done with the uvm_test_done 
// objection.

module top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class comp extends uvm_component;

    `uvm_component_utils(comp)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run();
      forever begin
        #20;
      end
    endtask
   
  endclass


  class test extends uvm_test;

    `uvm_component_utils(test)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task run();
      #10 global_stop_request(); 
      #10;
    endtask

    function void report;
      if($time == 10) $display("*** UVM TEST PASSED ***");
      else $display("*** UVM TEST FAILED ***");
    endfunction
  endclass

  initial begin
    run_test();
  end

endmodule
