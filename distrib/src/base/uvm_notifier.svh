//
//-----------------------------------------------------------------------------
//   Copyright 2013 Synopsys, Inc.
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
//-----------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// CLASS: uvm_notifier
//
// The uvm_notifier class provides a set of callbacks as notifications 
// for extension.
//
// A default notifier instance, <uvm_default_notifier>, is used when the
// notification is called.
//
//------------------------------------------------------------------------------

class uvm_notifier extends uvm_object;
  
  `uvm_object_utils(uvm_notifier)

  function new(string name = "uvm_notifier");
    super.new(name);
  endfunction
  
  virtual function void uvm_notify_component_creation(uvm_component comp);
    return;
  endfunction

  virtual function void uvm_notify_port_creation(uvm_component port_comp, string type_name);
    return;
  endfunction

  virtual function void uvm_notify_port_connection(uvm_component port_comp,
                                                   uvm_component provider_comp);
    return;
  endfunction

endclass
