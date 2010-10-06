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

class blk_R_test_seq extends uvm_ral_sequence;

   `uvm_object_utils(blk_R_test_seq)

   function new(string name = "blk_R_test_seq");
      super.new(name);
   endfunction: new

   ral_block_B ral;

   virtual task body();
      uvm_ral::status_e status;
      uvm_ral_data_t    data;
      int n;

      // Initialize R with a random value then check against mirror
      data[7:0] = $urandom();
      ral.R.write(status, data, .parent(this));
      ral.R.mirror(status, uvm_ral::CHECK, .parent(this));

      // Perform a random number of INC operations
      n = ($urandom() % 7) + 3;
      `uvm_info("blk_R_test_seq", $psprintf("Incrementing R %0d times...", n), UVM_NONE);
      repeat (n) begin
         ral.CTL.write(status, ral_fld_B_CTL_CTL::INC, .parent(this));
         data++;
         void'(ral.R.predict(data));
      end
      // Check the final value
      ral.R.mirror(status, uvm_ral::CHECK, .parent(this));

      // Perform a random number of DEC operations
      n = ($urandom() % 8) + 2;
      `uvm_info("blk_R_test_seq", $psprintf("Decrementing R %0d times...", n), UVM_NONE);
      repeat (n) begin
         ral.CTL.write(status, ral_fld_B_CTL_CTL::DEC, .parent(this));
         data--;
         void'(ral.R.predict(data));
      end
      // Check the final value
      ral.R.mirror(status, uvm_ral::CHECK, .parent(this));

      // Reset the register and check
      ral.CTL.write(status, ral_fld_B_CTL_CTL::CLR, .parent(this));
      void'(ral.R.predict(0));
      ral.R.mirror(status, uvm_ral::CHECK, .parent(this));
   endtask
   
endclass
