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
// TITLE: Memory Walk test Sequence
//

//------------------------------------------------------------------------------
// CLASS: uvm_ral_single_mem_walk_seq
//
// Runs the walking-ones algorithm on the memory given by the <mem> property,
// which must be assigned prior to starting this sequence.
//
// The walking ones algorithm is performed for each map in which the memory
// is defined.
//
// The algorithm is:
//
//| for (k = 0 thru memsize-1)
//|   write addr=k data=~k
//|   if (k > 0) {
//|     read addr=k-1, expect data=~(k-1)
//|     write addr=k-1 data=k-1
//|   if (k == last addr)
//|     read addr=k, expect data=~k
//
//------------------------------------------------------------------------------

class uvm_ral_single_mem_walk_seq extends uvm_ral_sequence;

   `uvm_object_utils(uvm_ral_single_mem_walk_seq)


   // Variable: mem
   //
   // The memory to test; must be assigned prior to starting sequence.

   uvm_ral_mem mem;


   // Function: new
   //
   // Creates a new instance of the class with the given name.

   function new(string name="ral_mem_walk_seq");
     super.new(name);
   endfunction


   // Task: body
   //
   // Performs the walking-ones algorithm on each map of the memory
   // specifed in <mem>.

   virtual task body();
      uvm_ral_map maps[$];
      int n_bits;

      if (mem == null) begin
         `uvm_error("RAL", "No memory specified to run sequence on");
         return;
      end
      n_bits = mem.get_n_bits();

      // Memories may be accessible from multiple physical interfaces (maps)
      mem.get_maps(maps);
      
      // Walk the memory via each map
      foreach (maps[j]) begin
         uvm_ral::status_e status;
         uvm_ral_data_t  val, exp, v;
         
         // Only deal with RW memories
         if (mem.get_access(maps[j]) != "RW") continue;

         `uvm_info("RAL", $psprintf("Walking memory %s in map \"%s\"...",
                                    mem.get_full_name(), maps[j].get_full_name()), UVM_LOW);
         
         // The walking process is, for address k:
         // - Write ~k
         // - Read k-1 and expect ~(k-1) if k > 0
         // - Write k-1 at k-1
         // - Read k and expect ~k if k == last address
         for (int k = 0; k < mem.get_size(); k++) begin

            mem.write(status, k, ~k, uvm_ral::BFM, maps[j], this);

            if (status != uvm_ral::IS_OK) begin
               `uvm_error("RAL", $psprintf("Status was %s when writing \"%s[%0d]\" through map \"%s\".",
                                           status.name(), mem.get_full_name(), k, maps[j].get_full_name()));
            end
            
            if (k > 0) begin
               mem.read(status, k-1, val, uvm_ral::BFM, maps[j], this);
               if (status != uvm_ral::IS_OK) begin
                  `uvm_error("RAL", $psprintf("Status was %s when reading \"%s[%0d]\" through map \"%s\".",
                                              status.name(), mem.get_full_name(), k, maps[j].get_full_name()));
               end
               else begin
                  exp = ~(k-1) & ((1'b1<<n_bits)-1);
                  if (val !== exp) begin
                     `uvm_error("RAL", $psprintf("\"%s[%0d-1]\" read back as 'h%h instead of 'h%h.",
                                                 mem.get_full_name(), k, val, exp));
                     
                  end
               end
               
               mem.write(status, k-1, k-1, uvm_ral::BFM, maps[j], this);
               if (status != uvm_ral::IS_OK) begin
                  `uvm_error("RAL", $psprintf("Status was %s when writing \"%s[%0d-1]\" through map \"%s\".",
                                              status.name(), mem.get_full_name(), k, maps[j].get_full_name()));
               end
            end
            
            if (k == mem.get_size() - 1) begin
               mem.read(status, k, val, uvm_ral::BFM, maps[j], this);
               if (status != uvm_ral::IS_OK) begin
                  `uvm_error("RAL", $psprintf("Status was %s when reading \"%s[%0d]\" through map \"%s\".",
                                              status.name(), mem.get_full_name(), k, maps[j].get_full_name()));
               end
               else begin
                  exp = ~(k) & ((1'b1<<n_bits)-1);
                  if (val !== exp) begin
                     `uvm_error("RAL", $psprintf("\"%s[%0d]\" read back as 'h%h instead of 'h%h.",
                                                 mem.get_full_name(), k, val, exp));
                     
                  end
               end
            end
         end
      end
   endtask: body

endclass: uvm_ral_single_mem_walk_seq


//------------------------------------------------------------------------------
// CLASS: uvm_ral_mem_walk_seq
//
// 
//------------------------------------------------------------------------------

class uvm_ral_mem_walk_seq extends uvm_ral_sequence;

   `uvm_object_utils(uvm_ral_mem_walk_seq)

   function new(string name="ral_mem_walk_seq");
     super.new(name);
   endfunction

   virtual task body();

      if (ral == null) begin
         `uvm_error("RAL", "Not block or system specified to run sequence on");
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);

      if (ral.get_attribute("NO_RAL_TESTS") == "") begin
        if (ral.get_attribute("NO_MEM_WALK_TEST") == "") begin
           uvm_ral_mem mems[$];
           uvm_ral_single_mem_walk_seq mem_seq = new("single_mem_walk_seq");
           this.reset_blk(ral);
           ral.reset();

           // Iterate over all memories, checking accesses
           ral.get_memories(mems);
           foreach (mems[i]) begin
              // Registers with some attributes are not to be tested
              if (mems[i].get_attribute("NO_RAL_TESTS") != "" ||
	          mems[i].get_attribute("NO_MEM_WALK_TEST") != "") continue;

              mem_seq.mem = mems[i];
              mem_seq.start(null, this);
           end
        end
      end

   endtask: body


   // Any additional steps required to reset the block
   // and make it accessible
   virtual task reset_blk(uvm_ral_block blk);
   endtask

endclass: uvm_ral_mem_walk_seq
