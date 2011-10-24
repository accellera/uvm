`include "uvm_macros.svh"
import uvm_pkg::*;

typedef byte unsigned uint8;

class D;
  rand uint8 x;
endclass

class test extends uvm_test;

  D d;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);

    process p;
    uint8 result;
    bit error;

    set_report_verbosity_level(UVM_DEBUG);

    p = process::self();
    p.srandom(100);
    d = new;
    void'(d.randomize());
    $display("Pass1 d.x: %h",d.x);
    result = d.x;


    p.srandom(100);
    d = new;
    void'(d.randomize());
    $display("Pass2 d.x: %h",d.x);
    if (d.x != result) begin
      `uvm_error("Bad Result", $sformatf("Expected d.x=%0d, but got %0d",result,d.x))
      error = 1;
    end


    p.srandom(100);
    `uvm_info("DEBUG_MSG", "This should not affect randomization", UVM_DEBUG )
    d = new;
    void'(d.randomize());
    $display("Pass3 d.x: %h",d.x);
    if (d.x != result) begin
      `uvm_error("Bad Result", $sformatf("Expected d.x=%0d, but got %0d",result,d.x))
      error = 1;
    end

    if (error)
      $display("** UVM TEST FAILED **");
    else
      $display("** UVM TEST PASSED **");

  endtask

endclass

module top;

   initial run_test();

endmodule
