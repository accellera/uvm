
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

// Test: 20inherit
// Purpose: Test a complex inheritence hierarchy with different types
//   of callbacks used at each level of the hierarchy, mixing typewide
//   and instance specific callbacks.
// API tested:
//   `uvm_do_callbacks
//   `uvm_register_cb
//   `uvm_set_super_type
//   uvm_callbacks#(T,CB)::add(comp,cb); //append
//   uvm_callbacks#(T,CB)::display();
//
// Callback Class hierarchy
//
//         base_cb               z_cb
//    ^       ^    ^              ^
//   /        |     \             |
// my_base_cb |      |          my_z_cb
//           a_cb   b_cb
//          ^  ^     ^
//         /   |      \     
//    my_a__cb |     my_b_cb
//            ax_cb
//             ^
//             |
//           my_ax_cb
//
// Component Class Hierarchy (and callbacks they use)
//
//          base_comp (base_cb)
//          ^       ^
//        /          \
//    a_comp (a_cb)  b_comp (b_cb)
//      ^    (z_cb)
//      |
//    ax_comp (ax_cb)


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

virtual class base_cb extends uvm_callback;
   function new(string name = "base_cb");
      super.new(name);
   endfunction

   virtual function void base_f(ref string q[$]);
   endfunction
endclass


virtual class a_cb extends base_cb;
   function new(string name = "a_cb");
      super.new(name);
   endfunction

   virtual function void a_f(ref string q[$]);
   endfunction
endclass


virtual class b_cb extends base_cb;
   function new(string name = "b_cb");
      super.new(name);
   endfunction

   virtual function void b_f(ref string q[$]);
   endfunction
endclass


virtual class ax_cb extends a_cb;
   function new(string name = "ax_cb");
      super.new(name);
   endfunction

   virtual function void ax_f(ref string q[$]);
   endfunction
endclass


virtual class z_cb extends uvm_callback;
   function new(string name = "z_cb");
      super.new(name);
   endfunction

   virtual function void z_f(ref string q[$]);
   endfunction
endclass


