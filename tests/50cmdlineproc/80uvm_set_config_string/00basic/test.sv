program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_test;

   string my_string;
   bit pass_the_test = 1;

   `uvm_component_utils_begin(test)
     `uvm_field_string(my_string, UVM_ALL_ON)
   `uvm_component_utils_end

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual task run();
      uvm_top.stop_request();
   endtask

   virtual function void check();
     if (my_string != "FOO")
         pass_the_test = pass_the_test & 0;
       else
         $display("  my_string is: %s", my_string);
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
