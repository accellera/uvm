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

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class myagent extends uvm_agent;
    `uvm_new_func
  endclass

  class test extends uvm_test;
    myagent agent1, agent2;

    `uvm_new_func
    `uvm_component_utils(test)

    function void build();
      set_config_int("agent1","is_active",UVM_ACTIVE);
      set_config_int("agent2","is_active",UVM_PASSIVE);
      agent1 = new("agent1", this);
      agent2 = new("agent2", this);
    endfunction

    task run;
      bit failed=0;
      if(agent1.is_active != UVM_ACTIVE || agent1.get_is_active() != UVM_ACTIVE) begin
       $display("*** UVM TEST FAILED, agent1 is not active as expected ***");
       failed = 1;
      end
      if(agent2.is_active != UVM_PASSIVE || agent2.get_is_active() != UVM_PASSIVE) begin
       $display("*** UVM TEST FAILED, agent2 is not passive as expected ***");
       failed = 1;
      end
      if(!failed) $display("*** UVM TEST PASSED ***");
    endtask
  endclass

initial run_test();
endmodule
