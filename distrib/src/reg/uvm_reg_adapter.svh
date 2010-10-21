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
// TITLE: Register Model Adaptor for Bus Agent
//
// This file defines the following classes:
//
// <uvm_reg_item> : abstract register transaction type
//
// <uvm_reg_bus_item> : physical register transaction type
//
// <uvm_reg_adapter> : converts between a register transaction type and a bus transaction type
//
// <uvm_reg_passthru_adapter> : a converter whose input is passed to its output
//
// <uvm_reg_predictor> : updates the RegModel mirror based on observed bus transactions
//
//

//------------------------------------------------------------------------------
// CLASS: uvm_reg_item
//
// Defines an abstract register transaction item. No bus-specific information
// is present, although a handle a <uvm_reg_map> is provided in case the user
// wishes to implement a custom address translation algorithm.
//------------------------------------------------------------------------------

class uvm_reg_item extends uvm_sequence_item;

  `uvm_object_utils(uvm_reg_item)

  // Variable: element_kind
  //
  // Kind of element being accessed: REG, MEM, or FIELD. See <uvm_elem_kind_e>.
  //
  uvm_elem_kind_e element_kind;


  // Variable: element
  //
  // A handle to the RegModel model element associated with this transaction.
  // Use <element_kind> to determine the type to cast  to: <uvm_reg>,
  // <uvm_mem>, or <uvm_reg_field>.
  //
  uvm_object element;


  // Variable: kind
  //
  // Kind of access: READ or WRITE.
  //
  rand uvm_access_e kind;


  // Variable: value
  //
  // The value to write to, or after completion, the value read from the DUT.
  //
  rand uvm_reg_data_logic_t value;


  // Variable: offset
  //
  // The offset address, if a memory access. Undefined if not a memory access.
  //
  rand uvm_reg_addr_t offset;


  // Variable: status
  //
  // The result of the transaction: IS_OK, HAS_X, or ERROR.
  // See <uvm_status_e>.
  //
  uvm_status_e status;


  // Variable: map
  //
  // The local map used to obtain addresses. Users may customize 
  // address-translation using this map.
  //
  uvm_reg_map map;


  // Variable: path
  //
  // The path being used: BFM or BACKDOOR. Currently, uvm_reg_item transactions
  // are used only during frontdoor (BFM) accesses.
  //
  uvm_path_e path;


  // Variable: extension
  //
  // Handle to optional user data, as conveyed in the call to write, read,
  // mirror, or update call. Must derive from uvm_object. 
  //
  rand uvm_object           extension;


  // Variable: fname
  //
  // The file name from where this transaction originated, if provided
  // at the call site.
  //
  string                     fname = ""; // file and line from which access originated


  // Variable: lineno
  //
  // The file name from where this transaction originated, if provided 
  // at the call site.
  //
  int                        lineno = 0;


  // Function: new
  //
  // Create a new instance of this type, giving it the optional ~name~.
  //
  function new(string name="");
    super.new(name);
  endfunction


  // Function: convert2string
  //
  // Returns a string showing the contents of this transaction.
  //
  virtual function string convert2string();
    string s;
    s = {"kind=",kind.name()," ele_kind=",element_kind.name(),
         " ele_name=",element.get_full_name() };
    s = {s, $sformatf(" value=%0h",value)};
    if (element_kind == UVM_MEM)
      s = {s, $sformatf(" offset=%0h",offset)};
    s = {s," map=",(map==null?"null":map.get_full_name())," path=",path.name()};
    s = {s," status=",status.name()};
    return s;
  endfunction


  // Function: copy
  //
  // Copy the ~rhs~ object into this object. The ~rhs~ object must
  // derive from <uvm_reg_item>.
  //
  virtual function void copy(uvm_object rhs);
    uvm_reg_item rhs_;
    assert(rhs != null);
    if (!$cast(rhs_,rhs)) begin
      `uvm_error("WRONG_TYPE","Provided rhs is not of type uvm_reg_item")
      return;
    end
    super.copy(rhs);
    element_kind = rhs_.element_kind;
    element = rhs_.element;
    kind = rhs_.kind;
    value = rhs_.value;
    offset = rhs_.offset;
    status = rhs_.status;
    map = rhs_.map;
    path = rhs_.path;
    extension = rhs_.extension;
  endfunction

endclass



//------------------------------------------------------------------------------
//
// CLASS: uvm_reg_bus_item
//
// Defines a generic bus transaction for register and memory accesses. Extending
// from <uvm_reg_item>, this class adds bus-specific information such as
// address, byte_en, and execution priority. If the bus is narrower than the
// register or memory location being accessed, there will be multiple bus
// operations (<uvm_reg_bus_item> transactions) for every abstract <uvm_reg_item>
// transaction. In this case, ~data~ represents the portion 
// of <uvm_reg_item::value> to be transferred during this bus cycle. 
// If the bus is wide enough to perform the register or memory operation in
// a single cycle, ~data~ will be the same as ~value~.
//------------------------------------------------------------------------------

