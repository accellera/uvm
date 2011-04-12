//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
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

  `include "simple_item.sv"
  `include "simple_sequencer.sv"
  `include "simple_driver.sv"
  `include "simple_seq_lib.sv"

  class test extends uvm_test;

     `uvm_component_utils(test)

     function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
     endfunction

     task run_phase(uvm_phase phase);
        phase.raise_objection(null);
        #2000;
        phase.drop_objection(null);
     endtask
  endclass

  simple_sequencer sequencer;
  simple_driver driver;

  initial begin
    set_config_string("sequencer", "default_sequence", "simple_seq_sub_seqs");
    sequencer = new("sequencer", null); sequencer.build();
    driver = new("driver", null); driver.build();
    driver.seq_item_port.connect(sequencer.seq_item_export);
    uvm_default_printer=uvm_default_tree_printer;
    sequencer.print();
    driver.print();

    run_test("test");
  end

endmodule
