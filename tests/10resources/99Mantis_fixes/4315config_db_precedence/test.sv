//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
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

// This test verifies that a warning is issued if a null object is 
// passed to set_config_object.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 1;

class child_comp extends uvm_component;

   `uvm_component_utils(child_comp)
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   virtual function void build_phase(uvm_phase phase);
     bit fail_if_set;
     uvm_config_db#(bit)::set(this, "", "fail_if_set", 1);
     uvm_config_db#(bit)::get(this, "", "fail_if_set", fail_if_set);
     if (fail_if_set)
       $display("*** UVM TEST FAILED ***");
     else
       $display("*** UVM TEST PASSED ***");
   endfunction : build_phase
   
endclass : child_comp

class parent_comp extends uvm_component;
   child_comp c;
   
   `uvm_component_utils(parent_comp)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   virtual function void build_phase(uvm_phase phase);
     c = child_comp::type_id::create("c", this);
     uvm_config_db#(bit)::set(this, "*", "fail_if_set", 0);
     uvm_config_db#(bit)::set(this, "*", "fail_if_set", 0);
     uvm_config_db#(bit)::set(this, "*", "fail_if_set", 0);
   endfunction : build_phase
      
endclass : parent_comp
      
   
class test extends uvm_component;
   parent_comp p;
     
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction
   `uvm_component_utils(test)
   function void build_phase(uvm_phase phase);
      p = parent_comp::type_id::create("p", this);
   endfunction : build_phase
endclass : test
   
  initial run_test();
endmodule
