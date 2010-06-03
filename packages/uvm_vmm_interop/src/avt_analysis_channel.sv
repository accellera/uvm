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
// CLASS: avt_analysis_channel
//
//------------------------------------------------------------------------------
//
// The avt_analysis_channel is used to connect any UVM component with an
// analysis port or export to any VMM component via a vmm_channel.
//
// The adapter operates in two different modes.
//
// UVM analysis port to VMM channel - Connect any UVM component with an analysis
// port to this adapter's <analysis_export>. The adapter will convert all
// incoming UVM transactions to a VMM transaction and ~put~ it to the vmm_channel.
//
// VMM channel to UVM analysis export - Connect the adapter's <analysis_port> to
// one or more UVM components with an analysis export. The adapter will ~get~
// any transaction put into the vmm_channel, convert them to an UVM transaction,
// and broadcast it out the analysis port.
//
// Users should connect either the <analysis_export> or <analysis_port>, not
// both.
//
// (see avt_analysis_channel.gif)
//
// See also the <avt_analysis_channel example>.
//
//------------------------------------------------------------------------------


class avt_analysis_channel #(type UVM=int, VMM=int,
                             UVM2VMM=avt_converter #(UVM,VMM),
                             VMM2UVM=avt_converter #(VMM,UVM))
                         extends uvm_component;

  typedef avt_analysis_channel #(UVM, VMM, UVM2VMM, VMM2UVM) this_type;

  `uvm_component_param_utils(this_type)

  // Port: analysis_export
  //
  // The adapter may receive UVM transactions via this analysis export.
  // The 

  uvm_analysis_imp #(UVM, this_type) analysis_export;


  // Port: analysis_port
  //
  // VMM transactions received from the channel are converted to UVM
  // transactions and broadcast out this analysis port. 

   uvm_analysis_port #(UVM) analysis_port;


  // Function: new
  //
  // Creates a new avt_analysis_channel with the given ~name~ and
  // optional ~parent~; the optional ~chan~ argument provides the
  // handle to the vmm_channel being adapted. If no channel is given,
  // the adapter will create one.

  function new (string name, uvm_component parent=null,
                vmm_channel_typed #(VMM) chan=null);
    super.new(name, parent);
    if (chan == null)
      chan = new("VMM Analysis Channel",name);
    this.chan = chan;
    analysis_export = new("analysis_export",this);
    analysis_port   = new("analysis_port",this);
  endfunction


  // Task: run
  //
  // If the <analysis_port> is connected, the run task
  // will continually get VMM transactions from the vmm_channel and
  // end the converted transactions out the <analysis_port>.

  virtual task run();
    if (analysis_port.size() > 0)
      forever begin
        VMM vmm_t;
        UVM uvm_t;
        chan.get(vmm_t);
        uvm_t = VMM2UVM::convert(vmm_t);
        analysis_port.write(uvm_t);
      end
   endtask


  // Function: write
  //
  // The write method, called via the <analysis_export>, converts
  // an incoming UVM transaction to its VMM counterpart, then sneaks
  // the converted transaction to the vmm_channel.

  function void write(UVM uvm_t);
    VMM vmm_t;
    if (uvm_t == null)
     return;
    vmm_t = UVM2VMM::convert(uvm_t);
    chan.sneak(vmm_t);
  endfunction


   // Variable: chan
   //
   // The vmm_channel instance being adapted; if not supplied in
   // its <new> constructor, the adapter will create one.
   //
   // Incoming transactions from the <analysis_export> will be converted
   // to VMM and ~put~ to this channel.
   //
   // If the <analysis_port> is connected, transaction injected into
   // the channel are fetched, converted, and sent out the <analysis_port>.

   vmm_channel_typed #(VMM) chan;

endclass

