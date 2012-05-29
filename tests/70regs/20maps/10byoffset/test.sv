//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
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

   uvm_reg_field f8;

   function new(string name = "reg8");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.f8 = new("f8");
      this.f8.configure(this, 8,  0, "RW", 0, 'h0, 1, 0, 1);
   endfunction
endclass


class reg32 extends uvm_reg;

   uvm_reg_field f32;

   function new(string name = "reg32");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.f32 = new("f32");
      this.f32.configure(this, 32,  0, "RW", 0, 'h0, 1, 0, 1);
   endfunction
endclass


class dut extends uvm_reg_block;
   `uvm_object_utils(dut)
   rand reg32 r0;
   rand reg8  r1;
   rand reg32 r2;

   uvm_reg_map bus8;
   uvm_reg_map bus32;

   function new(string name = "dut");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      // create
      r0 = new("r0");
      r1 = new("r1");
      r2 = new("r2");

      // configure
      r0.build();   r0.configure(this, null);
      r1.build();   r1.configure(this, null);
      r2.build();   r2.configure(this, null);

      // define default map
      bus8 = create_map("bus8", 'h0, 1, UVM_LITTLE_ENDIAN);
      bus32 = create_map("bus32", 'h0, 4, UVM_LITTLE_ENDIAN);

      bus8.add_reg(r0,    'h0,  "RW");
      bus8.add_reg(r1,    'h4,  "RW");
      bus8.add_reg(r2,    'h5,  "RW");

      bus32.add_reg(r0,    'h0,  "RW");
      bus32.add_reg(r1,    'h4,  "RW");
      bus32.add_reg(r2,    'h8,  "RW");
   endfunction
endclass


class catcher extends uvm_report_catcher;
   static int seen = 0;
   virtual function action_e catch();
      if (get_message() == "Cannot get register by offset: Block blk is not locked.") begin
         seen++;
         set_severity(UVM_INFO);
      end
      return THROW;
   endfunction
endclass


initial
begin
   uvm_reg rg;
   dut blk; catcher ctchr;
   blk = new("blk"); ctchr = new;

   blk.build();
   blk.print();
   $write("%s\n", blk.convert2string());

   uvm_report_cb::add(null,ctchr);

   $write("Checking if get_by_offset(0 reports if model is not locked...\n");
   catcher::seen = 0;
   rg = blk.bus8.get_reg_by_offset(0);
   if (catcher::seen != 1) `uvm_error("Test", "uvm_reg_map::get_reg_by_offset() did not report that model was not locked");
   if (rg != null) `uvm_error("test", "A register was found without being locked");
   catcher::seen = 0;
   
   uvm_report_cb::delete(null,ctchr);

   $write("Locking model and trying again...\n");
   blk.lock_model();

   rg = blk.bus8.get_reg_by_offset(0);   
   if (rg != blk.r0) `uvm_error("Test", $sformatf("Register at bus8/0 is %s instead of r0", (rg == null)? "(null)" : rg.get_full_name()));

   rg = blk.bus8.get_reg_by_offset(3);   
   if (rg != blk.r0) `uvm_error("Test", $sformatf("Register at bus8/3 is %s instead of r0", (rg == null)? "(null)" : rg.get_full_name()));
   
   rg = blk.bus8.get_reg_by_offset(4);   
   if (rg != blk.r1) `uvm_error("Test", $sformatf("Register at bus8/4 is %s instead of r1", (rg == null)? "(null)" : rg.get_full_name()));

   rg = blk.bus8.get_reg_by_offset(5);   
   if (rg != blk.r2) `uvm_error("Test", $sformatf("Register at bus8/8 is %s instead of r2", (rg == null)? "(null)" : rg.get_full_name()));

   rg = blk.bus8.get_reg_by_offset(8);   
   if (rg != blk.r2) `uvm_error("Test", $sformatf("Register at bus8/8 is %s instead of r2", (rg == null)? "(null)" : rg.get_full_name()));

   rg = blk.bus8.get_reg_by_offset(9);   
   if (rg != null) `uvm_error("Test", $sformatf("Register at bus8/9 is %s instead of (null)", rg.get_full_name()));

   $write("Checking via a 32-bit bus...\n");
   
   rg = blk.bus32.get_reg_by_offset(0);   
   if (rg != blk.r0) `uvm_error("Test", $sformatf("Register at bus32/0 is %s instead of r0", (rg == null)? "(null)" : rg.get_full_name()));

   rg = blk.bus32.get_reg_by_offset(1);   
   if (rg != null) `uvm_error("Test", $sformatf("Register at bus32/1 is %s instead of (null)", rg.get_full_name()));

   rg = blk.bus32.get_reg_by_offset(4);   
   if (rg != blk.r1) `uvm_error("Test", $sformatf("Register at bus32/4 is %s instead of r1", (rg == null)? "(null)" : rg.get_full_name()));

   rg = blk.bus32.get_reg_by_offset(5);   
   if (rg != null) `uvm_error("Test", $sformatf("Register at bus32/5 is %s instead of (null)", rg.get_full_name()));

   rg = blk.bus32.get_reg_by_offset(7);   
   if (rg != null) `uvm_error("Test", $sformatf("Register at bus32/7 is %s instead of (null)", rg.get_full_name()));

   rg = blk.bus32.get_reg_by_offset(8);   
   if (rg != blk.r2) `uvm_error("Test", $sformatf("Register at bus32/8 is %s instead of r2", (rg == null)? "(null)" : rg.get_full_name()));

   rg = blk.bus32.get_reg_by_offset(9);   
   if (rg != null) `uvm_error("Test", $sformatf("Register at bus32/9 is %s instead of (null)", rg.get_full_name()));

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
