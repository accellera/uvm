//------------------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
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

import uvm_pkg::*;
`include "uvm_macros.svh"

bit test_error = 0;

//----------------------------------------------------------------------
// config_base
//
// Serves as the base class for some different configuration objects
//----------------------------------------------------------------------
virtual class config_base;
  pure virtual function string sprint();
endclass

//----------------------------------------------------------------------
// config_A
//
// A configuration object derived from config_base
//----------------------------------------------------------------------
class config_A extends config_base;

  rand int unsigned thingy;
  rand int unsigned doodad;

  constraint c { thingy < 100 &&
                 doodad > 1000 && doodad < 5000; }

  function string sprint();
    string s;
    $sformat(s, "thingy = %0d, doodad = %0d", thingy, doodad);
    return s;
  endfunction

endclass

//----------------------------------------------------------------------
// config_B
//
// Another configurations object derived from config_base
//----------------------------------------------------------------------
class config_B extends config_base;

  rand int unsigned whatchit;

  constraint c { whatchit < 87; }

  function string sprint();
    string s;
    $sformat(s, "whatchit = %0d", whatchit);
    return s;
  endfunction

endclass  

//----------------------------------------------------------------------
// bus_if
//
// A bus interface.  This example illustrates how to store virtual
// interfaces in the resources database using types (rather than string
// names).
//----------------------------------------------------------------------
interface bus_if;
  bit clk;
  bit [7:0] data;
  bit [7:0] addr;
endinterface

//----------------------------------------------------------------------
// component
//----------------------------------------------------------------------
class component #(type CONFIG = int) extends uvm_component;

  CONFIG cfg;
  virtual bus_if bus;
  int ii;
  bit [7:0] data;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();

    uvm_resource#(bit [7:0]) r_data;

    ii = 91; // default value for ii;

    // retrieve a config object by type from the resource database
    if(!uvm_resource_db#(CONFIG)::read_by_type(get_full_name(), cfg, this)) begin
      `uvm_error("TESTERROR", "no config object available");
      test_error = 1;
    end
    else
      uvm_report_info("build", $sformatf("got config object: %s",
                      cfg.sprint()));

    // retrieve a virtual interface from the resource database by type
    // instead of by name.
    if(!uvm_resource_db#(virtual bus_if)::read_by_type(get_full_name(), bus, this)) begin
      `uvm_error("TESTERROR", "no bus interface available");
      test_error = 1;
    end
    else
      uvm_report_info("build", "got bus_if");

    // this read will result in a failure because we have not added a
    // resource whose type is int into the resource database.  The
    // variable ii retains its default value
    if(!uvm_resource_db#(int)::read_by_type(get_full_name(), ii, this))
      uvm_report_info("build", "no ii");
    else begin
      `uvm_error("TESTERROR", "non-existant int mysteriously located in resource pool");
      test_error = 1;
    end
    uvm_report_info("build", $sformatf("ii = %0d", ii));

    // here we get a resource by name   
    if(!uvm_resource_db#(bit [7:0])::read_by_name(get_full_name(), "data", data, this)) begin
      `uvm_error("TESTERROR", "cannot locate 'data' in the resource pool");
      test_error = 1;
    end
    else begin
      uvm_report_info("build", $sformatf("data = %0d", data));
    end
   
  endfunction

  function void check();
    string msg;

    if(ii != 91) begin
      `uvm_error("TESTERROR", "ii somehow changed value");
      test_error = 1;
    end

    if(data != 43) begin
      `uvm_error("TESTERROR", "somehow the read only reasource 'data' changed value");
      test_error = 1;
    end
    
  endfunction
  
endclass

//----------------------------------------------------------------------
// shell
//----------------------------------------------------------------------
class shell extends uvm_component;

  // Define two specializations of component distinguished by the config
  // object type.  Instantiate one of each

  component#(config_A) c1;
  component#(config_B) c2;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    c1 = new("c1", this);
    c2 = new("c2", this);
  endfunction

endclass

//----------------------------------------------------------------------
// env
//----------------------------------------------------------------------
class env extends uvm_component;

  `uvm_component_utils(env)

  shell s1, s2;
  config_A cA;
  config_B cB;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build();
    uvm_resource#(bit [7:0]) r_data;

    s1 = new("s1", this);
    s2 = new("s2", this);

    // Create, randomize, and set two configuration object, cA, and
    // cB.  These are stored in the database anonymously.  Since they
    // have no names they can only be looked up by type

    cA = new();
    assert(cA.randomize());
    uvm_resource_db#(config_A)::set_anonymous("*", cA, this);


    cB = new();
    assert(cB.randomize());
    uvm_resource_db#(config_B)::set_anonymous("*", cB, this);

    r_data = uvm_resource_db#(bit [7:0])::set_default("*", "data");
    r_data.write(43, this);
    r_data.set_read_only();

  endfunction

endclass

//----------------------------------------------------------------------
// test
//
// Top-level test
//----------------------------------------------------------------------
class test extends uvm_component;

  `uvm_component_utils(test)

  env e;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    e = new("env", this);
  endfunction

  function void report();
    // We print the configuration datbase just for reference.  The
    // result does not affect whether or not the test passes.
    uvm_resources.dump();
    uvm_resources.dump_get_records();

    if(test_error)
      $display("** UVM TEST FAIL **");
    else
      $display("** UVM TEST PASSED **");
  endfunction

endclass

//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

  bus_if bus();

  initial begin

    // set the bus interface as a resource
    uvm_resource_db#(virtual bus_if)::set("*", "bus_if", bus);
    
    run_test();

  end

endmodule

