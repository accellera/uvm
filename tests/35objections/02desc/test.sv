// This test has components issuing a variety of objections.
// The top object traps all objections and stores their string
// descriptions in an aa for checking.

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  uvm_objection foo = new("foo");
  class lower_comp extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      fork 
        repeat(3) #40 uvm_test_done.raise_objection(this);
        repeat(3) #25 uvm_test_done.raise_objection(this,{"raise test done from ", get_full_name()});
        repeat(3) #25 foo.raise_objection(this,{"raise foo from ", get_full_name()});
        repeat(3) #70 uvm_test_done.drop_objection(this,{"drop test done from ", get_full_name()});
        repeat(3) #70 foo.drop_objection(this,{"drop foo from ", get_full_name()});
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
        repeat(4) #25 uvm_test_done.raise_objection(this,{"raise test done from ", get_full_name()});
        repeat(2) #25 foo.raise_objection(this,{"raise foo from ", get_full_name()});
        repeat(4) #70 uvm_test_done.drop_objection(this,{"drop test done from ", get_full_name()});
        repeat(2) #70 foo.drop_objection(this,{"drop foo from ", get_full_name()});
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
    top_comp tc;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      tc = new("tc", this);
    endfunction

    virtual function void raised (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
      raised_counter[description] += count;
    endfunction
    virtual function void dropped (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
      dropped_counter[description] += count;
    endfunction
    virtual task all_dropped (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
      all_dropped_counter[description] += count;
    endtask

    function void report();
      $display("Total objections types raised/dropped: %0d", raised_counter.num()+dropped_counter.num());
      foreach(raised_counter[idx]) $display("Raised: %s : %0d", idx, raised_counter[idx]);
      foreach(dropped_counter[idx]) $display("Dropped: %s : %0d", idx, dropped_counter[idx]);
      foreach(all_dropped_counter[idx]) $display("All dropped: %s : %0d", idx, all_dropped_counter[idx]);

      if(raised_counter[""] != 3) begin
        $display("** UVM TEST FAILED 2**");
      end
      if(raised_counter["raise foo from uvm_test_top.tc.mc"] != 2) begin
        $display("** UVM TEST FAILED 3**");
      end
      if(raised_counter["raise foo from uvm_test_top.tc.mc.lc"] != 3) begin
        $display("** UVM TEST FAILED 4**");
      end
      if(raised_counter["raise test done from uvm_test_top.tc.mc"] != 4) begin
        $display("** UVM TEST FAILED **");
      end
      if(raised_counter["raise test done from uvm_test_top.tc.mc.lc"] != 3) begin
        $display("** UVM TEST FAILED 5**");
      end
      if(dropped_counter[""] != 3) begin
        $display("** UVM TEST FAILED 6**");
      end
      if(dropped_counter["drop foo from uvm_test_top.tc.mc"] != 2) begin
        $display("** UVM TEST FAILED 7**");
      end
      if(dropped_counter["drop foo from uvm_test_top.tc.mc.lc"] != 3) begin
        $display("** UVM TEST FAILED 8**");
      end
      if(dropped_counter["drop test done from uvm_test_top.tc.mc"] != 4) begin
        $display("** UVM TEST FAILED 9**");
      end
      if(dropped_counter["drop test done from uvm_test_top.tc.mc.lc"] != 3) begin
        $display("** UVM TEST FAILED 10**");
      end
      if(all_dropped_counter["drop foo from uvm_test_top.tc.mc.lc"] != 1) begin
        $display("** UVM TEST FAILED 11**");
      end
      if(all_dropped_counter["drop test done from uvm_test_top.tc.mc"] != 1) begin
        $display("** UVM TEST FAILED 12**");
      end

      $display("** UVM TEST PASSED **");
    endfunction

  endclass

  initial run_test("test");

endmodule
