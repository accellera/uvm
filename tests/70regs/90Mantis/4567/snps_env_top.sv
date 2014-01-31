// -------------------------------------------------------------
//    Copyright 2013 Synopsys, Inc.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under t,he License.
// -------------------------------------------------------------
// //
// Template for Top module
//
`include "dut.v"

`ifndef SNPS_ENV_TOP__SV
`define SNPS_ENV_TOP__SV

module snps_env_top;

   logic clk;
   logic rst;

   // Clock Generation
   parameter sim_cycle = 10;
   
   // Reset Delay Parameter
   parameter rst_delay = 50;

   always 
      begin
          #(sim_cycle/2) clk = ~clk;
      end
   dut_if drv_if(clk,rst);

   prg test(); 
   
 dut dut(drv_if.wdata, drv_if.rdata, drv_if.addr, drv_if.direction, drv_if.enable, clk, rst);
 
   //Driver reset depending on rst_delay
   initial begin
     static uvm_pkg::uvm_coreservice_t cs_ = uvm_pkg::uvm_coreservice_t::get();

         clk = 0;
         rst = 0;
      #1 rst = 1;
         repeat (rst_delay) @(clk);
         rst = 1'b0;
         @(clk);
   repeat(1000) begin
   @(clk);
   end
	 begin
      uvm_pkg::uvm_report_server svr;
      svr = cs_.get_report_server();

      svr.report_summarize();

      if (svr.get_severity_count(uvm_pkg::UVM_FATAL) == 0 &&
          svr.get_severity_count(uvm_pkg::UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
	 $finish;
end
endmodule: snps_env_top

`endif // SNPS_ENV_TOP__SV
