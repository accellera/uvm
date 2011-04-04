//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc. 
//   Copyright 2010-2011 Mentor Graphics Corporation
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

  // This test verifies that the new phase names do not conflict with
  // basic user names like reset, configure, main and shutdown.
  //
  // The user derived class uses these names but with arg values and
  // verifies that they are never called but that the basic phases
  // are called.

import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_test;

   static int n_ph = 0;
   static int n_called = 0;

   `uvm_component_utils(test)

   string last_phase = "";

   // Some user task names that are not phase tasks.
   task reset (string reset_type="SOFT");
      n_called ++;
   endtask

   task configure(int arg);
     n_called++;
   endtask

   task main;
     n_called++;
   endtask

   task shutdown(int arg1, int arg2);
     n_called++;
   endtask

   // Testing the basic phases

   function void check_the_phase(string prev, string curr);
      `uvm_info("Test", $sformatf("Executing phase \"%s\"...", curr), UVM_LOW)
      if (prev != last_phase) begin
`uvm_error("Test", $sformatf("Phase before \"%s\" was \"%s\" instead of \"%s\".",
                             curr, last_phase, prev));
      end
      last_phase = curr;
      n_ph++;
   endfunction
   
   task check_the_phase_t(string prev, string curr, uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("Test", $sformatf("Starting phase \"%s\"...", curr), UVM_LOW)
      #10;
      if (prev != last_phase) begin
`uvm_error("Test", $sformatf("Previous phase was \"%s\" instead of \"%s\".",
                             last_phase, prev));
      end
      #10;
      last_phase = curr;
      `uvm_info("Test", $sformatf("Ending phase \"%s\"...", curr), UVM_LOW)
      n_ph++;
      phase.drop_objection(this);
   endtask

   function new(string name = "my_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      check_the_phase("", "build");
   endfunction
   
   function void connect_phase(uvm_phase phase);
      check_the_phase("build", "connect");
   endfunction
   
   function void end_of_elaboration_phase(uvm_phase phase);
      check_the_phase("connect", "end_of_elaboration");
   endfunction
   
   function void start_of_simulation_phase(uvm_phase phase);
      check_the_phase("end_of_elaboration", "start_of_simulation");
   endfunction
   
   task run_phase(uvm_phase phase);
      check_the_phase_t("start_of_simulation", "run",phase);
   endtask
   
   task pre_reset_phase(uvm_phase phase);
      check_the_phase_t("start_of_simulation", "pre_reset",phase);
      // Make sure the last phase is not "run"
      #10;
      last_phase = "pre_reset";
   endtask
   
   task reset_phase(uvm_phase phase);
      check_the_phase_t("pre_reset", "reset",phase);
   endtask
   
   task post_reset_phase(uvm_phase phase);
      check_the_phase_t("reset", "post_reset",phase);
   endtask
   
   task pre_configure_phase(uvm_phase phase);
      check_the_phase_t("post_reset", "pre_configure",phase);
   endtask
   
   task configure_phase(uvm_phase phase);
      check_the_phase_t("pre_configure", "configure",phase);
   endtask
   
   task post_configure_phase(uvm_phase phase);
      check_the_phase_t("configure", "post_configure",phase);
   endtask
   
   task pre_main_phase(uvm_phase phase);
      check_the_phase_t("post_configure", "pre_main",phase);
   endtask
   
   task main_phase(uvm_phase phase);
      check_the_phase_t("pre_main", "main",phase);
   endtask
   
   task post_main_phase(uvm_phase phase);
      check_the_phase_t("main", "post_main",phase);
   endtask
   
   task pre_shutdown_phase(uvm_phase phase);
      check_the_phase_t("post_main", "pre_shutdown",phase);
   endtask
   
   task shutdown_phase(uvm_phase phase);
      check_the_phase_t("pre_shutdown", "shutdown",phase);
   endtask
   
   task post_shutdown_phase(uvm_phase phase);
      check_the_phase_t("shutdown", "post_shutdown",phase);
   endtask
   
   function void extract_phase(uvm_phase phase);
      check_the_phase("post_shutdown", "extract");
   endfunction
   
   function void check_phase(uvm_phase phase);
      check_the_phase("extract", "check");
   endfunction
   
   function void report_phase(uvm_phase phase);
      check_the_phase("check", "report");
   endfunction
   
   function void final_phase(uvm_phase phase);
      check_the_phase("report", "final");
   endfunction
   
endclass

initial
begin
   uvm_top.finish_on_completion = 0;
   `uvm_info("Test", "Phasing one component through default phases...", UVM_NONE);
   
   run_test();

   begin
      test t;
      $cast(t, uvm_top.find("uvm_test_top"));
      if (t.last_phase != "final") begin
         `uvm_error("Test", $sformatf("Last phase was \"%s\" instead of \"final\".",
                                      t.last_phase));
      end
   end
   
   if (test::n_called != 0) begin
      `uvm_error("Test", $sformatf("Expected no user tasks to get called, but %0d were",
                                   test::n_called));
   end
   
   if (test::n_ph != 21) begin
      `uvm_error("Test", $sformatf("A total of %0d phase methods were executed instead of 21.",
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

endmodule
