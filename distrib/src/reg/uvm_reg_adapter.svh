//
// -------------------------------------------------------------
//    Copyright 2004-2009 Synopsys, Inc.
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
 
//------------------------------------------------------------------------------
// Title: Classes for Adapting Between Register and Bus Operations
//
// This section defines classes used to convert transaction streams between
// generic register address/data reads and writes and physical bus accesses. 
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// Class: uvm_reg_adapter
//
// This class defines an interface for converting between <uvm_tlm_generic_payload>
// and a specific bus transaction. 
//------------------------------------------------------------------------------

virtual class uvm_reg_adapter extends uvm_object;

  // Function: new
  //
  // Create a new instance of this type, giving it the optional ~name~.

  function new(string name="");
    super.new(name);
  endfunction


  // Variable: supports_byte_enable
  //
  // Set this bit in extensions of this class if the bus protocol supports
  // byte enables.
  
  bit supports_byte_enable;


  // Variable: provides_responses
  //
  // Set this bit in extensions of this class if the bus driver provides
  // separate response items.

  bit provides_responses; 


  // Function: reg2bus
  //
  // Extensions of this class ~must~ implement this method to convert a
  // <uvm_reg_item> to the <uvm_sequence_item> subtype that defines the bus
  // transaction.
  //
  // The method must allocate a new bus item, assign its members from
  // the corresponding members from the given ~bus_rw~ item, then
  // return it. The bus item gets returned in a <uvm_sequence_item> base handle.

  pure virtual function uvm_sequence_item reg2bus(uvm_tlm_generic_payload rw);


  // Function: bus2reg
  //
  // Extensions of this class ~must~ implement this method to copy members
  // of the given ~bus_item~ to corresponding members of the provided
  // ~bus_rw~ instance. Unlike <reg2bus>, the resulting transaction
  // is not allocated from scratch. This is to accommodate applications
  // where the bus response must be returned in the original request.

  pure virtual function void bus2reg(uvm_sequence_item bus_item,
                                     uvm_tlm_generic_payload rw);


endclass


//------------------------------------------------------------------------------
// Group: Example
//
// The following example illustrates how to implement a RegModel-BUS adapter class
// for the APB bus protocol.
//
//|class rreg2apb_adapter extends uvm_reg_adapter;
//|  `uvm_object_utils(reg2apb_adapter)
//|
//|  function new(string name="reg2apb_adapter");
//|    super.new(name);
//|    
//|  endfunction
//|
//|  virtual function uvm_sequence_item reg2bus(uvm_reg_bus_op rw);
//|    apb_item apb = apb_item::type_id::create("apb_item");
//|    apb.op   = (rw.kind == UVM_READ) ? apb::READ : apb::WRITE;
//|    apb.addr = rw.addr;
//|    apb.data = rw.data;
//|    return apb;
//|  endfunction
//|
//|  virtual function void bus2reg(uvm_sequencer_item bus_item,
//|                                uvm_reg_bus_op rw);
//|    apb_item apb;
//|    if (!$cast(apb,bus_item)) begin
//|      `uvm_fatal("CONVERT_APB2REG","Bus item is not of type apb_item")
//|    end
//|    rw.kind  = apb.op==apb::READ ? UVM_READ : UVM_WRITE;
//|    rw.addr = apb.addr;
//|    rw.data = apb.data;
//|    rw.status = UVM_IS_OK;
//|  endfunction
//|
//|endclass
//
//------------------------------------------------------------------------------


