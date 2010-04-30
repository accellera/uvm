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

class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   virtual function action_e catch();
      $write("Caught a message...\n");
      seen++;
      return CAUGHT;
   endfunction
endclass

class test extends uvm_test;

   bit pass = 1;
    my_catcher ctchr;
    my_catcher ctchr1;
    my_catcher ctchr2;
    my_catcher ctchr3;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run();
      
 
  begin
    $write("UVM TEST - ERROR expected since registering a default catcher with NULL handle\n");
        
    //add_report_default_catcher(uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
    uvm_report_catcher::add_report_default_catcher(ctchr);
    
    $write("UVM TEST - ERROR expected since registering a severity catcher with NULL handle\n");
    //add_report_severity_catcher(uvm_severity severity, uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
    uvm_report_catcher::add_report_severity_catcher(UVM_INFO, ctchr1);
    
    $write("UVM TEST - ERROR expected since registering an ID catcher with NULL handle\n");
    //add_report_id_catcher(string id, uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
    uvm_report_catcher::add_report_id_catcher("MyID", ctchr2);

    $write("UVM TEST - ERROR expected since registering a severity/ID catcher with NULL handle\n");
    //add_report_severity_id_catcher(uvm_severity severity, string id, uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
    uvm_report_catcher::add_report_severity_id_catcher(UVM_WARNING,"MyOtherID" ,ctchr3); 

 
      end
      uvm_report_catcher::remove_all_report_catchers();
      $write("UVM TEST EXPECT 4 UVM_ERROR\n");
      uvm_top.stop_request();
   endtask

   virtual function void report();
      
      $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
