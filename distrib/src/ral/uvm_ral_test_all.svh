//
// -------------------------------------------------------------
//    Copyright 2010 Mentor Graphics Corp.
//    Copyright 2010 Synopsys, Inc.
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

typedef enum bit [63:0] {
  RAL_HW_RESET      = 64'h0000_0000_0000_0001,
  RAL_BIT_BASH      = 64'h0000_0000_0000_0002,
  RAL_REG_ACCESS    = 64'h0000_0000_0000_0004,
  RAL_MEM_ACCESS    = 64'h0000_0000_0000_0008,
  RAL_SHARED_ACCESS = 64'h0000_0000_0000_0010,
  RAL_MEM_WALK      = 64'h0000_0000_0000_0020,
  ALL_RAL_TESTS     = 64'hffff_ffff_ffff_ffff 
} uvm_ral_tests_e;


class uvm_ral_built_in_seq extends uvm_ral_sequence;

   `uvm_object_utils(uvm_ral_built_in_seq)

   function new(string name="ral_hw_reset_seq");
     super.new(name);
   endfunction

   uvm_ral_tests_e tests = ALL_RAL_TESTS;

   virtual task body();

      if (ral == null) begin
         `uvm_error("RAL", "Not block or system specified to run sequence on");
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);
      
      if (tests & RAL_HW_RESET &&
          ral.get_attribute("NO_RAL_TESTS") == "" &&
          ral.get_attribute("NO_HW_RESET_TEST") == "") begin
        uvm_ral_hw_reset_seq seq = uvm_ral_hw_reset_seq::type_id::create("ral_hw_reset_seq");
        seq.ral = ral;
        seq.start(null,this);
      end

      if (tests & RAL_BIT_BASH &&
          ral.get_attribute("NO_RAL_TESTS") == "" &&
          ral.get_attribute("NO_BIT_BASH_TEST") == "") begin
        uvm_ral_bit_bash_seq seq = uvm_ral_bit_bash_seq::type_id::create("ral_bit_bash_seq");
        seq.ral = ral;
        seq.start(null,this);
      end

      if (tests & RAL_REG_ACCESS &&
          ral.get_attribute("NO_RAL_TESTS") == "" &&
          ral.get_attribute("NO_REG_ACCESS_TEST") == "") begin
        uvm_ral_reg_access_seq seq = uvm_ral_reg_access_seq::type_id::create("ral_reg_access_seq");
        seq.ral = ral;
        seq.start(null,this);
      end

      if (tests & RAL_MEM_ACCESS &&
          ral.get_attribute("NO_RAL_TESTS") == "" &&
          ral.get_attribute("NO_MEM_ACCESS_TEST") == "") begin
        uvm_ral_mem_access_seq seq = uvm_ral_mem_access_seq::type_id::create("ral_mem_access_seq");
        seq.ral = ral;
        seq.start(null,this);
      end

      if (tests & RAL_SHARED_ACCESS &&
          ral.get_attribute("NO_RAL_TESTS") == "" &&
          ral.get_attribute("NO_SHARED_ACCESS_TEST") == "") begin
        uvm_ral_shared_access_seq seq = uvm_ral_shared_access_seq::type_id::create("ral_shared_access_seq");
        seq.ral = ral;
        seq.start(null,this);
      end

      if (tests & RAL_MEM_WALK &&
          ral.get_attribute("NO_RAL_TESTS") == "" &&
          ral.get_attribute("NO_MEM_WALK_TEST") == "") begin
        uvm_ral_mem_walk_seq seq = uvm_ral_mem_walk_seq::type_id::create("ral_mem_walk_seq");
        seq.ral = ral;
        seq.start(null,this);
      end

   endtask: body

endclass: uvm_ral_built_in_seq

