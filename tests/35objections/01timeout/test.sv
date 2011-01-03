// This test verifies that the configured setting of
// the global timeout is used by the run phase.

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class lower_comp extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    function void start_of_simulation();
      // This will be the last setting, so it should be the
      // one used.
      `uvm_info("SETTO","Setting timeout to 33ms", UVM_NONE)
      uvm_top.set_config_int("", "timeout", 33ms);
    endfunction
  endclass
  class middle_comp extends uvm_component;
    lower_comp lc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      lc = new("lc", this);
    endfunction
    function void end_of_elaboration();
      `uvm_info("SETTO","Setting timeout to 88ns", UVM_NONE)
      uvm_top.set_config_int("", "timeout", 88ns);
    endfunction
  endclass
  class top_comp extends uvm_component;
    middle_comp mc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc = new("mc", this);
    endfunction
    function void build();
      `uvm_info("SETTO","Setting timeout to 7s", UVM_NONE)
      uvm_top.set_config_int("", "timeout", 7s);
    endfunction
  endclass
  class test extends uvm_component;
    top_comp tc;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      tc = new("tc", this);
      uvm_top.set_report_id_action_hier("PH_TIMEOUT", UVM_NO_ACTION);
    endfunction
    function void report();
      if($time == 33ms) $display("** UVM TEST PASSED **");
      else $display("** UVM TEST FAILED **");
    endfunction
  endclass

  initial run_test("test");

  initial begin
    
    //safety check
    #34ms  $display("** UVM TEST FAILED **");
  end
endmodule
