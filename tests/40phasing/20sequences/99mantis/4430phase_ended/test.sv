//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc. 
//   Copyright 2010-2011 Mentor Graphics Corporation
//   Copyright 2011 Synopsys, Inc.
//   Copyright 2013 NVIDIA Corporation
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


module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

// Test the simple setting of default sequences for a couple of
// different phases, configure and main.

class myseq extends uvm_sequence;
  static int start_cnt = 0, end_cnt = 0;
  `uvm_object_utils(myseq)
  
  task body;
    start_cnt++;
    `uvm_info("INBODY", "Starting myseq!!!", UVM_NONE)
    #10;
    `uvm_info("INBODY", "Ending myseq!!!", UVM_NONE)
    end_cnt++;
  endtask

  function new(string name="myseq");
     super.new(name);
  endfunction

endclass

class myseqr extends uvm_sequencer;
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  `uvm_component_utils(myseqr)

  task configure_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("CONFIG", "In configure!!!", UVM_NONE)
    #20;
    `uvm_info("CONFIG", "Exiting configure!!!", UVM_NONE)
    phase.drop_objection(this);
  endtask
    
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("MAIN","In main!!!", UVM_NONE)
    #1;
    `uvm_info("MAIN","Exiting main!!!", UVM_NONE)
    phase.drop_objection(this);
  endtask

endclass


class test extends uvm_test;

   myseq seq_ran, seq_killed;

   myseqr seqr;
   function new(string name = "my_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(test)

   function void build_phase(uvm_phase phase);
      seqr = new("seqr", this);
      seq_ran = myseq::type_id::create("seq_ran", this);
      seq_killed = myseq::type_id::create("seq_killed", this);

      uvm_config_db #(uvm_sequence_base)::set(this, "seqr.configure_phase", "default_sequence", seq_ran);
      uvm_config_db #(uvm_sequence_base)::set(this, "seqr.main_phase", "default_sequence", seq_killed);
   endfunction
   
   function void report_phase(uvm_phase phase);
     bit pass = 1;
     if (seq_ran.get_sequence_state() != UVM_FINISHED) begin
         pass = 0;
         `uvm_error("NOT_FINISHED", "'seq_ran' not in the 'UVM_FINISHED' state!")
     end

     if (seq_killed.get_sequence_state() != UVM_STOPPED) begin
         pass = 0;
         `uvm_error("NOT_STOPPED", "'seq_killed' not in the 'UVM_STOPPED' state!")
     end

     if (!pass) 
       $display("*** UVM TEST FAILED ***");
     else
       $display("*** UVM TEST PASSED ***");
   endfunction
   
endclass

initial
begin
   run_test();
end

endmodule
