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
//This test verifies auto-config of string queues.
//
//The macros which are tested are:
//  `uvm_field_queue_string

//Pass/Fail criteria:
//  The copy, compare, pack, unpack, print, record and set_config_int must
//  produce the correct results.
//

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class test extends uvm_test;
    string cfg_field_set[$];
    string cfg_field_notset[$];

    `uvm_new_func
    `uvm_component_utils_begin(test)
      `uvm_field_queue_string(cfg_field_set, UVM_DEFAULT)
      `uvm_field_queue_string(cfg_field_notset, UVM_DEFAULT)
    `uvm_component_utils_end

    task run;
      if(cfg_field_set.size() != 3)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field is not set ***", UVM_NONE);
      else begin
        if(cfg_field_set[0] != "zero")
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field[0] is not set ***", UVM_NONE);
        if(cfg_field_set[1] != "one")
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field[1] is not set ***", UVM_NONE);
        if(cfg_field_set[2] != "two")
          uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field[2] is not set ***", UVM_NONE);
      end
      if(cfg_field_notset.size() != 0)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_notset is set ***", UVM_NONE);
 
      uvm_report_info("PASSED", "*** UVM TEST PASSED ***", UVM_NONE);

    endtask
  endclass

  initial begin
    set_config_int("*", "cfg_field_set", 3);
    set_config_string("*", "cfg_field_set[0]", "zero");
    set_config_string("*", "cfg_field_set[1]", "one");
    set_config_string("*", "cfg_field_set[2]", "two");
    run_test();
  end

endmodule
