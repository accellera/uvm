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
// tlm2 imps -- interface implementations
//
// Binds the interface with the object that contains the interface
// implementation.
//----------------------------------------------------------------------

// IMP binding macros

`define TLM2_NB_TRANSPORT_FW_IMP(imp, T, P, t, p, delay)                  \
  function tlm_sync_e nb_transport_fw(ref T t, ref P p, ref time delay);  \
    return imp.nb_transport_fw(t, p, delay);                              \
  endfunction

`define TLM2_NB_TRANSPORT_BW_IMP(imp, T, P, t, p, delay)                  \
  function tlm_sync_e nb_transport_bw(ref T t, ref P p, ref time delay);  \
    return imp.nb_transport_bw(t, p, delay);                              \
  endfunction

`define TLM2_B_TRANSPORT_IMP(imp, T, t, delay)                            \
  task b_transport(ref T t, ref time delay);                              \
    imp.b_transport(t, delay);                                            \
  endtask

//======================================================================
//
// imp classes.  These are used like exports excpet an addtional class
// parameter specifices the type of the implementation object.  When the
// imp is instantiated the implementation object is bound.
//
//======================================================================

class tlm_nb_transport_fw_imp #(type T=tlm2_generic_payload,
                      type P=tlm_phase_e,
                      type IMP=int)
  extends uvm_port_base #(tlm2_if #(T,P));
  `UVM_IMP_COMMON(`TLM2_NB_FW_MASK, "tlm_nb_transport_fw_imp", IMP)
  `TLM2_NB_TRANSPORT_FW_IMP(m_imp, T, P, t, p, delay)
endclass

class tlm_nb_transport_bw_imp #(type T=tlm2_generic_payload,
                      type P=tlm_phase_e,
                      type IMP=int)
  extends uvm_port_base #(tlm2_if #(T,P));
  `UVM_IMP_COMMON(`TLM2_NB_BW_MASK, "tlm_nb_transport_bw_imp", IMP)
  `TLM2_NB_TRANSPORT_BW_IMP(m_imp, T, P, t, p, delay)
endclass

class tlm_b_transport_imp #(type T=tlm2_generic_payload,
                            type IMP=int)
  extends uvm_port_base #(tlm2_if #(T));
  `UVM_IMP_COMMON(`TLM2_B_MASK, "tlm_b_transport_imp", IMP)
  `TLM2_B_TRANSPORT_IMP(m_imp, T, t, delay)
endclass
