program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

// This test needs lots of messaging and checks for correct number.

class test extends uvm_test;

   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("A", "A id message", UVM_LOW)
      `uvm_info("B", "B id message", UVM_HIGH)
      #1000;
      `uvm_info("A", "A id message", UVM_MEDIUM)
      `uvm_info("B", "B id message", UVM_LOW)
      #1000;
      phase.drop_objection(this);
   endtask

   virtual function void report();
     uvm_report_server rs = uvm_report_server::get_server();
     `uvm_info("A", "A id message", UVM_LOW)
     `uvm_info("B", "B id message", UVM_LOW)
     if((rs.get_id_count("A") == 2) && (rs.get_id_count("B") == 1))
       $write("** UVM TEST PASSED **\n");
   endfunction

endclass


initial run_test();

endprogram
