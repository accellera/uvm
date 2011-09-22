//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc. 
//   Copyright 2010-2011 Mentor Graphics Corporation
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


module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

// Test the simple setting of default sequences for a couple of
// different phases on a proactive sequencer. A reactive sequence
// will run on another sequencer. This test verifies that the
// reactive sequence gets stopped properly when the proactive
// sequence is done.
//
// The timing should be:
//    0    seqr1  (configure, runs for 10)
//   10    seqr1  (main, runs for 30)
//   40    seqr1  (shutdown, runs for 130)
//
//  seqr2.configure_cont = 1 
//  seqr2.main_cont = 3 
//  seqr2.shutown_cont = 13 

typedef class myseqr;
class wrapper;
  int array[time] 
   `ifndef INCA
   = '{default:0}
   `endif
   ;
endclass

wrapper seqr_seqs[myseqr];

class myseq extends uvm_sequence #(uvm_sequence_item);
  time t = 10;
  `uvm_object_utils(myseq)
 
  wrapper w; 
  task body;
    int c;
    myseqr seqr;

    if (starting_phase!=null) starting_phase.raise_objection(this);
    $cast(seqr, m_sequencer);
    if(seqr_seqs.exists(seqr))
      w = seqr_seqs[seqr];
    else begin
      w = new;
      seqr_seqs[seqr] = w;
    end

    c = w.array[$time];
    w.array[$time] = c+1;
   
    `uvm_info("INBODY", $sformatf("Starting %s !!!",get_name()), UVM_NONE)
    #(t);
    `uvm_info("INBODY", $sformatf("Ending %s !!!",get_name()), UVM_NONE)
    if (starting_phase!=null) starting_phase.drop_objection(this);

  endtask

  function new(string name="myseq");
     super.new(name);
  endfunction

endclass

// Reactive Sequences
class my_reactive extends uvm_sequence;
  `uvm_object_utils(my_reactive)
  static int configure_cnt = 0;
  static int main_cnt = 0;
  static int shutdown_cnt = 0;

  function new(string name="my_reactive");
     super.new(name);
  endfunction

endclass
class my_reactive_configure extends my_reactive;
  `uvm_object_utils(my_reactive_configure)
  task body;
    `uvm_info("REACT", $sformatf("Starting %s !!!",get_name()), UVM_NONE)
    #5 
    while(1) begin
      configure_cnt++;
      #10;
    end
  endtask

  function new(string name="my_reactive_configure");
     super.new(name);
  endfunction

endclass
class my_reactive_main extends my_reactive;
  `uvm_object_utils(my_reactive_main)
  task body;
    `uvm_info("REACT", $sformatf("Starting %s !!!",get_name()), UVM_NONE)
    #5 
    while(1) begin
      main_cnt++;
      #10;
    end
  endtask

  function new(string name="my_reactive_main");
     super.new(name);
  endfunction

endclass
class my_reactive_shutdown extends my_reactive;
  `uvm_object_utils(my_reactive_shutdown)
  task body;
    `uvm_info("REACT", $sformatf("Starting %s !!!",get_name()), UVM_NONE)
    #5 
    while(1) begin
      shutdown_cnt++;
      #10;
    end
  endtask

  function new(string name="my_reactive_shutdown");
     super.new(name);
  endfunction

endclass

// Active Sequences
class my_config_seq extends myseq;
  static int start_cnt = 0, end_cnt = 0;
  `uvm_object_utils(my_config_seq)
  task body;
    start_cnt++;
    t = 10;
    super.body();
    end_cnt++;
  endtask

  function new(string name="my_config_seq");
     super.new(name);
  endfunction

endclass
class my_main_seq extends myseq;
  static int start_cnt = 0, end_cnt = 0;
  `uvm_object_utils(my_main_seq)
  task body;
    start_cnt++;
    t = 30;
    super.body();
    end_cnt++;
  endtask

  function new(string name="my_main_seq");
     super.new(name);
  endfunction

