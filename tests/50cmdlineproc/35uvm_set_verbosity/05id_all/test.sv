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

   virtual function void messages(string phase);
     `uvm_info({phase,"_none"}, {"none message from ",phase}, UVM_NONE)
     `uvm_info({phase,"_low"}, {"low message from ",phase}, UVM_LOW)
     `uvm_info({phase,"_med"}, {"med message from ",phase}, UVM_MEDIUM)
     `uvm_info({phase,"_high"}, {"high message from ",phase}, UVM_HIGH)
     `uvm_info({phase,"_full"}, {"full message from ",phase}, UVM_FULL)
   endfunction

   virtual function void build();
     messages("build");
   endfunction

   virtual function void connect();
     messages("connect");
   endfunction

   virtual function void end_of_elaboration();
     messages("end_of_elaboration");
   endfunction

   virtual function void start_of_simulation();
     messages("start_of_simulation");
   endfunction

   virtual function void extract();
     messages("extract");
   endfunction

   virtual function void check();
     messages("check");
   endfunction

   virtual function void report();
     messages("report");
   endfunction

   virtual function void finalize();
     messages("finalize");
   endfunction

   virtual task run();
      #100;
      messages("run");
      #200;
      messages("run");
      #700;
      messages("run");
      uvm_top.stop_request();
   endtask

/*
   virtual function void report();
     uvm_report_server rs = uvm_report_server::get_server();
     if(rs.get_id_count("INVLCMDARGS") == 1)
       $write("** UVM TEST PASSED **\n");
   endfunction
*/
endclass


initial
  begin
     run_test();
  end

endprogram
