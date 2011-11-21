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

class reg16 extends uvm_reg;
   `uvm_object_utils(reg16)
   
   uvm_reg_field f16;

   function new(string name = "reg16");
      super.new(name,16,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.f16 = new("f16");
      this.f16.configure(this, 16,  0, "RW", 0, 'h0, 1, 0, 1);
   endfunction
endclass


class leaf extends uvm_reg_block;
   `uvm_object_utils(leaf)
   rand reg16  r;

   uvm_reg_map bus8_0;
   uvm_reg_map bus8_1;

   function new(string name = "leaf");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      r = new("r");
      r.build();
      r.configure(this, null);

      bus8_0 = create_map("bus8_0", 'h0, 1, UVM_LITTLE_ENDIAN);
      bus8_0.add_reg(r,    'h10,  "RW");
      bus8_1 = create_map("bus8_1", 'h0, 1, UVM_LITTLE_ENDIAN);
      bus8_1.add_reg(r,    'h10,  "RW");
   endfunction
endclass


class branch extends uvm_reg_block;
   `uvm_object_utils(branch)
   rand leaf l;

   uvm_reg_map bus32x32;
   uvm_reg_map bus32x8;

   function new(string name = "branch");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      l = new("l");
      l.build();
      l.configure(this);

      bus32x32 = create_map("bus32x32", 'h0, 4, UVM_LITTLE_ENDIAN, 1);
      bus32x32.add_submap(l.bus8_0,   'h0);

      bus32x8 = create_map("bus32x8", 'h0, 4, UVM_LITTLE_ENDIAN, 0);
      bus32x8.add_submap(l.bus8_1,   'h0);
   endfunction
endclass


class trunk extends uvm_reg_block;
   `uvm_object_utils(trunk)
   rand branch br;

   uvm_reg_map bus8_0;
   uvm_reg_map bus8_1;

   function new(string name = "trunk");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      br = new("br");
      br.build();
      br.configure(this);

      bus8_0 = create_map("bus8_0", 'h0, 1, UVM_LITTLE_ENDIAN);
      bus8_0.add_submap(br.bus32x32,'h0);

      bus8_1 = create_map("bus8_1", 'h0, 1, UVM_LITTLE_ENDIAN);
      bus8_1.add_submap(br.bus32x8, 'h0);
   endfunction
endclass


function void check_map(uvm_reg rg, uvm_reg_map map, uvm_reg_addr_t exp[]);
   uvm_reg_addr_t addr[];
   
   void'(rg.get_addresses(map, addr));
   if (addr != exp) begin
      `uvm_error("Test", $sformatf("Register %s is at addresses %p in map %s instead of %p",
                                   rg.get_full_name(), addr,
                                   map.get_full_name(), exp));
   end
endfunction


initial
begin
   uvm_reg rg;
   uvm_reg_addr_t addr[];
   uvm_reg_addr_t exp[];
   trunk dut;

   dut = new("dut");

   dut.build();
   dut.lock_model();

   dut.print();

   rg = dut.br.l.r;

`ifndef POSSIBLE_OPTIMIZATION
    begin
            uvm_reg_addr_t t[8];
 	    t='{'h40, 'h41, 'h42, 'h43,
                               'h44, 'h45, 'h46, 'h47};

   check_map(rg, dut.bus8_0, t);

   check_map(rg, dut.bus8_1, t);
    end
`else
   check_map(rg, dut.bus8_0, '{'h40, 'h44});
   check_map(rg, dut.bus8_1, '{'h40, 'h44});
`endif

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
