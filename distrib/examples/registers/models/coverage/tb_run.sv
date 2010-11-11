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

`include "uvm_pkg.sv"

program tb;

import uvm_pkg::*;

`include "regmodel.sv"
`include "tb_env.sv"


class tb_test extends uvm_test;

   function new(string name = "tb_test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run();
      tb_env env;
      uvm_status_e   status;
      uvm_reg_data_t data;

      if (!$cast(env, uvm_top.find("env")) || env == null) begin
         `uvm_fatal("test", "Cannot find tb_env");
      end

      env.regmodel.reset();
      void'(env.regmodel.set_cover(UVM_CVR_ALL));

      begin
         uvm_reg_sequence seq;

         seq = uvm_reg_bit_bash_seq::type_id::create("seq");
         seq.model = env.regmodel;
         seq.start(env.bus.sqr);
         seq.wait_for_sequence_state(FINISHED);

         seq = uvm_mem_walk_seq::type_id::create("seq");
         seq.model = env.regmodel;
         seq.start(env.bus.sqr);
         seq.wait_for_sequence_state(FINISHED);

      end

      `uvm_info("Test", "Generating and uploading 100 configurations...", UVM_LOW)
      env.regmodel.Ra.F1.value.rand_mode(1);
      env.regmodel.Ra.F2.value.rand_mode(1);
      env.regmodel.Rb.F1.value.rand_mode(1);
      env.regmodel.Rb.F2.value.rand_mode(1);
      
      repeat (100) begin
         uvm_sequence_base seq = new;
         uvm_status_e status;

         void'(env.regmodel.randomize() with {
                                              Ra.F2.value == Rb.F2.value;
                                              });
         env.regmodel.update(status, .parent(seq));
         env.regmodel.sample_values();
      end
     
      global_stop_request();
   endtask
endclass


initial begin
   tb_env env;
   tb_test test;
   uvm_report_server svr;
   
   env = new("env");
   test = new("test");

   svr = _global_reporter.get_report_server();
   svr.set_max_quit_count(10);
   
   run_test();
end

endprogram
