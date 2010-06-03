//-----------------------------------------------------------------------------
//    Copyright 2008 Mentor Graphics Corporation
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the "License"); you may
//    not use this file except in compliance with the License.  You may obtain
//    a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//    License for the specific language governing permissions and limitations
//    under the License.
//-----------------------------------------------------------------------------



//------------------------------------------------------------------------------
//
// Title: VMM Producers
//
// This file defines the following VMM consumer components.
//
//------------------------------------------------------------------------------


//-----------------------------------------------------------------------------
//
// Group: vmm_producer_1chan
//
// A VMM producer using a single request channel to put transactions and
// expects responses to be annotated in the original request. It randomly
// chooses one of three completion models.
//-----------------------------------------------------------------------------

// (begin inline source)
class vmm_producer_1chan extends `VMM_XACTOR;

  vmm_channel_typed #(vmm_apb_rw) out_chan;

  function new(string inst,
               int unsigned stream_id=-1,
               vmm_channel_typed #(vmm_apb_rw) out_chan=null
               `VMM_XACTOR_NEW_ARGS);
    
    super.new("vmm_producer_1ch", inst, stream_id 
              `VMM_XACTOR_NEW_CALL); 
    if (out_chan == null)
      out_chan = new("APB Channel","out_chan");
    
    this.out_chan = out_chan;
    
  endfunction: new


  virtual protected task main();

    vmm_apb_rw wr_req = new();
    
    super.main();

    for(int i = 0; i < 10; i++) begin

      vmm_apb_rw tr;

      // WRITE

      assert(wr_req.randomize() with {wr_req.kind == vmm_apb_rw::WRITE;});
      
      // assume blocks until tr is processed by consumer (atomic mode)
      `vmm_note(log,{"via ATOMIC MODE             - ",wr_req.psdisplay()});
      this.out_chan.put(wr_req);
      

      // READ to verify

      tr = new;
      tr.addr = wr_req.addr;
      tr.kind = vmm_apb_rw::READ;
      tr.data = 'x;

      randcase

	// atomic (blocks on put)
        1: begin
	  vmm_apb_rw local_wr = new wr_req;
          this.out_chan.put(tr);
	  assert(tr.data == local_wr.data);
          `vmm_note(log,{"via ATOMIC MODE             - ",tr.psdisplay(),"\n"});
        end

	// blocking (blocks on vmm_data::ENDED)
        1: begin
	  vmm_apb_rw local_wr = new wr_req;
          this.out_chan.sneak(tr);
          tr.notify.wait_for(vmm_data::ENDED);
	  assert(tr.data == local_wr.data);
          `vmm_note(log,{"via BLOCKING MODE           - ",tr.psdisplay(),"\n"});
        end

	// nonblocking (separate process waits for vmm_data::ENDED)
        1: begin
	  vmm_apb_rw local_wr = new wr_req;
          this.out_chan.sneak(tr);
          fork
            begin
              tr.notify.wait_for(vmm_data::ENDED);
	      assert(tr.data == local_wr.data);
              `vmm_note(log,{"via NON-BLOCKING MODE       - ",tr.psdisplay(),"\n"});
            end
          join_none

        end

      endcase
            
   end // for (int i = 0; i < 10; i++)
   wait fork;  //PH> Weihua's
      
    this.notify.indicate(XACTOR_STOPPED);

  endtask

endclass
// (end inline source)

    
//-----------------------------------------------------------------------------
//
// Group: vmm_producer_2chan
//
// A VMM producer using request and response channels. It randomly
// chooses one of two completion models.
//-----------------------------------------------------------------------------

// (begin inline source)
class vmm_producer_2chan extends vmm_xactor;

  vmm_channel_typed #(vmm_apb_rw) out_chan, in_chan;

  function new(string inst,
               int unsigned stream_id=-1,
               vmm_channel_typed #(vmm_apb_rw) out_chan=null,
               vmm_channel_typed #(vmm_apb_rw) in_chan=null
               `VMM_XACTOR_NEW_ARGS);
    
    super.new("vmm__producer_2chan", inst, stream_id 
              `VMM_XACTOR_NEW_CALL); 
    if (out_chan == null)
      out_chan = new("vmm_channel #(vmm_apb_rw)","out_chan",10);
    
    this.out_chan = out_chan;
    if (in_chan == null)
      in_chan = new("vmm_channel #(vmm_apb_rw)","in_chan",10);
    
    this.in_chan = in_chan;
    
  endfunction


  virtual protected task main();

    vmm_apb_rw wr_req = new();
    vmm_apb_rw rd_req = new();
    vmm_apb_rw rr     = new();

    int unsigned addrs[$];
    integer unsigned m[int];
    vmm_apb_rw reqs[$];
    string  s;
    
    super.main();

    for(int i = 0; i < 10; i++) begin

      wr_req.data_id      = i;
      wr_req.scenario_id  = 1;
      assert(wr_req.randomize() with {wr_req.kind == vmm_apb_rw::WRITE;});
      `vmm_note(log,$psprintf("VMM Producer: Addr = %h, Data = %h, Kind = %s",
               wr_req.addr, wr_req.data, wr_req.kind));
      addrs.push_back(wr_req.addr);
      m[wr_req.addr]  = wr_req.data; // for results checking
      
      randcase

        // blocking request/response
        1: begin
          this.out_chan.put(wr_req);
          this.in_chan.get(rr);
          end

        // nonblocking request/response
        1: begin
          this.out_chan.sneak(wr_req);
          fork
            this.in_chan.get(rr);
          join_none
          #10;
        end

      endcase

      if(rr.compare(wr_req,s))
        `vmm_note(log,$psprintf("VMM Producer Got: Addr = %h, Data = %h, Kind = %s",
                 rr.addr, rr.data, rr.kind));
      else
        `vmm_error(log,
                   $psprintf("VMM R/R Producer: put %s; got %s",
                             wr_req.psdisplay(),rr.psdisplay()));

    end

    // Now do out-of-order reads to the addresses we've just written
    fork
      for(int i = 0; i<10; i++) begin
        rd_req              = new();
        rd_req.kind         = vmm_apb_rw::READ;
        rd_req.data         = 'x;
        rd_req.addr         = addrs[i];
        rd_req.data_id      = i;
        rd_req.scenario_id  = 1;
        //rd_reqs.push_back(rd_req);
        
        fork
          automatic vmm_apb_rw mytr  = rd_req;
          int dly      = {$random} % 100;
          #dly this.out_chan.put(mytr);
          `vmm_note(log,$psprintf("VMM Producer: Addr = %h, Data = %h, Kind = %s, id = %0d",
                   rd_req.addr, rd_req.data, rd_req.kind, rd_req.data_id));
          join_none // this should put 10 read transactions out in random order
      end

      for(int j = 0; j<10; j++) begin
        this.in_chan.get(rr);
        if(!rr.compare(reqs[rr.data_id],s))
           `vmm_error(log,
             $psprintf("VMM R/R Producer: put %s; got %s",
             reqs[rr.data_id].psdisplay(),rr.psdisplay()));
           else
           `vmm_note(log,$psprintf("VMM Producer Got: Addr = %h, Data = %h, Kind = %s",
                    rr.addr, rr.data, rr.kind));
      end
    join

    this.notify.indicate(XACTOR_STOPPED);

  endtask

endclass
// (end inline source)

    
//----------------------------------------------------------------------------------
//
// Group: vmm_notifier
//
// VMM Producer that conveys transactions as status in a notify indication.
//
//----------------------------------------------------------------------------------

// (begin inline source)
class vmm_notifier #(type T=int) extends vmm_xactor;

  int GENERATED=0;
  vmm_channel_typed #(T) out_chan; // for scoreboard

  function new(string inst,
               vmm_channel_typed #(T) out_chan=null);
    super.new("vmm_notifier",inst);
    GENERATED  = notify.configure(GENERATED,vmm_notify::ONE_SHOT);
    if (out_chan == null)
      this.out_chan = new("vmm_channel #(vmm_apb_rw)","out_chan");
  endfunction

  virtual task main();
    T tr,cp;
    super.main();
    tr  = new();
    repeat(10) begin
      assert(tr.randomize());
      $cast(cp,tr.copy());
      //    #0;
      `vmm_note(log,$psprintf("Notifying with status %s", tr.psdisplay()));
      notify.indicate(GENERATED, tr);
      out_chan.sneak(cp);
      #1;
    end
  endtask

endclass
// (end inline source)



