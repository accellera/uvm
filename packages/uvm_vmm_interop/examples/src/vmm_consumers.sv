//------------------------------------------------------------------------------
// Copyright 2008 Mentor Graphics Corporation
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
// Title: VMM Consumers
//
// This file defines the following VMM consumer components.
//
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// Group: vmm_consumer
//
// A simple VMM consumer xactor that gets transactions from a channel and
// "executes" them by printing them and delaying a bit. A real consumer would
// naturally do something more substantive with each transaction.
//------------------------------------------------------------------------------

// (begin inline source)
class vmm_consumer #(type T=vmm_data) extends vmm_xactor;

   // Variable: in_chan
   //
   // The vmm_channel from which new transasctions are obtained.

   vmm_channel_typed #(T) in_chan;

   int stop_after_n_insts = -1;
   int num_insts = 0;
   int DONE;

   // Function: new
   //
   // The standard constructor for a vmm_xactor: inst name,
   // stream_id, and an optional input vmm_channel handle.
   // If the in_chan handle is not given, a new default channel
   // is created.

   function new(string inst,
                int unsigned stream_id=-1,
                vmm_channel_typed #(T) in_chan=null
                `VMM_XACTOR_NEW_ARGS);

     super.new("vmm_consumer #(T)", inst, stream_id `VMM_XACTOR_NEW_CALL); 
     if (in_chan == null)
        in_chan = new("vmm_channel #(T)","in_chan");

     this.in_chan = in_chan;

     DONE = this.notify.configure(-1, vmm_notify::ON_OFF);

   endfunction: new


   // Task: main
   //
   // A process that continually peeks transactions from <in_chan>,
   // prints it, waits a bit, then pops it off the channel to unblock
   // the producer.

   virtual protected task main();

     fork
       super.main();
     join_none

      while (this.stop_after_n_insts <= 0 ||
             this.num_insts < this.stop_after_n_insts) begin

       T tr;

       this.wait_if_stopped_or_empty(this.in_chan);

       this.in_chan.peek(tr);

       `vmm_note(log, {"Received transaction ", tr.psdisplay()});
       #100;
        
        
       this.in_chan.get(tr); // pop

       num_insts++;

     end

     this.notify.indicate(DONE);
     this.notify.indicate(XACTOR_STOPPED);
     this.notify.indicate(XACTOR_IDLE);
     this.notify.reset(XACTOR_BUSY);

   endtask: main

endclass
// (end inline source)


//------------------------------------------------------------------------------
//
// Group: vmm_watcher
//
// Receives data via notification status
//------------------------------------------------------------------------------

// (begin inline source)
class vmm_watcher #(type T=int) extends vmm_xactor;

  // Variable: INCOMING
  //
  // The notification id upon which this component will wait for a transaction.
  // Components wanting to source transaction to this component must call
  // this.notify(INCOMING,<transaction>), where <transaction> is the handle
  // to any vmm_data-based transaction.

  int INCOMING;

  // Variable: sbd_chan
  //
  // A channel into which the received data is sneaked and from which the
  // main method gets the data, so that the tee() call in the
  // scoreboard will also see it.

  vmm_channel_typed #(T) sbd_chan;

  // Function: new
  //
  // Creates a new instance of this class with name specified in ~inst~
  // argument. The INCOMING notification is configured, and a callback is
  // registered to call this component's <indicated> method when the
  // INCOMING notification is indicated.

  function new(string inst);
    vmm_watcher_cb #(vmm_watcher #(T)) cb;
    super.new("vmm_watcher",inst);
    INCOMING = notify.configure(-1,vmm_notify::ONE_SHOT); 
    cb = new(this);
    notify.append_callback(INCOMING,cb);
    sbd_chan = new("vmm_channel","Scoreboard channel");
  endfunction

   // Task: main
   //
   // A process that continually gets transactions from sbd_chan,
   // so that the scoreboard's tee() method will see it.

   virtual protected task main();
     T tmp;
     fork
       super.main();
     join_none

     while (1) 
       sbd_chan.get(tmp);
   endtask // main

  
  // Function: indicated
  //
  // When the INCOMING notification is indicated, the incoming transaction
  // is passed to this function for processing. 

  virtual function void indicated(vmm_data status);
    `vmm_note(log,{"Received transaction ",status.psdisplay()});
    sbd_chan.sneak(status);
  endfunction

endclass
// (end inline source)

//------------------------------------------------------------------------------
//
// Group: vmm_notifier_consumer
//
//------------------------------------------------------------------------------

