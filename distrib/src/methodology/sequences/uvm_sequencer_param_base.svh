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


//------------------------------------------------------------------------------
//
// CLASS: uvm_sequencer_param_base #(REQ,RSP)
//
// Provides base functionality used by the uvm_sequencer and uvm_push_sequencer.
// The implementation is dependent on REQ and RSP parameters.
//------------------------------------------------------------------------------

class uvm_sequencer_param_base #(type REQ = uvm_sequence_item,
                                 type RSP = REQ) extends uvm_sequencer_base;

  typedef uvm_sequencer_param_base #( REQ , RSP) this_type;

//    static bit sequences[string] = '{default:0};

  REQ m_last_req_buffer[$];
  RSP m_last_rsp_buffer[$];

  protected int m_num_last_reqs = 1;
  protected int num_last_items = m_num_last_reqs;
  protected int m_num_last_rsps = 1;
  protected int m_num_reqs_sent = 0;
  protected int m_num_rsps_received = 0;


  // Port: rsp_export
  //
  // This is the analysis export used by drivers or monitors to send responses
  // to the sequencer.  When a driver wishes to send a response, it may do so
  // through exactly one of three methods:
  //
  //|  seq_item_port.item_done(response)
  //|  seq_item_done.put(response)
  //|  rsp_port.write(response)
  //
  // The rsp_port in the driver and/or monitor must be connected to the
  // rsp_export in this sequencer in order to send responses through the
  // response analysis port.
  
  uvm_analysis_export #(RSP) rsp_export;


  uvm_sequencer_analysis_fifo #(RSP) sqr_rsp_analysis_fifo;

  // Variable- m_req_fifo
  //
  // Fifo for handing reqests between scenario and driver.
  // Should be declared local.

  uvm_tlm_fifo #(REQ) m_req_fifo;
  

  // Function: new
  //
  // Creates and initializes an instance of this class using the normal 
  // constructor arguments for uvm_component: name is the name of the instance,
  // and parent is the handle to the hierarchical parent, if any.

  function new (string name, uvm_component parent);
    super.new(name, parent);

    rsp_export              = new("rsp_export", this);
    sqr_rsp_analysis_fifo   = new("sqr_rsp_analysis_fifo", this);
    sqr_rsp_analysis_fifo.print_enabled = 0;
    m_req_fifo              = new("req_fifo", this);
    m_req_fifo.print_enabled = 0;
  endfunction // new
  

  // Function- do_print
  //
  function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_field("num_last_reqs", m_num_last_reqs, $bits(m_num_last_reqs), UVM_DEC);
    printer.print_field("num_last_rsps", m_num_last_rsps, $bits(m_num_last_rsps), UVM_DEC);
  endfunction


  // Function- connect
  //
  function void connect();
    rsp_export.connect(sqr_rsp_analysis_fifo.analysis_export);
  endfunction // void


  // Function- build
  //
  virtual function void build();
    super.build();
    sqr_rsp_analysis_fifo.sequencer_ptr = this;
  endfunction // function
  
  
  //
  //
  // Methods available to Sequencers
  // 
  //
  
  
  // Function: send_request
  //
  // The send_request function may only be called after a wait_for_grant call.
  // This call will send the request item, t,  to the sequencer pointed to by
  // sequence_ptr. The sequencer will forward it to the driver. If rerandomize
  // is set, the item will be randomized before being sent to the driver.

  virtual function void send_request(uvm_sequence_base sequence_ptr, uvm_sequence_item t, bit rerandomize = 0);
    REQ param_t;

    if (sequence_ptr == null) begin
      uvm_report_fatal("SNDREQ", "Send request sequence_ptr is null", UVM_NONE);
    end

    if (sequence_ptr.m_wait_for_grant_semaphore < 1) begin
      uvm_report_fatal("SNDREQ", "Send request called without wait_for_grant", UVM_NONE);
    end
    sequence_ptr.m_wait_for_grant_semaphore--;
    
    if ($cast(param_t, t)) begin
      if (rerandomize == 1) begin
        if (!param_t.randomize()) begin
          uvm_report_warning("SQRSNDREQ", "Failed to rerandomize sequence item in send_request");
        end
      end
      if (param_t.get_transaction_id() == -1) begin
        param_t.set_transaction_id(sequence_ptr.m_next_transaction_id++);
      end
      m_last_req_push_front(param_t);
    end else begin
      uvm_report_fatal(get_name(),$psprintf("send_request failed to cast sequence item"), UVM_NONE);
