//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Mentor Graphics Corporation
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


module dut();

   reg r2;

   initial begin: b1
      reg r1;
   end

endmodule



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


class b1_typ extends uvm_reg_block;
   
   rand r1_typ r1; 
   
   function new(string name = "b1_typ");
      super.new(name,UVM_NO_COVERAGE);
   endfunction
   
   virtual function void build();
      
      r1 = r1_typ::type_id::create("r1");
      r1.configure(this,null,"r1");
      r1.build();
   endfunction
   
   `uvm_object_utils(b1_typ)
   
endclass


class top_blk extends uvm_reg_block;
   
   rand r1_typ r2; 
   rand b1_typ b1; 
   
   function new(string name = "top_blk");
      super.new(name,UVM_NO_COVERAGE);
   endfunction
   
   virtual function void build();
      
      r2 = r1_typ::type_id::create("r2");
      r2.configure(this,null,"r2");
      r2.build();

      b1 = b1_typ::type_id::create("b1");
      b1.configure(this,"b1");
      b1.build();
   endfunction
   
   `uvm_object_utils(top_blk)
   
endclass


initial
begin
   uvm_hdl_path_concat paths[$];
   uvm_hdl_path_slice slice;
   string roots[$];
   
   top_blk model;
   
   model = new("model");
   
   model.build();
   model.set_hdl_path_root("dut");

   begin
      uvm_reg_mem_hdl_paths_seq seq;
      seq = new;
      seq.model = model;
      seq.start(null);
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
