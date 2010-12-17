program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_test;

   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual task run();
     #100 uvm_test_done.raise_objection(this);
     #200 uvm_test_done.drop_objection(this);
   endtask

   virtual function void report();
     uvm_report_server rs = uvm_report_server::get_server();
     // Need to include the implicit objections. So, there are
     // 6 raises but between 3 and 6 drops depending on cancelled
     // drops, and 2 all drops.
     if(rs.get_id_count("OBJTN_TRC") >= 12 && 
        rs.get_id_count("OBJTN_TRC") <= 14 )
       $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
