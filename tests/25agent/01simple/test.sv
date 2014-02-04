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

  class test extends uvm_test;

    simple_agent agent;

     `uvm_component_utils(test)

     function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
     endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      agent = simple_agent::type_id::create("agent", this);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);

      uvm_config_db#(uvm_object_wrapper)::set(agent.sequencer, "run_phase", "default_sequence",
                                              simple_seq_sub_seqs::type_id::get());
    endfunction


    task run_phase(uvm_phase phase);
      phase.raise_objection(null);
      print();
      #2000;
      phase.drop_objection(null);
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

  endclass

  initial begin
    uvm_default_printer=uvm_default_tree_printer;

    run_test("test");
  end

endmodule
