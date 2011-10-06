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
//  The copy, compare, pack, unpack, print, record and set_config_int must
//  produce the correct results.
//

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class myobject extends uvm_sequence_item;
    int i;
    byte b;
    logic [127:0] bigint;

    `uvm_object_utils_begin(myobject)
      `uvm_field_int(i, UVM_DEFAULT)
      `uvm_field_int(b, UVM_DEFAULT)
      `uvm_field_int(bigint, UVM_DEFAULT)
    `uvm_object_utils_end

  function new(string name="myobject");
     super.new(name);
  endfunction

  endclass

  class test extends uvm_test;
    int cfg_field_set = 0;
    int cfg_field_notset = 0;

    `uvm_new_func
    `uvm_component_utils_begin(test)
      `uvm_field_int(cfg_field_set, UVM_DEFAULT)
      `uvm_field_int(cfg_field_notset, UVM_DEFAULT)
    `uvm_component_utils_end

    myobject obj = new;
    task run;
      byte unsigned bytes[];
      myobject cp;
      string exp = {
        "----------------------------------------------------\n",
        "Name      Type      Size  Value                     \n",
        "----------------------------------------------------\n",
        "obj       myobject  -     -                         \n",
        "  i       integral  32    'h5555                    \n",
        "  b       integral  8     'h55                      \n",
        "  bigint  integral  128   'haaaa5555aaaa5555aaaa5555\n",
        "----------------------------------------------------\n"
      };

      obj.set_name("obj");

      if(cfg_field_set != 33)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field is not set ***", UVM_NONE);
      if(cfg_field_notset != 0)
        uvm_report_info("FAILED", "*** UVM TEST FAILED cfg_field_notset is set ***", UVM_NONE);
   
      obj.b = 'haa;
      obj.i = 'h5555;
      obj.bigint = 128'haaaa5555aaaa5555aaaa5555;

      $cast(cp, obj.clone());
      cp.set_name("obj_copy");

      // This tests the copy and the compare
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare failed, expected to pass ***", UVM_NONE);

      cp.b = ~cp.b;
      if(cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, expected to fail ***", UVM_NONE);

      void'(cp.pack_bytes(bytes));
      if(bytes.size() != 21)
        uvm_report_info("FAILED", "*** UVM TEST FAILED compare passed, packed incorrectly ***", UVM_NONE);

      void'(obj.unpack_bytes(bytes));
      if(!cp.compare(obj))
        uvm_report_info("FAILED", "*** UVM TEST FAILED unpack failed ***", UVM_NONE);


      uvm_default_printer.knobs.reference=0;
      if(exp != obj.sprint()) begin
        string s = obj.sprint();
        foreach (exp[i]) begin
          $write("%c",s[i]);
          if (exp[i] != s[i]) $write("X"); else $write(" ");
        end
        uvm_report_info("FAILED", "*** UVM TEST FAILED print failed ***", UVM_NONE);
      end

      obj.print();
      uvm_report_info("PASSED", "*** UVM TEST PASSED ***", UVM_NONE);

      recording_detail=UVM_LOW;
      void'(begin_tr(obj));
      end_tr(obj);

    endtask
  endclass

  initial begin
    set_config_int("*", "cfg_field_set", 33);
    run_test();
  end

endmodule
