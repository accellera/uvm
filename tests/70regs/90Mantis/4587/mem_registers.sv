`ifndef __MEM_REGISTERS_SV__
`define __MEM_REGISTERS_SV__


class mem_reg_block extends uvm_reg_block;
   `uvm_object_utils(mem_reg_block)

   
   // List of all memories
   uvm_mem          mem;
   
   function new(string name = "mem_reg_block");
      super.new(name, build_coverage(UVM_CVR_ADDR_MAP));
   endfunction // new

   virtual function void build();
      
      // Create the memory    
      mem = new("mem", 4096, 128, "RW", UVM_NO_COVERAGE);
      mem.configure(this);
      

      // Map each sub-block
      // create_map("name", base_address, bus byte width, endianness, byte_addressing)
      this.default_map = create_map("default_map", 'h0, 16, UVM_LITTLE_ENDIAN, 1);
      this.default_map.add_mem(mem, 0);

      lock_model();
   endfunction // build
endclass // mem_reg_block


`endif // __MEM_REGISTERS_SV__
