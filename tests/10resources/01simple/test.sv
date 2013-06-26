//----------------------------------------------------------------------
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
//----------------------------------------------------------------------

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum { MODE_CONFIGURE, MODE_DATA, MODE_RESET } mode_t;

//----------------------------------------------------------------------
// child_component
//----------------------------------------------------------------------
class child_component extends uvm_component;

  uvm_resource #(int) r;
  uvm_resource #(int) t;
  int size = 8;
  bit flag = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();

    super.build();

    if(!uvm_resource_db#(int)::read_by_name(get_full_name(), "size", size))
      `uvm_warning("RSRCNF", $sformatf("resource size in scope %s not found", get_full_name()));
    $display("%s: size = %0d", get_full_name(), size);

    if(!uvm_resource_db#(bit)::read_by_name(get_full_name(), "flag", flag))
      `uvm_warning("RSRCNF", $sformatf("resource flag in scope %s not found", get_full_name()));
    $display("%s: flag = %0d", get_full_name(), flag);

  endfunction

  function void report();
    uvm_queue#(uvm_resource_base) rq;
    $display("resources visible in %s", get_full_name());
    rq = uvm_resources.lookup_scope(get_full_name());
    uvm_resources.print_resources(rq);
  endfunction

endclass

//----------------------------------------------------------------------
// parent_component
//----------------------------------------------------------------------
class parent_component extends uvm_component;

  child_component child1;
  child_component child2;
  uvm_resource_pool rp;
  mode_t mode = MODE_RESET;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    rp = uvm_resource_pool::get();
  endfunction

  function void build();
    child1 = new("child1", this);
    child2 = new("child2", this);

    // Intentionally mispell "mode" to see if the spell checker works
    if(!uvm_resource_db#(mode_t)::read_by_name(get_full_name(), "mde", mode))
      `uvm_warning("RSRCNF", "resource not found");
    // try a different intentional misspelling
    if(!uvm_resource_db#(mode_t)::read_by_name(get_full_name(), "odf", mode))
      `uvm_warning("RSRCNF", "resource not found");
    $display("%s: mode = %0d", get_full_name(), mode);

  endfunction

  function void report();
    uvm_queue#(uvm_resource_base) rq;
    $display("resources visible in %s", get_full_name());
    rq = uvm_resources.lookup_scope(get_full_name());
    uvm_resources.print_resources(rq);
  endfunction

endclass

//----------------------------------------------------------------------
// test
//----------------------------------------------------------------------
class test extends uvm_component;

  `uvm_component_utils(test)

  parent_component mom;
  parent_component dad;
  uvm_resource_pool rp;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    rp = uvm_resource_pool::get();
  endfunction

  function void build();
    uvm_int_rsrc r;
    mom = new("mom", this);
    dad = new("dad", this);

    // create and export a resource that is available only in the "mom"
    // sub-hierarchy.  We use a glob to represent the set of scopes over
    // which this resource is visible
    uvm_resource_db#(int)::set("*.mom.*", "size", 16, this);

    // create and export a resource that is available only in the "dad"
    // sub-hierarchy.  Here we use a regex to represent the set of
    // scopes over which this resource is visible.  Note that the
    // regular expressio is enclosed in forward slashes (/) indicating
    // it is a proper regular expression and not a glob.

    uvm_resource_db#(int)::set("/.*\\.dad\\..*/", "size", 32, this);

    
    // create and export a resource that is available only in leaves
    // named child1.
    uvm_resource_db#(bit)::set("*.child1", "flag", 1, this);

    // create and export a resource that is available anywhere in the
    // sub-herarchy rooted at this this component.
    uvm_resource_db#(mode_t)::set("*", "mode", MODE_CONFIGURE, this);
  endfunction

  task run();
    uvm_resources.dump();
    $display("--- unused resources ---");
    uvm_resources.print_resources(uvm_resources.find_unused_resources);
  endtask

  function void report();
    uvm_queue#(uvm_resource_base) rq;

    // lookup_scope() locates all the resources that are visible
    // in the current scope -- i.e. the scope identified by get_full_name(),
    // and returns then in a queue.  The function print_resources is a 
    // convenience function that prints all the resources in the queue.
    $display("resources visible in %s", get_full_name());
    rq = uvm_resources.lookup_scope(get_full_name());
    uvm_resources.print_resources(rq);

    $display("** UVM TEST PASSED **");

  endfunction

endclass

//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

  initial run_test();

endmodule
