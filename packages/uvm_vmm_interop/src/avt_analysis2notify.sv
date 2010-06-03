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
// CLASS: avt_analysis2notify
//
//------------------------------------------------------------------------------
//
// The avt_analysis2notify adapter receives UVM data from its <analysis_export>,
// converts it to VMM, then indicates the configured event notification,
// passing the converted data as vmm_data-based status. VMM components that have
// registered a callback for the notification will received the converted data
//
// (see avt_analysis2notify.gif)
//
// See also the <avt_analysis2notify example>.
//
//-----------------------------------------------------------------------------

class avt_analysis2notify #(type UVM=int, VMM=int, UVM2VMM=int) extends uvm_component;

  typedef avt_analysis2notify #(UVM,VMM,UVM2VMM) this_type;

  `uvm_component_param_utils(this_type)


  // Port: analysis_export
  //
  // The adapter receives UVM transactions via this analysis export.
  
  uvm_analysis_imp #(UVM,this_type) analysis_export;


  // Variable: notify
  //
  // The notify object that this adapter uses to indicate the <RECEIVED>
  // event notification.

  vmm_notify notify;


  // Variable: RECEIVED
  //
  // The notification id that this adapter indicates upon receipt of
  // UVM data from its <analysis_export>. 

  int RECEIVED;


  // Function: new
  //
  // Creates a new analysis-to-notify adapter with the given ~name~ and
  // optional ~parent~; the ~notify~ and ~notification_id~ together
  // specify the notification event that this adapter will indicate
  // upon receipt of a transaction on its <analysis_export>.
  //
  // If the ~notify~ handle is not supplied or null, the adapter will
  // create one and assign it to the <notify> property. If the 
  // ~notification_id~ is not provided, the adapter will configure a
  // ONE_SHOT notification and assign it to the <RECEIVED> property. 

   //instance of VMM log to capture messages. This is only constructed 
   //if notify is null.
   local vmm_log log;

  function new(string name, uvm_component parent=null,
               vmm_notify notify=null, int notification_id=-1);
    // All instances will be children of uvm_top, so give each a unique name
    super.new(name,parent);
    
    analysis_export = new("analysis_export",this);
    this.notify        = notify;
    if (notify == null) begin
      log              = new("vmm_log","vmm_notify2analysis_adapter_log");
      notify           = new(log);
    end
    if (notification_id == -1)
      notification_id  = notify.configure(-1,vmm_notify::ONE_SHOT);
    else
      if (notify.is_configured(notification_id) != vmm_notify::ONE_SHOT)
        begin
`ifdef UVM_ON_TOP
          uvm_report_fatal("Bad Notification ID",
                           $psprintf({"Notification id %0d not configured, ",
                                      "or not configured as ONE_SHOT"}, 
                                     notification_id));
`endif
`ifdef VMM_ON_TOP
          `vmm_fatal(log,
                     $psprintf({"Notification id %0d not configured, ",
                                "or not configured as ONE_SHOT"}, 
                               notification_id));
`endif
        end
    RECEIVED  = notification_id;
  endfunction


  // Function: write
  //
  // The write method, called via the <analysis_export>, converts
  // an incoming UVM transaction to its VMM counterpart, then indicates
  // the configured <RECEIVE> notification, passing the converted data
  // as status.

  virtual function void write(UVM t);
    VMM vmm_out;
    UVM uvm_in;
    if (t == null)
      return;

    assert($cast(uvm_in,t));
    vmm_out  = UVM2VMM::convert(uvm_in);
    notify.indicate(RECEIVED,vmm_out);
  endfunction

endclass
