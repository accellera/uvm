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

`include "uvm_macros.svh"
program top;

import uvm_pkg::*;


class trans extends uvm_sequence_item;
   `uvm_object_utils(trans)

   function new(string name = "");
      super.new(name);
   endfunction
endclass


class leaf_seq extends uvm_sequence#(trans);
   `uvm_object_utils(leaf_seq)

   function new(string name = "");
      super.new(name);
   endfunction
   
   task body();
      `uvm_info("SEQPRI", $sformatf("Executing sequence with pri=%0d.", get_priority()), UVM_LOW)

      `uvm_do(req)
   endtask
endclass


class mid_seq extends uvm_sequence;
   `uvm_object_utils(mid_seq)

   leaf_seq seq;
   
   function new(string name = "");
      super.new(name);
   endfunction
   
   task body();
      `uvm_info("SEQPRI", $sformatf("Executing sequence with pri=%0d.", get_priority()), UVM_LOW)
      `uvm_do(seq)
   endtask
endclass


class top_seq extends uvm_sequence;
   `uvm_object_utils(top_seq)

   int pri = 100;

   mid_seq seq;
   
   function new(string name = "");
      super.new(name);
   endfunction
   
   task body();
      if (starting_phase != null) starting_phase.raise_objection(this);

      `uvm_info("SEQPRI", $sformatf("Executing sequence with pri=%0d.", get_priority()), UVM_LOW)

      if (get_priority() != pri) begin
         `uvm_error("BADDFLTPRI", $sformatf("Invalid default priority for top sequence: %0d instead of %0d",
                                            get_priority(), pri));
      end

      seq = new("seq");
      seq.start(get_sequencer(), this);

      if (starting_phase != null) starting_phase.drop_objection(this);
   endtask
endclass


class top2_seq extends uvm_sequence;
   `uvm_object_utils(top2_seq)

   mid_seq seq;
   
   function new(string name = "");
      super.new(name);
   endfunction
   
   task body();
      `uvm_info("SEQPRI", $sformatf("Executing sequence with pri=%0d.", get_priority()), UVM_LOW)

      if (get_priority() != 100) begin
         `uvm_error("BADDFLTPRI", $sformatf("Invalid default priority for top sequence: %0d instead of %0d",
                                            get_priority(), 100));
      end

      seq = new("seq");
      seq.start(get_sequencer(), this, 10);
   endtask
endclass


class test extends uvm_test;

   `uvm_component_utils(test)

   uvm_sequencer#(trans) sqr;
   uvm_seq_item_pull_port#(trans) seq_item_port;

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      sqr = new("sqr", this);
      seq_item_port = new("seq_item_port", this);

      uvm_config_db#(uvm_object_wrapper)::set(this, "sqr.main_phase",
                                              "default_sequence",
                                              top_seq::get_type());

      sqr.set_arbitration(SEQ_ARB_STRICT_FIFO);
   endfunction
   
   function void connect_phase(uvm_phase phase);
      seq_item_port.connect(sqr.seq_item_export);
   endfunction

   virtual task main_phase(uvm_phase phase);
      phase.raise_objection(this);

      fork
         begin
            top_seq seq = new("top");
            seq.pri = 500;
            seq.start(sqr, null, 500);
         end
         begin
            top2_seq seq = new("top2");
            seq.start(sqr);
         end
      join
      phase.drop_objection(this);
   endtask

   virtual task run_phase(uvm_phase phase);
      int exp_pri[3] = '{500, 100, 10};
      
      phase.raise_objection(this);

      foreach (exp_pri[i]) begin
         trans tr;
         uvm_sequence_base seq;

         #100;
         
         seq_item_port.get_next_item(tr);
         seq = tr.get_parent_sequence();

         `uvm_info("DRV/EXEC",
                   $sformatf("Executing sequence item \"%s\" with priority %0d...", tr.get_full_name(), (seq==null) ? -1 : seq.get_priority()),
                   UVM_NONE)

         if (seq == null) begin
            `uvm_error("NOSEQ", "Item is executed without a parent sequence")
         end
         else begin
            int pri = seq.get_priority;
            if (pri != exp_pri[i]) begin
               `uvm_error("BADPRI",
                          $sformatf("Item executed with priority %0d instead of %0d.",
                                    pri, exp_pri[i]))
            end
         end
         
         #10;
         
         seq_item_port.item_done();
      end

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
