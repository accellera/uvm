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
`include "uvm_macros.svh"

class catcher_return_caught extends uvm_report_catcher;
  string id;
  function new(string id); this.id = id; endfunction
  
  virtual function action_e catch();
  if(get_id() != id) return THROW;
  $write("An instance of catcher_return_caught, Caught a message...\n");
  $write("===========================================\n");
  
  return CAUGHT;
  endfunction
endclass

  
class catcher_return_caught_call_issue extends uvm_report_catcher;
  string id;
  function new(string id); this.id = id; endfunction
   
  virtual function action_e catch();
  if(get_id() != id) return THROW;
  $write("An instance of catcher_return_caught_call_issue, Caught a message...calling issue()...\n");
  $write("===========================================\n");
  issue();
  return CAUGHT;
   endfunction
endclass

class catcher_return_throw extends uvm_report_catcher;
  string id;
  function new(string id); this.id = id; endfunction
   
  virtual function action_e catch();
  if(get_id() != id) return THROW;
  $write("An instance of catcher_return_throw, Caught a message...\n");
  $write("===========================================\n");
  return THROW;
  endfunction
endclass

class catcher_return_throw_call_issue extends uvm_report_catcher;
  string id;
  function new(string id); this.id = id; endfunction
  
  virtual function action_e catch();
  if(get_id() != id) return THROW;
  $write("An instance of catcher_return_throw_call_issue, Caught a message...calling issue()...\n");
  $write("===========================================\n");
  issue();
  return THROW;
  endfunction
endclass

  class catcher_return_unknown_action extends uvm_report_catcher;
  string id;
  function new(string id); this.id = id; endfunction
  
  virtual function action_e catch();
  if(get_id() != id) return THROW;
  $write("An instance of catcher_return_unknown_action, Caught a message...\n");
  $write("===========================================\n");
  return UNKNOWN_ACTION;
  
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
      $write("UVM TEST - Catchers which return CAUGHT/THROW and call issue() \n");
      
      begin
          catcher_return_caught  ctchr1 = new("Catcher1");
          catcher_return_caught_call_issue ctchr2 = new("Catcher2");
          catcher_return_throw  ctchr3 = new("Catcher3");
          catcher_return_throw_call_issue ctchr4 = new("Catcher4");
          catcher_return_unknown_action ctchr5 = new("Catcher5");
        
           $write("===========================================\n");
          //add_report_id_catcher(string id, uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
          $write("adding a catcher of type catcher_return_caught  with id of Catcher1\n");
          uvm_report_cb::add(null,ctchr1);
          
          $write("adding a catcher of type catcher_return_caught_call_issue with id of Catcher2\n");
          uvm_report_cb::add(null,ctchr2);

          $write("adding a catcher of type catcher_return_throw  with id of Catcher3\n");
          uvm_report_cb::add(null,ctchr3);
          
          $write("adding a catcher of type catcher_return_throw_call_issue with id of Catcher4\n");
          uvm_report_cb::add(null,ctchr4);

           $write("adding a catcher of type catcher_return_unknown_action with id of Catcher5\n");
          uvm_report_cb::add(null,ctchr5);

           $write("===========================================\n");
        
          `uvm_info("Catcher1", "This message is for Catcher1", UVM_MEDIUM);
          `uvm_info("Catcher2", "This message is for Catcher2", UVM_MEDIUM);
          `uvm_info("Catcher3", "This message is for Catcher3", UVM_MEDIUM);
          `uvm_info("Catcher4", "This message is for Catcher4", UVM_MEDIUM);
          `uvm_info("Catcher5", "This message is for Catcher5 which calls an UNKNOWN_ACTION", UVM_MEDIUM);
          `uvm_info("XYZ", "This message is for No One", UVM_MEDIUM);
            
        end // begin

      $write("UVM TEST EXPECT 1 UVM_ERROR\n");
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
