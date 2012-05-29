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

class cfg extends uvm_object;
  int z;

  function string convert2string();
    string s;
    $sformat(s, "{ z = %0d }", z);
    return s;
  endfunction

endclass

class  env extends uvm_component;

  uvm_bitstream_t A;
  int B;
  uvm_object dummy;
  cfg C, D;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    if(!uvm_resource_db#(uvm_bitstream_t)::read_by_name(get_full_name(), "A", A, this))
      `uvm_error("NOCONFIG", "A not located in resource pool")
    $display("A = %0d", A);

    if(!get_config_int("B", B))
      `uvm_error("NOCONFIG", "B not located in resource pool")
    $display("B = %0d", B);

    if(!uvm_resource_db#(uvm_object)::read_by_name(get_full_name(), "C", dummy, this))
      `uvm_error("NOCONFIG", "C not located in resource pool")
    else
      if(!$cast(C, dummy))
        `uvm_error("NOCONFIG", "C has incorrect type")
      else
        $display("C = %s", C.convert2string());

    if(!get_config_object("D", dummy, 0))
      `uvm_error("NOCONFIG", "D not located in resource pool")
    else
      if(!$cast(D, dummy))
        `uvm_error("NOCONFIG", "D has incorrect type")
      else
        $display("D = %s", D.convert2string());

    if(A == 14 && B == 98 && C.z == -122 && D.z == 88)
      $display("** UVM TEST PASSED **");
    else
      $display("** UVM TEST FAIL **");

  endfunction

endclass

class test extends uvm_component;

  `uvm_component_utils(test)

  env e;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    cfg c, d;

    e = new("env", this);

    set_config_int("*", "A", 14);

    uvm_resource_db#(uvm_bitstream_t)::set("*", "B", 98, this);

    c = new();
    c.z = -122;
    set_config_object("*", "C", c, 0);

    d = new();
    d.z = 88;
    uvm_resource_db#(uvm_object)::set("*", "D", d, this);
  endfunction

  function void report();
    uvm_resource_pool rp = uvm_resource_pool::get();
    rp.dump();
  endfunction

endclass

module top;
  initial run_test();
endmodule
