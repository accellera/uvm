//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   uvm_report_object client;
   int client_cnt[uvm_report_object];

   virtual function action_e catch();
      client = get_client();
      $write("Caught a message from client \"%0s\"...\n",client.get_full_name());
      seen++;
      if(!client_cnt.exists(client)) client_cnt[client]=0;
      client_cnt[client]++;
      return CAUGHT;
   endfunction
endclass

class leaf extends uvm_component;
   `uvm_component_utils(leaf)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction
   task run;
     repeat(4) #10 `uvm_info("from_leaf", "Message from leaf", UVM_NONE)
   endtask
endclass

class mid extends uvm_component;
   leaf leaf1, leaf2;

   `uvm_component_utils(mid)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
      leaf1 = new("leaf1", this);
      leaf2 = new("leaf2", this);
   endfunction
   task run;
     repeat(4) #10 `uvm_info("from_mid", "Message from mid", UVM_NONE)
   endtask
endclass

class test extends uvm_test;
   mid mid1;

   bit pass = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
      mid1 = new("mid1", this);
   endfunction

   virtual task run();
      my_catcher ctchr = new;

      $write("UVM TEST EXPECT 3 UVM_INFO\n");
      #11;

      if (my_catcher::seen != 0) begin
         $write("ERROR: Message was caught with no catcher installed!\n");
         pass = 0;
      end
      begin
          uvm_report_cb::add(mid1.leaf1,ctchr); //add to mid1.leaf1
          uvm_report_cb::add(mid1,ctchr); //add to mid1
         #10;
         if (my_catcher::seen != 2) begin
            $write("ERROR: Message was NOT caught with default catcher installed!\n");
            pass = 0;
         end
         uvm_report_cb::delete(mid1,ctchr); //remove to mid1
         #10
         if (my_catcher::seen != 3) begin
            $write("ERROR: Message was NOT caught with default catcher installed!\n");
            pass = 0;
         end
      end
      uvm_report_cb::delete(null,ctchr);
      #10;
      if (my_catcher::seen != 3) begin
         $write("ERROR: Message was caught after all catcher removed!\n");
         pass = 0;
      end
      uvm_top.stop_request();
   endtask

   virtual function void report();
      if (pass) $write("** UVM TEST PASSED **\n");
      else $write("** UVM TEST FAILED! **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
