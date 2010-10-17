//---------------------------------------------------------------------- 
//   Copyright 2010 Cadence Design Systems, Inc. 
//   Copyright 2010 Synopsys, Inc. 
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


//
// If this test fails, try toggling the definition of `UVM_USE_ALT_PHASING
//

`include "uvm_macros.svh"

`include "vendor_a_base_pkg.sv"
`include "vendor_a_ip1_pkg.sv"
`include "vendor_a_ip2_pkg.sv"
`include "vendor_b_base_pkg.sv"
`include "vendor_b_ip_pkg.sv"

module top;
  import va_base_pkg::*;
  import vb_base_pkg::*;
  import va_ip1_pkg::*;
  import va_ip2_pkg::*;
  import vb_ip_pkg::*;
  import uvm_pkg::*;

  //Make test participate in the phases from Vendor A and B
  typedef class test;

  va_pre_start_phase#(test) test_pre_start_ph;
  va_init_phase#(test)      test_init_ph;
  va_reset_phase#(test)     test_vareset_ph;

  vb_reset_phase#(test)     test_vbreset_ph;
  vb_shutdown_phase#(test)  test_shutdown_ph;
  vb_post_shutdown_phase#(test) test_post_shutdown_ph;

  class test extends uvm_test;
    va_ip1_env env1;
    va_ip2_env env2;
    vb_ip_env env3;

    int del = 200;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);

      if(test_pre_start_ph == null) begin
        test_pre_start_ph = new;
        test_init_ph = new;
        test_vareset_ph = new;
        uvm_top.insert_phase(test_pre_start_ph, end_of_elaboration_ph);
        uvm_top.insert_phase(test_init_ph, start_of_simulation_ph);
        uvm_top.insert_phase(test_vareset_ph, test_init_ph);

        test_vbreset_ph = new;
        test_shutdown_ph = new;
        test_post_shutdown_ph = new;
        uvm_top.insert_phase(test_vbreset_ph, start_of_simulation_ph);
        uvm_top.insert_phase(test_shutdown_ph, report_ph);
        uvm_top.insert_phase(test_post_shutdown_ph, test_shutdown_ph);
      end

      env1 = new("env1", this);
      env2 = new("env2", this);
      env3 = new("env3", this);

    endfunction

    virtual task stop(string ph_name);
      wait(enable_stop_interrupt==0);
    endtask

    virtual task va_pre_start();
      enable_stop_interrupt=1;
      uvm_report_info("va_pre_start", "Executing pre_start phase");
      uvm_report_info("va_pre_start_start", "Starting pre start phase", UVM_LOW);
      #del;
      uvm_report_info("va_pre_start_end", "Ending pre start phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    virtual task va_init();
      enable_stop_interrupt=1;
      uvm_report_info("va_init", "Executing init phase");
      uvm_report_info("va_init_start", "Starting init phase", UVM_LOW);
      #(1000-del);
      uvm_report_info("va_init_end", "Ending init phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    virtual task va_reset();
      enable_stop_interrupt=1;
      uvm_report_info("va_reset", "Executing reset (VA) phase");
      uvm_report_info("va_reset_start", "Starting reset phase", UVM_LOW);
      #del;
      uvm_report_info("va_reset_end", "Ending reset phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    virtual task vb_reset();
      enable_stop_interrupt=1;
      uvm_report_info("vb_reset", "Executing reset (VB) phase");
      uvm_report_info("vb_reset_start", "Starting reset phase", UVM_LOW);
      #del;
      uvm_report_info("vb_reset_end", "Ending reset phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    virtual task run();
      enable_stop_interrupt=1;
      super.run();
      uvm_report_info("run_start", "Starting run phase", UVM_LOW);
      #(1000-del);
      uvm_report_info("run_end", "Ending run phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    virtual task vb_shutdown();
      enable_stop_interrupt=1;
      uvm_report_info("vb_shutdown", "Executing shutdown phase");
      uvm_report_info("vb_shutdown_start", "Starting shutdown phase", UVM_LOW);
      #del;
      uvm_report_info("vb_shutdown_end", "Ending shutdown phase", UVM_LOW);
      enable_stop_interrupt=0;
    endtask

    virtual function void vb_post_shutdown();
      uvm_report_info("vb_post_shutdown", "Executing post shutdown phase");
    endfunction

    virtual function void report();
      $write("** UVM TEST PASSED **\n");
    endfunction

  endclass

  initial run_test();
endmodule