endclass
class my_shutdown_seq extends myseq;
  static int start_cnt = 0, end_cnt = 0;
  `uvm_object_utils(my_shutdown_seq)
  task body;
    start_cnt++;
    t = 130;
    super.body();
    end_cnt++;
  endtask

  function new(string name="my_shutdown_seq");
     super.new(name);
  endfunction

endclass

class myseqr extends uvm_sequencer;
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  `uvm_component_utils(myseqr)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("RUN","In run!!!", UVM_NONE)
    #500;
    `uvm_info("RUN","Exit run!!!", UVM_NONE)
    phase.drop_objection(this);
  endtask
endclass


class test extends uvm_test;
   myseqr seqr1, seqr2;
   function new(string name = "my_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(test)

   typedef uvm_config_db #(uvm_object_wrapper) phase_rsrc;

   function void build_phase(uvm_phase phase);
      seqr1 = new("seqr1", this);
      seqr2 = new("seqr2", this);
      phase_rsrc::set(this, "seqr1.configure_phase", "default_sequence", my_config_seq::type_id::get());
      phase_rsrc::set(this, "seqr1.main_phase", "default_sequence",      my_main_seq::type_id::get());
      phase_rsrc::set(this, "seqr1.shutdown_phase", "default_sequence",  my_shutdown_seq::type_id::get());
      phase_rsrc::set(this, "seqr2.configure_phase", "default_sequence", my_reactive_configure::type_id::get());
      phase_rsrc::set(this, "seqr2.main_phase", "default_sequence",      my_reactive_main::type_id::get());
      phase_rsrc::set(this, "seqr2.shutdown_phase", "default_sequence",  my_reactive_shutdown::type_id::get());
   endfunction
   
   function void report_phase(uvm_phase phase);
     wrapper w;

     // Check the active sequences
     if(seqr_seqs.num() != 1) begin
       $display("*** UVM TEST FAILED expected 1 sequencers to report, got %0d ***", seqr_seqs.num());
       return;
     end
     if(!seqr_seqs.exists(seqr1) ) begin
       $display("*** UVM TEST FAILED results from a seqr1 do not exist***");
       return;
     end

     foreach(seqr_seqs[i]) begin
        myseqr seqr = i;
        time t;
        w = seqr_seqs[seqr];
        // Each sequencer has 3 default sequences
        if(w.array.num() != 3) begin
          $display("*** UVM TEST FAILED sequencer %s has %0d sequences, but expected 3 ***", seqr.get_full_name(), w.array.num());
         return;
        end
        // Should have exactly one sequence at each time
        if(w.array.first(t)) begin
          do begin
            if(w.array[t] != 1) begin
              $display("*** UVM TEST FAILED sequencer %s has %0d sequences at time %0t, but expected only 1 ***", seqr.get_full_name(), w.array[t], t);
              return;
            end
          end while(w.array.next(t));
        end
        // Check the specific sequencer times
        if(seqr == seqr1)
            begin
              if(!w.array.exists(0) || !w.array.exists(10) || !w.array.exists(40)) begin
                $display("*** UVM TEST FAILED sequencer %s has wrong sequence times ***", seqr.get_full_name());
                return;
              end
            end
        else
            begin
              $display("*** UVM TEST FAILED invalid sequencer results ***");
              return;
            end
     end

     if(my_config_seq::start_cnt != 1 && my_config_seq::end_cnt != 1) begin
       $display("*** UVM TEST FAILED, expected a total of 1 config sequence ***");
       return;
     end
     if(my_main_seq::start_cnt != 1 && my_main_seq::end_cnt != 1) begin
       $display("*** UVM TEST FAILED, expected a total of 1 main sequence ***");
       return;
     end
     if(my_shutdown_seq::start_cnt != 1 && my_shutdown_seq::end_cnt != 1) begin
       $display("*** UVM TEST FAILED, expected a total of 1 shutdown sequence ***");
       return;
     end

     //Check Reactive sequences
     if(my_reactive::configure_cnt != 1) begin
       $display("*** UVM TEST FAILED, expected a total of 1 config loop in reactive sequence but got %0d ***", my_reactive::configure_cnt);
       return;
     end
     if(my_reactive::main_cnt != 3) begin
       $display("*** UVM TEST FAILED, expected a total of 3 main loop in reactive sequence but got %0d ***", my_reactive::main_cnt);
       return;
     end
     if(my_reactive::shutdown_cnt != 13) begin
       $display("*** UVM TEST FAILED, expected a total of 13 shutdown loop in reactive sequence but got %0d ***", my_reactive::shutdown_cnt);
       return;
     end

     $display("*** UVM TEST PASSED ***");
   endfunction
   
endclass

initial
begin
   run_test();
end

endmodule
