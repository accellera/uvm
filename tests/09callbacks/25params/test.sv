//----------------------------------------------------------------------
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2010 Mentor Graphics Corporation
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


// Test: 25params
// Purpose: Test parameterized callback classes are properly executed
//   by parameterized components.
// API tested:
//   `uvm_do_callbacks
//   `uvm_register_cb
//   `uvm_set_super_type
//   uvm_callbacks#(T,CB)::add(comp,cb); //append
//
// Callback Class hierarchy
//
//     specific_cb            generic_cb
//    ^           ^              ^
//   /             \             |
// my_specific_cb   |          my_generic_cb
//             special_cb#(N) 
//                 ^
//                 |     
//            my_special_cb#(N)
//
// Component Class Hierarchy (and callbacks they use)
//
//        generic_comp (generic_cb)
//              ^
//              |
//        special_comp#(N)  (specific_cb)
//                          (special_cb#(N))

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

virtual class generic_cb extends uvm_callback;
   function new(string name = "generic_cb");
      super.new(name);
   endfunction

   virtual function void generic_f(ref string q[$]);
   endfunction
endclass

class generic_comp extends uvm_component;
   string q[$];

   function new(string name = "generic_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(generic_comp)
   `uvm_register_cb(generic_comp, generic_cb)

   virtual task run();
      `uvm_do_callbacks(generic_comp, generic_cb, generic_f(q))
   endtask
endclass


virtual class specific_cb extends uvm_callback;
   function new(string name = "specific_cb");
      super.new(name);
   endfunction

   virtual function void specific_f(ref string q[$]);
   endfunction
endclass


virtual class special_cb #(int N = 0) extends specific_cb;
   function new(string name = "special_cb");
      super.new(name);
   endfunction

   virtual function void special_f(ref string q[$], input int n);
   endfunction
endclass

class special_comp #(int N = 0) extends generic_comp;
   function new(string name = "special_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   typedef special_comp#(N) special_comp_type;
   typedef special_cb#(N) special_cb_type;

   `uvm_component_param_utils(special_comp#(N))
   `uvm_set_super_type(special_comp_type, generic_comp)
   `uvm_register_cb(special_comp_type, special_cb_type)
   `uvm_register_cb(special_comp_type, specific_cb)

   virtual task run();
      super.run();
      `uvm_do_callbacks(special_comp#(N), specific_cb, specific_f(q))
      `uvm_do_callbacks(special_comp#(N), special_cb#(N), special_f(q, N))
   endtask
endclass


class my_generic_cb extends generic_cb;
   string m_id;

   function new(string id);
      m_id = id;
   endfunction

   virtual function void generic_f(ref string q[$]);
      q.push_back({"my_generic_cb::generic_f(", m_id, ")"});
   endfunction
endclass


class my_specific_cb extends specific_cb;
   string m_id;

   function new(string id);
      m_id = id;
   endfunction

   virtual function void specific_f(ref string q[$]);
      q.push_back({"my_specific_cb::specific_f(", m_id, ")"});
   endfunction
endclass

class my_special_cb #(int N = 0) extends special_cb#(N);
   string m_id;

   function new(string id);
      m_id = id;
   endfunction

   virtual function void specific_f(ref string q[$]);
      q.push_back({"my_special_cb::specific_f(", m_id, ")"});
   endfunction

   virtual function void special_f(ref string q[$], input int n);
      q.push_back($sformatf("my_special_cb::special#(%0d)_f(%s)",
                            n, m_id));
   endfunction
endclass


class test extends uvm_test;

   bit pass = 1;

   special_comp#(1) a1;
   special_comp#(2) a2;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build();
      my_generic_cb  generic;
      my_specific_cb specific;
      my_special_cb#(1) special1;
      my_special_cb#(2) special2;

      a1  = new("a1", this);
      a2  = new("a2", this);

      generic = new("a1");
      uvm_callbacks#(generic_comp, generic_cb)::add(a1, generic);
      generic = new("*");
      uvm_callbacks#(generic_comp, generic_cb)::add(null, generic);
      special1 = new("a1");
      uvm_callbacks#(special_comp#(1), special_cb#(1))::add(null, special1);
      specific = new("*");
      uvm_callbacks#(special_comp#(1), specific_cb)::add(null, specific); // a1
      special2 = new("a2");
      uvm_callbacks#(special_comp#(2), special_cb#(2))::add(null, special2);
   endfunction

   virtual task run();
      uvm_top.stop_request();
   endtask

   virtual function void check();
      string p[$];
      bit fail = 0;

      uvm_pkg::uvm_callbacks#(uvm_object)::display();
      uvm_callbacks#(generic_comp)::display();
      uvm_callbacks#(special_comp#(1))::display();
      uvm_callbacks#(special_comp#(2))::display();

      print_trace("a1", a1.q);
      print_trace("a2", a2.q);

      p.push_back("my_generic_cb::generic_f(a1)");
      p.push_back("my_generic_cb::generic_f(*)");
      p.push_back("my_special_cb::specific_f(a1)");
      p.push_back("my_specific_cb::specific_f(*)");
      p.push_back("my_special_cb::special#(1)_f(a1)");
      fail = 0;
      foreach(p[i]) if(a1.q[i] != p[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "a1 did not execute expected callback sequence");
         print_trace("observed:", a1.q);
         print_trace("expected:", p);
         pass = 0;
      end

      p.delete();
      p.push_back("my_generic_cb::generic_f(*)");
      p.push_back("my_special_cb::specific_f(a2)");
      p.push_back("my_special_cb::special#(2)_f(a2)");
      fail = 0;
      foreach(p[i]) if(a2.q[i] != p[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "a2 did not execute expected callback sequence");
         print_trace("observed:", a2.q);
         print_trace("expected:", p);
         pass = 0;
      end
   endfunction

   function void print_trace(string name, ref string q[$]);
      $write("%s:", name);
      foreach (q[i]) begin
         $write(" \"%s\"", q[i]);
      end
      $write("\n");
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
