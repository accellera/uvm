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
//This test verifies that the basic funcitonality in uvm_field_int
//macro works as expected.
//
//The macros which are tested are:
//  `uvm_field_int

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
    myobject object = new;
    int      value = 0;
    `uvm_object_utils_begin(container)
      `uvm_field_object(object, UVM_DEFAULT)
      `uvm_field_int(value, UVM_DEFAULT)
    `uvm_object_utils_end

  function new(string name="container");
     super.new(name);
  endfunction

  endclass

  container cfg_container = new;

  class test extends uvm_test;
    container cfg_field_set_clone = null;
    container cfg_field_set_ref = null;
    container cfg_field_notset = null;

    `uvm_new_func
    `uvm_component_utils_begin(test)
      `uvm_field_object(cfg_field_set_clone, UVM_DEFAULT)
      `uvm_field_object(cfg_field_set_ref, UVM_DEFAULT)
      `uvm_field_object(cfg_field_notset, UVM_DEFAULT)
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
        "  object                 myobject            -                       -\n",
        "    color                colors              32                 ORANGE\n",
        "    i                    integral            32             'hffffaaaa\n",
        "    str                  string              11            from object\n",
        "  value                  integral            32                   'haa\n",
        "----------------------------------------------------------------------\n"
      };

      obj.set_name("obj");

      if(cfg_field_set_clone == cfg_container)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_set_clone is set to ref ***", UVM_NONE);
      if((cfg_field_set_clone.value != 22) || (cfg_field_set_clone.object.color != BLUE) ||
         (cfg_field_set_clone.object.i != 55) || (cfg_field_set_clone.object.str != "from cfg"))
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_set_clone is not set correctly ***", UVM_NONE);
   
      if(cfg_field_set_ref != cfg_container)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_set_ref is not set to ref ***", UVM_NONE);
      if(cfg_field_notset != null)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_notset is set ***", UVM_NONE);
   
      obj.value = 'haa;
      obj.object.color = ORANGE;
      obj.object.i = 'h5555;
      obj.object.str = "from object";

      $cast(cp, obj.clone());
      cp.set_name("obj_copy");

      // This tests the copy and the compare
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare failed, expected to pass ***", UVM_NONE);

      cp.object.i = ~cp.object.i;
      if(cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, expected to fail ***", UVM_NONE);

      uvm_default_packer.use_metadata = 1;
      void'(cp.pack_bytes(bytes));
$display("BYTES: %0d", bytes.size());
      if(bytes.size() != 25)
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, packed incorrectly ***", UVM_NONE);

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
    cfg_container.object.color = BLUE; 
    cfg_container.object.i = 55; 
    cfg_container.object.str = "from cfg"; 
    set_config_object("*", "cfg_field_set_clone", cfg_container);
    set_config_object("*", "cfg_field_set_ref", cfg_container, 0);
    run_test();
  end

endmodule
