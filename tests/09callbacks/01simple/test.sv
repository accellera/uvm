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

// Test: 01simple
// Purpose: To test the basic usage of callbacks. 
// API tested:
//   `uvm_do_callbacks
//   `uvm_register_cb
//      uvm_callbacks#(T,CB)::add(comp,cb); //append
//      uvm_callbacks#(T,CB)::add(comp,cb,UVM_PREPEND); //preappend
//      uvm_callbacks#(T,CB)::delete(comp,cb);   
//      uvm_callback::callback_mode(0); //disable
//      uvm_callback::callback_mode(1); //enable
//      uvm_callback::callback_mode();  //read

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
      // Executes the callbacks twice. cb2 is disabled the first
      // time through but enabled for the second time.
      repeat(2) begin
        $display("executing callbacks");
        `uvm_do_callbacks(ip_comp,cb_base,doit(q))
        #10;
      end
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
    mycb cb, rcb, dis_cb;
    ip_comp comp;
    `uvm_component_utils(test)
    function new(string name,uvm_component parent);
      super.new(name,parent);
      comp = new("comp",this);
    endfunction

    function void build();
      cb = new("cb0");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb);

      if(cb.callback_mode() != 1)
        $display("## UVM_TEST FAILED, expected cb mode 1 **");

      cb = new("cb1");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb);
      void'(cb.callback_mode(0));
      dis_cb = cb;
  
      if(cb.callback_mode() != 0)
        $display("## UVM_TEST FAILED, expected cb mode 0 **");

      cb = new("cb2");
      rcb = cb;
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb);
  
      cb = new("cb3");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb);
  
      uvm_callbacks#(ip_comp,cb_base)::delete(comp,rcb);
   
      cb = new("cb4");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb, UVM_PREPEND);
  
      uvm_callbacks#(ip_comp,cb_base)::display();

    endfunction

    task run;
      #5 void'(dis_cb.callback_mode(1));
      #100 uvm_top.stop_request();
    endtask

    function void report();
      int failed = 0;
      string exp[$];
      //cb2 was deleted and cb1 was disabled
      exp.push_back("cb4"); exp.push_back("cb0");  exp.push_back("cb3"); 
      exp.push_back("cb4"); exp.push_back("cb0");  exp.push_back("cb1"); exp.push_back("cb3"); 
      $write("CBS: ");
      foreach(comp.q[i]) $write("%s ",comp.q[i]);
      $write("\n");
      foreach(comp.q[i]) 
        if(comp.q[i] != exp[i]) begin
           $display("ERROR: expected: comp.q[%0d]", i, exp[i]);
           $display("       got:      comp.q[%0d]", i, comp.q[i]);
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
