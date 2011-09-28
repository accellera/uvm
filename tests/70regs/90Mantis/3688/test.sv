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

   `uvm_object_utils(blk2)

   function new(string name = "blk2");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      b1 = blk1::type_id::create("leaf");
      b1.configure(this);
      b1.build();

      default_map = create_map("", 0, 1, UVM_BIG_ENDIAN);
      default_map.add_submap(b1.default_map, 'h00);
   endfunction
endclass


class blk3 extends uvm_reg_block;
   blk2 b1;

   `uvm_object_utils(blk3)

   function new(string name = "blk3");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      b1 = blk2::type_id::create("mid");
      b1.configure(this);
      b1.build();

      default_map = create_map("", 0, 1, UVM_BIG_ENDIAN);
      default_map.add_submap(b1.default_map, 'h000);
   endfunction
endclass




initial
begin
   int n_warns, p_warns;
   uvm_report_server svr;
   blk3 blk;
   
   svr = _global_reporter.get_report_server();
   
   blk = new("top");
   blk.build();
   
   p_warns = svr.get_severity_count(UVM_WARNING);
   
   $write("Checking get_block_by_name()...\n");   
   begin
      uvm_reg_block b;
      
      b = blk.get_block_by_name("DoesNotExist");
      if (b != null) begin
         `uvm_error("Internal", "Was able to find block \"DoesNotExist\"?!?!?!???.")
      end
      
      n_warns = svr.get_severity_count(UVM_WARNING);
      if (n_warns - p_warns != 1) begin
         `uvm_error("Test", $sformatf("Expected only 1 warning. Got %0d", n_warns - p_warns))
      end
      p_warns = n_warns;
   end

   $write("Checking get_map_by_name()...\n");   
   begin
      uvm_reg_map b;

      b = blk.get_map_by_name("DoesNotExist");
      if (b != null) begin
         `uvm_error("Internal", "Was able to find map \"DoesNotExist\"?!?!?!???.")
      end

      n_warns = svr.get_severity_count(UVM_WARNING);
      if (n_warns - p_warns != 1) begin
         `uvm_error("Test", $sformatf("Expected only 1 warning. Got %0d", n_warns - p_warns))
      end
      p_warns = n_warns;
   end

   $write("Checking get_reg_by_name()...\n");   
   begin
      uvm_reg b;

      b = blk.get_reg_by_name("DoesNotExist");
      if (b != null) begin
         `uvm_error("Internal", "Was able to find reg \"DoesNotExist\"?!?!?!???.")
      end

      n_warns = svr.get_severity_count(UVM_WARNING);
      if (n_warns - p_warns != 1) begin
         `uvm_error("Test", $sformatf("Expected only 1 warning. Got %0d", n_warns - p_warns))
      end
      p_warns = n_warns;
   end

   $write("Checking get_field_by_name()...\n");   
   begin
      uvm_reg_field b;

      b = blk.get_field_by_name("DoesNotExist");
      if (b != null) begin
         `uvm_error("Internal", "Was able to find field \"DoesNotExist\"?!?!?!???.")
      end

      n_warns = svr.get_severity_count(UVM_WARNING);
      if (n_warns - p_warns != 1) begin
         `uvm_error("Test", $sformatf("Expected only 1 warning. Got %0d", n_warns - p_warns))
      end
      p_warns = n_warns;
   end

   $write("Checking get_mem_by_name()...\n");   
   begin
      uvm_mem b;

      b = blk.get_mem_by_name("DoesNotExist");
      if (b != null) begin
         `uvm_error("Internal", "Was able to find mem \"DoesNotExist\"?!?!?!???.")
      end

      n_warns = svr.get_severity_count(UVM_WARNING);
      if (n_warns - p_warns != 1) begin
         `uvm_error("Test", $sformatf("Expected only 1 warning. Got %0d", n_warns - p_warns))
      end
      p_warns = n_warns;
   end

   $write("Checking get_vreg_by_name()...\n");   
   begin
      uvm_vreg b;

      b = blk.get_vreg_by_name("DoesNotExist");
      if (b != null) begin
         `uvm_error("Internal", "Was able to find vreg \"DoesNotExist\"?!?!?!???.")
      end

      n_warns = svr.get_severity_count(UVM_WARNING);
      if (n_warns - p_warns != 1) begin
         `uvm_error("Test", $sformatf("Expected only 1 warning. Got %0d", n_warns - p_warns))
      end
      p_warns = n_warns;
   end

   $write("Checking get_vfield_by_name()...\n");   
   begin
      uvm_vreg_field b;

      b = blk.get_vfield_by_name("DoesNotExist");
      if (b != null) begin
         `uvm_error("Internal", "Was able to find vfield \"DoesNotExist\"?!?!?!???.")
      end
      
      n_warns = svr.get_severity_count(UVM_WARNING);
      if (n_warns - p_warns != 1) begin
         `uvm_error("Test", $sformatf("Expected only 1 warning. Got %0d", n_warns - p_warns))
      end
      p_warns = n_warns;
   end
      
      
   if (svr.get_severity_count(UVM_FATAL) +
       svr.get_severity_count(UVM_ERROR) == 0)
      $write("** UVM TEST PASSED **\n");
   else
      $write("!! UVM TEST FAILED !!\n");

   svr.summarize();
end

endprogram
