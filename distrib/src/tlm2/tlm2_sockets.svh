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
// Sockets
//
// Each *_socket class is derived from a corresponding *_socket_base
// class.  The base class contains the "meat" of the class, the derived
// classes (in this file) contain the connection semantics.
//
// There are eight socket types: the cross of blocking and nonblocking,
// passthrough and termination, target and initiator
//
//    tlm2_nb_passthrough_initiator_socket
//    tlm2_nb_passthrough_target_socket
//    tlm2_b_passthrough_initiator_socket
//    tlm2_b_passthrough_target_socket
//    tlm2_b_target_socket
//    tlm2_b_initiator_socket
//    tlm2_nb_target_socket
//    tlm2_nb_initiator_socket
//
//----------------------------------------------------------------------

//======================================================================
//=                                                                    =
//=                       Passthrough Sockets                          =
//=                                                                    =
//======================================================================

//----------------------------------------------------------------------
// tlm2_nb_passthrough_initiator_socket
//
// IS-A forward port; HAS-A backward export
//----------------------------------------------------------------------
class tlm2_nb_passthrough_initiator_socket #(type T=tlm2_generic_payload,
                                             type P=tlm_phase_e)
  extends tlm2_nb_passthrough_initiator_socket_base #(T,P);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void connect(this_type provider);

    tlm2_nb_passthrough_initiator_socket_base #(T,P) initiator_pt_socket;
    tlm2_nb_passthrough_target_socket_base #(T,P) target_pt_socket;
    tlm2_nb_target_socket_base #(T,P) target_socket;

    uvm_component c;

    super.connect(provider);

    if($cast(initiator_pt_socket, provider)) begin
      bw_export.connect(initiator_pt_socket.bw_export);
      return;
    end

    if($cast(target_pt_socket, provider)) begin
      target_pt_socket.bw_port.connect(bw_export);
      return;
    end

    if($cast(target_socket, provider)) begin
      target_socket.bw_port.connect(bw_export);
      return;
    end

    c = get_comp();
    `uvm_error_context(get_type_name(), "type mismatch in connect -- connection cannot be completed", c)

  endfunction

endclass

//----------------------------------------------------------------------
// tlm2_nb_passthrough_target_socket
//
// IS-A forward export; HAS-A backward port
//----------------------------------------------------------------------
class tlm2_nb_passthrough_target_socket #(type T=tlm2_generic_payload,
                                          type P=tlm_phase_e)
  extends tlm2_nb_passthrough_target_socket_base #(T,P);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void connect(this_type provider);

    tlm2_nb_passthrough_target_socket_base #(T,P) target_pt_socket;
    tlm2_nb_target_socket_base #(T,P) target_socket;

    uvm_component c;

    super.connect(provider);

    if($cast(target_pt_socket, provider)) begin
      target_pt_socket.bw_port.connect(bw_port);
      return;
    end

    if($cast(target_socket, provider)) begin
      target_socket.bw_port.connect(bw_port);
      return;
    end

    c = get_comp();
    `uvm_error_context(get_type_name(), "type mismatch in connect -- connection cannot be completed", c)

  endfunction

endclass

//----------------------------------------------------------------------
// tlm2_b_passthrough_initiator_socket
//
// IS-A forward port;
//----------------------------------------------------------------------
class tlm2_b_passthrough_initiator_socket #(type T=tlm2_generic_payload)
  extends tlm2_b_passthrough_initiator_socket_base #(T);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void connect(this_type provider);

    tlm2_b_passthrough_initiator_socket_base #(T) initiator_pt_socket;
    tlm2_b_passthrough_target_socket_base #(T) target_pt_socket;
    tlm2_b_target_socket_base #(T) target_socket;

    uvm_component c;

    super.connect(provider);

    if($cast(initiator_pt_socket, provider) ||
       $cast(target_pt_socket, provider)    ||
       $cast(target_socket, provider))
      return;

    c = get_comp();
    `uvm_error_context(get_type_name(), "type mismatch in connect -- connection cannot be completed", c)

  endfunction

endclass

//----------------------------------------------------------------------
// tlm2_b_passthrough_target_socket
//
// IS-A forward export;
//----------------------------------------------------------------------
class tlm2_b_passthrough_target_socket #(type T=tlm2_generic_payload)
  extends tlm2_b_passthrough_target_socket_base #(T);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void connect(this_type provider);

    tlm2_b_passthrough_target_socket_base #(T) target_pt_socket;
    tlm2_b_target_socket_base #(T) target_socket;

    uvm_component c;

    super.connect(provider);

    if($cast(target_pt_socket, provider)    ||
       $cast(target_socket, provider))
      return;

    c = get_comp();
    `uvm_error_context(get_type_name(), "type mismatch in connect -- connection cannot be completed", c)
  endfunction

