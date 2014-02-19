//---------------------------------------------------------------------- 
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


// Test that tries to clone a component which is an error.  This test
// exists to show the output is augmented with the cloned component's
// being output in the error message.

program p;

import uvm_pkg::*;
`include "uvm_macros.svh"

class cb_illcln_demote extends uvm_report_catcher;
   static int seen = 0;

   virtual function action_e catch();
      if (get_id() == "ILLCLN" && get_severity() == UVM_ERROR) begin
         set_severity(UVM_WARNING);
         set_action(UVM_DISPLAY);
         seen++;
      end
      return THROW;
   endfunction
endclass

class cb_failcln_demote extends uvm_report_catcher;
   static int seen = 0;

   virtual function action_e catch();
      if (get_id() == "FAILCLN" && get_severity() == UVM_FATAL) begin
         set_severity(UVM_WARNING);
         set_action(UVM_DISPLAY);
         seen++;
      end
      return THROW;
   endfunction
endclass

typedef class comp;

class config_obj extends uvm_object;
   comp config_comp;
   `uvm_object_utils_begin(config_obj)
     `uvm_field_object(config_comp, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "unnamed-config_obj");
     super.new(name);
   endfunction
endclass

class comp extends uvm_component;
   //config_obj co;
   `uvm_component_utils_begin(comp)
     //`uvm_field_object(co, UVM_ALL_ON)
   `uvm_component_utils_end

   function new(string name = "", uvm_component parent = null);
      super.new(name, parent);
   endfunction
endclass
         
class test extends uvm_test;

   config_obj co0;
   comp c0, c1;
   comp oc0, oc1;

   `uvm_component_utils(test)

   function new(string name = "", uvm_component parent = null);
      super.new(name, parent);
   endfunction
         
   function void build_phase(uvm_phase phase); 
      co0 = new("co0");
      c0 = new("c0", this);
      c1 = new("c1", this);
      oc0 = new("oc0", this);
      $cast(oc1, oc0.clone());
      co0.config_comp = c1;
      uvm_config_object::set(this, "*", "co", co0.clone()); 
   endfunction

   function void report_phase(uvm_phase phase);
      uvm_coreservice_t cs_;
      uvm_root top;
      uvm_report_server svr;
      cs_ = uvm_coreservice_t::get();
      top = cs_.get_root();
      svr = top.get_report_server();
      if ((svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0) &&
         (cb_illcln_demote::seen == 2) &&
         (cb_failcln_demote::seen == 1))

         $write("** UVM TEST PASSED **\n");
      else
         $write("** UVM TEST FAILED **\n");
   endfunction
endclass

initial
begin
   cb_illcln_demote cid;
   cb_failcln_demote cfd;
   cid = new;
   cfd = new;
   uvm_report_cb::add(null,cid);
   uvm_report_cb::add(null,cfd);
      
   run_test("test");

end

endprogram

