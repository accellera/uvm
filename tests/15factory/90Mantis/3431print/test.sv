//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc.
//   Copyright 2010-2011 Synopsys, Inc.
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

// This test was copied from the factory example for the purpose
// of fixing mantis 3431.

/*
About: factory

This example will illustrate the usage of uvm_factory methods.



To get more details about the factory related methods, check the file:
	- uvm/src/base/uvm_factory.svh


*/

`include "uvm_macros.svh"
`include "packet_pkg.sv"
`include "gen_pkg.sv"
`include "env_pkg.sv"

module top;
  import uvm_pkg::*;
  import packet_pkg::*;
  import gen_pkg::*;
  import env_pkg::*;

  `include "uvm_macros.svh"

  class mygen extends gen;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function packet get_packet();
      `uvm_info("PKTGEN", $sformatf("Getting a packet from %s (%s)", get_full_name(), get_type_name()),UVM_MEDIUM)
      return super.get_packet();
    endfunction

    //Use the macro in a class to implement factory registration along with other
    //utilities (create, get_type_name). To just do factory registration, use the
    //macro `uvm_object_registry(mygen,"mygen")
    `uvm_component_utils(mygen)

  endclass

  // A big type name to force the resize of the table
  class myreallybigtypenamepacket extends packet;
    constraint ct10 { addr >= 11 && addr <= 20; }
    `uvm_object_utils(myreallybigtypenamepacket)

  function new(string name="myreallybigtypenamepacket");
     super.new(name);
  endfunction

  endclass

  class mypacket extends packet;
    constraint ct10 { addr >= 0 && addr <= 10; }

    //Use the macro in a class to implement factory registration along with other
    //utilities (create, get_type_name).
    `uvm_object_utils(mypacket)

  function new(string name="mypacket");
     super.new(name);
  endfunction

  endclass

  class test extends uvm_test;
    env e;

    `uvm_new_func
    `uvm_component_utils(test)
    
    function void build_phase(uvm_phase phase);
      gen::type_id::set_inst_override(mygen::get_type(), "uvm_test_top.env.gen1");
      gen::type_id::set_inst_override(mygen::get_type(), "uvm_test_top.env.generator2");
      packet::type_id::set_type_override(mypacket::get_type());
      mypacket::type_id::set_type_override(myreallybigtypenamepacket::get_type());
      e = env::type_id::create("env",this);
    endfunction

    task run_phase(uvm_phase phase);
      $display("START OF GOLD FILE");
      factory.print(1);
      $display("END OF GOLD FILE");
    endtask
  endclass

  initial begin
    run_test;
  end

endmodule 

