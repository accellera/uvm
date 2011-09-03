//----------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics Corporation
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
// Title: TLM Sockets
//
// A collection of TLM2 socket types.
//
// Termination Sockets - A termination socket must be the terminus
// of every TLM path.  A transaction originates with an initator socket
// and ultimately ends up in a target socket.  There may be zero or more
// passthrough sockets between initiator and target.
//
// Passthrough Sockets - Passthrough sockets are used to connect an
// initiator socket up the component hierarchy toward some target socket.
// They contain an export for connecting the backward path from that target
// socket back to the initiator socket. Passthrough targets are used to
// promote a target socket interface up the component hierarchy toward
// some initiator socket.  They contain a port for connecting the
// backward path from the child target socket back to the originating
// initiator socket.
//----------------------------------------------------------------------


class uvm_tlm_target_socket_base #(type T=uvm_tlm_generic_payload,
                                        P=uvm_tlm_phase_e)
                              extends uvm_port_base #(uvm_tlm_if #(T,P));

  uvm_tlm_nb_transport_bw_port #(T,P) bw_port;

  function new (string name, uvm_component parent,
                uvm_port_type_e port_type, int min_size=1, int max_size=1);
    super.new (name, parent, port_type, min_size, max_size);
    m_if_mask = `UVM_TLM_NB_FW_MASK + `UVM_TLM_B_MASK +
                `UVM_TLM_NB_BW_MASK;
    bw_port = new("bw_port", get_comp());
  endfunction

endclass



class uvm_tlm_initiator_socket_base #(type T=uvm_tlm_generic_payload,
                                        P=uvm_tlm_phase_e)
                              extends uvm_port_base #(uvm_tlm_if #(T,P));

  function new (string name, uvm_component parent,
                int min_size=1, int max_size=1);
    super.new (name, parent, UVM_PORT, min_size, max_size);
    m_if_mask = `UVM_TLM_NB_FW_MASK + `UVM_TLM_B_MASK +
                `UVM_TLM_NB_BW_MASK;
  endfunction
  virtual function void connect_bw(uvm_port_base #(uvm_tlm_if #(T,P)) provider);
  endfunction

endclass





//----------------------------------------------------------------------
// Class: uvm_tlm_target_socket
//
// IS-A forward imp; HAS-A backward port
//
// The component instantiating this socket must implement
// the nb_transport_fw() and b_transport() methods.
//
//|   function uvm_tlm_sync_e nb_transport_fw(T t, ref P p, input uvm_tlm_time delay);
//|   task b_transport(T t, uvm_tlm_time delay);
//
//----------------------------------------------------------------------

class uvm_tlm_target_socket #(type T=uvm_tlm_generic_payload,
                                   P=uvm_tlm_phase_e,
                                   IMP_NB=uvm_void,
                                   IMP_B=IMP_NB)
            extends uvm_tlm_target_socket_base #(T,P);

  local IMP_B m_imp_b;
  local IMP_NB m_imp_fw_nb;


  function new (string name, uvm_component parent,
                IMP_NB imp_nb = null, IMP_B imp_b = null);

    super.new (name, parent,UVM_IMPLEMENTATION,1,1);

    if (imp_b == null)
      $cast(m_imp_b, parent);
    else
      m_imp_b = imp_b;

    if (m_imp_b == null)
       `uvm_error("UVM/TLM2/NOIMP", {"uvm_tlm_target_socket ", name,
                                     " has no b_transport implementation"});

    if (imp_nb == null)
      $cast(m_imp_fw_nb, parent);
    else
      m_imp_fw_nb = imp_nb;

    if (m_imp_fw_nb == null)
       `uvm_error("UVM/TLM2/NOIMP", {"uvm_tlm_target_socket ", name,
                                     " has no nb_transport_fw implementation"});
  endfunction

  const static string type_name = "uvm_tlm_target_socket";

  virtual function string get_type_name();
    return type_name;
  endfunction

  `UVM_TLM_B_TRANSPORT_IMP    (m_imp_b, T, t, delay)
  `UVM_TLM_NB_TRANSPORT_FW_IMP(m_imp_fw_nb, T, P, t, p, delay)
  `UVM_TLM_NB_TRANSPORT_BW_IMP(bw_port, T, P, t, p, delay)

endclass



//----------------------------------------------------------------------
// Class: uvm_tlm_passthrough_target_socket
//
// IS-A forward export; HAS-A backward port
//----------------------------------------------------------------------
class uvm_tlm_passthrough_target_socket #(type T=uvm_tlm_generic_payload,
                                               P=uvm_tlm_phase_e)
                          extends uvm_tlm_target_socket_base #(T,P);

  
  function new (string name, uvm_component parent,
                int min_size=1, int max_size=1);
    super.new (name, parent, UVM_EXPORT, min_size, max_size);
  endfunction

  const static string type_name = "uvm_tlm_passthrough_target_socket";

  virtual function string get_type_name();
    return type_name;
  endfunction

  function void connect(uvm_port_base #(uvm_tlm_if #(T,P)) provider);
    uvm_tlm_target_socket_base #(T,P) target;
    if ($cast(target,provider)) begin
      target.bw_port.connect(bw_port);
      super.connect(provider);
    end
    else
      `uvm_error("TLM2/CONNECT",{"Can not connect ",get_full_name()," to ",
              provider.get_full_name(),", which is not a compatible type."})
  endfunction

  `UVM_TLM_B_TRANSPORT_IMP    (this.m_if, T, t, delay)
  `UVM_TLM_NB_TRANSPORT_FW_IMP(this.m_if, T, P, t, p, delay)
  `UVM_TLM_NB_TRANSPORT_BW_IMP(bw_port,   T, P, t, p, delay)

endclass


//----------------------------------------------------------------------
// Class: uvm_tlm_passthrough_initiator_socket
//
// IS-A forward port; HAS-A backward export
//----------------------------------------------------------------------
class uvm_tlm_passthrough_initiator_socket #(type T=uvm_tlm_generic_payload,
                                                  P=uvm_tlm_phase_e)
                extends uvm_tlm_initiator_socket_base #(T,P);

  uvm_tlm_nb_transport_bw_export #(T,P) bw_export;

  function new (string name, uvm_component parent,
                int min_size=1, int max_size=1);
    super.new (name, parent, min_size, max_size);
    bw_export = new("bw_export", get_comp());
  endfunction

  const static string type_name = "uvm_tlm_passthrough_initiator_socket";

  virtual function string get_type_name();
    return type_name;
  endfunction

  function void connect(uvm_port_base #(uvm_tlm_if #(T,P)) provider);
    uvm_tlm_target_socket_base #(T,P) target;
    uvm_tlm_passthrough_initiator_socket #(T,P) init_pt;
    if ($cast(init_pt,provider))
      bw_export.connect(init_pt.bw_export);
    else if ($cast(target,provider))
      target.bw_port.connect(bw_export);
    else begin
      `uvm_error("TLM2/CONNECT",{"Can not connect ",get_full_name()," to ",
              provider.get_full_name(),", which is not a compatible type."})
      return;
    end
    super.connect(provider);
  endfunction

  `UVM_TLM_B_TRANSPORT_IMP(m_if, T, t, delay)
  `UVM_TLM_NB_TRANSPORT_FW_IMP(m_if, T, P, t, p, delay)
  `UVM_TLM_NB_TRANSPORT_BW_IMP(bw_export, T, P, t, p, delay)

endclass


//----------------------------------------------------------------------
// Class: uvm_tlm_initiator_socket
//
// IS-A forward PORT; HAS-A backward imp
//
// The component instantiating this socket must implement
// a nb_transport_bw() method.
//
//|  function uvm_tlm_sync_e nb_transport_bw(T t, ref P p, input uvm_tlm_time delay);
//
//----------------------------------------------------------------------

class uvm_tlm_initiator_socket #(type T=uvm_tlm_generic_payload,
                                      P=uvm_tlm_phase_e,
                                      IMP_BW=uvm_void)
                extends uvm_tlm_initiator_socket_base #(T,P);

  uvm_tlm_nb_transport_bw_imp #(T,P,IMP_BW) bw_imp;

  function new (string name, uvm_component parent, IMP_BW imp=null,
                int min_size=1, int max_size=1);
    super.new (name, parent, min_size, max_size);
    // The bw_imp parent can not be the containing socket
    bw_imp = new("bw_imp", parent, imp);
  endfunction

  const static string type_name = "uvm_tlm_initiator_socket";

  virtual function string get_type_name();
    return type_name;
  endfunction


  typedef uvm_tlm_target_socket_base #(T,P) base_type;

  function void connect(uvm_port_base #(uvm_tlm_if #(T,P)) provider);
    uvm_tlm_passthrough_initiator_socket #(T,P) init_pt;
    uvm_tlm_target_socket_base #(T,P) target;
    if ($cast(init_pt,provider))
      init_pt.bw_export.connect(bw_imp);
    else if ($cast(target,provider))
      target.bw_port.connect(bw_imp);
    else begin
      `uvm_error("TLM2/CONNECT",{"Can not connect ",get_full_name()," to ",
              provider.get_full_name(),", which is not a compatible type."})
      return;
    end
    super.connect(provider);
  endfunction

  `UVM_TLM_B_TRANSPORT_IMP    (m_if, T, t, delay)
  `UVM_TLM_NB_TRANSPORT_FW_IMP(m_if, T, P, t, p, delay)
  `UVM_TLM_NB_TRANSPORT_BW_IMP(bw_imp, T, P, t, p, delay)

endclass



