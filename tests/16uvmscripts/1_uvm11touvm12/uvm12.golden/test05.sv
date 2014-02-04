//---------------------------------------------------------------------- 
//   Copyright 2010 Cadence Design Systems, Inc.
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

// This test creates a simple hierarchy where three leaf cells belong
// to three different domains. The environment puts the three
// domains into lockstep to make sure they are phased together.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"



class cb_demote extends uvm_report_catcher;
   static int seen = 0;

   virtual function action_e catch();
      if (get_id() == "Connection Error" && get_severity() == UVM_ERROR) begin
         set_severity(UVM_WARNING);
         set_action(UVM_DISPLAY);
         seen++;
      end
      return THROW;
   endfunction
endclass

class req extends uvm_sequence_item ;
  endclass

  class monitor extends uvm_component ;    
    uvm_analysis_port #(req) rst_mon_port;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      rst_mon_port = new("rst_mon_port",this);
    endfunction
  endclass

  class agent extends uvm_component ;
    monitor m_mon ;
    uvm_analysis_port #(req) rst_mon_port;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      rst_mon_port = new("rst_mon_port",this);
      m_mon = new("m_mon",this);
    endfunction
    function void connect_phase (uvm_phase phase);
      cb_demote cth = new ;
      rst_mon_port = m_mon.rst_mon_port ; // oops, someone equated them
      uvm_report_cb::add(null,cth,UVM_PREPEND); // expect error
      m_mon.rst_mon_port.connect(rst_mon_port) ; 
      uvm_report_cb::delete(null,cth); // don't expect any more
      if (cb_demote::seen !== 1) begin
         `uvm_error("TEST", "Did not get error for port connected to itself")
      end
    endfunction
  endclass
  
  class test extends uvm_test ;
    agent a1; 

    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent) ;
      a1 = new("a1", this);
    endfunction
    function void phase_started(uvm_phase phase) ;
      if (phase.get_name() == "end_of_elaboration")
        `uvm_info("TEST","End of elaboration",UVM_MEDIUM);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase.drop_objection(this);
    endtask

   function void report_phase(uvm_phase phase);
      uvm_root top = uvm_root::get();
      uvm_report_server svr = top.get_report_server();
      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("** UVM TEST FAILED **\n");
   endfunction
  endclass

  initial begin
    
    run_test("test");
  end
endmodule
