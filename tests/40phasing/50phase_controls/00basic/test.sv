//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
//   Copyright 2011 Cadence Design Systems, Inc.
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

`include "uvm_macros.svh"
module top;
  import uvm_pkg::*;

class basic_item extends uvm_sequence_item;
  rand int unsigned addr; constraint c1 { addr < 16'h1500; }
  rand int unsigned data; constraint c2 { data < 16'h2500; }

  `uvm_object_utils_begin(basic_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "basic_item");
    super.new(name);
  endfunction : new

endclass : basic_item

class basic_driver extends uvm_driver #(basic_item);
  `uvm_component_utils(basic_driver)
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task get_and_send();
    forever begin
      #10;

      seq_item_port.get_next_item(req);
      `uvm_info("Driver", $sformatf("Printing received item, addr=%1d, data=%1d",
                                    req.addr, req.data), UVM_NONE);
      seq_item_port.item_done();
    end
  endtask : get_and_send

  task run_phase (uvm_phase phase);
    get_and_send();
  endtask: run_phase

  task post_shutdown_phase(uvm_phase phase);
    //Should stop accepting and sending request here.
    disable get_and_send;
  endtask : post_shutdown_phase

endclass : basic_driver

class basic_sequencer extends uvm_sequencer #(basic_item);
  function new (string name, uvm_component parent);
    super.new(name, parent);
    `uvm_update_sequence_lib_and_item(basic_item)
    count = 0;
  endfunction : new
  `uvm_sequencer_utils(basic_sequencer)
endclass : basic_sequencer

class basic_default_seq extends uvm_sequence #(basic_item);
  function new(string name="basic_default_seq");
    super.new(name);
  endfunction

  `uvm_object_utils(basic_default_seq)

  virtual task body();
    starting_phase.raise_objection(this);
    for( int i=1; i< 4; i++) begin
      `uvm_info(get_name(), $sformatf("In body() of %s, doing req #(%1d out of 3) ...",
                                      get_name(), i ),UVM_NONE);
      `uvm_do(req)
    end
    starting_phase.drop_objection(this);
  endtask
  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction
endclass : basic_default_seq

class basic_seq extends uvm_sequence #(basic_item);
  function new(string name="basic_seq");
    super.new(name);
  endfunction

  `uvm_object_utils(basic_seq)

  virtual task body();
    if(starting_phase != null) starting_phase.raise_objection(this);
    for( int i=1; i< 9; i++) begin
      #(i+1);
      `uvm_info(get_name(), $sformatf("In body() of %s, doing req #(00%1d out of 8) ...",
                                      get_name(), i ),UVM_NONE);
      `uvm_do(req)       //This sequence would run fine if this line is commented out.
    end
    if(starting_phase != null) starting_phase.drop_objection(this);
  endtask
  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction
endclass : basic_seq

class basic_main_phase_seq extends uvm_sequence #(basic_item);
  function new(string name="basic_main_phase_seq");
    super.new(name);
  endfunction

  `uvm_object_utils(basic_main_phase_seq)

  virtual task body();
    starting_phase.raise_objection(this);
    for( int i=1; i< 13; i++) begin
      #(i+1);
      `uvm_info(get_name(), $sformatf("In body() of %s, doing req #(__%1d out of 12) ...",
                                      get_name(), i ),UVM_NONE);
      `uvm_do(req)       //This sequence would run fine if this line is commented out.
    end
    starting_phase.drop_objection(this);
  endtask
  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction
endclass : basic_main_phase_seq

class test extends uvm_test;
  basic_sequencer sequencer;
  basic_driver    driver;

  `uvm_component_utils_begin( test );
  `uvm_component_utils_end

  function new( string n, uvm_component p = null);
    super.new( n, p);
    $display( "\nTest %s created.\n\n", n );
  endfunction : new

  function void build();
    super.build();
//    set_config_string("sequencer", "default_sequence", "basic_default_seq");

    sequencer = basic_sequencer::type_id::create("sequencer", this);
    driver    = basic_driver::type_id::create("driver", this);

    this.print();
  endfunction : build

  typedef uvm_config_db #(uvm_sequence_base) sequence_rsrc;

  function void connect_phase(uvm_phase phase);
    basic_seq seq = new;
    super.connect();
    void'(seq.randomize());
    driver.seq_item_port.connect(sequencer.seq_item_export);
    sequence_rsrc::set(this, "seqr1.main_phase", "default_sequence", seq);
  endfunction : connect_phase

  virtual task run_phase(uvm_phase phase);
    //basic_seq run_seq; run_seq = new( "basic_seq_in_run" ); run_seq.start( sequencer );
    //`uvm_info( "RUN", "Done run phase", UVM_NONE );
  endtask : run_phase

  virtual task main_phase(uvm_phase phase);
    basic_seq main_seq; main_seq = new( "basic_seq_in_main" ); main_seq.start( sequencer );
    `uvm_info( "RUN", "Done main phase", UVM_NONE );
  endtask : main_phase

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    svr = _global_reporter.get_report_server();

    svr.summarize();

    if (svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) == 0) begin
      `uvm_info("REPORT", "** UVM TEST PASSED **\n", UVM_NONE);
    end else begin
      `uvm_info("REPORT", "!! UVM TEST FAILED !!\n", UVM_NONE);
    end
  endfunction : report_phase

  function void phase_started( uvm_phase phase);
    `uvm_info( "PHASE", $sformatf( "Phase %s() STATED ----------------------------\n",
                                   phase.get_name()), UVM_NONE);
    super.phase_started( phase );
  endfunction : phase_started

  function void phase_ended( uvm_phase phase);
    super.phase_ended( phase );
    `uvm_info( "PHASE", $sformatf( "Phase %s() ENDED  ----------------------------\n",
                                   phase.get_name()), UVM_NONE);
  endfunction : phase_ended
endclass : test

  initial begin
    fork
      run_test();

      #2000 begin
        $display( "\n\nTIME OUT");
        uvm_top.stop_request(); //timeout.
      end
    join
  end
endmodule : top
