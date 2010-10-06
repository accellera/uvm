`ifndef RAL_SLAVE
`define RAL_SLAVE

import uvm_pkg::*;

class ral_reg_slave_ID extends uvm_ral_reg;

   uvm_ral_field REVISION_ID;
   uvm_ral_field CHIP_ID;
   uvm_ral_field PRODUCT_ID;

   function new(string name = "slave_ID");
      super.new(name,32,uvm_ral::NO_COVERAGE);
   endfunction

   virtual function void build();
      this.REVISION_ID = uvm_ral_field::type_id::create("REVISION_ID");
          this.CHIP_ID = uvm_ral_field::type_id::create("CHIP_ID");
       this.PRODUCT_ID = uvm_ral_field::type_id::create("PRODUCT_ID");

      this.REVISION_ID.configure(this, 8,  0, "RO",   8'h03, 'hx, 0, 1);
          this.CHIP_ID.configure(this, 8,  8, "RO",   8'h5A, 'hx, 0, 1);
       this.PRODUCT_ID.configure(this, 10, 16,"RO", 10'h176, 'hx, 0, 1);
   endfunction
   
   `uvm_object_utils(ral_reg_slave_ID)
   
endclass


class ral_reg_slave_INDEX extends uvm_ral_reg;

   uvm_ral_field value;
   
   function new(string name = "slave_INDEX");
      super.new(name,8,uvm_ral::NO_COVERAGE);
   endfunction

   virtual function void build();
      this.value = uvm_ral_field::type_id::create("value");
      this.value.configure(this, 8, 0, "RW", 32'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction

   `uvm_object_utils(ral_reg_slave_INDEX)

endclass


class ral_reg_slave_DATA extends uvm_ral_reg;

   uvm_ral_field value;
   
   function new(string name = "slave_DATA");
      super.new(name,32,uvm_ral::NO_COVERAGE);
   endfunction

   virtual function void build();
      this.value = uvm_ral_field::type_id::create("value");
      this.value.configure(this, 32, 0, "RU", 32'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction

   `uvm_object_utils(ral_reg_slave_DATA)
   
endclass


class ral_reg_slave_COUNTERS extends uvm_ral_reg;

   rand uvm_ral_field value;
   
   function new(string name = "slave_COUNTERS");
      super.new(name,32,uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.value = uvm_ral_field::type_id::create("value");
      this.value.configure(this, 32, 0, "RU", 32'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction
   
   `uvm_object_utils(ral_reg_slave_COUNTERS)
   
endclass


class ral_reg_slave_TABLES extends uvm_ral_reg;

   rand uvm_ral_field value;
   
   function new(string name = "slave_TABLES");
      super.new(name,32,uvm_ral::NO_COVERAGE);
   endfunction

   virtual function void build();
      this.value = uvm_ral_field::type_id::create("value");
      this.value.configure(this, 32, 0, "RW", 32'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction

   `uvm_object_utils(ral_reg_slave_TABLES)
   
endclass


class ral_mem_slave_DMA_RAM extends uvm_ral_mem;

   function new(string name = "slave_DMA_RAM");
      super.new(name,'h400,32,"RW",uvm_ral::NO_COVERAGE);
   endfunction
   
   `uvm_object_utils(ral_mem_slave_DMA_RAM)
   
endclass


class indexed_reg extends uvm_ral_reg_frontdoor;

   uvm_ral_reg INDEX;
   int         addr;
   uvm_ral_reg DATA;

   function new(string name = "indexed_reg");
      super.new(name);
   endfunction

   `uvm_object_utils(indexed_reg)

   virtual task body();
      INDEX.write(status, addr, .parent(this));
      if (is_write) DATA.write(status, data, .parent(this));
      else DATA.read(status, data, .parent(this));
   endtask
endclass


class ral_block_slave extends uvm_ral_block;

   rand ral_reg_slave_ID       ID;
   rand ral_reg_slave_INDEX    INDEX;
   rand ral_reg_slave_DATA     DATA;
   rand ral_reg_slave_TABLES   TABLES[256];
   rand ral_mem_slave_DMA_RAM  DMA_RAM;

   uvm_ral_field REVISION_ID;
   uvm_ral_field CHIP_ID;
   uvm_ral_field PRODUCT_ID;

   function new(string name = "slave");
      super.new(name,uvm_ral::NO_COVERAGE);
   endfunction

   virtual function void build();

      // create
      ID        = ral_reg_slave_ID::type_id::create("ID");
      INDEX     = ral_reg_slave_INDEX::type_id::create("INDEX");
      DATA      = ral_reg_slave_DATA::type_id::create("DATA");
      foreach (TABLES[i])
      TABLES[i] = ral_reg_slave_TABLES::type_id::create($sformatf("TABLES[%0d]",i));
      DMA_RAM   = ral_mem_slave_DMA_RAM::type_id::create("DMA_RAM");

      // configure
      ID.build();
      ID.configure(this,null,"ID");
      INDEX.build();
      INDEX.configure(this,null,"INDEX");
      DATA.build();
      DATA.configure(this,null,"DATA");
      foreach (TABLES[i]) begin
         TABLES[i].build();
         TABLES[i].configure(this,null,$sformatf("TABLES[%0d]",i));
      end
      DMA_RAM.configure(this,"");

      // define default map
      default_map = create_map("default_map", 'h0, 4, uvm_ral::LITTLE_ENDIAN);
      default_map.add_reg(ID,    'h0,  "RW");
      default_map.add_reg(INDEX, 'h20, "RW");
      default_map.add_reg(DATA,  'h24, "RW");
      foreach (TABLES[i])
        default_map.add_reg(TABLES[i], 0, "RW", 1);
      default_map.add_mem(DMA_RAM, 'h2000, "RW");
      
      // create/set frontdoor
      foreach (TABLES[i]) begin
         indexed_reg fd = new($sformatf("TABLES[%0d] FD",i));
         fd.INDEX = INDEX;
         fd.DATA  = DATA;
         fd.addr  = i;
         TABLES[i].set_frontdoor(fd);
      end

      // field handle aliases
      REVISION_ID = ID.REVISION_ID;
      CHIP_ID     = ID.CHIP_ID;
      PRODUCT_ID  = ID.PRODUCT_ID;

      Xlock_modelX();
   endfunction
   
   `uvm_object_utils(ral_block_slave)
   
endclass : ral_block_slave


`endif
