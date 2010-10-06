// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
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

import uvm_pkg::*;
import apb_pkg::*;

`include "ral_slave.sv"
`include "tb_env.sv"


class user_test_seq extends uvm_ral_sequence;

   ral_block_slave ral;

   function new(string name="user_test_seq");
      super.new(name);
   endfunction : new

   rand bit   [31:0] addr;
   rand logic [31:0] data;
   
   `uvm_object_utils(user_test_seq)
   
   virtual task body();
      // Randomize the content of 10 random indexed registers
      repeat (10) begin
         bit [7:0]         idx = $urandom;
         uvm_ral_data_t    data = $urandom;
         uvm_ral::status_e status;
         ral.TABLES[idx].write(status, data, .parent(this));
      end
   endtask : body
endclass : user_test_seq




class ral_user_test extends uvm_test;

   `uvm_component_utils(ral_user_test);

   tb_env env;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build();
      apb_config apb_cfg = new;
      apb_cfg.vif = $root.tb_top.apb0;
      env = tb_env::type_id::create("env",this);
      set_config_object("env.apb.*","config",apb_cfg,0);
   endfunction

   virtual task run();
      apb_reset_seq reset_seq;
      user_test_seq seq;

      reset_seq = apb_reset_seq::type_id::create("apb_reset_seq",this);
      reset_seq.start(env.apb.sqr);

      seq = user_test_seq::type_id::create("user_test_seq",this);
      seq.ral = env.ral;
      seq.start(null);

      // Find which indexed registers are non-zero
      foreach (env.ral.TABLES[i]) begin
         uvm_ral_data_t    data;
         uvm_ral::status_e status;

         env.ral.TABLES[i].read(status, data);
         if (data != 0) $write("TABLES[%0d] is 0x%h...\n", i, data);
      end
      
      global_stop_request();

   endtask : run

endclass : ral_user_test



