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


class uvm_ral_shared_reg_access_seq extends uvm_ral_sequence;

   uvm_ral_reg rg;

   `uvm_object_utils(uvm_ral_shared_reg_access_seq)

   function new(string name="ral_shared_reg_access_seq");
     super.new(name);
   endfunction


   virtual task body();
      uvm_ral_data_t  other_mask;
      uvm_ral_data_t  wo_mask[$];
      uvm_ral_field fields[$];
      uvm_ral_map maps[$];

      if (rg == null) begin
         `uvm_error("RAL", "No register specified to run sequence on");
         return;
      end

      // Only look at shared registers
      if (rg.get_n_maps() < 2) return;
      rg.get_maps(maps);

      // Let's see what kind of bits we have...
      rg.get_fields(fields);

      // Identify unpredictable bits and the ones we shouldn't change
      other_mask = 0;
      foreach (fields[k]) begin
         int lsb, w;
         
         lsb = fields[k].get_lsb_pos_in_register();
         w   = fields[k].get_n_bits();
         
         if (!fields[k].is_known_access(maps[0])) begin
            repeat (w) begin
               other_mask[lsb++] = 1'b1;
            end
         end
      end
      
      // WO bits will always readback as 0's but the mirror
      // with return what is supposed to have been written
      // so we cannot use the mirror-check function
      foreach (maps[j]) begin
         uvm_ral_data_t  wo;
         wo = 0;
         foreach (fields[k]) begin
            int lsb, w;
            
            lsb = fields[k].get_lsb_pos_in_register();
            w   = fields[k].get_n_bits();
            
            if (fields[k].get_access(maps[j]) == "WO") begin
               repeat (w) begin
                  wo[lsb++] = 1'b1;
               end
            end
         end
         wo_mask[j] = wo;
      end
      
      // Try to write through each map
      foreach (maps[j]) begin
         uvm_ral::status_e status;
         uvm_ral_data_t  prev, v;
         
         // The mirror should contain the initial value
         prev = rg.get();
         
         // Write a random value, except in those "don't touch" fields
         v = ({$random, $random} & ~other_mask) | (prev & other_mask);
         
         `uvm_info("RAL", $psprintf("Writing register %s via map \"%s\"...",
                                    rg.get_full_name(), maps[j].get_full_name), UVM_LOW);
         
         `uvm_info("RAL", $psprintf("Writing 'h%h over 'h%h", v, prev),UVM_DEBUG);
         
         rg.write(status, v, uvm_ral::BFM, maps[j], this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when writing register \"%s\" through map \"%s\".",
                                        status.name(), rg.get_full_name(), maps[j].get_full_name()));
         end
         
         foreach (maps[k]) begin
            uvm_ral_data_t  actual, exp;
            
            `uvm_info("RAL", $psprintf("Reading register %s via map \"%s\"...",
                                       rg.get_full_name(), maps[k].get_full_name()), UVM_LOW);
            
            // Was it what we expected?
            exp = rg.get() & ~wo_mask[k];
            
            rg.read(status, actual, uvm_ral::BFM, maps[k], this);
            if (status != uvm_ral::IS_OK) begin
               `uvm_error("RAL", $psprintf("Status was %s when reading register \"%s\" through map \"%s\".",
                                           status.name(), rg.get_full_name(), maps[k].get_full_name()));
            end
            
            `uvm_info("RAL", $psprintf("Read 'h%h, expecting 'h%h",
                                        actual, exp),UVM_DEBUG);
            
            if (actual !== exp) begin
               `uvm_error("RAL", $psprintf("Register \"%s\" through map \"%s\" is 'h%h instead of 'h%h after writing 'h%h via map \"%s\" over 'h%h.",
                                           rg.get_full_name(), maps[k].get_full_name(),
                                           actual, exp, v, maps[j].get_full_name(), prev));
            end
         end
      end
   endtask: body
endclass: uvm_ral_shared_reg_access_seq


