//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
//   Copyright 2011 Cadence Design Systems, Inc.
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
//------------------------------------------------------------------------------

`include "uvm_pkg.sv"

module p;

import uvm_pkg::*;

class comp1 extends uvm_component;
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   task main(uvm_phase phase);
      // this will override stop_request; test will end at 5100.
      phase.raise_objection(this);
      `uvm_info("comp1", "main thread started...", UVM_LOW);
      #5000;
      `uvm_info("comp1", "main thread completed...", UVM_LOW);
      phase.drop_objection(this);
   endtask

   virtual task run_phase(uvm_phase phase);
      enable_stop_interrupt = 1;
      `uvm_info("comp1", "run phase started...", UVM_LOW);
      fork begin
         main(phase);
      end join_none
      #100;
      `uvm_info("comp1", "run phase ended...", UVM_LOW);
   endtask

   task interrupt();
      `uvm_info("comp1", "interrupt thread started...", UVM_LOW);
      #1000;
      `uvm_info("comp1", "interrupt thread completed...", UVM_LOW);
   endtask

   virtual task stop(string ph_name);
      `uvm_info("comp1", {"stop ", ph_name, " phase started..."}, UVM_LOW);
      fork
         interrupt();
      join_none
      #100;
      `uvm_info("comp1", {"stop ", ph_name, " phase ended..."}, UVM_LOW);
   endtask

   virtual function void extract_phase(uvm_phase phase);
      `uvm_info("comp1", "extract phase started...", UVM_LOW);
      if ($time() != 5100) begin
         `uvm_error("test", $sformatf("extract() phase started at %0d instead of 600.", $time));
      end
   endfunction

   virtual function void report_phase(uvm_phase phase);
      $write("** UVM TEST PASSED **\n");
   endfunction
endclass


class test extends uvm_test;
   `uvm_component_utils(test)
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction
endclass


initial
begin
   comp1 c;
   c = new("c", null);
   run_test();
   #500 global_stop_request;
end


endmodule
