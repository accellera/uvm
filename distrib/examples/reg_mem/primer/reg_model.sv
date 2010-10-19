`ifndef REG_SLAVE
`define REG_SLAVE

import uvm_pkg::*;

class reg_reg_slave_ID extends uvm_reg;

   uvm_reg_field REVISION_ID;
   uvm_reg_field CHIP_ID;
   uvm_reg_field PRODUCT_ID;

   function new(string name = "slave_ID");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.REVISION_ID = uvm_reg_field::type_id::create("REVISION_ID");
          this.CHIP_ID = uvm_reg_field::type_id::create("CHIP_ID");
       this.PRODUCT_ID = uvm_reg_field::type_id::create("PRODUCT_ID");

      this.REVISION_ID.configure(this, 8,  0, "RO",   8'h03, 0, 1);
          this.CHIP_ID.configure(this, 8,  8, "RO",   8'h5A, 0, 1);
       this.PRODUCT_ID.configure(this, 10, 16,"RO", 10'h176, 0, 1);
   endfunction
   
   `uvm_object_utils(reg_reg_slave_ID)
   
endclass


class reg_reg_slave_INDEX extends uvm_reg;

   uvm_reg_field value;
   
   function new(string name = "slave_INDEX");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.value = uvm_reg_field::type_id::create("value");
      this.value.configure(this, 8, 0, "RW", 32'h0, 0, 1);
   endfunction

   `uvm_object_utils(reg_reg_slave_INDEX)

endclass


class reg_reg_slave_DATA extends uvm_reg;

   uvm_reg_field value;
   
   function new(string name = "slave_DATA");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.value = uvm_reg_field::type_id::create("value");
      this.value.configure(this, 32, 0, "RU", 32'h0, 0, 1);
   endfunction

   `uvm_object_utils(reg_reg_slave_DATA)
   
endclass


class reg_reg_slave_SOCKET extends uvm_reg;

   rand uvm_reg_field IP;
   rand uvm_reg_field PORT;
   
   function new(string name = "slave_ADDR");
      super.new(name,64,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.IP   = uvm_reg_field::type_id::create("value");
      this.PORT = uvm_reg_field::type_id::create("value");
      
        this.IP.configure(this, 48,  0, "RW", 48'h0, 0, 1);
      this.PORT.configure(this, 16, 48, "RW", 16'h0, 0, 1);
   endfunction
   
   `uvm_object_utils(reg_reg_slave_SOCKET)
   
endclass


class reg_reg_slave_SESSION extends uvm_reg_file;

   rand reg_reg_slave_SOCKET SRC;
   rand reg_reg_slave_SOCKET DST;
   
   function new(string name = "slave_SESSION");
      super.new(name);
   endfunction: new

   virtual function void build();
      this.SRC = reg_reg_slave_SOCKET::type_id::create("SRC");
      this.DST = reg_reg_slave_SOCKET::type_id::create("DST");

      this.SRC.build();
      this.DST.build();
   endfunction

   virtual function map(uvm_reg_mem_map    mp,
                        uvm_reg_mem_addr_t offset);
      this.SRC.configure(get_block(), this, "SRC");
      this.DST.configure(get_block(), this, "DST");

      mp.add_reg(SRC, offset+'h00);
      mp.add_reg(DST, offset+'h08);
   endfunction
   
   `uvm_object_utils(reg_reg_slave_SESSION)
   
endclass


class reg_reg_slave_TABLES extends uvm_reg;

   rand uvm_reg_field value;
   
   function new(string name = "slave_TABLES");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      this.value = uvm_reg_field::type_id::create("value");
      this.value.configure(this, 32, 0, "RW", 32'h0, 0, 1);
   endfunction

   `uvm_object_utils(reg_reg_slave_TABLES)
   
endclass


class reg_mem_slave_DMA_RAM extends uvm_mem;

   function new(string name = "slave_DMA_RAM");
      super.new(name,'h400,32,"RW",UVM_NO_COVERAGE);
   endfunction
   
   `uvm_object_utils(reg_mem_slave_DMA_RAM)
   
endclass


class indexed_reg extends uvm_reg_frontdoor;

   uvm_reg INDEX;
   int     addr;
   uvm_reg DATA;

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


class reg_block_slave extends uvm_reg_mem_block;

   rand reg_reg_slave_ID       ID;
   rand reg_reg_slave_INDEX    INDEX;
   rand reg_reg_slave_DATA     DATA;

   rand reg_reg_slave_SESSION  SESSION[256];
   
   rand reg_reg_slave_TABLES   TABLES[256];
   
   rand reg_mem_slave_DMA_RAM  DMA_RAM;

   uvm_reg_field REVISION_ID;
   uvm_reg_field CHIP_ID;
   uvm_reg_field PRODUCT_ID;

   function new(string name = "slave");
      super.new(name,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

      // create
      ID        = reg_reg_slave_ID::type_id::create("ID");
      INDEX     = reg_reg_slave_INDEX::type_id::create("INDEX");
      DATA      = reg_reg_slave_DATA::type_id::create("DATA");
      foreach (SESSION[i])
         SESSION[i] = reg_reg_slave_SESSION::type_id::create($sformatf("SESSION[%0d]",i));
      foreach (TABLES[i])
         TABLES[i] = reg_reg_slave_TABLES::type_id::create($sformatf("TABLES[%0d]",i));
      DMA_RAM   = reg_mem_slave_DMA_RAM::type_id::create("DMA_RAM");

      // configure
      ID.build();
      ID.configure(this,null,"ID");
      INDEX.build();
      INDEX.configure(this,null,"INDEX");
      DATA.build();
      DATA.configure(this,null,"DATA");
      foreach (SESSION[i]) begin
         SESSION[i].build();
         SESSION[i].configure(this,null,$sformatf("SESSION[%0d]",i));
      end
      foreach (TABLES[i]) begin
         TABLES[i].build();
         TABLES[i].configure(this,null,$sformatf("TABLES[%0d]",i));
      end
      DMA_RAM.configure(this,"");

      // define default map
      default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);
      default_map.add_reg(ID,    'h0,  "RW");
      default_map.add_reg(INDEX, 'h20, "RW");
      default_map.add_reg(DATA,  'h24, "RW");
      foreach (SESSION[i])
         SESSION[i].map(default_map, 'h1000 + 16 * i);
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

      lock_model();
   endfunction
   
   `uvm_object_utils(reg_block_slave)
   
endclass : reg_block_slave


`endif
