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

    add_string ("catcher_name", get_name());

    return THROW;
  endfunction
endclass

class my_server extends uvm_default_report_server;
  virtual function string compose_report_message(uvm_report_message report_message, string report_object_name = "");
    report_message.add_string("server_name", get_name());

    compose_report_message = super.compose_report_message(report_message, report_object_name);
  endfunction
endclass

class my_handler extends uvm_report_handler;
  `uvm_object_utils(my_handler)

  function new(string name = "my_report_handler");
    super.new(name);
  endfunction

  virtual function void process_report_message(uvm_report_message report_message);
    report_message.add_string("handler_name", get_name());
    super.process_report_message(report_message);
  endfunction
endclass

class test extends uvm_test;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent = null);
     super.new(name, parent);
  endfunction

  virtual function void uvm_process_report_message(uvm_report_message report_message);
    report_message.add_string ("component_name", get_name());
    super.uvm_process_report_message(report_message);
  endfunction


  virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    $display("START OF GOLD FILE");
    `uvm_info("ID0", "Message 0", UVM_MEDIUM)
    $display("END OF GOLD FILE");

    phase.drop_objection(this);
  endtask

endclass

initial begin
     static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

     static uvm_factory fact = cs_.get_factory();
     static my_server server = new();
     static my_catcher catcher = new();
     uvm_report_cb::add(null, catcher);
     uvm_report_server::set_server(server);
     fact.set_type_override_by_type(uvm_report_handler::get_type(), my_handler::get_type());
     fact.print();

     run_test();
  end

endprogram
