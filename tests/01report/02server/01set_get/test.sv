//---------------------------------------------------------------------- 
//   Copyright 2010 Cadence Design Systems.
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

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

int cnt = 0;
bit success = 0 ;

class my_server extends uvm_default_report_server;
  virtual function string compose_report_message(uvm_report_message report_message, string report_object_name = "");
    cnt++;
    compose_report_message = {"MY_SERVER: ", super.compose_report_message(report_message, report_object_name)};
  endfunction

  // to make sure this is being executed, have it display a good result
  // (despite the dummy error thrown earlier)
  virtual function void report_summarize(UVM_FILE file=0) ;
     if (success == 1) begin
       $display("**** UVM TEST PASSED ****");
       $display("--- UVM Report Summary ---");
       $display("");
       $display("** Report counts by severity");
       $display("UVM_INFO :    6");
       $display("UVM_WARNING :    0");
       $display("UVM_ERROR :    0");
       $display("UVM_FATAL :    0");
    end
    else begin
       $display("**** UVM TEST FAILED ****");
       super.report_summarize(file) ;
    end
  endfunction

endclass

class test extends uvm_test;
   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
     my_server serv = new;
     // Emit a message before setting the server to make sure counts are
     // properly copied over.
     `uvm_info("MSG1", "Some message", UVM_LOW)
     `uvm_info("MSG2", "Another message", UVM_LOW)

     // Set the global server
     uvm_report_server::set_server(serv);

     //Emit some messages to the new server
     `uvm_info("MSG1", "Some message again", UVM_LOW)
     `uvm_info("MSG2", "Another message again", UVM_LOW)

   endtask

   virtual function void report();
     uvm_report_server serv = uvm_report_server::get_server();
     if(serv.get_id_count("MSG1") == 2 && serv.get_id_count("MSG2") == 2 && cnt == 2) begin
        success = 1 ;
     end
     `uvm_error("EXPECTED","This is an expected error designed to test whether report_server that was set is used at end of sim") 
   endfunction
endclass


initial
  begin
     run_test();
  end

endmodule
