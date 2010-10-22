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

class hw_reset_test extends uvm_test;

   tb_env env;

   `uvm_component_utils(hw_reset_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual task run();
      apb_reset_seq reset_seq;
      uvm_reg_hw_reset_seq seq;

      $cast(env, uvm_top.find("env"));

      reset_seq = apb_reset_seq::type_id::create("apb_reset_seq",this);
      reset_seq.start(env.apb.sqr);

      seq = uvm_reg_hw_reset_seq::type_id::create("uvm_reg_hw_reset_seq",this);
      seq.model = env.model;
      seq.start(null);

      global_stop_request();

   endtask : run

endclass : hw_reset_test



