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


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class obj extends uvm_object;
   `uvm_object_utils(obj)

   static string exp_name;

   function new(string name = "obj");
      super.new(name);

      if (name != exp_name) begin
         `uvm_error("Test", $sformatf("Object name is \"%s\" instead of \"%s\".", name, exp_name))
      end
   endfunction
endclass


class comp extends uvm_component;
   `uvm_component_utils(comp)

   static string exp_name;
   static uvm_component exp_parent;

   function new(string name = "comp", uvm_component parent = null);
      super.new(name, parent);

      if (name != exp_name) begin
         `uvm_error("Test", $sformatf("Component name is \"%s\" instead of \"%s\".", name, exp_name))
      end
      if (parent != exp_parent) begin
         `uvm_error("Test", $sformatf("Component parent of \"%s\" is not as expected.", name))
      end
   endfunction
endclass


initial
begin
   uvm_report_server svr;
   obj o;
   comp c;
   comp p;
   
   svr = _global_reporter.get_report_server();

   $write("Testing raw object constructor...\n");
   obj::exp_name = "X";
   o = new("X");
   obj::exp_name = "obj";
   o = new();
   
   $write("Testing object factory constructor...\n");
   obj::exp_name = "A";
   o = obj::type_id::create("A");
   
   $write("Testing raw component constructor...\n");
   comp::exp_name = "X";
   comp::exp_parent = null;
   p = new("X");
   comp::exp_name = "comp";
   comp::exp_parent = p;
   c = new(,p);
   
   $write("Testing component factory constructor...\n");
   comp::exp_name = "A";
   c = comp::type_id::create("A",p);
   
   if (svr.get_severity_count(UVM_FATAL) +
       svr.get_severity_count(UVM_ERROR) == 0)
      $write("** UVM TEST PASSED **\n");
   else
      $write("!! UVM TEST FAILED !!\n");

   svr.summarize();
end

endprogram
