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
// CLASS- vmm_watcher_cb
//
// Receives data via notification status, then forwards data to the configured
// VMM component. The type of the VMM component is specified in the type
// parameter, and the instance of a VMM component of that type is specified
// in the constructor argument.
// 
//------------------------------------------------------------------------------

class vmm_watcher_cb #(type WATCHER=int) extends vmm_notify_callbacks;

  WATCHER watcher;

  // Function- new
  //
  // Creates a new callback instance that forwards transactions to the
  // object specified in the constructor argument.

  function new (WATCHER watcher);
    this.watcher=watcher;
  endfunction

  // Function- indicated
  //
  // When the notification associated with this callback is indicated, this
  // function is called, which forwards the received data to the target
  // component.

  virtual function void indicated(vmm_data status);
    watcher.indicated(status);
  endfunction

endclass


//------------------------------------------------------------------------------
//
// CLASS: avt_notify2analysis
//
//------------------------------------------------------------------------------
//
// The avt_notify2analysis adapter receives VMM data supplied by a vmm_notify
// event notification, converts it to UVM, then broadcasts it to all components
// connected to its <analysis_port>
//
// (see avt_notify2analysis.gif)
//
// See also <avt_notify2analysis example>.
//
//------------------------------------------------------------------------------

class avt_notify2analysis #(type VMM=int, UVM=int, VMM2UVM=int) 
        extends uvm_component;

  typedef avt_notify2analysis #(VMM,UVM,VMM2UVM) this_type;

  `uvm_component_param_utils(this_type)


  // Port: analysis_port
  //
  // The adapter writes converted VMM data supplied by a vmm_notify event
  // notification to this analysis_port. 
  //
  // Components connected to this analysis port via an analysis export will
  // receive these transactions in a non-blocking fashion. If a receiver can
  // not immediately accept broadcast transactions, it must buffer them.

  uvm_analysis_port #(UVM) analysis_port;


  // Variable: notify
  //
  // The notify object that this adapter uses to register a callback on the
  // <RECEIVED> event notification.

  vmm_notify notify;


  // Variable: RECEIVED
  //
  // The notification id that, when indicated, will provide data to
  // a callback registered by this adapter. The callback will forward
  // the data to the <indicated> method.

  int RECEIVED;


  // Function: new
  //
  // Creates a new notify-to-analysis adapter with the given ~name~ and
  // optional ~parent~; the ~notify~ and ~notification_id~ together
  // specify the notification instance that this adapter will be
  // sensitive to. The adapter will register a callback that is called
  // when the notification is indicated. The callback will forward the
  // (status) transaction to the <indicated> method.   
  //
  // If the ~notify~ handle is not supplied or null, the adapter will
  // create one and assign it to the <notify> property. If the 
  // ~notification_id~ is not provided, the adapter will configure a
  // ONE_SHOT notification and assign it to the <RECEIVED> property. 

  function  new (string name, uvm_component parent=null,
                vmm_notify notify=null, int notification_id=-1);

    vmm_watcher_cb #(this_type) cb;

    super.new(name,parent);

    analysis_port = new("analysis_port",this);

    if (notify == null) begin
      vmm_log log;
      log = new("vmm_log","avt_notify2analysis_log");
      notify = new(log);
    end

    this.notify = notify;

    if (notification_id == -1)
      notification_id = notify.configure(-1,vmm_notify::ONE_SHOT);
    else
      if (notify.is_configured(notification_id) != vmm_notify::ONE_SHOT)
        uvm_report_fatal("Bad Notification ID",
          $psprintf({"Notification id %0d not configured, ",
                    "or not configured as ONE_SHOT"}, notification_id));
    this.RECEIVED = notification_id;

    cb = new(this);
    notify.append_callback(RECEIVED, cb);

  endfunction


  // Function: indicated
  //
  // Called back when the <RECEIVED> notification in the <notify>
  // object is indicated, this method converts the <VMM> data given
  // in the ~status~ argument to its <UVM> counterpart, then send
  // it out the <analysis_port> to any connected subscribers.

  virtual function void indicated(vmm_data status);
    UVM uvm_out;
    VMM vmm_in;
    if (status == null)
      return;
    assert ($cast(vmm_in,status));
    uvm_out = VMM2UVM::convert(vmm_in);
    analysis_port.write(uvm_out);
  endfunction

endclass


