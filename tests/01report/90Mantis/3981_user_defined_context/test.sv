//---------------------------------------------------------------------- 
//   Copyright 2012 Mentor Graphics Corporation
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

/*
Test that the report catcher can catch messages issued by non-uvm_components
based on the user-defined context (i.e. the source of the message). The
source of the message for uvm_components is usually the hierarchical name
(get_full_name).  For non-UVM components the full name is always "reporter",
representing uvm_top. This means you can't filter non-uvm_component reports
based on their context. This test proves that you now can.


report(uvm_severity severity,
      string name,
      string id,
      string message,
      int verbosity_level,
      string filename,
      int line,
      uvm_report_object client
*/

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

bit ok = 1;

// user-defined catcher that uses new 'get_context' method to get the
// 'name' provided to the uvm_report_handler::report method.

class catcher extends uvm_report_catcher;
   virtual function action_e catch();
      if (get_context() == "some_context") begin
        set_severity(UVM_INFO);
        $display("message with context 'some_context' was caught");
        return CAUGHT;
      end
      return THROW;
   endfunction
endclass


// dummy test to satisfy regression environment's expectation of a uvm test
class test extends uvm_test;
   `uvm_component_utils(test)
   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction
   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10;
      phase.drop_objection(this);
   endtask
   virtual function void report();
      if (ok) 
        $display("** UVM TEST PASSED **\n");
      else
        $display("** UVM TEST FAILED! **\n");
   endfunction
endclass


initial begin

  automatic uvm_report_handler msg = new();

  automatic catcher rc = new;
  uvm_report_cb::add(null,rc);

  $display("UVM TEST EXPECT 1 UVM_ERROR");

  #1;
  msg.report(UVM_ERROR, "some_context",       "SOME_ID", "Issuing message that should be filtered");
  msg.report(UVM_ERROR, "some_other_context", "SOME_ID", "Issuing message that should not be filtered", UVM_MEDIUM, `__FILE__, `__LINE__); // UVM TEST RUN-TIME FAILURE


end

initial
  run_test();
  
endmodule

