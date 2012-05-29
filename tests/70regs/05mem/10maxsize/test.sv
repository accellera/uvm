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

class mem extends uvm_mem;

   function new(string name = "mem");
      super.new(name,256, 65);
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

      lock_model();
   endfunction
endclass


class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   virtual function action_e catch();
      string txt = get_message();

      if (get_severity() == UVM_FATAL &&
          get_id() == "RegModel") begin
         txt = txt.substr(29,46);
         $write(">>%s<<\n", txt);
         if (txt == "UVM_REG_DATA_WIDTH") begin
            seen++;
            set_severity(UVM_WARNING);
            set_action(UVM_DISPLAY);
            return THROW;
         end
      end
      return THROW;
   endfunction
endclass


initial
begin
   blk b;my_catcher c;
   b = new;

   c = new;
   uvm_report_cb::add(null, c);

   b.build();
   
   if (my_catcher::seen != 1) begin
      `uvm_error("Test", "Fatal message about invalid UVM_REG_DATA_WIDTH value not seen");
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
