//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2011 Mentor Graphics Corporation
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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_class extends uvm_object;
  int foo = 3;
  string bar = "hi there";
  `uvm_object_utils_begin(my_class)
    `uvm_field_int(foo, UVM_ALL_ON | UVM_DEC)
    `uvm_field_string(bar, UVM_ALL_ON)
  `uvm_object_utils_end
  function new (string name = "unnamed-my_class");
    super.new(name);
  endfunction
endclass

class my_catcher extends uvm_report_catcher;
  virtual function action_e catch();

    if(get_severity() == UVM_FATAL)
      set_severity(UVM_ERROR);

    return THROW;
  endfunction
endclass

class test extends uvm_test;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent = null);
     super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    int my_int;
    string my_string;
    my_class my_obj;
    uvm_report_message msg;

    phase.raise_objection(this);

    my_int = 5;
    my_string = "foo";
    my_obj = new("my_obj");

    $display("GOLD-FILE-START");

    `uvm_info_begin("TEST", "Testing message...", UVM_LOW)
    `uvm_message_add_tag("my_color", "red")
    `uvm_message_add_int(my_int, UVM_DEC,"",UVM_LOG)
    `uvm_message_add_string(my_string,UVM_LOG|UVM_RM_RECORD)
    `uvm_message_add_object(my_obj)
    `uvm_info_end

    `uvm_warning_begin("TEST", "Testing message...")
    `uvm_message_add_tag("my_color", "red")
    `uvm_message_add_int(my_int, UVM_DEC,"",UVM_LOG)
    `uvm_message_add_string(my_string,UVM_LOG|UVM_RM_RECORD)
    `uvm_message_add_object(my_obj)
    `uvm_warning_end

    `uvm_error_begin("TEST", "Testing message...")
    `uvm_message_add_tag("my_color", "red")
    `uvm_message_add_int(my_int, UVM_DEC,"",UVM_LOG)
    `uvm_message_add_string(my_string,UVM_LOG|UVM_RM_RECORD)
    `uvm_message_add_object(my_obj)
    `uvm_error_end

    `uvm_fatal_begin("TEST", "Testing message...")
    `uvm_message_add_tag("my_color", "red")
    `uvm_message_add_int(my_int, UVM_DEC,"",UVM_LOG)
    `uvm_message_add_string(my_string,UVM_LOG|UVM_RM_RECORD)
    `uvm_message_add_object(my_obj)
    `uvm_fatal_end

    $display("GOLD-FILE-END");

    phase.drop_objection(this);
  endtask

endclass

initial
  begin
     static my_catcher catcher = new();
     uvm_report_cb::add(null, catcher);

     run_test();
  end

endprogram
