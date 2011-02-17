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

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   task run();
     for (int i = 0; i < 20; i++) begin
       #100;
       `uvm_error("TESTERR", "An error.")
     end
   endtask

endclass


initial
  begin
     run_test();
  end

final
  begin
    if ($time == 300)
      $write("UVM TEST EXPECT 3 UVM_ERROR\n");
      $write("** UVM TEST PASSED **\n");
  end

endprogram
