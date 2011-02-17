//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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
//------------------------------------------------------------------------------

//---------------------------------------------------------------------- 
// Test: 05order
// Purpose: To test the order of execution of callbacks.
// API tested:
//   `uvm_do_callbacks
//   `uvm_register_cb
//      uvm_callbacks#(T,CB)::add(comp,cb); //append
//      uvm_callbacks#(T,CB)::add(null,cb); //preappend

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

virtual class a_cb extends uvm_callback;
   function new(string name = "a_cb");
      super.new(name);
   endfunction

   virtual function void f(ref int q[$]);
   endfunction
endclass


class a_comp extends uvm_component;
   int q[$];

   function new(string name = "a_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(a_comp)
   `uvm_register_cb(a_comp, a_cb)

   virtual task run();
      `uvm_do_callbacks(a_comp, a_cb, f(q));
   endtask
endclass


class my_a_cb extends a_cb;
   local int m_id;

   function new(int id);
      m_id = id;
   endfunction

   virtual function void f(ref int q[$]);
      $write("Executing f() in %s(%0d)...\n", get_name(), m_id);
      q.push_back(m_id);
   endfunction
endclass

class test extends uvm_test;

   bit pass = 1;

   a_comp a1;
   a_comp a2;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build();
      my_a_cb cb;

      a1 = new("a1", this);
      cb = new(1);
      uvm_callbacks#(a_comp, a_cb)::add(a1, cb);
      cb = new(2);
      uvm_callbacks#(a_comp, a_cb)::add(null, cb);

      a2 = new("a2", this);
      cb = new(3);
      uvm_callbacks#(a_comp, a_cb)::add(a2, cb);
      cb = new(4);
      uvm_callbacks#(a_comp, a_cb)::add(null, cb);
      cb = new(5);
      uvm_callbacks#(a_comp, a_cb)::add(a1, cb);
   endfunction

   virtual task run();
      uvm_top.stop_request();
   endtask

   virtual function void check();
      int exp[$];
      int fail;

      exp.push_back(1); exp.push_back(2); 
      exp.push_back(4); exp.push_back(5); 
      fail = 0;
      foreach(exp[i]) if(a1.q[i] != exp[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "Callback execution order for a1 was not 1, 2, 4, 5.");
         pass = 0;
      end
      exp.delete();
      exp.push_back(2); exp.push_back(3); 
      exp.push_back(4);
      fail = 0;
      foreach(exp[i]) if(a2.q[i] != exp[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "Callback execution order for a2 was not 2, 3, 4.");   
         pass = 0;
      end
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
