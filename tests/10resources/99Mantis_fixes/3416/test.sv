//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc.
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

program p;

import uvm_pkg::*;
`include "uvm_macros.svh"

class an_obj extends uvm_object;
   int i;

   `uvm_object_utils_begin(an_obj)
      `uvm_field_int(i, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "");
      super.new(name);
   endfunction

   function string convert2string();
      return $sformatf("i=%0d", i);
   endfunction
endclass

class my_obj extends an_obj;
   function new(string name = "");
      super.new(name);
   endfunction
endclass

class your_obj extends an_obj;
   function new(string name = "");
      super.new(name);
   endfunction
endclass


initial
begin
   my_obj mo = new("mo");
   your_obj yo = new("yo");
   
   uvm_resource_default_converter#(bit [7:0])::register();
   uvm_resource_class_converter#(my_obj)::register();
   uvm_resource_sprint_converter#(your_obj)::register();

   uvm_resource_db#(int)::set("int", "*", 0);
   uvm_resource_db#(string)::set("string", "*", "foo!");
   uvm_resource_db#(bit [7:0])::set("bit[7:0]", "*", 'hA5);
   uvm_resource_db#(reg [7:0])::set("reg[7:0]", "*", 'hF0);
   uvm_resource_db#(an_obj)::set("an_obj", "*", null);
   uvm_resource_db#(an_obj)::set("an_obj-m", "*", mo);
   uvm_resource_db#(an_obj)::set("an_obj-y", "*", yo);
   uvm_resource_db#(my_obj)::set("my_obj-0", "*", null);
   uvm_resource_db#(my_obj)::set("my_obj", "*", mo);
   uvm_resource_db#(your_obj)::set("yr_obj", "*", null);
   uvm_resource_db#(your_obj)::set("yr_obj", "*", yo);

   uvm_resource_db#(bit)::dump();

   uvm_resource_default_converter#(uvm_bitstream_t)::register();
   uvm_config_db#(uvm_bitstream_t)::set(null,"*","para1",3);
   uvm_config_db#(int)::set(null,"*","para2",4);

   uvm_config_db#()::dump();
end

endprogram
