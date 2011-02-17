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

// This test creates a couple of hierarchies in order to have
// many top levels. Then, it verifies that the uvm_root::top_levels
// array and the uvm_component::get_children() provide the 
// correct information.


package pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;

  // A simple hierarchy
  class C extends uvm_component;
    `uvm_component_utils(C)
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass
  class B extends uvm_component;
    C cc1, cc2;
    `uvm_component_utils(B)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      cc1 = new("cc1", this);
      cc2 = new("cc2", this);
    endfunction
  endclass
  class A extends uvm_component;
    C cc1, cc2;
    B bb1, bb2;
    `uvm_component_utils(B)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      cc1 = new("cc1", this);
      cc2 = new("cc2", this);
      bb1 = new("bb1", this);
      bb2 = new("bb2", this);
    endfunction
    function void report();
      uvm_component children[$];
      get_children(children);
      if(children.size() != 4) begin
        failed = 1;
        `uvm_error("BADNUM", $sformatf("Number of children was expected to be 4 but was %0d", children.size()))
      end      
    endfunction
  endclass
endpackage

module mod;
  import pkg::*;

  A aaa1 = new ($sformatf("%m.aaa1"), null);
endmodule


module test;
  import uvm_pkg::*;
  import pkg::*;
  `include "uvm_macros.svh"

  mod mod1();
  mod mod2();
 
  class test extends A;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
    uvm_top.print_topology();
      uvm_top.stop_request();
    endtask
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);

      //check the root top levels
      if(uvm_top.top_levels.size() != 3) begin
        failed = 1;
        `uvm_error("BADNUM", $sformatf("Number of top levels was expected to be 3 but was %0d", uvm_top.top_levels.size()))
      end
      if(uvm_top.top_levels[0].get_full_name() != "uvm_test_top") begin
        failed = 1;
        `uvm_error("BADNUM", $sformatf("Expected top_levels[0] to be uvm_test_top, but got %0s", uvm_top.top_levels[0].get_full_name()))
      end
      if(!failed)
         $display("UVM TEST PASSED");
    endfunction
  endclass

  initial run_test();
endmodule
