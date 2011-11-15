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

  function new(string name="baseclass");
    super.new(name);
  endfunction
endclass

class mid_class extends uvm_sequence_item;
  rand int a;
  base_class base[];

  `uvm_object_utils_begin(mid_class)
    `uvm_field_int(a, UVM_ALL_ON|UVM_DEC)
    `uvm_field_array_object(base, UVM_ALL_ON|UVM_DEEP|UVM_NOPACK)
  `uvm_object_utils_end

  constraint valid {
    a < 100; a >= 0;
  }

  function new(string name="mid_class");
    super.new(name);
//    base = new("base");
  endfunction

  function void do_pack(uvm_packer packer);
    super.do_pack(packer);
    packer.pack_field_int(base.size(),32);
    foreach(base[i]) begin
      packer.pack_object(base[i]);
    end
  endfunction

  function void do_unpack(uvm_packer packer);
    int unpacked_size;
    base_class factory = new();
    super.do_unpack(packer);
    unpacked_size = packer.unpack_field_int(32);
    base = new[unpacked_size];
    foreach(base[i]) begin
      assert($cast(base[i], factory.create()));
      packer.unpack_object(base[i]);
    end
  endfunction
endclass

class my_class extends uvm_sequence_item;

  rand int a;
  mid_class mid;
  rand int c[];

  `uvm_object_utils_begin(my_class)
    `uvm_field_int(a, UVM_ALL_ON|UVM_DEC)
    `uvm_field_object(mid, UVM_ALL_ON|UVM_DEEP|UVM_NOPACK)
    `uvm_field_array_int(c, UVM_ALL_ON|UVM_DEC)
  `uvm_object_utils_end

  constraint valid {
    a < 100; a >= 0;
    c.size() < 10; c.size > 0;
  }

  function new(string name="my_class");
    super.new(name);
//    mid = new("mid");
  endfunction

  function void do_pack(uvm_packer packer);
    super.do_pack(packer);
    packer.pack_object(mid);
  endfunction

  function void do_unpack(uvm_packer packer);
    super.do_unpack(packer);
    if (mid == null) begin
      mid_class factory = new();
      assert($cast(mid, factory.create()));
    end
    packer.unpack_object(mid);
  endfunction

endclass

class test extends uvm_test;

  `uvm_new_func
  `uvm_component_utils(test)

  task run;
    my_class a, b;
    byte unsigned bytes_for_pack_copy [];

    a = new("a");
    b = new("b");

    // Set up a
    a.mid = new("b");
    a.mid.a = 13;
    a.mid.base = new[7];
    foreach(a.mid.base[i]) begin
      a.mid.base[i] = new($sformatf("b[%0d]", i));
      a.mid.base[i].a = $urandom_range(1, 100);
    end
    assert(a.randomize());

    // Now pack a and unpack it into b
    uvm_default_packer.use_metadata = 1;
    void'(a.pack_bytes(bytes_for_pack_copy));
    void'(b.unpack_bytes(bytes_for_pack_copy));
    
    a.print();
    b.print();

    if (!a.compare(b)) begin
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
