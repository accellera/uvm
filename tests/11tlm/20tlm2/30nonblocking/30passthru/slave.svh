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
// slave
//----------------------------------------------------------------------
class slave extends uvm_component;

  uvm_tlm_nb_target_socket #(slave, trans) target_socket;

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
    target_socket = new("target_socket", this);
  endfunction

  //--------------------------------------------------------------------
  // nb_transport_fw
  //
  // Implementation of nb_transport_fw.  Provides a forward path from
  // initiator to target
  //--------------------------------------------------------------------
  function uvm_tlm_sync_e nb_transport_fw(trans t,
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

    fork begin
        fsm_proc = process::self();
        fsm();
    end
    join_none

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
          begin
            #(delay_time.get_realtime(1ns));
            $sformat(msg, "begin req: %s", transaction.convert2string());
            `uvm_info("slave", msg, UVM_NONE);
            state = END_REQ;
            #0;
          end

        END_REQ:
          begin
            `uvm_info("slave", "end req", UVM_NONE);
            #5; // time to complete request
            delay.reset();
            sync = target_socket.nb_transport_bw(transaction, state, delay);
            state = BEGIN_RESP;
            #0;
          end

        BEGIN_RESP:
          begin
            delay.incr(3, 1ns);
            `uvm_info("slave", "begin rsp", UVM_NONE);
            transaction.set_response_status(UVM_TLM_OK_RESPONSE);
            sync = target_socket.nb_transport_bw(transaction, state, delay);
            wait(state != BEGIN_RESP);
          end

        END_RESP:
         begin
            n_trans++;
            #(delay_time.get_realtime(1ns));
            `uvm_info("slave", "end rsp", UVM_NONE);
            wait (state != END_RESP);
          end

      endcase
      
    end

  endtask

endclass
