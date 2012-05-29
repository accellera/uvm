//
//------------------------------------------------------------------------------
//   Copyright 2012 Synopsys
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
//------------------------------------------------------------------------------

module top;
import uvm_pkg::*;
`include "uvm_macros.svh"

class my_catcher extends uvm_report_catcher;
   function new(string name);
      super.new(name);
   endfunction

   function action_e catch();
      return THROW;
   endfunction
endclass

initial begin
   my_catcher ct;
   uvm_root top;
   top = uvm_root::get();
   
   `uvm_info("TEST", "Checking global catchers with same name...warning expected", UVM_NONE)
   ct = new("A");
   uvm_report_cb::add(null, ct);
   ct = new("A");
   uvm_report_cb::add(null, ct);
   
   `uvm_info("TEST", "Checking instance catchers with same name...warning expected", UVM_NONE)
   ct = new("B");
   uvm_report_cb::add(top, ct);
   ct = new("B");
   uvm_report_cb::add(top, ct);

   `uvm_info("TEST", "Checking global+instance catchers with same name...warning expected", UVM_NONE)
   ct = new("C");
   uvm_report_cb::add(null, ct);
   ct = new("C");
   uvm_report_cb::add(top, ct);

   `uvm_info("TEST", "Checking instance+global catchers with same name...warning expected", UVM_NONE)
   ct = new("D");
   uvm_report_cb::add(top, ct);
   ct = new("D");
   uvm_report_cb::add(null, ct);

   begin
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();
      
      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0 &&
          svr.get_severity_count(UVM_WARNING) == 4)
         $write("** UVM TEST PASSED! **\n");
      else
         $write("** UVM TEST FAILED! **\n");

      svr.summarize();
   end
end
endmodule
