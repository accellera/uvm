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
// title: Sockets
//
// Each *_socket class is derived from a corresponding *_socket_base
// class.  The base class contains the "meat" of the class, the derived
// classes (in this file) contain the connection semantics.
//
// Sockets come in several flavors: Each socket is either an initiator or a 
// target, a passthrough or a terminator. Further, any particular socket 
// implements either the blocking interfaces or the nonblocking interfaces. 
// Terminator sockets are used on initiators and targets as well as 
// interconnect components as shown in the figure above. Passthrough
//  sockets are used to enable connections to cross hierarchical boundaries.
//
// There are eight socket types: the cross of blocking and nonblocking,
// passthrough and termination, target and initiator
//
// Sockets are specified based on what they are (IS-A)
// and what they contains (HAS-A).
// IS-A and HAS-A are types of object relationships. 
// IS-A refers to the inheritance relationship and
//  HAS-A refers to the ownership relationship. 
// For example if you say D is a B that means that D is derived from base B. 
// If you say object A HAS-A B that means that B is a member of A.
//
// The termination sockets are
//
//    -  <tlm_b_target_socket>
//
//    -  <tlm_b_initiator_socket>
//
//    -  <tlm_nb_target_socket>
//
//    -  <tlm_nb_initiator_socket>           
//
// The passthrough sockets are
//
//    -  <tlm_b_passthrough_initiator_socket>
//
//    -  <tlm_b_passthrough_target_socket>
//
//    -  <tlm_nb_passthrough_initiator_socket>
//
//    -  <tlm_nb_passthrough_target_socket>
//

//----------------------------------------------------------------------
// class: tlm_b_initiator_socket
//
// IS-A forward port; has no backward path except via the payload
// contents
//----------------------------------------------------------------------
class tlm_b_initiator_socket #(type T=tlm_generic_payload)
  extends tlm_b_initiator_socket_base #(T);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction 
   
   // Function: Connect
   //
   // Connect this socket to a <tlm_b_target_socket>
  function void connect(this_type provider);

    tlm_b_passthrough_initiator_socket_base #(T) initiator_pt_socket;
    tlm_b_passthrough_target_socket_base #(T) target_pt_socket;
    tlm_b_target_socket_base #(T) target_socket;

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
// Class: tlm_b_target_socket
//
// IS-A forward imp; has no backward path except via the payload
// contents.
//----------------------------------------------------------------------
class tlm_b_target_socket #(type T=tlm_generic_payload,
                             type IMP=int)
  extends tlm_b_target_socket_base #(T);

  local IMP m_imp;

  function new (string name, uvm_component parent, IMP imp);
    super.new (name, parent);
    m_imp = imp;
  endfunction

   // Function: Connect
   //
   // Connect this socket to a <tlm_b_initiator_socket>
  function void connect(this_type provider);

    uvm_component c;

    super.connect(provider);

    c = get_comp();
    `uvm_error_context(get_type_name(), "You cannot call connect() on a target termination socket", c)
  endfunction

  `TLM_B_TRANSPORT_IMP(m_imp, T, t, delay)

endclass

//----------------------------------------------------------------------
// Class: tlm_nb_initiator_socket
//
// IS-A forward port; HAS-A backward imp
//----------------------------------------------------------------------
class tlm_nb_initiator_socket #(type T=tlm_generic_payload,
                                 type P=tlm_phase_e,
                                 type IMP=int)
  extends tlm_nb_initiator_socket_base #(T,P);

  tlm_nb_transport_bw_imp #(T,P,IMP) bw_imp;

  function new(string name, uvm_component parent, IMP imp);
    super.new (name, parent);
    bw_imp = new("bw_imp", imp);
  endfunction

   // Function: Connect
   //
   // Connect this socket to a <tlm_nb_target_socket>
   function void connect(this_type provider);

    tlm_nb_passthrough_initiator_socket_base #(T,P) initiator_pt_socket;
    tlm_nb_passthrough_target_socket_base #(T,P) target_pt_socket;
    tlm_nb_target_socket_base #(T,P) target_socket;

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


