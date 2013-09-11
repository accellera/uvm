//---------------------------------------------------------------------- 
//   Copyright 2013 Cadence Design Systems, Inc.
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

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

   int a;

   assign a = something();
   
   function int something();
      uvm_config_db#(bit)::set(null,"a","b",1);
      return 1;
   endfunction // something


class test extends uvm_component;
   `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction // new

   function void report_phase(uvm_phase phase);
      uvm_report_info("TEST","*** UVM TEST PASSED ***",UVM_NONE);
   endfunction
endclass // test

   initial run_test();

endmodule
