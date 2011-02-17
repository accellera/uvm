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


  class my_item extends uvm_sequence_item;
    `uvm_object_utils(my_item)
    function new(string name = "my_item_");
      super.new(name);
    endfunction
  endclass


  typedef class my_sequencer;
  typedef class my_driver;


  class my_sequence extends uvm_sequence #(my_item);
    `uvm_object_utils(my_sequence)
    `uvm_declare_p_sequencer(my_sequencer)
    function new(string name = "my_sequence");
      super.new(name);
    endfunction
    task body();
      $display("%t %s body() starting", $time, get_type_name());
      `uvm_do(req)
      $display("%t %s body() ending", $time, get_type_name());
    endtask
    function bit is_relevant();
      $display("%t %s relevant check! %0b", $time, get_type_name(), p_sequencer.rel_var);
      return p_sequencer.rel_var;
    endfunction
    task wait_for_relevant();
      @(p_sequencer.rel_var);
    endtask
  endclass



  class my_sequencer extends uvm_sequencer #(my_item);
    bit rel_var = 1;
    `uvm_component_utils(my_sequencer)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  
  time try_return_time;


  class my_driver extends uvm_driver #(my_item);
    `uvm_component_utils(my_driver)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1;
      $display("%t calling try_next_item...", $time);
      seq_item_port.try_next_item(req);
      $display("%t back from try_next_item...", $time);
      if (req != null) begin
        req.print();
        $display("%t try_next_item completed", $time);
        seq_item_port.item_done();
      end
      else begin
        try_return_time = $time;
        $display("%t try_next_item returned null", $time);
      end
      phase.drop_objection(this);
    endtask
  endclass



  
  class test extends uvm_test;

    my_sequencer ms0;
    my_driver md0;

    `uvm_component_utils_begin(test)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build();
      super.build();
      ms0 = my_sequencer::type_id::create("ms0", this);
      md0 = my_driver::type_id::create("md0", this);
    endfunction

    function void connect();
      md0.seq_item_port.connect(ms0.seq_item_export);
    endfunction

    task run_phase(uvm_phase phase);
      my_sequence the_seq;
      the_seq = my_sequence::type_id::create("the_seq", this);
      phase.raise_objection(this);
      fork
        the_seq.start(ms0);
      join_none
      #1;
      for (int i = 0; i < 6; i++) begin
        #0;
      end
      ms0.rel_var = 0;
      #300;
      ms0.rel_var = 1;
      phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
      if (try_return_time == 1)
        $display("UVM TEST PASSED");
      else
        $display("UVM TEST FAILED");
    endfunction

  endclass

  initial run_test();

endmodule

