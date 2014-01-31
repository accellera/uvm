//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2010-2011 Mentor Graphics Corporation
//    Copyright 2010-2011 Cadence Design Systems, Inc.
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


module dut();

   wire [7:0] w, w_nodrv;
   wire [3:0] w_vhdl_drv;

   reg [7:0] q = 'h0F;
   reg [7:0] d = 'hF0;
   ZERO z(w_vhdl_drv);

   assign w = q; //'hD4;

   always #100 q = d;
endmodule


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum { READ, DEPOSIT, FORCE, RELEASE } op_e;

task automatic op(op_e oper, string hdl, bit [7:0] wr_val=0, bit [7:0] exp_val, int lineno, time force_time=0);


  bit [7:0] rd_val = 0;

  if (oper == DEPOSIT) begin
   if (!uvm_hdl_deposit(hdl,wr_val))
      `uvm_error(hdl,"uvm_hdl_deposit returned FALSE")
  end
  else if (oper == FORCE) begin
   if (force_time == 0) begin
     if (!uvm_hdl_force(hdl,wr_val))
        `uvm_error(hdl,"uvm_hdl_force returned FALSE")
   end
   else begin
     uvm_hdl_force_time(hdl,wr_val,force_time);
   end
  end
  else if (oper == RELEASE) begin
   if (!uvm_hdl_release(hdl))
      `uvm_error(hdl,"uvm_hdl_release returned FALSE")
  end

  if (!uvm_hdl_read(hdl,rd_val)) 
    `uvm_error(hdl, "uvm_hdl_read returned FALSE")

  if (rd_val !== exp_val) begin
    if (oper == DEPOSIT || oper == FORCE)
      uvm_report_error(hdl, $sformatf("(line %0d): %s of 'h%h - read back got 'h%h instead of 'h%h",
       lineno, oper.name(), wr_val, rd_val, exp_val));
    else
      uvm_report_error(hdl, $sformatf("(line %0d): %s - read back got 'h%h instead of 'h%h",
       lineno, oper.name(), rd_val, exp_val));
  end

endtask

// Regs:
// Deposit - overwrites value, DUT may change procedurally anytime
// Force - forces value until released
// Release - forced value remains until DUT produrally reassigns
//
// Wires:
// Deposit - overwrites value, is retained until one or more driver(s) change value
// Force - forces value until released
// Release - if continuously driven, immediately gets driven value accordingly.
//           if not driven, retains value until next direct assignment


initial begin
   static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

   reg [7:0] dat;
   
   #50; // get between updates to q
   op(DEPOSIT, "dut.q",       'h3F, 'h3F, `__LINE__);
#5;
   op(FORCE, "dut.z.ZERO",       'hFF, 'h0f, `__LINE__);
   op(READ, "dut.z.ZERO",       , 'h0F, `__LINE__);
#5;
   op(DEPOSIT, "dut.z.b",       'hAB, 'hAB, `__LINE__);
   op(READ, "dut.z.b",       , 'hAB, `__LINE__);
   op(DEPOSIT, "dut.z.c",       'hF, 'hF, `__LINE__);
   op(DEPOSIT, "dut.z.d",       'h1, 'h1, `__LINE__);

  
   begin
      uvm_report_server svr;
      svr = cs_.get_report_server();

      svr.report_summarize();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
end

endprogram
