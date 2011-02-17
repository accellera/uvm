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

// This test checks that a generic severity override, INFO->WARNING,
// for example, works and can later be replaced back.

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

// From time 0 to 10 all messages should be INFO
// From time 10 to 20 all messages should be WARNING
// From time 20 to 30 all messages should be ERROR
// From time 30 to 40 all messages should be FATAL

bit pass = 1;
class my_catcher extends uvm_report_catcher;
   int sev[uvm_severity_type];
   uvm_severity_type s;

   virtual function action_e catch(); 
      s = uvm_severity_type'(get_severity());

      // Ignore messages from root component
      if(get_client() == uvm_root::get())
        return THROW;
 
      sev[s] ++;
      $display("%0t: got severity %s for id %s", $time, s.name(), get_id());
      if($time <10) begin
        if(s != UVM_INFO) begin
          $display("*** UVM TEST FAILED expected UVM_INFO but got %s", s.name());
          pass=0;
        end
      end
      else if($time <20) begin
        if(s != UVM_WARNING) begin
          $display("*** UVM TEST FAILED expected UVM_WARNING but got %s", s.name());
          pass=0;
        end
      end
      else if($time <30) begin
        if(s != UVM_ERROR) begin
          $display("*** UVM TEST FAILED expected UVM_ERROR but got %s", s.name());
          pass=0;
        end
      end
      else if($time <40) begin
        // Ignore the stop request info
        if(s != UVM_FATAL) begin
          $display("*** UVM TEST FAILED expected UVM_FATAL but got %s", s.name());
          pass=0;
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

   my_catcher ctchr = new;

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      uvm_report_cb::add(null,ctchr);

      // Set severities to INFO and then do a couple of messages of each type
      set_all_severities(UVM_INFO);
      try_all_severities();

      #15;
      // Set severities to WARNING and then do a couple of messages of each type
      set_all_severities(UVM_WARNING);
      try_all_severities();
      
      #10;
      // Set severities to ERROR and then do a couple of messages of each type
      set_all_severities(UVM_ERROR);
      try_all_severities();

      #10;
      // Set severities to FATAL and then do a couple of messages of each type
      set_all_severities(UVM_FATAL);
      try_all_severities();

      phase.drop_objection(this);
   endtask

   virtual function void report();
      if(ctchr.sev.num() != 4) begin
        $display("*** UVM TEST FAILED Expected to catch four different severities, but got %0d instead ***", ctchr.sev.num());
        pass = 0;
      end
      foreach(ctchr.sev[i])
         if(ctchr.sev[i] != 8) begin
            uvm_severity_type s = i;
            $display("*** UVM TEST FAILED Expected to catch 8 messages of type %s, but got %0d instead ***", s.name(), ctchr.sev[i]);
            pass = 0;
         end

      if (pass) $write("** UVM TEST PASSED **\n");
   endfunction

   function void set_all_severities(uvm_severity_type sev);
     set_report_severity_override(UVM_INFO, sev);
     set_report_severity_override(UVM_WARNING, sev);
     set_report_severity_override(UVM_ERROR, sev);
     set_report_severity_override(UVM_FATAL, sev);
   endfunction
   function void try_all_severities();
     `uvm_info("INFO1", "first info message", UVM_NONE)
     `uvm_warning("WARNING1", "first warning message")
     `uvm_error("ERROR1", "first error message")
     `uvm_fatal("FATAL1", "first fatal message")
     `uvm_info("INFO2", "second info message", UVM_NONE)
     `uvm_warning("WARNING2", "second warning message")
     `uvm_error("ERROR2", "second error message")
     `uvm_fatal("FATAL2", "second fatal message")
   endfunction
endclass


initial
  begin
     run_test();
  end

endmodule
