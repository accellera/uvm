//---------------------------------------------------------------------- 
//   Copyright 2010 Cadence Design Systems, Inc. 
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

// This test verifies that a persistent thread does not stall a phase
// from completing and that a persistent thread is not killed when the
// phase ends.
//
// The low component starts a persistent thread by using set_thread_mode,
// and the sub component starts a persistent thread by using 
// set_default_thread_mode.

import uvm_pkg::*;
`include "uvm_macros.svh"

bit failed=0;
class low extends uvm_component;

   `uvm_component_utils(low)

   function new(string name = "my_comp", uvm_component parent = null);
      super.new(name, parent);
      set_phase_domain("uvm");
   endfunction

   bit reset_activated = 0; 
   bit main_started = 0; 

   task reset();
      uvm_phase_schedule s = get_current_phase();
      set_thread_mode(UVM_PHASE_PERSISTENT);
      `uvm_info("RESET", "Start reset...", UVM_NONE)
      #100;
      if(s.get_state() != UVM_PHASE_DONE) begin
        failed = 1;
        `uvm_error("NTDONE", "Reset phase was not done during reactivation")
      end
      reset_activated = 1;
      `uvm_info("RESET", "Finish reset task...", UVM_NONE)
   endtask
   
   task main();
     main_started = 1;
     if($time != 0) begin
        failed = 1;
        `uvm_error("BDTIME", "Main phase was not started at time 0")
     end
     `uvm_info("MAIN", "Start main...", UVM_NONE)
     #150 `uvm_info("MAIN", "End main...", UVM_NONE)
   endtask
endclass 
   
class sub extends uvm_component;
   bit cfg_activated = 0; 

   `uvm_component_utils(sub)   
   function new(string name = "sub1", uvm_component parent = null);
      super.new(name, parent);    
      set_phase_domain("uvm");
      set_default_thread_mode(UVM_PHASE_PERSISTENT);  
   endfunction

   task configure();
      uvm_phase_schedule s = get_current_phase();
      `uvm_info("CFG", "Start configure...", UVM_NONE)
      #10;
      if(s.get_state() != UVM_PHASE_DONE) begin
        failed = 1;
        `uvm_error("NTDONE", "Configure phase was not done during reactivation")
      end
      cfg_activated = 1;
      `uvm_info("CFG", "Finish configure task...", UVM_NONE)
   endtask
   
endclass

class test extends uvm_component;      
   `uvm_component_utils(test)
   sub sub_inst;
   low low_inst;

   function new(string name = "test1", uvm_component parent = null);
      super.new(name, parent);
   endfunction
   function void build();
      super.build();    
      sub_inst = sub::type_id::create("sub_inst", this);
      low_inst = low::type_id::create("low_inst", this);
   endfunction
   function void finalize();
     if(!low_inst.reset_activated) begin
       failed = 1;
       `uvm_error("RSTFAIL", "low_inst.reset phase did not reactivate as expected")
     end
     if(!low_inst.main_started) begin
       failed = 1;
       `uvm_error("MNFAIL", "low_inst.main phase never started")
     end
     if(!sub_inst.cfg_activated) begin
       failed = 1;
       `uvm_error("CFGFAIL", "sub_inst.configure phase did not reactivate as expected")
     end
     if(failed == 0)
       $display("**** UVM TEST PASSED ****");
     else
       $display("**** UVM TEST FAILED ****");
   endfunction
endclass
	 
initial
begin
   run_test("test");
end

endmodule

