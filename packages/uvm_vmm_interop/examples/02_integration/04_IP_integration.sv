//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
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

//----------------------------------------------------------------------
// Example: IP Integration
//
// This example shows how to integrate an UVM agent IP in both a
// VMM-based ("VMM on top") and UVM-based ("UVM on top") environment.
// All testbench components used in this example are reusable.
//
// Testbench overview:
//
// Using the interconnected model, whereby UVM and VMM
// components are instantiated and configured using their respective
// APIs, this example shows that the interoperability library allows
// either environment to be "on top" and with few differences between
// the two. 
//
// (see ip_integration_hfpb_tb.gif)
//
// The design consists of two memories driven by a master, all
// connected to a highly configurable HFPB bus model. (The HFPB bus
// protocol is a an arbitrary bus-based protocol used for demonstrating
// UVM methodology and design practices.) The hfpb_agent serves as a
// hierarchical container for all the HFPB xactors-- indeed, the entire
// protocol-specific bus model.
//
// The HFPB agent represents a typical UVM IP block. Inside it, you
// can see that we are using only a fraction of its capability. 
//
// (see ip_integration_hfpb_agent.gif)
//
// The agent can be configured with any number of slaves, a monitor,
// and other optional subcomponents. It can even be driven by virtual
// sequences. If these capabilities aren't needed, ~the subcomponents
// are never created~. Thus, the IP block consumes only the resouces it
// needs for the particular configuration being used. In a sense, the
// IP block is polymorphic. The underlying code for the IP block does
// not need modification to accommodate a great many different
// topologies and configurations.
//
// In operation:
//
// The test drives transactions into the agent and those tranactions
// are converted by the master inside the agent into pin activity.
// The slaves respond to the pin activity and convert it to transaction
// streams which are sent externally to the memories.  The master
// (driver) and slaves are all encapsulated inside the agent.
// Although we don't in this example, an RTL-level DUT model could
// be connected to the HFPB agent via a virtual interface variable.
// Once connected, the DUT could act as a master or another slave on
// the HFPB bus.
// 
// The agent models configurable UVM hierarchy, or topology, which
// introduces some issues when instantiated in a vmm_env. In VMM, there
// is only one build() method-- in the vmm_env. The vmm_env is the
// only class that uses a phased test flow. In UVM, all UVM components
// are phaseable so that any component that is used at an ~env~ level
// today can be used as a mere sub-component of a larger testbench
// tomorrow. 
//
// The vmm_env::build() method is used to instantiate all components
// by direct call to each component's constructor, which is expected
// to new any subcomponents directly as well. Since connections in
// VMM are also defined via constructor arguments (such as vmm_channel),
// a vmm_env is completely built when the build() method completes.
// Moreover, any VMM subcomponent may be considered built when its
// constructor returns. Ths user must manage hierarchy, connection
// and configuration manually in the environment's build() method.
//
// In UVM, building and connecting are implemented as two distinct
// phases. All components-- envs, subcomponents, and leaf-level
// grandchildren alike-- employ a two-phase construction process.
// The UVM phasing mechanism calls build() on each component in
// the hierarchy in top-down order. If a parent in its build()
// creates new children, those children's build() methods will
// later be called to facilitate the creation of grandchildren.
// After the build() phase completes, only then is the testbench
// topology stable. The phasing mechanism then begins to call the
// connect() method in each component to facilitate port-export
// connections. Since connect() involves making references to
// subcomponent's ports and exports, which are considered children
// of their parent, as in
//
//|    t.transport_port.connect(agent.transport_export);
//
// the subcomponent ~must~ be built before any of its ports can be
// connected.
//
// The UVM phasing mechanism is flexible in that it allows you to
// insert custom task or function-based phases to the list of
// predefined phases.  The interoperability library leverages this
// capability by inserting the new VMM phases at the appropriate
// place in the overall test flow. The UVM already defines the
// build() phase, so that phase did not need to be added.
//
// With phases combined, the vmm_env::build() method gets called as
// part of the build phase for both UVM and VMM components alike.
// Thus, vmm_env::build() will complete before any of its (UVM)
// subcomponents' build() methods are called. It is therefore
// necessary, following the interconnected model, for the vmm_env
// writer to be aware of the UVM phasing model and implement the
// connect() method to connect UVM subcomponents. 
//
// If the vmm_env designer is comfortable using the UVM set/get_config
// mechanism to configure subcomponents, then these calls may be
// issued in build(), where the parent.build() calls set_config() and
// the child.build() calls get_config(). The top-level ~test~ may
// also call set_config() to configure any component in the testbench
// hierarchy, including the env. In order to use the standard
// VMM mechanism of the parent reaching down to set parameter values
// directly, this can only be done to UVM subcomponents after the 
// build() ~phase~ has fully completed. It is best to do this kind
// of "run-time" configuration at end_of_elaboration() or after.
//
// A note on model abstraction:
//
// A more abstract HFPB bus model implementation would merely need
// an address map to forward transactions to the appropriate slave.
// Such a model would execute much faster because it would not be
// converting the transactions to and from pin-level activity.
//
// The port/export design of our HFPB agent allows us to easily
// substitute in such bus models. Thus, we can reuse our tests and
// memory models with bus models that are optimized for speed,
// pin-level accuracy, or anywhere in between.
//
// (inline source)
//----------------------------------------------------------------------

