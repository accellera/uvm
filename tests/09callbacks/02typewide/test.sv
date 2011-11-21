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

// Test: 02typewide
// Purpose: Basic tests for typewide callbacks
// API tested:
//   `uvm_do_callbacks
//   `uvm_register_cb
//      uvm_callbacks#(T,CB)::add(null,cb); //append
//      uvm_callbacks#(T,CB)::add(null,cb,UVM_PREPEND); //preappend
//      uvm_callbacks#(T,CB)::delete(null,cb);   
//      uvm_callback::callback_mode(0); //disable

module test;
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
      uvm_report_info("EXCB","executing callbacks",UVM_NONE);
      `uvm_do_callbacks(ip_comp,cb_base,doit(q))
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
    ip_comp comp, comp1;
    `uvm_component_utils(test)
    function new(string name,uvm_component parent);
      super.new(name,parent);
      comp = new("comp",this);

      cb = new("comp_cb0");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb);
      cb = new("tw_cb0");
      uvm_callbacks#(ip_comp,cb_base)::add(null,cb);
    endfunction

    function void build();
      comp1 = new("comp1",this);

      cb = new("comp1_cb0");
      uvm_callbacks#(ip_comp,cb_base)::add(comp1,cb);

      cb = new("disabled_cb1");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb);
      void'(cb.callback_mode(0));
      uvm_callbacks#(ip_comp,cb_base)::add(comp1,cb);
  
      cb = new("cb2");
      rcb = cb;
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb);
      uvm_callbacks#(ip_comp,cb_base)::add(comp1,cb);
  
      cb = new("cb3");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb);
 
      //delete type wide 
      uvm_callbacks#(ip_comp,cb_base)::delete(null,rcb);
   
      cb = new("tw_cb4");
      uvm_callbacks#(ip_comp,cb_base)::add(null,cb,UVM_PREPEND);
  
      uvm_callbacks#(ip_comp,cb_base)::display();
    endfunction

    task run;
      #100 uvm_top.stop_request();
    endtask

    function void report();
      int failed = 0;
      string exp[$], exp1[$];
      //cb2 was deleted and cb1 was disabled

      exp.push_back("comp_cb0");  exp.push_back("tw_cb0"); 
      exp.push_back("cb3");  exp.push_front("tw_cb4");

      exp1.push_back("tw_cb0"); 
      exp1.push_back("comp1_cb0");  exp1.push_front("tw_cb4");

      $write("comp CBS: ");
      foreach(comp.q[i]) $write("%s ",comp.q[i]);
      $write("\n");
      $write("comp1 CBS: ");
      foreach(comp1.q[i]) $write("%s ",comp1.q[i]);
      $write("\n");

      foreach(comp.q[i]) 
        if(comp.q[i] != exp[i]) begin
           $display("ERROR: expected: comp.q[%0d] = %s", i, exp[i]);
           $display("       got:      comp.q[%0d] = %s", i, comp.q[i]);
           failed = 1;
        end
      foreach(comp1.q[i]) 
        if(comp1.q[i] != exp1[i]) begin
           $display("ERROR: expected: comp1.q[%0d] = %s", i, exp1[i]);
           $display("       got:      comp1.q[%0d] = %s", i, comp1.q[i]);
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
