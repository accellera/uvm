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

module top;

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

initial begin

    // User variables  
    uvm_trace_message l_trace_message;
    int l_tr_handle;
    int my_int;
    string my_string;
    my_class my_obj;


    #5;

    my_int = 5;
    my_string = "foo";
    my_obj = new("my_obj");

    // Zero time consuming
    `uvm_info_begin(l_trace_message, "TEST_BEGIN", "Beginning...", UVM_LOW)
    `uvm_add_trace_tag(l_trace_message, "color", "red")
    `uvm_add_trace_int(l_trace_message, my_int, UVM_DEC)
    `uvm_add_trace_string(l_trace_message, my_string)
    `uvm_add_trace_object(l_trace_message, my_obj)

    $display("START OF GOLD FILE");
    l_trace_message.print();
    $display("END OF GOLD FILE");

    `uvm_info_end(l_trace_message, "Ending...", l_tr_handle)

end

endmodule
