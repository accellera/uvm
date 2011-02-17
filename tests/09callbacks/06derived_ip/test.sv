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

// Test: 06derived_ip
// Purpose: Tests having a class hierarchy which uses callbacks
//   at different levels of the hierarchy.
// API tested:
//   `uvm_do_callbacks
//   `uvm_register_cb
//   `uvm_set_super_type
//      uvm_callbacks#(T,CB)::add(comp,cb); //append
//      uvm_callbacks#(T,CB)::delete(comp,cb);   
//      uvm_callback::callback_mode(0); //disable

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  virtual class cb_base extends uvm_callback;
    function new(string name=""); super.new(name); endfunction
    pure virtual function void doit(ref string q[$]);
  endclass

  class ip_base extends uvm_component;
    string q[$];
    `uvm_component_utils(ip_base)
    `uvm_register_cb(ip_base,cb_base)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      int i;
      $display("executing callbacks from ip_base");
      `uvm_do_callbacks(ip_base,cb_base,doit(q))
    endtask
  endclass

  class ip_ext extends ip_base;
    `uvm_component_utils(ip_ext)
    `uvm_set_super_type(ip_ext,ip_base)
    `uvm_register_cb(ip_ext,cb_base)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      int i;
//Since we are executing the same callbacks, they should happen
//in both places.
      $display("executing callbacks from derived class");
      `uvm_do_callbacks(ip_ext,cb_base,doit(q))
      super.run();
      uvm_top.stop_request();

    endtask
  endclass 

  class mycb extends cb_base;
    `uvm_object_utils(mycb)
    function new(string name=""); super.new(name); endfunction
    virtual function void  doit(ref string q[$]);
      q.push_back(get_name());
    endfunction
  endclass


  class test extends uvm_component;
    mycb cb, rcb;
    ip_ext comp;
    `uvm_component_utils(test)
    function new(string name,uvm_component parent);
      super.new(name,parent);
      comp = new("comp",this);
    endfunction

    function void build();
      cb = new("cb0");
      uvm_callbacks#(ip_ext,cb_base)::add(comp,cb);

      cb = new("cb1");
      uvm_callbacks#(ip_ext,cb_base)::add(comp,cb);
      void'(cb.callback_mode(0));
  
      cb = new("cb2");
      rcb = cb;
      uvm_callbacks#(ip_base,cb_base)::add(comp,cb);
  
      cb = new("cb3");
      uvm_callbacks#(ip_base,cb_base)::add(comp,cb);
  
      uvm_callbacks#(ip_base,cb_base)::delete(comp,rcb);
   
      uvm_callbacks#(ip_base,cb_base)::display();
    endfunction

    function void report();
      int failed = 0;
      string exp[$];
      //cb2 was deleted and cb1 was disabled
      exp.push_back("cb0"); exp.push_back("cb3"); 
      exp.push_back("cb0"); exp.push_back("cb3"); 
      $write("CBS: ");
      foreach(comp.q[i]) $write("%s ",comp.q[i]);
      $write("\n");
      foreach(comp.q[i]) 
        if(comp.q[i] != exp[i]) begin
           $display("ERROR: expected: comp.q[%0d] %s", i, exp[i]);
           $display("       got:      comp.q[%0d] %s", i, comp.q[i]);
           failed = 1;
        end
      if(failed)
        $write("** UVM TEST FAILED! **\n");
      else
        $write("** UVM TEST PASSED! **\n");
    endfunction
  endclass

  initial begin
    run_test();
  end
  
endmodule
