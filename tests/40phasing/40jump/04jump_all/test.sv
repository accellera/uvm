//
//----------------------------------------------------------------------
//   Copyright 2007-2010 Cadence Design Systems, Inc.
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
import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_component;

   `uvm_component_utils(test)

   function new(string _name, uvm_component _parent);
      super.new(_name, _parent);
   endfunction : new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction : build_phase

   virtual function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
      
       // Attempt to jump to extract...
       uvm_domain::jump_all(uvm_extract_phase::get());
   endfunction : start_of_simulation_phase 
      
   virtual task run();
      uvm_test_done.raise_objection(this);
      `uvm_error(get_type_name(), "Should not be in run() we jumped to extract")
      #1;
         
      uvm_test_done.drop_objection(this);
   endtask : run

   virtual function void extract_phase(uvm_phase phase);
      uvm_report_server svr = _global_reporter.get_report_server();
      if (svr.get_severity_count(UVM_ERROR) == 0)
        $write("** UVM TEST PASSED **");
      else
        $write("!! UVM TEST FAILED !!");
   endfunction : extract_phase
  
endclass : test

module runner;
   initial 
     run_test();
endmodule // runner

