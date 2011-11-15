//---------------------------------------------------------------------- 
//   Copyright 2011 Synopsys, Inc. 
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

class subseq extends uvm_sequence;
   `uvm_object_utils(subseq)

   rand bit foo;

   constraint foo_is_always_one {
      foo == 1;
   }

   function new(string name = "subseq");
      super.new(name);
      do_not_randomize = 1;
   endfunction

   task body();
      if (starting_phase != null) begin
         $write("Checking default phase...\n");
         starting_phase.raise_objection(this);
      end

      $write("Executing subseq...\n");
      if (foo !== 0) begin
         `uvm_error("BadFoo", "subseq was randomized")
      end

      #10;

      if (starting_phase != null) begin
         $write("Checking default phase...\n");
         starting_phase.drop_objection(this);
      end
   endtask
endclass


class topseq extends uvm_sequence;
   `uvm_object_utils(topseq)

   function new(string name = "topseq");
      super.new(name);
   endfunction

   task body();
      subseq seq;

      $write("Executing topseq...\n");

      $write("Checking uvm_do()...\n");
      `uvm_do(seq);
      
      $write("Checking uvm_send()...\n");
      `uvm_create(seq);
      `uvm_rand_send(seq);
   endtask
endclass


class test extends uvm_test;

   `uvm_component_utils(test)

   uvm_sequencer sqr;

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      sqr = new("sqr", this);

      begin
         subseq seq = new("def.seq");
         uvm_config_db#(uvm_sequence_base)::set(this, "sqr", "main_phase.default_sequence", seq);
      end
   endfunction

   virtual task run_phase(uvm_phase phase);
      topseq seq;

      phase.raise_objection(this);

      seq = new("seq");
      seq.start(null);

      #10;
      
      phase.drop_objection(this);
   endtask


   function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass


initial run_test("test");

endprogram
