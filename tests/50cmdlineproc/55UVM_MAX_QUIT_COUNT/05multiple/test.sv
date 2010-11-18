program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

bit pass_the_test = 1;

class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
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

uvm_report_server rs;

final
  begin
    rs = uvm_report_server::get_server();
    if(rs.get_id_count("MULTMAXQUIT") != 1)
      pass_the_test = pass_the_test & 0;
    if ($time == 500 && pass_the_test == 1) begin
      $write("UVM TEST EXPECT 5 UVM_ERROR\n");
      $write("** UVM TEST PASSED **\n");
    end
  end

endprogram
