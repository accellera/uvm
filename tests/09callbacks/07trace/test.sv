//
//----------------------------------------------------------------------
//   Copyright 2010 Verilab, Inc.
//   Copyright 2007-2011 Cadence Design Systems, Inc. 
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

// Description: 
//
// The UVM_CB_TRACE_ON flag causes debug information to be printed
// when callbacks are executed or registered. Test that this is, 
// indeed, the case.
//
// Test was copied from 09callbacks/01simple


module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Catch the messages that should be printed by the TRACE
  // option. We should flag an error if these never appear.
  class my_catcher extends uvm_report_catcher;
    // Keep a count of how many messages we saw. User can specify
    // how many messages should be seen during construction.
    local int unsigned count = 0;
    local int unsigned expected_count;

    function new(int unsigned c);
       super.new();
       this.expected_count = c;
    endfunction: new

    virtual function void trace_count(string msg);
       count++;
       $display(msg);
    endfunction: trace_count

    virtual function bit count_match();
      if (this.expected_count != count) begin
         $display($sformatf("ERROR: Expected %1d callback trace messages, but saw %1d during the test.", expected_count, count));
         return 0;
      end

      return 1;
    endfunction:count_match

    virtual function action_e catch();
      //$display("just caught a message with ID: ", get_id());
      if (get_id() == "UVMCB_TRC") begin
        string msg = get_message();
        $display("Just saw a UVMCB_TRC message.");

        case (1)
          uvm_is_match("*UVM_APPEND*", msg): trace_count("   - UVM_APPEND");
          uvm_is_match("*allback mode*", msg): trace_count("   - callback_mode");
          uvm_is_match("*Delete*", msg): trace_count("   - delete");
          //uvm_is_match("*METHOD_CALL*", msg): trace_count("   saw METHOD_CALL");
          uvm_is_match("*doit\(q\)*", msg): trace_count("   - User function doit(q)");
        endcase
      end
      return THROW;
    endfunction:catch
  endclass:my_catcher

  virtual class cb_base extends uvm_callback;
    function new(string name=""); super.new(name); endfunction
    pure virtual function void  doit(ref string q[$]);
  endclass

  // Create an component that will have callbacks
  class ip_comp extends uvm_component;
    string q[$];
    `uvm_component_utils(ip_comp)
    `uvm_register_cb(ip_comp,cb_base)
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      int i;
      uvm_report_info(get_name(), "In ip_comp run(): Executing callbacks");
      `uvm_do_callbacks(ip_comp,cb_base,doit(q))
    endtask
  endclass

  // User extends the VIP callback base class to add custom functionality
  class mycb extends cb_base;
    `uvm_object_utils(mycb)
    function new(string name=""); super.new(name); endfunction
    virtual function void  doit(ref string q[$]);
      q.push_back(get_name());
    endfunction
  endclass

  // Start the test
  // 1) Register some callbacks
  // 2) Test that callbacks can be disabled
  // 3) (added) Test that callbacks can be reenabled
  // 4) Callbacks should be executed
  // 5) (added) Trace info should be printed
  class test extends uvm_component;
    mycb cb, rcb;
    ip_comp comp;
    `uvm_component_utils(test)

    // Expecting to see 14 callback messages in this test.
    my_catcher catcher = new(14);

    function new(string name,uvm_component parent);
      super.new(name,parent);
      comp = new("comp",this);

      // First, register a catcher to see if TRACE messages appear.
      // Trace counter not incremented because catcher isn't registered yet! 
      uvm_report_cb::add(null, catcher); 
    endfunction

    function void build();
      cb = new("cb0");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb); // TRACE 1

      cb = new("cb1");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb); // TRACE 2

      // Disable callback cb1
      void'(cb.callback_mode(0)); // TRACE 3
  
      cb = new("cb2");
      rcb = cb;
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb); // TRACE 4
  
      cb = new("cb3");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb); // TRACE 5
  
      uvm_callbacks#(ip_comp,cb_base)::delete(comp,rcb); // TRACE 6
   
      cb = new("cb4");
      uvm_callbacks#(ip_comp,cb_base)::add(comp,cb); // TRACE 7
  
      uvm_callbacks#(ip_comp,cb_base)::display();  

    endfunction

    // Begin the test.
    task run;
      uvm_report_info(get_name(), "In run(): About to start test");

      // Next, run the test.
      #100 uvm_top.stop_request();

      // Check to see if the catcher saw both kinds of debug messages.
      // If not, stop simulation with an error.
    endtask

    function void report();
      int failed = 0;
      string exp[$];
      //cb2 was deleted and cb1 was disabled
      // TRACE 8, TRACE 9, TRACE 10 via calls to doit() in component 
      exp.push_back("cb0");  exp.push_back("cb3"); exp.push_back("cb4"); 
      $write("CBS: ");
      foreach(comp.q[i]) $write("%s ",comp.q[i]);
      $write("\n");
      foreach(comp.q[i]) 
        if(comp.q[i] != exp[i]) begin
           $display("ERROR: expected: comp.q[%0d]", i, exp[i]);
           $display("       got:      comp.q[%0d]", i, comp.q[i]);
           failed = 1;
        end

      // Make sure the catcher saw the expected number of messages.
      if (!catcher.count_match()) begin
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
