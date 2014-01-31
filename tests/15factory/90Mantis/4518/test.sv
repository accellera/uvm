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
endclass


initial begin
   static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

   uvm_report_server svr;
   obj o;
   
   svr = cs_.get_report_server();

   $write("Testing obsolete object constructor...\n");
   o = new();
   
   $write("Testing object factory constructor...\n");
   o = obj::type_id::create("A");
   if (o.get_name() != "A") begin
      `uvm_error("TEST", {"Object name is \"", o.get_name(), "\" instead of \"A\"."})
   end
   
   if (svr.get_severity_count(UVM_FATAL) +
       svr.get_severity_count(UVM_ERROR) == 0)
      $write("** UVM TEST PASSED **\n");
   else
      $write("!! UVM TEST FAILED !!\n");

   svr.report_summarize();
end

endprogram
