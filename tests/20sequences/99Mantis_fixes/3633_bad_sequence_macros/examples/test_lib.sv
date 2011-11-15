//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
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

`include "ubus_example_tb.sv"


// Base Test
class ubus_example_base_test extends uvm_test;

  `uvm_component_utils(ubus_example_base_test)

  ubus_example_tb ubus_example_tb0;
  uvm_table_printer printer;
  bit test_pass = 1;

  function new(string name = "ubus_example_base_test", 
    uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Enable transaction recording for everything
    uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
    // Create the tb
    ubus_example_tb0 = ubus_example_tb::type_id::create("ubus_example_tb0", this);
    // Create a specific depth printer for printing the created topology
    printer = new();
    printer.knobs.depth = 3;
  endfunction : build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    // Set verbosity for the bus monitor for this demo
     if(ubus_example_tb0.ubus0.bus_monitor != null)
       ubus_example_tb0.ubus0.bus_monitor.set_report_verbosity_level(UVM_FULL);
    `uvm_info(get_type_name(),
      $sformatf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
  endfunction : end_of_elaboration_phase

  task run_phase(uvm_phase phase);
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);
  endtask : run_phase

  function void extract_phase(uvm_phase phase);
    if(ubus_example_tb0.scoreboard0.sbd_error)
      test_pass = 1'b0;
  endfunction // void
  
  function void report_phase(uvm_phase phase);
    if(test_pass) begin
      `uvm_info(get_type_name(), "** UVM TEST PASSED **", UVM_NONE)
    end
    else begin
      `uvm_error(get_type_name(), "** UVM TEST FAIL **")
    end
  endfunction

endclass : ubus_example_base_test


// Read Modify Write Read Test
class test_read_modify_write extends ubus_example_base_test;

  `uvm_component_utils(test_read_modify_write)

  function new(string name = "test_read_modify_write", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    uvm_config_db#(uvm_object_wrapper)::set(this,
		    "ubus_example_tb0.ubus0.masters[0].sequencer.run_phase", 
			       "default_sequence",
				read_modify_write_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,
		    "ubus_example_tb0.ubus0.slaves[0].sequencer.run_phase", 
			       "default_sequence",
				slave_memory_seq::type_id::get());
    // Create the tb
    super.build_phase(phase);
  end
  endfunction : build_phase

endclass : test_read_modify_write


// Large word read/write test
class test_r8_w8_r4_w4 extends ubus_example_base_test;

  `uvm_component_utils(test_r8_w8_r4_w4)

  function new(string name = "test_r8_w8_r4_w4", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
		      "ubus_example_tb0.ubus0.masters[0].sequencer.run_phase", 
			       "default_sequence",
				r8_w8_r4_w4_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this,
		      ".ubus_example_tb0.ubus0.slaves[0].sequencer.run_phase", 
			       "default_sequence",
				slave_memory_seq::type_id::get());
  end
  endfunction : build_phase

endclass : test_r8_w8_r4_w4 


// 2 Master, 4 Slave test
class test_2m_4s extends ubus_example_base_test;

  `uvm_component_utils(test_2m_4s)

  function new(string name = "test_2m_4s", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
     loop_read_modify_write_seq lrmw_seq;

  begin
    // Overides to the ubus_example_tb build_phase()
    // Set the topology to 2 masters, 4 slaves
    uvm_config_db#(int)::set(this,"ubus_example_tb0.ubus0", 
			       "num_masters", 2);
    uvm_config_db#(int)::set(this,"ubus_example_tb0.ubus0", 
			       "num_slaves", 4);
     
   // Control the number of RMW loops
    uvm_config_db#(int)::set(this,"ubus_example_tb0.ubus0.masters[0].sequencer.loop_read_modify_write_seq", "itr", 6);
    uvm_config_db#(int)::set(this,"ubus_example_tb0.ubus0.masters[1].sequencer.loop_read_modify_write_seq", "itr", 8);

     // Define the sequences to run in the run phase
    uvm_config_db#(uvm_object_wrapper)::set(this,"*.ubus0.masters[0].sequencer.main_phase", 
			       "default_sequence",
				loop_read_modify_write_seq::type_id::get());
     lrmw_seq = loop_read_modify_write_seq::type_id::create();
    uvm_config_db#(uvm_sequence_base)::set(this,
			       "ubus_example_tb0.ubus0.masters[1].sequencer.main_phase", 
			       "default_sequence",
				lrmw_seq);

     for(int i = 0; i < 4; i++) begin
	string slname;
	$swrite(slname,"ubus_example_tb0.ubus0.slaves[%0d].sequencer", i);
	uvm_config_db#(uvm_object_wrapper)::set(this, {slname,".run_phase"}, 
						  "default_sequence",
						  slave_memory_seq::type_id::get());
     end
     
    // Create the tb
    super.build_phase(phase);
  end
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    // Connect other slaves monitor to scoreboard
    ubus_example_tb0.ubus0.slaves[1].monitor.item_collected_port.connect(
      ubus_example_tb0.scoreboard0.item_collected_export);
    ubus_example_tb0.ubus0.slaves[2].monitor.item_collected_port.connect(
      ubus_example_tb0.scoreboard0.item_collected_export);
    ubus_example_tb0.ubus0.slaves[3].monitor.item_collected_port.connect(
      ubus_example_tb0.scoreboard0.item_collected_export);
  endfunction : connect_phase
  
  function void end_of_elaboration_phase(uvm_phase phase);
    // Set up slave address map for ubus0 (slaves[0] is overwritten here)
    ubus_example_tb0.ubus0.set_slave_address_map("slaves[0]", 16'h0000, 16'h3fff);
    ubus_example_tb0.ubus0.set_slave_address_map("slaves[1]", 16'h4000, 16'h7fff);
    ubus_example_tb0.ubus0.set_slave_address_map("slaves[2]", 16'h8000, 16'hBfff);
    ubus_example_tb0.ubus0.set_slave_address_map("slaves[3]", 16'hC000, 16'hFfff);
     super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase

