module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class leaf extends uvm_component;
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    int value=0;

    `uvm_component_utils_begin(leaf)
       `uvm_field_int(value, UVM_DEFAULT)
    `uvm_component_utils_end

    function void report;
      if(value != 20) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  class test extends uvm_component;
    leaf l;
    function new(string name,uvm_component parent);
      super.new(name,parent);
    endfunction

    `uvm_component_utils(test)

    function void build;
      set_config_int("*","value",20);
      l = new("l",this);
      l.build();
    endfunction
  endclass
 
  initial begin
    run_test;
  end
endmodule
