//---------------------------------------------------------------------- 
//   Copyright 2013 Synopsys, Inc. 
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

class reg1 extends uvm_reg;
   `uvm_object_utils(reg1)

   uvm_reg_field data;

   function new(string name = "reg1");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      data = uvm_reg_field::type_id::create("data",,get_full_name());
      data.configure(this, 32,  0, "RW", 0,   'h0, 1, 0, 1);
   endfunction
endclass


class rfile1 extends uvm_reg_file;
   `uvm_object_utils(rfile1)

  reg1 r1;

   function new(string name = "rfile1");
     super.new(name);
   endfunction

   virtual function void build();
     r1 = reg1::type_id::create("r1",,get_full_name());
     r1.configure(get_parent(), this, "");
     r1.build();
   endfunction
endclass


class rfile2 extends uvm_reg_file;
   `uvm_object_utils(rfile2)

  reg1 r1;
  rfile1 rf1;

   function new(string name = "rfile2");
     super.new(name);
   endfunction

   virtual function void build();
     r1 = reg1::type_id::create("r1",,get_full_name());
     r1.configure(get_parent(), this, "");
     r1.build();

     rf1 = rfile1::type_id::create("rf1",,get_full_name());
     rf1.configure(get_parent(), this, "");
     rf1.build();
   endfunction
endclass


class blk1 extends uvm_reg_block;
   `uvm_object_utils(blk1)

   reg1 r1;
   rfile1 rf1;
   rfile2 rf2;
   
   function new(string name = "blk1");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      r1 = reg1::type_id::create("r1",,get_full_name());
      r1.configure(this, null, "");
      r1.build();

      rf1 = rfile1::type_id::create("rf1",,get_full_name());
      rf1.configure(this, null, "");
      rf1.build();

      rf2 = rfile2::type_id::create("rf2",,get_full_name());
      rf2.configure(this, null, "");
      rf2.build();
   endfunction
endclass


class blk2 extends uvm_reg_block;
   reg1 r1;
   rfile1 rf1;
   rfile2 rf2;
   blk1 b1;

   `uvm_object_utils(blk2)

   function new(string name = "blk2");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      r1 = reg1::type_id::create("r1",,get_full_name());
      r1.configure(this, null, "");
      r1.build();

      rf1 = rfile1::type_id::create("rf1",,get_full_name());
      rf1.configure(this, null, "");
      rf1.build();

      rf2 = rfile2::type_id::create("rf2",,get_full_name());
      rf2.configure(this, null, "");
      rf2.build();

      b1 = blk1::type_id::create("b1");
      b1.configure(this);
      b1.build();
   endfunction
endclass


function void check_name(string act, string exp);
  if (act == exp) return;

  `uvm_error("TEST", {exp, ".get_full_name() returned \"", act, "\" instead of \"", exp, "\"."})
endfunction


initial begin
   static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

   blk2 blk;
  
   blk = blk2::type_id::create("blk");
   blk.build();

   check_name(blk.r1.get_full_name(),            "blk.r1");
   check_name(blk.rf1.r1.get_full_name(),        "blk.rf1.r1");
   check_name(blk.rf2.r1.get_full_name(),        "blk.rf2.r1");
   check_name(blk.rf2.rf1.r1.get_full_name(),    "blk.rf2.rf1.r1");
   check_name(blk.b1.r1.get_full_name(),         "blk.b1.r1");
   check_name(blk.b1.rf1.r1.get_full_name(),     "blk.b1.rf1.r1");
   check_name(blk.b1.rf2.r1.get_full_name(),     "blk.b1.rf2.r1");
   check_name(blk.b1.rf2.rf1.r1.get_full_name(), "blk.b1.rf2.rf1.r1");
          
   begin
      uvm_report_server svr;
      svr = cs_.get_report_server();

      svr.report_summarize();

      if (svr.get_severity_count(UVM_FATAL) == 0 &&
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
end

endprogram
