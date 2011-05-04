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
//This test is for Mantis 3412. The auto config should set a queue
//element regardless of if the queue has been sized by config.
//
//The macros which are tested are:
//  `uvm_field_queue_enum
//  `uvm_field_queue_int
//  `uvm_field_queue_string
//  `uvm_field_queue_object

//Pass/Fail criteria:
// Ensure the queue settings from config take effect.
//

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum { ONE, TWO, THREE, FOUR, FIVE } numbers;
  class myobject extends uvm_object;
  endclass

  myobject theobj = new;

  class test extends uvm_test;
    numbers cfg_field_enum[$];
    int cfg_field_int[$];
    string cfg_field_string[$];
    myobject cfg_field_obj[$];

    `uvm_new_func
    `uvm_component_utils_begin(test)
      `uvm_field_queue_enum(numbers, cfg_field_enum, UVM_DEFAULT)
      `uvm_field_queue_int(cfg_field_int, UVM_DEFAULT)
      `uvm_field_queue_string(cfg_field_string, UVM_DEFAULT)
      `uvm_field_queue_object(cfg_field_obj, UVM_DEFAULT)
    `uvm_component_utils_end

    myobject obj = new;
    task run_phase(uvm_phase phase);
      bit failed=0;
      if(cfg_field_enum[2] != FOUR) begin
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_enum[2] is not set ***", UVM_NONE);
          failed = 1;
      end
      if(cfg_field_int[2] != 55) begin
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_int[2] is not set ***", UVM_NONE);
          failed = 1;
      end
      if(cfg_field_string[2] != "howdy") begin
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_string[2] is not set ***", UVM_NONE);
          failed = 1;
      end
      if(cfg_field_obj[2] != theobj) begin
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_obj[2] is not set ***", UVM_NONE);
          failed = 1;
      end
      if(failed == 0)
        $display("*** UVM TEST PASSED ***");
      else
        $display("*** UVM TEST FAILED ***");
    endtask
  endclass

  initial begin
    set_config_int("*", "cfg_field_enum[2]", FOUR);
    set_config_int("*", "cfg_field_int[2]", 55);
    set_config_string("*", "cfg_field_string[2]", "howdy");
    set_config_object("*", "cfg_field_obj[2]", theobj, 0);
    run_test();
  end

endmodule
