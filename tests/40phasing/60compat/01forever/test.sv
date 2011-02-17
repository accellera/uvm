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

// This test verifies the standard uvm 1.0 ea methodology of having
// a forever loop in some component. That component is passive and
// does not effect the end of test.
//

module top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class comp extends uvm_component;

    `uvm_component_utils(comp)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
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

    task run_phase(uvm_phase phase);
      phase.raise_objection(this, "raise run objection for UVM semantic");
      #10; 
      phase.drop_objection(this, "drop run objection for UVM semantic");
      #10;
    endtask

    function void report_phase(uvm_phase phase);
      if($time == 10) $display("*** UVM TEST PASSED ***");
      else $display("*** UVM TEST FAILED ***");
    endfunction
  endclass

  initial begin
    run_test();
  end

endmodule
