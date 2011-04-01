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

// -*- focus : test uvm_config_db object handling with same names but different types

import uvm_pkg::*;
`include "uvm_macros.svh"


module top;

  initial begin
    run_test();
  end

endmodule

	class parent;
endclass : parent

class child1 extends parent;
endclass : child1

class child2 extends parent;
endclass : child2

class test extends uvm_component;

  child1 c1a;
  child1 c1b;
  child2 c2a;
  child2 c2b;
  parent p;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    c1a = new();
    c1b = new();
    c2a = new();
    c2b = new();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
 	  
    uvm_config_db#(child1)::set(null,"top.test", "child", c1a);
    uvm_config_db#(child2)::set(null,"top.test", "child", c2a);

    assert(uvm_config_db#(child1)::get(null,"top.test", "child", c1b)) else   `uvm_error("TEST", "no value in store");
    assert(c1b == c1a) else `uvm_error("TEST", "resource db did not return the correct value or did not return a value at all for type \"child1\" type");

    assert(uvm_config_db#(child2)::get(null,"top.test", "child", c2b)) else   `uvm_error("TEST", "no value in store");
    assert (c2b == c2a) else `uvm_error("TEST", "resource db did not return the correct value or did not return a value at all for type \"child2\" type");

    assert(!uvm_config_db#(parent)::get(null,"top.test", "child", p)) else   `uvm_error("TEST", "value in store");  
    
    phase.drop_objection(this);
    endtask

  function void report_phase(uvm_phase phase);
    uvm_report_server rs = get_report_server();
  	  super.report_phase(phase);
    if(rs.get_severity_count(UVM_ERROR) > 0)
      $display("** UVM TEST FAIL **");
    else
      $display("** UVM TEST PASSED **");
  endfunction

endclass
	
