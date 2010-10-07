//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
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

   wire [7:0] w = 'hD4;

   reg [7:0] q = 'h0F;
   reg [7:0] d = 'hF0;

   always #100 q = d;
endmodule


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

initial
begin
   reg [7:0] dat;
   
   #50;
   `uvm_info("Test", "Can read a reg?", UVM_LOW);
   if (!uvm_hdl_read("dut.q", dat))
      `uvm_error("dut.q", "uvm_hdl_read returned FALSE");
   if (dat !== 'h0F) 
      `uvm_error("dut.q", $psprintf("uvm_hdl_read returned 'h%h instead of 'h0F", dat));
   `uvm_info("Test", "Can read a wire?", UVM_LOW);
   if (!uvm_hdl_read("dut.w", dat))
      `uvm_error("dut.w", "uvm_hdl_read returned FALSE");
   if (dat !== 'hD4) 
      `uvm_error("dut.w", $psprintf("uvm_hdl_read returned 'h%h instead of 'hD4", dat));
   `uvm_info("Test", "Can read a reg slice?", UVM_LOW);
   if (!uvm_hdl_read("dut.q[0]", dat))
      `uvm_error("dut.q[0]", "uvm_hdl_read returned FALSE");
   if (dat !== 'h01) 
      `uvm_error("dut.q[0]", $psprintf("uvm_hdl_read returned 'h%h instead of 'h01", dat));
   `uvm_info("Test", "Can read a wire slice?", UVM_LOW);
   if (!uvm_hdl_read("dut.w[0]", dat))
      `uvm_error("dut.w[0]", "uvm_hdl_read returned FALSE");
   if (dat !== 'h00) 
      `uvm_error("dut.w[0]", $psprintf("uvm_hdl_read returned 'h%h instead of 'h00", dat));

   #50;
   `uvm_info("Test", "Can write a reg?", UVM_LOW);
   if (!uvm_hdl_deposit("dut.q", 'h3C))
      `uvm_error("dut.q", "uvm_hdl_deposit returned FALSE");
   if (!uvm_hdl_read("dut.q", dat))
      `uvm_error("dut.q", "uvm_hdl_read returned FALSE");
   if (dat !== 'h3C) 
      `uvm_error("dut.q", $psprintf("uvm_hdl_read returned 'h%h instead of 'h3C", dat));
   `uvm_info("Test", "Can write a reg slice?", UVM_LOW);
   if (!uvm_hdl_deposit("dut.q[4]", 1'b0))
      `uvm_error("dut.q", "uvm_hdl_deposit returned FALSE");
   if (!uvm_hdl_read("dut.q[4]", dat))
      `uvm_error("dut.q[4]", "uvm_hdl_read returned FALSE");
   if (dat !== 'h00) 
      `uvm_error("dut.q[4]", $psprintf("uvm_hdl_read returned 'h%h instead of 'h00", dat));
   if (!uvm_hdl_deposit("dut.q[4]", 1'b1))
      `uvm_error("dut.q", "uvm_hdl_deposit returned FALSE");
   if (!uvm_hdl_read("dut.q[4]", dat))
      `uvm_error("dut.q[4]", "uvm_hdl_read returned FALSE");
   if (dat !== 'h01) 
      `uvm_error("dut.q[4]", $psprintf("uvm_hdl_read returned 'h%h instead of 'h01", dat));
   
   `uvm_info("Test", "Can write a wire (with no effect)?", UVM_LOW);
   if (!uvm_hdl_deposit("dut.w", 'h3C))
      `uvm_error("dut.w", "uvm_hdl_deposit returned FALSE");
   if (!uvm_hdl_read("dut.w", dat))
      `uvm_error("dut.w", "uvm_hdl_read returned FALSE");
   if (dat !== 'hD4) 
      `uvm_error("dut.w", $psprintf("uvm_hdl_read returned 'h%h instead of 'hD4", dat));
   
   #100;
   `uvm_info("Test", "Deposited value can be overwritten?", UVM_LOW);
   if (!uvm_hdl_read("dut.q", dat))
      `uvm_error("dut.q", "uvm_hdl_read returned FALSE");
   if (dat !== 'hF0) 
      `uvm_error("dut.q", $psprintf("uvm_hdl_read returned 'h%h instead of 'hF0", dat));

   `uvm_info("Test", "Can force a reg?", UVM_LOW);
   if (!uvm_hdl_force("dut.q", 'h3C))
      `uvm_error("dut.q", "uvm_hdl_force returned FALSE");
   if (!uvm_hdl_read("dut.q", dat))
      `uvm_error("dut.q", "uvm_hdl_read returned FALSE");
   if (dat !== 'h3C) 
      `uvm_error("dut.q", $psprintf("uvm_hdl_read returned 'h%h instead of 'h3C", dat));
   
   `uvm_info("Test", "Can force a wire?", UVM_LOW);
   if (!uvm_hdl_force("dut.w", 'h3C))
      `uvm_error("dut.w", "uvm_hdl_force returned FALSE");
   if (!uvm_hdl_read("dut.w", dat))
      `uvm_error("dut.w", "uvm_hdl_read returned FALSE");
   if (dat !== 'h3C) 
      `uvm_error("dut.w", $psprintf("uvm_hdl_read returned 'h%h instead of 'h3C", dat));

   #100;
   `uvm_info("Test", "Forced value cannot be overwritten?", UVM_LOW);
   if (!uvm_hdl_read("dut.q", dat))
      `uvm_error("dut.q", "uvm_hdl_read returned FALSE");
   if (dat !== 'h3C) 
      `uvm_error("dut.q", $psprintf("uvm_hdl_read returned 'h%h instead of 'h3C", dat));
   if (!uvm_hdl_read("dut.w", dat))
      `uvm_error("dut.w", "uvm_hdl_read returned FALSE");
   if (dat !== 'h3C) 
      `uvm_error("dut.w", $psprintf("uvm_hdl_read returned 'h%h instead of 'h3C", dat));
   
   `uvm_info("Test", "Can release a reg?", UVM_LOW);
   if (!uvm_hdl_release("dut.q"))
      `uvm_error("dut.q", "uvm_hdl_release returned FALSE");
   if (!uvm_hdl_read("dut.q", dat))
      `uvm_error("dut.q", "uvm_hdl_read returned FALSE");
   if (dat !== 'hF0) 
      `uvm_error("dut.q", $psprintf("uvm_hdl_read returned 'h%h instead of 'hF0", dat));
   
   `uvm_info("Test", "Can release a wire?", UVM_LOW);
   if (!uvm_hdl_release("dut.w"))
      `uvm_error("dut.w", "uvm_hdl_release returned FALSE");
   if (!uvm_hdl_read("dut.w", dat))
      `uvm_error("dut.w", "uvm_hdl_read returned FALSE");
   if (dat !== 'hD4) 
      `uvm_error("dut.w", $psprintf("uvm_hdl_read returned 'h%h instead of 'hD4", dat));

   `uvm_info("Test", "Forced value propagate?", UVM_LOW);
   if (!uvm_hdl_force("dut.d", 'hA5))
      `uvm_error("dut.q", "uvm_hdl_force returned FALSE");
   #100;
   if (!uvm_hdl_read("dut.q", dat))
      `uvm_error("dut.q", "uvm_hdl_read returned FALSE");
   if (dat !== 'hA5) 
      `uvm_error("dut.q", $psprintf("uvm_hdl_read returned 'h%h instead of 'hA5", dat));

   `uvm_info("Test", "Released value propagate?", UVM_LOW);
   if (!uvm_hdl_release("dut.d"))
      `uvm_error("dut.d", "uvm_hdl_release returned FALSE");
   if (!uvm_hdl_read("dut.d", dat))
      `uvm_error("dut.d", "uvm_hdl_read returned FALSE");
   if (dat !== 'hF0) 
      `uvm_error("dut.d", $psprintf("uvm_hdl_release returned 'h%h instead of 'hF0", dat));
   #100;
   if (!uvm_hdl_read("dut.q", dat))
      `uvm_error("dut.q", "uvm_hdl_read returned FALSE");
   if (dat !== 'hF0) 
      `uvm_error("dut.q", $psprintf("uvm_hdl_read returned 'h%h instead of 'hF0", dat));

   `uvm_info("Test", "Check timed forced", UVM_LOW);
   uvm_hdl_force_time("dut.d", 'h0F, 100);
   if (!uvm_hdl_read("dut.q", dat))
      `uvm_error("dut.q", "uvm_hdl_read returned FALSE");
   if (dat !== 'h0F) 
      `uvm_error("dut.q", $psprintf("uvm_hdl_read returned 'h%h instead of 'h0F", dat));
   if (!uvm_hdl_read("dut.d", dat))
      `uvm_error("dut.d", "uvm_hdl_read returned FALSE");
   if (dat !== 'hF0) 
      `uvm_error("dut.d", $psprintf("uvm_hdl_read returned 'h%h instead of 'hF0", dat));

   
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
