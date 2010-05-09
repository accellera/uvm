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

`ifndef UVM_BASE_SVH
`define UVM_BASE_SVH

  // Miscellaneous classes and functions. uvm_void is defined in uvm_misc,
  // along with some auxillary functions that UVM needs but are not really
  // part of UVM.
  `include "base/uvm_version.svh"
  `include "base/uvm_misc.sv"

  // The base object element. Contains data methods (copy/compare etc) and
  // factory creation methods (create). Also includes control classes.
  `include "base/uvm_object_globals.svh"
  `include "base/uvm_object.sv"

  `include "base/uvm_pool.svh"
  `include "base/uvm_queue.svh"

  // Policies
  `include "base/uvm_printer.sv"
  `include "base/uvm_comparer.svh"
  `include "base/uvm_packer.sv"
  `include "base/uvm_recorder.svh"

  // Event interface
  `include "base/uvm_event_callback.svh"
  `include "base/uvm_event.svh"
  `include "base/uvm_barrier.svh"

  // Callback interface
  `include "base/uvm_callback.svh"

  // Reporting interface
  `include "base/uvm_report_catcher.svh"
  `include "base/uvm_report_server.svh"
  `include "base/uvm_report_handler.svh"
  `include "base/uvm_report_object.svh"

  // Base transaction object
  `include "base/uvm_transaction.sv"

  // The phase declarations. uvm_component does the actual phasing.
  `include "base/uvm_phases.sv"

  // uvm_component has a co-dependency with the factory. 
  `include "base/uvm_factory.sv"
  `include "base/uvm_registry.svh"

  `include "base/uvm_component.sv"
  `include "base/uvm_config.sv"

  // Objection interface
  `include "base/uvm_objection.svh"
  `include "base/uvm_heartbeat.svh"

  `include "base/uvm_globals.svh"

  `include "base/uvm_extern_report_server.svh"

`endif // UVM_BASE_SVH
