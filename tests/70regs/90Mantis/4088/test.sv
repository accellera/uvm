//---------------------------------------------------------------------- 
//   Copyright 2012 Accellera Systems Initiative
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

  `uvm_object_utils(a_reg)

   function new(string name = "a_reg");
      super.new(name, 64, UVM_NO_COVERAGE);
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

class a_blk extends uvm_reg_block;
   
  a_reg REG;
  
  function new(string name = "a_blk");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    this.REG = a_reg::type_id::create("REG");
    this.REG.build();
    this.REG.configure(this, null);
    
    default_map = create_map("default_map", 'h0, 8, UVM_BIG_ENDIAN);
    default_map.add_reg(REG, 'h00000000, "RW");
  endfunction
endclass

  
class info_error_catcher extends uvm_report_catcher;
  int error_seen = 0;
  int info_seen = 0;
  virtual function action_e catch();

    if (get_severity() == UVM_ERROR && get_id() == "RegModel" &&
        get_message() == "Register \"blk.REG\" value read from DUT (0xffffffffffffffff) does not match mirrored value (0x000xXx0000000000)") begin
      error_seen++;
      return CAUGHT;
    end else if (get_severity() == UVM_INFO && get_id() == "RegModel") begin
      info_seen++;
      return THROW;
    end
 else begin
      return THROW;
    end
  endfunction
endclass


class test extends uvm_test;

  `uvm_component_utils(test)

  info_error_catcher catcher;
  a_blk blk;
  
  function new(string name = "test", uvm_component parent=null);
    super.new(name,parent);
    catcher = new;
    uvm_report_cb::add(null,catcher);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    blk = new("blk");
    blk.build();
    blk.lock_model();

    if (blk.REG.do_check('0, '1, blk.default_map))
      `uvm_error(get_type_name(), "do_check did not report an error as expected")
  endfunction

  function void report_phase(uvm_phase phase);
    uvm_coreservice_t cs_;
    uvm_report_server svr;
    cs_ = uvm_coreservice_t::get();
    svr = cs_.get_report_server();
    
    if (svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) == 0 && 
        catcher.error_seen == 1  && 
        catcher.info_seen == 21)
      $write("** UVM TEST PASSED **\n");
    else
      $write("!! UVM TEST FAILED !!\n");
  endfunction
endclass

initial begin
  run_test();
end
endprogram
