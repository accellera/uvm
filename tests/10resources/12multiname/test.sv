//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Mentor Graphics Corporation
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

  typedef uvm_config_db#(int) my_config_type;

  class test extends uvm_component;
    uvm_resource_pool p = uvm_resource_pool::get();

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    `uvm_component_utils(test)
    task run;

      int unsigned bar=0;
      uvm_resource_base rb;

      uvm_resource_types::rsrc_q_t rq;
      uvm_resource_base r;
      uvm_resource_pool rp = uvm_resource_pool::get();

      my_config_type::set(this,"foo","bar",10);
      rq = rp.lookup_regex_names({get_full_name(),".foo"}, "bar");

      r = uvm_resource#(int unsigned)::get_highest_precedence(rq);
      rb = p.get_by_name("foo","bar", uvm_resource#(int unsigned)::get_type());

      //void'(uvm_config_db#(int unsigned)::get(this,"foo","bar",bar));
      if(rb != null)
        $display("**** UVM TEST FAILED ****");
      else
        $display("**** UVM TEST PASSED ****");
    endtask

  endclass

  initial run_test();
endmodule
