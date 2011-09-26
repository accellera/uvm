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
    checker_logic32 ckr = new();
    ckr.lookfor_and_match("a", 32'hfx);
    ckr.lookfor_and_match("b", 9'oxzx);
    ckr.lookfor_and_match("c", 32'hd_x_e_x_a_x_d_z);
    ckr.lookfor_and_match("d", 8'b10x0x11x);
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
