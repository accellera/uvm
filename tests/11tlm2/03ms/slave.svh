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

//----------------------------------------------------------------------
// slave
//----------------------------------------------------------------------
class slave extends uvm_component;

  typedef slave this_t;
  tlm_nb_target_socket #(trans, tlm_phase_e, this_t) target_socket;

  local tlm_phase_e state;
  local time delay_time;
  local trans transaction;

  local process fsm_proc;
  local uvm_barrier barrier;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    state = UNINITIALIZED_PHASE;
  endfunction

  //--------------------------------------------------------------------
  // build
  //--------------------------------------------------------------------
  function void build();
    target_socket = new("target_socket", this, this);
    barrier = uvm_pool#(string, uvm_barrier)::get_global("barrier");
    barrier.set_threshold(barrier.get_threshold() + 1);
  endfunction

  //--------------------------------------------------------------------
  // nb_transport_fw
  //
  // Implementation of nb_transport_fw.  Provides a forward path from
  // initiator to target
  //--------------------------------------------------------------------
  function tlm_sync_e nb_transport_fw(ref trans t,
                                      ref tlm_phase_e p,
                                      ref time delay);
    delay_time = delay;
    transaction = t;
    state = p;

    return TLM_ACCEPTED;
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  task run();

    fork
      begin
        fsm_proc = process::self();
        fsm();
      end
    join_none

    // wait barrier
    barrier.wait_for();

    // clean up
    fsm_proc.kill();

    `uvm_info("slave", "shutting down...", UVM_NONE);

  endtask

  //--------------------------------------------------------------------
  // fsm
  //--------------------------------------------------------------------
  task fsm();

    tlm_phase_e prev_state;
    time delay;
    tlm_sync_e sync;
    string msg;

    forever begin

      case(state)

        UNINITIALIZED_PHASE:
          begin
            wait (state != UNINITIALIZED_PHASE);
          end

        BEGIN_REQ:
          begin
            #delay_time;
            $sformat(msg, "begin req: %s", transaction.convert2string());
            `uvm_info("slave", msg, UVM_NONE);
            state = END_REQ;
            #0;
          end

        END_REQ:
          begin
            `uvm_info("slave", "end req", UVM_NONE);
            #5; // time to complete request
            delay = 0;
            sync = target_socket.nb_transport_bw(transaction, state, delay);
            state = BEGIN_RESP;
            #0;
          end

        BEGIN_RESP:
          begin
            delay = 3;
            `uvm_info("slave", "begin rsp", UVM_NONE);
            transaction.set_response_status(TLM_OK_RESPONSE);
            sync = target_socket.nb_transport_bw(transaction, state, delay);
            wait(state != BEGIN_RESP);
          end

        END_RESP:
          begin
            #delay_time;
            `uvm_info("slave", "end rsp", UVM_NONE);
            wait (state != END_RESP);
          end

      endcase
      
    end

  endtask

endclass
