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
// different phases on two sequencers. Sequencer 1 runs the
// sequence in the configure and main phases and Sequencer 2
// runs in the pre_configure and pre_main phases. Both run in
// the shutdown phase.
//
// The timing should be:
//    0    seqr2  (pre_configure)
//   10    seqr1  (configure)
//   20    seqr2  (pre_main)
//   30    seqr1  (main)
//  130    seqr1  (shutdown)
//         seqr2  (shutdown)

typedef class myseqr;
class wrapper;
  int array[time]
    `ifdef QUESTA
    = '{ default:0 }
    `endif
    ;
endclass

wrapper seqr_seqs[myseqr];

class myseq extends uvm_sequence;
  static int start_cnt = 0, end_cnt = 0;
  `uvm_object_utils(myseq)
 
  wrapper w; 

  task body;

    int c;
    myseqr seqr;

    if (starting_phase!=null) starting_phase.raise_objection(this);

    start_cnt++;

    $cast(seqr, m_sequencer);
    if(seqr_seqs.exists(seqr))
      w = seqr_seqs[seqr];
    else begin
      w = new;
      seqr_seqs[seqr] = w;
    end

    c = w.array[$time];
    w.array[$time] = c+1;
   
    `uvm_info("INBODY", {seqr.get_name()," Starting myseq in phase ",starting_phase.get_name()}, UVM_NONE)
    #10;
    `uvm_info("INBODY", {seqr.get_name()," Ending myseq!!!"}, UVM_NONE)
    end_cnt++;
    if (starting_phase!=null) starting_phase.drop_objection(this);

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

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("MAIN","In main!!!", UVM_NONE)
    #100;
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
      phase_rsrc::set(this, "seqr1.configure_phase", "default_sequence", myseq::type_id::get());
      phase_rsrc::set(this, "seqr1.main_phase", "default_sequence", myseq::type_id::get());
      phase_rsrc::set(this, "seqr1.shutdown_phase", "default_sequence", myseq::type_id::get());
      phase_rsrc::set(this, "seqr2.pre_configure_phase", "default_sequence", myseq::type_id::get());
      phase_rsrc::set(this, "seqr2.pre_main_phase", "default_sequence", myseq::type_id::get());
      phase_rsrc::set(this, "seqr2.shutdown_phase", "default_sequence", myseq::type_id::get());
   endfunction
   
   function void report_phase(uvm_phase phase);
     wrapper w;

     if(seqr_seqs.num() != 2) begin
       $display("*** UVM TEST FAILED expected 2 sequencers to report, got %0d ***", seqr_seqs.num());
       return;
     end
     if(!seqr_seqs.exists(seqr1) || !seqr_seqs.exists(seqr2)) begin
       $display("*** UVM TEST FAILED results from a sequencer do not exist***");
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
              if(!w.array.exists(10) || !w.array.exists(30) || !w.array.exists(130)) begin
                $display("*** UVM TEST FAILED sequencer %s has wrong sequence times ***", seqr.get_full_name());
                return;
              end
            end
        else if(seqr == seqr2)
            begin
              if(!w.array.exists(0) || !w.array.exists(20) || !w.array.exists(130)) begin
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

     if(myseq::start_cnt != 6 && myseq::end_cnt != 6)
       $display("*** UVM TEST FAILED, expected a total of 6 sequences ***");
      else
       $display("*** UVM TEST PASSED ***");
   endfunction
   
endclass

initial
begin
   run_test();
end

endmodule
