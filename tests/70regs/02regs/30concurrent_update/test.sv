// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corporation
//    Copyright 2010-2011 Cadence Design Systems, Inc.
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
// 

`include "dut.sv"
`include "uvm_macros.svh"

module top;

import uvm_pkg::*;

`include "regmodel.sv"
`include "tb_env.sv"


class test extends uvm_test;

   tb_env env;

   `uvm_component_utils(test)

   function new(string name = "tb_test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build();
     env = new("env",this);
   endfunction

   virtual task run_phase(uvm_phase phase);
      uvm_status_e  status1,status2,status3;
      uvm_reg_data_t exp,act;

      phase.raise_objection(this);

      env.regmodel.reset();

      exp = 1;
      env.regmodel.user_acp.set(10);

      fork
         env.regmodel.user_acp.update(status1);
         #0 env.regmodel.update(status2);
      join

      env.regmodel.user_acp.read(status3, act);

      if (status1 == UVM_NOT_OK)
        $display("update to user_acp returned status UVM_NOT_OK");
      if (status2 == UVM_NOT_OK)
        $display("update to reg model block returned status UVM_NOT_OK");
      if (status3 == UVM_NOT_OK)
        $display("read from user_acp returned status UVM_NOT_OK");

      $display("expected: %0h  actual: %0h",exp,act);
      
      if (act !== exp) begin
        $display("!! UVM TEST FAILED !!\n");
      end
      else begin
        $display("** UVM TEST PASSED **\n");
      end

      phase.drop_objection(this);
   endtask

endclass


initial begin
   uvm_report_server svr;

   svr = _global_reporter.get_report_server();
   svr.set_max_quit_count(10);
   
   run_test();
end

endmodule
