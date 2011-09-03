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
// Each uvm_tlm_*_socket class is derived from a corresponding
// uvm_tlm_*_socket_base class.  The base class contains most of the
// implementation of the class, The derived classes (in this file)
// contain the connection semantics.
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
//----------------------------------------------------------------------

//------------------------
// Group: Blocking Sockets
//------------------------

//----------------------------------------------------------------------
// Class: uvm_tlm_b_initiator_socket
//
// IS-A forward port; has no backward path except via the payload
// contents. The blocking transport socket is equivalent to a
// <uvm_tlm_b_transport_port>. 
//----------------------------------------------------------------------

class uvm_tlm_b_initiator_socket #(type T=uvm_tlm_generic_payload)
                           extends uvm_tlm_b_transport_port #(T);

  // Function: new
  //
  // Construct a new instance of this socket
  //
  function new (string name, uvm_component parent,
                int min_size=1, int max_size=1);
    super.new (name, parent, min_size, max_size);
  endfunction

  const static string type_name = "uvm_tlm_b_initiator_socket";

  virtual function string get_type_name();
    return type_name;
  endfunction
   
endclass


//----------------------------------------------------------------------
// Class: uvm_tlm_b_target_socket
//
// IS-A forward imp; has no backward path except via the payload
// contents. The blocking transport socket is equivalent to a
// <uvm_tlm_b_transport_imp>.
//
// The component instantiating this socket must implement
// a b_transport() method with the following signature
//
//|   task b_transport(T t, uvm_tlm_time delay);
//
//----------------------------------------------------------------------

class uvm_tlm_b_target_socket #(type IMP=int,
                                type T=uvm_tlm_generic_payload)
                    extends uvm_tlm_b_transport_imp #(T,IMP);

  // Function: new
  //
  // Construct a new instance of this socket ~imp~ is a reference to the
  // class implementing the b_transport() method. If not specified, it
  // is assumed to be the same as ~parent~. The ~imp~ is not required
  // to be a component.
  //
  function new (string name, uvm_component parent, IMP imp=null);
    super.new (name, parent, imp);
  endfunction

  const static string type_name = "uvm_tlm_b_target_socket";

  virtual function string get_type_name();
    return type_name;
  endfunction
   
endclass


//----------------------------------------------------------------------
// Class: uvm_tlm_b_passthrough_initiator_socket
//
// IS-A forward port. Equivalent to a <uvm_tlm_b_transport_port>.
//----------------------------------------------------------------------

class uvm_tlm_b_passthrough_initiator_socket #(type T=uvm_tlm_generic_payload)
  extends uvm_tlm_b_transport_port #(T);

  function new (string name, uvm_component parent,
                int min_size=1, int max_size=1);
    super.new (name, parent, min_size, max_size);
  endfunction

  const static string type_name = "uvm_tlm_b_passthrough_initiator_socket";

  virtual function string get_type_name();
    return type_name;
  endfunction
   
endclass


//----------------------------------------------------------------------
// Class: uvm_tlm_b_passthrough_target_socket
//
// IS-A forward export. Equivalent to a <uvm_tlm_b_transport_export>.
//----------------------------------------------------------------------
class uvm_tlm_b_passthrough_target_socket #(type T=uvm_tlm_generic_payload)
  extends uvm_tlm_b_transport_export #(T);

  function new (string name, uvm_component parent,
                int min_size=1, int max_size=1);
    super.new (name, parent, min_size, max_size);
  endfunction

  const static string type_name = "uvm_tlm_b_passthrough_target_socket";

  virtual function string get_type_name();
    return type_name;
  endfunction
   
endclass



//---------------------------
// Group: Nonblocking Sockets
//---------------------------

`define UVM_TLM_NB_SOCKET_COMMON(TYPE) \
  task b_transport(T t, uvm_tlm_time delay);  \
    uvm_component comp = get_comp(); \
    `uvm_error_context("UVM/TLM/NOTIMPL", \
                  {get_full_name(), \
                   ".b_transport() called. The ",get_type_name(), \
                   " supports only the non-blocking interfaces"},comp) \
  endtask \
  \
  const static string type_name = `"TYPE`"; \
  \
  virtual function string get_type_name(); \
    return this.type_name; \
  endfunction


