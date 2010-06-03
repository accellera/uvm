//------------------------------------------------------------------------------
//    Copyright 2008 Mentor Graphics Corporation
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the "License"); you may
//    not use this file except in compliance with the License.  You may obtain
//    a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//    License for the specific language governing permissions and limitations
//    under the License.
//------------------------------------------------------------------------------
`ifndef UVM_ON_TOP
  `ifndef VMM_ON_TOP
     "No UVM|VMM_ON_TOP... must define UVM_ON_TOP or VMM_ON_TOP"
  `endif
`endif
  
`include "uvm_pkg.sv"
`include "vmm.sv"

package avt_interop_pkg;
  import uvm_pkg::*;
  import vmm_std_lib::*;
  
// for UVM_ON_TOP
`include "avt_uvm_vmm_log_fmt.sv"
`include "avt_uvm_vmm_env.sv"

// for VMM_ON_TOP
`include "avt_vmm_uvm_report_server.sv"
`include "avt_vmm_uvm_env.sv"

`include "avt_converter.sv"

`include "avt_uvm_tlm2channel.sv"
`include "avt_channel2uvm_tlm.sv"
`include "avt_analysis_channel.sv"
`include "avt_analysis2notify.sv"
`include "avt_notify2analysis.sv"

endpackage // avt_interop_pkg
  
