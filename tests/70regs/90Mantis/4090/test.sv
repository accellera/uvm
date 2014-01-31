//---------------------------------------------------------------------- 
//   Copyright 2012 Accellera Systems Initiative
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

  `include "uvm_macros.svh"
  import uvm_pkg::*;

class a_reg extends uvm_reg;
  bit volatile = 1;
  uvm_reg_field VOL0;
  uvm_reg_field VOL1;

  `uvm_object_utils(a_reg)
  
  function new(string name = "a_reg");
    super.new(name,64,UVM_NO_COVERAGE);
  endfunction

  virtual function build();
    this.VOL0 = uvm_reg_field::type_id::create("VOL0");
    this.VOL0.configure(this, 1, 0, "RW", volatile, 1'b0, 1, 0, 0);
    this.VOL1 = uvm_reg_field::type_id::create("VOL1");
    this.VOL1.configure(this, 1, 1, "RW", ~volatile, 1'b0, 1, 0, 0);
  endfunction
endclass
  
class test extends uvm_test;
  a_reg rg;
  
  `uvm_component_utils(test)

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    rg = a_reg::type_id::create("rg");
    void'(rg.build());
  endfunction

  task main_phase(uvm_phase phase);
    // Setting volatile through 'configure' will affect compare
    if (!rg.VOL0.is_volatile()) 
      `uvm_error(get_type_name(), "VOL0 field is not volatile despite being configured as such")
    if (rg.VOL0.get_compare() == UVM_CHECK) 
      `uvm_error(get_type_name(), "VOL0 field is checked despite being configured as volatile")
    
    if (rg.VOL1.is_volatile()) 
      `uvm_error(get_type_name(), "VOL1 field is volatile despite not being configured as such")
    if (rg.VOL1.get_compare() == UVM_NO_CHECK) 
      `uvm_error(get_type_name(), "VOL1 field is not checked despite not being configured as volatile")


    // Setting compare will not affect volatile
    rg.VOL0.set_compare(UVM_CHECK);
    if (!rg.VOL0.is_volatile()) 
      `uvm_error(get_type_name(), "volatile member affected by setting compare")
    if (rg.VOL0.get_compare() == UVM_NO_CHECK) 
      `uvm_error(get_type_name(), "set_compare does not work correctly")
    rg.VOL0.set_compare(UVM_NO_CHECK);
    
    rg.VOL1.set_compare(UVM_NO_CHECK);
    if (rg.VOL1.is_volatile()) 
      `uvm_error(get_type_name(), "volatile member affected by setting compare")
    if (rg.VOL1.get_compare() == UVM_CHECK) 
      `uvm_error(get_type_name(), "set_compare does not work correctly")
    rg.VOL1.set_compare(UVM_CHECK);

  
    // Setting volatile through 'set_volatility' will NOT affect compare
    rg.VOL0.set_volatility(0);
    if (rg.VOL0.get_compare() == UVM_CHECK) 
      `uvm_error(get_type_name(), "compare member affected by setting volatile")
    if (rg.VOL0.is_volatile()) 
      `uvm_error(get_type_name(), "set_volatile does not work properly")

    rg.VOL1.set_volatility(1);
    if (rg.VOL1.get_compare() == UVM_NO_CHECK) 
      `uvm_error(get_type_name(), "compare member affected by setting volatile")
    if (!rg.VOL1.is_volatile()) 
      `uvm_error(get_type_name(), "set_volatile does not work properly")
  endtask
  
  function void report_phase(uvm_phase phase);
    uvm_coreservice_t cs_;
    uvm_report_server svr;
    cs_ = uvm_coreservice_t::get();
    svr = cs_.get_report_server();

    if (svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) == 0)
      $write("** UVM TEST PASSED **\n");
    else
      $write("!! UVM TEST FAILED !!\n");
  endfunction
endclass


  initial begin
    run_test();
  end

endprogram
