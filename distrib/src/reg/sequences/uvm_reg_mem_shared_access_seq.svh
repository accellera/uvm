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
// TITLE: Shared Register and Memory Access test Sequences
//

//
// class: uvm_reg_shared_access_seq
//
// Verify the accessibility of a shared register
// by writing through each address map
// then reading it via every other address maps
// in which the register is readable and the backdoor,
// making sure that the resulting value matches the mirrored value.
//
// Registers that contain fields with unknown access policies
// cannot be tested.
//
// The DUT should be idle and not modify any register during this test.
//

class uvm_reg_shared_access_seq extends uvm_reg_sequence;

   // Variable: rg
   // The register to be tested
   uvm_reg rg;

   `uvm_object_utils(uvm_reg_shared_access_seq)

   function new(string name="uvm_reg_shared_access_seq");
     super.new(name);
   endfunction


   virtual task body();
      uvm_reg_data_t  other_mask;
      uvm_reg_data_t  wo_mask[$];
      uvm_reg_field fields[$];
      uvm_reg_map maps[$];

      if (rg == null) begin
         `uvm_error("RegModel", "No register specified to run sequence on");
         return;
      end

      // Registers with some attributes are not to be tested
      if (rg.get_attribute("NO_REG_TESTS") != "") return;
      if (rg.get_attribute("NO_SHARED_ACCESS_TEST") != "") return;

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
         uvm_reg_data_t  wo;
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
         uvm_status_e status;
         uvm_reg_data_t  prev, v;
         
         // The mirror should contain the initial value
         prev = rg.get();
         
         // Write a random value, except in those "don't touch" fields
         v = ({$random, $random} & ~other_mask) | (prev & other_mask);
         
         `uvm_info("RegModel", $psprintf("Writing register %s via map \"%s\"...",
                                    rg.get_full_name(), maps[j].get_full_name), UVM_LOW);
         
         `uvm_info("RegModel", $psprintf("Writing 'h%h over 'h%h", v, prev),UVM_DEBUG);
         
         rg.write(status, v, UVM_BFM, maps[j], this);
         if (status != UVM_IS_OK) begin
            `uvm_error("RegModel", $psprintf("Status was %s when writing register \"%s\" through map \"%s\".",
                                        status.name(), rg.get_full_name(), maps[j].get_full_name()));
         end
         
         foreach (maps[k]) begin
            uvm_reg_data_t  actual, exp;
            
            `uvm_info("RegModel", $psprintf("Reading register %s via map \"%s\"...",
                                       rg.get_full_name(), maps[k].get_full_name()), UVM_LOW);
            
            // Was it what we expected?
            exp = rg.get() & ~wo_mask[k];
            
            rg.read(status, actual, UVM_BFM, maps[k], this);
            if (status != UVM_IS_OK) begin
               `uvm_error("RegModel", $psprintf("Status was %s when reading register \"%s\" through map \"%s\".",
                                           status.name(), rg.get_full_name(), maps[k].get_full_name()));
            end
            
            `uvm_info("RegModel", $psprintf("Read 'h%h, expecting 'h%h",
                                        actual, exp),UVM_DEBUG);
            
            if (actual !== exp) begin
               `uvm_error("RegModel", $psprintf("Register \"%s\" through map \"%s\" is 'h%h instead of 'h%h after writing 'h%h via map \"%s\" over 'h%h.",
                                           rg.get_full_name(), maps[k].get_full_name(),
                                           actual, exp, v, maps[j].get_full_name(), prev));
            end
         end
      end
   endtask: body
endclass: uvm_reg_shared_access_seq


//
// class: uvm_mem_shared_access_seq
//
// Verify the accessibility of a shared memory
// by writing through each address map
// then reading it via every other address maps
// in which the memory is readable and the backdoor,
// making sure that the resulting value matches the written value.
//
// The DUT should be idle and not modify the memory during this test.
//

class uvm_mem_shared_access_seq extends uvm_reg_sequence;

   // variable: mem
   // The memory to be tested
   uvm_mem mem;

   `uvm_object_utils(uvm_mem_shared_access_seq)

   function new(string name="uvm_mem_shared_access_seq");
     super.new(name);
   endfunction

   virtual task body();
      int read_from;
      uvm_reg_map maps[$];

      if (mem == null) begin
         `uvm_error("RegModel", "No memory specified to run sequence on");
         return;
      end

      // Memories with some attributes are not to be tested
      if (mem.get_attribute("NO_REG_TESTS") != "") return;
      if (mem.get_attribute("NO_MEM_TESTS") != "") return;
      if (mem.get_attribute("NO_SHARED_ACCESS_TEST") != "") return;

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
            `uvm_warning("RegModel", $psprintf("Memory \"%s\" cannot be read from any maps or backdoor. Shared access not verified.", mem.get_full_name()));
            return;
         end
      end
      
      // Try to write through each map
      foreach (maps[j]) begin
         
         `uvm_info("RegModel", $psprintf("Writing shared memory \"%s\" via map \"%s\".",
                                    mem.get_full_name(), maps[j].get_full_name()), UVM_LOW);
         
         // All addresses
         for (int offset = 0; offset < mem.get_size(); offset++) begin
            uvm_status_e status;
            uvm_reg_data_t  prev, v;
            
            // Read the initial value
            if (mem.get_backdoor() != null) begin
               mem.peek(status, offset, prev);
               if (status != UVM_IS_OK) begin
                  `uvm_error("RegModel", $psprintf("Status was %s when reading initial value of \"%s\"[%0d] through backdoor.",
                                              status.name(), mem.get_full_name(), offset));
               end
            end
            else begin
               mem.read(status, offset, prev, UVM_BFM, maps[read_from], this);
               if (status != UVM_IS_OK) begin
                  `uvm_error("RegModel", $psprintf("Status was %s when reading initial value of \"%s\"[%0d] through map \"%s\".",
                                              status.name(), mem.get_full_name(),
                                              offset, maps[read_from].get_full_name()));
               end
            end
            
            
            // Write a random value,
            v = {$random, $random};
            
            mem.write(status, offset, v, UVM_BFM, maps[j], this);
            if (status != UVM_IS_OK) begin
               `uvm_error("RegModel", $psprintf("Status was %s when writing \"%s\"[%0d] through map \"%s\".",
                                           status.name(), mem.get_full_name(), offset, maps[j].get_full_name()));
            end
            
            // Read back from all other maps
            foreach (maps[k]) begin
               uvm_reg_data_t  actual, exp;
               
               mem.read(status, offset, actual, UVM_BFM, maps[k], this);
               if (status != UVM_IS_OK) begin
                  `uvm_error("RegModel", $psprintf("Status was %s when reading %s[%0d] through map \"%s\".",
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
                  `uvm_error("RegModel", $psprintf("%s[%0d] through map \"%s\" is 'h%h instead of 'h%h after writing 'h%h via map \"%s\" over 'h%h.",
                                              mem.get_full_name(), offset, maps[k].get_full_name(),
                                              actual, exp, v, maps[j].get_full_name(), prev));
               end
            end
         end
      end
   endtask: body
