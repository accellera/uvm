//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Synopsys, Inc. 
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


class blk1 extends uvm_reg_block;
   `uvm_object_utils(blk1)

   reg1 r1;
   reg1 r2;
   
   function new(string name = "blk1");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      // The 'h100 will be ignored once this map is instantiated
      // in a higher level map.
      default_map = create_map("", 'h100, 4, UVM_LITTLE_ENDIAN);
      
      r1 = reg1::type_id::create("r1",,get_full_name());
      r1.configure(this, null, "");
      r1.build();

      r2 = reg1::type_id::create("r2",,get_full_name());
      r2.configure(this, null, "");
      r2.build();

      default_map.add_reg(r1, 0);
      default_map.add_reg(r2, 'h10);
   endfunction
endclass


class blk2 extends uvm_reg_block;
   blk1 b1;
   blk1 b2;

   `uvm_object_utils(blk2)

   function new(string name = "blk2");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      b1 = blk1::type_id::create("b1");
      b1.configure(this);
      b1.build();

      b2 = blk1::type_id::create("b2");
      b2.configure(this);
      b2.build();

      default_map = create_map("", 'h10000, 1, UVM_LITTLE_ENDIAN);
      default_map.add_submap(b1.default_map, 'h1000);
      default_map.add_submap(b2.default_map, 'h2000);

      b2.default_map.set_base_addr('h200);
   endfunction
endclass


function void check_address(uvm_reg rg,
                            uvm_reg_addr_t off,
                            uvm_reg_addr_t addr);
   $write("Checking address of \"%s\"...\n", rg.get_full_name());
   if (rg.get_offset() !== off) begin
      `uvm_error("TEST",
                 $sformatf("Register \"%s\" is at offset 'h%h instead of 'h%h",
                           rg.get_full_name(), rg.get_offset(), off));
   end
   if (rg.get_address() !== addr) begin
      `uvm_error("TEST",
                 $sformatf("Register \"%s\" is at address 'h%h instead of 'h%h",
                           rg.get_full_name(), rg.get_address(), addr));
   end
endfunction

initial
begin
   blk2 blk;
   blk = blk2::type_id::create("blk");
   blk.build();
   blk.lock_model();

   check_address(blk.b1.r1, 'h0000, 'h11000);
   check_address(blk.b1.r2, 'h0010, 'h11040);
   check_address(blk.b2.r1, 'h0000, 'h10200);
   check_address(blk.b2.r2, 'h0010, 'h10240);
          
   begin
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      svr.summarize();

      if (svr.get_severity_count(UVM_FATAL) == 0 &&
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
end

endprogram
