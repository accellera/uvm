program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

bit pass_the_test = 1;

class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1000;
      phase.drop_objection(this);
   endtask

endclass


initial run_test();

final
  begin
    uvm_report_server rs;
    rs = uvm_report_server::get_server();
    if(rs.get_id_count("MULTTIMOUT") != 1)
      pass_the_test = pass_the_test & 0;
    if ($time == 25 && pass_the_test == 1) begin
      $write("UVM TEST EXPECT 1 UVM_ERROR\n");
      $write("** UVM TEST PASSED **\n");
    end
  end

endprogram
