//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2011 Synopsys Inc
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
// Master/Slave configuration
// A master sends randomized transactions to a slave
//
// The topology of the configuration looks like this:
//
//                +---------------------+ 
// +--------+     |        shell        |     +-------+
// |        |     |    +-----------+    |     |       |
// | master |>--->|--->| connector |>---|>--->| slave |
// |        |     |    +-----------+    |     |       |
// +--------+     |                     |     +-------+
//                +---------------------+
//
// The connector intercepts transactions and prints them.  The shell
// wraps the connector.  The shell serves no functional purpose except
// to illustrate how to build hierarchical connections using sockets.
//
// text-diagram socket notation
//
//  |>    is an initator socket
//  -|>   is an initiator passthrough socket
//  >|    is a target socket
//  >|-   is a target passthrough socket
//
//
// The components all use nonblocking sockets and thus the cofiguration
// is approximately timed (AT), as opposed to a loosely timed (LT)
// configuration that uses blocking sockets.  The protocol uses the
// basic AT protocol, the master and slave ping-pong between each other
// to issue requests and retrieve responses.
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// trans
//----------------------------------------------------------------------
class trans extends uvm_tlm_generic_payload;

  function string convert2string();
    return super.convert2string();
  endfunction

endclass

`include "master.svh"
`include "slave.svh"

//----------------------------------------------------------------------
// connector
//
// A simple connector object that demonstrates how to build and connect
// a connector.  It simply intercpets the transactions as they pass by
// and prints them.  Transactions prefixed with "-->" are moving from
// the initiator to the target (i.e. traversing the forward path);
// transactions prefixed with "<--" are moving from the target back to
// the initiator (i.e. traversing the backward path).
//----------------------------------------------------------------------
class connector #(type T=uvm_tlm_generic_payload,
                  type P=uvm_tlm_phase_e)
  extends uvm_component;

  typedef connector #(T,P) this_type;

  uvm_tlm_nb_initiator_socket #(this_type,T,P) initiator_socket;
  uvm_tlm_nb_target_socket #(this_type,T,P) target_socket;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    initiator_socket = new("initiator_socket", this, this);
    target_socket = new("target_socket", this, this);
  endfunction

  function uvm_tlm_sync_e nb_transport_fw(T t, ref P p, input uvm_tlm_time delay);
    string msg;
    $sformat(msg, "--> %s", t.convert2string());
    `uvm_info("connector", msg, UVM_NONE);
    return initiator_socket.nb_transport_fw(t, p, delay);
  endfunction

  function uvm_tlm_sync_e nb_transport_bw(T t, ref P p, input uvm_tlm_time delay);
    string msg;
    $sformat(msg, "<-- %s", t.convert2string());
    `uvm_info("connector", msg, UVM_NONE);
    return target_socket.nb_transport_bw(t, p, delay);
  endfunction
    
endclass

//----------------------------------------------------------------------
// shell
//
// demonstrates hierarchical connectivity using passthrough sockets
//----------------------------------------------------------------------
class shell #(type T=uvm_tlm_generic_payload,
              type P=uvm_tlm_phase_e)
  extends uvm_component;

  connector #(T,P) c;
  uvm_tlm_nb_passthrough_initiator_socket #(T,P) initiator_socket;
  uvm_tlm_nb_passthrough_target_socket #(T,P) target_socket;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    initiator_socket = new("initiator_socket", this);
    target_socket = new("target_socket", this);
    c = new("connector", this);
  endfunction

  function void connect();
    target_socket.connect(c.target_socket);
    c.initiator_socket.connect(initiator_socket);
  endfunction

endclass


//----------------------------------------------------------------------
// env
//----------------------------------------------------------------------
class env extends uvm_component;

  `uvm_component_utils(env)

  master m;
  slave s;
  shell #(trans, uvm_tlm_phase_e) c;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    m = new("master", this);
    s = new("slave", this);
    c = new("shell", this);
  endfunction

  function void connect();
    m.initiator_socket.connect(c.target_socket);
    c.initiator_socket.connect(s.target_socket);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1000;
    phase.drop_objection(this);
  endtask

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

  function void check();
     if (e.m.n_trans != e.s.n_trans) begin
        `uvm_error("TEST",
                   $sformatf("Master (%0d) and slave (%0d) saw different # of completed transactions",
                             e.m.n_trans, e.s.n_trans))
     end

     if (e.m.n_trans < 5) begin
        `uvm_error("TEST",
                   $sformatf("Master completed too few (%0d) transactions",
                             e.m.n_trans))
     end

  endfunction

endclass

//----------------------------------------------------------------------
// top
//----------------------------------------------------------------------
module top;

initial
begin
   uvm_root top;
   
   top = uvm_root::get();

   top.finish_on_completion = 0;
   run_test("test");

   begin
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
end

endmodule
