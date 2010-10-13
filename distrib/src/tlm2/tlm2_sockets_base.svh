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
// Socket Base Classes
//
// A collection of base classes, one for each socket type.  The reason
// for having a base class for each socket is that all the socket (base)
// types must be known before connect is defined.  Socket connection
// semantics are provided in the derived classes, which are user
// visible.
//----------------------------------------------------------------------


//======================================================================
//=                                                                    =
//=                       Passthrough Sockets                          =
//=                                                                    =
//======================================================================
//
// Passthrough initiators are ports and contain exports -- i.e. IS-A
// port and HAS-A export.  Passthrough targets are the opposite, they
// are exports and contain ports.

//----------------------------------------------------------------------
// tlm_nb_passthrough_initiator_socket_base
//
// IS-A forward port; HAS-A backward export
//----------------------------------------------------------------------
class tlm_nb_passthrough_initiator_socket_base #(type T=tlm_generic_payload,
                                                  type P=tlm_phase_e)
  extends uvm_port_base #(tlm_if #(T,P));

  tlm_nb_transport_bw_export #(T,P) bw_export;

  function new (string name, uvm_component parent,
                int min_size=1, int max_size=1);
    super.new (name, parent, UVM_PORT, min_size, max_size);
    m_if_mask = `TLM_NB_FW_MASK;
    bw_export = new("bw_export", get_comp());
  endfunction

  `UVM_TLM_GET_TYPE_NAME("tlm_nb_passthrough_initiator_socket")

  `TLM_NB_TRANSPORT_FW_IMP(this.m_if, T, P, t, p, delay)
  `TLM_NB_TRANSPORT_BW_IMP(bw_export, T, P, t, p, delay)

endclass

//----------------------------------------------------------------------
// tlm_nb_passthrough_target_socket_base
//
// IS-A forward export; HAS-A backward port
//----------------------------------------------------------------------
class tlm_nb_passthrough_target_socket_base #(type T=tlm_generic_payload,
                                               type P=tlm_phase_e)
  extends uvm_port_base #(tlm_if #(T,P));

  tlm_nb_transport_bw_port #(T,P) bw_port;

  function new (string name, uvm_component parent,
                int min_size=1, int max_size=1);
    super.new (name, parent, UVM_EXPORT, min_size, max_size);
    m_if_mask = `TLM_NB_FW_MASK;
    bw_port = new("bw_port", get_comp());
  endfunction

  `UVM_TLM_GET_TYPE_NAME("tlm_nb_passthrough_target_socket")

  `TLM_NB_TRANSPORT_FW_IMP(this.m_if, T, P, t, p, delay)
  `TLM_NB_TRANSPORT_BW_IMP(bw_port, T, P, t, p, delay)

endclass

//----------------------------------------------------------------------
// tlm_b_passthrough_initiator_socket_base
//
// IS-A forward port;
//----------------------------------------------------------------------
class tlm_b_passthrough_initiator_socket_base #(type T=tlm_generic_payload)
  extends uvm_port_base #(tlm_if #(T));

  `UVM_PORT_COMMON(`TLM_B_MASK, "tlm_b_passthrough_initiator_socket")
  `TLM_B_TRANSPORT_IMP(this.m_if, T, t, delay)

endclass

//----------------------------------------------------------------------
// tlm_b_passthrough_target_socket_base
//
// IS-A forward export;
//----------------------------------------------------------------------
class tlm_b_passthrough_target_socket_base #(type T=tlm_generic_payload)
  extends uvm_port_base #(tlm_if #(T));

  `UVM_EXPORT_COMMON(`TLM_B_MASK, "tlm_b_passthrough_target_socket")
  `TLM_B_TRANSPORT_IMP(this.m_if, T, t, delay)

 endclass


//======================================================================
//=                                                                    =
//=                       Termination Sockets                          =
//=                                                                    =
//======================================================================
//
// A termination socket must be the terminus of every TLM path.  A
// transaction originates with an initator socket and ultimately ends up
// in a target socket.  There may be zero or more passthrough sockets
// between initiator and target.

//----------------------------------------------------------------------
// tlm_b_target_socket_base
//
// IS-A forward imp; has no backward path except via the payload
// contents.
//----------------------------------------------------------------------
class tlm_b_target_socket_base #(type T=tlm_generic_payload)
  extends uvm_port_base #(tlm_if #(T));

  function new (string name, uvm_component parent);
    super.new (name, parent, UVM_IMPLEMENTATION, 1, 1);
    m_if_mask = `TLM_B_MASK;
  endfunction

  `UVM_TLM_GET_TYPE_NAME("tlm_b_target_socket")

endclass

//----------------------------------------------------------------------
// tlm_b_initiator_socket_base
//
// IS-A forward port; has no backward path except via the payload
// contents
//----------------------------------------------------------------------
class tlm_b_initiator_socket_base #(type T=tlm_generic_payload)
  extends uvm_port_base #(tlm_if #(T));

  `UVM_PORT_COMMON(`TLM_B_MASK, "tlm_b_initiator_socket")
  `TLM_B_TRANSPORT_IMP(this.m_if, T, t, delay)

endclass

//----------------------------------------------------------------------
// tlm_nb_target_socket_base
//
// IS-A forward imp; HAS-A backward port
//----------------------------------------------------------------------
class tlm_nb_target_socket_base #(type T=tlm_generic_payload,
                                   type P=tlm_phase_e)
  extends uvm_port_base #(tlm_if #(T,P));

  tlm_nb_transport_bw_port #(T,P) bw_port;

  function new (string name, uvm_component parent);
    super.new (name, parent, UVM_IMPLEMENTATION, 1, 1);
    m_if_mask = `TLM_NB_FW_MASK;
  endfunction

  `UVM_TLM_GET_TYPE_NAME("tlm_nb_target_socket")

  `TLM_NB_TRANSPORT_BW_IMP(bw_port, T, P, t, p, delay)

endclass

//----------------------------------------------------------------------
// tlm_nb_initiator_socket_base
//
// IS-A forward port; HAS-A backward imp
//----------------------------------------------------------------------
class tlm_nb_initiator_socket_base #(type T=tlm_generic_payload,
                                      type P=tlm_phase_e)
  extends uvm_port_base #(tlm_if #(T,P));

  function new (string name, uvm_component parent);
    super.new (name, parent, UVM_PORT, 1, 1);
    m_if_mask = `TLM_NB_FW_MASK;
  endfunction

  `UVM_TLM_GET_TYPE_NAME("tlm_nb_initiator_socket")

  `TLM_NB_TRANSPORT_FW_IMP(this.m_if, T, P, t, p, delay)

endclass
