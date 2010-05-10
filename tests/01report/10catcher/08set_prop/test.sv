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
`include "uvm_macros.svh"

class my_catcher extends uvm_report_catcher; //Default Catcher modifying the message
   
   virtual function action_e catch();
      $write("Default Catcher Caught a Message...\n");
      if(get_message() == "SQUARE")
        begin
          
          $write("Default Catcher modified the message\n " );
          set_message({"Modifying SQUARE to TRIANGLE"});
          
        end
      if(get_message() == "CIRCLE")
        begin
          
          $write("Default Catcher modified the action to UNKNOWN_ACTION\n " );
          set_action(UNKNOWN_ACTION);
          return UNKNOWN_ACTION;
        end
      return THROW;
   endfunction
endclass

  class my_catcher1 extends uvm_report_catcher; // Severity Catcher modifying the message severity
   
   virtual function action_e catch();
      $write("Severity Catcher Caught a Message...\n");
      if(get_message() == "MSG2")
        begin
          
          $write("Severity Catcher is Changing the severity from UVM_WARNING to UVM_ERROR\n");
          set_severity(UVM_ERROR);
        end
      return THROW;
   endfunction
  endclass


  class my_catcher2 extends uvm_report_catcher; // Severity Catcher modifying the message severity
   
   virtual function action_e catch();
      $write("ID Catcher Caught a Message...\n");
      if(get_message() == "MSG3")
        begin
          
          $write("ID Catcher is Changing the ID from Orion to Jupiter\n");
          set_id("Jupiter");
        end
      return THROW;
   endfunction
  endclass

  
  class my_catcher3 extends uvm_report_catcher; // Severity Catcher modifying the message severity
   
  virtual function action_e catch();
  int verbo;
  verbo = this.get_verbosity();
  
  if (verbo > UVM_HIGH)
    begin
      $write("A: ID Catcher3  is Changing the verbosity from %0d to %0d \n", verbo, UVM_DEBUG);
      this.set_verbosity(UVM_DEBUG);
      $write("A: ID Catcher3 new verbosity is %d \n", this.get_verbosity());
        
    end
    else 
      begin
        $write("B: ID Catcher3 is Changing the verbosity from %0d to %0d \n", verbo, UVM_LOW);
        this.set_verbosity(UVM_LOW);
        $write("B: ID Catcher3 new verbosity is %0d \n", this.get_verbosity());
      end
  return THROW;
  endfunction
  endclass

  

  
  

class test extends uvm_test;

    bit pass = 1;
    my_catcher ctchr  = new();
    my_catcher1 ctchr1 = new();
    my_catcher2 ctchr2 = new();
    my_catcher3 ctchr3 = new();

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run();
      
 
  begin
    $write("UVM TEST - Changing catcher severity, id, message, action, verbosity \n");
        
    //add_report_default_catcher(uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
    uvm_report_cb::add(null,ctchr);
    `uvm_info("ctchr", "SQUARE", UVM_MEDIUM);
    
     uvm_report_cb::add(null, ctchr1);
    `uvm_warning("ctchr1", "MSG2");

    
     uvm_report_cb::add(null, ctchr2);
    `uvm_info("Orion", "MSG3", UVM_MEDIUM);

    $write("Calling a message CIRCLE so the Default catcher modify its actions to UNKNOWN_ACTION");
    
    `uvm_info("ctchr", "CIRCLE", UVM_MEDIUM);
    
   
    uvm_report_cb::add(null,ctchr3); 
    `uvm_info("MyOtherID", "Message1 Sending a UVM_MEDIUM message", UVM_MEDIUM);
    `uvm_info("MyOtherID", "Message2 Sending a UVM_FULL message", UVM_FULL);
 
      end
      
      $write("UVM TEST EXPECT 2 UVM_ERROR\n");
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
