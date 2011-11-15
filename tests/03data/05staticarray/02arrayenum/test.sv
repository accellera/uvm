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
//This test verifies that the basic funcitonality in uvm_field_sarray_enum
//macro works as expected.
//
//The macros which are tested are:
//  `uvm_field_sarray_enum

//Pass/Fail criteria:
//  The copy, compare, pack, unpack, print, record and set_config_int must
//  produce the correct results.
//

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum { ONE, TWO, THREE, FOUR, FIVE } numbers;
  typedef enum { RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, VIOLET } colors;

  class myobject extends uvm_sequence_item;
    numbers num[5];
    colors  col[5];

    `uvm_object_utils_begin(myobject)
      `uvm_field_sarray_enum(numbers, num, UVM_DEFAULT)
      `uvm_field_sarray_enum(colors, col, UVM_DEFAULT)
    `uvm_object_utils_end

  function new(string name="myobject");
     super.new(name);
  endfunction

  endclass

  class test extends uvm_test;
    numbers cfg_field_set[5];
    numbers cfg_field_notset[5];

    `uvm_new_func
    `uvm_component_utils_begin(test)
      `uvm_field_sarray_enum(numbers, cfg_field_notset, UVM_DEFAULT)
      `uvm_field_sarray_enum(numbers, cfg_field_set, UVM_DEFAULT)
    `uvm_component_utils_end

    myobject obj = new;
    task run;
      byte unsigned bytes[];
      myobject cp;
      string exp = {
        "----------------------------------------------------------------------\n",
        "Name                     Type                Size                Value\n",
        "----------------------------------------------------------------------\n",
        "obj                      myobject            -                       -\n",
        "  num                    array(numbers)      5                       -\n",
        "    [0]                  numbers             32                    ONE\n",
        "    [1]                  numbers             32                    TWO\n",
        "    [2]                  numbers             32                  THREE\n",
        "    [3]                  numbers             32                   FOUR\n",
        "    [4]                  numbers             32                   FIVE\n",
        "  col                    array(colors)       5                       -\n",
        "    [0]                  colors              32                    RED\n",
        "    [1]                  colors              32                 ORANGE\n",
        "    [2]                  colors              32                  GREEN\n",
        "    [3]                  colors              32                  GREEN\n",
        "    [4]                  colors              32                   BLUE\n",
        "----------------------------------------------------------------------\n"
      };

      obj.set_name("obj");

      if(cfg_field_set[0] != TWO)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field[0] is not set ***", UVM_NONE);
      if(cfg_field_set[1] != THREE)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field[1] is not set ***", UVM_NONE);
      if(cfg_field_set[2] != FOUR)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field[2] is not set ***", UVM_NONE);
  
      foreach(cfg_field_notset[i])
        if(cfg_field_notset[i] != RED)
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_notset is set ***", UVM_NONE);
 
      foreach(obj.num[i]) obj.num[i] = numbers'(i);
      foreach(obj.col[i]) obj.col[i] = colors'(i);

      $cast(cp, obj.clone());
      cp.set_name("obj_copy");

      // This tests the copy and the compare
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare failed, expected to pass ***", UVM_NONE);

      cp.col[2] = GREEN;
      if(cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, expected to fail ***", UVM_NONE);

      //uvm_default_packer.use_metadata=1;
      void'(cp.pack_bytes(bytes));
      if(bytes.size() != 40)
        uvm_report_info("FAILED", "*** UVM TEST FAILED packed incorrectly ***", UVM_NONE);

      void'(obj.unpack_bytes(bytes));
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED unpack failed ***", UVM_NONE);


      uvm_default_printer.knobs.reference=0;
      //if(exp != obj.sprint())
      //  uvm_report_info("FAILED", "*** UVM TEST FAILED print failed ***", UVM_NONE);

      obj.print();
      uvm_report_info("PASSED", "*** UVM TEST PASSED ***", UVM_NONE);

      recording_detail=UVM_LOW;
      void'(begin_tr(obj));
      end_tr(obj);

    endtask
  endclass

  initial begin
    set_config_int("*", "cfg_field_set[0]", TWO);
    set_config_int("*", "cfg_field_set[1]", THREE);
    set_config_int("*", "cfg_field_set[2]", FOUR);
    run_test();
  end

endmodule
