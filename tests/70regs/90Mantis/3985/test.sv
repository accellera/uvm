//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc. 
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

class mem extends uvm_mem;

   function new(string name = "mem");
      super.new(name, 256, 32);
   endfunction
endclass


class blk extends uvm_reg_block;
   mem m;

   function new(string name = "blk");
      super.new(name);
   endfunction

   virtual function void build();
      m = new("m");
      m.configure(this);

      default_map = create_map("map", 'h1000, 4, UVM_LITTLE_ENDIAN);
      default_map.add_mem(m, 'h800);
   endfunction
endclass


initial
begin
   blk b;
   b = new;
   b.build();
   b.lock_model();

   begin
      uvm_mem mem;
      mem = b.default_map.get_mem_by_offset('h1800);
      if (mem == null) `uvm_error("TEST", "Did not find the memory at offset 'h1800");
      if (mem != b.m) `uvm_error("TEST", "Found the wrong memory at offset 'h1800");

      // Byte-addressing used by default
      mem = b.default_map.get_mem_by_offset('h1BFC);
      if (mem == null) `uvm_error("TEST", "Did not find the memory at offset 'h1BFC");
      if (mem != b.m) `uvm_error("TEST", "Found the wrong memory at offset 'h1BFC");

      mem = b.default_map.get_mem_by_offset('h1700);
      if (mem != null) `uvm_error("TEST", "Found a memory at offset 'h1700");

      mem = b.default_map.get_mem_by_offset('h1C00);
      if (mem != null) `uvm_error("TEST", "Found a memory at offset 'h1C00");
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
