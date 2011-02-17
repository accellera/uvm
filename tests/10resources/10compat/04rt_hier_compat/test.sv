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

  class myleaf extends uvm_component;
    int build_val=0;
    int run_val=0;
 
    `uvm_new_func
    `uvm_component_utils(myleaf)

    function void build();
      super.build();
      void'(get_config_int("value", build_val));
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #5 void'(get_config_int("value", run_val));
      phase.drop_objection(this);
    endtask
  endclass
 
  class mycomp extends uvm_component;
    myleaf leaf; 
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    `uvm_component_utils(mycomp)

    function void build();
      super.build();
      set_config_int("mc", "value", 33);
      leaf = new("leaf", this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #2 set_config_int("leaf", "value", 55);
      phase.drop_objection(this);
    endtask
  endclass

  class test extends uvm_component;
    mycomp mc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    `uvm_component_utils(test)

    function void build();
      super.build();
      set_config_int("mc.leaf", "value", 22);
      mc = new("mc", this);
    endfunction

    task run_phase(uvm_phase phase);
      bit failed = 0;

      phase.raise_objection(this);
      set_config_int("mc.leaf", "value", 44); //takes precedence because of hierarhcy
      #10;
      if(mc.leaf.build_val != 22) begin 
        $display("*** UVM TEST FAILED, expected mc.leaf.build_val=22 but got %0d ***", mc.leaf.build_val);
        failed = 1;
      end

      // Create a backward incompat on purpose. Want last set at runtime. So,
      // would have gotten 44, but we want 55 since it is set at time 2.
      if(mc.leaf.run_val != 55) begin
        $display("*** UVM TEST FAILED, expected mc.run_val=55 but got %0d ***", mc.leaf.run_val);
        failed = 1;
      end
      if(!failed) $display("*** UVM TEST PASSED ***");
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test();
endmodule
