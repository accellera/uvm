//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

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
