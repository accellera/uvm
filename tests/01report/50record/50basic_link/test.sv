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

//uvm_report_object urm0 = new("urm0");
uvm_report_object urm1 = new("urm1");


initial begin

    // User variables  
    uvm_trace_message l_trace_messageA, l_trace_messageB;
    int l_tr_handle0, l_tr_handle1;

    // Adjust action on urm1
    urm1.set_report_severity_action(UVM_INFO, UVM_RM_RECORD | UVM_DISPLAY);

    #5;

    // Message A starts at 5, Message B starts at 15.
    // Message A finishes at 35 (Message B is still going)
    // Message B finishes at 60

    // Spans #30 time
    `uvm_info_begin(l_trace_messageA, "TEST_A", "Beginning A...", UVM_LOW, urm1)

    #10;

    // Spans #45 time
    `uvm_info_begin(l_trace_messageB, "TEST_B", "Beginning B...", UVM_LOW, urm1)

    #20
    `uvm_info_end(l_trace_messageA, "Ending A...", l_tr_handle0)

    #25;
    `uvm_info_end(l_trace_messageB, "Ending B...", l_tr_handle1)

    #30;
    `uvm_link(l_tr_handle0, l_tr_handle1, "child", "TEST_L", UVM_LOW, urm1)

    #100;
    `uvm_link(-1 , l_tr_handle1, "BAD", "TEST_L", UVM_LOW, urm1)

end

endmodule
