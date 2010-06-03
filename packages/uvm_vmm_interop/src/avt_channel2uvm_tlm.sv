//------------------------------------------------------------------------------
// Copyright 2008 Mentor Graphics Corporation
// Copyright 2010 Synopsys, Inc.
//
// All Rights Reserved Worldwide
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License.  You may obtain
// a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//------------------------------------------------------------------------------

class avt_match_uvm_id;

  static function bit match(uvm_sequence_item req,
                          uvm_sequence_item rsp);
     return req.get_sequence_id() == rsp.get_sequence_id() &&
            req.get_transaction_id() == rsp.get_transaction_id();
  endfunction

endclass

//------------------------------------------------------------------------------
//
// CLASS: avt_channel2uvm_tlm
//
//------------------------------------------------------------------------------
//
// Use this class to connect a VMM producer to an UVM consumer.
// Consumers can implement many different response-delivery models:
//
// - does not return a response
//
// - returns a response via a separate TLM port
//
// - embeds a response in the original request transaction, which is available
//   to a requester that holds a handle to the original request.
//
// The adapter can accommodate these consumer types.
//
//   (see avt_channel2uvm_tlm.gif)
//
// To use this adapter, the integrator instantiates a VMM producer, an UVM
// consumer, and an <avt_channel2uvm_tlm> adapter whose parameter values correspond
// to the VMM and UVM data types used by the producer and consumer and the
// converter types used to translate in one or both directions.
//
// If the default vmm_channels created by the VMM producer or adapter are not
// used, then the integrator must also instantiate a request vmm_channel and
// possibly a response vmm_channel, if the VMM producer uses one.
//
// Integrators of VMM-on-top environments need to instantiate the UVM consumer
// and adapter via an UVM container, or wrapper component. This wrapper
// component serves to provide the connect method needed to bind the UVM ports
// and exports.
//
// See also <avt_channel2uvm_tlm example> and <avt_channel2uvm_tlm seq_item example>.
//
//------------------------------------------------------------------------------

