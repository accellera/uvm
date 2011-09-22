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
//This test verifies that the basic funcitonality in uvm_field_real
//macro works as expected.
//
//The macros which are tested are:
//  `uvm_field_real

//Pass/Fail criteria:
//  The copy, compare, pack, unpack, print, record and set_config_int must
//  produce the correct results.
//

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class myobject extends uvm_sequence_item;
    real r1;
    real r2;

    `uvm_object_utils_begin(myobject)
      `uvm_field_real(r1, UVM_DEFAULT)
      `uvm_field_real(r2, UVM_DEFAULT)
    `uvm_object_utils_end

  function new(string name="myobject");
     super.new(name);
  endfunction

  endclass

  class test extends uvm_test;
    real cfg_field_set = 0;
    real cfg_field_notset = 0;

    `uvm_new_func
    `uvm_component_utils_begin(test)
      `uvm_field_real(cfg_field_set, UVM_DEFAULT)
      `uvm_field_real(cfg_field_notset, UVM_DEFAULT)
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
        "  r1                     real                64                  1.234\n",
        "  r2                     real                64                  18.13\n",
        "----------------------------------------------------------------------\n"
      };

      obj.set_name("obj");

      if(cfg_field_set != 33.33)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field is not set ***", UVM_NONE);
      if(cfg_field_notset != 0)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_notset is set ***", UVM_NONE);
   
      obj.r1 = 1.234;
      obj.r2 = 13.13;

      $cast(cp, obj.clone());
      cp.set_name("obj_copy");

      // This tests the copy and the compare
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare failed, expected to pass ***", UVM_NONE);

      cp.r2 = cp.r2+5.0;
      if(cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, expected to fail ***", UVM_NONE);

      void'(cp.pack_bytes(bytes));
      if(bytes.size() != 16)
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
    set_config_int("*", "cfg_field_set", $realtobits(33.33));
    run_test();
  end

endmodule
