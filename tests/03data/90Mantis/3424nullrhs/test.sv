//---------------------------------------------------------------------- 
//   Copyright 2011 Cadence Design Systems, Inc.
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

`include "uvm_macros.svh"
module test;

  import uvm_pkg::*;

  class data extends uvm_sequence_item;
    rand int a;

    `uvm_object_utils_begin(data)
      `uvm_field_int(a, UVM_ALL_ON)
    `uvm_object_utils_end

  function new(string name="data");
     super.new(name);
  endfunction

  endclass

  class contain extends uvm_sequence_item;
    rand data d;

    `uvm_object_utils_begin(contain)
      `uvm_field_object(d, UVM_ALL_ON)
    `uvm_object_utils_end

  function new(string name="contain");
     super.new(name);
  endfunction

  endclass

  class test extends uvm_test;

    `uvm_new_func
    `uvm_component_utils(test)

    task run;
      contain a, b;
  
      a = new;
  
      assert(a.randomize());
  
//      if(b.d != null || !b.compare(a))
      if(a.compare(b))
        $display("*** UVM TEST FAILED***");
      else
        $display("*** UVM TEST PASSED***");
    endtask
  
  endclass

  initial
    run_test("test");

endmodule
