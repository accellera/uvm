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

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class env extends uvm_component;
    `uvm_component_utils(env)
    `uvm_new_func
  endclass : env

  class test extends uvm_component;
    env myenv;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      myenv = new("myenv", this);
    endfunction

    function void build_phase(uvm_phase phase);
      myenv.set_report_id_verbosity("ID1", UVM_LOW);
      set_report_id_verbosity_hier("ID2", UVM_MEDIUM);
      set_report_id_verbosity("ID3", UVM_HIGH);

      myenv.set_report_severity_action(UVM_WARNING, UVM_CALL_HOOK|UVM_DISPLAY|UVM_COUNT);

      set_report_id_action_hier("ACT_ID", UVM_DISPLAY|UVM_LOG|UVM_COUNT);
      set_report_id_action("ACT_ID2", UVM_DISPLAY);

      set_report_severity_id_action(UVM_INFO, "ID1", UVM_DISPLAY|UVM_COUNT);

      set_report_severity_override(UVM_ERROR,UVM_FATAL);

      set_report_severity_id_verbosity_hier(UVM_WARNING, "WARN1", UVM_INFO);

      set_report_default_file(1);

      set_report_max_quit_count(5);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
      $display("START OF GOLD FILE");
      dump_report_state();
      $display("END OF GOLD FILE");
    endtask : run_phase
  endclass : test

  initial run_test();

endmodule
