//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc. 
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


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class r1_typ extends uvm_reg;

   uvm_reg_field WO1;
   uvm_reg_field W1;
   uvm_reg_field WOS;
   uvm_reg_field WOC;
   uvm_reg_field WO;
   uvm_reg_field W0CRS;
   uvm_reg_field W0SRC;
   uvm_reg_field W1CRS;
   uvm_reg_field W1SRC;
   uvm_reg_field W0T;
   uvm_reg_field W0S;
   uvm_reg_field W0C;
   uvm_reg_field W1T;
   uvm_reg_field W1S;
   uvm_reg_field W1C;
   uvm_reg_field WCRS;
   uvm_reg_field WSRC;
   uvm_reg_field WS;
   uvm_reg_field WC;
   uvm_reg_field WRS;
   uvm_reg_field WRC;
   uvm_reg_field RS;
   uvm_reg_field RC;
   uvm_reg_field RW;
   uvm_reg_field RO;

   function new(string name = "a_reg");
      super.new(name,64,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.WO1   = uvm_reg_field::type_id::create("WO1");
      this.W1    = uvm_reg_field::type_id::create("W1");
      this.WOS   = uvm_reg_field::type_id::create("WOS");
      this.WOC   = uvm_reg_field::type_id::create("WOC");
      this.WO    = uvm_reg_field::type_id::create("WO");
      this.W0CRS = uvm_reg_field::type_id::create("W0CRS");
      this.W0SRC = uvm_reg_field::type_id::create("W0SRC");
      this.W1CRS = uvm_reg_field::type_id::create("W1CRS");
      this.W1SRC = uvm_reg_field::type_id::create("W1SRC");
      this.W0T   = uvm_reg_field::type_id::create("W0T");
      this.W0S   = uvm_reg_field::type_id::create("W0S");
      this.W0C   = uvm_reg_field::type_id::create("W0C");
      this.W1T   = uvm_reg_field::type_id::create("W1T");
      this.W1S   = uvm_reg_field::type_id::create("W1S");
      this.W1C   = uvm_reg_field::type_id::create("W1C");
      this.WCRS  = uvm_reg_field::type_id::create("WCRS");
      this.WSRC  = uvm_reg_field::type_id::create("WSRC");
      this.WS    = uvm_reg_field::type_id::create("WS");
      this.WC    = uvm_reg_field::type_id::create("WC");
      this.WRS   = uvm_reg_field::type_id::create("WRS");
      this.WRC   = uvm_reg_field::type_id::create("WRC");
      this.RS    = uvm_reg_field::type_id::create("RS");
      this.RC    = uvm_reg_field::type_id::create("RC");
      this.RW    = uvm_reg_field::type_id::create("RW");
      this.RO    = uvm_reg_field::type_id::create("RO");

        this.WO1.configure(this, 2, 48, "WO1",   0, 2'b01, 1, 0, 0);
         this.W1.configure(this, 2, 46, "W1",    0, 2'b01, 1, 0, 0);
        this.WOS.configure(this, 2, 44, "WOS",   0, 2'b01, 1, 0, 0);
        this.WOC.configure(this, 2, 42, "WOC",   0, 2'b01, 1, 0, 0);
         this.WO.configure(this, 2, 40, "WO",    0, 2'b01, 1, 0, 0);
      this.W0CRS.configure(this, 2, 38, "W0CRS", 0, 2'b01, 1, 0, 0);
      this.W0SRC.configure(this, 2, 36, "W0SRC", 0, 2'b01, 1, 0, 0);
      this.W1CRS.configure(this, 2, 34, "W1CRS", 0, 2'b01, 1, 0, 0);
      this.W1SRC.configure(this, 2, 32, "W1SRC", 0, 2'b01, 1, 0, 0);
        this.W0T.configure(this, 2, 30, "W0T",   0, 2'b01, 1, 0, 0);
        this.W0S.configure(this, 2, 28, "W0S",   0, 2'b01, 1, 0, 0);
        this.W0C.configure(this, 2, 26, "W0C",   0, 2'b01, 1, 0, 0);
        this.W1T.configure(this, 2, 24, "W1T",   0, 2'b01, 1, 0, 0);
        this.W1S.configure(this, 2, 22, "W1S",   0, 2'b01, 1, 0, 0);
        this.W1C.configure(this, 2, 20, "W1C",   0, 2'b01, 1, 0, 0);
       this.WCRS.configure(this, 2, 18, "WCRS",  0, 2'b01, 1, 0, 0);
       this.WSRC.configure(this, 2, 16, "WSRC",  0, 2'b01, 1, 0, 0);
         this.WS.configure(this, 2, 14, "WS",    0, 2'b01, 1, 0, 0);
         this.WC.configure(this, 2, 12, "WC",    0, 2'b01, 1, 0, 0);
        this.WRS.configure(this, 2, 10, "WRS",   0, 2'b01, 1, 0, 0);
        this.WRC.configure(this, 2,  8, "WRC",   0, 2'b01, 1, 0, 0);
         this.RS.configure(this, 2,  6, "RS",    0, 2'b01, 1, 0, 0);
         this.RC.configure(this, 2,  4, "RC",    0, 2'b01, 1, 0, 0);
         this.RW.configure(this, 2,  2, "RW",    0, 2'b01, 1, 0, 0);
         this.RO.configure(this, 2,  0, "RO",    0, 2'b01, 1, 0, 0);
   endfunction

   `uvm_object_utils(r1_typ)
   
endclass

bit [49:0] r1 = `UVM_REG_DATA_WIDTH'h1555555555555;


class b1_typ extends uvm_reg_block;

   rand r1_typ r1; 
   
   function new(string name = "b1_typ");
            super.new(name,UVM_NO_COVERAGE);
   endfunction
   
   virtual function void build();
      
      r1 = r1_typ::type_id::create("r1");
      r1.build();
      r1.configure(this,null,"r1");
   endfunction
   
   `uvm_object_utils(b1_typ)
   
endclass


function void check(uvm_reg_data_t data, uvm_reg_data_t exp, string txt);
   if (data != exp) begin
      `uvm_error("Test", $sformatf("%s value is 'h%h instead of 'h%h", txt, data, exp))
   end
endfunction


initial
begin
   b1_typ model;
   uvm_status_e status;
   uvm_reg_data_t data;
   
   model = new("model");
   
   model.build();
   model.set_hdl_path_root("$root.top");

   model.reset();
   `uvm_info("Test", "Checking initial values...", UVM_NONE)
   data = model.r1.get();
   check(data, `UVM_REG_DATA_WIDTH'h1555555555555, "Mirrored");
   data = '0;
   model.r1.peek(status, data);
   check(data, `UVM_REG_DATA_WIDTH'h1555555555555, "Peeked");
   data = '0;
   model.r1.peek(status, data);
   check(data, `UVM_REG_DATA_WIDTH'h1555555555555, "Re-peeked");

   `uvm_info("Test", "Checking emulation of read side effects...", UVM_NONE)
   model.r1.read(status, data, .path(UVM_BACKDOOR));
   check(data, `UVM_REG_DATA_WIDTH'h0405555555555, "Read");
   data = '0;
   model.r1.peek(status, data);
   check(data, `UVM_REG_DATA_WIDTH'h155CC555C5CC5, "Peeked");
   data = model.r1.get();
   check(data, `UVM_REG_DATA_WIDTH'h155CC555C5CC5, "Mirrored");
   
   model.reset();
   r1 = `UVM_REG_DATA_WIDTH'h1555555555555;
   
   `uvm_info("Test", "Checking reset values...", UVM_NONE)
   data = model.r1.get();
   check(data, `UVM_REG_DATA_WIDTH'h1555555555555, "Mirrored");
   data = '0;
   model.r1.peek(status, data);
   check(data, `UVM_REG_DATA_WIDTH'h1555555555555, "Peeked");
   data = '0;
   model.r1.peek(status, data);
   check(data, `UVM_REG_DATA_WIDTH'h1555555555555, "Re-peeked");

   `uvm_info("Test", "Checking emulation of write side effects...", UVM_NONE)
   model.r1.write(status, `UVM_REG_DATA_WIDTH'h2AAAAAAAAAAAA, .path(UVM_BACKDOOR));
   model.r1.peek(status, data);
   check(data, `UVM_REG_DATA_WIDTH'h2B21713D3CA59, "Peeked");
   data = model.r1.get();
   check(data, `UVM_REG_DATA_WIDTH'h2B21713D3CA59, "Mirrored");

   `uvm_info("Test", "Checking emulation of 2nd write side effects...", UVM_NONE)
   model.r1.write(status, `UVM_REG_DATA_WIDTH'h16AAAAAAAAAAA, .path(UVM_BACKDOOR));
   model.r1.peek(status, data);
   check(data, `UVM_REG_DATA_WIDTH'h2B21751D3CA59, "Peeked");
   data = model.r1.get();
   check(data, `UVM_REG_DATA_WIDTH'h2B21751D3CA59, "Mirrored");

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