endclass


//======================================================================
//=                                                                    =
//=                       Termination Sockets                          =
//=                                                                    =
//======================================================================

//----------------------------------------------------------------------
// tlm2_b_target_socket
//
// IS-A forward imp; has no backward path except via the payload
// contents.
//----------------------------------------------------------------------
class tlm2_b_target_socket #(type T=tlm2_generic_payload,
                             type IMP=int)
  extends tlm2_b_target_socket_base #(T);

  local IMP m_imp;

  function new (string name, uvm_component parent, IMP imp);
    super.new (name, parent);
    m_imp = imp;
  endfunction

  function void connect(this_type provider);

    uvm_component c;

    super.connect(provider);

    c = get_comp();
    `uvm_error_context(get_type_name(), "You cannot call connect() on a target termination socket", c)
  endfunction

  `TLM2_B_TRANSPORT_IMP(m_imp, T, t, delay)

endclass

//----------------------------------------------------------------------
// tlm2_b_initiator_socket
//
// IS-A forward port; has no backward path except via the payload
// contents
//----------------------------------------------------------------------
class tlm2_b_initiator_socket #(type T=tlm2_generic_payload)
  extends tlm2_b_initiator_socket_base #(T);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void connect(this_type provider);

    tlm2_b_passthrough_initiator_socket_base #(T) initiator_pt_socket;
    tlm2_b_passthrough_target_socket_base #(T) target_pt_socket;
    tlm2_b_target_socket_base #(T) target_socket;

    uvm_component c;

    super.connect(provider);

    if($cast(initiator_pt_socket, provider)  ||
       $cast(target_pt_socket, provider)     ||
       $cast(target_socket, provider))
      return;

    c = get_comp();
    `uvm_error_context(get_type_name(), "type mismatch in connect -- connection cannot be completed", c)

  endfunction

endclass

//----------------------------------------------------------------------
// tlm2_nb_target_socket
//
// IS-A forward imp; HAS-A backward port
//----------------------------------------------------------------------
class tlm2_nb_target_socket #(type T=tlm2_generic_payload,
                              type P=tlm_phase_e,
                              type IMP=int)
  extends tlm2_nb_target_socket_base #(T,P);

  local IMP m_imp;

  function new (string name, uvm_component parent, IMP imp);
    super.new (name, parent);
    m_imp = imp;
    bw_port = new("bw_port", get_comp());
  endfunction

  function void connect(this_type provider);

    uvm_component c;

    super.connect(provider);

    c = get_comp();
    `uvm_error_context(get_type_name(), "You cannot call connect() on a target termination socket", c)
  endfunction

  `TLM2_NB_TRANSPORT_FW_IMP(m_imp, T, P, t, p, delay)

endclass

//----------------------------------------------------------------------
// tlm2_nb_initiator_socket
//
// IS-A forward port; HAS-A backward imp
//----------------------------------------------------------------------
class tlm2_nb_initiator_socket #(type T=tlm2_generic_payload,
                                 type P=tlm_phase_e,
                                 type IMP=int)
  extends tlm2_nb_initiator_socket_base #(T,P);

  tlm_nb_transport_bw_imp #(T,P,IMP) bw_imp;

  function new(string name, uvm_component parent, IMP imp);
    super.new (name, parent);
    bw_imp = new("bw_imp", imp);
  endfunction

  function void connect(this_type provider);

    tlm2_nb_passthrough_initiator_socket_base #(T,P) initiator_pt_socket;
    tlm2_nb_passthrough_target_socket_base #(T,P) target_pt_socket;
    tlm2_nb_target_socket_base #(T,P) target_socket;

    uvm_component c;

    super.connect(provider);

    if($cast(initiator_pt_socket, provider)) begin
      initiator_pt_socket.bw_export.connect(bw_imp);
      return;
    end
    if($cast(target_pt_socket, provider)) begin
      target_pt_socket.bw_port.connect(bw_imp);
      return;
    end

    if($cast(target_socket, provider)) begin
      target_socket.bw_port.connect(bw_imp);
      return;
    end
    
    c = get_comp();
    `uvm_error_context(get_type_name(), "type mismatch in connect -- connection cannot be completed", c)

  endfunction

endclass
