//---------------------------------------------------------------------- 
//   Copyright 2011 Cadence Design Systems, Inc.
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

// -*-focus: This test check the accesibility of the resource database (currently, from a module only)

import uvm_pkg::*;
`include "uvm_macros.svh"

module top();
  int num1 = 1;
  int num2 = 3;

  class test extends uvm_component;
    `uvm_component_utils(test)
  
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    function void report();
      uvm_resource_pool rp = uvm_resource_pool::get();
      uvm_report_server rs = get_report_server();
      if(rs.get_severity_count(UVM_ERROR) > 0)
        $display("** UVM TEST FAIL **");
      else
        $display("** UVM TEST PASSED **");
    endfunction
  endclass

  initial begin
    uvm_config_db#(int)::set(null, "", "val", num1);
    if (!uvm_config_db#(int)::get(null, "", "val", num2)) begin
      `uvm_error("TEST", "can't access resource db from a module");
    end else begin if (num2 != num1) begin
      `uvm_error("TEST", "resource db returned a wrong value");
    end end
  end

  initial run_test();

endmodule


