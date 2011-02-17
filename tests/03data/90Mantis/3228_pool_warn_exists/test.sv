//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   virtual function action_e catch();
      if(get_severity() == UVM_WARNING) begin
        seen++;
      end
      return THROW;
   endfunction
endclass

class test extends uvm_test;

   bit pass = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   uvm_pool#(int,int) pool=new;

   virtual task run();
      my_catcher ctchr = new;
      uvm_report_cb::add(null,ctchr);

      for(int i=0; i<10; i+=2) pool.add(i,i*8);
      if(ctchr.seen != 0) begin 
        $display("** UVM TEST FAILED, Got warning on add_no_dup with no entries**");
        return;
      end
      for(int i=0; i<10; i+=2) begin
        pool.add(i,i+32);
        if(pool.get(i)  != i+32) begin
          $display("** UVM TEST FAILED, add(%0d,%0d), incorrect value: %0d**", i, i+32, pool.get(i));
          return;
        end
      end
      if(ctchr.seen != 0) begin 
        $display("** UVM TEST FAILED, Got warning on add with entries**");
        return;
      end
      $display("** UVM TEST PASSED! **");
   endtask

endclass


initial
  begin
     run_test();
  end

endprogram
