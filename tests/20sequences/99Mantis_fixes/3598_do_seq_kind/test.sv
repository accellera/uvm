//
//------------------------------------------------------------------------------
//   Copyright 2011 cadence
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
// -*- focus : do_seq_kind leads to SEQNOTITM
module top();

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class my_item extends uvm_sequence_item;
    rand bit[7:0] addr;
    `uvm_object_utils_begin(my_item)
      `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "unnamed-my_item");
      super.new(name);
    endfunction
  endclass

  class my_sub_sequence extends uvm_sequence #(my_item);
    `uvm_object_utils(my_sub_sequence)
    function new(string name = "my_sub_sequence");
      super.new(name);
    endfunction
    task body();
	my_item m;
	`uvm_do(m)
    endtask
  endclass  

  class my_sequence extends uvm_sequence #(my_item);
    `uvm_object_utils(my_sequence)
    function new(string name = "my_sequence");
      super.new(name);
    endfunction // new
    task body();
       $display("FOO");
begin
       
       my_sequence s;
       
        uvm_phase phase=get_starting_phase();       
       $display("BLA");
        phase.raise_objection(this); 
       
        begin    
 	uvm_sequence#(my_item) s = my_sub_sequence::type_id::create("seq");
	`uvm_info("MANTIS","now doing do_sequence_kind",UVM_NONE)
	`uvm_do(s)
	end
        phase.drop_objection(this);
   end
    endtask
  endclass

  class my_driver extends uvm_driver #(my_item);
    `uvm_component_utils(my_driver)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        #100;
        seq_item_port.item_done();
      end
    endtask
  endclass

  class my_agent extends uvm_agent;
    `uvm_component_utils(my_agent)

    uvm_sequencer #(my_item) ms;
    my_driver md;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ms = uvm_sequencer #(my_item)::type_id::create("ms", this);
      md = my_driver::type_id::create("md", this);
    endfunction

    function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
      md.seq_item_port.connect(ms.seq_item_export);
    endfunction
  endclass
  
  class test extends uvm_test;
    `uvm_component_utils(test)

    my_agent ma0;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase); 
      super.build();
      ma0 = my_agent::type_id::create("ma0", this);
      uvm_config_string::set(this, "ma0.ms","default_sequence","my_sequence");
    endfunction

    function void report_phase(uvm_phase phase);
      `uvm_info("MANTIS","UVM TEST PASSED",UVM_NONE)
      `uvm_info(get_type_name(), $sformatf("The topology:\n%s", this.sprint()), UVM_HIGH)
    endfunction
  endclass

  initial
    run_test();

endmodule
