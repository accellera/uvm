//---------------------------------------------------------------------- 
//   Copyright 2010 Cadence Design Systems, Inc. 
//   Copyright 2011 Mentor Graphics Corporation
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

// This test checks that a id specific severity overrides work.
// For this test, all of the override ids have _OVR as part of
// the name, and all non-overrides do not.
//
// This test is identical to the 02idspec test, except it uses
// the new uvm_report generic method to send the messages

`define test_report(SEVERITY,ID,MSG,VERBOSITY) \
begin \
  if (uvm_report_enabled(VERBOSITY,SEVERITY,ID)) \
    uvm_report(SEVERITY,ID,MSG,VERBOSITY, `uvm_file, `uvm_line); \
end

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

bit pass = 1;

class sev_id_pair;
  uvm_severity sev;
  string id;
  function new(uvm_severity sev, string id);
    this.sev = sev;
    this.id = id;
  endfunction
endclass

class my_catcher extends uvm_report_catcher;
   int sev[sev_id_pair];
   sev_id_pair p;

   virtual function action_e catch();
      string s_str;
      string exp_sev;
      uvm_coreservice_t cs_;
      cs_ = uvm_coreservice_t::get();

      // Ignore messages from root
      if(get_client() == cs_.get_root())
        return THROW;

      p = new(uvm_severity'(get_severity()), get_id());
      
      sev[p] ++;

      $display("GOT MESSAGE %0s WITH SEVERITY %0s AND EXPECTED SEVERITY %0s",p.id, p.sev.name(), get_message());

      exp_sev = get_message();
    
      if(p.sev.name() != exp_sev) begin
        $display("**** UVM_TEST FAILED EXPECTED SEVERITY %0s GOT %0s ****", exp_sev, p.sev.name());
        pass = 0; 
      end

      return CAUGHT;
   endfunction
endclass

class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   my_catcher ctchr = new;
   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      uvm_report_cb::add(null,ctchr);

      // Set severities to INFO and then do a couple of messages of each type
      set_id_severities("id1", UVM_INFO);
      try_severities("id1", "UVM_INFO");

      #15;
      // Set severities to WARNING and then do a couple of messages of each type
      set_id_severities("id2", UVM_WARNING);
      try_severities("id2", "UVM_WARNING");
      
      #10;
      // Set severities to ERROR and then do a couple of messages of each type
      set_id_severities("id1", UVM_ERROR);
      try_severities("id1", "UVM_ERROR");

      #10;
      // Set severities to FATAL and then do a couple of messages of each type
      set_id_severities("id1", UVM_FATAL);
      try_severities("id1", "UVM_FATAL");

      phase.drop_objection(this);
   endtask

   virtual function void report();
      if(ctchr.sev.num() != 32) begin
        $display("*** UVM TEST FAILED Expected to catch eight different severity/id pairs, but got %0d instead ***", ctchr.sev.num());
        pass = 0;
      end
      foreach(ctchr.sev[i])
         if(ctchr.sev[i] != 1) begin
            sev_id_pair p = i;
            $display("*** UVM TEST FAILED Expected to catch 1 messages of type {%s,%s}, but got %0d instead ***", p.sev.name(), p.id, ctchr.sev[i]);
            pass = 0;
         end

      if (pass) $write("** UVM TEST PASSED **\n");
   endfunction

   function void set_id_severities(string id, uvm_severity sev);
     set_report_severity_id_override(UVM_INFO, {"INFO_",id}, sev);
     set_report_severity_id_override(UVM_WARNING, {"WARNING_",id}, sev);
     set_report_severity_id_override(UVM_ERROR, {"ERROR_",id}, sev);
     set_report_severity_id_override(UVM_FATAL, {"FATAL_",id}, sev);
   endfunction

   function void try_severities(string id, string sev);
     //For each type, there is one that will be overridden and one that will be
     //untouched. The message string is the expected verbosity of the message.
     `test_report(UVM_INFO,{"INFO_",id}, sev, UVM_NONE)
     `test_report(UVM_INFO,{"INFO_",id,"_SAFE"}, "UVM_INFO", UVM_NONE)
     `test_report(UVM_WARNING,{"WARNING_",id}, sev, UVM_NONE)
     `test_report(UVM_WARNING,{"WARNING_",id,"_SAFE"}, "UVM_WARNING", UVM_NONE)
     `test_report(UVM_ERROR,{"ERROR_",id}, sev, UVM_NONE)
     `test_report(UVM_ERROR,{"ERROR_",id,"_SAFE"}, "UVM_ERROR", UVM_NONE)
     `test_report(UVM_FATAL,{"FATAL_",id}, sev, UVM_NONE)
     `test_report(UVM_FATAL,{"FATAL_",id,"_SAFE"}, "UVM_FATAL", UVM_NONE)
   endfunction
endclass


initial
  begin
     run_test();
  end

endmodule
