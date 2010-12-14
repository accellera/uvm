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
     string verb_matches[$];
     string tool, version;
     bit add_em = 0;
     clp = uvm_cmdline_processor::get_inst();
     tool = clp.get_tool_name();
     version = clp.get_tool_version();
     $display("Tool: %s, Version : %s", tool, version);
     void'(clp.get_arg_matches("+UVM_VERBOSITY=", verb_matches));
     $display("verb_matches size : %0d", verb_matches.size());
     for(int i = 0; i < verb_matches.size(); i++) begin
       $display("verb_matches[%0d]: %0s", i, verb_matches[i]);
     end
     $display("Doing +UVM_VERBOSITY= match size check");
     if(verb_matches.size() != 3)
       pass_the_test = pass_the_test & 0;
     else
       $display("  Correct number of +UVM_VERBOSITY= values found");
   endfunction

   virtual task run();
      uvm_top.stop_request();
   endtask

   virtual function void report();
     uvm_report_server rs = uvm_report_server::get_server();
     if(rs.get_id_count("MULTVERB") != 1)
       pass_the_test = pass_the_test & 0;
     if(pass_the_test)
       $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
