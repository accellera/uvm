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

import float_pkg::*;
import fpu_util_pkg::*;

//----------------------------------------------------------------------
// calc
//
// A component that generates randomized floating point computations
//----------------------------------------------------------------------
class calc extends uvm_component;

  `uvm_component_utils(calc);

  uvm_transport_port #(fpu_request, fpu_response) transport_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    transport_port = new("transport_port", this);
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  task run();

    forever begin
      random_calc();
      #1;
    end

  endtask

  //--------------------------------------------------------------------
  // random_calc
  //
  // generate a randomized calculation -- the operator and two operands
  // are generated randomly.
  //--------------------------------------------------------------------
  virtual task random_calc();

    string s;

    fpu_request req;
    fpu_response rsp;
    op_t op = ($random % 5) & 'h7; // generate a random operation
    ieeeFloat A = new();
    ieeeFloat B = new();

    // create a new request with randomized operands and the operation
    // that was randomly selected above

    req = new(A.gen_small(), B.gen_small(), op);
    transport_port.transport(req, rsp);

  endtask

endclass

//----------------------------------------------------------------------
// calc2
//
// Another component that generates randomized FPU calculations.  This
// component will also generate operands of 1.0 and 0.0 specifically.
//----------------------------------------------------------------------
class calc2 extends calc;

  `uvm_component_utils(calc2);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task random_calc();

    string s;

    fpu_request req;
    fpu_response rsp;
    op_t op = ($random % 5) & 'h7; // generate a random operation

    req = new(rand_operand(), rand_operand(), op);
    transport_port.transport(req, rsp);

  endtask

  function shortreal rand_operand();
    shortreal f;
    ieeeFloat r = new();
    case ($random & 'h3)
      0 : r.set(0.0);
      1 : r.set(1.0);
      2 : void'(r.gen_small());
      3 : void'(r.gen_float());
    endcase

    f = r.fl2real();

    if($random & 1)
      f = - f;

    return f;

  endfunction

endclass
