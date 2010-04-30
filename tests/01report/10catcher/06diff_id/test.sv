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

//////////////distrib/src/base/uvm_object_globals.svh////////////////////////////
//////// uvm_severity   
////////
///////typedef enum uvm_severity
///////{
///////  UVM_INFO,
///////  UVM_WARNING,
///////  UVM_ERROR,
///////  UVM_FATAL
/////////} uvm_severity_type;
//////////////////////////


///////uvm_misc.svh////////////
/////////
////// typedef enum {UVM_APPEND, UVM_PREPEND} uvm_apprepend;
///////////////////////////////
///////////////////////////////



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

  int pass1 = 1;
  int pass2 = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run();
      $write("UVM TEST - Same catcher type - different IDs\n");
      
      if (my_catcher::seen != 0) 
        begin
          $write("ERROR: Message was caught with no catcher installed!\n");
          pass1 = 0;
          pass2 = 0;
          
        end
        begin
          my_catcher ctchr1 = new;
          my_catcher ctchr2 = new;
          

          //add_report_id_catcher(string id, uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
          $write("adding a catcher of type my_catcher with id of Catcher1\n");
          uvm_report_catcher::add_report_id_catcher("Catcher1",ctchr1);
          
          $write("adding a catcher of type my_catcher with id of Catcher2\n");
          uvm_report_catcher::add_report_id_catcher("Catcher2",ctchr2);
        
          `uvm_info("Catcher1", "This message is for Catcher1", UVM_MEDIUM);
          if (my_catcher::seen == 1) begin
            $write("Message was caught with catcher ID=Catcher1 \n");
            pass1 = 1;
          end
          
          `uvm_info("Catcher2", "This message is for Catcher2", UVM_MEDIUM);
          if (my_catcher::seen == 2) begin
            $write("Message was caught with catcher ID=Catcher2 \n");
            pass2 = 1;
          end
            `uvm_info("XYZ", "This message is for No One", UVM_MEDIUM);

            
            `uvm_info("Catcher1", "This message is for Catcher1", UVM_MEDIUM);
          if (my_catcher::seen == 3) begin
            $write("Message was caught for a second time with catcher ID=Catcher1 \n");
            pass1 = 2;
          end
          
          `uvm_info("Catcher2", "This message is for Catcher2", UVM_MEDIUM);
          if (my_catcher::seen == 4) begin
            $write("Message was caught for a second time with catcher ID=Catcher2 \n");
            pass2 = 2;
          end
            
            `uvm_info("XYZ", "This second message is for No One", UVM_MEDIUM);

            
            
        end // begin
  


  
      uvm_report_catcher::remove_all_report_catchers();
      
      uvm_top.stop_request();
   endtask

   virtual function void report();
      
       if ((pass1 == 2) & (pass2 == 2)) $write("** UVM TEST PASSED **\n");
      else $write("** UVM TEST FAILED! **\n"); 
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
