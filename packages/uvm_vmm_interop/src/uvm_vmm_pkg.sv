//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc. 
//   Copyright 2010 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary derivative
//   work of Synopsys, Inc., and is fully protected under copyright and
//   trade secret laws. You may not view, use, disclose, copy, or
//   distribute this file or any information contained herein except
//   pursuant to a valid written license from Synopsys.
//
//   The Original Work is licensed under the Apache License, Version 2.0.
//
//   You may obtain a copy of the Original Work at
//
//       http://www.accellera.org/activities/vip/
//
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//
//----------------------------------------------------------------------

`ifndef UVM_VMM_PKG_SV
`define UVM_VMM_PKG_SV

`ifndef UVM_PKG_SV
`include "uvm_pkg.sv" // DO NOT INLINE

`endif

`ifndef VMM__SV
`define VMM_IN_PACKAGE
`include "vmm.sv" // DO NOT INLINE

`endif

import uvm_pkg::*;

`include "avt_adapters.sv"
import avt_interop_pkg::*;

`endif // UVM_VMM_PKG_SV
