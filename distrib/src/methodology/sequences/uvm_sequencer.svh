//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc. 
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


  typedef class uvm_sequence_base;

  typedef uvm_seq_item_pull_port #(uvm_sequence_item, uvm_sequence_item) uvm_seq_item_prod_if;


//------------------------------------------------------------------------------
//
// CLASS: uvm_sequencer #(REQ,RSP)
//
//------------------------------------------------------------------------------

class uvm_sequencer #(type REQ = uvm_sequence_item,
                      type RSP = REQ) extends uvm_sequencer_param_base #(REQ, RSP);

  typedef uvm_sequencer #( REQ , RSP) this_type;
  bit     sequence_item_requested = 0;
  bit     get_next_item_called    = 0;


  // Variable: seq_item_export
  //
  // This export provides access to this sequencer's implementation of the
  // sequencer interface, <sqr_if_base #(REQ,RSP)>, which defines the following
  // methods:
  //
  //|  virtual task          get_next_item      (output REQ request);
  //|  virtual task          try_next_item      (output REQ request);
  //|  virtual function void item_done          (input RSP response=null);
  //|  virtual task          wait_for_sequences ();
  //|  virtual function bit  has_do_available   ();
  //|  virtual task          get                (output REQ request);
  //|  virtual task          peek               (output REQ request);
  //|  virtual task          put                (input RSP response);
  //
  // See <sqr_if_base #(REQ,RSP)> for information about this interface.

  uvm_seq_item_pull_imp #(REQ, RSP, this_type) seq_item_export;


  // Function: new
  //
  // Creates and initializes an instance of this class using the normal
  // constructor arguments for uvm_component: name is the name of the instance,
  // and parent is the handle to the hierarchical parent, if any.

  function new (string name, uvm_component parent);
    super.new(name, parent);

    seq_item_export         = new ("seq_item_export", this);
  endfunction // new
  
  // return proper type name string
  virtual function string get_type_name();
    return "uvm_sequencer";
  endfunction 

  function void connect();
    super.connect();
  endfunction // void

  virtual function void build();
    super.build();
  endfunction // function
  
  // Counting the number of of connections is done at end of
  // elaboration and the start of run.  If the user neglects to
  // call super in one or the other, the sequencer will still
  // have the correct value

  protected virtual function int  m_find_number_driver_connections();
    uvm_port_component_base provided_to_port_list[string];
    uvm_port_component_base seq_port_base;
    
    // Check that the seq_item_pull_port is connected
    seq_port_base = seq_item_export.get_comp();
    seq_port_base.get_provided_to(provided_to_port_list);
    return(provided_to_port_list.num());
  endfunction

  // Function: stop_sequences
  //
  // Tells the sequencer to kill all sequences and child sequences currently
  // operating on the sequencer, and remove all requests, locks and responses
  // that are currently queued.  This essentially resets the sequencer to an
  // idle state.

  virtual function void stop_sequences();
    REQ t;
    int reported  = 0;
    
    super.stop_sequences();
    sequence_item_requested  = 0;
    get_next_item_called     = 0;
    // Empty the request fifo
    while (m_req_fifo.try_get(t)) begin
      if (reported == 0) begin
        uvm_report_info(get_full_name(), "Sequences stopped.  Removing request from sequencer fifo");
        reported  = 1;
      end
//      void'(m_req_fifo.try_get(t));
    end
  endfunction // stop_sequences

  //============================================================================
  //
  // Internal Methods - do not use directly; they are subject to change or
  //                    elimination.
  //
  //============================================================================

  // Task- select_sequence

  local task select_sequence();
    int selected_sequence;

    // Select a sequence
    do begin
      wait_for_sequences();
      selected_sequence = choose_next_request();
      if (selected_sequence == -1) begin
        wait_for_available_sequence();
      end
    end while (selected_sequence == -1);
    // issue grant
    if (selected_sequence >= 0) begin
      set_arbitration_completed(arb_sequence_q[selected_sequence].request_id);
      arb_sequence_q.delete(selected_sequence);
      m_update_lists();
    end
  endtask // select_sequence


  // Task- get_next_item
  //
  // private- access only via seq_item_export

  virtual task get_next_item(output REQ t);
    REQ     req_item;

    // If a sequence_item has already been requested, then get_next_item()
    // should not be called again until item_done() has been called.

    if (get_next_item_called == 1) begin
      uvm_report_error(get_full_name(), "Get_next_item called twice without item_done or get in between", UVM_NONE);
    end
    
    if (sequence_item_requested == 0) begin
      select_sequence();
    end

    // Set flag indicating that the item has been requested to ensure that item_done or get
    // is called between requests
    sequence_item_requested = 1;
    get_next_item_called = 1;
    m_req_fifo.peek(t);
  endtask // get_next_item


  // Task- try_next_item
  //
  // private- access only via seq_item_export

  virtual task try_next_item(output REQ t);
    wait_for_sequences();
    if (has_do_available() == 0) begin
      t = null;
      return;
    end
    get_next_item(t);
  endtask // try_next_item



  // Function- item_done
  //
  // private- access only via seq_item_export

  virtual function void item_done(RSP item = null);
    REQ t;

    // Set flag to allow next get_next_item or peek to get a new sequence_item
    sequence_item_requested = 0;
    get_next_item_called = 0;
    
    if (m_req_fifo.try_get(t) == 0) begin
      uvm_report_fatal(get_full_name(), "Item done reports empty request fifo", UVM_NONE);
    end else begin
      m_wait_for_item_sequence_id = t.get_sequence_id();
      m_wait_for_item_transaction_id = t.get_transaction_id();
    end
    
    if (item != null) begin
      seq_item_export.put_response(item);
    end

    // Grant any locks as soon as possible
    grant_queued_locks();
  endfunction // void


  // Task- put
  //
  // private- access only via seq_item_export

  virtual task put (RSP t);
    put_response(t);
  endtask // put


  // Task- get
  //
  // private- access only via seq_item_export

  task get(output REQ t);
    if (sequence_item_requested == 0) begin
      select_sequence();
    end
    sequence_item_requested = 1;
    m_req_fifo.peek(t);
    item_done();
  endtask // get


  // Task- peek
  //
  // private- access only via seq_item_export

  task peek(output REQ t);

    if (sequence_item_requested == 0) begin
      select_sequence();
    end
    
    // Set flag indicating that the item has been requested to ensure that item_done or get
    // is called between requests
    sequence_item_requested = 1;
    m_req_fifo.peek(t);
  endtask // peek


  // Function- item_done_trigger
  //
  // private - backwards compatibility

  function void item_done_trigger(RSP item = null);
    item_done(item);
  endfunction


  // Function- item_done_get_trigger_data
  //
  // private

  function RSP item_done_get_trigger_data();
    return last_rsp(0);
  endfunction

endclass  

typedef uvm_sequencer #(uvm_sequence_item) uvm_virtual_sequencer;

