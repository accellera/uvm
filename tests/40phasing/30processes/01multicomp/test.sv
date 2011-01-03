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

import uvm_pkg::*;
`include "uvm_macros.svh"

class passive_comp extends uvm_component;
  `uvm_component_utils(passive_comp)

  int cnt=0;

  function new (string name, uvm_component parent);
    super.new(name,parent);
    set_phase_domain("uvm");
  endfunction

  task main;
    fork
      doit;
    join_none
    #15;
  endtask

  task doit;
    forever #10 cnt++;
  endtask
endclass

class active_comp extends uvm_component;
  `uvm_component_utils(active_comp)

  int started, post_started;
  int ended, post_ended;

  function new (string name, uvm_component parent);
    super.new(name,parent);
    set_phase_domain("uvm");
  endfunction

  task main;
    started = 1;
    #105;
    ended = 1;
  endtask
  task post_main;
    post_started = 1;
    #105;
    post_ended = 1;
  endtask

endclass

class test extends uvm_test;
   passive_comp p_comp;
   active_comp  a_comp;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
      set_phase_domain("uvm");

      p_comp = new("p_comp", this);
      a_comp = new("a_comp", this);
   endfunction

   function void report;
     //The passive component should count to 10 (every 10 units for
     //105 units. We want to verify that it terminated correctly.
     if(p_comp.cnt != 10) begin
       $display("*** UVM TEST FAILED : p_comp count = %0d, expected 10 ***", p_comp.cnt);
       return;
     end
     if(!a_comp.started || !a_comp.ended) begin
       $display("*** UVM TEST FAILED : main phase never exectued ***");
       return;
     end
     if(!a_comp.post_started || !a_comp.post_ended) begin
       $display("*** UVM TEST FAILED : post_main phase never exectued ***");
       return;
     end
     $display("*** UVM TEST PASSED ***");
   endfunction
endclass

initial begin
  run_test();
end

endmodule
