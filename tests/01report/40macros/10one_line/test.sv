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

    if(get_severity() == UVM_FATAL)
      set_severity(UVM_ERROR);

    return THROW;
  endfunction
endclass

class test extends uvm_test;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent = null);
     super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase); uvm_coreservice_t cs_ = uvm_coreservice_t::get();

    uvm_report_message msg;
    uvm_root top = cs_.get_root();

    phase.raise_objection(this);

    $display("GOLD-FILE-START");

    `uvm_info("I_TEST", "Testing info macro...", UVM_LOW)
    `uvm_warning("W_TEST", "Testing warning macro...")
    `uvm_error("E_TEST", "Testing error macro...")
    `uvm_fatal("F_TEST", "Testing fatal macro...")

    `uvm_info_context("I_TEST", "Testing info macro...", UVM_LOW, top)
    `uvm_warning_context("W_TEST", "Testing warning macro...", top)
    `uvm_error_context("E_TEST", "Testing error macro...", top)
    `uvm_fatal_context("F_TEST", "Testing fatal macro...", top)

    $display("GOLD-FILE-END");

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
