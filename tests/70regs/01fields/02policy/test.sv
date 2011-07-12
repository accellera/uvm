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

class a_blk extends uvm_reg_block;
   function new(string name = "a_blk");
      super.new(name);
   endfunction
endclass


class a_reg extends uvm_reg;

   uvm_reg_field DC;
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
      this.DC    = uvm_reg_field::type_id::create("DC");
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

         this.DC.configure(this, 2, 50, "RW",    0, 2'b01, 1, 0, 0);
         this.DC.set_compare(UVM_NO_CHECK);
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
endclass


//
// Use a user-defined front-door to model the DUT instead
//
class dut extends uvm_reg_frontdoor;

   uvm_reg_data_t R;
   bit written;

   function new(string name="dut");
      super.new(name);
      reset();
   endfunction

   function void reset();
      R = `UVM_REG_DATA_WIDTH'h5555555555555;
      written = 0;
   endfunction

   virtual task body();
      uvm_reg_data_t data;

      if (rw_info.kind == UVM_WRITE) begin
         data = rw_info.value[0];
         
         R[51:50] = data[51:50];             // DC
         R[49:48] = (written) ? R[49:48] : data[49:48]; // WO1
         R[47:46] = (written) ? R[47:46] : data[47:46]; // W1
         R[45:44] = 2'b11;                   // WOS
         R[43:42] = 2'b00;                   // WOC
         R[41:40] = data[41:40];             // WO
         R[39:38] = R[39:38] &  data[39:38]; // W0CRS
         R[37:36] = R[37:36] | ~data[37:36]; // W0SRC
         R[35:34] = R[35:34] & ~data[35:34]; // W1CRS
         R[33:32] = R[33:32] |  data[33:32]; // W1SRC
         R[31:30] = R[31:30] ^ ~data[31:30]; // W0T
         R[29:28] = R[29:28] | ~data[29:28]; // W0S
         R[27:26] = R[27:26] &  data[27:26]; // W0C
         R[25:24] = R[25:24] ^  data[25:24]; // W1T
         R[23:22] = R[23:22] |  data[23:22]; // W1S
         R[21:20] = R[21:20] & ~data[21:20]; // W1C
         R[19:18] = 2'b00;                   // WCRS
         R[17:16] = 2'b11;                   // WSRC
         R[15:14] = 2'b11;                   // WS
         R[13:12] = 2'b00;                   // WC
         R[11:10] = data[11:10];             // WRS
         R[ 9: 8] = data[ 9: 8];             // WRC
         R[ 7: 6] = R[ 7: 6];                // RS
         R[ 5: 4] = R[ 5: 4];                // RC
         R[ 3: 2] = data[ 3: 2];             // RW
         R[ 1: 0] = R[ 1: 0];                // RO

         written = 1;
      end
      else begin

         data = 0;
         
         data[51:50] = $random;                    // DC
         data[49:48] = 2'b00;                      // WO1
         data[47:46] = R[47:46];                   // W1
         data[45:44] = 2'b00;                      // WOS
         data[43:42] = 2'b00;                      // WOC
         data[41:40] = 2'b00;                      // WO
         data[39:38] = R[39:38]; R[39:38] = 2'b11; // W0CRS
         data[37:36] = R[37:36]; R[37:36] = 2'b00; // W0SRC
         data[35:34] = R[35:34]; R[35:34] = 2'b11; // W1CRS
         data[33:32] = R[33:32]; R[33:32] = 2'b00; // W1SRC
         data[31:30] = R[31:30];                   // W0T
         data[29:28] = R[29:28];                   // W0S
         data[27:26] = R[27:26];                   // W0C
         data[25:24] = R[25:24];                   // W1T
         data[23:22] = R[23:22];                   // W1S
         data[21:20] = R[21:20];                   // W1C
         data[19:18] = R[19:18]; R[19:18] = 2'b11; // WCRS
         data[17:16] = R[17:16]; R[17:16] = 2'b00; // WSRC
         data[15:14] = R[15:14];                   // WS
         data[13:12] = R[13:12];                   // WC
         data[11:10] = R[11:10]; R[11:10] = 2'b11; // WRS
         data[ 9: 8] = R[ 9: 8]; R[ 9: 8] = 2'b00; // WRC
         data[ 7: 6] = R[ 7: 6]; R[ 7: 6] = 2'b11; // RS
         data[ 5: 4] = R[ 5: 4]; R[ 5: 4] = 2'b00; // RC
         data[ 3: 2] = R[ 3: 2];                   // RW
         data[ 1: 0] = R[ 1: 0];                   // RO

         rw_info.value[0] = data;
      end
   endtask

endclass


initial
begin
   uvm_reg_data_t data;
   a_blk blk; 
   a_reg rg;
   dut   fd;

    blk=new("blk");
    rg=new("rg");
    fd=new();
    
   blk.default_map = blk.create_map("map", 0, 8, UVM_BIG_ENDIAN);
   rg.build();
   rg.configure(blk);
   blk.default_map.add_reg(rg, 0, "RW", 1, fd);
   blk.default_map.set_auto_predict();
   
   rg.reset();
   blk.print();
   blk.lock_model();
   
   begin   
      uvm_reg_single_bit_bash_seq seq;
      seq = new();
      seq.rg = rg;
      seq.start(null);
   end
   
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
