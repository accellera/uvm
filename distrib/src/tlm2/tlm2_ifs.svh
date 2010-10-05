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
// tlm2 interfaces
//----------------------------------------------------------------------

typedef enum
  {
    UNINITIALIZED_PHASE,
    BEGIN_REQ,
    END_REQ,
    BEGIN_RESP,
    END_RESP
  } tlm_phase_e;

typedef enum 
  {
    TLM_ACCEPTED,
    TLM_UPDATED,
    TLM_COMPLETED
  } tlm_sync_e;


`define TLM_TASK_ERROR "TLM-2 interface task not implemented"
`define TLM_FUNCTION_ERROR "TLM-2 interface function not implemented"

class tlm2_if #(type T=tlm2_generic_payload,
                type P=tlm_phase_e);

  virtual function tlm_sync_e nb_transport_fw(T t, ref P p, ref time delay);
    `uvm_error("nb_transport_fw", `TLM_FUNCTION_ERROR)
    return TLM_ACCEPTED;
  endfunction

  virtual function tlm_sync_e nb_transport_bw(T t, ref P p, ref time delay);
    `uvm_error("nb_transport_bw", `TLM_FUNCTION_ERROR)
    return TLM_ACCEPTED;
  endfunction

  virtual task b_transport(T t, ref time delay);
    `uvm_error("b_transport", `TLM_TASK_ERROR)
  endtask

endclass

