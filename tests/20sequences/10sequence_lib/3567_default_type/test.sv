module test;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    class t1 extends uvm_sequence_library;
        `uvm_object_utils(t1)
        `uvm_sequence_library_utils(t1)
        function new(string name="");
            super.new(name);
            init_sequence_library();
        endfunction 
    endclass

class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void report();
      $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end
   
endmodule

