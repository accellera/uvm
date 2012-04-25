//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc.
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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef class phasing_test;


class test extends phasing_test;
  `uvm_component_utils(test)

  int number_of_jumps_requested = 25 ;
  int number_of_jumps_completed = 0 ;
  
  function new(string name="anon", uvm_component parent=null);
    super.new(name,parent);
    uvm_report_info("Test", "Testing correct phase order...");
    predicted_phasing.push_back("new");
    predicted_phasing.push_back("common/build");
    predicted_phasing.push_back("common/connect");
    predicted_phasing.push_back("common/end_of_elaboration");
    predicted_phasing.push_back("common/start_of_simulation");
    predicted_phasing.push_back("common/run");
    predicted_phasing.push_back("uvm/pre_reset");
    predicted_phasing.push_back("uvm/reset");
    predicted_phasing.push_back("uvm/post_reset");
    predicted_phasing.push_back("uvm/pre_configure");
    predicted_phasing.push_back("uvm/configure");
    predicted_phasing.push_back("uvm/post_configure");
    predicted_phasing.push_back("uvm/pre_main");
    predicted_phasing.push_back("uvm/main");

    for (int i = 0; i < number_of_jumps_requested; i++) begin
      // jump(reset_ph)
      predicted_jumps.push_back("main->reset");

      predicted_phasing.push_back("uvm/reset");
      predicted_phasing.push_back("uvm/post_reset");
      predicted_phasing.push_back("uvm/pre_configure");
      predicted_phasing.push_back("uvm/configure");
      predicted_phasing.push_back("uvm/post_configure");
      predicted_phasing.push_back("uvm/pre_main");
      predicted_phasing.push_back("uvm/main");
    end

    predicted_phasing.push_back("uvm/post_main");
    predicted_phasing.push_back("uvm/pre_shutdown"); 
       predicted_phasing.push_back("uvm/shutdown"); 
       predicted_phasing.push_back("uvm/post_shutdown");
    predicted_phasing.push_back("common/extract");
    predicted_phasing.push_back("common/check");
    predicted_phasing.push_back("common/report");
    predicted_phasing.push_back("common/final");
  endfunction

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);
    if (number_of_jumps_completed < number_of_jumps_requested) begin
      number_of_jumps_completed++ ;
      phase.jump(phase.find_by_name("reset"));
    end
    phase.drop_objection(this);
  endtask

endclass


// test base class intended to debug the proper order of phase execution

class phasing_test extends uvm_test;
  static string predicted_phasing[$]; // ordered list of DOMAIN/PHASE strings to check against
  static string audited_phasing[$]; // ordered list of DOMAIN/PHASE strings to check against

  static string predicted_jumps[$];
  static string audited_jumps[$];

  static bit pass = 1;

  static int delta_ready_to_end_vs_ended = 0 ;

  // there should be 1 phase_ready_to_end per phase_ended in this test
  function void phase_ready_to_end(uvm_phase phase);
    if (phase.get_name()=="reset") delta_ready_to_end_vs_ended++ ;
  endfunction
  
  function void phase_ended(uvm_phase phase);
     uvm_phase goto = phase.get_jump_target();
     if (phase.get_name()=="reset") delta_ready_to_end_vs_ended-- ;
     if (goto != null) begin
        audited_jumps.push_back({phase.get_name(),"->",goto.get_name()});
     end
  endfunction
   
  function void audit(string item="");
    if (item != "") begin
      audited_phasing.push_back(item);
      uvm_report_info("Test",$sformatf("- debug: recorded phase %s",item));
    end
  endfunction

  task audit_task(uvm_phase phase, string item="");
    phase.raise_objection(this);
    #10;
    audit(item);
    #10;
    phase.drop_objection(this);
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
        $display("  | %s | %s |     match", predicted, audited);
      else begin
        $display("  | %s | %s | <<< MISMATCH", predicted, audited);
        pass = 0;
      end
    end
    $display("  +-----------------------------+-----------------------------+");


    $display("");
    $display("Checking jumps:");
    $display("  +-----------------------------+-----------------------------+");
    $display("  | Predicted Jump              | Actual Jump                 |");
    $display("  +-----------------------------+-----------------------------+");
    n_phases = predicted_jumps.size();
    if (audited_jumps.size() > n_phases) n_phases = audited_jumps.size();
    for (int i=0; (i < n_phases); i++) begin
      string predicted, audited;
      predicted = (i >= predicted_jumps.size()) ? "" : predicted_jumps[i];
      audited = (i >= audited_jumps.size()) ? "" : audited_jumps[i];
      if (predicted == audited)
        $display("  | %s | %s |     match", predicted, audited);
      else begin
        $display("  | %s | %s | <<< MISMATCH", predicted, audited);
         pass = 0;
      end
    end
    $display("  +-----------------------------+-----------------------------+");

    if (delta_ready_to_end_vs_ended !=0) begin
      $display("MISMATCH: phase_ready_to_end and phase_ended did not execute same number of times for reset phase");
      pass = 0 ;
    end
  endfunction

  function new(string name, uvm_component parent); super.new(name,parent); audit("new"); endfunction
  function void build_phase(uvm_phase phase);    audit("common/build");       endfunction
  function void connect_phase(uvm_phase phase);  audit("common/connect");     endfunction
  function void end_of_elaboration_phase(uvm_phase phase);  audit("common/end_of_elaboration"); endfunction
  function void start_of_simulation_phase(uvm_phase phase); audit("common/start_of_simulation"); endfunction
  task run_phase(uvm_phase phase);               audit_task(phase,"common/run");         endtask
  task pre_reset_phase(uvm_phase phase);         audit_task(phase,"uvm/pre_reset");      endtask
  task reset_phase(uvm_phase phase);             audit_task(phase,"uvm/reset");          endtask
  task post_reset_phase(uvm_phase phase);        audit_task(phase,"uvm/post_reset");     endtask
  task pre_configure_phase(uvm_phase phase);     audit_task(phase,"uvm/pre_configure");  endtask
  task configure_phase(uvm_phase phase);         audit_task(phase,"uvm/configure");      endtask
  task post_configure_phase(uvm_phase phase);    audit_task(phase,"uvm/post_configure"); endtask
  task pre_main_phase(uvm_phase phase);          audit_task(phase,"uvm/pre_main");       endtask
  task main_phase(uvm_phase phase);              audit_task(phase,"uvm/main");           endtask
  task post_main_phase(uvm_phase phase);         audit_task(phase,"uvm/post_main");      endtask
  task pre_shutdown_phase(uvm_phase phase);      audit_task(phase,"uvm/pre_shutdown");   endtask
  task shutdown_phase(uvm_phase phase);          audit_task(phase,"uvm/shutdown");       endtask
  task post_shutdown_phase(uvm_phase phase);     audit_task(phase,"uvm/post_shutdown");  endtask
  function void extract_phase(uvm_phase phase);  audit("common/extract");     endfunction
  function void check_phase(uvm_phase phase);    audit("common/check");       endfunction
  function void report_phase(uvm_phase phase);   audit("common/report");      endfunction
  function void final_phase(uvm_phase phase); audit("common/final");    endfunction
endclass


initial begin
  uvm_top.finish_on_completion = 0;
  run_test();
  phasing_test::check_phasing();
  begin
    uvm_report_server svr;
    svr = _global_reporter.get_report_server();
    svr.summarize();
    if (phasing_test::pass &&
        (svr.get_severity_count(UVM_FATAL) +
         svr.get_severity_count(UVM_ERROR) == 0))
      $write("** UVM TEST PASSED **\n");
    else
      $write("!! UVM TEST FAILED !!\n");
  end
end


endprogram
