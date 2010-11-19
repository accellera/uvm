program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

bit pass_the_test = 1;

class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void start_of_simulation();
     set_global_timeout(500);
   endfunction

   task run();
      #1000;
      uvm_top.stop_request();
   endtask

endclass


initial
  begin
     run_test();
  end

uvm_report_server rs = uvm_report_server::get_server();

final
  begin
    if(rs.get_id_count("NOTIMOUTOVR") != 1)
      pass_the_test = pass_the_test & 0;
    if ($time == 100 && pass_the_test == 1) begin
      $write("UVM TEST EXPECT 1 UVM_ERROR\n");
      $write("** UVM TEST PASSED **\n");
    end
  end

endprogram
