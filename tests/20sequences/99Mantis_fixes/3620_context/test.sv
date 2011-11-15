//
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
//

`include "uvm_macros.svh"

program p;

import uvm_pkg::*;

class subseq extends uvm_sequence;
   `uvm_object_utils(subseq)

   function new(string name = "");
      super.new(name);
   endfunction

   function void pre_randomize();
      if (get_parent_sequence() == null) begin
         `uvm_error("NOPSEQ", "Parent sequence not set before randomize()")
      end
      if (get_sequencer() == null) begin
         `uvm_error("NOPSEQR", "Parent sequencer not set before randomize()")
      end
   endfunction

   virtual task pre_start();
      if (get_parent_sequence() == null) begin
         `uvm_error("NOPSEQ", "Parent sequence not set before start()")
      end
      if (get_sequencer() == null) begin
         `uvm_error("NOPSEQR", "Parent sequencer not set before start()")
      end
   endtask

   virtual task body();
      `uvm_info("SUBSEQ", {"Executing sub-sequence ", get_full_name()}, UVM_LOW)
   endtask
endclass


class topseq extends uvm_sequence;
   `uvm_object_utils(topseq)

   function new(string name = "");
      super.new(name);
   endfunction

   virtual task body();
      subseq seq;

      `uvm_do(seq);

      seq = subseq::type_id::create("seq");
      `uvm_send(seq);

      seq = subseq::type_id::create("seq");
      `uvm_rand_send(seq);
   endtask
endclass


class seqlib extends uvm_sequence_library#(uvm_sequence_item);
   `uvm_object_utils(seqlib)
   `uvm_sequence_library_utils(seqlib)
   `uvm_add_to_seq_lib(subseq, seqlib)

   function new(string name = "");
      super.new(name);
      init_sequence_library();
   endfunction
endclass


class test extends uvm_test;
   `uvm_component_utils(test)
   
   uvm_sequencer sqr;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction
   
   function void build();
      super.build();
      sqr = uvm_sequencer#()::type_id::create("sqr", this);
   endfunction
   
   task run_phase(uvm_phase phase);
      topseq tseq;
      seqlib lseq;
      
      phase.raise_objection(this);
      tseq = topseq::type_id::create("tseq", this);
      tseq.start(sqr);

      lseq = seqlib::type_id::create("lseq", this);
      void'(lseq.randomize());
//      lseq.sequence_count = 1;
      lseq.start(sqr);
      
      phase.drop_objection(this);
   endtask

   function void final_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass


initial run_test();

endprogram

