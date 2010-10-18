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


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class r1_typ extends uvm_reg;

   function new(string name = "r1_typ");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
   endfunction
   
   `uvm_object_utils(r1_typ)
   
endclass


class b1_typ extends uvm_reg_mem_block;

   rand r1_typ r1; 

   function new(string name = "b1_typ");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      r1 = r1_typ::type_id::create("r1");
      r1.build();
      r1.configure(this,null,"r1");
   endfunction
   
   `uvm_object_utils(b1_typ)
   
endclass


class top_blk extends uvm_reg_mem_block;

   rand b1_typ b1; 

   function new(string name = "top_blk");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      b1 = b1_typ::type_id::create("b1");
      b1.build();
      b1.configure(this,"b1");
   endfunction
   
   `uvm_object_utils(top_blk)
   
endclass


function void check_roots(string name,
                          string roots[$],
                          string exp[]);
   $write("Path(s) to %s:\n", name);
   foreach (roots[i]) begin
      $write("   %s\n", roots[i]);
      if (roots[i] != exp[i]) begin
         `uvm_error("ROOTS", $psprintf(" Root does not match \"%s\".", exp[i]));
      end
   end
   
endfunction


function void check_paths(string name,
                          uvm_hdl_path_concat paths[$],
                          uvm_hdl_path_concat exp[]);
   $write("Path(s) to %s:\n", name);
   foreach (paths[i]) begin
      uvm_hdl_path_concat slices;
      uvm_hdl_path_concat exp_sl;

      slices = paths[i];
      exp_sl = exp[i];

      $write("   %s\n", uvm_hdl_concat2string(slices));
      foreach (slices[j]) begin
         if (slices[i].path != exp_sl[j].path) begin
            `uvm_error("PATHS", $psprintf(" Path does not match \"%s\".", exp_sl[j].path));
         end
      end
   end
   
endfunction


initial
begin
   uvm_hdl_path_concat paths[$];
   uvm_hdl_path_slice  slice;
   string roots[$];
   
   top_blk regmem = new("regmem");
   
   regmem.build();
   regmem.set_hdl_path_root("$root.dut");

   regmem.b1.get_full_hdl_path(roots);
   check_roots("regmem.b1", roots, '{"$root.dut.b1"});

   regmem.b1.r1.get_full_hdl_path(paths);
   check_paths("regmem.b1.r1", paths,'{ '{ '{"$root.dut.b1.r1", -1, -1} } });

   begin
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      svr.summarize();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_NOT_OK) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
end

endprogram
