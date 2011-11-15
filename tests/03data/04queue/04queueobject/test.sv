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
//This test verifies that the basic funcitonality in uvm_field_queue_object
//macro works as expected. It does not test auto-config, that is tested
//seperately due to issues.
//
//The macros which are tested are:
//  `uvm_field_queue_object

//Pass/Fail criteria:
//  The copy, compare, pack, unpack, print, record must
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
    myobject object[$];
    int value = 0;
    `uvm_object_utils_begin(container)
      `uvm_field_queue_object(object, UVM_DEFAULT)
      `uvm_field_int(value, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name = "container");
      super.new(name);
      for(int i=0;i<1; ++i) begin
         object.push_back(null);
         object[i] = new;
      end
      object[0].color = ORANGE; object[0].i = 'haa; object[0].str = "zero";
    endfunction
  endclass

  container cfg_container = new;

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
        "  object                 da(object)          3                       -\n",
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
      for(int i=0;i<3;++i) begin
        obj.object[i] = new;
      end
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

      if(cp.object.size() != 3) begin
        uvm_report_info("FAILED", $sformatf("*** UVM TEST FAILED copy failed, expected queue size 3, got %0d ***",cp.object.size()), UVM_NONE);
      end

      // This tests the copy and the compare
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare failed, expected to pass ***", UVM_NONE);

      cp.object[1].i = ~cp.object[1].i;
      if(cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, expected to fail ***", UVM_NONE);

      uvm_default_packer.use_metadata = 1;
      void'(cp.pack_bytes(bytes));
      if(bytes.size() != 73)
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
    cfg_container.value = 22;
    cfg_container.object.push_back(null);
    cfg_container.object[0] = new;
    cfg_container.object[0].color = BLUE; 
    cfg_container.object[0].i = 55; 
    cfg_container.object[0].str = "from cfg"; 
    run_test();
  end

endmodule
