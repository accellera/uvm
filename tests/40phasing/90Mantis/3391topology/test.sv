//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc.
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

program p;

import uvm_pkg::*;
`include "uvm_macros.svh"

class leaf extends uvm_component;

   `uvm_component_utils(leaf)

   function new(string name = "leaf", uvm_component parent = null);
      super.new(name, parent);
   endfunction
endclass


class branch extends uvm_component;

   leaf l1;
   leaf l2;
   
   `uvm_component_utils(branch)

   function new(string name = "branch", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      l1 = leaf::type_id::create("l1", this);
      l2 = leaf::type_id::create("l2", this);
   endfunction
endclass


class trunk extends uvm_component;

   branch b1;
   branch b2;
   
   `uvm_component_utils(trunk)

   function new(string name = "trunk", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      b1 = branch::type_id::create("b1", this);
      b2 = branch::type_id::create("b2", this);
   endfunction
endclass

class test extends uvm_test;

   branch b1;
   branch b2;
   
   `uvm_component_utils(test)

   function new(string name = "test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      b1 = branch::type_id::create("b1", this);
      b2 = branch::type_id::create("b2", this);
   endfunction
endclass

initial
begin
   trunk t1;
   uvm_root top;

   t1 = new("t1");
   top = uvm_root::get();
   top.enable_print_topology = 1;

   run_test();
end

endprogram
