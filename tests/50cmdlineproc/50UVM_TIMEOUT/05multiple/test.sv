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

bit pass_the_test = 1;

class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1000;
      phase.drop_objection(this);
   endtask

endclass


initial run_test();

final
  begin
    uvm_report_server rs;
    rs = uvm_report_server::get_server();
    if(rs.get_id_count("MULTTIMOUT") != 1)
      pass_the_test = pass_the_test & 0;
    if ($time == 25 && pass_the_test == 1) begin
      $write("UVM TEST EXPECT 1 UVM_ERROR\n");
      $write("** UVM TEST PASSED **\n");
    end
  end

endprogram
