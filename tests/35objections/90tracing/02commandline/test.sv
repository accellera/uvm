// This test has components issuing a variety of objections.
// The top object traps all objections and stores their string
// descriptions in an aa for checking.

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
    task run;
      fork 
        repeat(3) #40 uvm_test_done.raise_objection(this);
        repeat(3) #25 uvm_test_done.raise_objection(this,get_full_name());
        repeat(3) #25 foo.raise_objection(this);
        repeat(3) #70 uvm_test_done.drop_objection(this,get_full_name());
        repeat(3) #70 foo.drop_objection(this);
        repeat(3) #90 uvm_test_done.drop_objection(this);
      join
    endtask
  endclass
  class middle_comp extends uvm_component;
    lower_comp lc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      lc = new("lc", this);
    endfunction
    task run;
      fork 
        repeat(4) #25 uvm_test_done.raise_objection(this);
        repeat(2) #25 foo.raise_objection(this);
        repeat(4) #70 uvm_test_done.drop_objection(this);
        repeat(2) #70 foo.drop_objection(this);
      join
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
      // plus 5 alldrop messages. The implicit drops can potentially be canceled
      // so the total number of traces will be between 169 and 183.
      if(ctchr.id_cnt["OBJTN_TRC"] < 169 || ctchr.id_cnt["OBJTN_TRC"] > 183) begin
        $display("** UVM TEST FAILED ** Saw %0d OBJTN_TRC messages but expected between 169 and 183", ctchr.id_cnt["OBJTN_TRC"]);
      end
      if(my_catcher::msg_cnt < 169 || my_catcher::msg_cnt > 183) begin
        $display("** UVM TEST FAILED ** Saw %0d messages but expected between 169 and 183", my_catcher::msg_cnt);
      end
      if(cli_cnt < 169 || cli_cnt > 183) begin
        $display("** UVM TEST FAILED ** Saw %0d clients but expected between 169 and 183", cli_cnt);
      end

      $display("** UVM TEST PASSED **");
    endfunction

  endclass

  initial run_test("test");

endmodule
