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


// Check that we can still instantiate components in the connect_phase,
// but no further

program p;

import uvm_pkg::*;
`include "uvm_macros.svh"

class cb_catch extends uvm_report_catcher;
   static int seen = 0;

   virtual function action_e catch();
      if (get_id() == "ILLCRT" && get_severity() == UVM_FATAL) begin
         seen++;
         return CAUGHT;
      end
      return THROW;
   endfunction
endclass

class cb_demote extends uvm_report_catcher;
   static int seen = 0;

   virtual function action_e catch();
      if (get_id() == "ILLCRT" && get_severity() == UVM_FATAL) begin
         set_severity(UVM_WARNING);
         set_action(UVM_DISPLAY);
         seen++;
      end
      return THROW;
   endfunction
endclass

class comp extends uvm_component;
   `uvm_component_utils(comp)

   function new(string name = "", uvm_component parent = null);
      super.new(name, parent);
   endfunction
endclass
         
class test extends uvm_test;
   `uvm_component_utils(test)

   function new(string name = "", uvm_component parent = null);
      super.new(name, parent);
   endfunction
         
   function void build_phase(uvm_phase phase);
      comp c = new("build_phase", this);
   endfunction

   function void connect_phase(uvm_phase phase);
      comp c;
      cb_catch cth = new;
      
      uvm_report_cb::add(null,cth,UVM_PREPEND);
      c = new("connect_phase", this);
      uvm_report_cb::delete(null,cth);

      if (cb_catch::seen !== 1) begin
         `uvm_error("TEST", "Components not allowed to be created in connect phase")
      end
   endfunction

   function void end_of_elaboration_phase(uvm_phase phase);
      comp c = new("eoe_phase", this);
      if (cb_demote::seen == 0) begin
         `uvm_error("TEST", "Components allowed to be created past the connect phase")
      end
   endfunction


   function void report_phase(uvm_phase phase);
      uvm_root top = uvm_root::get();
      uvm_report_server svr = top.get_report_server();
      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("** UVM TEST FAILED **\n");
   endfunction
endclass

initial
begin
   cb_demote cth;
   cth = new;
   uvm_report_cb::add(null,cth);
      
   run_test("test");

end

endprogram

