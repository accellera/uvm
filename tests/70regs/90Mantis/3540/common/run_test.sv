// 
// -------------------------------------------------------------
//    Copyright 2004-2011 Synopsys, Inc.
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

`include "uvm_macros.svh"
`include "apb.sv"
`include "tb_top.sv"

program tb;

import uvm_pkg::*;
import apb_pkg::*;

`include "regmodel.sv"
`include "tb_env.sv"

class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   virtual function action_e catch();
      if (get_severity() == UVM_ERROR && get_id() == "RegModel") begin
         seen++;
         set_severity(UVM_INFO);
         set_action(UVM_DISPLAY);
      end
      return THROW;
   endfunction
endclass

class test extends uvm_test;

   `uvm_component_utils(test)

   tb_env env;
   my_catcher catch;
   
   function new(string name, uvm_component parent=null);
      super.new(name,parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      env = tb_env::type_id::create("env", this);
      catch = new();
      uvm_report_cb::add(null, catch);
      catch.callback_mode(0);
   endfunction

   virtual task main_phase(uvm_phase phase);
      uvm_status_e status;
      uvm_reg_data_t rdat;
      
      phase.raise_objection(this);

      $write("Checking normal read()...should not issue a mismatch error...\n");
      env.regmodel.DATA.predict(32'hDEADBEEF);
      env.regmodel.DATA.read(status, rdat);
      void'(env.regmodel.DATA.randomize()); // Change 'desired value'
      if (env.regmodel.DATA.get_mirrored_value() != rdat) begin
         `uvm_error("Test", $sformatf("Mirror was not updated with readback value by read(): 'h%h instead of 'h%h",
                                      env.regmodel.DATA.get_mirrored_value(), rdat))
      end

      $write("Checking mirror()...should issue a mismatch error...\n");
      env.regmodel.DATA.predict(32'hDEADBEEF);
      catch.callback_mode(1);
      env.regmodel.DATA.mirror(status, UVM_CHECK);
      if (my_catcher::seen != 1) begin
         `uvm_error("Test", "The expected mismatch error message was not seen")
      end
      my_catcher::seen = 0;
      catch.callback_mode(0);
      if (env.regmodel.DATA.get() != rdat) begin
         `uvm_error("Test", $sformatf("Mirror was not updated with readback value by mirror(): 'h%h instead of 'h%h",
                                      env.regmodel.DATA.get(), rdat))
      end

      $write("Checking check-on-read() mode()...should issue a mismatch error...\n");
      env.regmodel.DATA.predict(32'hDEADBEEF);
      catch.callback_mode(1);
      env.regmodel.default_map.set_check_on_read(1);
      env.regmodel.DATA.read(status, rdat);
      env.regmodel.default_map.set_check_on_read(0);
      if (my_catcher::seen != 1) begin
         `uvm_error("Test", "The expected mismatch error message was not seen")
      end
      my_catcher::seen = 0;
      catch.callback_mode(0);
      if (env.regmodel.DATA.get() != rdat) begin
         `uvm_error("Test", $sformatf("Mirror was not updated with readback value by read(): 'h%h instead of 'h%h",
                                      env.regmodel.DATA.get(), rdat))
      end

      $write("Checking mirror(BACKDOOR)...should issue a mismatch error...\n");
      env.regmodel.DATA.predict(32'hDEADBEEF);
      catch.callback_mode(1);
      env.regmodel.DATA.mirror(status, UVM_CHECK, UVM_BACKDOOR);
      if (my_catcher::seen != 1) begin
         `uvm_error("Test", "The expected mismatch error message was not seen")
      end
      my_catcher::seen = 0;
      catch.callback_mode(0);
      if (env.regmodel.DATA.get() != rdat) begin
         `uvm_error("Test", $sformatf("Mirror was not updated with readback value by mirror(): 'h%h instead of 'h%h",
                                      env.regmodel.DATA.get(), rdat))
      end

      $write("Checking normal read(BACKDOOR)...should not issue a mismatch error...\n");
      env.regmodel.DATA.predict(32'hDEADBEEF);
      env.regmodel.DATA.read(status, rdat, UVM_BACKDOOR);
      if (env.regmodel.DATA.get() != rdat) begin
         `uvm_error("Test", $sformatf("Mirror was not updated with readback value by read(): 'h%h instead of 'h%h",
                                      env.regmodel.DATA.get(), rdat))
      end

      $write("Checking check-on-read(BACKDOOR) mode()...should issue a mismatch error...\n");
      env.regmodel.DATA.predict(32'hDEADBEEF);
      begin
         uvm_reg_map bkdr = uvm_reg_map::backdoor();
         catch.callback_mode(1);
         bkdr.set_check_on_read(1);
         env.regmodel.DATA.read(status, rdat, UVM_BACKDOOR);
         bkdr.set_check_on_read(0);
      end
      if (my_catcher::seen != 1) begin
         `uvm_error("Test", "The expected mismatch error message was not seen")
      end
      my_catcher::seen = 0;
      catch.callback_mode(0);
      if (env.regmodel.DATA.get() != rdat) begin
         `uvm_error("Test", $sformatf("Mirror was not updated with readback value by read(): 'h%h instead of 'h%h",
                                      env.regmodel.DATA.get(), rdat))
      end

      phase.drop_objection(this);
   endtask

   virtual function void final_phase(uvm_phase phase);
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
   run_test();
end

endprogram
