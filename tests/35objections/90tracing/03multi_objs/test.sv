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

// This test has components issuing a variety of objections.
// The top object traps all objections and stores their string
// descriptions in an aa for checking.

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class my_catcher extends uvm_report_catcher;
     int id_cnt[string];
     int msg_cnt[string];
     int client_cnt[uvm_report_object];
     virtual function action_e catch();
        if(get_id()!="OBJTN_TRC") return THROW;
        if(!id_cnt.exists(get_id())) id_cnt[get_id()] = 0;
        id_cnt[get_id()]++;

        if(!msg_cnt.exists(get_message())) msg_cnt[get_message()] = 0;
        msg_cnt[get_message()]++;

        if(!client_cnt.exists(get_client())) client_cnt[get_client()] = 0;
        client_cnt[get_client()]++;
        return CAUGHT;
     endfunction
  endclass

  class lower_comp extends uvm_component;
    uvm_objection from_bottom = new("from_bottom");
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      uvm_test_done.raise_objection(this);
      fork 
        repeat(3) #40 from_bottom.raise_objection(this);
        repeat(3) #50 from_bottom.drop_objection(this);
      join
      uvm_test_done.drop_objection(this);
    endtask
  endclass
  class middle_comp extends uvm_component;
    uvm_objection from_middle = new("from_middle");
    lower_comp lc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      lc = new("lc", this);
    endfunction
    task run;
      uvm_test_done.raise_objection(this);
      fork 
        repeat(3) #40 from_middle.raise_objection(this);
        repeat(3) #50 from_middle.drop_objection(this);
      join
      uvm_test_done.drop_objection(this);
    endtask
  endclass
  class top_comp extends uvm_component;
    uvm_objection from_top = new("from_top");
    middle_comp mc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc = new("mc", this);
    endfunction
    task run;
      uvm_test_done.raise_objection(this);
      fork 
        repeat(3) #40 from_top.raise_objection(this);
        repeat(3) #50 from_top.drop_objection(this);
      join
      uvm_test_done.drop_objection(this);
    endtask
  endclass
  class test extends uvm_component;
    int raised_counter[string];
    int dropped_counter[string];
    int all_dropped_counter[string];
    my_catcher ctchr = new;

    top_comp tc;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      tc = new("tc", this);
      uvm_report_cb::add(null,ctchr);
      void'(uvm_test_done.trace_mode(1));
      void'(tc.mc.lc.from_bottom.trace_mode(1));
      //don't trace the middle objections
      void'(tc.from_top.trace_mode(1));
    endfunction

    function void report();
      int msg_cnt=0, cli_cnt=0;
      uvm_report_object obj;

      foreach(ctchr.id_cnt[idx]) begin
        $display("ID: %0s : %0d", idx, ctchr.id_cnt[idx]);
      end
      foreach(ctchr.msg_cnt[idx]) begin
        $display("MSG: %0s : %0d", idx, ctchr.msg_cnt[idx]);
        msg_cnt += ctchr.msg_cnt[idx];
      end
      foreach(ctchr.client_cnt[idx]) begin
        uvm_report_object obj = idx;
        $display("OBJ: %0s : %0d", obj.get_full_name(), ctchr.client_cnt[idx]);
        cli_cnt += ctchr.client_cnt[idx];
      end
      if(ctchr.id_cnt["OBJTN_TRC"] != 101) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(msg_cnt != 101 || cli_cnt != 101) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      //pick an arbitrary message to look at
      obj=uvm_test_done;
      if(ctchr.client_cnt[obj] != 29) 
      begin
        $display("** UVM TEST FAILED **");
        return;
      end
      obj=tc.mc.lc.from_bottom;
      if(ctchr.client_cnt[obj] != 45) 
      begin
        $display("** UVM TEST FAILED **");
        return;
      end
      obj=tc.mc.from_middle;
      if(ctchr.client_cnt.exists(obj))
      begin
        $display("** UVM TEST FAILED **");
        return;
      end
      obj=tc.from_top;
      if(ctchr.client_cnt[obj] != 27) 
      begin
        $display("** UVM TEST FAILED **");
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction

  endclass

  initial run_test("test");

endmodule
