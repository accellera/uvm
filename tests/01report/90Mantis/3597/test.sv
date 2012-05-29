//---------------------------------------------------------------------- 
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

class demote extends uvm_report_catcher;
   function new();
      super.new("demote");
   endfunction
   
   virtual function action_e catch();
      if (get_severity() == UVM_INFO) set_severity(UVM_ERROR);
      else if (get_severity() == UVM_WARNING) set_severity(UVM_FATAL);
      else set_severity(UVM_INFO);
      return THROW;
   endfunction
endclass


class demote_react extends uvm_report_catcher;
   function new();
      super.new("demote_react");
   endfunction

   virtual function action_e catch();
      if (get_severity() == UVM_INFO) set_severity(UVM_ERROR);
      else if (get_severity() == UVM_WARNING) set_severity(UVM_FATAL);
      else set_severity(UVM_INFO);
      set_action(UVM_NO_ACTION);
      return THROW;
   endfunction
endclass


class react_demote extends uvm_report_catcher;
   function new();
      super.new("react_demote");
   endfunction

   virtual function action_e catch();
      set_action(UVM_NO_ACTION);
      if (get_severity() == UVM_INFO) set_severity(UVM_ERROR);
      else if (get_severity() == UVM_WARNING) set_severity(UVM_FATAL);
      else set_severity(UVM_INFO);
      return THROW;
   endfunction
endclass


class do_check extends uvm_report_catcher;
   static uvm_severity sev;
   static bit react;

   function new();
      super.new("do_check");
   endfunction

   virtual function action_e catch();

      if (sev == UVM_INFO) begin // Was set to ERROR
         if (react) begin
            if (get_action != UVM_NO_ACTION) begin
               `uvm_error("Test",
                          $sformatf("Specific action in promoted UVM_INFO is not as expected: 'b%b",
                                    get_action()))
            end
         end
         else begin
            if (get_action != (UVM_DISPLAY | UVM_COUNT)) begin
               `uvm_error("Test",
                          $sformatf("Default action in promoted UVM_INFO is not as expected: 'b%b",
                                    get_action()))
            end
         end
      end
            
      if (sev == UVM_WARNING) begin // Was set to FATAL
         if (react) begin
            if (get_action != UVM_NO_ACTION) begin
               `uvm_error("Test",
                          $sformatf("Specific action in promoted UVM_WARNING is not as expected: 'b%b",
                                    get_action()))
            end
         end
         else begin
            if (get_action != (UVM_DISPLAY | UVM_EXIT)) begin
               `uvm_error("Test",
                          $sformatf("Default action in promoted UVM_WARNING is not as expected: 'b%b",
                                    get_action()))
            end
         end
      end
            
      if (sev == UVM_ERROR) begin
         if (react) begin
            if (get_action != UVM_NO_ACTION) begin
               `uvm_error("Test",
                          $sformatf("Specific action in demoted UVM_ERROR is not as expected: 'b%b",
                                    get_action()))
            end
         end
         else begin
            if (get_action != UVM_DISPLAY) begin
               `uvm_error("Test",
                          $sformatf("Default action in demoted UVM_ERROR is not as expected: 'b%b",
                                    get_action()))
            end
         end
      end
            
      if (sev == UVM_FATAL) begin
         if (react) begin
            if (get_action != UVM_NO_ACTION) begin
               `uvm_error("Test",
                          $sformatf("Specific action in demoted UVM_FATAL is not as expected: 'b%b",
                                    get_action()))
            end
         end
         else begin
            if (get_action != UVM_DISPLAY) begin
               `uvm_error("Test",
                          $sformatf("Default action in demoted UVM_FATAL is not as expected: 'b%b",
                                    get_action()))
            end
         end
      end

      return CAUGHT;
   endfunction
endclass


class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
      demote d = new;
      demote_react dr = new;
      react_demote rd = new;
      do_check ch = new;

      phase.raise_objection(this);

      uvm_report_cb::add(null, ch);

      $write("Do_checking simple demotion...\n");

      uvm_report_cb::add(null, d, UVM_PREPEND);
      do_check::sev = UVM_INFO;
      `uvm_info("demote", "This is a note", UVM_NONE)
      do_check::sev = UVM_WARNING;
      `uvm_warning("demote", "This is a warning")
      do_check::sev = UVM_ERROR;
      `uvm_error("demote", "This is an error")
      do_check::sev = UVM_FATAL;
      `uvm_fatal("demote", "This is a fatal")
      uvm_report_cb::delete(null, d);
      
      $write("Do_checking demotion followed by action...\n");

      do_check::react = 1;
      
      uvm_report_cb::add(null, dr, UVM_PREPEND);
      do_check::sev = UVM_INFO;
      `uvm_info("demote", "This is a note", UVM_NONE)
      do_check::sev = UVM_WARNING;
      `uvm_warning("demote", "This is a warning")
      do_check::sev = UVM_ERROR;
      `uvm_error("demote", "This is an error")
      do_check::sev = UVM_FATAL;
      `uvm_fatal("demote", "This is a fatal")
      uvm_report_cb::delete(null, dr);
      
      $write("Do_checking action followed by demotion...\n");
      uvm_report_cb::add(null, rd, UVM_PREPEND);
      do_check::sev = UVM_INFO;
      `uvm_info("demote", "This is a note", UVM_NONE)
      do_check::sev = UVM_WARNING;
      `uvm_warning("demote", "This is a warning")
      do_check::sev = UVM_ERROR;
      `uvm_error("demote", "This is an error")
      do_check::sev = UVM_FATAL;
      `uvm_fatal("demote", "This is a fatal")
      uvm_report_cb::delete(null, rd);
      
      uvm_report_cb::delete(null, ch);
      
      phase.drop_objection(this);
   endtask


   function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass


initial run_test("test");

endprogram
