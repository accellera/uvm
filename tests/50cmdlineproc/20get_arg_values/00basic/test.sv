program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_test;

   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void start_of_simulation();
     uvm_cmdline_processor clp;
     string arg_values[$];
     string tool, version;
     bit add_em = 0;
     clp = uvm_cmdline_processor::get_inst();
     tool = clp.get_tool_name();
     version = clp.get_tool_version();
     $display("Tool: %s, Version : %s", tool, version);
     void'(clp.get_arg_values("+foo=", arg_values));
     $display("arg_values size : %0d", arg_values.size());
     for(int i = 0; i < arg_values.size(); i++) begin
       $display("arg_values[%0d]: %0s", i, arg_values[i]);
     end
     $display("Doing +foo match size check");
     if(arg_values.size() != 3)
       pass_the_test = pass_the_test & 0;
     else
       $display("  Correct number of +foo= values found");
     void'(clp.get_arg_values("+bar=", arg_values));
     $display("arg_values size : %0d", arg_values.size());
     for(int i = 0; i < arg_values.size(); i++) begin
       $display("arg_values[%0d]: %0s", i, arg_values[i]);
     end
     $display("Doing /bar/ match size check");
     if(arg_values.size() != 2)
       pass_the_test = pass_the_test & 0;
     else
       $display("  Correct number of /bar/ arguments found");
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
