//
//------------------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc. 
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
//------------------------------------------------------------------------------

`ifndef UVM_MISC_SVH
`define UVM_MISC_SVH


//------------------------------------------------------------------------------
//
// Topic: uvm_void
//
// The ~uvm_void~ class is the base class for all UVM classes. It is an abstract
// class with no data members or functions. It allows for generic containers of
// objects to be created, similar to a void pointer in the C programming
// language. User classes derived directly from ~uvm_void~ inherit none of the
// UVM functionality, but such classes may be placed in ~uvm_void~-typed
// containers along with other UVM objects.
//
//------------------------------------------------------------------------------

virtual class uvm_void;
endclass

// Append/prepend symbolic values for order-dependent APIs
typedef enum {UVM_APPEND, UVM_PREPEND} uvm_apprepend;

// Forward declaration since scope stack uses uvm_objects now
typedef class uvm_object;

//----------------------------------------------------------------------------
//
// CLASS- uvm_scope_stack
//
//----------------------------------------------------------------------------

class uvm_scope_stack;
  local string   m_scope="";
  local string   m_scope_arg="";
  local int      m_depth=0;
  local bit      m_object_map[uvm_void];
  local uvm_void m_stack[$];

  extern function void   set          (string s, uvm_object obj);
  extern function void   down         (string s, uvm_object obj);
  extern function void   down_element (int element, uvm_object obj);
  extern function void   up           (uvm_object obj, byte separator=".");
  extern function void   up_element   (uvm_object obj);
  extern function void   set_arg      (string arg);
  extern function void   unset_arg    (string arg);
  extern function void   set_arg_element  (string arg, int ele);
  extern function int    depth        ();
  extern function string get          ();
  extern function string get_arg      ();
  extern function uvm_object current    ();

  extern function bit    in_hierarchy  (uvm_object obj);
endclass

`endif // UVM_MISC_SVH
