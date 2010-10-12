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
// TITLE: Bit Bashing Test Sequence
//


class uvm_ral_reg_bit_bash_seq extends uvm_ral_sequence;

   uvm_ral_reg rg;

   `uvm_object_utils(uvm_ral_reg_bit_bash_seq)

   function new(string name="ral_reg_bit_bash_seq");
     super.new(name);
   endfunction

   virtual task body();
      uvm_ral_field fields[$];
      string mode[`UVM_RAL_DATA_WIDTH];
      uvm_ral_map maps[$];
      uvm_ral_data_t  wo_mask;
      uvm_ral_data_t  reset_val;
      int n_bits;
         
      if (rg == null) begin
         `uvm_error("RAL", "No register specified to run sequence on");
         return;
      end

      n_bits = rg.get_n_bytes() * 8;
         
      // Let's see what kind of bits we have...
      rg.get_fields(fields);
         
      // Registers may be accessible from multiple physical interfaces (maps)
      rg.get_maps(maps);
         
      // Bash the bits in the register via each map
      foreach (maps[j]) begin
         uvm_ral::status_e status;
         uvm_ral_data_t  val, exp, v, other;
         int next_lsb;
         
         next_lsb = 0;
         wo_mask = '1;
         other = 0;
         foreach (fields[k]) begin
            int lsb, w, o;
            
            lsb = fields[k].get_lsb_pos_in_register();
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
         while (next_lsb < `UVM_RAL_DATA_WIDTH) begin
            other[next_lsb] = 0;
            mode[next_lsb++] = "RO";
         end
         
         if (uvm_report_enabled(UVM_NONE,UVM_INFO,"RAL"))
	 	`uvm_info("RAL", $psprintf("Verifying bits in register %s in map \"%s\"...",
                                    rg.get_full_name(), maps[j].get_full_name()),UVM_LOW);
         
         /*
         // TODO: this test should not rely on nor check the reset values; that is role of the reset test sequence

         // The mirror still contains initial value
         reset_val = rg.get();
         
         // But the mirrored value of any WO bits will read back
         // as all zeroes via the frontdoor...
         reset_val &= wo_mask;
         
         rg.read(status, val, uvm_ral::BFM, maps[j], this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when reading register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), maps[j].get_full_name()));
         end
         
         if (val !== reset_val) begin
            `uvm_error("RAL", $psprintf("Initial value of register \"%s\" ('h%h) not %s ('h%h)",
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
            
         rg.write(status, val, uvm_ral::BFM, maps[j], this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when writing to register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), maps[j].get_full_name()));
         end
         
         exp = rg.get() & wo_mask;
         rg.read(status, v, uvm_ral::BFM, maps[j], this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when reading register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), maps[j].get_full_name()));
         end
         
         if (v !== exp) begin
            `uvm_error("RAL", $psprintf("Writing 'h%h to register \"%s\" with initial value 'h%h yielded 'h%h instead of 'h%h",
                                        val, rg.get_full_name(), reset_val, v, exp));
         end
         */
      end
   endtask: body


   task bash_kth_bit(uvm_ral_reg     rg,
                     int             k,
                     string          mode,
                     uvm_ral_map  map,
                     uvm_ral_data_t  wo_mask);
      uvm_ral::status_e status;
      uvm_ral_data_t  val, exp, v;
      bit bit_val;

      `uvm_info("RAL", $psprintf("...Bashing %s bit #%0d", mode, k),UVM_MEDIUM);
      
      repeat (2) begin
         val = rg.get();
         v   = val;
         exp = val;
         val[k] = ~val[k];
         bit_val = val[k];
         
         rg.write(status, val, uvm_ral::BFM, map, this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when writing to register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), map.get_full_name()));
         end
         
         exp = rg.get() & wo_mask;
         rg.read(status, val, uvm_ral::BFM, map, this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when reading register \"%s\" through map \"%s\".",
                                        status, rg.get_full_name(), map.get_full_name()));
         end
         
         if (val !== exp) begin
            `uvm_error("RAL", $psprintf("Writing a %b in bit #%0d of register \"%s\" with initial value 'h%h yielded 'h%h instead of 'h%h",
                                        bit_val, k, rg.get_full_name(), v, val, exp));
         end
      end
   endtask: bash_kth_bit

endclass: uvm_ral_reg_bit_bash_seq


class uvm_ral_bit_bash_seq extends uvm_ral_sequence;

   `uvm_object_utils(uvm_ral_bit_bash_seq)

   function new(string name="ral_bit_bash_seq");
     super.new(name);
   endfunction

   virtual task body();

      if (ral == null) begin
         `uvm_error("RAL", "Not block or system specified to run sequence on");
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);

      if (ral.get_attribute("NO_RAL_TESTS") == "") begin
        if (ral.get_attribute("NO_BIT_BASH_TEST") == "") begin
           uvm_ral_reg regs[$];
           uvm_ral_reg_bit_bash_seq sub_seq;

           sub_seq = uvm_ral_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq");
           this.reset_blk(ral);
           ral.reset();

           // Iterate over all registers, checking accesses
           ral.get_registers(regs);
           foreach (regs[i]) begin
              // Registers with some attributes are not to be tested
              if (regs[i].get_attribute("NO_RAL_TESTS") != "" ||
	          regs[i].get_attribute("NO_BIT_BASH_TEST") != "") continue;

              sub_seq.rg = regs[i];
              sub_seq.start(null,this);
           end
        end
      end

   endtask: body


   // Any additional steps required to reset the block
   // and make it accessibl
   virtual task reset_blk(uvm_ral_block blk);
   endtask

endclass: uvm_ral_bit_bash_seq

