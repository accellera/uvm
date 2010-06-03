//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
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

package hfpb_components_pkg;

  import uvm_pkg::*;
  import hfpb_pkg::*;
//  import fpu_uvm_tlm_pkg::*;

  const string objection_barrier = "objection";

  // transaction-level driver
  `include "hfpb_tlm_driver.svh"

  // masters
  `include "hfpb_master_base.svh"
//  `include "hfpb_float_mem_master.svh"
//  `include "hfpb_fpu_master.svh"
  `include "hfpb_random_mem_master.svh"
  `include "hfpb_directed_mem_master.svh"
//  `include "calc.svh"  

  // slaves
  `include "hfpb_mem.svh"
//  `include "hfpb_fpu.svh"

endpackage
