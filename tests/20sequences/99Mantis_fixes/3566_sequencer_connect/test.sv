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
// -*- focus : connect is ignored in uvm_sequencers
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

  class my_sequencer extends uvm_sequencer #(my_item);
    `uvm_component_utils(my_sequencer)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    virtual function void connect();
        super.connect();
        `uvm_info("MANTIS","UVM TEST PASSED",UVM_NONE)
    endfunction
  endclass
  
  class my_sequence extends uvm_sequence #(my_item);
    my_sequencer target_sqr;
    `uvm_object_utils(my_sequence)
    function new(string name = "my_sequence");
      super.new(name);
    endfunction
    task body();
        my_item m;   
        uvm_test_done.raise_objection(this);     
        `uvm_create_on(m, target_sqr)
        `uvm_send(m)
        uvm_test_done.drop_objection(this);     
    endtask
  endclass


  
  class my_driver extends uvm_driver #(my_item);
    `uvm_component_utils(my_driver)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task run();
      forever begin
        seq_item_port.get_next_item(req);
        #100;
        seq_item_port.item_done();
      end
    endtask
  endclass

  class my_agent extends uvm_agent;
    `uvm_component_utils(my_agent)

    my_sequencer ms;
    my_sequencer vsqr;       
    my_driver md;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build();
      super.build();
      ms = my_sequencer::type_id::create("ms", this);
      md = my_driver::type_id::create("md", this);
      vsqr = my_sequencer::type_id::create("vsqr", this);
    endfunction

    function void connect();
      md.seq_item_port.connect(ms.seq_item_export);
    endfunction
  endclass

  
  class test extends uvm_test;
    `uvm_component_utils(test)

    my_agent ma0;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build();
      super.build();
      ma0 = my_agent::type_id::create("ma0", this);
    endfunction

    function void end_of_elaboration();
      `uvm_info(get_type_name(), $sformatf("The topology:\n%s", this.sprint()), UVM_HIGH)
    endfunction

    task run();
      my_sequence the_0seq;
      uvm_test_done.raise_objection(this);
      the_0seq = my_sequence::type_id::create("the_0seq", this);
      the_0seq.target_sqr = ma0.ms;
      the_0seq.start(ma0.vsqr);
      uvm_test_done.drop_objection(this);
    endtask
  endclass

  initial
    run_test();

endmodule
