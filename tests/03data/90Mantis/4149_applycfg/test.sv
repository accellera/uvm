//---------------------------------------------------------------------- 
//   Copyright 2012 Synopsys, Inc.
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

`include "uvm_macros.svh"

module test;

import uvm_pkg::*;

class my_comp_base extends uvm_component;
   int A;

  `uvm_component_utils_begin(my_comp_base)
    `uvm_field_int(A,UVM_DEFAULT)      
  `uvm_component_utils_end

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

endclass

class my_comp extends my_comp_base;
   int B;

  `uvm_component_utils_begin(my_comp)
    `uvm_field_int(B,UVM_DEFAULT)      
  `uvm_component_utils_end

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

endclass

class test extends uvm_test;  
   my_comp comp;

   `uvm_component_utils_begin(test) 
        `uvm_field_object(comp,UVM_DEFAULT)
   `uvm_component_utils_end    
   
   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      comp = my_comp::type_id::create("env", this);
      uvm_config_db#(uvm_bitstream_t)::set(this, "*", "A", 'hAA);
      uvm_config_db#(uvm_bitstream_t)::set(this, "*", "B", 'hBB);
   endfunction
   
   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      print();

      if (comp.A != 'hAA) begin
         `uvm_error("TEST", "comp.A was not auto-configured");
      end
      if (comp.B != 'hBB) begin
         `uvm_error("TEST", "comp.B was not auto-configured");
      end
      phase.drop_objection(this);
   endtask
   
   function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass

initial run_test("test");

endmodule
