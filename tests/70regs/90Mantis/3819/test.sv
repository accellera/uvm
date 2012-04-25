// 
// -------------------------------------------------------------
//    Copyright 2004-2012 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corporation
//    Copyright 2010 Cadence Design Systems, Inc.
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

`include "apb.sv"
`include "tb_top.sv"

program test;

import uvm_pkg::*;
import apb_pkg::*;

`include "reg_model.sv"
`include "tb_env.sv"


class dut_reset_seq extends uvm_sequence;

   function new(string name = "dut_reset_seq");
      super.new(name);
   endfunction

   `uvm_object_utils(dut_reset_seq)
   
   virtual task body();
      tb_top.rst = 1;
      repeat (5) @(negedge tb_top.clk);
      tb_top.rst = 0;
   endtask
endclass


class test extends uvm_test;

   `uvm_component_utils(test)

   tb_env env;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = tb_env::type_id::create("env", this);
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      begin
         dut_reset_seq rst_seq;
         rst_seq = dut_reset_seq::type_id::create("rst_seq", this);
         rst_seq.start(null);
      end
      env.model.reset();

      begin
         uvm_status_e status;
         uvm_reg_data_t rdat;

         env.model.DATA.write(status, $random);
         env.model.DATA.read(status, rdat);
      end

      phase.drop_objection(this);
   endtask : run_phase

   function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass



initial
begin
   uvm_config_db#(apb_vif)::set(null, "*.env.apb", "vif", $root.tb_top.apb0);
   run_test("test");
end

endprogram
