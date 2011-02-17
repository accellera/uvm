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

// This test verifies that the configured setting of
// the global timeout is used by the run phase.

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class lower_comp extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    function void start_of_simulation();
      // This will be the last setting, so it should be the
      // one used.
      `uvm_info("SETTO","Setting timeout to 33ms", UVM_NONE)
      //uvm_top.set_config_int("", "timeout", 33ms);
      uvm_top.set_timeout(33ms);
      
    endfunction
  endclass
  class middle_comp extends uvm_component;
    lower_comp lc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      lc = new("lc", this);
    endfunction
    function void end_of_elaboration();
      `uvm_info("SETTO","Setting timeout to 88ns", UVM_NONE)
      //uvm_top.set_config_int("", "timeout", 88ns);
      uvm_top.set_timeout(88ns);
    endfunction
  endclass
  class top_comp extends uvm_component;
    middle_comp mc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc = new("mc", this);
    endfunction
    function void build();
      `uvm_info("SETTO","Setting timeout to 7s", UVM_NONE)
      //uvm_top.set_config_int("", "timeout", 7s);
      uvm_top.set_timeout(7s);
    endfunction
  endclass
  class test extends uvm_component;
    top_comp tc;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      tc = new("tc", this);
      uvm_top.set_report_id_action_hier("PH_TIMEOUT", UVM_NO_ACTION);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
    endtask
       
    function void report();
      if($time == 33ms) $display("** UVM TEST PASSED **");
      else $display("** UVM TEST FAILED **", $time);
    endfunction
  endclass

  initial run_test("test");

  initial begin
    
    //safety check
    #34ms  $display("** UVM TEST FAILED **", $time);
  end
endmodule
