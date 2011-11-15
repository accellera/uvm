//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc.
//   Copyright 2010 Mentor Graphics Corporation
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

class my_class extends uvm_sequence_item;

  rand int a;
  rand int b[];

  `uvm_object_utils_begin(my_class)
    `uvm_field_int(a, UVM_ALL_ON|UVM_DEC)
    `uvm_field_array_int(b, UVM_ALL_ON|UVM_DEC)
  `uvm_object_utils_end

  constraint valid {
    a < 100; a >= 0;
    b.size() < 100;
    foreach(b[i]) {
      b[i] < 100; b[i] >= 0;
    }
  }

  function new(string name="my_class");
    super.new(name);
  endfunction

endclass

class test extends uvm_test;

  `uvm_new_func
  `uvm_component_utils(test)

  task run;
    my_class class_a, class_b;

    class_a = new("class_a");
    class_b = new("class_b");

    assert(class_a.randomize());

    $cast(class_b, class_a.clone());

    class_a.print();
    class_b.print();

    if (!class_b.compare(class_a)) begin
      `uvm_error("EPILOG", "FAILED");
    end
    else begin
      if (class_b.a == class_a.a &&
          class_b.b == class_a.b) begin
         $write("** UVM TEST PASSED **\n");
      end
      else begin
        `uvm_error("CMP_TEST", "The compare operation succeeded, but the two classes are not the same.");
        `uvm_error("EPILOG", "FAILED");
      end
    end

  endtask

endclass

initial
  run_test("test");

endmodule
