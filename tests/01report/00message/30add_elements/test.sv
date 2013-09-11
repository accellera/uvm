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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_catcher extends uvm_report_catcher;
  virtual function action_e catch();
    uvm_report_message l_msg;


    add_string ("catcher_name", get_name());

    return THROW;
  endfunction
endclass


class test extends uvm_test;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent = null);
     super.new(name, parent);
  endfunction

  virtual function void uvm_report( uvm_severity severity,
                                    string id,
                                    string message,
                                    int verbosity = (severity == uvm_severity'(UVM_ERROR)) ? UVM_LOW :
                                                    (severity == uvm_severity'(UVM_FATAL)) ? UVM_NONE : UVM_MEDIUM,
                                    string filename = "",
                                    int line = 0,
                                    string context_name = "",
                                    bit report_enabled_checked =0);
    uvm_report_message l_report_message;
    if (report_enabled_checked == 0) begin
      if (!uvm_report_enabled(verbosity, severity, id))
        return;
    end
    l_report_message = uvm_report_message::get_report_message();
    l_report_message.set_report_message(filename, line,
      uvm_severity_type'(severity), id, message, verbosity, context_name);

    l_report_message.add_string ("component_name", get_name());

    process_report_message(l_report_message);
    l_report_message.free_report_message(l_report_message);
  endfunction


  virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    $display("START OF GOLD FILE");
    `uvm_info("ID0", "Message 0", UVM_MEDIUM)
    $display("END OF GOLD FILE");

    phase.drop_objection(this);
  endtask

endclass

initial
  begin
     static my_catcher catcher = new();
     uvm_report_cb::add(null, catcher);

     run_test();
  end

endprogram
