//---------------------------------------------------------------------- 
//   Copyright 2010 Cadence Design Systems, Inc. 
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
endclass

class myseqr extends uvm_sequencer;
  function new(string name, uvm_component parent);
    super.new(name,parent);
    set_phase_domain("uvm", .hier(0));
  endfunction
  `uvm_component_utils(myseqr)

  task main_phase(uvm_phase phase);
    `uvm_info("MAIN","In main!!!", UVM_NONE)
    #100;
    `uvm_info("MAIN","Exiting main!!!", UVM_NONE)
  endtask

endclass


class test extends uvm_test;
   myseqr seqr;
   function new(string name = "my_comp", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(test)

   function void build_phase(uvm_phase phase);
      uvm_phase domain, cfg, main;
      seqr = new("seqr", this);
      domain = seqr.find_phase_schedule("uvm_pkg::uvm","*");
      uvm_config_db #(uvm_object_wrapper)::set(this, "seqr", "configure_ph", myseq::type_id::get());
      uvm_config_db #(uvm_object_wrapper)::set(this, "seqr", "main_ph", myseq::type_id::get());
   endfunction
   
   function void report_phase(uvm_phase phase);
     if(myseq::start_cnt != 2 && myseq::end_cnt != 2)
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
