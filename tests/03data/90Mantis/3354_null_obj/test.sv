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

class base_class extends uvm_sequence_item;
  rand int a;

  `uvm_object_utils_begin(base_class)
    `uvm_field_int(a, UVM_ALL_ON|UVM_DEC)
  `uvm_object_utils_end

  constraint valid {
    a < 100; a >= 0;
  }

  function new(string name="base_class");
    super.new(name);
  endfunction

endclass


class my_class extends uvm_sequence_item;

  rand int a;
  base_class b;
  base_class c;

  `uvm_object_utils_begin(my_class)
    `uvm_field_int(a, UVM_ALL_ON|UVM_DEC)
    `uvm_field_object(b, UVM_ALL_ON|UVM_DEEP)
    `uvm_field_object(c, UVM_ALL_ON|UVM_DEEP)
  `uvm_object_utils_end

  constraint valid {
    a < 100; a >= 0;
  }

  function new(string name="my_class");
    super.new(name);
    b = null;
    c = new("c");
  endfunction

endclass

class test extends uvm_test;

  `uvm_new_func
  `uvm_component_utils(test)

  task run;
    my_class a, b, c;
    byte unsigned bytes[];

    a = new("a");
    b = new("b");

    assert(a.randomize());

    b.copy(a);

    a.print();
    b.print();

    if (!a.compare(b)) begin
       `uvm_error("EPILOG", "Object did not copy or compare");
    end

    uvm_default_packer.use_metadata = 1;

    assert(a.randomize());
    void'(a.pack_bytes(bytes));

    c = new("c");
`ifdef ALLOC_SUBOBJ
    // Should data be unpacked in a newly allocated sub-object??
    c.c = null;
`endif

    void'(c.unpack_bytes(bytes));

    a.print();
    c.print();

    if (!a.compare(c)) begin
       `uvm_error("EPILOG", "Object did not pack/unpack or compare");
    end

  endtask

   function void report();
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
      
   endfunction

endclass

initial
  run_test("test");

endmodule
