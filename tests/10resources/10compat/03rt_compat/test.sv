//---------------------------------------------------------------------- 
//   Copyright 2010 Mentor Graphics Corporation
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

  class mycomp extends uvm_component;
    int build_val=0;
    int run_val=0;
 
    `uvm_new_func
    `uvm_component_utils(mycomp)

    function void build();
      super.build();
      void'(get_config_int("value", build_val));
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #2;
      void'(get_config_int("value", run_val));
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
      set_config_int("mc", "value", 22);
      set_config_int("mc", "value", 33);
      mc = new("mc", this);
    endfunction

    task run_phase(uvm_phase phase);
      bit failed = 0;
      phase.raise_objection(this);
      set_config_int("mc", "value", 44);
      #10;
      if(mc.build_val != 33) begin 
        $display("*** UVM TEST FAILED, expected mc.build_val=33 but got %0d ***", mc.build_val);
        failed = 1;
      end
      if(mc.run_val != 44) begin
        $display("*** UVM TEST FAILED, expected mc.run_val=44 but got %0d ***", mc.run_val);
        failed = 1;
      end
      if(!failed) $display("*** UVM TEST PASSED ***");
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test();
endmodule
