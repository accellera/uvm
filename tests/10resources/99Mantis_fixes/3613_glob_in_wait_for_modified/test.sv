//----------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics Corporation
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
//----------------------------------------------------------------------

import uvm_pkg::*;
`include "uvm_macros.svh"

// This test verifies that a waiter wakes up if the resource it is
// waiting on is set via a glob expression. Note: some glob expressions
// are valid regular expr and can inadvertently match even though it
// was not first converted to a reg expr.

byte failed = 1;

class test extends uvm_component;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  int exp;
  task wait_for_c1_field1_via_wildcard();
      int act;
      `uvm_info("WildField1", "Waiting for c1.field1 to change",UVM_NONE)
      uvm_config_db#(uvm_bitstream_t)::wait_modified(null, "test.c1", "field1");
      void'(uvm_config_db#(uvm_bitstream_t)::get(null,"test.c1","field1",act));
      if(act != exp) begin
        failed = 1;
        $display("*** UVM TEST FAILED for wait_modified field1 set via wildcard, expected value %0d, got %0d", exp, act);
        return;
      end
      failed--;
      `uvm_info("WildField1", $sformatf("c1.field1 changed to %0d",act),UVM_NONE)
  endtask

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
      set_config_int("test.c1","field1",10);
      set_config_int("test.c2","field1",20);
    begin
      fork
        wait_for_c1_field1_via_wildcard();
      join_none
      #0;
      exp = 1234;
      $display("Setting c1.field1...");
      uvm_config_db#(uvm_bitstream_t)::set(null,"*.c*","field1",1234);
      wait fork;
    end
    phase.drop_objection(this);
  endtask

  function void report();
    if(failed) begin
       `uvm_error("FAILED", $sformatf("Did not get the expected number of wakeups"))
      $display("** UVM TEST FAILED **");
    end
    else
      $display("** UVM TEST PASSED **");

  endfunction

endclass

module top;
  initial
    run_test();
endmodule
