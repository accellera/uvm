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

  class test extends uvm_component;

    uvm_report_server l_rs = uvm_report_server::get_server();

    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    function void report_phase(uvm_phase phase);

      // Produce some id counts
      `uvm_info("ID1", "Message", UVM_NONE)
      `uvm_info("ID2", "Message", UVM_NONE)
      `uvm_info("ID3", "Message", UVM_NONE)

      // A few warning to bump the warning count
      `uvm_warning("ID2", "Message")
      `uvm_warning("ID3", "Message")

      // Cheating to set the fatal count
      l_rs.set_severity_count(UVM_ERROR, 50);

      // Cheating to set the fatal count
      l_rs.set_severity_count(UVM_FATAL, 10);

      l_rs.set_max_quit_count(5);

      $display("GOLD-FILE-START");
      l_rs.print();
      $display("GOLD-FILE-END");

    endfunction : report_phase

  endclass : test

  initial run_test();

endmodule