class vmm_notifier_consumer #(type T=vmm_data) extends vmm_xactor;

   // Variable: in_chan
   //
   // The vmm_channel from which new transasctions are obtained.

   vmm_channel_typed #(T) in_chan, out_chan;

   int stop_after_n_insts = -1;
   int num_insts = 0;
   int GENERATED=0;

   // Function: new
   //
   // The standard constructor for a vmm_xactor: inst name,
   // stream_id, and an optional input vmm_channel handle.
   // If the in_chan handle is not given, a new default channel
   // is created.

   function new(string inst,
                int unsigned stream_id=-1,
                vmm_channel_typed #(T) in_chan=null,
                vmm_channel_typed #(T) out_chan=null
                `VMM_XACTOR_NEW_ARGS);

     super.new("vmm_consumer #(T)", inst, stream_id `VMM_XACTOR_NEW_CALL); 
     if (in_chan == null)
        in_chan = new("vmm_channel #(T)","in_chan");

     this.in_chan = in_chan;

     if (out_chan == null)
        out_chan = new("vmm_channel #(T)","out_chan");

     this.out_chan = out_chan;

     GENERATED = notify.configure(GENERATED,vmm_notify::ONE_SHOT);

   endfunction: new


   // Task: main
   //
   // A process that continually peeks transactions from <in_chan>,
   // prints it, waits a bit, then pops it off the channel to unblock
   // the producer.

   virtual protected task main();

     fork
       super.main();
       wait_to_notify();
     join_none

      while (this.stop_after_n_insts <= 0 ||
             this.num_insts < this.stop_after_n_insts) begin

       T tr;

       this.wait_if_stopped_or_empty(this.in_chan);

       this.in_chan.peek(tr);

       `vmm_note(log, {"Starting transaction...\n",
                        tr.psdisplay("   ")});
        
        this.out_chan.sneak(tr);
        
       this.in_chan.get(tr); // pop

       num_insts++;

     end

   endtask: main

   task wait_to_notify();
     T tr;
     forever begin
       #100;
       tr=new();
       assert(tr.randomize());
       `vmm_note(log,$psprintf("\n%m About to notify with status\n%s",
                               tr.psdisplay()));
       notify.indicate(GENERATED, tr);
     end
   endtask: wait_to_notify

endclass
// (end inline source)

//-----------------------------------------------------------------------------
//
// Group: vmm_pipelined_consumer
//
//------------------------------------------------------------------------------

class vmm_pipelined_consumer #(type T=vmm_data) extends vmm_xactor;

   // Variable: req_chan
   //
   // The vmm_channel from which new transasctions are obtained.

   vmm_channel_typed #(T) req_chan, rsp_chan;

   int stop_after_n_insts = -1;
   int num_insts = 0;
   int DONE;

   // Function: new
   //
   // The standard constructor for a vmm_xactor: inst name,
   // stream_id, and an optional input vmm_channel handle.
   // If the req_chan handle is not given, a new default channel
   // is created.

   function new(string inst,
                int unsigned stream_id=-1,
                vmm_channel_typed #(T) req_chan=null,
                vmm_channel_typed #(T) rsp_chan=null
                `VMM_XACTOR_NEW_ARGS);

     super.new("vmm_consumer #(T)", inst, stream_id `VMM_XACTOR_NEW_CALL); 
     if (req_chan == null)
        req_chan = new("vmm_channel #(T)","req_chan");

     this.req_chan = req_chan;

     if (rsp_chan == null)
        rsp_chan = new("vmm_channel #(T)","rsp_chan");

     this.rsp_chan = rsp_chan;

     DONE = this.notify.configure(-1, vmm_notify::ON_OFF);
   endfunction: new


   // Task: main
   //
   // A process that continually peeks transactions from <req_chan>,
   // prints it, waits a bit, then pops it off the channel to unblock
   // the producer.

   virtual protected task main();
     fork
       super.main();
     join_none

      while (this.stop_after_n_insts <= 0 ||
             this.num_insts < this.stop_after_n_insts) begin

       T req;
       // Wait for pipeline to be ready to accept transaction
       this.req_chan.get(req);
       `vmm_note(log, {"Starting transaction...\n",
                        req.psdisplay("   ")});
       fork
         begin
         T rsp;
         //YSL>> In BP doc, this is rsp=new(req)?
         //YSL>> But, using $cast is not working as expected
         //$cast(rsp, req.copy());
         $cast(rsp,req.copy());
         // Mimic waiting response
         #20;
         rsp.data='hdeadbeef;
         `vmm_note(log, {"Receiving transaction...\n", 
                         rsp.psdisplay("   ")});
         
         // 'req' executed and 'rsp' annotated with response
         req.notify.indicate(vmm_data::ENDED, rsp);
         //req.notify.wait_for(vmm_data::ENDED);
         //YSL>> This line is based on the BP doc, but it does not seem to be required?
         //YSL>> It works like a normal vmm_channel to scoreboard(?)
         this.rsp_chan.sneak(rsp); // Can also use put()
         `vmm_note(log, {"Returning rsp transaction...\n", 
                         rsp.psdisplay("   ")});
         num_insts++;
         end
       join_none

     end
   endtask: main

endclass
