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

//------------------------------------------------------------------------------
//
// CLASS: avt_uvm_tlm2channel
//
//------------------------------------------------------------------------------
//
// Use this class to connect an UVM sequencer to a VMM driver via vmm_channel.
// Drivers can implement many different response-delivery models:
//
// - does not return a response
//
// - embeds a response in the original request transaction, which is available
//   to a requester that holds a handle to the original request.
//
// - returns a response in a separate vmm_channel
//
// The adapter can accommodate all such drivers.
//
//   (see avt_uvm_tlm2channel.gif)
//
// Communication is established by connecting the adapter to any of the above
// UVM producer types using the appropriate ports and exports.
//
// To use this adapter, the integrator instantiates an UVM producer, a VMM
// consumer, and an ~avt_uvm_tlm2channel~ adapter whose parameter values correspond
// to the UVM and VMM data types used by the producer and consumer and the
// converter types used to translate in one or both directions.
//
// If the default vmm_channels created by the VMM consumer or adapter are not
// used, then the integrator must also instantiate a request vmm_channel and a
// response vmm_channel, if the VMM consumer uses one.
//
// Integrators of VMM-on-top environments need to instantiate the UVM consumer
// and adapter via an UVM container, or wrapper component. This wrapper
// component serves to provide the connect method needed to bind the UVM ports
// and exports.
//
// See also <avt_uvm_tlm2channel example> and <avt_uvm_tlm2channel seq_item example>.
//
//------------------------------------------------------------------------------

