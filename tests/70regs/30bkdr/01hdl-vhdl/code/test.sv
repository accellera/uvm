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

module top;
   
//VHDL DUT   
   DUT DUTINST();

   //test
   prg prginst();   
   
endmodule // top

program prg;

import uvm_pkg::*;
`include "uvm_macros.svh"
   
typedef enum { READ, DEPOSIT, FORCE, RELEASE } op_e;

task automatic op(op_e oper, string hdl, bit [7:0] wr_val=0, bit [7:0] exp_val, int lineno, time force_time=0);


  bit [7:0] rd_val = 0;

  `uvm_info("TEST",$sformatf("attempting line %0d",lineno),UVM_NONE)

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

// release semantic might differ per simulator
// VCS:
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
//
// IUS release commands are done with vhpiReleaseKV which means the entity will preserve the current value UNTIL
// a new data value is progated to the signal/wire. this can make a difference when an intermediate wire si being forced and released. 

initial begin
   static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

   reg [7:0] dat;
   
   #51; // get between updates to q

   
   op(READ,   "top.DUTINST.q",            , 'h0F, `__LINE__);
   op(READ,   "top.DUTINST.w",            , 'h0F, `__LINE__);
   op(READ,   "top.DUTINST.q[1]",         , 'h01, `__LINE__);

   op(DEPOSIT, "top.DUTINST.q",       'h3C, 'h3C, `__LINE__);
   op(DEPOSIT, "top.DUTINST.q[4]",    'h00, 'h00, `__LINE__);
   op(DEPOSIT, "top.DUTINST.q[6]",    'h01, 'h01, `__LINE__);

/*
   op(DEPOSIT, "top.DUTINST.q[6:4]",  'h02, 'h02, `__LINE__);
   op(READ,    "top.DUTINST.q",           , 'h2C, `__LINE__);
   op(DEPOSIT, "top.DUTINST.q[7:4]",  'h06, 'h06, `__LINE__);
*/
   
   #1;
   op(READ,    "top.DUTINST.w",           , 'h6C, `__LINE__); // w is now q
   op(DEPOSIT, "top.DUTINST.w",       'h3C, 'h3C, `__LINE__); // w retains until q drives new value
   #1;
   op(READ,    "top.DUTINST.w",           , 'h3C, `__LINE__); //
   op(DEPOSIT, "top.DUTINST.q",       'hA5, 'hA5, `__LINE__); // deposit on 'top.DUTINST.q'

   #1;

   op(READ,    "top.DUTINST.w",           , 'hA5, `__LINE__); // w is now q


   #100; // d propagates to q,w 
//#150

   op(READ,    "top.DUTINST.q",           , 'hF0, `__LINE__); // q and w are now d again
   op(READ,    "top.DUTINST.w",           , 'hF0, `__LINE__); //

   op(FORCE,   "top.DUTINST.q",       'h3C, 'h3C, `__LINE__); // force q and w
   op(FORCE,   "top.DUTINST.w",       'hA5, 'hA5, `__LINE__); //

   #200; // q = d should not "take"
//#350

   op(READ,    "top.DUTINST.q",           , 'h3C, `__LINE__); // q and w still forced, not d's value (F0)
   op(READ,    "top.DUTINST.w",           , 'hA5, `__LINE__);
   
   op(RELEASE, "top.DUTINST.q",           , 'h3C, `__LINE__); // q released to value of d or to forced q ??
   
   op(RELEASE, "top.DUTINST.w",           , 'hA5, `__LINE__); // w is re-evaluated, now q

   op(READ,    "top.DUTINST.q",           , 'h3C, `__LINE__); // read q just for chuckles

   #101; // d propagates to q,w again
//#450
   op(READ,    "top.DUTINST.q",           , 'hF0, `__LINE__); // q and w are now d again
   op(READ,    "top.DUTINST.w",           , 'hF0, `__LINE__); //

   op(FORCE,   "top.DUTINST.d",       'hA5, 'hA5, `__LINE__); // force d

   #100; // d propagates to q,w again
// #550
   op(READ,    "top.DUTINST.q",           , 'hA5, `__LINE__); // q and w are now d
   op(READ,    "top.DUTINST.w",           , 'hA5, `__LINE__); //

   op(RELEASE, "top.DUTINST.d",           , 'hA5, `__LINE__); // d released, stays the same

   #100; // d propagates to q,w again
// #650
   op(READ,    "top.DUTINST.q",           , 'hA5, `__LINE__); // q and w still d
   op(READ,    "top.DUTINST.w",           , 'hA5, `__LINE__);

   op(FORCE,   "top.DUTINST.d",       'hF0, 'hF0, `__LINE__); // force d back to F0

   #100; // d propagates to q,w again
//#750
   op(READ,    "top.DUTINST.q",           , 'hF0, `__LINE__); // q and w back to d
   op(READ,    "top.DUTINST.w",           , 'hF0, `__LINE__);

   op(FORCE,   "top.DUTINST.d",       'h0F, 'h0F, `__LINE__, 100); // d forced for 100, then released
// #850

   op(READ,    "top.DUTINST.q",           , 'h0F, `__LINE__); // q and w should be d
   op(READ,    "top.DUTINST.w",           , 'h0F, `__LINE__);

   op(FORCE,   "top.DUTINST.w",       'hAA, 'haa, `__LINE__, 100); // w is driven to AA for 100, then released,
 // #950                                                          // which immed re-evaluates to its q driver, which is 'h0F

   // TODO: test undriven wire
   
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
