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
// TITLE: Register Access Test Sequence
//

typedef class uvm_ral_mem_access_seq;

class uvm_ral_single_reg_access_seq extends uvm_ral_sequence;

   uvm_ral_reg rg;

   `uvm_object_utils(uvm_ral_single_reg_access_seq)

   function new(string name="ral_single_reg_access_seq");
     super.new(name);
   endfunction

   virtual task body();
      uvm_ral_map maps[$];

      if (rg == null) begin
         `uvm_error("RAL", "No register specified to run sequence on");
         return;
      end

      // Can only deal with registers with backdoor access
      if (rg.get_backdoor() == null && !rg.has_hdl_path()) begin
         `uvm_error("RAL", $psprintf("Register \"%s\" does not have a backdoor mechanism available",
                                       rg.get_full_name()));
         return;
      end

      // Registers may be accessible from multiple physical interfaces (maps)
      rg.get_maps(maps);

      // Cannot test access if register contains RO or OTHER fields
      begin
         uvm_ral_field fields[$];

         rg.get_fields(fields);
         foreach (fields[j]) begin
            foreach (maps[k]) begin
               if (fields[j].get_access(maps[k]) == "RO") begin
                  `uvm_warning("RAL", $psprintf("Register \"%s\" has RO bits",
                                                rg.get_full_name()));
                  return;
               end
               if (!fields[j].is_known_access(maps[k])) begin
                  `uvm_warning("RAL", $psprintf("Register \"%s\" has unknown\"%s\" bits",
                                                rg.get_full_name(),
                                                fields[j].get_access(maps[k])));
                  return;
               end
            end
         end
      end
      
      // Access each register:
      // - Write complement of reset value via front door
      // - Read value via backdoor and compare against mirror
      // - Write reset value via backdoor
      // - Read via front door and compare against mirror
      foreach (maps[j]) begin
         uvm_ral::status_e status;
         uvm_ral_data_t  v, exp;
         
         `uvm_info("RAL", $psprintf("Verifying access of register %s in map \"%s\"...",
                                    rg.get_full_name(), maps[j].get_full_name()), UVM_LOW);
         
         v = rg.get();
         
         rg.write(status, ~v, uvm_ral::BFM, maps[j], this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when writing \"%s\" through map \"%s\".",
                                        status.name(), rg.get_full_name(), maps[j].get_full_name()));
         end
         #1;
         
         rg.mirror(status, uvm_ral::CHECK, uvm_ral::BACKDOOR, uvm_ral_map::backdoor, this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when reading reset value of register \"%s\" through backdoor.",
                                        status.name(), rg.get_full_name()));
         end
         
         rg.write(status, v, uvm_ral::BACKDOOR, maps[j], this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when writing \"%s\" through backdoor.",
                                        status.name(), rg.get_full_name()));
         end
         
         rg.mirror(status, uvm_ral::CHECK, uvm_ral::BFM, maps[j], this);
         if (status != uvm_ral::IS_OK) begin
            `uvm_error("RAL", $psprintf("Status was %s when reading reset value of register \"%s\" through map \"%s\".",
                                        status.name(), rg.get_full_name(), maps[j].get_full_name()));
         end
      end
   endtask: body
endclass: uvm_ral_single_reg_access_seq


class uvm_ral_reg_access_seq extends uvm_ral_sequence;

   `uvm_object_utils(uvm_ral_reg_access_seq)

   function new(string name="ral_reg_access_seq");
     super.new(name);
   endfunction


   virtual task body();

      if (ral == null) begin
         `uvm_error("RAL", "Not block or system specified to run sequence on");
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);
      
      if (ral.get_attribute("NO_RAL_TESTS") == "") begin
        if (ral.get_attribute("NO_REG_ACCESS_TEST") == "") begin
           uvm_ral_reg regs[$];
           uvm_ral_single_reg_access_seq sub_seq;

           sub_seq = uvm_ral_single_reg_access_seq::type_id::create("single_reg_access_seq");
           this.reset_blk(ral);
           ral.reset();

           // Iterate over all registers, checking accesses
           ral.get_registers(regs);
           foreach (regs[i]) begin
              // Registers with some attributes are not to be tested
              if (regs[i].get_attribute("NO_RAL_TESTS") != "" ||
	          regs[i].get_attribute("NO_REG_ACCESS_TEST") != "") continue;

              // Can only deal with registers with backdoor access
              if (regs[i].get_backdoor() == null && !regs[i].has_hdl_path()) begin
                 `uvm_warning("RAL", $psprintf("Register \"%s\" does not have a backdoor mechanism available",
                                               regs[i].get_full_name()));
                 continue;
              end

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

endclass: uvm_ral_reg_access_seq



class uvm_ral_access_seq extends uvm_ral_sequence;

   `uvm_object_utils(uvm_ral_access_seq)

   function new(string name="ral_access_seq");
     super.new(name);
   endfunction

   virtual task body();

      if (ral == null) begin
         `uvm_error("RAL", "Not block or system specified to run sequence on");
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);
      
      if (ral.get_attribute("NO_RAL_TESTS") == "") begin
        if (ral.get_attribute("NO_REG_ACCESS_TEST") == "") begin
           uvm_ral_reg_access_seq sub_seq = new("reg_access_seq");
           this.reset_blk(ral);
           ral.reset();
           sub_seq.ral = ral;
           sub_seq.start(null,this);
        end
        if (ral.get_attribute("NO_MEM_ACCESS_TEST") == "") begin
           uvm_ral_mem_access_seq sub_seq = new("mem_access_seq");
           this.reset_blk(ral);
           ral.reset();
           sub_seq.ral = ral;
           sub_seq.start(null,this);
        end
      end

   endtask: body


   // Any additional steps required to reset the block
   // and make it accessibl
   virtual task reset_blk(uvm_ral_block blk);
   endtask


endclass: uvm_ral_access_seq


