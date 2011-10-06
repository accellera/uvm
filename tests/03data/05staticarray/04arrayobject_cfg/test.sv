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
//This test verifies that the auto-config functionality in uvm_field_sarray_object
//macro works as expected.
//
//The macros which are tested are:
//  `uvm_field_sarray_object

//Pass/Fail criteria:
//  The set_config_* must produce the correct results.
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

  container cfg_container = new;

  class test extends uvm_test;
    container cfg_field_set_clone = new;
    container cfg_field_set_ref = new;
    container cfg_field_notset;
    container  cfg_field_set_sub = new;

    `uvm_new_func
    `uvm_component_utils_begin(test)
      `uvm_field_object(cfg_field_set_clone, UVM_DEFAULT)
      `uvm_field_object(cfg_field_set_ref, UVM_DEFAULT)
      `uvm_field_object(cfg_field_notset, UVM_DEFAULT)
      `uvm_field_object(cfg_field_set_sub, UVM_DEFAULT)
    `uvm_component_utils_end

    task run;
      if(cfg_field_set_clone.object[0] == cfg_container.object[0]) begin
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_set_clone is set to ref ***", UVM_NONE);
      end
      if((cfg_field_set_clone.value != 0) || (cfg_field_set_clone.object[0].color != BLUE) ||
         (cfg_field_set_clone.object[0].i != 55) || (cfg_field_set_clone.object[0].str != "from cfg")) begin
cfg_field_set_clone.print();
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_set_clone is not set correctly ***", UVM_NONE);
      end
   
      if(cfg_field_set_ref.object[0] != cfg_container.object[0])
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_set_ref is not set to ref ***", UVM_NONE);
      if(cfg_field_notset != null)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_notset is set ***", UVM_NONE);
   
      if((cfg_field_set_sub.value != 0) || (cfg_field_set_sub.object[0] == cfg_container.object[0]) ||
         (cfg_field_set_sub.object[0].color != BLUE) || (cfg_field_set_sub.object[0].i != 55) || 
         (cfg_field_set_sub.object[0].str != "from cfg"))
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_set_sub is not set correctly ***", UVM_NONE);
   
      recording_detail=UVM_LOW;

      uvm_report_info("PASSED", "*** UVM TEST PASSED ***", UVM_NONE);

    endtask
  endclass

  initial begin
    cfg_container.value = 22;
    cfg_container.object[0] = new;
    cfg_container.object[0].color = BLUE; 
    cfg_container.object[0].i = 55; 
    cfg_container.object[0].str = "from cfg"; 
    set_config_object("*", "cfg_field_set_clone.object[0]", cfg_container.object[0]);
    set_config_object("*", "cfg_field_set_ref.object[0]", cfg_container.object[0], 0);
    set_config_object("*", "cfg_field_set_sub.object[0]", cfg_container.object[0]);
    run_test();
  end

endmodule
