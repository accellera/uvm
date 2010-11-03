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

//
// TITLE: Bit Bashing Test Sequences
//

//
// class: uvm_reg_single_bit_bash_seq
//
// Verify the implementation of a register
// by attempting to write 1's and 0's to every bit in it,
// via every address map in which the register is mapped,
// making sure that the resulting value matches the mirrored value.
//
// Registers that contain fields with unknown access policies
// cannot be tested.
//
// The DUT should be idle and not modify any register durign this test.
//

class uvm_reg_single_bit_bash_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

   // Variable: rg
   // The register to be tested
   uvm_reg rg;

   `uvm_object_utils(uvm_reg_single_bit_bash_seq)

   function new(string name="uvm_reg_single_bit_bash_seq");
     super.new(name);
   endfunction

   virtual task body();
      uvm_reg_field fields[$];
      string mode[`UVM_REG_DATA_WIDTH];
      uvm_reg_map maps[$];
      uvm_reg_data_t  wo_mask;
      uvm_reg_data_t  reset_val;
      int n_bits;
         
      if (rg == null) begin
         `uvm_error("RegModel", "No register specified to run sequence on");
         return;
      end

      n_bits = rg.get_n_bytes() * 8;
         
      // Let's see what kind of bits we have...
      rg.get_fields(fields);
         
      // Registers may be accessible from multiple physical interfaces (maps)
      rg.get_maps(maps);
         
      // Bash the bits in the register via each map
      foreach (maps[j]) begin
         uvm_status_e status;
         uvm_reg_data_t  val, exp, v, other;
         int next_lsb;
         
         next_lsb = 0;
         wo_mask = '1;
         other = 0;
         foreach (fields[k]) begin
            int lsb, w, o;
            
            lsb = fields[k].get_lsb_pos();
            w   = fields[k].get_n_bits();
            o   = ~fields[k].is_known_access(maps[j]);
            if (fields[k].get_access(maps[j]) == "DC") o = 1;
            // Any unused bits on the right side of the LSB?
            while (next_lsb < lsb) begin
               other[next_lsb] = 0;
               mode[next_lsb++] = "RO";
            end
            
            repeat (w) begin
               other[next_lsb] = o;
               mode[next_lsb] = fields[k].get_access(maps[j]);
               if (mode[next_lsb] == "WO") wo_mask[next_lsb] = 1'b0;
               next_lsb++;
            end
         end
         // Any unused bits on the left side of the MSB?
         while (next_lsb < `UVM_REG_DATA_WIDTH) begin
            other[next_lsb] = 0;
            mode[next_lsb++] = "RO";
         end
         
         if (uvm_report_enabled(UVM_NONE,UVM_INFO,"RegModel"))
	 	`uvm_info("RegModel", $psprintf("Verifying bits in register %s in map \"%s\"...",
                                    rg.get_full_name(), maps[j].get_full_name()),UVM_LOW);
         
         /*
         // TODO: this test should not rely on nor check the reset values; that is role of the reset test sequence

         // The mirror still contains initial value
         reset_val = rg.get();
         
         // But the mirrored value of any WO bits will read back
         // as all zeroes via the frontdoor...
         reset_val &= wo_mask;
         
         rg.read(status, val, UVM_BFM, maps[j], this);
         if (status != UVM_IS_OK) begin
            `uvm_error("RegModel", $psprintf("Status was %s when reading register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), maps[j].get_full_name()));
         end
         
         if (val !== reset_val) begin
            `uvm_error("RegModel", $psprintf("Initial value of register \"%s\" ('h%h) not %s ('h%h)",
                                        rg.get_full_name(), val,
                                        (j == 0) ? "reset value" : "as expected",
                                        reset_val));
         end
         */
         
         // Bash the kth bit
         for (int k = 0; k < n_bits; k++) begin
            // Cannot test unpredictable bit behavior
            if (other[k]) continue;
            
            bash_kth_bit(rg, k, mode[k], maps[j], wo_mask);
         end
            
            /*
         // Write the complement of the reset value
         // Except in unknown field accesses
         val = reset_val ^ ~other;
            
         rg.write(status, val, UVM_BFM, maps[j], this);
         if (status != UVM_IS_OK) begin
            `uvm_error("RegModel", $psprintf("Status was %s when writing to register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), maps[j].get_full_name()));
         end
         
         exp = rg.get() & wo_mask;
         rg.read(status, v, UVM_BFM, maps[j], this);
         if (status != UVM_IS_OK) begin
            `uvm_error("RegModel", $psprintf("Status was %s when reading register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), maps[j].get_full_name()));
         end
         
         if (v !== exp) begin
            `uvm_error("RegModel", $psprintf("Writing 'h%h to register \"%s\" with initial value 'h%h yielded 'h%h instead of 'h%h",
                                        val, rg.get_full_name(), reset_val, v, exp));
         end
         */
      end
   endtask: body


   task bash_kth_bit(uvm_reg     rg,
                     int             k,
                     string          mode,
                     uvm_reg_map  map,
                     uvm_reg_data_t  wo_mask);
      uvm_status_e status;
      uvm_reg_data_t  val, exp, v;
      bit bit_val;

      `uvm_info("RegModel", $psprintf("...Bashing %s bit #%0d", mode, k),UVM_MEDIUM);
      
      repeat (2) begin
         val = rg.get();
         v   = val;
         exp = val;
         val[k] = ~val[k];
         bit_val = val[k];
         
         rg.write(status, val, UVM_BFM, map, this);
         if (status != UVM_IS_OK) begin
            `uvm_error("RegModel", $psprintf("Status was %s when writing to register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), map.get_full_name()));
         end
         
         exp = rg.get() & wo_mask;
         rg.read(status, val, UVM_BFM, map, this);
         if (status != UVM_IS_OK) begin
            `uvm_error("RegModel", $psprintf("Status was %s when reading register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), map.get_full_name()));
         end
         
         if (val !== exp) begin
            `uvm_error("RegModel", $psprintf("Writing a %b in bit #%0d of register \"%s\" with initial value 'h%h yielded 'h%h instead of 'h%h",
                                        bit_val, k, rg.get_full_name(), v, val, exp));
         end
      end
   endtask: bash_kth_bit

endclass: uvm_reg_single_bit_bash_seq


//
// class: uvm_reg_bit_bash_seq
//
// Verify the implementation of all registers in a block
// by executing the <uvm_reg_single_bit_bash_seq> sequence on it.
//
// Blocks and registers with the NO_REG_TESTS or
// the NO_BIT_BASH_TEST attribute are not verified.
//

class uvm_reg_bit_bash_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

   `uvm_object_utils(uvm_reg_bit_bash_seq)

   function new(string name="uvm_reg_bit_bash_seq");
     super.new(name);
   endfunction

   // variable: model
   // The block to be tested
   
   virtual task body();

      if (model == null) begin
         `uvm_error("RegModel", "Not block or system specified to run sequence on");
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);

      if (model.get_attribute("NO_REG_TESTS") == "") begin
        if (model.get_attribute("NO_BIT_BASH_TEST") == "") begin
           uvm_reg regs[$];
           uvm_reg_single_bit_bash_seq sub_seq;

           sub_seq = uvm_reg_single_bit_bash_seq::type_id::create("reg_bit_bash_seq");
           this.reset_blk(model);
           model.reset();

           // Iterate over all registers, checking accesses
           model.get_registers(regs);
           foreach (regs[i]) begin
              // Registers with some attributes are not to be tested
              if (regs[i].get_attribute("NO_REG_TESTS") != "" ||
	          regs[i].get_attribute("NO_BIT_BASH_TEST") != "") continue;

              sub_seq.rg = regs[i];
              sub_seq.start(null,this);
           end
        end
      end

   endtask: body


   //
   // task: reset_blk
   // Reset the DUT that corresponds to the specified block abstraction class.
   //
   // Currently empty.
   // Will rollback the environment's phase to the ~reset~
   // phase once the new phasing is available.
   //
   // In the meantime, the DUT should be reset before executing this
   // test sequence or this method should be implemented
   // in an extension to reset the DUT.
   //
   virtual task reset_blk(uvm_reg_block blk);
   endtask

endclass: uvm_reg_bit_bash_seq

