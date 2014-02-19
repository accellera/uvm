//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc.
//   All Rights Reserved Worldwide 
// 
//   Licensed under the Apache License, Version 2.0 (the 
//   "License"); you may not use this file except in 
//   compliance with the License.  You may obtain a copy of 
//   the License at 
// 
//       http://www.apache.org/licenses/LICENSE-2.0 
// 
//   Unless required by applicable law or agreed to in 
//   writing, software distributed under the License is 
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
//   CONDITIONS OF ANY KIND, either express or implied.  See 
//   the License for the specific language governing 
//   permissions and limitations under the License. 
//----------------------------------------------------------------------


`include "uvm_macros.svh"
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


initial begin
   static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

   uvm_report_server svr;

   static tb_env env = new("env");
   svr = cs_.get_report_server();
   svr.set_max_quit_count(10);

   uvm_config_db#(apb_vif)::set(env, "apb", "vif", $root.tb_top.apb0);
   uvm_reg::include_coverage("*", UVM_CVR_ALL);
   run_test();
   end

endmodule

