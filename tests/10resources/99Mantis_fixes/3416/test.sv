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

interface intf;
    int i='hdeadbeef;
    function string convert2string();
      return $sformatf("%m 'h%x", i);
    endfunction
endinterface

module testm;
intf myif();
endmodule

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
   `uvm_object_utils(my_obj)
   function new(string name = "");
      super.new(name);
   endfunction
endclass

class your_obj extends an_obj;
   `uvm_object_utils(your_obj)
   function new(string name = "");
      super.new(name);
   endfunction
endclass

class some_none_uvm_object;
   int i='hdeadbeef;
   function string convert2string();
      return $sformatf("i=%0x", i);
   endfunction
endclass
    
initial
begin
   static my_obj mo = new("mo");
   static your_obj yo = new("yo");
   static some_none_uvm_object some_nuvm_object = new;

   uvm_default_printer=uvm_default_line_printer;
   
   void'(m_uvm_resource_convert2string_converter#(some_none_uvm_object)::register());
   void'(m_uvm_resource_convert2string_converter#(virtual intf)::register());
   

   $display("GOLD-FILE-START");
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

   uvm_config_db#(uvm_bitstream_t)::set(null,"*","para1",3);
   uvm_config_db#(int)::set(null,"*","para2",4);

   uvm_config_db#(some_none_uvm_object)::set(null,"*","no-uvm-object",some_nuvm_object);
 
   uvm_resource_db#(virtual intf)::set("vif","entry",testm.myif);
   
   uvm_config_db#()::dump();
   $display("GOLD-FILE-END");
  
end

endprogram
