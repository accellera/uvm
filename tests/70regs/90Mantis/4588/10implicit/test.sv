/*********************************************************************
 * SYNOPSYS CONFIDENTIAL                 			     *
 *                               				     *
 * This is an unpublished, proprietary work of Synopsys, Inc., and   *
 * is fully protected under copyright and trade secret laws. You may *
 * not view, use, disclose, copy, or distribute this file or any     *
 * information contained herein except pursuant to a valid written   *
 * license from Synopsys.                                            *
 ********************************************************************/


`include "regmodel.sv"
`include "tb_top.sv"
module tb;

import uvm_pkg::*;
import apb_pkg::*;

`include "tb_env.sv"
`include "run_test.sv"


class dut_reset_seq extends uvm_sequence;

   function new(string name = "dut_reset_seq");
      super.new(name);
   endfunction

   `uvm_object_utils(dut_reset_seq)
   
   virtual task body();
      tb_top.rst = 1;
      repeat (5) @(negedge tb_top.clk);
      tb_top.rst = 0;
   endtask
endclass


initial
begin
   uvm_report_server svr;

   static tb_env env = new("env");
   svr = _global_reporter.get_report_server();
   svr.set_max_quit_count(10);

   uvm_config_db#(apb_vif)::set(env, "apb", "vif", $root.tb_top.apb0);
   uvm_reg::include_coverage("*", UVM_CVR_ALL);
   run_test();
   end

endmodule

