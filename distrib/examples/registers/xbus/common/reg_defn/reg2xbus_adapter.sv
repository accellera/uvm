//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corp.
//   Copyright 2010 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

`include "xbus_transfer.sv"

class reg2xbus_adapter extends uvm_reg_adapter;

  `uvm_object_utils(reg2xbus_adapter)

  function new(string name="");
    super.new(name);
    provides_responses = 1;
    supports_byte_enable = 0;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    xbus_transfer xbus = xbus_transfer::type_id::create("xbus_transfer");
    int n_bytes = ((rw.n_bits + 7) / 8 );
    xbus.read_write = (rw.kind == UVM_READ) ? READ : WRITE;
    xbus.addr = rw.addr;
    xbus.data = new[n_bytes];
    foreach (xbus.data[i])
      xbus.data[i] = rw.data >> i*8;
    xbus.size = n_bytes;
    return xbus;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    xbus_transfer xbus;
    if (!$cast(xbus,bus_item)) begin
      `uvm_fatal("NOT_XBUS_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw.kind = xbus.read_write == READ ? UVM_READ : UVM_WRITE;
    rw.addr = xbus.addr;
    foreach (xbus.data[i])
      rw.data[i*8 +:8] = xbus.data[i];
    rw.status = UVM_IS_OK;
  endfunction

endclass

