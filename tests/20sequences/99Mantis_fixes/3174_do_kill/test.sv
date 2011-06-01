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

module test();

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit kill_test_bit;

  class my_item extends uvm_sequence_item;
    rand bit[7:0] addr;
    `uvm_object_utils_begin(my_item)
      `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "unnamed-my_item");
      super.new(name);
    endfunction
  endclass

  typedef class my_sequencer;

  class my_sequence extends uvm_sequence #(my_item);
    `uvm_object_utils(my_sequence)
    `uvm_declare_p_sequencer(my_sequencer)
    function new(string name = "my_sequence");
      super.new(name);
    endfunction
    task body();
      `uvm_info(get_type_name(), $sformatf("body starting, raising my objection"), UVM_HIGH)
      uvm_test_done.raise_objection(this);
      #1000;
      //`uvm_do(req)
      `uvm_info(get_type_name(), $sformatf("item done, sequence is finishing"), UVM_HIGH)
    endtask
    function void do_kill();
      `uvm_info(get_type_name(), $sformatf("kill done, dropping my objection"), UVM_HIGH)
      uvm_test_done.drop_objection(this);
      kill_test_bit = 1;
    endfunction
  endclass

  class my_sequencer extends uvm_sequencer #(my_item);
    `uvm_component_utils_begin(my_sequencer)
    `uvm_component_utils_end
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass
  
  class my_driver extends uvm_driver #(my_item);
    `uvm_component_utils(my_driver)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run();
      forever begin
        seq_item_port.get_next_item(req);
        `uvm_info(get_type_name(), $sformatf("Request is:\n%s", req.sprint()), UVM_HIGH)
        #100;
        seq_item_port.item_done();
      end
    endtask
  endclass

  class my_agent extends uvm_agent;
    my_sequencer ms;
    my_driver md;
    `uvm_component_utils(my_agent)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    function void build();
      super.build();
      ms = my_sequencer::type_id::create("ms", this);
      md = my_driver::type_id::create("md", this);
    endfunction
    function void connect();
      md.seq_item_port.connect(ms.seq_item_export);
    endfunction
  endclass
  
  class test extends uvm_test;
    my_agent ma0;
    `uvm_component_utils_begin(test)
    `uvm_component_utils_end
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
      fork
        the_0seq.start(ma0.ms);
      join_none
      if (kill_test_bit != 0) begin
        `uvm_error("BADBIT", "kill_test_bit is not 0");
      end
      #500;
      the_0seq.kill();
      if (kill_test_bit != 1) begin
        `uvm_error("BADBIT", "kill_test_bit is not 1");
      end
      #1000;
      uvm_test_done.drop_objection(this);
    endtask
    function void report();
      if(kill_test_bit == 1)
        $display("** UVM TEST PASSED **");
    endfunction
  endclass

  initial begin
    run_test();
  end

endmodule
