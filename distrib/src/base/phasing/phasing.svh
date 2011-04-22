//
//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
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

`ifndef UVM_PHASING_SVH
 `define UVM_PHASING_SVH

// The phase declarations
 `include "base/phasing/uvm_phase.svh"
 `include "base/phasing/uvm_domain.svh"
 `include "base/phasing/uvm_bottomup_phase.svh"
 `include "base/phasing/uvm_topdown_phase.svh"
 `include "base/phasing/uvm_task_phase.svh"

 // Common Phases
 `include "base/phasing/uvm_build_phase.svh"
 `include "base/phasing/uvm_connect_phase.svh"
 `include "base/phasing/uvm_end_of_elaboration_phase.svh"
 `include "base/phasing/uvm_start_of_simulation_phase.svh"
 `include "base/phasing/uvm_run_phase.svh"
 `include "base/phasing/uvm_extract_phase.svh"
 `include "base/phasing/uvm_check_phase.svh"
 `include "base/phasing/uvm_report_phase.svh"
 `include "base/phasing/uvm_final_phase.svh"

 // Run-Time Phases
 `include "base/phasing/uvm_pre_reset_phase.svh"
 `include "base/phasing/uvm_reset_phase.svh"
 `include "base/phasing/uvm_post_reset_phase.svh"
 `include "base/phasing/uvm_pre_configure_phase.svh"
 `include "base/phasing/uvm_configure_phase.svh"
 `include "base/phasing/uvm_post_configure_phase.svh"
 `include "base/phasing/uvm_pre_main_phase.svh"
 `include "base/phasing/uvm_main_phase.svh"
 `include "base/phasing/uvm_post_main_phase.svh"
 `include "base/phasing/uvm_pre_shutdown_phase.svh"
 `include "base/phasing/uvm_shutdown_phase.svh"
 `include "base/phasing/uvm_post_shutdown_phase.svh"

 `include "base/phasing/uvm_process.svh"

// For backward compatibility with OVM only! Use the uvm_ prefixed
// handles for each phase, e.g. uvm_build_ph. Or better yet, always
// use uvm_<phase>_phase::get() to access the singleton handle
// for a given <phase>.
uvm_phase build_ph ;
uvm_phase connect_ph ;
uvm_phase end_of_elaboration_ph ;
uvm_phase start_of_simulation_ph ;
uvm_phase run_ph ;
uvm_phase extract_ph ;
uvm_phase check_ph ;
uvm_phase report_ph ;


`endif //  `ifndef UVM_PHASING_SVH
