//---------------------------------------------------------------------- 
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
   
   function new(string name = "blk1");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      default_map = create_map("", 'h0, 4, UVM_LITTLE_ENDIAN);
      
      r1 = reg1::type_id::create("r1",,get_full_name());
      r1.configure(this, null, "");
      r1.build();

      default_map.add_reg(r1, 0);
   endfunction
endclass


class blk2 extends uvm_reg_block;
   blk1 b1;
   blk1 b2;
   blk1 a1;

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

      a1 = blk1::type_id::create("a1");
      a1.configure(this);
      a1.build();

      default_map = create_map("", 'h0, 4, UVM_LITTLE_ENDIAN);
      default_map.add_submap(a1.default_map, 'h0000);
      default_map.add_submap(b1.default_map, 'h1000);
      default_map.add_submap(b2.default_map, 'h2000);
   endfunction
endclass

initial
begin
   blk2 blk;
   blk = blk2::type_id::create("blk");
   blk.build();
   blk.lock_model();

   begin
      uvm_reg_block blks[$];

      void'(uvm_reg_block::find_blocks("*.b*", blks));
      if (blks.size() != 2) begin
         `uvm_error("TEST", $sformatf("Found %0d blocks matching \"*.b*\" instead of 2.",
                                      blks.size()))
         foreach (blks[i]) begin
            $write("   Found block: \"%s\".\n", blks[i].get_full_name());
         end
      end

      blks.delete();
      
      void'(uvm_reg_block::find_blocks("*1", blks, blk));
      if (blks.size() != 2) begin
         `uvm_error("TEST", $sformatf("Found %0d sub-blocks matching \"*1\" instead of 2.",
                                      blks.size()))
         foreach (blks[i]) begin
            $write("   Found block: \"%s\".\n", blks[i].get_full_name());
         end
      end
   end
          
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