//      $display("\nparam_t: %p\n\nt: %p\n\n", param_t, t);
    end

    param_t.set_sequence_id(sequence_ptr.m_get_sqr_sequence_id(m_sequencer_id, 1));
    t.set_sequencer(this);
    if (m_req_fifo.try_put(param_t) != 1) begin
      uvm_report_fatal(get_full_name(), 
                       $psprintf("Sequencer send_request not able to put to fifo, depth; %0d", m_req_fifo.size()), UVM_NONE);
    end

    m_num_reqs_sent++;
    // Grant any locks as soon as possible
    grant_queued_locks();
  endfunction


  // Function: get_current_item
  //
  // Returns the request_item currently being executed by the sequencer. If the
  // sequencer is not currently executing an item, this method will return null.
  //
  // The sequencer is executing an item from the time that get_next_item or peek
  // is called until the time that get or item_done is called.
  //
  // Note that a driver that only calls get() will never show a current item,
  // since the item is completed at the same time as it is requsted.
    
  function REQ get_current_item();
    REQ t;

    if (m_req_fifo.try_peek(t) == 0) begin
      return (null);
    end
    return(t);
  endfunction // REQ


  // Function- put_response
  //
  // private

  function void put_response (RSP t);
    uvm_sequence_base sequence_ptr;
    
    if (t == null) begin
      uvm_report_fatal("SQRPUT", "Driver put a null response", UVM_NONE);
    end

    m_last_rsp_push_front(t);
    m_num_rsps_received++;

    // Check that set_id_info was called
    if (t.get_sequence_id() == -1) begin
