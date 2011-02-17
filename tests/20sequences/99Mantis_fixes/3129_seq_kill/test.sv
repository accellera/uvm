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

`include "stop_started_seq_sv_side.sv"

`include "uvm_macros.svh"

module top;
   import uvm_pkg::*;
   import my_uvc::*;
  
   reg clk;
   initial clk = 0;
   always #10 clk = ~clk;
   

class test extends uvm_env;
   my_uvc_sequencer sequencer0;
   //ml_uvm_seq::ml_uvm_sequencer_stub sequencer_stub;
   my_uvc_driver driver0;
   
   `uvm_component_utils(test)
   
    function new (string name, uvm_component parent);
       super.new(name, parent);
    endfunction : new
   
   virtual function void build();
      super.build();
      set_config_string("sequencer0", "default_sequence", "root_seq");
      sequencer0 = my_uvc_sequencer::type_id::create("sequencer0", this);

      // Instatiate the seqer stub and associate it with the env's actual sequencer.
      //sequencer_stub = ml_uvm_seq::ml_uvm_sequencer_stub::type_id::create("sequencer_stub", this);
      //sequencer_stub.set_sv_seqr(sequencer0);
      
       driver0 = my_uvc_driver::type_id::create("driver0", this);
   endfunction 
   
   virtual function void connect();
      driver0.seq_item_port.connect(sequencer0.seq_item_export);
   endfunction 
   
   function void end_of_elaboration();
      this.print();
   endfunction 
   
   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #7000;
      phase.drop_objection(this);
   endtask
endclass
   
   initial run_test("test");
   
endmodule
