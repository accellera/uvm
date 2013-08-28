//
//------------------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics
//   Copyright 2011 Cadence
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
//------------------------------------------------------------------------------

module top();

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit block_bit;

  class my_item extends uvm_sequence_item;
    int int_param;
    `uvm_object_utils_begin(my_item)
      `uvm_field_int(int_param, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "unnamed-my_item");
      super.new(name);
    endfunction
  endclass

  class my_sequence extends uvm_sequence #(my_item);
    string param;
    `uvm_object_utils_begin(my_sequence)
      `uvm_field_string(param, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "my_sequence");
      super.new(name);
    endfunction
    task pre_body();
      `uvm_info(get_type_name(), $sformatf("pre_body starting"), UVM_HIGH)
    endtask
    task body();
      `uvm_info("SEQ", {"param = ", param}, UVM_LOW)
        if (param != "BAR")
          `uvm_error("SEQ", {"param is ", param, " expected BAR"})
      `uvm_info(get_type_name(), $sformatf("body starting"), UVM_HIGH)
      #100;
      `uvm_do(req)
      `uvm_info("SEQ", $sformatf("req.int_param = %0d", req.int_param), UVM_LOW)
      if (req.int_param != 15)
          `uvm_error("SEQ", $sformatf("req.int_param is %0d. expected 15", req.int_param))
      `uvm_info(get_type_name(), $sformatf("item done, sequence is finishing"), UVM_HIGH)
    endtask
  endclass

  class top_seq extends uvm_sequence #(my_item);
    string param;
           
    `uvm_object_utils_begin(top_seq)
      `uvm_field_string(param, UVM_ALL_ON)
    `uvm_object_utils_end

     my_sequence seq;
     
    function new(string name = "top_seq");
      super.new(name);
    endfunction
    task pre_body();
      `uvm_info(get_type_name(), $sformatf("pre_body starting"), UVM_HIGH)
    endtask
    task body();
      `uvm_info(get_type_name(), $sformatf("body starting"), UVM_HIGH)
      `uvm_info("SEQ", {"param = ", param}, UVM_LOW)
        if (param != "FOO")
          `uvm_error("SEQ", {"param is ", param, " expected FOO"})
      #100;
       `uvm_create(seq)
       `uvm_do(seq);
    endtask
  endclass

  class my_sequencer extends uvm_sequencer #(my_item);
    `uvm_component_utils(my_sequencer)

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
    `uvm_component_utils(my_agent)

    my_sequencer ms;
    my_driver md;

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
      uvm_config_db#(string)::set(this,"*", "param", "FOO");
      uvm_config_db#(string)::set(this,"ma0.ms.the_0seq.seq", "param", "BAR");
      uvm_config_db#(int)::set(this,"*", "int_param", 15);
    endfunction

    task run_phase(uvm_phase phase);
      top_seq the_0seq;
      phase.raise_objection(this);
      the_0seq = top_seq::type_id::create("the_0seq", this);
      the_0seq.start(ma0.ms);
      phase.drop_objection(this);
    endtask

   function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction

  endclass

  initial
    run_test();

endmodule
