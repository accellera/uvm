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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class base_type extends uvm_object;
  `uvm_object_utils(base_type)

  function new(string name="base_type");
     super.new(name);
  endfunction

endclass

class derived_type extends base_type;
  `uvm_object_utils(derived_type)

  function new(string name="derived_type");
     super.new(name);
  endfunction

endclass

class my_component extends uvm_component;
   base_type b0;
   `uvm_component_utils(my_component)
   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction
   function void build();
     b0 = base_type::type_id::create("b0", this);
   endfunction
endclass

class test extends uvm_test;

   my_component c0, c1;
   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void build();
     c0 = my_component::type_id::create("c0", this);
     c1 = my_component::type_id::create("c1", this);
   endfunction

   virtual task run();
      uvm_top.stop_request();
   endtask

   virtual function void check();
     if (c0.b0.get_type_name() != "derived_type")
         pass_the_test = pass_the_test & 0;
       else
         $display("  c0.b0 is of type: %s", c0.b0.get_type_name());
     if (c1.b0.get_type_name() != "derived_type")
         pass_the_test = pass_the_test & 0;
       else
         $display("  c1.b0 is of type: %s", c1.b0.get_type_name());
   endfunction

   virtual function void report();
     if(pass_the_test)
       $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
