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


module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

// This test checks for two modes of the name change:
//   1. a component uses only the old OVM phase names
//   2. a component uses the new phase names but extends from one which uses
//      the old names.

// base class uses old OVM style names for the common phases. These all need to
// executed even though the extended class is using the new phase names.

class base extends uvm_test;

   static int n_ph = 0;

   `uvm_component_utils(base)

   string last_phase = "";

   function void check_the_phase(string prev, string curr);
      `uvm_info("Test", $psprintf("Executing phase \"%s\"...", curr), UVM_LOW)
      if (prev != last_phase) begin
`uvm_error("Test", $psprintf("Phase before \"%s\" was \"%s\" instead of \"%s\".",
                             curr, last_phase, prev));
      end
      last_phase = curr;
      n_ph++;
   endfunction
   
   task check_the_phase_t(string prev, string curr);
      `uvm_info("Test", $psprintf("Starting phase \"%s\"...", curr), UVM_LOW)
      #10;
      if (prev != last_phase) begin
`uvm_error("Test", $psprintf("Previous phase was \"%s\" instead of \"%s\".",
                             last_phase, prev));
      end
      #10;
      last_phase = curr;
      `uvm_info("Test", $psprintf("Ending phase \"%s\"...", curr), UVM_LOW)
      n_ph++;
      global_stop_request();
   endtask

   function new(string name = "my_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void build();
      check_the_phase("", "build");
   endfunction
   
   function void connect();
      check_the_phase("build", "connect");
   endfunction
   
   function void end_of_elaboration();
      check_the_phase("connect", "end_of_elaboration");
   endfunction
   
   function void start_of_simulation();
      check_the_phase("end_of_elaboration", "start_of_simulation");
   endfunction
   
   task run();
      check_the_phase_t("start_of_simulation", "run");
   endtask
   
   function void extract();
      check_the_phase("run", "extract");
   endfunction

   function void check();
      check_the_phase("extract", "check");
   endfunction

   function void report();
      check_the_phase("check", "report");
   endfunction

   function void finalize_phase();
      check_the_phase("report", "finalize");
   endfunction
endclass

// Extended class uses the new names

class test extends base;
   base b;  //extends one component that just uses the old style
   `uvm_component_utils(test)

   function new(string name = "my_comp", uvm_component parent = null);
      super.new(name, parent);
      b = new("b", this);
   endfunction

   function void build_phase();
      super.build_phase();
   endfunction
   
   function void connect_phase();
      super.connect_phase();
   endfunction
   
   function void end_of_elaboration_phase();
      super.end_of_elaboration_phase();
   endfunction
   
   function void start_of_simulation_phase();
      super.start_of_simulation_phase();
   endfunction
   
   task run_phase();
      super.run_phase();
   endtask
   
   function void extract_phase();
      super.extract_phase();
   endfunction

   function void check_phase();
      super.check_phase();
   endfunction

   function void report_phase();
      super.report_phase();
   endfunction

   function void finalize_phase();
      super.finalize_phase();
   endfunction
endclass

initial
begin
   uvm_top.finish_on_completion = 0;
   `uvm_info("Test", "Phasing one component common phases...", UVM_NONE);
   
   run_test();

   begin
      test t;
      $cast(t, uvm_top.find("uvm_test_top"));
      if (t.last_phase != "finalize") begin
         `uvm_error("Test", $psprintf("Last phase was \"%s\" instead of \"finalize\".",
                                      t.last_phase));
      end
   end
  
   // 9 phases for each of the components
   if (test::n_ph != 18) begin
      `uvm_error("Test", $psprintf("A total of %0d phase methods were executed instead of 18.",
                                   base::n_ph));
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

endmodule
