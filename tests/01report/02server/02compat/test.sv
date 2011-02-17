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


class my_server extends uvm_report_server;
  int cnt = 0;
  virtual function string compose_message( uvm_severity severity, string name,
      string id, string message, string filename, int    line);
    cnt++;
    compose_message = {"MY_SERVER: ",
      super.compose_message(severity, name, id, message, filename, line) };
  endfunction
endclass

class test extends uvm_test;
   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run();
     uvm_report_global_server glob = new;
     my_server serv = new;
     // Emit a message before setting the server to make sure counts are
     // properly copied over.
     `uvm_info("MSG1", "Some message", UVM_LOW)
     `uvm_info("MSG2", "Another message", UVM_LOW)

     // Set the global server
     glob.set_server(serv);

     //Emit some messages to the new server
     `uvm_info("MSG1", "Some message again", UVM_LOW)
     `uvm_info("MSG2", "Another message again", UVM_LOW)

   endtask

   virtual function void report();
     uvm_report_global_server glob = new;
     uvm_report_server serv;
     serv = glob.get_server();
     if(serv.get_id_count("MSG1") == 2 && serv.get_id_count("MSG2") == 2)
       $display("**** UVM TEST PASSED ****");
     else
       $display("**** UVM TEST FAILED ****");
   endfunction
endclass


initial
  begin
     run_test();
  end

endmodule