`ifndef CDNS_NO_SQR_CHK_SEQ_ID
      uvm_report_fatal("SQRPUT", "Driver put a response with null sequence_id", UVM_NONE);
`endif
      return;
    end
      
    sequence_ptr = find_sequence(t.get_sequence_id());

    if (sequence_ptr != null) begin
      // If the response_handler is enabled for this sequence, then call the response handler
      if (sequence_ptr.get_use_response_handler() == 1) begin
        sequence_ptr.response_handler(t);
        return;
      end
      
      sequence_ptr.put_response(t);
    end
    else begin
      uvm_report_info("Sequencer", 
                      $psprintf("Dropping response for sequence %0d, sequence not found.  Probable cause: sequence exited or has been killed", 
                                t.get_sequence_id()));
    end
  endfunction // void
  

  // Function- analysis_write
  //
  // Do not call directly except by overrides in derived classes

  virtual function void analysis_write(uvm_sequence_item t);
    RSP response;

    if (!$cast(response, t)) begin
      uvm_report_fatal("ANALWRT", "Failure to cast analysis port write item", UVM_NONE);
    end
    put_response(response);
  endfunction
  

  // Task: start_default_sequence
  //
  // Called when the run phase begins, this method starts the default sequence,
  // as specified by the default_sequence member variable.

  virtual task start_default_sequence();
    uvm_sequence_base m_seq ;

    if(sequences.size() == 2 && sequences[0] == "uvm_random_sequence" &&
       sequences[1] == "uvm_exhaustive_sequence") begin
      uvm_report_warning("NOUSERSEQ",
                         "No user sequence available.  Not starting the default sequence.",
                         UVM_NONE);
      return;
    end
    
    if(sequences.size() != 0) begin
      //create the sequence object
      if (!$cast(m_seq, factory.create_object_by_name(default_sequence, 
                                                   get_full_name(), default_sequence))) 
        begin
          uvm_report_fatal("FCTSEQ", 
                           $psprintf("Default sequence set to invalid value : %0s.", 
                                     default_sequence), UVM_NONE);
        end

      if (m_seq == null) begin
        uvm_report_fatal("STRDEFSEQ", "Null m_sequencer reference", UVM_NONE);
      end
      m_seq.print_sequence_info = 1;
      m_seq.set_parent_sequence(null);
      m_seq.set_sequencer(this);
      m_seq.reseed();
      if (!m_seq.randomize()) begin
        uvm_report_warning("STRDEFSEQ", "Failed to randomize sequence");
      end
      if(count != 0)
        m_seq.start(this);
    end
  endtask



  // Task- run
  //
  // Do not call directly except by overrides in derived classes

  task run();
    start_default_sequence();
  endtask // run


  // Function: get_num_reqs_sent
  //
  // Returns the number of requests that have been sent by this sequencer.

  function int get_num_reqs_sent();
    return m_num_reqs_sent;
  endfunction


  // Function: get_num_rsps_received
  //
  // Returns the number of responses received thus far by this sequencer.

  function int get_num_rsps_received();
    return m_num_rsps_received;
  endfunction


  // Function: set_num_last_reqs
  //
  // Sets the size of the last_requests buffer.  Note that the maximum buffer
  // size is 1024.  If max is greater than 1024, a warning is issued, and the
  // buffer is set to 1024.  The default value is 1.

  function void set_num_last_reqs(int unsigned max);
    if(max > 1024) begin
      uvm_report_warning("HSTOB", 
        $psprintf("Invalid last size; 1024 is the maximum and will be used"));
      max = 1024;
    end

    //shrink the buffer
    while((m_last_req_buffer.size() != 0) && (m_last_req_buffer.size() > max)) begin
      void'(m_last_req_buffer.pop_back());
    end

    m_num_last_reqs = max;
    num_last_items = max;

  endfunction


  // Function: get_num_last_reqs
  //
  // Returns the size of the last requests buffer, as set by set_num_last_reqs.

  function int unsigned get_num_last_reqs();
    return m_num_last_reqs;
  endfunction


  // Function: last_req
  //
  // Returns the last request item by default.  If n is not 0, then it will get
  // the n¿th before last request item.  If n is greater than the last request
  // buffer size, the function will return null.

  function REQ last_req(int unsigned n = 0);
    if(n > m_num_last_reqs) begin
      uvm_report_warning("HSTOB",
        $psprintf("Invalid last access (%0d), the max history is %0d", n,
        m_num_last_reqs));
      return null;
    end
    if(n == m_last_req_buffer.size())
      return null;
  
    return m_last_req_buffer[n];
  endfunction
  

  // Function- m_last_req_push_front
  //
  // private

  function void m_last_req_push_front(REQ item);
    if(!m_num_last_reqs)
      return;
 
    if(m_last_req_buffer.size() == m_num_last_reqs)
      void'(m_last_req_buffer.pop_back());

    this.m_last_req_buffer.push_front(item);
  endfunction

  
  // Function: set_num_last_rsps
  //
  // Sets the size of the last_responses buffer.  The maximum buffer size is
  // 1024. If max is greater than 1024, a warning is issued, and the buffer is
  // set to 1024.  The default value is 1.

  function void set_num_last_rsps(int unsigned max);
    if(max > 1024) begin
      uvm_report_warning("HSTOB", 
        $psprintf("Invalid last size; 1024 is the maximum and will be used"));
      max = 1024;
    end

    //shrink the buffer
    while((m_last_rsp_buffer.size() != 0) && (m_last_rsp_buffer.size() > max)) begin
      void'(m_last_rsp_buffer.pop_back());
    end

    m_num_last_rsps = max;

  endfunction


  // Function: get_num_last_rsps
  //
  // Returns the max size of the last responses buffer, as set by
  // set_num_last_rsps.

  function int unsigned get_num_last_rsps();
    return m_num_last_rsps;
  endfunction


  // Function: last_rsp
  //
  // Returns the last response item by default.  If n is not 0, then it will
  // get the nth-before-last response item.  If n is greater than the last
  // response buffer size, the function will return null.

  function RSP last_rsp(int unsigned n = 0);
    if(n > m_num_last_rsps) begin
      uvm_report_warning("HSTOB",
        $psprintf("Invalid last access (%0d), the max history is %0d", n,
        m_num_last_rsps));
      return null;
    end
    if(n == m_last_rsp_buffer.size())
      return null;
  
    return m_last_rsp_buffer[n];
  endfunction
  

  // Function- m_last_rsp_push_front
  // 
  // private

  function void m_last_rsp_push_front(RSP item);
    if(!m_num_last_rsps)
      return;
 
    if(m_last_rsp_buffer.size() == m_num_last_rsps)
      void'(m_last_rsp_buffer.pop_back());

    this.m_last_rsp_buffer.push_front(item);
  endfunction

 
  // Task: execute_item
  //
  // This task allows the user to supply an item or sequence to the sequencer
  // and have it be executed procedurally. The parent sequence for the item or
  // sequence is a temporary sequence that is automatically created.  There is
  // no capability to retrieve responses.  The sequencer will drop responses to
  // items done using this interface.

  virtual task execute_item(uvm_sequence_item item);
    uvm_sequence_base temp_seq;
    
    temp_seq = new();
    item.set_sequencer(this);
    item.set_parent_sequence(temp_seq);
    temp_seq.set_sequencer(this);
    temp_seq.start_item(item);
    temp_seq.finish_item(item);
  endtask // execute_item


  // Function- m_add_builtin_seqs
  //
  // private

  virtual function void m_add_builtin_seqs(bit add_simple = 1);
    if(!sequence_ids.exists("uvm_random_sequence"))
      add_sequence("uvm_random_sequence");
    if(!sequence_ids.exists("uvm_exhaustive_sequence"))
      add_sequence("uvm_exhaustive_sequence");
    if(add_simple == 1)
      if(!sequence_ids.exists("uvm_simple_sequence"))
        add_sequence("uvm_simple_sequence");
  endfunction

endclass

  

