module top_tb;
   `include "uvm_macros.svh"
   import uvm_pkg::*;
   import mem_pkg::*;
   `include "mem_tests.sv"

   initial begin
      run_test();
   end
endmodule // top_tb
