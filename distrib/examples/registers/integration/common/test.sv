// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
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

`include "regmodel.sv"
`include "tb_env.sv"

class hw_reset_test extends uvm_test;

   function new(string name = "hw_reset_test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   `uvm_component_utils(hw_reset_test)
   
   virtual task run();
      tb_top.rst = 1;
      repeat (5) @(negedge tb_top.clk);
      tb_top.rst = 0;

      #100;

      begin
         uvm_reg_hw_reset_seq seq;
         tb_env env;
         
         $cast(env, uvm_top.find("env"));

         seq = uvm_reg_hw_reset_seq::type_id::create("uvm_reg_hw_reset_seq",,
                                                     get_full_name());
         seq.model = env.regmodel;
         seq.start(null);
      end
      
      global_stop_request();
   endtask
endclass


initial
begin
   static tb_env env = new("env");

   uvm_config_db#(apb_vif)::set(env, "apb", "vif", $root.tb_top.apb0);

   run_test();
end

endprogram