endclass : test_2m_4s




//// Added by azhang
//
class test_2m_4s_azhang_vseqr extends uvm_sequencer;
  `uvm_component_utils_begin(test_2m_4s_azhang_vseqr)
  `uvm_component_utils_end

  uvm_sequencer#(ubus_transfer) seqr1;
  uvm_sequencer#(ubus_transfer) seqr2;

  function new (string name, uvm_component parent);
    super.new(name, parent);
    //`uvm_update_sequence_lib
  endfunction : new
endclass : test_2m_4s_azhang_vseqr

class test_2m_4s_azhang_vseq extends uvm_sequence;


  read_byte_seq read_byte_seq0;
  write_byte_seq write_byte_seq0;

  rand bit [15:0] addr_check;
  bit [7:0] m_data0_check;

  virtual task body();
    `uvm_info(get_type_name(),$sformatf("%s starting reading...", get_sequence_path()), UVM_MEDIUM);
    //// `uvm_do_on_with(read_byte_seq0, p_sequencer.seqr1, {read_byte_seq0.transmit_del == 0; })
    `uvm_create_on(read_byte_seq0, p_sequencer.seqr1)
    assert(read_byte_seq0.randomize() with {read_byte_seq0.transmit_del == 0; })
//    read_byte_seq0.start(p_sequencer.seqr1,this);
	`uvm_send(read_byte_seq0)

    addr_check = read_byte_seq0.rsp.addr;
    m_data0_check = read_byte_seq0.rsp.data[0] + 1;
    // WRITE MODIFIED READ DATA
    `uvm_info(get_type_name(),$sformatf("%s starting writing...", get_sequence_path()), UVM_MEDIUM);
    `uvm_do_on_with(write_byte_seq0, p_sequencer.seqr2, { write_byte_seq0.start_addr == addr_check; write_byte_seq0.data0 == m_data0_check; } )
    `uvm_info(get_type_name(),$sformatf("%s end of body...", get_sequence_path()), UVM_MEDIUM);
  endtask : body

  task pre_body();
    starting_phase.raise_objection(this, "read_modify_write_seq");
  endtask: pre_body

  task post_body();
    starting_phase.drop_objection(this, "read_modify_write_seq");
  endtask: post_body  


  `uvm_object_utils(test_2m_4s_azhang_vseq)
  `uvm_declare_p_sequencer(test_2m_4s_azhang_vseqr)

  function new (string name = "test_2m_4s_azhang_vseq");
    super.new(name);
  endfunction : new

endclass : test_2m_4s_azhang_vseq

// 2 Master, 4 Slave test
class test_2m_4s_azhang extends ubus_example_base_test;
   test_2m_4s_azhang_vseqr vseqr;

  `uvm_component_utils(test_2m_4s_azhang)

  function new(string name = "test_2m_4s_azhang", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);

  begin
    // Overides to the ubus_example_tb build_phase()
    // Set the topology to 2 masters, 4 slaves
    uvm_config_db#(int)::set(this,"ubus_example_tb0.ubus0", 
			       "num_masters", 2);
    uvm_config_db#(int)::set(this,"ubus_example_tb0.ubus0", 
			       "num_slaves", 4);
     
   // Control the number of RMW loops
    uvm_config_db#(int)::set(this,"ubus_example_tb0.ubus0.masters[0].sequencer.loop_read_modify_write_seq", "itr", 6);
    uvm_config_db#(int)::set(this,"ubus_example_tb0.ubus0.masters[1].sequencer.loop_read_modify_write_seq", "itr", 8);
   // uvm_config_db#(int)::set(this,"test_2m_4s_azhang_vseqr.seqr1.lrmw1_seq", "itr", 6);
   // uvm_config_db#(int)::set(this,"test_2m_4s_azhang_vseqr.seqr2.lrmw2_seq", "itr", 8);

     // Define the sequences to run in the run phase
    uvm_config_db#(uvm_object_wrapper)::set(this,"test_2m_4s_azhang_vseqr.run_phase", 
			       "default_sequence",
				test_2m_4s_azhang_vseq::type_id::get());

    vseqr = test_2m_4s_azhang_vseqr::type_id::create("test_2m_4s_azhang_vseqr", this);
        

     for(int i = 0; i < 4; i++) begin
	string slname;
	$swrite(slname,"ubus_example_tb0.ubus0.slaves[%0d].sequencer", i);
	uvm_config_db#(uvm_object_wrapper)::set(this, {slname,".run_phase"}, 
						  "default_sequence",
						  slave_memory_seq::type_id::get());
     end
     
    // Create the tb
    super.build_phase(phase);
  end
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    // Connect other slaves monitor to scoreboard
    ubus_example_tb0.ubus0.slaves[1].monitor.item_collected_port.connect(
      ubus_example_tb0.scoreboard0.item_collected_export);
    ubus_example_tb0.ubus0.slaves[2].monitor.item_collected_port.connect(
      ubus_example_tb0.scoreboard0.item_collected_export);
    ubus_example_tb0.ubus0.slaves[3].monitor.item_collected_port.connect(
      ubus_example_tb0.scoreboard0.item_collected_export);
    vseqr.seqr1  = ubus_example_tb0.ubus0.masters[0].sequencer;
    vseqr.seqr2  = ubus_example_tb0.ubus0.masters[1].sequencer;
  endfunction : connect_phase
  
  function void end_of_elaboration_phase(uvm_phase phase);
    // Set up slave address map for ubus0 (slaves[0] is overwritten here)
    ubus_example_tb0.ubus0.set_slave_address_map("slaves[0]", 16'h0000, 16'h3fff);
    ubus_example_tb0.ubus0.set_slave_address_map("slaves[1]", 16'h4000, 16'h7fff);
    ubus_example_tb0.ubus0.set_slave_address_map("slaves[2]", 16'h8000, 16'hBfff);
    ubus_example_tb0.ubus0.set_slave_address_map("slaves[3]", 16'hC000, 16'hFfff);
     super.end_of_elaboration_phase(phase);
  endfunction : end_of_elaboration_phase

endclass : test_2m_4s_azhang
