//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
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

`include "xbus_demo_tb.sv"


// Base Test
class xbus_demo_base_test extends uvm_test;

  `uvm_component_utils(xbus_demo_base_test)

  xbus_demo_tb xbus_demo_tb0;
  //uvm_table_printer printer;

  function new(string name = "xbus_demo_base_test", 
    uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build();
    super.build();
    // Enable transaction recording for everything
    set_config_int("*", "recording_detail", UVM_FULL);
    // Create the tb
    xbus_demo_tb0 = xbus_demo_tb::type_id::create("xbus_demo_tb0", this);
    // Create a specific depth printer for printing the created topology
    //printer = new();
    //printer.knobs.depth = 3;
  endfunction : build

  function void end_of_elaboration();
    // Set verbosity for the bus monitor for this demo
    xbus_demo_tb0.xbus0.bus_monitor.set_report_verbosity_level(UVM_FULL);
    uvm_report_info(get_type_name(),
      $sformatf("Printing the test topology :\n%s", this.sprint()), UVM_LOW);
  endfunction : end_of_elaboration

endclass : xbus_demo_base_test


// Objection Mechanism Example Test
class test extends xbus_demo_base_test;

  `uvm_component_utils(test)

  function new(string name = "test", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build();
    // Set the default sequence for the master and slave
    set_config_string("xbus_demo_tb0.xbus0.masters[0].sequencer",
      "default_sequence", "obj_example_seq");
    set_config_string("xbus_demo_tb0.xbus0.slaves[0].sequencer", 
      "default_sequence", "slave_memory_seq");
    // Create the tb
    super.build();
  endfunction : build

  function void report();
    if($time > 2000) $display("** UVM TEST FAILED : time is %0t**", $time);
    $display("** UVM TEST PASSED **");
  endfunction

endclass : test

