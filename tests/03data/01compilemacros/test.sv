//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
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

//Field Macros:
//This test verifies that the field macros compile. The macros live inside
//the uvm_object_utils_begin/end block, so those macros are also tested
//for compilation.
//	- `uvm_object_utils_begin(myobject)
//	- `uvm_object_utils_end
//
//The macros which are tested are:
//  `uvm_field_int
//  `uvm_field_enum
//  `uvm_field_string
//  `uvm_field_object
//  `uvm_field_real
//
//  `uvm_field_array_int
//  `uvm_field_array_enum
//  `uvm_field_array_string
//  `uvm_field_array_object
//
//  `uvm_field_queue_int
//  `uvm_field_queue_enum
//  `uvm_field_queue_string
//  `uvm_field_queue_object
//
//  `uvm_field_aa_int_string
//  `uvm_field_aa_int_int
//  `uvm_field_aa_string_string
//  `uvm_field_aa_object_string
//  `uvm_field_aa_object_int
//  `uvm_field_aa_int_byte_unsigned
//  `uvm_field_aa_int_int_unsigned
//  `uvm_field_aa_int_enumkey

//Pass/Fail criteria:
//Compilation pass is success.
//

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum { ONE, TWO, THREE } numbers;

  class myobject extends uvm_object;
    int i;
    string s; 
    myobject ob;
    numbers num;
    real r;

    int ia[];
    string sa[]; 
    myobject ca[];
    numbers numa[];

    int iq[$];
    string sq[$]; 
    myobject cq[$];
    numbers numq[$];

    int aa_is[string];
    int aa_ii[int];

    string aa_ss[string];

    myobject aa_os[string];
    myobject aa_oi[int];

    int aa_ibu[byte unsigned];
    int aa_iiu[int unsigned];
    int aa_inum[numbers];

    `uvm_object_utils_begin(myobject)
      `uvm_field_int(i, UVM_DEFAULT)
      `uvm_field_enum(numbers, num, UVM_DEFAULT)
      `uvm_field_string(s, UVM_DEFAULT)
      `uvm_field_object(ob, UVM_DEFAULT)
      `uvm_field_real(r, UVM_DEFAULT)

      `uvm_field_array_int(ia, UVM_DEFAULT)
      `uvm_field_array_enum(numbers, numa, UVM_DEFAULT)
      `uvm_field_array_string(sa, UVM_DEFAULT)
      `uvm_field_array_object(ca, UVM_DEFAULT)

      `uvm_field_queue_int(iq, UVM_DEFAULT)
      `uvm_field_queue_enum(numbers, numq, UVM_DEFAULT)
      `uvm_field_queue_string(sq, UVM_DEFAULT)
      `uvm_field_queue_object(cq, UVM_DEFAULT)

      `uvm_field_aa_int_string(aa_is, UVM_DEFAULT)
      `uvm_field_aa_int_int(aa_ii, UVM_DEFAULT)

      `uvm_field_aa_string_string(aa_ss, UVM_DEFAULT)

      `uvm_field_aa_object_string(aa_os, UVM_DEFAULT)
      `uvm_field_aa_object_int(aa_oi, UVM_DEFAULT)

      `uvm_field_aa_int_byte_unsigned(aa_ibu, UVM_DEFAULT)
      `uvm_field_aa_int_int_unsigned(aa_iiu, UVM_DEFAULT)
      `uvm_field_aa_int_enumkey(numbers, aa_inum, UVM_DEFAULT)
    `uvm_object_utils_end

  function new(string name="myobject");
     super.new(name);
  endfunction

  endclass
  class test extends uvm_test;
    `uvm_new_func
    `uvm_component_utils(test)
    myobject obj = new;
    task run;
      uvm_report_info("PASSED", "*** UVM TEST PASSED ***", UVM_NONE);
    endtask
  endclass

  initial run_test();

endmodule
