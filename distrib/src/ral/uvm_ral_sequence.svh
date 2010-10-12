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
//
// CLASS: uvm_ral_item
//
//------------------------------------------------------------------------------

class uvm_ral_item extends uvm_sequence_item;

  `uvm_object_utils(uvm_ral_item)

  uvm_ral::elem_kind_e      element_kind;  // REG, MEM, or FIELD 
  uvm_object                element;       // handle to reg, field, mem, etc.

  rand uvm_ral::access_e    kind;        // READ, WRITE, MIRROR(READ), UPDATE(WRITE)
  rand uvm_ral_data_t       value;       // data out (write), data in (read)
  rand uvm_ral_addr_t       offset;      // for mems

  uvm_ral::status_e         status;      // access outcome 

  uvm_ral_map               map;      // the map map being used
  uvm_ral::path_e           path;        // the path (BACKDOOR, BFM)

  rand uvm_object           extension;

  function new(string name="");
    super.new(name);
  endfunction

  virtual function string convert2string();
    string s;
    s = {"kind=",kind.name()," ele_kind=",element_kind.name()," ele_name=",element.get_full_name() };
    s = {s, $sformatf(" value=%0h",value)};
    if (element_kind == uvm_ral::MEM)
      s = {s, $sformatf(" offset=%0h",offset)};
    s = {s," map=",(map==null?"null":map.get_full_name())," path=",path.name()};
    s = {s," status=",status.name()};
    return s;
  endfunction

  virtual function void copy(uvm_object rhs);
    uvm_ral_item rhs_;
    assert(rhs != null);
    if (!$cast(rhs_,rhs)) begin
      `uvm_error("WRONG_TYPE","Provided rhs is not of type uvm_ral_item")
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
// CLASS: uvm_rw_access
//
//------------------------------------------------------------------------------

