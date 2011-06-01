//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2010 Mentor Graphics Corporation
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

   reg [7:0] q = 'h0F;
   reg [7:0] d = 'hF0;

   assign w = q; //'hD4;

   always #100 q = d;
endmodule


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum { READ, DEPOSIT, FORCE, RELEASE } op_e;

task  op(op_e oper, string hdl, bit [7:0] wr_val=0, bit [7:0] exp_val, int lineno, time force_time=0);


  bit [7:0] rd_val;

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
   //if (!uvm_hdl_release_and_read(hdl,rd_val))
      `uvm_error(hdl,"uvm_hdl_release returned FALSE")
  end

  if (!uvm_hdl_read(hdl,rd_val))
  //if (oper != RELEASE && !uvm_hdl_read(hdl,rd_val))
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


initial
begin
   reg [7:0] dat;
   
   #50; // get between updates to q

   
   op(READ,   "dut.q",            , 'h0F, `__LINE__);
   op(READ,   "dut.w",            , 'h0F, `__LINE__);
   op(READ,   "dut.q[1]",         , 'h01, `__LINE__);

   op(DEPOSIT, "dut.q",       'h3C, 'h3C, `__LINE__);
   op(DEPOSIT, "dut.q[4]",    'h00, 'h00, `__LINE__);
   op(DEPOSIT, "dut.q[6]",    'h01, 'h01, `__LINE__);
`ifndef MODEL_TECH
   op(DEPOSIT, "dut.q[6:4]",  'h02, 'h02, `__LINE__);
   op(READ,    "dut.q",           , 'h2C, `__LINE__);
   op(DEPOSIT, "dut.q[7:4]",  'h06, 'h06, `__LINE__);
`endif
   
   #0;
   op(READ,    "dut.w",           , 'h6C, `__LINE__); // w is now q
   op(DEPOSIT, "dut.w",       'h3C, 'h3C, `__LINE__); // w retains until q drives new value
   #0;
   op(READ,    "dut.w",           , 'h3C, `__LINE__); //
   op(DEPOSIT, "dut.q",       'hA5, 'hA5, `__LINE__); // deposit on 'dut.q'

   #0;
   op(READ,    "dut.w",           , 'hA5, `__LINE__); // w is now q


   #100; // d propagates to q,w

   op(READ,    "dut.q",           , 'hF0, `__LINE__); // q and w are now d again
   op(READ,    "dut.w",           , 'hF0, `__LINE__); //

   op(FORCE,   "dut.q",       'h3C, 'h3C, `__LINE__); // force q and w
   op(FORCE,   "dut.w",       'hA5, 'hA5, `__LINE__); //

   #200; // q = d should not "take"

   op(READ,    "dut.q",           , 'h3C, `__LINE__); // q and w still forced, not d's value (F0)
   op(READ,    "dut.w",           , 'hA5, `__LINE__);

   //op(READ,    "dut.d",           , 'hF0, `__LINE__); // if uncommented, next two lines fail if use release_and_read

   op(RELEASE, "dut.q",           , 'h3C, `__LINE__); // q stays until reassigned, should be C3?
   op(RELEASE, "dut.w",           , 'h3C, `__LINE__); // w is re-evaluated, now q

   op(READ,    "dut.q",           , 'h3C, `__LINE__); // read q just for chuckles

   #100; // d propagates to q,w again

   op(READ,    "dut.q",           , 'hF0, `__LINE__); // q and w are now d again
   op(READ,    "dut.w",           , 'hF0, `__LINE__); //

   op(FORCE,   "dut.d",       'hA5, 'hA5, `__LINE__); // force d

   #100; // d propagates to q,w again

   op(READ,    "dut.q",           , 'hA5, `__LINE__); // q and w are now d
   op(READ,    "dut.w",           , 'hA5, `__LINE__); //

   op(RELEASE, "dut.d",           , 'hA5, `__LINE__); // d released, stays the same

   #100; // d propagates to q,w again

   op(READ,    "dut.q",           , 'hA5, `__LINE__); // q and w still d
   op(READ,    "dut.w",           , 'hA5, `__LINE__);

   op(FORCE,   "dut.d",       'hF0, 'hF0, `__LINE__); // force d back to F0

   #100; // d propagates to q,w again

   op(READ,    "dut.q",           , 'hF0, `__LINE__); // q and w back to d
   op(READ,    "dut.w",           , 'hF0, `__LINE__);

   op(FORCE,   "dut.d",       'h0F, 'h0F, `__LINE__, 100); // d forced for 100, then released

   op(READ,    "dut.q",           , 'h0F, `__LINE__); // q and w should be d
   op(READ,    "dut.w",           , 'h0F, `__LINE__);

   op(FORCE,   "dut.w",       'hAA, 'h0F, `__LINE__, 100); // w is driven to AA for 100, then released,
                                                           // which immed re-evaluates to its q driver, which is 'h0F

   // TODO: test undriven wire
   
   begin
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      svr.summarize();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
end

endprogram
