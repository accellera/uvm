//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2011 Mentor Graphics Corporation
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

module top;

import uvm_pkg::*;
`include "uvm_macros.svh"

uvm_report_object urm0 = new("urm0");
uvm_report_object urm1 = new("urm1");

initial
  begin
    urm1.set_report_severity_action(UVM_INFO, UVM_RM_RECORD | UVM_DISPLAY);
    `uvm_info("ID0", "Message 0", UVM_NONE)
    `uvm_info("ID1", "Message 1", UVM_NONE)
    `uvm_info("ID2", "Message 2", UVM_NONE, uvm_top)
    `uvm_info("ID3", "Message 3", UVM_NONE, urm0)
    `uvm_info("ID4", "Message 4", UVM_NONE, urm1)
    `uvm_info("ID5", "Message 5", UVM_NONE, urm0, "contextA")
    `uvm_info("ID6", "Message 6", UVM_NONE, urm1, "contextA")
    `uvm_info("ID7", "Message 7", UVM_NONE, urm0, "contextB")
    `uvm_info("ID8", "Message 8", UVM_NONE, urm1, "contextB")
    `uvm_info("ID9", "Message 9", UVM_NONE, urm0, $psprintf("%m"))
    `uvm_info("IDA", "Message A", UVM_NONE, urm1, $psprintf("%m"))
    `uvm_info("ID5", "Message B (a repeat context)", UVM_NONE, urm0, "contextA")
    `uvm_info("ID6", "Message C (a repeat context)", UVM_NONE, urm1, "contextA")
  end

endmodule
