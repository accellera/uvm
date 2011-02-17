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

  class mycomp extends uvm_component;
    int build_val=0;
 
    `uvm_new_func
    `uvm_component_utils(mycomp)

    function void build();
      super.build();
      void'(get_config_int("value", build_val));
    endfunction
  endclass
 
  class test extends uvm_component;
    mycomp mc1;
    mycomp mc2;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    `uvm_component_utils(test)

    function void build();
      super.build();
      set_config_int("*", "value", 22);
      set_config_int("mc2", "value", 33);
      mc1 = new("mc1", this);
      mc2 = new("mc2", this);
    endfunction

    task run;
      bit failed = 0;
      if(mc1.build_val != 22) begin
        $display("*** UVM TEST FAILED, expected mc1.build_val=22 but got %0d ***", mc1.build_val);
        failed = 1;
      end
      if(mc2.build_val != 33) begin
        $display("*** UVM TEST FAILED, expected mc2.build_val=33 but got %0d ***", mc2.build_val);
        failed = 1;
      end
      if(!failed) $display("*** UVM TEST PASSED ***");
    endtask
  endclass

  initial run_test();
endmodule