class uvm_ral_shared_mem_access_seq extends uvm_ral_sequence;

   uvm_ral_mem mem;

   `uvm_object_utils(uvm_ral_shared_mem_access_seq)

   function new(string name="ral_shared_mem_access_seq");
     super.new(name);
   endfunction

   virtual task body();
      int read_from;
      uvm_ral_map maps[$];

      if (mem == null) begin
         `uvm_error("RAL", "No memory specified to run sequence on");
         return;
      end

      // Only look at shared memories
      if (mem.get_n_maps() < 2) return;
      mem.get_maps(maps);

      // We need at least a backdoor or a map that can read
      // the shared memory
      read_from = -1;
      if (mem.get_backdoor() == null) begin
         foreach (maps[j]) begin
            string right;
            right = mem.get_access(maps[j]);
            if (right == "RW" ||
                right == "RO") begin
               read_from = j;
               break;
            end
         end
         if (read_from < 0) begin
            `uvm_warning("RAL", $psprintf("Memory \"%s\" cannot be read from any maps or backdoor. Shared access not verified.", mem.get_full_name()));
            return;
         end
      end
      
      // Try to write through each map
      foreach (maps[j]) begin
         
         `uvm_info("RAL", $psprintf("Writing shared memory \"%s\" via map \"%s\".",
                                    mem.get_full_name(), maps[j].get_full_name()), UVM_LOW);
         
         // All addresses
         for (int offset = 0; offset < mem.get_size(); offset++) begin
            uvm_ral::status_e status;
            uvm_ral_data_t  prev, v;
            
            // Read the initial value
            if (mem.get_backdoor() != null) begin
               mem.peek(status, offset, prev);
               if (status != uvm_ral::IS_OK) begin
                  `uvm_error("RAL", $psprintf("Status was %s when reading initial value of \"%s\"[%0d] through backdoor.",
                                              status.name(), mem.get_full_name(), offset));
               end
            end
            else begin
               mem.read(status, offset, prev, uvm_ral::BFM, maps[read_from], this);
               if (status != uvm_ral::IS_OK) begin
                  `uvm_error("RAL", $psprintf("Status was %s when reading initial value of \"%s\"[%0d] through map \"%s\".",
                                              status.name(), mem.get_full_name(),
                                              offset, maps[read_from].get_full_name()));
               end
            end
            
            
            // Write a random value,
            v = {$random, $random};
            
            mem.write(status, offset, v, uvm_ral::BFM, maps[j], this);
            if (status != uvm_ral::IS_OK) begin
               `uvm_error("RAL", $psprintf("Status was %s when writing \"%s\"[%0d] through map \"%s\".",
                                           status.name(), mem.get_full_name(), offset, maps[j].get_full_name()));
            end
            
            // Read back from all other maps
            foreach (maps[k]) begin
               uvm_ral_data_t  actual, exp;
               
               mem.read(status, offset, actual, uvm_ral::BFM, maps[k], this);
               if (status != uvm_ral::IS_OK) begin
                  `uvm_error("RAL", $psprintf("Status was %s when reading %s[%0d] through map \"%s\".",
                                              status.name(), mem.get_full_name(), offset, maps[k].get_full_name()));
               end
               
               // Was it what we expected?
               exp = v;
               if (mem.get_access(maps[j]) == "RO") begin
                  exp = prev;
               end
               if (mem.get_access(maps[k]) == "WO") begin
                  exp = 0;
               end
               // Trim to number of bits
               exp &= (1 << mem.get_n_bits()) - 1;
               if (actual !== exp) begin
                  `uvm_error("RAL", $psprintf("%s[%0d] through map \"%s\" is 'h%h instead of 'h%h after writing 'h%h via map \"%s\" over 'h%h.",
                                              mem.get_full_name(), offset, maps[k].get_full_name(),
                                              actual, exp, v, maps[j].get_full_name(), prev));
               end
            end
         end
      end
   endtask: body
endclass: uvm_ral_shared_mem_access_seq



class uvm_ral_shared_access_seq extends uvm_ral_sequence;

   `uvm_object_utils(uvm_ral_shared_access_seq)

   function new(string name="ral_shared_access_seq");
     super.new(name);
   endfunction

   virtual task body();

      if (ral == null) begin
         `uvm_error("RAL", "Not block or system specified to run sequence on");
         return;
      end
      
      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);

      if (ral.get_attribute("NO_RAL_TESTS") == "" &&
          ral.get_attribute("NO_SHARED_ACCESS_TEST") == "") begin

         uvm_ral_reg regs[$];
         uvm_ral_mem mems[$];

         this.reset_blk(ral);
         ral.reset();

         // Iterate over all registers, checking accesses
         ral.get_registers(regs);
         foreach (regs[i]) begin
            // Registers with some attributes are not to be tested
            if (regs[i].get_attribute("NO_RAL_TESTS") == "" &&
	        regs[i].get_attribute("NO_SHARED_ACCESS_TEST") == "") begin
              uvm_ral_shared_reg_access_seq reg_seq;
              reg_seq = uvm_ral_shared_reg_access_seq::type_id::create("shared_reg_access_seq");
              reg_seq.rg = regs[i];
              reg_seq.start(this.get_sequencer(), this);
            end
         end

         // Iterate over all memories, checking accesses
         ral.get_memories(mems);
         foreach (mems[i]) begin
            // Registers with some attributes are not to be tested
            if (mems[i].get_attribute("NO_RAL_TESTS") == "" &&
	        mems[i].get_attribute("NO_MEM_ACCESS_TEST") == "") begin
              uvm_ral_shared_mem_access_seq mem_seq;
              mem_seq = uvm_ral_shared_mem_access_seq::type_id::create("shared_mem_access_seq");
              mem_seq.mem = mems[i];
              mem_seq.start(this.get_sequencer(), this);
            end
         end
      end

   endtask: body


   // Any additional steps required to reset the block
   // and make it accessibl
   virtual task reset_blk(uvm_ral_block blk);
   endtask


endclass: uvm_ral_shared_access_seq

