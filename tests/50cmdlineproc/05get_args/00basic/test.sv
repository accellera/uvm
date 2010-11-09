program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_test;

   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void start_of_simulation();
     uvm_cmdline_processor clp;
     string raw_args[$];
     string tool, version;
     bit add_em = 0;
     clp = uvm_cmdline_processor::get_inst();
     tool = clp.get_tool_name();
     version = clp.get_tool_version();
     $display("Tool: %s, Version : %s", tool, version);
     clp.get_args(raw_args);
     $display("raw_args size : %0d", raw_args.size());
     for(int i = 0; i < raw_args.size(); i++) begin
       $display("raw_args[%0d]: %0s", i, raw_args[i]);
     end
     case (tool)
       "Chronologic Simulation VCS Release " : begin
         $display("Doing VCS checks");
         if(raw_args.size() != 15)
           pass_the_test = pass_the_test & 0;
         else
           $display("  Correct number of arguments found");
       end
       "ncsim" : begin
         $display("Doing IUS checks");
         if(raw_args.size() != 22)
           pass_the_test = pass_the_test & 0;
         else
           $display("  Correct number of arguments found");
       end
       default : begin
         // Need Questa checks here -- currently just fail.
         pass_the_test = pass_the_test & 0;
       end
     endcase
   endfunction

   virtual task run();
      uvm_top.stop_request();
   endtask

   virtual function void report();
     if(pass_the_test)
       $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
