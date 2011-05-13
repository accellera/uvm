//---------------------------------------------------------------------- 
//   Copyright 2011 Cadence Design Systems, Inc.
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

module top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  class catcher extends uvm_report_catcher;
     static int seen = 0;
     virtual function action_e catch();
        if(get_id() == "INVSTNM" && get_severity() == UVM_ERROR) begin
          $display("Caught the INVSTNM error message...");
          seen++;
          return CAUGHT;
        end
        return THROW;
     endfunction
  endclass

  class test extends uvm_test;

     `uvm_component_utils(test)

     function new(string name, uvm_component parent = null);
        super.new(name, parent);
     endfunction
  
     virtual task run_phase(uvm_phase phase);
        catcher ctchr = new;
        uvm_report_cb::add(null,ctchr);

        this.set_name("foo");

        if (catcher::seen == 0) begin
           $display("**** UVM TEST FAILED : didn't see the error ****");
        end
        else begin
           $display("**** UVM TEST PASSED ****");
        end
     endtask
  endclass


  initial run_test();

endmodule
