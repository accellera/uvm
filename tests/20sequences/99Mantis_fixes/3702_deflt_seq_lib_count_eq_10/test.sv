//----------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc.
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

import uvm_pkg::*;
`include "uvm_macros.svh"

module top;

  `include "simple_item.sv"
  `include "simple_sequencer.sv"
  `include "simple_driver.sv"

  class simple_seq extends uvm_sequence #(simple_item);
      function new(string name="simple_seq");
        super.new(name);
      endfunction
      `uvm_object_utils(simple_seq)
      virtual task body();
        `uvm_info("SEQ_START", {"Executing sequence '",
           get_full_name(),"' (",get_type_name(),")"},UVM_NONE)
        #1;
      endtask
  endclass


  class simple_seq_lib extends uvm_sequence_library #(simple_item);

      `uvm_object_utils(simple_seq_lib)

      `uvm_sequence_library_utils(simple_seq_lib)

      function new(string name="");
        simple_seq seq;
        super.new(name);
        seq = new("simple_seq");
        add_sequence(simple_seq::get_type());
      endfunction

  endclass



  // SIMPLE TEST COMPONENT
  //
  // Normal component in most respects. Test infrastructure
  // requires top-level component be called 'test'

  class test extends uvm_component;

     `uvm_component_utils(test)

     function new(string name, uvm_component parent=null);
       super.new(name,parent);
     endfunction

     simple_sequencer sequencer;
     simple_driver driver;

     virtual function void build_phase(uvm_phase phase);
       sequencer = new("sequencer", this);
       driver = new("driver", this);
       uvm_default_printer=uvm_default_line_printer;
     endfunction

     virtual function void connect_phase(uvm_phase phase);
       driver.seq_item_port.connect(sequencer.seq_item_export);
     endfunction

     virtual task run_phase(uvm_phase phase);
       simple_seq_lib seq = new("simple_seq_lib");
       phase.raise_objection(this);
       seq.start(sequencer);
       phase.drop_objection(this);
     endtask

     virtual function void report();
       uvm_root top = uvm_root::get();
       uvm_report_server svr = top.get_report_server();
       if (svr.get_id_count("SEQ_START") != 10) begin
         `uvm_error("SEQ_COUNT_NOT_10",$sformatf("Expected 10 sequences. Got %0d",svr.get_id_count("SEQ_START")))
       end
       if (svr.get_severity_count(UVM_FATAL) +
           svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
       else
         $write("** UVM TEST FAILED **\n");
     endfunction

  endclass


  // TEST CONFIGURATION.
  //
  // This could be inside the test class.

  // NOTE: SEQUENCE INSTANCES, NOT TYPES
  typedef uvm_config_db #(uvm_sequence_base) phase_rsrc;

  initial begin
    run_test();
  end

endmodule
