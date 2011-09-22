//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
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

// Test: 10safety
// Purpose: Tests that warnings are issued if a user attempts to
//   add a callback to an object that does not support the specified
//   callback type.
// API tested:
//   `uvm_register_cb
//      uvm_callbacks#(T,CB)::add(comp,cb); //append
//      uvm_callbacks#(T,CB)::add(null,cb);
// Three illegal adds are done and three legal adds are done. The
// illegal adds are caught by the message catcher.

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

virtual class a_cb extends uvm_callback;
   function new(string name = "a_cb");
      super.new(name);
   endfunction
endclass


virtual class b1_cb extends uvm_callback;
   function new(string name = "b_cb");
      super.new(name);
   endfunction
endclass


virtual class b2_cb extends uvm_callback;
   function new(string name = "b_cb");
      super.new(name);
   endfunction
endclass


class a_comp extends uvm_component;
   function new(string name = "a_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(a_comp)
   `uvm_register_cb(a_comp, a_cb)
endclass


class b_comp extends uvm_component;
   function new(string name = "b_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(b_comp)
   `uvm_register_cb(b_comp, b1_cb)
   `uvm_register_cb(b_comp, b2_cb)
endclass


class my_a_cb extends a_cb;
   `uvm_object_utils(my_a_cb)

  function new(string name="my_a_cb");
     super.new(name);
  endfunction

endclass

class my_b1_cb extends b1_cb;
   `uvm_object_utils(my_b1_cb)

  function new(string name="my_b1_cb");
     super.new(name);
  endfunction

endclass

class my_b2_cb extends b2_cb;
   `uvm_object_utils(my_b2_cb)

  function new(string name="my_b2_cb");
     super.new(name);
  endfunction

endclass


class cb_catch extends uvm_report_catcher;
   static int seen = 0;

   virtual function action_e catch();
      if (get_id() == "CBUNREG" && get_severity() == UVM_WARNING) begin
         seen++;
         return CAUGHT;
      end
      return THROW;
   endfunction
endclass


class test extends uvm_test;

   bit pass = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build();
   endfunction

   virtual task run();
      my_a_cb acb   = new;
      my_b1_cb b1cb = new;
      my_b2_cb b2cb = new;

      $write("Checking valid registrations...\n");
      uvm_callbacks#(a_comp, a_cb)::add(null, acb);
      uvm_callbacks#(b_comp, b1_cb)::add(null, b1cb);
      uvm_callbacks#(b_comp, b2_cb)::add(null, b2cb);

      $write("Checking unsafe registrations...\n");
      begin
         cb_catch cth = new;
         uvm_report_cb::add(null,cth);
      end
      cb_catch::seen = 0;
      uvm_callbacks#(b_comp, a_cb)::add(null, acb);
      if (cb_catch::seen !== 1) begin
         `uvm_error("TEST", "Did not report error on unsafe 'acb' registratioon");
         pass = 0;
      end

      cb_catch::seen = 0;
      uvm_callbacks#(a_comp, b1_cb)::add(null, b1cb);
      if (cb_catch::seen !== 1) begin
         `uvm_error("TEST", "Did not report error on unsafe 'b1cb' registratioon");
         pass = 0;
      end

      cb_catch::seen = 0;
      uvm_callbacks#(a_comp, b2_cb)::add(null, b2cb);
      if (cb_catch::seen !== 1) begin
         `uvm_error("TEST", "Did not report error on unsafe 'b2cb' registratioon");
         pass = 0;
      end

      uvm_top.stop_request();
   endtask

   virtual function void check();
   endfunction

   virtual function void report();
      $write("** UVM TEST %s **\n", (pass) ? "PASSED" : "FAILED");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
