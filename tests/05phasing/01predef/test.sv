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

class test extends uvm_test;

   static int n_ph = 0;

   `uvm_component_utils(test)

   string last_phase = "";

   function void check_phase(string prev, string curr);
      `uvm_info("Test", $psprintf("Executing phase \"%s\"...", curr), UVM_LOW)
      if (prev != last_phase) begin
`uvm_error("Test", $psprintf("Phase before \"%s\" was \"%s\" instead of \"%s\".",
                             curr, last_phase, prev));
      end
      last_phase = curr;
      n_ph++;
   endfunction
   
   task check_phase_t(string prev, string curr);
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
   endtask

   function new(string name = "my_comp", uvm_component parent = null);
      super.new(name, parent);
      set_phase_domain("uvm");
   endfunction

   function void build();
      check_phase("", "build");
   endfunction
   
   function void connect();
      check_phase("build", "connect");
   endfunction
   
   function void end_of_elaboration();
      check_phase("connect", "end_of_elaboration");
   endfunction
   
   function void start_of_simulation();
      check_phase("end_of_elaboration", "start_of_simulation");
   endfunction
   
   task run();
      check_phase_t("start_of_simulation", "run");
   endtask
   
   task pre_reset();
      check_phase_t("start_of_simulation", "pre_reset");
      // Make sure the last phase is not "run"
      #10;
      last_phase = "pre_reset";
   endtask
   
   task reset();
      check_phase_t("pre_reset", "reset");
   endtask
   
   task post_reset();
      check_phase_t("reset", "post_reset");
   endtask
   
   task pre_configure();
      check_phase_t("post_reset", "pre_configure");
   endtask
   
   task configure();
      check_phase_t("pre_configure", "configure");
   endtask
   
   task post_configure();
      check_phase_t("configure", "post_configure");
   endtask
   
   task pre_main();
      check_phase_t("post_configure", "pre_main");
   endtask
   
   task main();
      check_phase_t("pre_main", "main");
   endtask
   
   task post_main();
      check_phase_t("main", "post_main");
   endtask
   
   task pre_shutdown();
      check_phase_t("post_main", "pre_shutdown");
   endtask
   
   task shutdown();
      check_phase_t("pre_shutdown", "shutdown");
   endtask
   
   task post_shutdown();
      check_phase_t("shutdown", "post_shutdown");
   endtask
   
   function void extract();
      check_phase("post_shutdown", "extract");
   endfunction
   
   function void check();
      check_phase("extract", "check");
   endfunction
   
   function void report();
      check_phase("check", "report");
   endfunction
   
   function void finalize();
      check_phase("report", "finalize");
   endfunction
   
endclass

initial
begin
   `uvm_info("Test", "Phasing one component through default phases...", UVM_NONE);
   
   run_test();

   begin
      test t;
      $cast(t, uvm_top.find("uvm_test_top"));
      if (t.last_phase != "finalize") begin
         `uvm_error("Test", $psprintf("Last phase was \"%s\" instead of \"finalize\".",
                                      t.last_phase));
      end
   end
   
   if (test::n_ph != 21) begin
      `uvm_error("Test", $psprintf("A total of %0d phase methods were executed instead of 21.",
                                   test::n_ph));
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