class avt_channel2uvm_tlm #(type VMM_REQ     = int,
                             UVM_REQ     = int,
                             VMM2UVM_REQ = int,
                             UVM_RSP     = UVM_REQ,
                             VMM_RSP     = VMM_REQ,
                             UVM2VMM_RSP = avt_converter #(UVM_RSP,VMM_RSP),
                             UVM_MATCH_REQ_RSP=avt_match_uvm_id)
                                              extends uvm_component;

   typedef avt_channel2uvm_tlm #(VMM_REQ, UVM_REQ, VMM2UVM_REQ,
                             UVM_RSP, VMM_RSP, UVM2VMM_RSP,
                             UVM_MATCH_REQ_RSP) this_type;

   `uvm_component_param_utils(this_type)


   // Port: seq_item_export
   //
   // Used by UVM driver consumers using the sequencer interface to
   // process transactions.  See <sqr_if_base #(REQ,RSP)> for information about
   // this interface.
   uvm_seq_item_pull_imp #(UVM_REQ, UVM_RSP, this_type) seq_item_export;

   // Port: get_peek_export
   //
   // For UVM consumers getting requests via peek/get
   uvm_get_peek_imp #(UVM_REQ, this_type) get_peek_export;

   // Port: response_export
   //
   // For UVM consumers returning responses via analysis write
   uvm_analysis_imp #(UVM_RSP, this_type) response_export;

   // Port: put_export
   //
   // For UVM consumers returning responses via blocking put
   uvm_put_imp #(UVM_RSP, this_type) put_export;

   // Port: slave_export
   //
   // For sending requests to passive UVM consumers via blocking put
   uvm_slave_imp #(UVM_REQ, UVM_RSP, this_type) slave_export;

   // Port: blocking_put_port
   //
   // For sending requests to ~passive~ UVM consumers via blocking put
   uvm_blocking_put_port #(UVM_RSP) blocking_put_port;

   // Port: blocking_transport_port
   //
   // For atomic execution with ~passive~ UVM consumers via blocking transport
   uvm_blocking_transport_port #(UVM_REQ, UVM_RSP) blocking_transport_port;


   // Port: blocking_master_port
   //
   // For driving a passive UVM consumers via blocking master interface
    uvm_blocking_master_port #(UVM_REQ, UVM_RSP) blocking_master_port;


   // Port: request_ap
   //
   // All requests are broadcast out this analysis port after successful
   // extraction from the request vmm_channel.
   uvm_analysis_port #(UVM_REQ) request_ap;


   // Port: response_ap
   //
   // All responses sent to the response channel are broadcast out this
   // analysis port.
   uvm_analysis_port #(UVM_RSP) response_ap;


   // Function: new
   //
   // Creates an instance of a avt_channel2uvm_tlm adaptor, with four optional
   // arguments.
   //
   // name     - specifies the instance name. Default is "avt_channel2uvm_tlm".
   //
   // parent   - specfies the parent uvm_component, if any. When null, the
   //            parent becomes the implicit uvm_top.
   //
   // req_chan - the request vmm_channel instance. If not specified, it must be
   //            assigned directory to the <req_chan> variable before
   //            end_of_elaboration.
   //
   // req_chan - the request vmm_channel instance. If not specified, it must be
   //            assigned directory to the <req_chan> variable before
   //            end_of_elaboration.

   function new (string name="avt_channel2uvm_tlm",
                 uvm_component parent=null,
                 vmm_channel_typed #(VMM_REQ) req_chan=null,
                 vmm_channel_typed #(VMM_RSP) rsp_chan=null,
                 bit rsp_is_req=1,
                 int unsigned max_pending_req=100);
      super.new(name,parent);
      // For active UVM producers
      seq_item_export = new("seq_item_export",this);
      get_peek_export = new("get_peek_export",this);
      response_export = new("response_export",this);
      put_export      = new("put_export",this);
      slave_export    = new("slave_export",this);

      // For passive UVM producers
      blocking_put_port       = new("blocking_put_port",this,0);
      blocking_transport_port = new("blocking_transport_port",this,0);
      blocking_master_port    = new("blocking_master_port",this,0);

      request_ap    = new("request_ap",this);
      response_ap   = new("response_ap",this);

      if (req_chan == null)
        req_chan = new("Channel-to-TLM Adapter Out Channel",name);
      this.req_chan = req_chan;
      this.rsp_chan = rsp_chan;
      this.rsp_is_req = rsp_is_req;
      this.max_pending_req = max_pending_req;
   endfunction


   // Function: build
   //
   // Called as part of a predefined test flow, this function will retrieve
   // the configuration setting for the <rsp_is_req> that
   // this component's <req_chan> variable has been configured with a non-null

   virtual function void build();
     void'(get_config_int("rsp_is_req",this.rsp_is_req));
     void'(get_config_int("pound_zero_count",this.pound_zero_count));
   endfunction


   // Function: end_of_elaboration
   //
   // Called as part of a predefined test flow, this function will check that
   // this component's <req_chan> variable has been configured with a non-null
   // instance of a vmm_channel #(VMM).

   virtual function void end_of_elaboration();
     if (this.req_chan == null)
     `ifdef UVM_ON_TOP
       `uvm_fatal("Connection Error",
          "avt_channel2uvm_tlm requires a request vmm_channel");
      `else
       `vmm_fatal(this.req_chan.log,
          "Connection Error avt_channel2uvm_tlm requires a request vmm_channel");
      `endif
     if (this.rsp_chan != null && this.rsp_is_req)
      `ifdef UVM_ON_TOP
       `uvm_warning("Ignoring rsp_is_req bit",
          "rsp_is_req bit is ignored when a response channel is in use");
       `else
       `vmm_warning(this.rsp_chan.log, "Ignoring rsp_is_req bit rsp_is_req bit is ignored when a response channel is in use");
       `endif
   endfunction


   // Task: run
   //
   // Called as part of a predefined test flow, the run task forks a
   // process for getting requests from the request channel and sending
   // them to the UVM consumer connection via the blocking put port.

   virtual task run();

     // only if port is connected
     if (blocking_put_port.size()) begin
       fork
         auto_put();
       join_none
     end
     else if (blocking_transport_port.size()) begin
       fork
         auto_transport();
       join_none
     end
     else if (blocking_master_port.size()) begin
       fork
         auto_blocking_master();
       join_none
     end

   endtask


   // Function: get_type_name
   //
   // Returns the type name, i.e. "avt_channel2uvm_tlm", of this
   // adapter.

   virtual function string get_type_name();
     return this.type_name;
   endfunction

   const static string type_name = "avt_channel2uvm_tlm";


   // Variable: req_chan
   //
   // Handle to the request vmm_channel #(VMM) instance being adapted. All puts
   // and gets via the TLM exports will be delegated to this channel.

   vmm_channel_typed #(VMM_REQ) req_chan;


   // Variable: rsp_chan
   //
   // Handle to the response vmm_channel #(VMM) instance being adapted. All
   // puts and gets via the TLM exports will be delegated to this channel.

   vmm_channel_typed #(VMM_RSP) rsp_chan;


   // Variable: rsp_is_req
   //
   // Indicates whether a response is the same object as the request with
   // the status and/or read data filled in. When set, and the <rsp_chan> is
   // null, the request process will, after returning from a put to the
   // request channel, copy the VMM request into the orginal UVM request
   // object and send it as the UVM response to the <seq_item_port>'s put
   // method.check
   //
   // In certain vmm_channel/driver
   // completion models, the channel full level is 1 and the connected driver
   // does not consume the transaction until it has been fully executed.
   // In this mode, the driver peeks the transaction from the channel,
   // executes it, fills in the response in fields of the same request
   // object, then finally pops (gets) the transaction off the channel.
   // This then frees the put process, which was waiting for the transaction
   // to leave the the channel. 
   //
   // This variable can be specified in a <new> constructor argument, or set
   // via a set_config_int("rsp_is_req",value) call targeting this component.

   protected bit rsp_is_req = 1;


   int pound_zero_count = 4;

   local VMM_REQ vmm_req[$];

   local UVM_REQ uvm_req[$];


   local bit item_done_on_get = 1;


   // Variable: max_pending_requests
   //
   // Specifies the maximum number of requests that can be outstanding.
   // The adapter holds all outgoing requests in a queue for later
   // matching with incoming responses. A maximum exists to prevent
   // this queue from growing too large.
   //
   // TODO: implement a user-settable timeout for all transactions
   // held in the pending queue.
   int unsigned max_pending_req = 100;


   // Task: auto_put
   //
   // Used by this adapter to send transactions to passive UVM consumers.

   virtual task auto_put();
     UVM_REQ o_req;
     forever begin
       this.peek(o_req);
       this.blocking_put_port.put(o_req);
       this.item_done();
     end
   endtask


   // Task: auto_transport
   //
   // Used by this adapter to send transactions to passive UVM consumers.

   virtual task auto_transport();
     UVM_REQ o_req;
     UVM_RSP o_rsp;
     forever begin
       this.peek(o_req);
       this.blocking_transport_port.transport(o_req,o_rsp);
       this.item_done(o_rsp);
     end
   endtask


   // Task: auto_blocking_master
   //
   // Used by this adapter to send transactions to passive UVM consumers.

   virtual task auto_blocking_master();
     UVM_REQ o_req;
     UVM_RSP o_rsp;
     fork
       // requests
       forever begin
         this.peek(o_req);
         this.blocking_master_port.put(o_req);
         this.item_done_on_get = 0;
         this.item_done();
       end
       // responses
       forever begin
         this.blocking_master_port.get(o_rsp);
         this.item_done(o_rsp);
       end
     join_none
   endtask


   // Function- convert
   //
   //
   function void convert (VMM_REQ v_req, output UVM_REQ o_req);
     if (vmm_req[$] == v_req) begin
       // needed only if req data can change between successive calls to peek
       // t = VMM2UVM_REQ::convert(v_req,uvm_req[$]);
       o_req = uvm_req[$];
     end
     else begin
       if (vmm_req.size() >= max_pending_req) begin
         `ifdef UVM_ON_TOP
          `uvm_fatal("Pending Transactions",
                  $psprintf("Exceeded maximum number of %0d pending requests.",
                     max_pending_req));
         `else
         `vmm_fatal(this.req_chan.log, 
                  $psprintf("Pending Transactions","Exceeded maximum number of %0d pending requests.",
                     max_pending_req));
         `endif
         o_req = null;
         return;
       end
       o_req = VMM2UVM_REQ::convert(v_req);
       uvm_req.push_back(o_req);
       vmm_req.push_back(v_req);
     end
   endfunction



   // Task: get
   //
   // Gets and converts a request from the <req_chan> vmm_channel.

   virtual task get(output UVM_REQ o_req);
     vmm_data v_pop;

     this.peek(o_req);
     if (this.item_done_on_get)
       this.item_done();
     else
       req_chan.XgetX(v_pop);

     this.m_last_o_req = null;
   endtask

   local UVM_REQ m_last_o_req;

   // Function: can_get
   //
   // Returns 1 if a transactions is available to get, 0 otherwise.
   virtual function bit can_get();
     return !(this.req_chan.size() <= this.req_chan.empty_level() ||
              this.req_chan.is_locked(vmm_channel::SINK));
   endfunction
  

   // Function: try_get
   //
   // If a transactions is available to get, returns the transaction
   // in the ~o_req~ output argument, else returns 0.
   virtual function bit try_get(output UVM_REQ o_req);
     vmm_data v_base;
     VMM_REQ v_req;
     if (!can_get())
       return 0;
     this.m_last_o_req = null;
     v_base = req_chan.try_peek();
     assert($cast(v_req, v_base));
     if (this.item_done_on_get)
       this.item_done();
     return 1;
   endfunction



   // Task: peek
   //
   // Peeks (does not consume) and converts a request from the <req_chan>
   // vmm_channel.
   //
   // TO DISCUSS- cached transaction can change between peeks.
   virtual task peek(output UVM_REQ o_req);
     VMM_REQ v_req;
     if (this.m_last_o_req != null) begin
       o_req = m_last_o_req;
       return;
     end
     req_chan.peek(v_req);
     convert(v_req,o_req);
     this.m_last_o_req = o_req;
   endtask


   // Function: can_peek
   //
   // Returns 1 if a transaction is available in the <req_chan>, 0 otherwise.
   //
   virtual function bit can_peek();
     return this.can_get();
   endfunction


   // Function: try_peek
   //
   // If a request is available to peek from the <req_chan>, this function
   // peeks (does not consume) the transaction from the channel, converts,
   // and returns via the ~o_req~ output argument. Otherwise, returns 0.
   //
   // TO DISCUSS- cached transaction can change between peeks.
   virtual function bit try_peek(output UVM_REQ o_req);
     vmm_data v_base;
     VMM_REQ v_req;
     if (!can_peek())
       return 0;
     if (this.m_last_o_req != null) begin
       o_req = m_last_o_req;
       return 1;
     end
     v_base = req_chan.try_peek();
     assert($cast(v_req, v_base));
     convert(v_req,o_req);
     this.m_last_o_req = o_req;
     return 1;
   endfunction


   // Task: put
   //
   // Converts and sneaks a response to the <rsp_chan> vmm_channel, if defined.
   // If the <rsp_chan> is null, the response is dropped.

   virtual task put (UVM_RSP o_rsp);
     put_response(o_rsp);
   endtask

 
   // Function: can_put
   //
   // Always returns 1 (true) because responses are sneaked into the channel.

   virtual function bit can_put ();
     return 1;
   endfunction

 
   // Function: try_put
   //
   // Sneak the given response to the response channel, or copy the
   // response to the corresponding request if <rsp_is_req> is set. 

   virtual function bit try_put (UVM_RSP o_rsp);
     this.put_response(o_rsp);
     return 1;
   endfunction

 
   // Function: write
   //
   // Used by active UVM consumers to send back responses.

   virtual function void write(UVM_RSP o_rsp);
     this.put_response(o_rsp); 
   endfunction


   // seq_item_pull_export implementations

   // Task: get_next_item 
   // 
   // Peeks and converts a request from the <req_chan> vmm_channel. This task
   // behaves like a blocking peek operation; it blocks until an item is
   // available in the channel. When available, the transaction is peeked and
   // ~not consumed from the channel~. The request is consumed upon a call
   // <get> or <item_done>.
   //
   // A call to ~get_next_item~ must always be followed by a call to <get> or
   // <item_done> before calling ~get_next_item~ again.

   virtual task get_next_item(output UVM_REQ t);
     VMM_REQ req;
     req_chan.peek(req);
     if (vmm_req[$] == req) begin
       `ifdef UVM_ON_TOP
       `uvm_error("Trans In-Progress",
         "Get_next_item called twice without item_done or get in between");
       `else
       `vmm_error(this.req_chan.log, "Trans In-Progress  Get_next_item called twice without item_done or get in between");
       `endif
       t = null;
       return;
     end
     this.peek(t);
     this.m_last_o_req = null;
   endtask


  // Task: try_next_item
  //
  // Waits a number of delta cycles waiting for a request
  // transaction to arrive in the <req_chan> vmm_channel. If a request is
  // available after this time, it is peeked from the channel, converted,
  // and returned. If after this time a request is not yet available,
  // the task sets ~t~ to null and returns. This behavior is similar to
  // a blocking peek with a variable delta-cycle timeout.

  virtual task try_next_item (output UVM_REQ t);
    wait_for_sequences();
    if (!has_do_available()) begin
      t = null;
      return;
    end
    get_next_item(t);
  endtask


   // Function: put_response
   //
   // A non-blocking version of <put>, this function converts and sneaks 
   // the given response into the <rsp_chan> vmm_channel. If the <rsp_chan>
   // is null, the response is dropped.

   virtual function void put_response (UVM_RSP o_rsp);

     VMM_REQ v_req;
     VMM_RSP v_rsp;

     if (o_rsp == null) begin
       `ifdef UVM_ON_TOP
       `uvm_fatal("SQRPUT", "Driver put a null response");
       `else
       `vmm_fatal(this.req_chan.log, "SQRPUT Driver put a null response");
       `endif
     end
     else if (o_rsp.get_sequence_id() == -1) begin
       `ifdef UVM_ON_TOP
       `uvm_fatal("SQRPUT",
         "Response has invalid sequence_id");
       `else
       `vmm_fatal(this.req_chan.log, "SQRPUT Response has invalid sequence_id");
       `endif
     end

     // Find the request that corresponds to this response
     foreach (vmm_req[i]) begin
       if (UVM_MATCH_REQ_RSP::match(uvm_req[i], o_rsp)) begin
         v_req = vmm_req[i];
         vmm_req.delete(i);
         uvm_req.delete(i);
         break;
       end
     end

     if (v_req == null) begin
        `ifdef UVM_ON_TOP
        `uvm_error("Orphan Response",
                          "A response did not match a pending request");
        `else
        `vmm_error(this.req_chan.log, "Orphan Response A response did not match a pending request");
        `endif                          
        return;
     end

     // If the response is configured to be the request, the response
     // is provided in the original request transaction.

     if (this.rsp_is_req) begin
        void'(UVM2VMM_RSP::convert(o_rsp, v_req));
        v_req.notify.indicate(vmm_data::ENDED, v_req);
        this.response_ap.write(o_rsp);
        return;
     end

     v_rsp = UVM2VMM_RSP::convert(o_rsp);
     v_req.notify.indicate(vmm_data::ENDED, v_rsp);
     this.response_ap.write(o_rsp);

     // dual channel
     if (this.rsp_chan != null) begin
       this.rsp_chan.sneak(v_rsp);
     end

   endfunction


   // Function: item_done
   //
   // A non-blocking function indicating an UVM driver is done with the
   // transaction retrieved with a <get_next_item> or <get>. The item_done
   // method pops the request off the <req_chan> vmm_channel,
   // converts the response argument, if provided, and sneaks converted response
   // into the <rsp_chan> vmm_channel. If the <rsp_chan> is null and
   // <rsp_is_req> is 0, the response, if provided, is dropped. If <rsp_is_req>
   // is 1, then the response is converted back into the original VMM request
   // and the transaction's ENDED notification is indicated.

   virtual function void item_done(UVM_RSP o_rsp=null);
     VMM_REQ v_req;
     UVM_REQ o_req;
     vmm_data v_req_base;

     // pop off the channel (assumes this hasn't already been done)
     req_chan.XgetX(v_req_base);
     $cast(v_req,v_req_base);

     if (v_req != vmm_req[$]) begin
     `ifdef UVM_ON_TOP
       `uvm_fatal("Item Not Started",
         "Item done called without a previous peek or get_next_item");
     `else
       `vmm_fatal(this.req_chan.log, "Item Not Started Item done called without a previous peek or get_next_item");
     `endif
     return;
     end

     o_req = uvm_req[$];

     this.request_ap.write(o_req);

     if (o_rsp != null) begin
       put_response(o_rsp);
       return;
     end

     if (this.rsp_is_req) begin

       o_req = uvm_req.pop_back();
       v_req = vmm_req.pop_back();

       void'(UVM2VMM_RSP::convert(o_req, v_req));
       v_req.notify.indicate(vmm_data::ENDED, v_req);

       if (this.response_ap.size())
         this.response_ap.write(o_req);
     end

   endfunction

 
   // Function: has_do_available
   //
   // Named for its association with UVM sequencer operation, this function
   // will return 1 if there is a transaction available to get from the
   // vmm_channel, <req_chan>.
 
   virtual function bit has_do_available();
     return !(req_chan.size() == 0 || req_chan.is_locked(vmm_channel::SINK));
   endfunction


   // Task: wait_for_sequences
   //
   // Used in the <try_next_item> method, this method waits a variable number
   // of #0 delays. This give the generator, which may not have resumed from
   // waiting for a previous call to <get> or <item_done>, a chance to wake
   // up and generate and put a new request into the <req_chan>. This allows
   // the driver to execute back-to-back tranasctions and the generator to
   // just-in-time request generation.

   virtual task wait_for_sequences();
     for (int i = 0; i < pound_zero_count; i++) #0;
   endtask



endclass

