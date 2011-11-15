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
//This test verifies that the basic funcitonality in uvm_field_sarray_object
//macro works as expected. Auto-config testing is done in a seperate test.
//
//The macros which are tested are:
//  `uvm_field_int

//Pass/Fail criteria:
//  The copy, compare, pack, unpack, print, record and must
//  produce the correct results.
//

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum { RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, VIOLET } colors;

  class myobject extends uvm_sequence_item;
    colors color = RED;
    int    i = 0;
    string str = "default";

    `uvm_object_utils_begin(myobject)
      `uvm_field_enum(colors, color, UVM_DEFAULT)
      `uvm_field_int(i, UVM_DEFAULT)
      `uvm_field_string(str, UVM_DEFAULT)
    `uvm_object_utils_end

  function new(string name="myobject");
     super.new(name);
  endfunction

  endclass

  class container extends uvm_sequence_item;
    myobject object[3];
    int value = 0;
    `uvm_object_utils_begin(container)
      `uvm_field_sarray_object(object, UVM_DEFAULT)
      `uvm_field_int(value, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name = "container");
      super.new(name);
      foreach(object[i]) object[i] = new;
      object[0].color = ORANGE; object[0].i = 'haa; object[0].str = "zero";
      object[1].color = GREEN; object[1].i = 'hbb; object[1].str = "one";
      object[2].color = VIOLET; object[2].i = 'hcc; object[2].str = "two";
    endfunction
  endclass

  class test extends uvm_test;
    `uvm_new_func
    `uvm_component_utils_begin(test)
    `uvm_component_utils_end

    task run;
      byte unsigned bytes[];
      container obj = new;
      container cp;
      string exp = {
        "----------------------------------------------------------------------\n",
        "Name                     Type                Size                Value\n",
        "----------------------------------------------------------------------\n",
        "obj                      container           -                       -\n",
        "  object                 sa(object)          3                       -\n",
        "    [0]                  myobject            -                       -\n",
        "      color              colors              32                 ORANGE\n",
        "      i                  integral            32                 'h5555\n",
        "      str                string              11            from object\n",
        "    [1]                  myobject            -                       -\n",
        "      color              colors              32                 YELLOW\n",
        "      i                  integral            32             'hffff5555\n",
        "      str                string              17      from object again\n",
        "    [2]                  myobject            -                       -\n",
        "      color              colors              32                  GREEN\n",
        "      i                  integral            32                 'h3333\n",
        "      str                string              8                last one\n",
        "  value                  integral            32                   'haa\n",
        "----------------------------------------------------------------------\n"
      };

      obj.set_name("obj");

      obj.value = 'haa;
      foreach(obj.object[i]) obj.object[i] = new;
      obj.object[0].color = ORANGE;
      obj.object[0].i = 'h5555;
      obj.object[0].str = "from object";
      obj.object[1].color = YELLOW;
      obj.object[1].i = 'haaaa;
      obj.object[1].str = "from object again";
      obj.object[2].color = GREEN;
      obj.object[2].i = 'h3333;
      obj.object[2].str = "last one";

      $cast(cp, obj.clone());
      cp.set_name("obj_copy");

      // This tests the copy and the compare
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare failed, expected to pass ***", UVM_NONE);

      cp.object[1].i = ~cp.object[1].i;
      if(cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, expected to fail ***", UVM_NONE);

      uvm_default_packer.use_metadata = 1;
      void'(cp.pack_bytes(bytes));
      if(bytes.size() != 69)
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
    run_test();
  end

endmodule
