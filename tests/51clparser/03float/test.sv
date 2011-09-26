import uvm_pkg::*;
`include "uvm_macros.svh"
import checker_pkg::*;

//----------------------------------------------------------------------
// test
//----------------------------------------------------------------------
class test extends uvm_component;

  `uvm_component_utils(test)

  local uvm_cmdline_processor cl;
  local string args[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    parse_cl();
  endfunction

  function void parse_cl();
    int unsigned i;
    string arg;
    uvm_cl_parser parser;

    parser = new();
    parser.parse();
  endfunction

  function void check();
    checker_float ckr = new();
    ckr.lookfor_and_match("a", 1.0);
    ckr.lookfor_and_match("b", -22.37);
    ckr.lookfor_and_match("c", 3.25e-9);
    ckr.lookfor_and_match("d", 865_423_911.001_543);
  endfunction

  function void report();
    uvm_report_server srvr = get_report_server();
    int errors = srvr.get_severity_count(UVM_ERROR);

    uvm_resource_db#(int)::dump();

    if(errors > 0)
      $display("*** UVM TEST FAILED ***");
    else
      $display("*** UVM TEST PASSED ***");
  endfunction

endclass

module top;

  initial run_test("test");

endmodule
