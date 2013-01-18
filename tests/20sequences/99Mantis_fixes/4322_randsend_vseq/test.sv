//----------------------------------------------------------------------
//   Copyright 2010-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Mentor Graphics Corporation
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

module test218;
   import uvm_pkg::*;

class simple_item extends uvm_sequence_item;
   `uvm_object_utils(simple_item)
   function new (string name="simple_item");
      super.new(name);
   endfunction 
endclass

class simple_sub_seq extends uvm_sequence #(simple_item);
   `uvm_declare_p_sequencer(uvm_sequencer#(simple_item))
   function new(string name="simple_sub_seq");
      super.new(name);
   endfunction
   `uvm_object_utils(simple_sub_seq)    
   virtual task body();
      repeat(3)
	#10  `uvm_do(req)
   endtask
endclass 

class simple_driver extends uvm_driver #(simple_item);
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   `uvm_component_utils(simple_driver)
   task run_phase(uvm_phase phase);
      forever begin
	 seq_item_port.get_next_item(req);
	 `uvm_info("TEST","getting next item...",UVM_MEDIUM)
	 #100;
	 seq_item_port.item_done(req);
      end
   endtask
endclass

class simple_vseq extends uvm_sequence #(uvm_sequence_item);
   uvm_sequencer#(simple_item) sqr[2];
   function new(string name="simple_vseq");
      super.new(name);
   endfunction
   `uvm_object_utils(simple_vseq)    
   virtual task body();
      simple_sub_seq a;
      repeat(20)
	begin
	   `uvm_create_on(a,sqr[0])
	   `uvm_rand_send_with(a,{})
	end
   endtask
endclass 


class test extends uvm_test;

   uvm_sequencer#(simple_item) lsqr[2];
   simple_driver driver[2];
   uvm_sequencer#(uvm_sequence_item) vsqr;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   `uvm_component_utils(test)

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      foreach(lsqr[idx]) lsqr[idx] = new($sformatf("lsqr%0d",idx),this);
      foreach(driver[idx]) driver[idx] = new($sformatf("driver%0d",idx),this);

      foreach(lsqr[idx]) driver[idx].seq_item_port.connect(lsqr[idx].seq_item_export);

      vsqr = new("vseq",this);
   endfunction

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      begin
	 simple_vseq v = new("vseq");
	 v.sqr = lsqr;
	 v.start(vsqr);

	 v.start(null);
	 
      end
      phase.drop_objection(this);
   endtask // run_phase

   function void report();
      `uvm_info("MANTIS","*** UVM TEST PASSED ***",UVM_NONE)
   endfunction

endclass

   initial begin
      run_test();
   end

endmodule


