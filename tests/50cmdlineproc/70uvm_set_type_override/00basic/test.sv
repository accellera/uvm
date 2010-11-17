program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class base_type extends uvm_object;
  `uvm_object_utils(base_type)
endclass

class derived_type extends base_type;
  `uvm_object_utils(derived_type)
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
