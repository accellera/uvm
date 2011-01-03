//---------------------------------------------------------------------- 
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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef class phasing_test;


class test extends phasing_test;
  `uvm_component_utils(test)
  function new(string name="anon", uvm_component parent=null);
    super.new(name,parent);
    uvm_report_info("Test", "Testing correct phase order...");
    predicted_phasing = { "new",
                          "common/build",
                          "common/connect",
                          "common/end_of_elaboration",
                          "common/start_of_simulation",
                          "common/run",
                          "uvm/pre_reset", "uvm/reset", "uvm/post_reset",
                          "uvm/pre_configure", "uvm/configure", "uvm/post_configure",
                          "uvm/pre_main", "uvm/main", "uvm/post_main",
                          "uvm/pre_shutdown", "uvm/shutdown", "uvm/post_shutdown",
                          "common/extract",
                          "common/check",
                          "common/report",
                          "common/finalize"
                          };
    set_phase_domain("uvm");
  endfunction
endclass


// test base class intended to debug the proper order of phase execution

class phasing_test extends uvm_test;
  static string predicted_phasing[$]; // ordered list of DOMAIN/PHASE strings to check against
  static string audited_phasing[$]; // ordered list of DOMAIN/PHASE strings to check against

  function void audit(string item="");
    if (item != "") begin
      audited_phasing.push_back(item);
      uvm_report_info("Test",$sformatf("- debug: recorded phase %s",item));
    end
  endfunction

  task audit_task(string item="");
    #10;
    audit(item);
    #10;
  endtask

  static function void check_phasing();
    integer n_phases;
    $display("");
    $display("Checking predicted order or phase execution:");
    $display("  +-----------------------------+-----------------------------+");
    $display("  | Predicted Phase             | Actual Phase                |");
    $display("  +-----------------------------+-----------------------------+");
    n_phases = predicted_phasing.size();
    if (audited_phasing.size() > n_phases) n_phases = audited_phasing.size();
    for (int i=0; (i < n_phases); i++) begin
      string predicted, audited;
      predicted = (i >= predicted_phasing.size()) ? "" : predicted_phasing[i];
      audited = (i >= audited_phasing.size()) ? "" : audited_phasing[i];
      if (predicted == audited)
        $display("  | %-27s | %-27s |     match", predicted, audited);
      else
        $display("  | %-27s | %-27s | <<< MISMATCH", predicted, audited);
    end
    $display("  +-----------------------------+-----------------------------+");
  endfunction

  function new(string name, uvm_component parent); super.new(name,parent); audit("new"); endfunction
  function void build();    audit("common/build");       endfunction
  function void connect();  audit("common/connect");     endfunction
  function void end_of_elaboration();  audit("common/end_of_elaboration"); endfunction
  function void start_of_simulation(); audit("common/start_of_simulation"); endfunction
  task run();               audit_task("common/run");         endtask
  task pre_reset();         audit_task("uvm/pre_reset");      endtask
  task reset();             audit_task("uvm/reset");          endtask
  task post_reset();        audit_task("uvm/post_reset");     endtask
  task pre_configure();     audit_task("uvm/pre_configure");  endtask
  task configure();         audit_task("uvm/configure");      endtask
  task post_configure();    audit_task("uvm/post_configure"); endtask
  task pre_main();          audit_task("uvm/pre_main");       endtask
  task main();              audit_task("uvm/main");           endtask
  task post_main();         audit_task("uvm/post_main");      endtask
  task pre_shutdown();      audit_task("uvm/pre_shutdown");   endtask
  task shutdown();          audit_task("uvm/shutdown");       endtask
  task post_shutdown();     audit_task("uvm/post_shutdown");  endtask
  function void extract();  audit("common/extract");     endfunction
  function void check();    audit("common/check");       endfunction
  function void report();   audit("common/report");      endfunction
  function void finalize(); audit("common/finalize");    endfunction
endclass


initial begin
  uvm_top.finish_on_completion = 0;
  run_test();
  phasing_test::check_phasing();
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
