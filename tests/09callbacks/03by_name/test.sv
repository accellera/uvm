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

// Test: 03by_name
// Purpose: To test adding and removing callbacks by name 
// API tested:
//   `uvm_do_callbacks
//   `uvm_register_cb
//      uvm_callbacks#(T,CB)::add_by_name("name",cb); //append
//      uvm_callbacks#(T,CB)::add_by_name("name",cb,null,UVM_PREPEND); //preappend
//      uvm_callbacks#(T,CB)::delete_by_name("name",cb);   

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  virtual class cb_base extends uvm_callback;
    function new(string name=""); super.new(name); endfunction
    pure virtual function void  doit(ref string q[$]);
  endclass

  class ip_comp extends uvm_component;
    string q[$];
    `uvm_component_utils(ip_comp)
    `uvm_register_cb(ip_comp,cb_base)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      int i;
      $display("executing callbacks");
      `uvm_do_callbacks(ip_comp,cb_base,doit(q))
    endtask
  endclass

  class ip_der extends ip_comp;
    `uvm_component_utils(ip_der)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass

  class leaf extends uvm_component;
    `uvm_component_utils(leaf)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
  endclass

  class mid extends uvm_component;
    ip_comp ip1;
    leaf    leaf1;
    ip_der  ip2;
    ip_der  der1;

    `uvm_component_utils(mid)
    function new(string name,uvm_component parent);
      super.new(name,parent);
      ip1 = new("ip1", this);
      leaf1 = new("leaf1", this);
      ip2 = new("ip2", this);
      der1 = new("der1", this);
    endfunction
  endclass

  class mycb extends cb_base;
    function new(string name=""); super.new(name); endfunction
    `uvm_object_utils(mycb)
    virtual function void  doit(ref string q[$]);
      q.push_back(get_name());
    endfunction
  endclass

  class test extends uvm_component;
    mycb cb, del_cb;
    mid m1;

    `uvm_component_utils(test)

    function new(string name,uvm_component parent);
      super.new(name,parent);
      m1=new("m1",this);
    endfunction

    typedef uvm_callbacks#(ip_comp,cb_base) cbtype;
    function void end_of_elaboration();
      cb = new("*1");
      cbtype::add_by_name("*1", cb, this);
      cb = new("*.ip1");
      cbtype::add_by_name("*.ip1", cb, this);
      cb = new("*.der1");
      del_cb = cb;
      cbtype::add_by_name("*.der1", cb, this);
      cb = new("*");
      cbtype::add_by_name("*", cb, this, UVM_PREPEND);

      cbtype::delete_by_name("*m1.de*",del_cb,this);

      uvm_callbacks#(ip_comp,cb_base)::display();
    endfunction
    task run;
      #10 uvm_top.stop_request();
    endtask
    function void report();
      bit failed = 0;

      $write("m1.ip1: ");
      foreach(m1.ip1.q[i]) $write("%s ", m1.ip1.q[i]);
      $write("\n");

      $write("m1.der1: ");
      foreach(m1.der1.q[i]) $write("%s ", m1.der1.q[i]);
      $write("\n");

      $write("m1.ip2: ");
      foreach(m1.ip2.q[i]) $write("%s ", m1.ip2.q[i]);
      $write("\n");

      if(m1.ip1.q.size() != 3) failed = 1;
      else begin
        if(m1.ip1.q[0] != "*") failed = 1;
        if(m1.ip1.q[1] != "*1") failed = 1;
        if(m1.ip1.q[2] != "*.ip1") failed = 1;
      end
      if(m1.der1.q.size() != 2) failed = 1;
      else begin
        if(m1.ip1.q[0] != "*") failed = 1;
        if(m1.ip1.q[1] != "*1") failed = 1;
      end
      if(m1.ip2.q.size() != 1) failed = 1;
      else
        if(m1.ip1.q[0] != "*") failed = 1;

      if(failed)
        $write("** UVM TEST FAILED! **\n");
      else
        $write("** UVM TEST PASSED! **\n");
    endfunction
  endclass


  initial begin
    run_test("test");
  end
  
endmodule
