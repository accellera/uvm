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

//-------------------------------------------------------
//
//                 top0        top1
//                  |           |
// :---------:      |           |
// |test_base| --:--:--:-----:--:--:---seqr0
// :---------:   |     |     |     |
//               |     |     |     |
//              bot0  bot1  bot2  bot3
//
//--------------------------------------------------------


// PRE_RESET_PH sequence
class test_pre_reset_seq extends my_seq;
  `uvm_object_utils(test_pre_reset_seq)

  task body;
    starting_phase.raise_objection(this);
    `uvm_info( "POWER_GOOD", "Waiting for power_good signal.", UVM_NONE);
    #10;
    `uvm_info( "POWER_GOOD", "Done power_good.", UVM_NONE);
    starting_phase.drop_objection(this);
  endtask : body

  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction

  function new(string name="test_pre_reset_seq");
     super.new(name);
  endfunction

endclass : test_pre_reset_seq

// PRE_RESET_PH sequence
class test_reset_seq extends my_seq;
  `uvm_object_utils(test_reset_seq)
  task body;
    starting_phase.raise_objection(this);
    `uvm_info( "HARD_RESET", "Wait for hard reset signal come and go", UVM_NONE);
    #15;
    `uvm_info( "HARD_RESET", "Done hard reset", UVM_NONE);
    starting_phase.drop_objection(this);
  endtask : body
  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction

  function new(string name="test_reset_seq");
     super.new(name);
  endfunction

endclass : test_reset_seq

// TRAINING sequences
class top_training_seq extends top_sequence;
  int unsigned delay  = $urandom_range( 20, 30);
  `uvm_object_utils(top_training_seq)
  task body;
    starting_phase.raise_objection(this);
    `uvm_info( "TRAINING", "Doing TOP interface training.", UVM_NONE);
    #(delay);
    `uvm_info( "TRAINING", "Done TOP training.", UVM_NONE);
    starting_phase.drop_objection(this);
  endtask : body
  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction

  function new(string name="top_training_seq");
     super.new(name);
  endfunction

endclass : top_training_seq

class bot_training_seq extends bot_sequence;
  int unsigned delay  = $urandom_range( 20, 30);
  `uvm_object_utils(bot_training_seq)
  task body;
    starting_phase.raise_objection(this);
    `uvm_info( "TRAINING", "Doing BOTTOM interface training.", UVM_NONE);
    #(delay);
    `uvm_info( "TRAINING", "Done BOTTOM training.", UVM_NONE);
    starting_phase.drop_objection(this);
  endtask : body
  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction

  function new(string name="bot_training_seq");
     super.new(name);
  endfunction

endclass : bot_training_seq

// CONFIG sequences
class top_configure_seq extends top_sequence;
  int unsigned delay  = $urandom_range( 20, 30);
  `uvm_object_utils(top_configure_seq)
  task body;
    starting_phase.raise_objection(this);
    `uvm_info( "CONFIG", $sformatf("Random traffic from %s.",
                                 m_sequencer.get_name()), UVM_NONE);
    for( int i = 1; i< 5; i++) begin
      delay  = $urandom_range( 1, 4); #(delay);
      `uvm_info(get_name(), $sformatf("Doing req #(%1d out of 4) ...", i),UVM_NONE);
      `uvm_do( req );
    end
    `uvm_info( "CONFIG", $sformatf("Done random traffic from %s.",
                                 m_sequencer.get_name()), UVM_NONE);
    starting_phase.drop_objection(this);
  endtask : body
  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction

  function new(string name="top_configure_seq");
     super.new(name);
  endfunction

endclass : top_configure_seq

// MAIN sequences
class top_random_seq extends top_sequence;
  int unsigned delay = $urandom_range( 20, 30);
  `uvm_object_utils(top_random_seq)
  task body;
    starting_phase.raise_objection(this);
    `uvm_info( "MAIN", $sformatf("Random traffic from %s.",
                                 m_sequencer.get_name()), UVM_NONE);
    for( int i = 1; i< 6; i++) begin
      #(4);
      `uvm_info(get_name(), $sformatf("Doing req #(%1d out of 5) ...", i),UVM_NONE);
      `uvm_do( req );
    end
    `uvm_info( "MAIN", $sformatf("Done random traffic from %s.",
                                 m_sequencer.get_name()), UVM_NONE);
    starting_phase.drop_objection(this);
  endtask : body
  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction

  function new(string name="top_random_seq");
     super.new(name);
  endfunction

endclass : top_random_seq

