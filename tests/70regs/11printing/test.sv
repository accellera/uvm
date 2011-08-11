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


class block_l1 extends uvm_reg_block;
   `uvm_object_utils(block_l1)
   rand reg32 r0;
   rand reg8  r1;
   rand reg32 r2;

   uvm_reg_map bus8;
   uvm_reg_map bus32;

   function new(string name = "block_l1");
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
      // FIXME base_addr does NOT seem to be honoured
      bus8 = create_map("bus8", 'hf, 1, UVM_LITTLE_ENDIAN);
      bus32 = create_map("bus32", 'hff, 4, UVM_LITTLE_ENDIAN);

      bus8.add_reg(r0,    'h0,  "RW");
      bus8.add_reg(r1,    'h4,  "RW");
      bus8.add_reg(r2,    'h5,  "RW");

      bus32.add_reg(r0,    'h0,  "RW");
      bus32.add_reg(r1,    'h4,  "RW");
      bus32.add_reg(r2,    'h8,  "RW");
   endfunction
endclass

class block_l2 extends uvm_reg_block;
   `uvm_object_utils(block_l2)

   uvm_reg_map m;
   block_l1 l1;
 
   function new(string name = "block_l2");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      // define default map
      m = create_map("combined_map", 0, 1, UVM_LITTLE_ENDIAN);
      l1=new("l1");
      l1.build();
      l1.configure(this, "foo");

    // FIXME notion of "offset" is unclear 
      m.add_submap(l1.bus8,'h200);
      m.add_submap(l1.bus32,'h400);
   endfunction
endclass
    
    
    function automatic void print_adresses(uvm_reg r);
      uvm_reg_map m[$];
      
      // FIXME seems only to return offset within the direct parent map
      r.get_maps(m);
      foreach(m[idx]) begin
         uvm_reg_map map = m[idx];
         `uvm_info("REG",$sformatf("addr of %s within map %s is %x",r.get_full_name(),map.get_full_name(),r.get_offset(map)),UVM_NONE)
      end
   endfunction

    function automatic void print_all_regs(uvm_reg_map m);
      uvm_reg r[$];
      `uvm_info("reg",{"printing for map ",m.get_full_name()},UVM_INFO)
      
      m.get_registers(r);
      
      // FIXME the query methods such as uvm_reg_map::get_registers() may return multiple entries for the same reg
      // FIXME WA for not having r=r.unique;
      begin 
        bit u[uvm_reg];
        foreach(r[idx])
             u[r[idx]]=1;
        
        r.delete();     
        foreach(u[idx])
            r.push_back(idx);
      end
      
      
      assert(r.size() ==3) else `uvm_error("REG",$sformatf("expected 3 regs but got %0d in map",r.size()))
      foreach (r[idx]) begin
         print_adresses(r[idx]);
      end
   endfunction
    
    
initial
begin
   uvm_reg rg;
   block_l2 blk;
   
   blk = new("blk");

   blk.build();
   blk.lock_model();

   blk.print();

   print_all_regs(blk.default_map);

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
