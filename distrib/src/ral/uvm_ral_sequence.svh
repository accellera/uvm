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
// This class provides base functionality for both user-defined RAL test
// sequences and "register translation sequences".
//
// - When used as a base for user-defined RAL test sequences, this class
//   provides convenience methods for reading and writing registers and
//   memories. Users implement the body() method to interact directly with
//   the RAL model (held in the <ral> property) or indirectly via the
//   delegation methods in this class. 
//
// - When used as a translation sequence, objects of this class are
//   executed directly on a bus sequencerwhich are used in support of a layered sequencer
//   use model, a pre-defined convert-and-execute algorithm is provided.
//
// Register operations do not require extending this class if none of the above
// services are needed. Register test sequences can be extend from the base
// <uvm_sequence #(REQ,RSP)> base class or even from outside a sequence. 
//
// Note- The convenience API not yet implemented.
//------------------------------------------------------------------------------

class uvm_ral_sequence #(type BASE=uvm_sequence #(uvm_rw_access)) extends BASE;

  `uvm_object_param_utils(uvm_ral_sequence #(BASE))

  // Parameter: BASE
  //
  // Specifies the sequence type to extend from.
  //
  // When used as a translation sequence running on a bus sequencer, ~BASE~ must
  // be compatible with the sequence type expected by the bus sequencer.
  //
  // When used as a test sequence running on a particular sequencer, ~BASE~
  // must be compatible with the sequence type expected by that sequencer.
  //
  // When used as a virtual test sequence without a sequencer, ~BASE~ does
  // not need to be specified, i.e. the default specialization is adequate.
  // 
  // To maximize opportunities for reuse, user-defined RAL sequences should
  // "promote" the BASE parameter to its own class.
  //
  // | class my_ral_sequence #(type BASE=uvm_sequence #(uvm_ral_item))
  // |                               extends uvm_ral_sequence #(BASE);
  //
  // This way, the RAL sequence can be extended from ~any~ sequence, including
  // user-defined base sequences, and can run on ~any~ sequencer.


  // Variable: ral
  //
  // Block abstraction this sequence executes on, defined only when this
  // sequence is a user-defined test sequence.
  //
  uvm_ral_block ral;


  // Variable: adapter
  //
  // Adapter to use for translating between abstract register transactions
  // and physical bus transactions, defined only when this sequence is a
  // translation sequence.
  //
  uvm_ral_adapter adapter;


  // Variable: ral_seqr
  //
  // The upstream sequencer  between abstract register transactions
  // and physical bus transactions, defined only when this sequence is a
  // translation sequence.
  // Layered upstream "register" sequencer.
  // Define when this sequence is a translation sequence
  // and we want to "pull" from an upstream sequencer.
  //
  uvm_sequencer #(uvm_rw_access) ral_seqr;


  // Function: new
  //
  // Create a new instance, giving it the optional ~name~.
  //
  function new (string name="uvm_ral_sequence_inst");
    super.new(name);
  endfunction


  // Task: body
  //
  // Continually gets a register transaction from the configured upstream
  // sequencer, <ral_seqr>, and executes the corresponding bus transaction
  // via <do_rw_access>. 
  //
  // User-defined RAL test sequences must override body() and not call
  // super.body(), else a warning will be issued and the calling process
  // not return.
  //
  virtual task body();
    if (m_sequencer == null) begin
      `uvm_fatal("NO_SEQR", {"Sequence executing as translation sequence, ",
         "but is not associated with a sequencer (m_sequencer == null)"})
    end
    if (ral_seqr == null) begin
      `uvm_warning("RAL_XLATE_NO_SEQR",
         {"Executing RAL translation sequence on sequencer ",
       m_sequencer.get_full_name(),"' does not have an upstream sequencer defined. ",
       "Execution of register items available only via direct calls to 'do_rw_access'"})
      wait(0);
    end
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


  local uvm_sequence_base parent_seq;


  // Function: do_rw_access
  //
  // Executes the given register transaction, ~rw~, via the sequencer on
  // which this sequence was started (i.e. m_sequencer). Uses the configured
  // <adapter> to convert the register transaction into the type expected by
  // this sequencer.
  //
  virtual task do_rw_access(uvm_rw_access rw);
    uvm_sequence_item bus_req;
    assert(m_sequencer != null);
    assert(adapter != null);
    `uvm_info("RAL_XLATE_SEQ_START",{"Doing transaction: ",rw.convert2string()},UVM_HIGH)
    
    parent_seq = rw.get_parent_sequence();
    bus_req = adapter.ral2bus(rw);
    bus_req.m_start_item(m_sequencer,this,rw.prior); 
    if (parent_seq != null) begin
      parent_seq.pre_do(1);
      parent_seq.mid_do(rw);
    end
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



  // Function- put_response
  //
  // not user visible. Needed to populate this sequence's response
  // queue with any bus item type. 
  //
  virtual function void put_response(uvm_sequence_item response_item);
    put_base_response(response_item);
  endfunction


/*
  // Task: pre_do
  //
  // When running on a downstream sequencer as a translation sequence, all
  // calls to ~pre_do~ by the downstream sequencer will be forwarded
  // to the originating RAL sequence running on the upstream sequencer.
  // Users may override ~pre_do~ to customize or disable this behavior.
  //
  //
  virtual task pre_do(bit is_item);
    if (parent_seq != null)
      parent_seq.pre_do(is_item);
  endtask


  // Function: mid_do
  //
  // When running on a downstream sequencer as a translation sequence, all
  // calls to ~mid_do~ by the downstream sequencer will be forwarded
  // to the originating RAL sequence running on the upstream sequencer.
  // Users may override ~mid_do~ to customize or disable this behavior.
  //
  //
  virtual function void mid_do(uvm_sequence_item this_item);
    if (parent_seq != null)
      parent_seq.mid_do(this_item);
  endfunction


  // Function: post_do
  //
  // When running on a downstream sequencer as a translation sequence, all
  // calls to ~post_do~ by the downstream sequencer will be forwarded
  // to the originating RAL sequence running on the upstream sequencer.
  // Users may override ~post_do~ to customize or disable this behavior.
  //
  //
  virtual function void post_do(uvm_sequence_item this_item);
    if (parent_seq != null)
      return parent_seq.post_do(this_item);
  endfunction


  // Function: is_relevant
  //
  // When running on a downstream sequencer as a translation sequence, all
  // calls to ~is_relevant~ by the downstream sequencer will be forwarded
  // to the originating RAL sequence running on the upstream sequencer.
  // Users may override ~is_relevant~ to customize or disable this behavior.
  //
  virtual function bit is_relevant();
    if (parent_seq != null)
      return parent_seq.is_relevant();
  endfunction


  // Function: wait_for_relevant
  //
  // When running on a downstream sequencer as a translation sequence, all
  // calls to ~wait_for_relevant~ by the downstream sequencer are forwarded
  // to the originating RAL sequence running on the upstream sequencer.
  // Users may override ~wait_for_relevant~ to customize or disable this
  // behavior.
  //
  virtual task wait_for_relevant();
    if (parent_seq != null)
      parent_seq.wait_for_relevant();
  endtask

*/
endclass
