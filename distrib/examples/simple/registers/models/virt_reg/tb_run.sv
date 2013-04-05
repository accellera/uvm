// 
// -------------------------------------------------------------
//    Copyright 2004-2011 Synopsys, Inc.
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

`include "uvm_pkg.sv"
`include "apb.sv"
`include "dut.sv"

module dut_top;
   bit clk = 0;
   bit rst = 0;

   apb_if apb0(clk);
   dut dut0(apb0, rst);

   always #10 clk = ~clk;
endmodule: dut_top


module tb_top;

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
      dut_top.rst = 1;
      repeat (5) @(negedge dut_top.clk);
      dut_top.rst = 0;
   endtask
endclass


class base_test extends uvm_test;

   tb_env env;

   `uvm_component_utils(base_test)

   function new(string name = "my_test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      env = tb_env::type_id::create("env", this);
   endfunction

   virtual task reset_phase(uvm_phase phase);
      phase.raise_objection(this);

      `uvm_info("Test", "Resetting DUT and Register Model...", UVM_LOW)
      begin
         dut_reset_seq rst_seq;
         rst_seq = dut_reset_seq::type_id::create("rst_seq", this);
         rst_seq.start(null);
      end
      env.regmodel.reset();

      phase.drop_objection(this);
   endtask
   
   virtual task main_phase(uvm_phase phase);
      uvm_reg_data_t rdat;
      uvm_status_e status;
      bit [3:0] i;
      int j;
      
      phase.raise_objection(this);

      `uvm_info("Test", "Writing virtual registers...", UVM_LOW)
      repeat (16) begin
         env.regmodel.R.F1.write(i, status, {4'hA, i});
         if (status != UVM_IS_OK) begin
            `uvm_error("TEST", "Writing virtual register did not return IS_OK")
         end
         i++;
      end

      // Make sure the last write has taken effect
      #100;
      
      `uvm_info("Test", "Dumping RAM via backdoor...", UVM_LOW)
      for (j = 0; j < 16*4; j++) begin
         env.regmodel.RAM.read(status, j, rdat, UVM_BACKDOOR);
         if (status != UVM_IS_OK) begin
            `uvm_error("TEST", "Reading RAM via backdoor not return IS_OK")
         end
         $write("RAM[%0d]= 'h%h\n", j, rdat[7:0]);

         if (j % 4 == 0) begin
            bit [7:0] exp;

            exp[3:0] = j / 4;
            exp[7:4] = 'hA;

            if (rdat[7:0] != exp) begin
               `uvm_error("TEST", $sformatf("RAM[%0d] is 'h%h instead of 'h%h",
                                            j, rdat[7:0], exp))
            end
         end
      end
      
      phase.drop_objection(this);
   endtask
endclass


initial begin
   uvm_report_server svr;

   svr = _global_reporter.get_report_server();
   svr.set_max_quit_count(10);
   
   uvm_config_db#(apb_vif)::set(null, "uvm_test_top.env.apb", "vif", $root.dut_top.apb0);

   run_test();
end

endmodule