class base_comp extends uvm_component;
   string q[$];

   function new(string name = "base_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(base_comp)
   `uvm_register_cb(base_comp, base_cb)

   virtual task run();
      `uvm_do_callbacks(base_comp, base_cb, base_f(q))
   endtask
endclass


class a_comp extends base_comp;
   function new(string name = "a_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(a_comp)
   `uvm_register_cb(a_comp, a_cb)
   `uvm_register_cb(a_comp, z_cb)
   `uvm_set_super_type(a_comp, base_comp)

   virtual task run();
      super.run();
      `uvm_do_callbacks(a_comp, a_cb, a_f(q))
      `uvm_do_callbacks(a_comp, z_cb, z_f(q))
   endtask
endclass


class ax_comp extends a_comp;
   function new(string name = "ax_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(ax_comp)
   `uvm_register_cb(ax_comp, ax_cb)
   `uvm_set_super_type(ax_comp, a_comp)

   virtual task run();
      super.run();
      `uvm_do_callbacks(ax_comp, ax_cb, ax_f(q))
   endtask
endclass


class b_comp extends base_comp;
   function new(string name = "b_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(b_comp)
   `uvm_register_cb(b_comp, b_cb)
   `uvm_set_super_type(b_comp, base_comp)

   virtual task run();
      super.run();
      `uvm_do_callbacks(b_comp, b_cb, b_f(q))
   endtask
endclass


class my_base_cb extends base_cb;
   string m_id;

   function new(string nm, string id);
      super.new(nm);
      m_id = id;
   endfunction

   virtual function void base_f(ref string q[$]);
      q.push_back({"my_base_cb::base_f(", m_id, ")"});
   endfunction
endclass


class my_a_cb extends a_cb;
   string m_id;

   function new(string nm, string id);
      super.new(nm);
      m_id = id;
   endfunction

   virtual function void base_f(ref string q[$]);
      q.push_back({"my_a_cb::base_f(", m_id, ")"});
   endfunction

   virtual function void a_f(ref string q[$]);
      q.push_back({"my_a_cb::a_f(", m_id, ")"});
   endfunction
endclass


class my_b_cb extends b_cb;
   string m_id;

   function new(string nm, string id);
      super.new(nm);
      m_id = id;
   endfunction

   virtual function void base_f(ref string q[$]);
      q.push_back({"my_b_cb::base_f(", m_id, ")"});
   endfunction

   virtual function void b_f(ref string q[$]);
      q.push_back({"my_b_cb::b_f(", m_id, ")"});
   endfunction
endclass


class my_ax_cb extends ax_cb;
   string m_id;

   function new(string nm, string id);
      super.new(nm);
      m_id = id;
   endfunction

   virtual function void base_f(ref string q[$]);
      q.push_back({"my_ax_cb::base_f(", m_id, ")"});
   endfunction

   virtual function void a_f(ref string q[$]);
      q.push_back({"my_ax_cb::a_f(", m_id, ")"});
   endfunction

   virtual function void ax_f(ref string q[$]);
      q.push_back({"my_ax_cb::ax_f(", m_id, ")"});
   endfunction
endclass


class my_z_cb extends z_cb;
   string m_id;

   function new(string nm, string id);
      super.new(nm);
      m_id = id;
   endfunction

   virtual function void z_f(ref string q[$]);
      q.push_back({"my_z_cb::z_f(", m_id, ")"});
   endfunction
endclass


class test extends uvm_test;

   bit pass = 1;

   a_comp  a1,  a2;
   ax_comp ax1, ax2;
   b_comp  b1,  b2;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build();
      my_base_cb  base;
      my_a_cb  a;
      my_z_cb  z;
      my_ax_cb ax;
      my_b_cb  b;

      a1  = new("a1", this);
      a2  = new("a2", this);
      ax1 = new("ax1", this);
      ax2 = new("ax2", this);
      b1  = new("b1", this);
      b2  = new("b2", this);

      base = new("my_base_a1","a1");
      uvm_callbacks#(base_comp, base_cb)::add(a1, base);
      base = new("my_base_*","*");
      uvm_callbacks#(base_comp, base_cb)::add(null, base); // All components
      a    = new("my_a_a1", "a1");
      uvm_callbacks#(a_comp, a_cb)::add(a1, a);
      a    = new("my_a_*","a*");
      uvm_callbacks#(a_comp, a_cb)::add(null, a);       // a1, a2, ax1 & ax2
      z    = new("my_z_a1", "a1");
      uvm_callbacks#(a_comp, z_cb)::add(a1, z);
      z    = new("my_z_*", "a*");
      uvm_callbacks#(a_comp, z_cb)::add(null, z);      // a1, a2, ax1 & ax2
      b    = new("my_b_b1", "b1");
      uvm_callbacks#(b_comp, b_cb)::add(b1, b);
      b    = new("my_b_*", "b*");
      uvm_callbacks#(b_comp, b_cb)::add(null, b);      // b1 & b2
      ax    = new("my_ax_ax1","ax1");
      uvm_callbacks#(ax_comp, ax_cb)::add(ax1, ax);
      ax    = new("my_ax_*","ax*");
      uvm_callbacks#(ax_comp, ax_cb)::add(null, ax);    // ax1 & ax2
   endfunction

   virtual task run();
      uvm_top.stop_request();
   endtask

   virtual function void check();
      string p[$];
      bit fail = 0;

      uvm_pkg::uvm_callbacks#(uvm_object)::display();
      uvm_callbacks#(a_comp)::display();
      uvm_callbacks#(b_comp)::display();
      uvm_callbacks#(ax_comp)::display();

      print_trace("a1", a1.q);
      print_trace("a2", a2.q);
      print_trace("ax1", ax1.q);
      print_trace("ax2", ax2.q);
      print_trace("b1", b1.q);
      print_trace("b2", b2.q);

      p.push_back("my_base_cb::base_f(a1)");
      p.push_back("my_base_cb::base_f(*)");
      p.push_back("my_a_cb::base_f(a1)");
      p.push_back("my_a_cb::base_f(a*)");
      p.push_back("my_a_cb::a_f(a1)");
      p.push_back("my_a_cb::a_f(a*)");
      p.push_back("my_z_cb::z_f(a1)");
      p.push_back("my_z_cb::z_f(a*)");
      fail = 0;
      foreach(p[i]) if(a1.q[i] != p[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "a1 did not execute expected callback sequence");
         print_trace("observed:", a1.q);
         print_trace("expected:", p);
         pass = 0;
      end

      p.delete();
      p.push_back("my_base_cb::base_f(*)");
      p.push_back("my_a_cb::base_f(a*)"); //----
      p.push_back("my_a_cb::a_f(a*)");
      p.push_back("my_z_cb::z_f(a*)");
      fail = 0;
      foreach(p[i]) if(a2.q[i] != p[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "a2 did not execute expected callback sequence");
         print_trace("observed:", a2.q);
         print_trace("expected:", p);
         pass = 0;
      end

      p.delete();
      p.push_back("my_base_cb::base_f(*)");
      p.push_back("my_a_cb::base_f(a*)");
      p.push_back("my_ax_cb::base_f(ax1)");
      p.push_back("my_ax_cb::base_f(ax*)");
      p.push_back("my_a_cb::a_f(a*)");
      p.push_back("my_ax_cb::a_f(ax1)");
      p.push_back("my_ax_cb::a_f(ax*)");
      p.push_back("my_z_cb::z_f(a*)");
      p.push_back("my_ax_cb::ax_f(ax1)");
      p.push_back("my_ax_cb::ax_f(ax*)");
      fail = 0;
      foreach(p[i]) if(ax1.q[i] != p[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "ax1 did not execute expected callback sequence");
         print_trace("observed:", ax1.q);
         print_trace("expected:", p);
         pass = 0;
      end

      p.delete();
      p.push_back("my_base_cb::base_f(*)");
      p.push_back("my_a_cb::base_f(a*)"); 
      p.push_back("my_ax_cb::base_f(ax*)");
      p.push_back("my_a_cb::a_f(a*)");
      p.push_back("my_ax_cb::a_f(ax*)");
      p.push_back("my_z_cb::z_f(a*)");
      p.push_back("my_ax_cb::ax_f(ax*)");
      fail = 0;
      foreach(p[i]) if(ax2.q[i] != p[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "ax2 did not execute expected callback sequence");
         print_trace("observed:", ax2.q);
         print_trace("expected:", p);
         pass = 0;
      end

      p.delete();
      p.push_back("my_base_cb::base_f(*)");
      p.push_back("my_b_cb::base_f(b1)");
      p.push_back("my_b_cb::base_f(b*)");
      p.push_back("my_b_cb::b_f(b1)");
      p.push_back("my_b_cb::b_f(b*)");
      fail = 0;
      foreach(p[i]) if(b1.q[i] != p[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "b1 did not execute expected callback sequence");
         print_trace("observed:", b1.q);
         print_trace("expected:", p);
         pass = 0;
      end

      p.delete();
      p.push_back("my_base_cb::base_f(*)");
      p.push_back("my_b_cb::base_f(b*)"); //----
      p.push_back("my_b_cb::b_f(b*)");
      fail = 0;
      foreach(p[i]) if(b2.q[i] != p[i]) fail = 1;
      if (fail) begin
         `uvm_error("TEST", "b2 did not execute expected callback sequence");
         print_trace("observed:", b2.q);
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
$display("BASE_COMP: %0d", uvm_typeid#(base_comp)::get());
$display("A_COMP: %0d", uvm_typeid#(a_comp)::get());
$display("AX_COMP: %0d", uvm_typeid#(ax_comp)::get());
$display("B_COMP: %0d", uvm_typeid#(b_comp)::get());
     run_test();
  end

endprogram
