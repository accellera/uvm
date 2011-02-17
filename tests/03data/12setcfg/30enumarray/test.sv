//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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
//------------------------------------------------------------------------------

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum { ZERO, ONE, TWO, THREE, FOUR } numbers;

  class test extends uvm_component;
    numbers sa_num[5];
    numbers da_num[];
    numbers q_num[$];

    `uvm_component_utils_begin(test)
      `uvm_field_sarray_enum(numbers, sa_num, UVM_DEFAULT)
      `uvm_field_array_enum(numbers, da_num, UVM_DEFAULT)
      `uvm_field_queue_enum(numbers, q_num, UVM_DEFAULT)
    `uvm_component_utils_end
    function new(string name, uvm_component parent);
      super.new(name,parent);
      recording_detail = UVM_LOW;
    endfunction

    function void report();
      bit failed=0;
      if(da_num.size() != 3) begin
        uvm_report_error("FAILURE", "**** UVM TEST FAILED da size != 3 ****", UVM_INFO);
        failed = 1;
      end
      if(sa_num[0] != ONE) begin
        uvm_report_error("FAILURE", $sformatf("**** UVM TEST FAILED sa_num[0] = %0s, expected ONE ****", sa_num[0].name()), UVM_INFO);
        failed = 1;
      end
      if(da_num[0] != TWO) begin
        uvm_report_error("FAILURE", $sformatf("**** UVM TEST FAILED da_num[0] = %0s, expected TWO ****", da_num[0].name()), UVM_INFO);
        failed = 1;
      end
      if(q_num[0] != THREE) begin
        uvm_report_error("FAILURE", $sformatf("**** UVM TEST FAILED q_num[0] = %0s, expected THREE ****", q_num[0].name()), UVM_INFO);
        failed = 1;
      end
      if(!failed)
        uvm_report_info("SUCCESS", "**** UVM TEST PASSED ****", UVM_INFO);
    endfunction
  endclass

  initial begin
    set_config_int("uvm_test_top", "sa_num[0]", ONE);
    set_config_int("uvm_test_top", "da_num", 3);
    set_config_int("uvm_test_top", "da_num[0]", TWO);
    set_config_int("uvm_test_top", "q_num", 1);
    set_config_int("uvm_test_top", "q_num[0]", THREE);
    run_test();
  end
endmodule
