program top;

import uvm_pkg::*;

class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run();
      uvm_top.stop_request();
   endtask

   virtual function void report();
      $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