class bot_random_seq extends bot_sequence;
  int unsigned delay = $urandom_range( 20, 30);
  `uvm_object_utils(bot_random_seq)
  task body;
    starting_phase.raise_objection(this);
    `uvm_info( "MAIN", $sformatf("Random traffic from %s.",
                                 m_sequencer.get_name()), UVM_NONE);
    for( int i = 1; i< 7; i++) begin
      #(3);
      `uvm_info(get_name(), $sformatf("Doing req #(%1d out of 6) ...", i),UVM_NONE);
      `uvm_do( req );
    end
    `uvm_info( "MAIN", $sformatf("Done random traffic from %s.",
                                 m_sequencer.get_name()), UVM_NONE);
    starting_phase.drop_objection(this);
  endtask : body
  function void do_kill();
    if(starting_phase.phase_done.get_objection_count(this))
      starting_phase.drop_objection(this);
  endfunction

  function new(string name="bot_random_seq");
     super.new(name);
  endfunction

endclass : bot_random_seq

// MAIN phase imp
class test_base_post_main_phase_imp extends uvm_task_phase;
  `uvm_object_utils( test_base_post_main_phase_imp )
  function new(string n="test_base_post_main_phase" );
    super.new(n);
  endfunction : new

  task exec_task(uvm_component comp, uvm_phase phase);
    `uvm_info( "POST_MAIN", $sformatf("Component %s executing phase %s", comp.get_name(), phase.get_name()), UVM_NONE);
  endtask
endclass : test_base_post_main_phase_imp

//--------------------------------------------------
//  Base test class : set up testbench and phases.
//--------------------------------------------------
class test_base extends uvm_test;
  top_env top0 ;
  top_env top1 ;

  bot_env bot0 ;
  bot_env bot1 ;
  bot_env bot2 ;
  bot_env bot3 ;

  my_seqr seqr0;

  `uvm_component_utils_begin(test_base)
  `uvm_component_utils_end

  function new( string n, uvm_component p = null);
    super.new( n, p);
    $display( "\nTest %s created.\n\n", n );
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    top0 = top_env::type_id::create( "top0", this);
    top1 = top_env::type_id::create( "top1", this);

    bot0 = bot_env::type_id::create( "bot0", this);
    bot1 = bot_env::type_id::create( "bot1", this);
    bot2 = bot_env::type_id::create( "bot2", this);
    bot3 = bot_env::type_id::create( "bot3", this);

    seqr0= my_seqr::type_id::create( "seqr0", this); //virtual sequencer

    // Each bot_env belongs to a separate domain so that
    // it can jump individually.
    //this.set_domain(uvm_domain::get_uvm_domain());

  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    //1 - reset
    uvm_config_wrapper::set(this, "seqr0.pre_reset_phase", "default_sequence", test_pre_reset_seq::type_id::get());
    uvm_config_wrapper::set(this, "seqr0.reset_phase", "default_sequence", test_reset_seq::type_id::get());

    //2a - pre configure - training at the TOP interface
    uvm_config_wrapper::set(this, "top*.*.*sequencer.pre_configure_phase", "default_sequence",
                        top_training_seq::type_id::get());

    //2b - configure - configure the DUT from the TOP interface
    uvm_config_wrapper::set(top0.agent, "sequencer.configure_phase", "default_sequence", top_configure_seq::type_id::get());

    //2c - post_configure - training at the BOT interface
    uvm_config_wrapper::set(this, "bot*.*.*sequencer.post_configure_phase", "default_sequence",
                        bot_training_seq::type_id::get());

    //3 - random traffic from top/bot
    uvm_config_wrapper::set(this, "top*.*.*sequencer.main_phase", "default_sequence",
                        top_random_seq::type_id::get());
    uvm_config_wrapper::set(this, "bot*.*.*sequencer.main_phase", "default_sequence",
                        bot_random_seq::type_id::get());

    uvm_config_wrapper::set(this, ".post_main_phase", "default_sequence", test_base_post_main_phase_imp::type_id::get());

  endfunction : connect_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();

    $display( "//--------------------------------------------------------\n",
              "//                                                        \n",
              "//                    top0        top1                    \n",
              "//                     |           |                      \n",
              "// :------------:      |           |                      \n",
              "// |uvm_test_top| --:--:--:-----:--:--:---seqr0           \n",
              "// :------------:   |     |     |     |                   \n",
              "//                  |     |     |     |                   \n",
              "//                 bot0  bot1  bot2  bot3                 \n",
              "//                                                        \n",
              "//--------------------------------------------------------\n");
  endfunction : end_of_elaboration_phase

  function void report_phase(uvm_phase phase);
    uvm_report_server svr = _global_reporter.get_report_server();
    svr.summarize();

    if (svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) == 0) begin
      `uvm_info("REPORT", "** UVM TEST PASSED **\n", UVM_NONE);
    end else begin
      `uvm_info("REPORT", "!! UVM TEST FAILED !!\n", UVM_NONE);
    end
  endfunction : report_phase

  //Debug messages when phase started & ended
  function void phase_started( uvm_phase phase);
    `uvm_info( phase.get_name(), $sformatf( "Phase %s() STARTED ----------------------------",
                                   phase.get_name()), UVM_NONE);
    super.phase_started( phase );

  endfunction : phase_started

  function void phase_ended( uvm_phase phase);
    super.phase_ended( phase );
    `uvm_info( phase.get_name(), $sformatf( "Phase %s() ENDED  ----------------------------\n\n",
                                   phase.get_name()), UVM_NONE);
  endfunction : phase_ended

endclass : test_base