endclass: uvm_mem_shared_access_seq



//
// class: uvm_reg_mem_shared_access_seq
//
// Verify the accessibility of all shared registers
// and memories in a block
// by executing the <uvm_reg_shared_access_seq>
// and <uvm_mem_shared_access_seq>
// sequence respectively on every register and memory within it.
//
// Blocks, registers and memories with the NO_REG_TESTS or
// the NO_SHARED_ACCESS_TEST attribute are not verified.
//

class uvm_reg_mem_shared_access_seq extends uvm_reg_sequence;


   // variable: reg_seq
   // The sequence used to test one register
   //
   protected uvm_reg_shared_access_seq reg_seq;
   
   // variable: mem_seq
   // The sequence used to test one memory
   //
   protected uvm_mem_shared_access_seq mem_seq;
   
   `uvm_object_utils(uvm_reg_mem_shared_access_seq)

   function new(string name="uvm_reg_mem_shared_access_seq");
     super.new(name);
   endfunction

   // variable: model
   // The block to be tested

   virtual task body();
      uvm_reg_block blks[$];

      if (model == null) begin
         `uvm_error("RegModel", "Not block or system specified to run sequence on");
         return;
      end
      
      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);

      reg_seq = uvm_reg_shared_access_seq::type_id::create("reg_shared_access_seq");
      mem_seq = uvm_mem_shared_access_seq::type_id::create("reg_shared_access_seq");

      this.reset_blk(model);
      model.reset();

      do_block(model);
      model.get_blocks(blks);
      foreach (blks[i]) begin
         do_block(blks[i]);
      end
   endtask: body


   // task: do_block
   // Test all of the registers and memories in a block
   protected virtual task do_block(uvm_reg_block blk);
      uvm_reg regs[$];
      uvm_mem mems[$];
      
      if (blk.get_attribute("NO_REG_TESTS") != "") return;
      if (blk.get_attribute("NO_MEM_TESTS") != "") return;
      if (blk.get_attribute("NO_REG_ACCESS_TEST") != "") return;


      this.reset_blk(model);
      model.reset();

      // Iterate over all registers, checking accesses
      model.get_registers(regs, UVM_NO_HIER);
      foreach (regs[i]) begin
         // Registers with some attributes are not to be tested
         if (regs[i].get_attribute("NO_REG_TESTS") == "" &&
	     regs[i].get_attribute("NO_SHARED_ACCESS_TEST") == "") begin
            reg_seq.rg = regs[i];
            reg_seq.start(this.get_sequencer(), this);
         end
      end

      // Iterate over all memories, checking accesses
      blk.get_memories(mems, UVM_NO_HIER);
      foreach (mems[i]) begin
         // Registers with some attributes are not to be tested
         if (mems[i].get_attribute("NO_REG_TESTS") == "" &&
             mems[i].get_attribute("NO_MEM_TESTS") == "" &&
	     mems[i].get_attribute("NO_SHARED_ACCESS_TEST") == "") begin
            mem_seq.mem = mems[i];
            mem_seq.start(this.get_sequencer(), this);
         end
      end

   endtask: do_block


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


endclass: uvm_reg_mem_shared_access_seq

