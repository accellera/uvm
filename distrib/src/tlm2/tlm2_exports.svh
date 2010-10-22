//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2010 Synopsys, Inc.
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
// title: tlm exports
//
// class definitions of export classes that connect tlm interfaces
//----------------------------------------------------------------------

// class: tlm_nb_transport_fw_export
//
// Non-blocking forward transport export class 
class tlm_nb_transport_fw_export #(type T=tlm_generic_payload,
                                   type P=tlm_phase_e)
  extends uvm_port_base #(tlm_if #(T,P));
  `UVM_EXPORT_COMMON(`TLM_NB_FW_MASK, "tlm_nb_transport_fw_export")
  `TLM_NB_TRANSPORT_FW_IMP(this.m_if, T, P, t, p, delay)
endclass

// class: tlm_nb_transport_bw_export
//
// Non-blocking backward transport export class 
// This class should be instantiated in the initiator transactor 
// which instantiates a non-blocking forward port. 
// The transactions sent from this transactor on the forward path 
// can be received by the transactor on the backward path through 
// this backward export.
class tlm_nb_transport_bw_export #(type T=tlm_generic_payload,
                                   type P=tlm_phase_e)
  extends uvm_port_base #(tlm_if #(T,P));
  `UVM_EXPORT_COMMON(`TLM_NB_BW_MASK, "tlm_nb_transport_bw_export")
  `TLM_NB_TRANSPORT_BW_IMP(this.m_if, T, P, t, p, delay)
    endclass

// class: tlm_b_transport_export
//
// Blocking transport export class.
// Any class instantiating this blocking transport export must 
// provide an implementation of the <b_transport> task.
class tlm_b_transport_export #(type T=tlm_generic_payload)
  extends uvm_port_base #(tlm_if #(T));
  `UVM_EXPORT_COMMON(`TLM_B_MASK, "tlm_b_transport_export")
  `TLM_B_TRANSPORT_IMP(this.m_if, T, t, delay)
endclass
