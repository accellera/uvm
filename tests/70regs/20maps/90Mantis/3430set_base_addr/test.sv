//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Synopsys, Inc. 
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc.
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
program top;

import uvm_pkg::*;

class reg8 extends uvm_reg;
   `uvm_object_utils(reg8)
   
   uvm_reg_field f8;

   function new(string name = "reg8");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.f8 = new("f8");
      this.f8.configure(this, 8,  0, "RW", 0, 'h0, 1, 0, 1);
   endfunction
endclass


class leaf extends uvm_reg_block;
   `uvm_object_utils(leaf)
   rand reg8  r;

   uvm_reg_map bus8;

   function new(string name = "leaf");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      r = new("r");
      r.build();
      r.configure(this, null);

      bus8 = create_map("bus8", 'h0, 1, UVM_LITTLE_ENDIAN);
      bus8.add_reg(r,    'h0,  "RW");
   endfunction
endclass


class dut extends uvm_reg_block;
   `uvm_object_utils(dut)
   rand leaf l;

   uvm_reg_map bus8;

   function new(string name = "dut");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      l = new("l");
      l.build();
      l.configure(this);

      bus8 = create_map("bus8", 'h0, 1, UVM_LITTLE_ENDIAN);
      bus8.add_submap(l.bus8,   'h0);
   endfunction
endclass


initial
begin
   uvm_reg rg;
   dut blk;
   blk = new("blk");

   blk.build();
   $write("Checking that set_base_addr() works before the model is locked...\n");
   blk.bus8.set_base_addr('h1000);
   blk.l.bus8.set_base_addr('h100);

   blk.lock_model();

   blk.print();

   rg = blk.bus8.get_reg_by_offset('h1100);
   if (rg == null) `uvm_error("Test", "No register at bus8/1100");

   $write("Checking that set_base_addr() works after the model is locked...\n");
   blk.bus8.set_base_addr('h2000);
   blk.l.bus8.set_base_addr('h200);

   blk.print();

   rg = blk.bus8.get_reg_by_offset('h2200);
   if (rg == null) `uvm_error("Test", "No register at bus8/1100");

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
