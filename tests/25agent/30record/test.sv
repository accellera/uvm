//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010-2013 Synopsys, Inc.
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
module test;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "simple_agent.sv"
  `include "piped_driver.sv"

  class test extends uvm_test;

    simple_agent agent[3];

    `uvm_component_utils(test)

    function new(string name = "", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      agent[0] = simple_agent::type_id::create("agent[0]", this);
      agent[1] = simple_agent::type_id::create("agent[1]", this);

      uvm_config_db#(uvm_bitstream_t)::set(this, "agent*", "recording_detail", 1);
      set_inst_override_by_type("agent[1].driver", simple_driver::type_id::get(),
                                piped_driver::type_id::get());

      // Stagger the sequences to avoid race conditions in the DB
      uvm_config_db#(uvm_object_wrapper)::set(this, "agent[0].sequencer.pre_main_phase", "default_sequence",
                                              simple_triple_do::type_id::get());
      uvm_config_db#(uvm_object_wrapper)::set(this, "agent[1].sequencer.main_phase", "default_sequence",
                                              simple_triple_do::type_id::get());

    endfunction

    // Make sure all pipelined transactions complete
    task shutdown_phase(uvm_phase phase);
      super.shutdown_phase(phase);
      phase.raise_objection(this);
      #100;
      phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
      uvm_coreservice_t cs_;
      uvm_report_server svr;
      cs_ = uvm_coreservice_t::get();
      svr = cs_.get_report_server();
      
      if (svr.get_severity_count(UVM_FATAL) == 0 &&
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
    endfunction

  endclass // test
   
class my_simple_item extends simple_item;
  static int unsigned x = 'hdeadbeef;
 function new (string name = "simple_item");
    super.new(name);
 endfunction : new
   function void post_randomize();
      addr=x;
      data=x+1;

      x = x ^ (x << 2);
   endfunction // post_generate
   `uvm_object_utils(my_simple_item)
endclass // my_simple_item


  initial begin
    uvm_default_printer=uvm_default_tree_printer;
    $system("rm -fr tr_db.log");
     simple_item::type_id::set_type_override(my_simple_item::get_type());

    run_test("test");
  end

endmodule
