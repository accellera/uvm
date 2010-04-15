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


// This file pulls in only untemplated classes. This allows for the 
// untemplated base code to reside in a package. For simulators
// which do not fully support templated classes in packages, this
// allows the base classes to be shared by many scopes. The file
// uvm_templates.svh can be included in each scope that needs to use
// the templated classes.


`ifndef UVM_BASE_PKG_SV
`define UVM_BASE_PKG_SV

// the following indicates only the base layer is being brought in
`define UVM_BASE_ONLY

// the following indicates we are creating a package
`define UVM_PKG_SV

package uvm_pkg;

`ifdef USE_PARAMETERIZED_WRAPPER
  `include "uvm.svh"
`else
  `include "uvm_macros.svh"
  `include "base/base.svh"
  `include "methodology/methodology_noparm.svh"
`endif
endpackage


`endif


