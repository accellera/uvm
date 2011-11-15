//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
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

`include "uvm_macros.svh"
program top;

import uvm_pkg::*;

class reg_ID extends uvm_reg;

   uvm_reg_field REVISION_ID;
   uvm_reg_field CHIP_ID;
   uvm_reg_field PRODUCT_ID;

   function new(string name = "reg_ID");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.REVISION_ID = uvm_reg_field::type_id::create("REVISION_ID");
          this.CHIP_ID = uvm_reg_field::type_id::create("CHIP_ID");
       this.PRODUCT_ID = uvm_reg_field::type_id::create("PRODUCT_ID");

      this.REVISION_ID.configure(this, 8,  0, "RW", 0,   8'h03, 1, 0, 1);
          this.CHIP_ID.configure(this, 8,  8, "RW", 0,   8'hFF, 0, 0, 1);
       this.PRODUCT_ID.configure(this, 10, 16,"RW", 0, 10'h176, 1, 0, 1);

      this.REVISION_ID.set_reset(8'h30);
          this.CHIP_ID.set_reset(8'h3C, "SOFT");
   endfunction
endclass


initial
begin
   uvm_reg_data_t data;
   reg_ID rg;
   rg = new;

   rg.build();
   
   rg.REVISION_ID.set(8'hFC);
       rg.CHIP_ID.set(8'hA5);
    rg.PRODUCT_ID.set(10'h289);

   data = rg.get();
   if (data !== 'h289A5FC) `uvm_error("Test", "Field values were not set");

   rg.reset("SOFT");
   data = rg.get();
   if (data !== 'h2893CFC) `uvm_error("Test", $sformatf("Soft reset value is 'h%h instead of 'h2893CFC", data));
   
   rg.reset();
   data = rg.get();
   if (data !== 'h1763C30) `uvm_error("Test", $sformatf("Hard reset value is 'h%h instead of 'h1765A30", data));

   
   rg.REVISION_ID.set(8'hFC);
       rg.CHIP_ID.set(8'hA5);
    rg.PRODUCT_ID.set(10'h289);
   data = rg.get();
   if (data !== 'h289A5FC) `uvm_error("Test", "Field values were not set");

   void'(rg.PRODUCT_ID.has_reset("HARD", 1));
   rg.CHIP_ID.set_reset(8'h5A);
   rg.reset();
   data = rg.get();
   if (data !== 'h2895A30) `uvm_error("Test", $sformatf("Hard reset value is 'h%h instead of 'h2895A30", data));
   
   rg.print();
   
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
