//
//----------------------------------------------------------------------
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
//----------------------------------------------------------------------

`ifndef UVM_MACROS_SVH
`define UVM_MACROS_SVH


// Default settings
`define _protected protected   
`define uvm_clear_queue(Q) Q.delete();
`define UVM_USE_FPC
`define UVM_USE_P_FORMAT
`define UVM_USE_FILE_LINE
`define UVM_USE_ALT_PHASING

//
// Any vendor specific defines go here.
//
`ifdef VCS
`endif

`ifdef QUESTA
  `undef  uvm_clear_queue
  `define uvm_clear_queue(Q) Q = '{};
  `undef  UVM_USE_ALT_PHASING
`endif

`ifdef INCA
  `ifndef INCA_PROTECTED_CTOR
    `undef _protected
    `define _protected 
  `endif
  `ifndef INCA_UVM_USE_FPC
    `undef  UVM_USE_FPC
  `endif
  `ifndef INCA_UVM_USE_P_FORMAT
    `undef  UVM_USE_P_FORMAT
  `endif
  `ifndef INCA_UVM_USE_FILE_LINE
    `undef  UVM_USE_FILE_LINE
  `endif
  `ifndef INCA_UVM_USE_AAOFAA
    `define UVM_USE_AAOFAA_WA
  `endif
`endif

`include "macros/uvm_version_defines.svh"
`include "macros/uvm_message_defines.svh"
`include "macros/uvm_phase_defines.svh"
`include "macros/uvm_object_defines.svh"
`include "macros/uvm_printer_defines.svh"
`include "macros/uvm_tlm_defines.svh"
`include "macros/uvm_sequence_defines.svh"
`include "macros/uvm_callback_defines.svh"

`endif
