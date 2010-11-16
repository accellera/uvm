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
      void'(uvm_test_done.trace_mode(1));
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
      if(ctchr.id_cnt["OBJTN_TRC"] != 65) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(msg_cnt != 65 || cli_cnt != 65) begin
        $display("** UVM TEST FAILED **");
        return;
      end
      //pick an arbitrary message to look at
      obj=uvm_test_done;
      if(ctchr.client_cnt[obj] != 65) 
      begin
        $display("** UVM TEST FAILED **");
        return;
      end
      if(ctchr.client_cnt.exists(foo)) 
      begin
        $display("** UVM TEST FAILED **");
        return;
      end
      $display("** UVM TEST PASSED **");
    endfunction

  endclass

  initial run_test("test");

endmodule
