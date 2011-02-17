//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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

// This test has components issuing a variety of objections.
// The top object traps all objections and stores their string
// descriptions in an aa for checking.

// Testbench structure
//     test
//      |
//      -- tc (top_comp)
//       |
//       -- mc (middle_comp)
//       |
//       -- lc (lower_comp)
//

// Objections:
//   lower_comp
//     6 uvm_test_done raise
//     6 uvm_test_done drop
//     1 uvm_test_done all_dropped
//     3 foo raise
//     3 foo drop
//     1 foo all_dropped
//     -----------------
//     9 raised
//     9 dropped
//     2 all_dropped
//   middle_comp
//     4 uvm_test_done raise 
//     4 uvm_test_done drop
//     1 uvm_test_done all_dropped
//     2 foo raise
//     2 foo drop
//     1 foo all_dropped
//     ---------------------
//     6 + 9 (15) raised
//     6 + 9 (15) dropped
//     2 all_dropped
//   top_comp
//     (all from below)
//     15 raised
//     15 dropped
//      2 all_dropped
//   test
//     (all from below)
//     15 raised
//     15 dropped
//      2 all_dropped
//   uvm_top
//     15 raised
//     15 dropped
//      2 all_dropped
//
// Total objections seen: 
//    69 raised
//    69 dropped
//    10 all_dropped
//   ---------------
//   148
//     
// extra raise/drop for lower and middle comp adds 10 (lower) + 8 (middle) extra trace messages

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class my_catcher extends uvm_report_catcher;
     static int msg_cnt = 0;
     int id_cnt[string];
     int client_cnt[uvm_report_object];
     virtual function action_e catch();
        if(get_id()!="OBJTN_TRC") return THROW;
        if(!id_cnt.exists(get_id())) id_cnt[get_id()] = 0;
        id_cnt[get_id()]++;

        if(!client_cnt.exists(get_client())) client_cnt[get_client()] = 0;
        client_cnt[get_client()]++;
        issue();
        msg_cnt++;
        return CAUGHT;
     endfunction
  endclass

  uvm_objection foo = new("foo");

  class lower_comp extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork 
        repeat(3) #40 phase.raise_objection(this);
        repeat(3) #25 phase.raise_objection(this,get_full_name());
        repeat(3) #25 foo.raise_objection(this);
        repeat(3) #70 phase.drop_objection(this,get_full_name());
        repeat(3) #70 foo.drop_objection(this);
        repeat(3) #90 phase.drop_objection(this);
      join
      phase.drop_objection(this);
    endtask
  endclass
  class middle_comp extends uvm_component;
    lower_comp lc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      lc = new("lc", this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork 
        repeat(4) #25 phase.raise_objection(this);
        repeat(2) #25 foo.raise_objection(this);
        repeat(4) #70 phase.drop_objection(this);
        repeat(2) #70 foo.drop_objection(this);
      join
      phase.drop_objection(this);
    endtask
  endclass
  class top_comp extends uvm_component;
    middle_comp mc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc = new("mc", this);
    endfunction
  endclass
  class test extends uvm_component;
    my_catcher ctchr = new;

    top_comp tc;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      tc = new("tc", this);
      uvm_report_cb::add(null,ctchr);
    endfunction

    function void report();
      int cli_cnt=0;

      foreach(ctchr.id_cnt[idx]) begin
        $display("ID: %0s : %0d", idx, ctchr.id_cnt[idx]);
      end
      foreach(ctchr.client_cnt[idx]) begin
        uvm_report_object obj = idx;
        $display("OBJ: %0s : %0d", obj.get_full_name(), ctchr.client_cnt[idx]);
        cli_cnt += ctchr.client_cnt[idx];
      end

      // Note that there are 35 objections from run for 15 implicit raise/drop
      // plus 5 alldrop messages.
      if(ctchr.id_cnt["OBJTN_TRC"] != 166) begin
        $display("** UVM TEST FAILED ** Saw %0d OBJTN_TRC messages instead of 166", ctchr.id_cnt["OBJTN_TRC"]);
        //return;
      end
      if(my_catcher::msg_cnt != 166) begin
        $display("** UVM TEST FAILED ** Saw %0d messages instead of 166", my_catcher::msg_cnt);
        //return;
      end
      if(cli_cnt != 166) begin
        $display("** UVM TEST FAILED ** Saw %0d clients instead of 166", cli_cnt);
        //return;
      end

      $display("** UVM TEST PASSED **");
    endfunction

  endclass

  initial run_test("test");

endmodule
