//
//------------------------------------------------------------------------------
//   Copyright 2011 Cadence Design Systems, Inc.
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

module top();

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class test extends uvm_component;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
      phase.phase_done.set_drain_time(this,100);

      phase.raise_objection(this);
      phase.drop_objection(this);

      phase.raise_objection(this);
      phase.drop_objection(this);
      `uvm_info("Done", "Finished run...", UVM_NONE)
    endtask
    `uvm_component_utils(test)

    function void report_phase(uvm_phase phase); 
      uvm_report_server server = uvm_report_server::get_server();
      if(server.get_id_count("OBJTN_ZERO") != 0) $display("*** UVM TEST FAILED ***");
      if(server.get_id_count("Done") != 1) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial begin
    run_test();
  end

endmodule