class uvm_reg_bus_item extends uvm_reg_item;

   `uvm_object_utils(uvm_reg_bus_item)

   // Variable: addr
   //
   // The bus address.
   //
   rand uvm_reg_addr_t addr;


   // Variable: data
   //
   // The data to write
   //
   rand uvm_reg_data_t data;

   
   // Variable: n_bits
   //
   // The number of bits of <uvm_reg_item::value> being transferred by
   // this transaction.

   rand int n_bits = `UVM_REG_DATA_WIDTH;

   constraint valid_uvm_rw_access {
      n_bits > 0;
      n_bits <= `UVM_REG_DATA_WIDTH;
   }


   // Variable: byte_en
   //
   // Enables for the byte lanes on the bus. Meaningful only when the
   // bus supports byte enables and the operation originates from a field
   // write/read.
   //
   rand uvm_reg_byte_en_t byte_en = '1;            // if bus supports it


   // Variable: prior
   //
   // The priority of this transfer, as defined by
   // <uvm_sequence_base::start_item>.
   //
   int prior = -1;


   // Function: new
   //
   // Create a new instance of this type, giving it the optional ~name~.
   //
   function new(string name="");
     super.new(name);
   endfunction


   // Function: convert2string
   //
   // Returns a string showing the contents of this transaction.
   //
   virtual function string convert2string();
     string s;
     s = super.convert2string();
     s = {s,$sformatf(" [rw_access: addr=%0h data=%0h bits=%0h byte_en=%0h]",
          addr,data,n_bits,byte_en)};
     return s;
   endfunction


   // Function: copy
   //
   // Copy the ~rhs~ object into this object. The ~rhs~ object must
   // derive from <uvm_reg_bus_item>.
   //
   virtual function void copy(uvm_object rhs);
     uvm_reg_bus_item rhs_;
     assert(rhs != null);
     if (!$cast(rhs_,rhs)) begin
       `uvm_error("WRONG_TYPE","Provided rhs is not of type uvm_reg_bus_item")
       return;
     end
     super.copy(rhs);
     addr = rhs_.addr;
     data = rhs_.data;
     n_bits = rhs_.n_bits;
     byte_en = rhs_.byte_en;
     fname = rhs_.fname;
     lineno = rhs_.lineno;
     
   endfunction

endclass: uvm_reg_bus_item


typedef class uvm_reg_block;


//------------------------------------------------------------------------------
//
// CLASS: uvm_reg_adapter
//
// This class defines an interface for converting between <uvm_reg_bus_item>
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
  // the corresponding members from the given ~rw_access~ item, then
  // return it. The bus item gets returned in a <uvm_sequence_item> base handle.

  pure virtual function uvm_sequence_item reg2bus(uvm_reg_bus_item rw_access);


  // Function: bus2reg
  //
  // Extensions of this class ~must~ implement this method to copy members
  // of the given ~bus_item~ to corresponding members of the provided
  // ~rw_access~ instance. Unlike <reg2bus>, the resulting transaction
  // is not allocated from scratch. This is to accommodate applications
  // where the bus response must be returned in the original request.

  pure virtual function void bus2reg(uvm_sequence_item bus_item, uvm_reg_bus_item rw_access);

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
//|  virtual function uvm_sequence_item reg2bus(uvm_reg_bus_item rw_access);
//|    apb_item apb = apb_item::type_id::create("apb_item");
//|    apb.op   = (rw_access.kind == UVM_READ) ? apb::READ : apb::WRITE;
//|    apb.addr = rw_access.addr;
//|    apb.data = rw_access.data;
//|    return apb;
//|  endfunction
//|
//|  virtual function void bus2reg(uvm_sequencer_item bus_item,
//|                                uvm_reg_bus_item rw_access);
//|    apb_item apb;
//|    if (!$cast(apb,bus_item)) begin
//|      `uvm_fatal("CONVERT_APB2REG","Bus item is not of type apb_item")
//|    end
//|    rw_access.kind  = apb.op==apb::READ ? UVM_READ : UVM_WRITE;
//|    rw_access.addr = apb.addr;
//|    rw_access.data = apb.data;
//|    rw_access.status = UVM_IS_OK;
//|  endfunction
//|
//|endclass



//------------------------------------------------------------------------------
//
// CLASS: uvm_reg_passthru_adapter
//
// Defines an extension of <uvm_reg_adapter> that does no conversion.
//
// This adapter is used when running in a layering model that has RegModel sequences
// running on a separate, generic "upstream" sequencer connected to a
// "downstream" bus sequencer. In this case, the RegModel map associated with
// the downstream bus must be configured to start RegModel items on the generic
// upstream RegModel sequencer and performing no conversion.
//
//| virtual function void build();
//|   reg_seqr = uvm_sequencer #(uvm_reg_bus_item)::type_id::create("reg_seqr",this);
//|   ...
//| endfunction
//|
//| virtual function void connect();
//|   uvm_reg_passthru_adapter reg2reg;
//|   reg2reg = uvm_reg_passthru_adapter::type_id::create("reg2reg");
//|   my_reg_model.default_map.set_sequencer(generic_reg_seqr,reg2reg);
//|   ...
//| endfunction
// 
//------------------------------------------------------------------------------

class uvm_reg_passthru_adapter extends uvm_reg_adapter;

  `uvm_object_utils(uvm_reg_passthru_adapter)

  // Function: reg2bus
  //
  // Returns the ~rw_access~ input argument.

  virtual function uvm_sequence_item reg2bus(uvm_reg_bus_item rw_access);
    return rw_access;
  endfunction


  // Function: bus2reg
  //
  // Copies the contents of the ~bus_item~, which must be of type <uvm_reg_bus_item>,
  // into the provided ~rw_access~ transaction.
  //
  virtual function void bus2reg(uvm_sequence_item bus_item, uvm_reg_bus_item rw_access);
    uvm_reg_bus_item from;
    assert(bus_item!=null);
    if (!$cast(from,bus_item)) begin
      `uvm_error("WRONG_TYPE","Provided bus_item is not of type uvm_reg_bus_item")
      return;
    end
    rw_access.copy(from);
  endfunction


endclass


//------------------------------------------------------------------------------
//
// CLASS: uvm_reg_predictor
//
// This class converts observed bus transactions of type <BUSTYPE> to generic
// registers transactions, determines the register being accessed based on the
// bus address, then updates the register's mirror value with the observed bus
// data, subject to the register's access mode. See <uvm_reg::predict> for details.
//
//------------------------------------------------------------------------------

class uvm_reg_predictor #(type BUSTYPE=int) extends uvm_component;

  `uvm_component_param_utils(uvm_reg_predictor#(BUSTYPE))


  // Variable: bus_in
  //
  // Observed bus transactions of type ~BUSTYPE~ are received from this
  // port and processed.
  // For each incoming transaction, the predictor will attempt to get the
  // register or memory handle corresponding to the observed bus address. 
  // If there is a match, the predictor calls the register or memory's
  // predict method, passing in the observed bus data. The register or
  // memory mirror will be updated with this data, subject to its configured
  // access behavior--RW, RO, WO, etc. The predictor will also convert the
  // bus transaction to a generic <uvm_reg_bus_item> transaction and send it
  // out its ~reg_ap~ analysis port.
  //
  // Note- the predictor currently does not handle multiple bus transactions
  // per logical RegModel transaction, which occurs when the bus width is smaller
  // than the register size.
  //
  uvm_analysis_imp #(BUSTYPE, uvm_reg_predictor #(BUSTYPE)) bus_in;


  // Variable: reg_ap
  //
  // Analysis output port that publishes <uvm_reg_bus_item> transactions
  // converted from bus transactions received on ~bus_in~.
  uvm_analysis_port #(uvm_reg_bus_item) reg_ap;


  // Variable: map
  //
  // The map used to convert a bus address to the corresponding register
  // or memory handle. Must be configured before the run phase.
  // 
  uvm_reg_map map;


  // Variable: adapter
  //
  // The adapter used to convert a bus address to an instance of
  // <uvm_reg_bus_item>. Must be configured before the run phase.
  //
  uvm_reg_adapter adapter;


  // Function: new
  //
  // Create a new instance of this type, giving it the optional ~name~
  // and ~parent~.
  //
  function new (string name, uvm_component parent);
    super.new(name, parent);
    bus_in = new("bus_in", this);
    reg_ap = new("reg_ap", this);
  endfunction


  // Function- write
  //
  // not a user-level method. Do not call directly. See documentation
  // for the ~bus_in~ member.
  //
  virtual function void write(BUSTYPE tr);
    uvm_reg_bus_item rw_access = new;
    uvm_reg rg;
    adapter.bus2reg(tr,rw_access);
    rg = map.get_reg_by_offset(rw_access.addr);
    if (rg != null) begin
      uvm_predict_e predict_kind = 
          (rw_access.kind == UVM_WRITE) ? UVM_PREDICT_WRITE : UVM_PREDICT_READ;
      rw_access.element_kind = UVM_REG;
      rw_access.element = rg;
      rw_access.path = UVM_BFM;
      rw_access.map = map;
      if (!rg.predict(rw_access.data,predict_kind,UVM_BFM))
        `uvm_info("REG_PREDICT_NOT_FOR_ME",{"Observed transaction does not target a register: ",$sformatf("%p",tr)},UVM_FULL)
      else
        reg_ap.write(rw_access);
      return;
    end
    /* Memories can be large, so do not predict. Users can use 
       backdoor peek/poke to update the memory mirror.
    else begin
      uvm_mem mem;
      mem = map.get_mem_by_offset(tr.addr);
      // snoop mem accesses too?
    end
    */
  endfunction

endclass

