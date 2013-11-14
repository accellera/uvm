`ifndef __MEM_TRANSFER_SV__
`define __MEM_TRANSFER_SV__

typedef enum bit {MEM_DIR_WRITE = 0,
                  MEM_DIR_READ  = 1} mem_transfer_dir_t;

typedef enum bit [1:0] {MEM_AMODE_LINEAR_INCREMENTING = 2'b00,
			MEM_AMODE_RESERVED            = 2'b01,
			MEM_AMODE_CONSTANT            = 2'b10,
                        MEM_AMODE_CACHE_LINE_WRAP     = 2'b11} mem_transfer_amode_t;

class mem_transfer extends uvm_sequence_item;

        bit        big_endian;
   rand bit [7:0]  mstid;
   rand bit [3:0]  xid;
   rand mem_transfer_dir_t dir;
   rand bit [31:0] address;
   rand bit [4:0]  align;
   rand bit [15:0] rsel;
   rand mem_transfer_amode_t amode;
   rand bit [2:0]  clsize;
   rand bit [31:0] bytecnt;   
   rand bit        excl;
   rand bit [2:0]  pri;
   rand bit [2:0]  epri;
   rand bit        nogap;
   rand bit        emudbg;
   rand bit        priv;
   rand bit [3:0]  privid;
   rand bit        caable;
   rand bit [1:0]  dtype;
   rand bit        done;
   rand bit [4:0]  xcnt;
   rand bit        secure;
   rand bit        depend;
   rand bit [15:0] byten;
   rand bit [7:0]  data[];
   rand bit        data_en[];
   rand bit [2:0]  status;
   rand bit [7:0]  perm;

        int unsigned phase_count = 0;
   rand int unsigned transmit_delay = 0;

   rand int unsigned element_size;
   rand int unsigned num_elements;

   rand int unsigned cache_size;

   bit 	    first_physical_transaction;
   bit      last_physical_transaction;
   
   constraint c_transmit_delay {
      transmit_delay inside {[0:10]};
      transmit_delay dist {0:/50, [1:10]:/50};
   }

   constraint c_data {
      data.size() == bytecnt;
   }

   constraint c_amode {
      if (amode == MEM_AMODE_LINEAR_INCREMENTING) {
         element_size == 0;
         num_elements == 0;
         cache_size == 0;
      }
      if (amode == MEM_AMODE_RESERVED) {
         element_size == 0;
         num_elements == 0;
         cache_size == 0;
      }
      if (amode == MEM_AMODE_CONSTANT) {
         address[4:0] == 0;
         element_size inside {1,2,4,8,16,32};
         num_elements inside {[1:16]};
         bytecnt == element_size * num_elements;
         if (element_size == 1)  clsize == 0;
         if (element_size == 2)  clsize == 1;
         if (element_size == 4)  clsize == 2;
         if (element_size == 8)  clsize == 3;
         if (element_size == 16) clsize == 4;
         if (element_size == 32) clsize == 5;
         cache_size == 0;
      }
      if (amode == MEM_AMODE_CACHE_LINE_WRAP) {
         address[1:0] == 0;
         element_size == 0;
         num_elements == 0;
         cache_size inside {16,32,64,128};
         if (cache_size == 16)  clsize == 0;
         if (cache_size == 32)  clsize == 1;
         if (cache_size == 64)  clsize == 2;
         if (cache_size == 128) clsize == 3;
         bytecnt[1:0] == 0;
         bytecnt <= cache_size;
      }
   }
   
   `uvm_object_utils_begin(mem_transfer)
      `uvm_field_int(big_endian, UVM_ALL_ON | UVM_NOCOMPARE)
      `uvm_field_int(mstid, UVM_ALL_ON)
      `uvm_field_int(xid, UVM_ALL_ON)
      `uvm_field_enum(mem_transfer_dir_t, dir, UVM_ALL_ON)
      `uvm_field_int(address, UVM_ALL_ON)
      `uvm_field_int(align, UVM_ALL_ON)
      `uvm_field_int(rsel, UVM_ALL_ON | UVM_NOCOMPARE)
      `uvm_field_enum(mem_transfer_amode_t, amode, UVM_ALL_ON)
      `uvm_field_int(clsize, UVM_ALL_ON)
      `uvm_field_int(bytecnt, UVM_ALL_ON)      
      `uvm_field_int(excl, UVM_ALL_ON)
      `uvm_field_int(pri, UVM_ALL_ON)
      `uvm_field_int(epri, UVM_ALL_ON | UVM_NOCOMPARE)
      `uvm_field_int(nogap, UVM_ALL_ON)
      `uvm_field_int(emudbg, UVM_ALL_ON)
      `uvm_field_int(priv, UVM_ALL_ON)
      `uvm_field_int(privid, UVM_ALL_ON)
      `uvm_field_int(caable, UVM_ALL_ON)
      `uvm_field_int(dtype, UVM_ALL_ON)
      `uvm_field_int(done, UVM_ALL_ON)
      `uvm_field_int(xcnt, UVM_ALL_ON)
      `uvm_field_int(secure, UVM_ALL_ON)
      `uvm_field_int(depend, UVM_ALL_ON)
      `uvm_field_int(byten, UVM_ALL_ON)
      `uvm_field_array_int(data, UVM_ALL_ON)
      `uvm_field_array_int(data_en, UVM_ALL_ON)
      `uvm_field_int(status, UVM_ALL_ON)
      `uvm_field_int(phase_count, UVM_ALL_ON | UVM_NOCOMPARE)
      `uvm_field_int(transmit_delay, UVM_ALL_ON)
      `uvm_field_int(element_size, UVM_ALL_ON | UVM_NOCOMPARE)
      `uvm_field_int(num_elements, UVM_ALL_ON | UVM_NOCOMPARE)
      `uvm_field_int(cache_size, UVM_ALL_ON | UVM_NOCOMPARE)
      `uvm_field_int(first_physical_transaction, UVM_ALL_ON | UVM_NOCOMPARE)
      `uvm_field_int(last_physical_transaction, UVM_ALL_ON | UVM_NOCOMPARE)
   `uvm_object_utils_end

   extern function new(string name = "mem_transfer_inst");
endclass // mem_transfer


function mem_transfer::new(string name = "mem_transfer_inst");
   super.new(name);
endfunction // new


`endif // __MEM_TRANSFER_SV__
