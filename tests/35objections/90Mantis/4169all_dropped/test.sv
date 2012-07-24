//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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
//------------------------------------------------------------------------------

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class comp extends uvm_component;
    `uvm_new_func
    `uvm_component_utils(comp)
     bit passed;

     function void build();
        super.build();
        uvm_test_done.raise_objection(this, "raising run phase objection in build");
        uvm_test_done.drop_objection(this, "dropping run phase objection in build");
     endfunction : build
     
    task run;
       uvm_test_done.raise_objection(this, "raising run phase objection in run");
       #5;
       passed = 1;
       uvm_test_done.drop_objection(this, "dropping run phase objection in run");
    endtask

    function void report();
      if(passed)
        $display("*** UVM TEST PASSED ***");
      else
        $display("*** UVM TEST FAILED: run phase killed prematurely ***");
    endfunction
  endclass

  class test extends uvm_test;
    comp c;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      c = new("c", this);
    endfunction
    `uvm_component_utils(test)
  endclass

  initial run_test;

endmodule
