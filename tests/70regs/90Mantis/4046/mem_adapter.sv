`ifndef __REG2MEM_ADAPTER_SV__
`define __REG2MEM_ADAPTER_SV__


class reg2mem_adapter extends uvm_reg_adapter;

   `uvm_object_utils(reg2mem_adapter)

   extern function new(string name = "reg2mem_adapter");
   extern virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
   extern virtual function void bus2reg(uvm_sequence_item bus_item,
					ref uvm_reg_bus_op rw);
endclass // reg2mem_adapter


function reg2mem_adapter::new(string name = "reg2mem_adapter");
   super.new(name);

   supports_byte_enable = 1'b1;
   provides_responses = 1'b0;
endfunction // new


function uvm_sequence_item reg2mem_adapter::reg2bus(const ref uvm_reg_bus_op rw);
   mem_transfer xfer = mem_transfer::type_id::create("xfer");

   xfer.address = rw.addr[31:0];
   xfer.dir     = ((rw.kind == UVM_READ) || (rw.kind == UVM_BURST_READ)) ? MEM_DIR_READ : MEM_DIR_WRITE;
   xfer.byten   = rw.byte_en;
   xfer.data    = new[(rw.n_bits + 7) / 8];
   xfer.bytecnt = xfer.data.size();
   xfer.align   = rw.addr[4:0];

   for (int i = 0; i < xfer.data.size(); i++) begin
      xfer.data[i] = rw.data[(i*8)+7-:8];
   end

   if (rw.status == UVM_NOT_OK) xfer.status = 1'b1;
   return xfer;
endfunction // reg2bus


function void reg2mem_adapter::bus2reg(uvm_sequence_item bus_item,
         		               ref uvm_reg_bus_op rw);
   mem_transfer xfer;

   // Cast the incoming bus item
   if (!$cast(xfer, bus_item)) begin
      `uvm_fatal("NOT_MEM_TRANSFER_TYPE","Provided bus_item is not of the correct type!")
      return;
   end

   rw.kind    = (xfer.dir == MEM_DIR_READ) ? UVM_READ : UVM_WRITE;
   rw.addr    = xfer.address;
   rw.byte_en = xfer.byten;
   rw.n_bits  = xfer.data.size() * 8;

   for (int i = 0; i < xfer.data.size(); i++) begin
      rw.data[(i*8)+7-:8] = xfer.data[i];
   end
   
   if (xfer.status != 0) rw.status = UVM_NOT_OK;
endfunction // bus2reg


`endif //  __REG2MEM_ADAPTER_SV__
