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
 
//
// TITLE: Classes for Adapting Between Register and Bus Operations
//
// The following classes are defined herein:
//
// <uvm_reg_adapter> : converts between a register transaction type and a bus transaction type
//
// <uvm_reg_null_adapter> : a converter that does nothing
//
// <uvm_reg_tlm_adapter> : converts between register items and TLM generic payload items
//
// <uvm_reg_predictor> : updates the RegModel mirror based on observed bus transactions
//


typedef class uvm_reg_block;
typedef class uvm_reg_null_adapter;


//------------------------------------------------------------------------------
//
// CLASS: uvm_reg_adapter
//
// This class defines an interface for converting between <uvm_reg_bus_op>
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

  pure virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);


  // Function: bus2reg
  //
  // Extensions of this class ~must~ implement this method to copy members
  // of the given ~bus_item~ to corresponding members of the provided
  // ~bus_rw~ instance. Unlike <reg2bus>, the resulting transaction
  // is not allocated from scratch. This is to accommodate applications
  // where the bus response must be returned in the original request.

  pure virtual function void bus2reg(uvm_sequence_item bus_item,
                                     ref uvm_reg_bus_op rw);


  local static uvm_reg_null_adapter m_null; 

  // Function: null
  //
  // Get a singleton instance of the <uvm_reg_null_adapter>. Use this
  // integrating the register model in a layered sequencer approach.
  //
  static function uvm_reg_null_adapter none();
    if (m_null == null)
      m_null = uvm_reg_null_adapter::type_id::create("reg_null_adapter");
    return m_null;
  endfunction
    

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



//------------------------------------------------------------------------------
//
// CLASS: uvm_reg_null_adapter
//
// Defines an extension of <uvm_reg_adapter> that does no conversion.
//
// This adapter is used when running in a layering model that has RegModel sequences
// running on a separate, generic "upstream" sequencer connected to a
// "downstream" bus sequencer. In this case, the register model does not perform
// the conversion to bus items, and so must be configured to use this null adapter.
// To do this, call <uvm_reg_map::set_sequencer> with <uvm_reg_adaptern::none>.
// For example:
//
//| virtual function void build();
//|   reg_seqr = uvm_sequencer #(uvm_reg_item)::type_id::create("reg_seqr",this);
//|   ...
//| endfunction
//|
//| virtual function void connect();
//|   my_reg_model.default_map.set_sequencer(reg_seqr,uvm_reg_adapter::none());
//|   ...
//| endfunction
// 
//------------------------------------------------------------------------------

class uvm_reg_null_adapter extends uvm_reg_adapter;

  `uvm_object_utils(uvm_reg_null_adapter)

  // Function: reg2bus
  //
  // Returns null.

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    return null;
  endfunction


  // Function: bus2reg
  //
  // Does nothing.
  //
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    return;
  endfunction


endclass


//------------------------------------------------------------------------------
//
// Class: uvm_reg_tlm_adapter
//
// For converting between <uvm_reg_bus_op> and <uvm_tlm_gp> items.
//
//------------------------------------------------------------------------------

class uvm_reg_tlm_adapter extends uvm_reg_adapter;

  `uvm_object_utils(uvm_reg_tlm_adapter)

  // Function: reg2bus
  //
  // Converts a <uvm_reg_bus_op> struct to a <uvm_tlm_gp> item.

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

     uvm_tlm_gp gp = uvm_tlm_gp::type_id::create("tlm_gp",, this.get_full_name());
     int nbytes = (rw.n_bits-1)/8+1;
     uvm_reg_addr_t addr=rw.addr;

     if (rw.kind == UVM_WRITE)
        gp.set_command(uvm_tlm_gp::TLM_WRITE_COMMAND);
     else
        gp.set_command(uvm_tlm_gp::TLM_READ_COMMAND);

     gp.set_address(addr);

     gp.m_byte_enable = new [nbytes];

     gp.set_streaming_width (nbytes);

     gp.m_data = new [gp.get_streaming_width()];

     for (int i = 0; i < nbytes; i++) begin
        gp.m_data[i] = rw.data[i*8+:8];
        gp.m_byte_enable[i] = (i > nbytes) ? 1'b0 : rw.byte_en[i];
     end

     return gp;

  endfunction


  // Function: bus2reg
  //
  // Converts a <uvm_tlm_gp> item to a <uvm_reg_bus_op>.
  // into the provided ~rw~ transaction.
  //
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);

    uvm_tlm_gp gp;
    int nbytes;

    assert(bus_item!=null);

    if (!$cast(gp,bus_item)) begin
      `uvm_error("WRONG_TYPE","Provided bus_item is not of type uvm_tlm_gp")
      return;
    end

    if (gp.get_command() == uvm_tlm_gp::TLM_WRITE_COMMAND)
      rw.kind = UVM_WRITE;
    else
      rw.kind = UVM_READ;

    rw.addr = gp.get_address();

    rw.byte_en = 0;
    foreach (gp.m_byte_enable[i])
      rw.byte_en[i] = gp.m_byte_enable[i];

    rw.data = 0;
    foreach (gp.m_data[i])
      rw.data[i*8+:8] = gp.m_data[i];

    rw.status = (gp.is_response_ok()) ? UVM_IS_OK : UVM_NOT_OK;


  endfunction

endclass

