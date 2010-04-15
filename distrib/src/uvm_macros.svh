//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   Copyright 2007-2009 Cadence Design Systems, Inc. 
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

`ifndef UVM_MACROS_SVH
`define UVM_MACROS_SVH

// Questa requires the qualifiers on the extern signature; IUS requires the
// qualifier to not be on the extern signature.
`ifdef INCA
  `define _protected /*for protected ctor. IUS doesn't support. */
  `define const      /*for const strings in certain contexts. */
  `define uvm_clear_queue(Q) \
    Q.delete();  //SV 2008
`else
  `define _protected protected
  `define const const
  `define uvm_clear_queue(Q) \
    Q = '{};  //SV 2005 and 2008
`endif

`include "macros/uvm_version_defines.svh"
`include "macros/uvm_message_defines.svh"
`include "macros/uvm_phase_defines.svh"
`include "macros/uvm_object_defines.svh"
`include "macros/uvm_printer_defines.svh"
`include "macros/uvm_tlm_defines.svh"
`include "macros/uvm_sequence_defines.svh"
`include "macros/uvm_callback_defines.svh"

`include "macros/uvm_layered_stimulus_defines.svh"

`endif
