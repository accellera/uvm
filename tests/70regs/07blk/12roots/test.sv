//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
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

class my_catcher extends uvm_report_catcher;
   static int n_dupl  = 0;
   virtual function action_e catch();
      if (get_severity() == UVM_ERROR &&
          get_id() == "UVM/REG/DUPLROOT") begin
         n_dupl++;
         set_severity(UVM_WARNING);
      end
      return THROW;
   endfunction
endclass


class blk1 extends uvm_reg_block;
   `uvm_object_utils(blk1)
   
   function new(string name = "blk1");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      default_map = create_map("", 0, 1, UVM_BIG_ENDIAN);
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

      default_map = create_map("", 0, 1, UVM_BIG_ENDIAN);
      default_map.add_submap(b2.default_map, 0);
   endfunction
endclass


initial
begin
   my_catcher c;
   c = new;
   uvm_report_cb::add(null, c);

   begin
      blk1 b1,b3; blk2 b2;
      b1 = blk1::type_id::create("b1");
      b2 = blk2::type_id::create("b2");
      b3 = blk1::type_id::create("b1");
      
      b1.lock_model();
      b2.lock_model();
      b3.lock_model();
   end

   begin
      uvm_reg_block blks[$];
      uvm_reg_block::get_root_blocks(blks);

      if (blks.size() != 3) begin
         `uvm_error("Test",
                    $sformatf("%0d root blocks were found instead of 3",
                              blks.size()))
         foreach (blks[i]) begin
            `uvm_info("Test", $sformatf("Root block: \"%s\"",
                                        blks[i].get_full_name()), UVM_NONE)
                                        
         end
      end
   end
   
   if (my_catcher::n_dupl != 1) begin
      `uvm_error("Test", "Fatal message about duplicate root register model names not seen");
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
