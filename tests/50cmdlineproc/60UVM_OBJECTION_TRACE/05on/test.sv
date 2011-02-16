program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_test;

   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
     phase.raise_objection(this);
     #100 phase.raise_objection(this);
     #200 phase.drop_objection(this);
     phase.drop_objection(this);
   endtask

   virtual function void report();
     uvm_report_server rs = uvm_report_server::get_server();
     if(rs.get_id_count("OBJTN_TRC") == 10)
       $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial run_test();

endprogram