class avt_uvm_tlm2channel #(type UVM_REQ     = int,
                             VMM_REQ     = int,
                             UVM2VMM_REQ = int,
                             VMM_RSP     = VMM_REQ,
                             UVM_RSP     = UVM_REQ,
                             VMM2UVM_RSP = avt_converter #(VMM_RSP,UVM_RSP))
                                              extends uvm_component;

   typedef avt_uvm_tlm2channel #(UVM_REQ, VMM_REQ, UVM2VMM_REQ,
                             VMM_RSP, UVM_RSP, VMM2UVM_RSP)
                              this_type;

   `uvm_component_param_utils(this_type)


   // Port: seq_item_port
   //
   // This bidirectional port is used to connect to an ~uvm_sequencer~ or any
   // other component providing an ~uvm_seq_item_export~. The uvm_seq_item port
   // and export communicate using the interface, <sqr_if_base #(REQ,RSP)>,
   // which, in part, defines the following methods:
   //
   //|  virtual task get  (output REQ request);
   //|  virtual task peek (output REQ request);
   //|  virtual task put  (RSP response);
   //
   // See <sqr_if_base #(REQ,RSP)> for information about this interface.

   uvm_seq_item_pull_port #(UVM_REQ,UVM_RSP) seq_item_port;


   // Port: put_export
   //
   // This export is used to receive transactions from an UVM producer
   // that utilizes a blocking or non-blocking put interface.
   uvm_put_imp #(UVM_REQ,this_type) put_export;


   // Port: master_export
   //
   // This bidirectional export is used to receive requests from and deliver
   // responses to an UVM producer that utilizes a blocking or non-blocking
   // master interface.
   uvm_master_imp #(UVM_REQ,UVM_RSP,this_type) master_export;


   // Port: blocking_transport_export
   //
   // This bidirectional export is used to receive requests from and deliver
   // responses to an UVM producer that utilizes a blocking transport interface.
   uvm_blocking_transport_imp #(UVM_REQ,UVM_RSP,this_type) blocking_transport_export;


   // Port: blocking_get_peek_port
   //
   // This unidirectional port is used to retrieve responses from a passive
   // UVM producer with a blocking get_peek export.
   uvm_blocking_get_peek_port #(UVM_REQ) blocking_get_peek_port;


   task blocking_get_peek_process();
   endtask


   // Port: blocking_put_port
   //
   // This port is used to deliver responses to an UVM producer that
   // expects responses from a blocking put interface.
   uvm_blocking_put_port #(UVM_REQ) blocking_put_port;



   // Port: blocking_slave_port
   //
   // This bidirectional port is used to request transactions from and deliver
   // responses to a passive UVM producer utilizing a blocking slave interface.
   uvm_blocking_slave_port #(UVM_REQ,UVM_RSP) blocking_slave_port;


   // Port: request_ap
   //
   // All transaction requests received from any of the interface ports and
   // exports in this adapter are broadcast out this analysis port to any UVM
   // subscribers. 
   uvm_analysis_port #(UVM_REQ) request_ap;


   // Port: response_ap
   //
   // All transaction responses received from any of the interface ports and
   // exports in this adapter are broadcast out this analysis port to any UVM
   // subscribers.  UVM producers that expect responses from an analysis
   // export may be connected to this port.
   uvm_analysis_port #(UVM_RSP) response_ap;


   // Function: new
   //
   // Creates a new avt_uvm_tlm2channel adapter given four optional arguments.
   //
   // name     - specifies the instance name. Default is "avt_uvm_tlm2channel".
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

   function new (string name="avt_uvm_tlm2channel",
                 uvm_component parent=null,
                 vmm_channel_typed #(VMM_REQ) req_chan=null,
                 vmm_channel_typed #(VMM_RSP) rsp_chan=null,
                 bit wait_for_req_ended=0);
      super.new(name,parent);

      // adapter may be driven by UVM producer via any of these exports
      put_export                = new("put_export",this);
      master_export             = new("master_export",this);
      blocking_transport_export = new("blocking_transport_export",this);

      // adapter may drive the UVM producer via any of these ports.
      seq_item_port             = new("seq_item_port",this,0);
      blocking_get_peek_port    = new("blocking_get_peek_port",this,0);
      blocking_put_port         = new("blocking_put_port",this,0);
      blocking_slave_port       = new("blocking_slave_port",this,0);
      request_ap                = new("request_ap",this);
      response_ap               = new("response_ap",this);

      if (req_chan == null)
        req_chan = new("TLM-to-Channel Adapter Request Channel",name);
      if (rsp_chan == null)
        rsp_chan = new("TLM-to-Channel Adapter Response Channel",name);
      this.req_chan = req_chan;
      this.rsp_chan = rsp_chan;
      this.wait_for_req_ended = wait_for_req_ended;
   endfunction


   // Function: build
   //
   // Called as part of a predefined test flow, this function will retrieve
   // the configuration setting for the <wait_for_req_ended> flag.

   virtual function void build();
     void'(get_config_int("wait_for_req_ended",this.wait_for_req_ended));
   endfunction


   // Function: end_of_elaboration
   //
   // Called as part of a predefined test flow, this function will check that
   // this component's <req_chan> variable has been configured with a non-null
   // instance of a vmm_channel #(VMM).

   virtual function void end_of_elaboration();
     if (this.req_chan == null)
       `uvm_fatal("Connection Error",
          "vmm_uvm_tlm2channel adapter requires a request vmm_channel");
   endfunction


   const static string type_name = "vmm_uvm_tlm2channel";


   // Function: get_type_name
   //
   // Returns the type name, i.e. "vmm_uvm_tlm2channel", of this
   // adapter.

   virtual function string get_type_name();
     return type_name;
   endfunction


   // Task: run
   //
   // Called as part of a predefined test flow, the run task forks a
   // process for getting requests from the <seq_item_port> and sending
   // them to the <req_chan> vmm_channel. If configured, it will also fork
   // an independent process for getting responses from the separate <rsp_chan>
   // vmm_channel and putting them back out the <seq_item_port>.

   virtual task run();

     bit port_is_connected = 0;

     if (this.seq_item_port.size()) begin
       //this.producer_port = seq_item_port;
       this.is_seq_item_port = 1;
       this.is_bidir_port = 1;
       port_is_connected = 1;
     end
     else if (blocking_get_peek_port.size()) begin
       this.producer_port = blocking_get_peek_port;
       port_is_connected = 1;
     end
     else if (blocking_slave_port.size()) begin
       this.producer_port = blocking_slave_port;
       this.is_bidir_port = 1;
       port_is_connected = 1;
     end

     if (port_is_connected) begin
       fork
         this.get_requests();
       join_none

       if (!this.is_bidir_port && !this.blocking_put_port.size() == 0 &&
           this.response_ap.size() == 0)
         this.rsp_chan.sink();
       else
         fork
           this.put_responses();
         join_none
     end

   endtask


   // Task: wait_for_ended
   //
   // Used to support VMM non-blocking completion models that indicate
   // and return response status via each transaction's ENDED notification.
   // For each transaction outstanding, this task is forked to wait for
   // the ENDED status. When that happens, the response is converted
   // and sent into the <rsp_chan>.
   //
   // The <wait_for_req_ended> bit, set in the constructor, determines
   // whether this task is used.

   virtual task wait_for_ended(VMM_REQ v_req);
     string data_id,scen_id;
     VMM_RSP v_rsp;
     assert($cast(v_rsp,v_req));
     fork
       begin : wait_for_ended_process
         v_req.notify.wait_for(vmm_data::ENDED);
         this.rsp_chan.sneak(v_rsp);
       end
       begin
         #this.request_timeout;
         data_id.itoa(v_req.data_id);
         scen_id.itoa(v_req.scenario_id);
         uvm_report_warning("Request Timed Out",
           {"The request with data_id=",data_id,
            " and scenario_id=",scen_id," timeout out."});
         disable wait_for_ended_process;
       end
     join
   endtask


   // Task: get_requests
   //
   // This task continually gets request transactions from the connected
   // sequencer, converts them to an equivalent VMM transaction, and puts
   // to the underlying <req_chan> vmm_channel.
   // 
   // If <wait_for_req_ended> is set and the <req_chan>'s full-level is 1, and
   // no <rsp_chan> is being used, it is assumed the put to <req_chan>
   // will not return until the transaction has been executed and the
   // response contained within the original request descriptor. In
   // this case, the modified VMM request is converted back to the
   // original UVM request object, which is then sent as a response to
   // both the <seq_item_port> and <response_ap> ports.
   //
   // This task is forked as a process from the <run> task.

   virtual task get_requests();
     UVM_REQ o_req;
     forever begin
       if (this.is_seq_item_port) begin
         seq_item_port.peek(o_req);
         this.put(o_req);
         seq_item_port.get(o_req); // pop
       end
       else begin
         producer_port.peek(o_req);
         this.put(o_req);
         producer_port.get(o_req); // pop
       end
     end
   endtask


   // Task: put_responses
   //
   // This task handles getting responses from the <rsp_chan> vmm_channel and
   // putting them to the appropriate UVM response port. The converters will handle
   // the transfer of (data_id,scenario_id) to (transaction_id/sequence_id)
   // information so responses can be matched to their originating requests.
   //
   // This task is forked as a process from the <run> task.

   virtual task put_responses();

     VMM_RSP v_rsp;
     UVM_RSP o_rsp;

     assert(this.rsp_chan != null);

     forever begin
       this.rsp_chan.get(v_rsp);
       o_rsp = VMM2UVM_RSP::convert(v_rsp);
       if (this.is_bidir_port) begin
         if (this.is_seq_item_port)
           this.seq_item_port.put(o_rsp);
	 else
           this.producer_port.put(o_rsp);
       end
       else if (blocking_put_port.size())
         this.blocking_put_port.put(o_rsp);
       this.response_ap.write(o_rsp);
     end

   endtask


   // Task: put
   //
   // Converts an UVM request to a VMM request and puts it into the
   // <req_chan> vmm_channel. Upon return, if <wait_for_req_ended> is set, the
   // VMM request is put to the <rsp_chan> for response-path processing.
   // The original UVM request is also written to the <request_ap>
   // analysis port.

   virtual task put (UVM_REQ o_req);
     VMM_REQ v_req;
     VMM_RSP v_rsp;
     v_req = UVM2VMM_REQ::convert(o_req);
     req_chan.put(v_req);
     request_ap.write(o_req);
     if (this.wait_for_req_ended)
       this.wait_for_ended(v_req);
     else begin
       assert($cast(v_rsp,v_req));
       this.rsp_chan.sneak(v_rsp);
     end
   endtask

 
   // Function: can_put
   //
   // Returns 1 if the <req_chan> can accept a new request.

   virtual function bit can_put ();
     return !this.req_chan.is_full();
   endfunction

 
   // Function: try_put
   //
   // If the <req_chan> can accept new requests, converts ~o_req~ to
   // its VMM equivalent, injects it into the channel, and returns 1.
   // Otherwise, returns 0.
   virtual function bit try_put (UVM_REQ o_req);
     VMM_REQ v_req;
     if (!this.can_put())
       return 0;
     v_req = UVM2VMM_REQ::convert(o_req);
     req_chan.sneak(v_req);
     request_ap.write(o_req);
     if (this.wait_for_req_ended)
       fork
       this.wait_for_ended(v_req);
       join_none
     else
     return 1;
   endfunction


   // Task: get
   //
   // Gets a response from the <rsp_chan>, converts, and returns in
   // the ~o_rsp~ output argument.

   virtual task get(output UVM_RSP o_rsp);
     VMM_RSP v_rsp;
     this.rsp_chan.get(v_rsp);
     o_rsp = VMM2UVM_RSP::convert(v_rsp);
   endtask

   // Function: can_get
   //
   // Returns 1 if a response is available to get, 0 otherwise.

   virtual function bit can_get();
     return !(this.rsp_chan.size() <= this.rsp_chan.empty_level() ||
              this.rsp_chan.is_locked(vmm_channel::SINK));
   endfunction
  

   // Function: try_get
   //
   // If a response is available in the <rsp_chan>, gets and returns
   // the response in the ~o_rsp~ output argument and returns 1.
   // Returns 0 otherwise.
   virtual function bit try_get(output UVM_RSP o_rsp);
     vmm_data v_base;
     VMM_RSP v_rsp;
     if (!this.can_get())
       return 0;
     rsp_chan.XgetX(v_base);
     assert($cast(v_rsp, v_base));
     o_rsp = VMM2UVM_RSP::convert(v_rsp);
     return 1;
   endfunction


   // Task: peek
   //
   // Peeks (does not consume) and converts a response from the <rsp_chan>.

   virtual task peek(output UVM_RSP o_rsp);
     VMM_RSP v_rsp;
     this.rsp_chan.get(v_rsp);
     o_rsp = VMM2UVM_RSP::convert(v_rsp);
   endtask


   // Function: can_peek
   //
   // Returns 1 if a transaction is available in the <rsp_chan>, 0 otherwise.

   virtual function bit can_peek();
     return this.can_get();
   endfunction


   // Function: try_peek
   //
   // If a response is available to peek from the <rsp_chan>, this function
   // peeks (does not consume) the transaction from the channel, converts,
   // and returns via the ~o_req~ output argument. Otherwise, returns 0.

   virtual function bit try_peek(output UVM_RSP o_rsp);
     vmm_data v_base;
     VMM_RSP v_rsp;
     if (!this.can_peek())
       return 0;
     v_base = rsp_chan.try_peek();
     assert($cast(v_rsp, v_base));
     o_rsp = VMM2UVM_RSP::convert(v_rsp);
     return 1;
   endfunction


  // Task: transport
  //
  // Blocking transport is used to atomically execute the geiven
  // request transaction, ~req~, and return the response in ~rsp~.

  task transport (UVM_REQ o_req, output UVM_RSP o_rsp);
    this.put(o_req);
    this.get(o_rsp);
  endtask



   // Variable: req_chan
   //
   // Handle to the request vmm_channel #(VMM) instance being adapted. 

   vmm_channel_typed #(VMM_REQ) req_chan;


   // Variable: rsp_chan
   //
   // Handle to the response vmm_channel #(VMM) instance being adapted.
   // The adapter uses a response channel regardless of whether the
   // VMM consumer uses it directly. This keeps the request and response
   // paths on the TLM side separate.

   vmm_channel_typed #(VMM_RSP) rsp_chan;


   // Variable: wait_for_req_ended
   //
   // When the VMM consumer does not use a separate response channel, this
   // bit specifies whether the response, which is annotated into the
   // original request, is available after a ~get~ from the request
   // channel (~wait_for_req_ended=0~) or after the original request's
   // ENDED status is indicated (~wait_for_req_ended=1~). The latter case
   // enables interconnecting with pipelined VMM consumers at the cost
   // of two additional processes for each outstanding request transaction.
   //
   // This variable can be specified in a <new> constructor argument, or set
   // via a set_config_int("wait_for_req_ended",value) call targeting this
   // component.

   protected bit wait_for_req_ended = 0;

   protected uvm_port_base #(uvm_tlm_if_base #(UVM_REQ,UVM_RSP)) producer_port;

   protected bit is_seq_item_port = 0;

   protected bit is_bidir_port = 0;

   time request_timeout = 100us;

endclass

