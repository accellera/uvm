//---------------------------------------------------------------------- 
//   Copyright 2010-2014 Synopsys, Inc. 
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

import uvm_pkg::*;
`include "uvm_macros.svh"

class x_module extends uvm_component;
  
  `uvm_component_utils_begin(x_module)
  `uvm_component_utils_end
    
    function new (string name, uvm_component parent);
      super.new(name,parent);
    endfunction

endclass

class test extends uvm_test;
  x_module x;
  
  `uvm_component_utils_begin(test)
    `uvm_field_object(x, UVM_DEFAULT)
  `uvm_component_utils_end
    
    function new (string name, uvm_component parent);
      super.new(name,parent);
    endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
endclass


class x_class extends uvm_object;
  `uvm_object_utils(x_class)

  function new (string name="x_class");
    super.new(name);
  endfunction
endclass

module test_check_module;
  initial begin
    x_class x;
    x  = new("x");
    uvm_config_db#(uvm_object)::set(null, "uvm_test_top","x", x);
    run_test();
  end
endmodule
