program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

bit pass_the_test = 1;

uvm_report_server rs = uvm_report_server::get_server();

class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void start_of_simulation();
     rs.set_max_quit_count(10);
   endfunction

   task run();
     for (int i = 0; i < 20; i++) begin
       #100;
       `uvm_error("TESTERR", "An error.")
     end
   endtask

endclass


initial
  begin
     run_test();
  end

final
  begin
    if ($time == 1000 && pass_the_test == 1) begin
      $write("UVM TEST EXPECT 10 UVM_ERROR\n");
      $write("** UVM TEST PASSED **\n");
    end
  end

endprogram
