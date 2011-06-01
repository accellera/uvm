// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//    Copyright 2010-2011 Mentor Graphics Corporation
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
//    permissions and limitations under t,he License.
// -------------------------------------------------------------
// 

`include "uvm_pkg.sv"

program tb;

import uvm_pkg::*;

`include "regmodel.sv"
`include "tb_env.sv"


class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   virtual function action_e catch();
      if (get_severity() == UVM_ERROR &&
          (get_id() == "UVM/REG/READONLY" ||
           get_id() == "UVM/REG/WRTEONLY")) begin
          seen++;
          set_severity(UVM_INFO);
      end
      return THROW;
   endfunction
endclass



class test extends uvm_test;

   `uvm_component_utils(test)

   function new(string name = "test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
      tb_env env;
      uvm_status_e   status;
      uvm_reg_data_t data;
      uvm_reg_data_t val;
      uvm_reg_data_t exp;

      if (!$cast(env, uvm_top.find("env")) || env == null) begin
         `uvm_fatal("test", "Cannot find tb_env");
      end

      phase.raise_objection(this);

      env.regmodel.reset();

      begin
         uvm_sequence_base seq = new;
            

         `uvm_info("Test", "Testing RO/WO sharing...", UVM_NONE)

         `uvm_info("test", "Testing normal operations...", UVM_LOW)
         env.regmodel.R.mirror(status, UVM_CHECK, .parent(seq));
         env.regmodel.R.peek(status, data, .parent(seq));
         val = env.regmodel.R.get();
         if (data !== val) begin
            `uvm_error("Test", $sformatf("%s (via BD) is 'h%h !== mirror 'h%h",
                                         env.regmodel.R.get_full_name(),
                                         data, val));
         end
         exp = val;
         // Read againt to check that the clear-on-read field was cleared
         env.regmodel.R.mirror(status, UVM_CHECK, .parent(seq));
         
         env.regmodel.W.write(status, 32'hDEADBEEF, .parent(seq));
         env.regmodel.W.peek(status, data, .parent(seq));
         val = env.regmodel.W.get();
         if (data !== val) begin
            `uvm_error("Test", $sformatf("%s (via BD) is 'h%h !== mirror 'h%h",
                                         env.regmodel.W.get_full_name(),
                                         data, val));
         end
         // Make sure writing W did not affect R
         env.regmodel.R.peek(status, data, .parent(seq));
         if (data !== exp) begin
            `uvm_error("Test", $sformatf("Accessing W affected R: 'h%h !== 'h%h",
                                         data, exp));
         end
         
         `uvm_info("Test", "Making sure you can't read the WO nor write the RO...", UVM_LOW)
         begin
            my_catcher c = new;
            uvm_report_cb::add(null, c);
         end
         
         env.regmodel.R.write(status, 0, .parent(seq));
         if (status != UVM_NOT_OK)
            `uvm_error("Test", "Writing to RO via frontdoor was succesful...");

         env.regmodel.R.write(status, 0, .path(UVM_BACKDOOR), .parent(seq));
         if (status != UVM_NOT_OK)
            `uvm_error("Test", "Writing to RO via backdoor was succesful...");

         env.regmodel.W.read(status, data, .parent(seq));
         if (status != UVM_NOT_OK)
            `uvm_error("Test", "Reading from WO via frontdoor was succesful...");

         env.regmodel.W.read(status, data, .path(UVM_BACKDOOR), .parent(seq));
         if (status != UVM_NOT_OK)
            `uvm_error("Test", "Reading from WO via backdoor was succesful...");

         if (my_catcher::seen != 4) begin
            `uvm_error("Test", "read() and write() calls to WO and RO registers were not reported as errors");
         end

         // Make sure W and R were not affected
         env.regmodel.W.peek(status, data, .parent(seq));
         if (data !== val) begin
            `uvm_error("Test", $sformatf("W was affected 'h%h !== 'h%h",
                                         data, val));
         end
         
         env.regmodel.R.peek(status, data, .parent(seq));
         if (data !== exp) begin

            `uvm_error("Test", $sformatf("R was affected 'h%h !== 'h%h",
                                         data, exp));
         end
      end
      phase.drop_objection(this);
   endtask

   virtual function void report();
	uvm_report_server svr =  _global_reporter.get_report_server();
   if (svr.get_severity_count(UVM_FATAL) +
       svr.get_severity_count(UVM_ERROR) +
       svr.get_severity_count(UVM_WARNING) == 0)
      $write("** UVM TEST PASSED **\n");
   else
      $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass


initial begin
   tb_env env;
   uvm_report_server svr;
   
   env = new("env");

   svr = _global_reporter.get_report_server();
   svr.set_max_quit_count(10);
   
   run_test();

end

endprogram
