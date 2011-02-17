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

//----------------------------------------------------------------------
// producer
//----------------------------------------------------------------------
class producer extends uvm_component;

  uvm_tlm_nb_initiator_socket #(producer) initiator_socket;

  bit done;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    initiator_socket = new("initator_socket", this);
  endfunction

  function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload t,
                                      ref uvm_tlm_phase_e p,
                                      input uvm_tlm_time delay);
    uvm_report_warning("producer", "nb_transport_bw is not implemented");
  endfunction

  task run_phase(uvm_phase phase);

    int unsigned i;
    uvm_tlm_time delay = new;
    uvm_tlm_phase_e ph;
    uvm_tlm_sync_e sync;
    uvm_tlm_generic_payload t;

    phase.raise_objection(this);

    delay.incr(1, 1ns);

    // not really nb - consumer should accept the trans nb fashion, but consume time executing it
    for(i = 0; i < 10; i++) begin
      t = generate_transaction();
      uvm_report_info("producer", t.convert2string());
      sync = initiator_socket.nb_transport_fw(t, ph, delay);
    end

    phase.drop_objection(this);
  endtask

  //--------------------------------------------------------------------
  // generate_transaction
  //
  // generat a new, randomized transaction
  //--------------------------------------------------------------------
  function uvm_tlm_generic_payload generate_transaction();

    bit [63:0] addr;
    int unsigned length;
    byte unsigned data[];

    uvm_tlm_generic_payload t = new();
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

  uvm_tlm_nb_target_socket #(consumer) target_socket;

  int unsigned transaction_count;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    target_socket = new("target_socket", this);
  endfunction

  function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload t,
                                      ref uvm_tlm_phase_e p,
                                      input uvm_tlm_time delay);
    uvm_report_info("consumer", t.convert2string());
    transaction_count++;
    return UVM_TLM_ACCEPTED;
  endfunction

  function void report();
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

  function void build();
    p = new("producer", this);
    c = new("consumer", this);
  endfunction

  function void connect();
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

  function void build();
    e = new("env", this);
  endfunction

endclass

//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

  initial run_test();

endmodule
