// -------------------------------------------------------------
//    Copyright 2012 Accellera Systems Initiative
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------

`include "uvm_macros.svh"

module test;

import uvm_pkg::*;

class my_comp extends uvm_component;
  int A;
  int B;

  `uvm_component_utils_begin(my_comp)
    `uvm_field_int(A, UVM_DEFAULT) 
    `uvm_field_int(B, UVM_DEFAULT) 
  `uvm_component_utils_end

    function new(string name, uvm_component parent = null);
      super.new(name, parent);
    endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass

class message_logger extends uvm_report_catcher;
  int total_seen = 0;
  int unsupported_seen = 0;

   virtual function action_e catch();
      if (get_severity() == UVM_INFO && get_id() == "CFGAPL") begin
        total_seen++;
        if (get_message() == "field B has an unsupported type") begin
          unsupported_seen++;
        end
        if (get_message() == "field C has an unsupported type") begin
          unsupported_seen++; // Safeguard: Not expecting this
        end
      end
     return THROW;
   endfunction
endclass

  
class test extends uvm_test;  
  my_comp comp;

  message_logger logger;
  
  `uvm_component_utils_begin(test) 
    `uvm_field_object(comp, UVM_DEFAULT)
  `uvm_component_utils_end    
    
    function new(string name, uvm_component parent = null);
      super.new(name, parent);
      logger = new;
      uvm_report_cb::add(null,logger);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    comp = my_comp::type_id::create("comp", this);
    uvm_config_db#(uvm_bitstream_t)::set(this, "*", "A", 'hAA); // Should be OK
    uvm_config_db#(logic [3:0])::set(this, "*", "B", 'hBB); // Should report message
    uvm_config_db#(logic [3:0])::set(this, "*", "C", 'hCC); // Should not report message
  endfunction
  
  function void report_phase(uvm_phase phase);
    uvm_coreservice_t cs_;
    uvm_report_server svr;
    cs_ = uvm_coreservice_t::get();
    svr = cs_.get_report_server();

    if ((svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) == 0) && 
        logger.total_seen == 5 && 
        logger.unsupported_seen == 1)
      $write("** UVM TEST PASSED **\n");
    else
      $write("!! UVM TEST FAILED !!\n");
  endfunction
endclass

initial begin
  uvm_component::print_config_matches = 1;
  run_test("test");
end

endmodule
