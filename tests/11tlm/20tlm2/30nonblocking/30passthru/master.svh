//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2010-2011 Synopsys Inc
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
// master
//----------------------------------------------------------------------
class master extends uvm_component;

  uvm_tlm_nb_initiator_socket #(master, trans) initiator_socket;

  local uvm_tlm_phase_e state;
  local uvm_tlm_time delay_time;
  local trans transaction;

  local process fsm_proc;

  int n_trans = 0;
   
  function new(string name, uvm_component parent);
    super.new(name, parent);
    state = UNINITIALIZED_PHASE;
  endfunction


  //--------------------------------------------------------------------
  // build
  //--------------------------------------------------------------------
  function void build();
    initiator_socket = new("initiator_socket", this);
  endfunction

  //--------------------------------------------------------------------
  // nb_transport_bw
  //
  // Implementation of nb_transport_bw.  Provides backward path from
  // target back top initiator
  //--------------------------------------------------------------------
  function uvm_tlm_sync_e nb_transport_bw(trans t,
                                      ref uvm_tlm_phase_e p,
                                      input uvm_tlm_time delay);

    delay_time = delay;
    transaction = t;
    state = p;

    return UVM_TLM_ACCEPTED;
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  task run_phase(uvm_phase phase);

    fork
      begin
        fsm_proc = process::self();
        fsm();
      end
    join_none

    #0;
    state = BEGIN_REQ; // start the state machin running
  endtask

  //--------------------------------------------------------------------
  // fsm
  //--------------------------------------------------------------------
  task fsm();

    uvm_tlm_phase_e prev_state;
    uvm_tlm_time delay = new;
    uvm_tlm_sync_e sync;
    string msg;

    forever begin

      case(state)

        UNINITIALIZED_PHASE:
          begin
            wait (state != UNINITIALIZED_PHASE);
          end

        BEGIN_REQ:
          // start a new transaction
          begin
            `uvm_info("master", "begin req", UVM_NONE);
            delay.reset();
            transaction = generate_transaction();
            sync = initiator_socket.nb_transport_fw(transaction, state, delay);
            // we are using the backward path, not the return path,
            // so we can ignore the return value of nb_transport_fw()
            wait (state != BEGIN_REQ);
          end

        END_REQ:
          begin
            #(delay_time.get_realtime(1ns));
            `uvm_info("master", "end req", UVM_NONE);
            wait(state != END_REQ);
          end

        BEGIN_RESP:
          begin
            #(delay_time.get_realtime(1ns));
            $sformat(msg, "begin rsp: %s", transaction.convert2string());
            `uvm_info("master", msg, UVM_NONE);
            state = END_RESP;
            #0;
          end

        END_RESP:
          begin
            `uvm_info("master", "end rsp", UVM_NONE);
            #7; // time to complete response
            delay.reset();
            sync = initiator_socket.nb_transport_fw(transaction, state, delay);
            state = BEGIN_REQ;
            n_trans++;
            #0;
          end

      endcase

    end

  endtask

  //--------------------------------------------------------------------
  // generate_transaction
  //
  // generat a new, randomized transaction
  //--------------------------------------------------------------------
  function trans generate_transaction();

    bit [63:0] addr;
    int unsigned length;
    byte unsigned data[];

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
