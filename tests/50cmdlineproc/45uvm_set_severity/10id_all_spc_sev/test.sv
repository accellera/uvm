program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

// This test needs lots of messaging and checks for correct actions.

class test extends uvm_test;

   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_error("A", "A Error but downgrading to an Info!!!")
      `uvm_error("B", "B Error but downgrading to an Info!!!")
      `uvm_error("C", "C Error but downgrading to an Info!!!")
      `uvm_error("D", "D Error but downgrading to an Info!!!")
      #1000;
      phase.drop_objection(this);
   endtask

   virtual function void report();
     uvm_report_server rs = uvm_report_server::get_server();
     if((rs.get_id_count("A") == 1) && (rs.get_id_count("B") == 1) &&
       (rs.get_id_count("C") == 1) && (rs.get_id_count("D") == 1) &&
       (rs.get_severity_count(UVM_ERROR) == 0))
       $write("** UVM TEST PASSED **\n");
   endfunction

endclass


initial run_test();

endprogram
