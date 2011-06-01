//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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


class passive_comp extends uvm_component;
   `uvm_component_utils(passive_comp)
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   bit busy;
   bit ending;

   task main_phase(uvm_phase phase);
      `uvm_info("passive_comp", "main thread started...", UVM_LOW);
      while (!ending) begin
        busy = 1;
        $display("%t   %m busy",$time);
        #10;
        $display("%t   %m not busy",$time);
        busy = 0;
        if (ending)
          phase.drop_objection(this,"ok, i'm ready");
        uvm_wait_for_nba_region();
      end
      `uvm_info("passive_comp", "main thread completed...", UVM_LOW);
   endtask

   virtual function void phase_ready_to_end(uvm_phase phase);
       if (phase.get_name() == "main") begin
         $display("%t   %m ready_to_end iter=%0d",$time,phase.get_ready_to_end_count());
         ending = 1;
         if (busy) begin
           phase.raise_objection(this,"not ready to end");
           $display("%t   %m re-raised",$time);
         end
       end
   endfunction

endclass


class active_comp extends uvm_component;
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   // normally wouldn't raise/drop each iter, but want to cause iter on read_to_end
   task main_phase(uvm_phase phase);
      `uvm_info("active_comp", "main thread started...", UVM_LOW);
      for (int i=0; i<10; i++) begin
        $display("%t %m raising",$time);
        phase.raise_objection(this);
        #7;
        $display("%t %m dropping",$time);
        phase.drop_objection(this);
        uvm_wait_for_nba_region();
      end
      `uvm_info("active_comp", "main thread completed...", UVM_LOW);
   endtask

   virtual function void extract_phase(uvm_phase phase);
      `uvm_info("EXTRACT START", "extract phase started...", UVM_LOW);
      if ($time() != 14) begin
         `uvm_error("test", $sformatf("extract() phase started at %0d instead of 14.", $time));
      end
   endfunction

   virtual function void report_phase(uvm_phase phase);
      $write("** UVM TEST PASSED **\n");
   endfunction

endclass


class test extends uvm_test;
   `uvm_component_utils(test)
   active_comp ac;
   passive_comp pc;
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction
   function void build();
     ac = new("ac", this);
     pc = new("pc", this);
   endfunction
endclass


initial run_test();


endmodule
