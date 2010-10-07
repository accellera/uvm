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
