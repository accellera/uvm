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
// TITLE: Hardware Reset Test Sequence
//

class uvm_ral_hw_reset_seq extends uvm_ral_sequence;

   `uvm_object_utils(uvm_ral_hw_reset_seq)

   function new(string name="ral_hw_reset_seq");
     super.new(name);
   endfunction


   virtual task body();

      if (ral == null) begin
         `uvm_error("RAL", "Not block or system specified to run sequence on");
         return;
      end
      
      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);

      if (ral.get_attribute("NO_RAL_TESTS") == "" &&
          ral.get_attribute("NO_HW_RESET_TEST") == "") begin
        uvm_ral_reg regs[$];
        uvm_ral_map maps[$];


        this.reset_blk(ral);
        ral.reset();
        ral.get_maps(maps);

        // Iterate over all maps defined for the RAL block

        foreach (maps[d]) begin

          // Iterate over all registers in the map, checking accesses
          // Note: if map were in inner loop, could test simulataneous
          // access to same reg via different bus interfaces 
          maps[d].get_registers(regs);

          foreach (regs[i]) begin

            uvm_ral::status_e status;

            // Registers with certain attributes are not to be tested
            if (regs[i].get_attribute("NO_RAL_TESTS") != "" ||
	        regs[i].get_attribute("NO_HW_RESET_TEST") != "") continue;

            `uvm_info(get_type_name(),
                      $psprintf("Verifying reset value of register %s in map \"%s\"...",
                      regs[i].get_full_name(), maps[d].get_full_name()), UVM_LOW);
            
            regs[i].mirror(status, uvm_ral::CHECK, uvm_ral::BFM, maps[d], this);

            if (status != uvm_ral::IS_OK) begin
               `uvm_error(get_type_name(),
                      $psprintf("Status was %s when reading reset value of register \"%s\" through map \"%s\".",
                      status.name(), regs[i].get_full_name(), maps[d].get_full_name()));
            end
          end
        end
      end

   endtask: body


   // Any additional steps required to reset the block
   // and make it accessible
   virtual task reset_blk(uvm_ral_block blk);
   endtask

endclass: uvm_ral_hw_reset_seq


