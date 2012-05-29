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

// -*- focus : test uvm_config_db type safe handling (compile time error)

import uvm_pkg::*;
`include "uvm_macros.svh"


module top;
  initial begin
    run_test();
  end

endmodule

class parent;
  int val;
endclass : parent

class child1 extends parent;
endclass : child1

class child2 extends parent;
endclass : child2



class test extends uvm_component;

  child1 c1;
  child2 c2;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    c1 = new();
    c2 = new();
  endfunction

  function void build();
    c1.val = 1;
    
    uvm_config_db#(child1)::set(null,"top.test", "child", c1);
    void'(uvm_config_db#(child1)::get(null,"top.test", "child", c2));  // UVM TEST COMPILE-TIME FAILURE UVM TEST RUN-TIME FAILURE
  endfunction

  function void report();
    uvm_report_server rs = get_report_server();
    if(rs.get_severity_count(UVM_ERROR) > 0)
      $display("** UVM TEST FAIL **");
    else
      $display("** UVM TEST PASSED **");
  endfunction

endclass
