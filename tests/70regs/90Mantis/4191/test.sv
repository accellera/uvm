//---------------------------------------------------------------------- 
//   Copyright 2012 Accellera Systems Initiative
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


program top;

`include "uvm_macros.svh"
import uvm_pkg::*;

class test extends uvm_test;
   uvm_reg_predictor#(uvm_sequence_item) predictor;
  
   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
     super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
     predictor = uvm_reg_predictor#(uvm_sequence_item)::type_id::create("predictor", this);
   endfunction

   task run_phase(uvm_phase phase);
     if (predictor.get_type_name() != "uvm_reg_predictor #(uvm_sequence_item)")
       `uvm_error(get_type_name(), {"Expected 'uvm_reg_predictor #(uvm_sequence_item)' when calling get_type_name(), but saw: ", predictor.get_type_name()})
   endtask
  
   function void report_phase(uvm_phase phase);
      uvm_coreservice_t cs_;
      uvm_report_server svr;
      cs_ = uvm_coreservice_t::get();
      svr = cs_.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