//----------------------------------------------------------------------
// Class: tlm_nb_target_socket
//
// IS-A forward imp; HAS-A backward port
//----------------------------------------------------------------------
class tlm_nb_target_socket #(type T=tlm_generic_payload,
                              type P=tlm_phase_e,
                              type IMP=int)
  extends tlm_nb_target_socket_base #(T,P);

  local IMP m_imp;

  function new (string name, uvm_component parent, IMP imp);
    super.new (name, parent);
    m_imp = imp;
    bw_port = new("bw_port", get_comp());
  endfunction

   // Function: connect
   //
   // Connect this socket to a <tlm_nb_initiator_socket>
  function void connect(this_type provider);

    uvm_component c;

    super.connect(provider);

    c = get_comp();
    `uvm_error_context(get_type_name(), "You cannot call connect() on a target termination socket", c)
  endfunction

  `TLM_NB_TRANSPORT_FW_IMP(m_imp, T, P, t, p, delay)

endclass

//----------------------------------------------------------------------
// Class: tlm_b_passthrough_initiator_socket
//
// IS-A forward port;
//----------------------------------------------------------------------
class tlm_b_passthrough_initiator_socket #(type T=tlm_generic_payload)
  extends tlm_b_passthrough_initiator_socket_base #(T);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

   // Function : connect
   //
   // Connect this socket to a <tlm_b_target_socket>
  function void connect(this_type provider);

    tlm_b_passthrough_initiator_socket_base #(T) initiator_pt_socket;
    tlm_b_passthrough_target_socket_base #(T) target_pt_socket;
    tlm_b_target_socket_base #(T) target_socket;

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
// Class: tlm_b_passthrough_target_socket
//
// IS-A forward export;
//----------------------------------------------------------------------
class tlm_b_passthrough_target_socket #(type T=tlm_generic_payload)
  extends tlm_b_passthrough_target_socket_base #(T);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction 
   
   // Function : connect
   //
   // Connect this socket to a <tlm_b_initiator_socket>
  function void connect(this_type provider);

    tlm_b_passthrough_target_socket_base #(T) target_pt_socket;
    tlm_b_target_socket_base #(T) target_socket;

    uvm_component c;

    super.connect(provider);

    if($cast(target_pt_socket, provider)    ||
       $cast(target_socket, provider))
      return;

    c = get_comp();
    `uvm_error_context(get_type_name(), "type mismatch in connect -- connection cannot be completed", c)
  endfunction

endclass



//----------------------------------------------------------------------
// Class: tlm_nb_passthrough_initiator_socket
//
// IS-A forward port; HAS-A backward export
//----------------------------------------------------------------------
class tlm_nb_passthrough_initiator_socket #(type T=tlm_generic_payload,
                                             type P=tlm_phase_e)
  extends tlm_nb_passthrough_initiator_socket_base #(T,P);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

   // Function : connect
   //
   // Connect this socket to a <tlm_nb_target_socket>
  function void connect(this_type provider);

    tlm_nb_passthrough_initiator_socket_base #(T,P) initiator_pt_socket;
    tlm_nb_passthrough_target_socket_base #(T,P) target_pt_socket;
    tlm_nb_target_socket_base #(T,P) target_socket;

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
// Class: tlm_nb_passthrough_target_socket
//
// IS-A forward export; HAS-A backward port
//----------------------------------------------------------------------
class tlm_nb_passthrough_target_socket #(type T=tlm_generic_payload,
                                          type P=tlm_phase_e)
  extends tlm_nb_passthrough_target_socket_base #(T,P);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

   // Function: connect
   //
   // Connect this socket to a <tlm_nb_initiator_socket>
  function void connect(this_type provider);

    tlm_nb_passthrough_target_socket_base #(T,P) target_pt_socket;
    tlm_nb_target_socket_base #(T,P) target_socket;

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
