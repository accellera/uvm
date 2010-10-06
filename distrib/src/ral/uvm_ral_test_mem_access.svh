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


class uvm_ral_single_mem_access_seq extends uvm_sequence #(uvm_sequence_item);

   uvm_ral_mem mem;

   `uvm_object_utils(uvm_ral_single_mem_access_seq)

   function new(string name="ral_single_mem_access_seq");
     super.new(name);
   endfunction

   virtual task body();
      string mode;
      uvm_ral_map maps[$];
      int n_bits;

      if (mem == null) begin
         `uvm_error("RAL", "No register specified to run sequence on");
         return;
      end

      // Can only deal with memories with backdoor access
      if (mem.get_backdoor() == null) begin
         `uvm_error("RAL", $psprintf("Memory \"%s\" does not have a backdoor mechanism available",
                                     mem.get_full_name()));
         return;
      end

      n_bits = mem.get_n_bits();
      
      // Memories may be accessible from multiple physical interfaces (maps)
      mem.get_maps(maps);

      // Walk the memory via each map
      foreach (maps[j]) begin
         uvm_ral::status_e status;
         uvm_ral_data_t  val, exp, v;
         
         `uvm_info("RAL", $psprintf("Accessing memory %s in map \"%s\"...\n",
                                    mem.get_full_name(), maps[j].get_full_name()), UVM_LOW);
         
         mode = mem.get_access(maps[j]);
         
         // The access process is, for address k:
         // - Write random value via front door
         // - Read via backdoor and expect same random value if RW
         // - Write complement of random value via back door
         // - Read via front door and expect inverted random value
         for (int k = 0; k < mem.get_size(); k++) begin
            val = $random & uvm_ral_data_t'((1'b1<<n_bits)-1);
            if (n_bits > 32)
              val = uvm_ral_data_t'(val << 32) | $random;
            if (mode == "RO") begin
               mem.peek(status, k, exp);
               if (status != uvm_ral::IS_OK) begin
                  `uvm_error("RAL", $psprintf("Status was %s when reading \"%s[%0d]\" through backdoor.",
                                              status.name(), mem.get_full_name(), k));
               end
            end
            else exp = val;
            
            mem.write(status, k, val, uvm_ral::BFM, maps[j], this);
            if (status != uvm_ral::IS_OK) begin
               `uvm_error("RAL", $psprintf("Status was %s when writing \"%s[%0d]\" through map \"%s\".",
                                           status.name(), mem.get_full_name(), k, maps[j].get_full_name()));
            end
            #1;
            
            val = 'x;
            mem.peek(status, k, val);
            if (status != uvm_ral::IS_OK) begin
               `uvm_error("RAL", $psprintf("Status was %s when reading \"%s[%0d]\" through backdoor.",
                                           status.name(), mem.get_full_name(), k));
            end
            else begin
               if (val !== exp) begin
                  `uvm_error("RAL", $psprintf("Backdoor \"%s[%0d]\" read back as 'h%h instead of 'h%h.",
                                              mem.get_full_name(), k, val, exp));
               end
            end
            
            exp = ~exp & ((1'b1<<n_bits)-1);
            mem.poke(status, k, exp);
            if (status != uvm_ral::IS_OK) begin
               `uvm_error("RAL", $psprintf("Status was %s when writing \"%s[%0d-1]\" through backdoor.",
                                           status.name(), mem.get_full_name(), k));
            end
            
            mem.read(status, k, val, uvm_ral::BFM, maps[j], this);
            if (status != uvm_ral::IS_OK) begin
               `uvm_error("RAL", $psprintf("Status was %s when reading \"%s[%0d]\" through map \"%s\".",
                                           status.name(), mem.get_full_name(), k, maps[j].get_full_name()));
            end
            else begin
               if (mode == "WO") begin
                  if (val !== '0) begin
                     `uvm_error("RAL", $psprintf("Front door \"%s[%0d]\" read back as 'h%h instead of 'h%h.",
                                                 mem.get_full_name(), k, val, 0));
                  end
               end
               else begin
                  if (val !== exp) begin
                     `uvm_error("RAL", $psprintf("Front door \"%s[%0d]\" read back as 'h%h instead of 'h%h.",
                                                 mem.get_full_name(), k, val, exp));
                  end
               end
            end
         end
      end
   endtask: body
endclass: uvm_ral_single_mem_access_seq




class uvm_ral_mem_access_seq extends uvm_ral_sequence;

   `uvm_object_utils(uvm_ral_mem_access_seq)

   function new(string name="ral_mem_access_seq");
     super.new(name);
   endfunction

   virtual task body();

      if (ral == null) begin
         `uvm_error("RAL", "Not block or system specified to run sequence on");
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);
      
      if (ral.get_attribute("NO_RAL_TESTS") == "") begin
        if (ral.get_attribute("NO_MEM_ACCESS_TEST") == "") begin
           uvm_ral_mem mems[$];
           uvm_ral_single_mem_access_seq mem_seq = new("single_mem_access_seq");
           this.reset_blk(ral);
           ral.reset();

           // Iterate over all memories, checking accesses
           ral.get_memories(mems);
           foreach (mems[i]) begin
              // Registers with some attributes are not to be tested
              if (mems[i].get_attribute("NO_RAL_TESTS") != "" ||
	          mems[i].get_attribute("NO_MEM_ACCESS_TEST") != "") continue;

              // Can only deal with memories with backdoor access
              if (mems[i].get_backdoor() == null) begin
                 `uvm_warning("RAL", $psprintf("Memory \"%s\" does not have a backdoor mechanism available",
                                               mems[i].get_full_name()));
                 continue;
              end

              mem_seq.mem = mems[i];
              mem_seq.start(null, this);
           end
        end
      end

   endtask: body


   // Any additional steps required to reset the block
   // and make it accessibl
   virtual task reset_blk(uvm_ral_block blk);
   endtask


endclass: uvm_ral_mem_access_seq


