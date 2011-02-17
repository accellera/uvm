//----------------------------------------------------------------------
//   Copyright 2010-2011 Mentor Graphics Corporation
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

import uvm_pkg::*;
`include "uvm_macros.svh"

//----------------------------------------------------------------------
// trans
//----------------------------------------------------------------------
class trans extends uvm_tlm_generic_payload;

  function string convert2string();
    return super.convert2string();
  endfunction

endclass

//----------------------------------------------------------------------
// producer
//----------------------------------------------------------------------
class producer extends uvm_component;

  uvm_tlm_b_initiator_socket #(trans) initiator_socket;

  local bit done;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    done = 0;
    enable_stop_interrupt = 1;
  endfunction

  function void build_phase(uvm_phase phase);
     initiator_socket = new("initator_socket", this);
  endfunction

  task run_phase(uvm_phase phase);

    int unsigned i;
    uvm_tlm_time delay = new;
    trans t;

    for(i = 0; i < 10; i++) begin
      t = generate_transaction();
      $display("producer", t.convert2string());
      initiator_socket.b_transport(t, delay);
    end

    done = 1;
  endtask

  task stop(string ph_name);
    wait(done == 1);
  endtask

  //--------------------------------------------------------------------
  // generate_transaction
  //
  // generate a new, randomized transaction
  //--------------------------------------------------------------------
  function trans generate_transaction();

    bit [63:0] addr;
    byte unsigned data[];
    int length;

    trans t = new();
    addr = $urandom() & 'hff;
    length = 4;
    data = new[length];

    t.set_data_length(length);
    t.set_address(addr);
    for(int unsigned i = 0; i < length; i++) begin
      data[i] = $urandom();
    end
    t.set_data(data);
    t.set_command(UVM_TLM_WRITE_COMMAND);

    return t;
  endfunction

endclass

//----------------------------------------------------------------------
// consumer
//----------------------------------------------------------------------
class consumer extends uvm_component;

  uvm_tlm_b_target_socket #(consumer, trans) target_socket;

  int unsigned transaction_count;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    transaction_count = 0;
  endfunction

  function void build_phase(uvm_phase phase);
   target_socket = new("target_socket", this, this);
  endfunction

  task b_transport(trans t, uvm_tlm_time delay);
    #5;
    uvm_report_info("consumer", t.convert2string());
    transaction_count++;
  endtask

  function void report_phase(uvm_phase phase);
    if(transaction_count == 10)
      $display("** UVM TEST PASSED **");
    else
      $display("** UVM TEST FAILED **"); 
  endfunction

endclass

//----------------------------------------------------------------------
// env
//----------------------------------------------------------------------
class env extends uvm_component;

  `uvm_component_utils(env)

  producer p;
  consumer c;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    p = new("producer", this);
    c = new("consumer", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    p.initiator_socket.connect(c.target_socket);
  endfunction

endclass

//----------------------------------------------------------------------
// test
//----------------------------------------------------------------------
class test extends uvm_component;

  `uvm_component_utils(test)

  env e;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    e = new("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #100;
    phase.drop_objection(this);
  endtask

endclass

//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

  initial run_test();

endmodule