`include "uvm_vmm_pkg.sv"   // The UVM and VMM libraries

// The following `ifdefs define the only differences between VMM
// on top and UVM on top, except in UVM-on-top mode we need to
// explicitly call global_stop_request to end the run phase.
//
// - the base class for the user env
// - the parent argument when called super.new in the env
// - the parent argument when creating children in the env

`ifdef VMM_ON_TOP
typedef `VMM_ENV base_env;
`define BASE_NEW_ARG  /*no parent arg*/
`define BASE_NEW_CALL /*no parent arg*/
`define PARENT null
`endif

`ifdef UVM_ON_TOP
typedef uvm_component base_env;
`define BASE_NEW_ARG ,uvm_component parent=null
`define BASE_NEW_CALL ,parent
`define PARENT this
`endif


`include "hfpb/hfpb_if.sv"      // HFPB interface definition
`include "hfpb/clock_reset.sv"  // HFPB clock & reset generator
`include "hfpb/hfpb_pkg.sv"     // HFPB protocol-specific components

`include "ctypes.sv"
`include "hfpb_components/hfpb_components_pkg.sv" // test-specific

import hfpb_pkg::*;
import hfpb_components_pkg::*;

`include "uvm_macros.svh"

parameter int DATA_SIZE = 8;
parameter int ADDR_SIZE = 9;

// this is the base class for all the tests
typedef hfpb_master_base #(DATA_SIZE, ADDR_SIZE) hfpb_test;

// these are the possible tests we can run.  Each is derived
// from hfpb_master_base#()
typedef 
    hfpb_random_mem_master #(DATA_SIZE, ADDR_SIZE) rand_test;
typedef
    hfpb_directed_mem_master #(DATA_SIZE, ADDR_SIZE) directed_test;


//----------------------------------------------------------------------
// Env - this defines our testbench topology.
//----------------------------------------------------------------------

class env #(int DATA_SIZE=8, int ADDR_SIZE=16) extends base_env;

  typedef bit [ADDR_SIZE-1:0] addr_t;

  hfpb_agent #(DATA_SIZE, ADDR_SIZE) agent;
  hfpb_mem   #(DATA_SIZE, ADDR_SIZE) mem1;
  hfpb_mem   #(DATA_SIZE, ADDR_SIZE) mem2;

  hfpb_addr_map #(ADDR_SIZE) addr_map;

  // can configure with any subtype of 'hfpb_test'
  hfpb_test test;

  function new(string name `BASE_NEW_ARG);
    super.new(name `BASE_NEW_CALL);
    addr_map = new();
  endfunction

  `ifdef VMM_ON_TOP
    `uvm_build
  `endif

  // Build - Set configuration for the HFPB agent, then create it
  //         and the other testbench components
  
  virtual function void build();
    super.build();
    
    // map the lower half of address space to mem1 (slave 0)
    // map the upper half of address space to mem2 (slave 1)
    addr_map.add_range('h000, 'h0ff, 0);
    addr_map.add_range('h100, 'h1ff, 1);

    set_config_int("hfpb_agent", "has_monitor", 0);
    set_config_int("hfpb_agent", "has_master",  1);
    set_config_int("hfpb_agent", "slaves",      2);
    set_config_int("hfpb_agent", "has_talker",  0);

    set_config_object("*", "addr_map", addr_map, 0);

    agent = new("hfpb_agent", `PARENT);
    mem1  = new("mem1",       `PARENT);
    mem2  = new("mem2",       `PARENT);

    // Ask to build an instance of the base class.  Because of
    // the override (below), we'll get the test we want.
    test = hfpb_test::type_id::create("mem_master", `PARENT);

    `ifdef VMM_ON_TOP
    uvm_build();
    test.transport_port.connect(agent.transport_export);
    mem1.slave_port.connect(agent.slave_export[0]);
    mem2.slave_port.connect(agent.slave_export[1]);
    `endif

  endfunction
  
  `ifdef UVM_ON_TOP
  // Connect - connect our test and memories to the hfpb agent
  //           We deferred connection to this phase, when we know
  //           that the entire component hierarchy has been built.

  virtual function void connect();
    super.connect();
    test.transport_port.connect(agent.transport_export);
    mem1.slave_port.connect(agent.slave_export[0]);
    mem2.slave_port.connect(agent.slave_export[1]);
  endfunction
  `endif

  `ifdef VMM_ON_TOP

    // In VMM-on-top mode, the vmm_env can implement start() and
    // wait_for_end() as usual to govern VMM xactor execution.
    // By default, in interoperability mode, the vmm_env's
    // wait_for_end() will issue an UVM stop_request to end
    // the run phase for UVM components. See HTML documentation on
    // the avt_uvm_vmm_env wrapper for details.
   
   virtual task wait_for_end();
     #0; //needed to avoid scheduling issue
     super.wait_for_end();
     #0; //needed to avoid scheduling issue
   endtask

  `endif
  `ifdef UVM_ON_TOP

    // In UVM-on-top mode, we implement the run() task here to
    // govern UVM component execution. Here, we simply issue an
    // immediate stop request, as their is no explicit end-of-test
    // condition for this example.
    //
    // Upon a stop request, the ~stop~ tasks of all UVM
    // components whose ~enable_stop_interrupt~ bit is set
    // will be called via separate processes. The ~run~ phase
    // completes when all forked ~stop~ tasks return.

    virtual task run();
      global_stop_request();
    endtask

  `endif

endclass


//----------------------------------------------------------------------
// Top-Level - Create our env and connect it to the bus interface
//             we'll be driving using a virtual interface handle
//             contained in a class. Then, specify which test to
//             run, this time via a type override in the factory
//----------------------------------------------------------------------

module example_04_IP_integration;

  env #(DATA_SIZE, ADDR_SIZE) e;
  hfpb_vif #(DATA_SIZE, ADDR_SIZE) hfpb_vif_obj;

  clk_rst cr();
  clock_reset ck (cr);
  hfpb_if #(DATA_SIZE, ADDR_SIZE) bus_if (cr.clk, cr.rst);

  initial begin
     
    e = new("env");
    hfpb_vif_obj = new(bus_if);
    set_config_object("*", "hfpb_vif", hfpb_vif_obj, 0);

    // identify the test we want to run by setting
    // a factory override.
    hfpb_test::type_id::set_type_override(
                                  directed_test::get_type_id());

    //OVM2UVM> uvm_enable_print_topology = 1;
    //OVM2UVM> FIXME> ovm_root.enable_print_topology = 1;  //OVM2UVM>
    uvm_default_table_printer.knobs.depth = 2;

    fork
      ck.run(2,10,0);
    join_none

    `ifdef VMM_ON_TOP
     e.run();
    `endif
    `ifdef UVM_ON_TOP
     run_test();
    `endif

    $finish();
    
  end

endmodule

