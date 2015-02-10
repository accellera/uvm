`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

class vip1_env extends uvm_env;
  
  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  `uvm_component_utils(vip1_env)

endclass

class test1 extends uvm_test;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction

  `uvm_component_utils(test1)

  function void build_phase(uvm_phase phase);
    uvm_factory factory;
    automatic uvm_coreservice_t cs;

    super.build_phase(phase);

    cs = uvm_coreservice_t::get();
    factory = cs.get_factory();

    if (factory.is_type_name_registered("vip1_env") == 1)
        $display("Testing function uvm_factory::is_type_name_registered(): VIP1 is a part of the testbench");
    else
        $display("Testing function uvm_factory::is_type_name_registered(): VIP1 is not a part of the testbench");

    if (factory.is_type_name_registered("vip2_env") == 1)
        $display("Testing function uvm_factory::is_type_name_registered(): VIP2 is a part of the testbench");
    else
        $display("Testing function uvm_factory::is_type_name_registered(): VIP2 is not a part of the testbench");
  endfunction

endclass

module dut;
  initial run_test("test1");
endmodule
