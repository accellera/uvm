module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class low extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction
    task run;
      $display("!!!!: %s", get_full_name());
    endtask
  endclass

  class test extends uvm_component;
    low low1;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      low1 = new("low1", this);
    endfunction
    task run;
      $display("!!!!: %s (%0s)", get_full_name(), get_type_name());
      $display("**** UVM TEST FAILED *****");
    endtask
  endclass

  class modtest extends uvm_component;
    low low1;
    `uvm_component_utils(modtest)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      low1 = new("low1", this);
    endfunction
    task run;
      $display("!!!!: %s (%0s)", get_full_name(), get_type_name());
      $display("**** UVM TEST PASSED *****");
    endtask
  endclass

  initial begin
    test::type_id::set_inst_override(modtest::type_id::get(),"uvm_test_top");
    run_test;
  end
endmodule