class uvm_rw_access extends uvm_ral_item;

  `uvm_object_utils(uvm_rw_access)

   rand  uvm_ral_addr_t       addr;                        // bus address
   rand  uvm_ral_data_logic_t data;                     // bus data
   rand  int                  n_bits = `UVM_RAL_DATA_WIDTH; // bit width

   rand  uvm_ral_byte_en_t    byte_en = '1;            // if bus supports it

   string                     fname = ""; // file and line from which access originated
   int                        lineno = 0;
   int                        prior = -1;

   constraint valid_uvm_rw_access {
      n_bits > 0;
      n_bits <= `UVM_RAL_DATA_WIDTH;
   }

   function new(string name="");
     super.new(name);
   endfunction

   virtual function string convert2string();
     string s;
     s = super.convert2string();
     s = {s,$sformatf(" [rw_access: addr=%0h data=%0h bits=%0h byte_en=%0h]",
          addr,data,n_bits,byte_en)};
     return s;
   endfunction

   virtual function void copy(uvm_object rhs);
     uvm_rw_access rhs_;
     assert(rhs != null);
     if (!$cast(rhs_,rhs)) begin
       `uvm_error("WRONG_TYPE","Provided rhs is not of type uvm_rw_access")
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

endclass: uvm_rw_access



typedef class uvm_ral_block;

//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_sequence
//
// Register operations do not require extending this class--they can be done
// via the uvm_sequence base class or even from outside a sequence. If used,
// the RAL sequence class (will) provides convenient features for the sequence
// writer wanting to access DUT registers via the RAL abstract model.
//------------------------------------------------------------------------------

class uvm_ral_sequence #(type BASE=uvm_sequence #(uvm_ral_item)) extends BASE;

  `uvm_object_param_utils(uvm_ral_sequence #(BASE))

  uvm_ral_block ral;       // define when this seq is a user seq
  uvm_ral_adapter adapter; // define when this seq is a translation seq

  // define when this seq is a translation seq and we want to "pull" from
  // an upstream RAL sequencer.
  uvm_sequencer #(uvm_rw_access) ral_seqr;

  function new (string name="uvm_ral_sequence_inst");
    super.new(name);
  endfunction

  virtual function void put_response(uvm_sequence_item response_item);
    put_base_response(response_item);
  endfunction

  //TODO: add access API (convenience layer to avoid .parent(this) in each rw)
  //TODO: reflect utility API (e.g. address translation) for user-defined translation sequence

  virtual task body();
    if (ral_seqr == null) begin
      `uvm_warning("RAL_XLATE_NO_SEQR",
         {"RAL translation sequence on sequencer ",
       m_sequencer.get_full_name(),"' does not have an upstream sequencer defined."})
      return;
    end
    assert(m_sequencer != null);
    `uvm_info("RAL_XLATE_SEQ_START",
       {"Starting RAL translation sequence on sequencer ",
       m_sequencer.get_full_name(),"'"},UVM_LOW)
    forever begin
      uvm_rw_access rw_access;
      ral_seqr.peek(rw_access);
      do_rw_access(rw_access);
      ral_seqr.get(rw_access);
      #0;
    end
  endtask

  uvm_sequence_base parent_seq;

  virtual task do_rw_access(uvm_rw_access rw);
    uvm_sequence_item bus_req;
    assert(m_sequencer != null);
    assert(adapter != null);
    `uvm_info("RAL_XLATE_SEQ_START",{"Doing transaction: ",rw.convert2string()},UVM_LOW) // change to HIGH
    
    parent_seq = rw.get_parent_sequence();
    bus_req = adapter.ral2bus(rw);
    bus_req.m_start_item(m_sequencer,this,rw.prior); 
    if (parent_seq != null)
      parent_seq.mid_do(rw);
    bus_req.m_finish_item(m_sequencer,this);
    bus_req.end_event.wait_on();
    if (adapter.provides_responses) begin
      uvm_sequence_item bus_rsp;
      uvm_ral::access_e op;
      get_base_response(bus_rsp);
      adapter.bus2ral(bus_rsp,rw);
    end
    else begin
      adapter.bus2ral(bus_req,rw);
    end
    if (parent_seq != null)
      parent_seq.post_do(rw);
  endtask

/*
  virtual function bit is_relevant();
  $display("\n\n***** %m ");
    if (parent_seq != null)
      return parent_seq.is_relevant();
  endfunction

  virtual task wait_for_relevant();
  $display("\n\n***** %m ");
    if (parent_seq != null)
      parent_seq.wait_for_relevant();
  endtask
*/
endclass


                                                              
//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_adapter
//
//------------------------------------------------------------------------------

virtual class uvm_ral_adapter extends uvm_object;

  //`uvm_object_utils(uvm_ral_adapter)

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
  // separate response items. If set, the <bus2ral> method must be
  // implemented.

  bit provides_responses; 


  // Function: ral2bus
  //
  // Extensions of this class ~must~ implement this method to adapter a
  // ~ral_item~ to the <sequence_item> that defines the bus transaction.
  // The method should allocate a new bus item, assign its members from
  // the corresponding members in the ral item, then return it. The bus
  // item gets returned in a <uvm_sequence_item> base handle.

  pure virtual function uvm_sequence_item ral2bus(uvm_rw_access rw_access);


  // Function: ral2bus
  //
  // Extensions of this class ~must~ implement this method to copy members
  // of the given ~bus_item~ to corresponding members of the provided
  // ~ral_item~. The ~bus_item~ is passed via a <uvm_sequence_item> base
  // handle, so it must be $cast to actual bus item type.

  pure virtual function void bus2ral(uvm_sequence_item bus_item, uvm_rw_access rw_access);

endclass


//------------------------------------------------------------------------------
// Group: Example
//
// The following example illustrates how to implement a RAL-BUS adapter class
// for the APB bus protocol.
//
//|class ral_apb_adapter extends uvm_ral_adapter;
//|  `uvm_object_utils(ral_apb_adapter)
//|
//|  virtual function uvm_sequence_item ral2bus(uvm_rw_access ral_access);
//|    apb_item apb = apb_item::type_id::create("apb_item");
//|    apb.op   = (ral_access.kind == uvm_ral::READ) ? apb::READ : apb::WRITE;
//|    apb.addr = ral_access.addr;
//|    apb.data = ral_access.data;
//|  endfunction
//|
//|  virtual function void bus2ral(uvm_sequencer_item bus_item,
//|                                uvm_ral_access ral_access);
//|    apb_item apb;
//|    if (!$cast(apb,bus_item)) begin
//|      `uvm_fatal("CONVERT_APB2RAL","Provided bus_item is not of type apb_item")
//|    end
//|    ral_access.kind  = apb.op == apb::READ ? uvm_ral::READ : uvm_ral::WRITE;
//|    ral_access.addr = apb.addr;
//|    ral_access.data = apb.data;
//|  endfunction
//|
//|endclass


//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_passthru_adapter
//
//------------------------------------------------------------------------------

class uvm_ral_passthru_adapter extends uvm_ral_adapter;

  `uvm_object_utils(uvm_ral_passthru_adapter)

  virtual function uvm_sequence_item ral2bus(uvm_rw_access rw_access);
    return rw_access;
  endfunction

  virtual function void bus2ral(uvm_sequence_item bus_item, uvm_rw_access rw_access);
    uvm_rw_access from;
    assert(bus_item!=null);
    if (!$cast(from,bus_item)) begin
      `uvm_error("WRONG_TYPE","Provided bus_item is not of type uvm_rw_access")
      return;
    end
    rw_access.copy(from);
  endfunction


endclass


//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_predictor
//
//------------------------------------------------------------------------------

// move to base library
class uvm_ral_predictor #(type BUSTYPE=int) extends uvm_component;

  uvm_analysis_imp #(BUSTYPE, uvm_ral_predictor #(BUSTYPE)) xbus_in;
  uvm_analysis_port #(uvm_rw_access) ral_ap;

  uvm_ral_map map;
  uvm_ral_adapter adapter;

  `uvm_component_param_utils(uvm_ral_predictor#(BUSTYPE))

  function new (string name, uvm_component parent);
    super.new(name, parent);
    xbus_in = new("xbus_in", this);
    ral_ap = new("ral_ap", this);
  endfunction

  function void set_adapter(uvm_ral_adapter adapter);
    this.adapter = adapter;
  endfunction

  virtual function void write(BUSTYPE tr);
    uvm_rw_access rw_access = new;
    uvm_ral_reg rg;
    adapter.bus2ral(tr,rw_access);
    rg = map.get_reg_by_offset(rw_access.addr);
    if (rg != null) begin
      uvm_ral::predict_e predict_kind = 
          (rw_access.kind == uvm_ral::WRITE) ? uvm_ral::PREDICT_WRITE : uvm_ral::PREDICT_READ;
      rw_access.element_kind = uvm_ral::REG;
      rw_access.element = rg;
      rw_access.path = uvm_ral::BFM;
      rw_access.map = map;
      if (!rg.predict(rw_access.data,predict_kind,uvm_ral::BFM))
        `uvm_info("RAL_PREDICT_NOT_FOR_ME",{"Observed transaction does not target a register: ",$sformatf("%p",tr)},UVM_FULL)
      else
        ral_ap.write(rw_access);
      return;
    end
    /*
    else begin
      uvm_ral_mem mem;
      mem = map.get_mem_by_offset(tr.addr);
      // snoop mem accesses too?
    end
    */
  endfunction

endclass

