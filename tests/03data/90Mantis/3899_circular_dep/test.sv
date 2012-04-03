//---------------------------------------------------------------------- 
//   Copyright 2011 Cadence
//   Copyright 2012 Synopsys, Inc.
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

`include "uvm_macros.svh"
module test;

import uvm_pkg::*;

typedef enum { EA,EB} E_t;

class agent_config extends uvm_object;
   uvm_component parent_component;
     
   `uvm_object_utils_begin(agent_config)
    `uvm_field_object(parent_component, UVM_ALL_ON)   
   `uvm_object_utils_end   

      function new(string name = "agent_config");
      super.new(name);
   endfunction : new   
endclass

class my_class extends uvm_component;
    E_t tp;  
    agent_config parent_config;

  `uvm_component_utils_begin(my_class)
    `uvm_field_enum(E_t,tp,UVM_ALL_ON)      
    `uvm_field_object(parent_config, UVM_ALL_ON)
  `uvm_component_utils_end

  `uvm_new_func
endclass

class test extends uvm_test;  
   agent_config cfg;   

   `uvm_component_utils_begin(test) 
        `uvm_field_object(cfg,UVM_ALL_ON)
   `uvm_component_utils_end    
   my_class c;
        
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    c   = new("class_a",this);      
    cfg = new("cfg");  
    cfg.parent_component=this;
    set_config_int("class_a","tp",EB);        
    set_config_object("class_a","parent_config",cfg,0);
    endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    print();
    #50 $display("UVM TEST PASSED");
    phase.drop_objection(this);
  endtask
  `uvm_new_func
endclass

initial begin
        uvm_component::print_config_matches=1;
        uvm_status_container::print_matches=1;
 
  run_test("test");
end
endmodule
