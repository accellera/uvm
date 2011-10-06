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

typedef enum { BOT_WRITE, BOT_READ } bot_cmd_t;

class bot_item extends uvm_sequence_item;
  rand bot_cmd_t cmd;
  rand int unsigned addr; constraint c1 { addr < 16'h1500; }
  rand int unsigned data; constraint c2 { data < 16'h2500; }

  `uvm_object_utils_begin( bot_item)
    `uvm_field_enum (bot_cmd_t, cmd, UVM_ALL_ON);
  `uvm_object_utils_end

  function new( string name = "bot_item" );
    super.new( name );
  endfunction : new

endclass : bot_item

class bot_sequencer extends uvm_sequencer #(bot_item);
  `uvm_component_utils(bot_sequencer)

  // new - constructor
  function new (string name="bot_sequencer", uvm_component parent);
    super.new(name, parent);
    count = 0;
  endfunction : new
endclass : bot_sequencer

class bot_sequence extends uvm_sequence #(bot_item);
  `uvm_object_utils_begin(bot_sequence)
    `uvm_field_object ( req, UVM_ALL_ON )
  `uvm_object_utils_end


  function new(string name="bot_sequence");
     super.new(name);
  endfunction

endclass : bot_sequence

class bot_driver extends uvm_driver#(bot_item);
  `uvm_component_utils_begin(bot_driver)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual task run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join_none;
  endtask : run_phase

  // get_and_drive
  virtual protected task get_and_drive();
    bot_item  this_item;

    forever begin
      seq_item_port.get_next_item(this_item); // Get the next data item the sequencer
      drive_item(this_item);                  // Drive it to the pins
      seq_item_port.item_done();              // Give the control back the the sequencer
    end
  endtask : get_and_drive

  // reset_signals
  virtual protected task reset_signals();
    //forever begin
    //Wait for the reset events (pre_reset_phase, reset_phase, post_reset_phase)
    //disable drive_item;
    //end
  endtask : reset_signals

  // drive_item
  virtual protected task drive_item (bot_item item);
    void'(item.begin_tr( $time ));
    #(3);
    `uvm_info( "BOT_DRIVE", $sformatf("Done driving item %s, addr=%X, data=%X ",
                                      item.cmd.name(), item.addr, item.data), UVM_NONE);
    //item.print();
  endtask : drive_item

  task stop_driving();
    disable get_and_drive;
    disable reset_signals;
  endtask : stop_driving

  task post_shutdown_phase(uvm_phase phase);
    phase.raise_objection(this);
    stop_driving();
    phase.drop_objection(this);
  endtask : post_shutdown_phase

endclass : bot_driver

class bot_agent extends uvm_agent;
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;

  bot_driver    driver;
  bot_sequencer sequencer;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(bot_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(is_active == UVM_ACTIVE) begin
      sequencer  = bot_sequencer::type_id::create( {get_name(), "_sequencer"}, this);
      driver = bot_driver::type_id::create( {get_name(), "_driver"}, this);
    end
  endfunction : build_phase

  // connect_phase
  function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : bot_agent

class bot_env extends uvm_env;
  bot_agent agent;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(bot_env)
  `uvm_component_utils_end

  // new - constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase
  function void build_phase(uvm_phase phase);
    agent  = bot_agent::type_id::create( get_name(), this);
  endfunction : build_phase

  //Debug messages when phase started & ended
  function void phase_started( uvm_phase phase);
    `uvm_info( "PHASE", $sformatf( "Phase %s() STARTED ----------------------------",
                                   phase.get_name()), UVM_MEDIUM);
    super.phase_started( phase );

  endfunction : phase_started

  function void phase_ended( uvm_phase phase);
    super.phase_ended( phase );
    `uvm_info( "PHASE", $sformatf( "Phase %s() ENDED  ----------------------------",
                                   phase.get_name()), UVM_MEDIUM);
  endfunction : phase_ended

endclass : bot_env
