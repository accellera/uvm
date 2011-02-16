program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

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


initial
  begin
     run_test();
  end

final
  begin
    if ($time == 20) begin
      $write("UVM TEST EXPECT 1 UVM_ERROR\n");
      $write("** UVM TEST PASSED **\n");
    end
  end

endprogram
