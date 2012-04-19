//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc. 
//   Copyright 2010-2011 Mentor Graphics Corporation
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


program top;

import uvm_pkg::*;

class c;
   int i;

   function string convert2string();
      return $sformatf("%0d", i);
   endfunction

   function bit compare(c  rhs);
      return i == rhs.i;
   endfunction

   function void copy(c  rhs);
      rhs.i = i;
   endfunction
endclass

initial
begin
   uvm_in_order_class_comparator#(c) sb;

   uvm_analysis_port#(c) exp;
   uvm_analysis_port#(c) obs;
   int v[10];

   v = '{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

   exp = new("exp", null);
   obs = new("obs", null);

   fork
      foreach (v[i]) begin
         c e;
         e = new();
         e.i = v[i];
         exp.write(e);
      end
   join_none

   #10;
   foreach (v[i]) begin
      c o;
      o = new();
      o.i = v[i];
      obs.write(o);
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
