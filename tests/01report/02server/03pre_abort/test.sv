//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc. 
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

// Tests that the pre_abort() callback is called for all components on
// exit.

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

int aborts [uvm_component];

class base extends uvm_component;
   `uvm_component_utils(base)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void pre_abort();
     `uvm_info("preabort", "In pre_abort...", UVM_NONE)
     if(aborts.exists(this)) 
       aborts[this]++;
     else
       aborts[this] = 1;
   endfunction
endclass


class A extends base;
   `uvm_component_utils(A)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction
endclass

class B extends base;
   A aa, aa2;
   
   `uvm_component_utils(B)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
      aa = new("aa", this);
      aa2 = new("aa2", this);
   endfunction
endclass
 
class test extends base;

   B bb;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
      bb = new("bb",this);
   endfunction

   virtual task run();
      $display("UVM TEST EXPECT 1 UVM_ERROR");
      set_report_max_quit_count(1);

      `uvm_error("someerror", "Create an error condition")
   endtask

   virtual function void pre_abort();
      bit failed = 0;
      super.pre_abort();
      //there are 4 components, so the aborts array needs 4 unique
      //handles, one for each component.
      if(aborts.num() != 4) begin
        failed = 1;
        $display("**** UVM TEST FAILED, %0d pre_aborts called, expected 4", aborts.num());
      end 
      if(aborts[this] != 1) begin
        failed = 1;
        $display("**** UVM TEST FAILED, %0d pre_abort called from %s, expected 1", aborts.num(), get_full_name());
      end 
      if(aborts[bb] != 1) begin
        failed = 1;
        $display("**** UVM TEST FAILED, %0d pre_abort called from %s, expected 1", aborts.num(), bb.get_full_name());
      end 
      if(aborts[bb.aa] != 1) begin
        failed = 1;
        $display("**** UVM TEST FAILED, %0d pre_abort called from %s, expected 1", aborts.num(), bb.aa.get_full_name());
      end 
      if(aborts[bb.aa2] != 1) begin
        failed = 1;
        $display("**** UVM TEST FAILED, %0d pre_abort called from %s, expected 1", aborts.num(), bb.aa2.get_full_name());
      end 
      if(failed == 0)
        $display("**** UVM TEST PASSED ****");
   endfunction

endclass


initial
  begin
     run_test();
  end

endmodule