//----------------------------------------------------------------------
// Class: uvm_tlm_nb_initiator_socket
//
// IS-A forward port; HAS-A backward imp
//
// The component instantiating this socket must implement
// a nb_transport_bw() method with the following signature
//
//|   function uvm_tlm_sync_e nb_transport_bw(T t, ref P p, input uvm_tlm_time delay);
//
//----------------------------------------------------------------------

class uvm_tlm_nb_initiator_socket #(type IMP=int,
                                    type T=uvm_tlm_generic_payload,
                                    type P=uvm_tlm_phase_e)
                extends uvm_tlm_initiator_socket #(T,P,IMP);

  // Function: new
  //
  // Construct a new instance of this socket
  // ~imp~ is a reference to the class implementing the
  // nb_transport_bw() method.
  // If not specified, it is assume to be the same as ~parent~.

  function new (string name, uvm_component parent, IMP imp = null);
    super.new (name, parent, imp);
    m_if_mask = `UVM_TLM_NB_FW_MASK + `UVM_TLM_NB_BW_MASK;
  endfunction
  `UVM_TLM_NB_SOCKET_COMMON(uvm_tlm_nb_initiator_socket)
endclass


//----------------------------------------------------------------------
// Class: uvm_tlm_nb_target_socket
//
// IS-A forward imp; HAS-A backward port
//
// The component instantiating this socket must implement
// a nb_transport_fw() method with the following signature
//
//|   function uvm_tlm_sync_e nb_transport_fw(T t, ref P p, input uvm_tlm_time delay);
//
//----------------------------------------------------------------------

class uvm_tlm_nb_target_socket #(type IMP=int,
                                 type T=uvm_tlm_generic_payload,
                                 type P=uvm_tlm_phase_e)
         extends uvm_tlm_target_socket #(T,P,IMP,uvm_tlm_nb_target_socket #(IMP,T,P));

  function new (string name, uvm_component parent, IMP imp_nb=null);
    super.new (name, parent, imp_nb, this);
    m_if_mask = `UVM_TLM_NB_FW_MASK + `UVM_TLM_NB_BW_MASK;
  endfunction
  `UVM_TLM_NB_SOCKET_COMMON(uvm_tlm_nb_target_socket)
endclass


//----------------------------------------------------------------------
// Class: uvm_tlm_nb_passthrough_initiator_socket
//
// IS-A forward port; HAS-A backward export
//----------------------------------------------------------------------

class uvm_tlm_nb_passthrough_initiator_socket #(type T=uvm_tlm_generic_payload,
                                                type P=uvm_tlm_phase_e)
                        extends uvm_tlm_passthrough_initiator_socket #(T,P);

  function new(string name, uvm_component parent);
    super.new(name, parent);
    m_if_mask = `UVM_TLM_NB_FW_MASK + `UVM_TLM_NB_BW_MASK;
  endfunction
  `UVM_TLM_NB_SOCKET_COMMON(uvm_tlm_nb_passthrough_initiator_socket)
endclass

//----------------------------------------------------------------------
// Class: uvm_tlm_nb_passthrough_target_socket
//
// IS-A forward export; HAS-A backward port
//----------------------------------------------------------------------

class uvm_tlm_nb_passthrough_target_socket #(type T=uvm_tlm_generic_payload,
                                             type P=uvm_tlm_phase_e)
                           extends uvm_tlm_passthrough_target_socket #(T,P);

  function new(string name, uvm_component parent);
    super.new(name, parent);
    m_if_mask = `UVM_TLM_NB_FW_MASK + `UVM_TLM_NB_BW_MASK;
  endfunction
  `UVM_TLM_NB_SOCKET_COMMON(uvm_tlm_nb_passthrough_target_socket)
endclass

