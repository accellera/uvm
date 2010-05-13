//-----------------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corp.
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
//-----------------------------------------------------------------------------

`ifndef UVM_CB_MACROS_SVH
`define UVM_CB_MACROS_SVH


//-----------------------------------------------------------------------------
// Group: Callback Macros
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// MACRO: `uvm_register_cb
//
// Registers the given ~CB~ callback type with the given ~T~ object type. If
// a type-callback pair is not registered then a warning is issued if an
// attempt is made to use the pair (add, delete, etc.).
//
// The registration will typically occur in the component that executes the
// given type of callback. For instance:
//
//| virtual class mycb extends uvm_callback;
//|   virtual function void doit();
//| endclass
//|
//| class my_comp extends uvm_component;
//|   `uvm_register_cb(my_comp,mycb)
//|   ...
//|   task run;
//|     ...
//|     `uvm_do_callbacks(my_comp, mycb, doit())
//|   endtask
//| endclass
//-----------------------------------------------------------------------------

`define uvm_register_cb(T,CB) \
  static local bit m_register_cb_``CB = uvm_callbacks#(T,CB)::register_pair(`"T`",`"CB`");


//-----------------------------------------------------------------------------
// MACRO: `uvm_set_super_type
//
// Defines the super type of T to be ST. This allows for derived class
// objects to inherit typewide callbacks that are registered with the base
// class.
//
// The registration will typically occur in the component that executes the
// given type of callback. For instance:
//
//| virtual class mycb extend uvm_callback;
//|   virtual function void doit();
//| endclass
//|
//| class my_comp extends uvm_component;
//|   `uvm_register_cb(my_comp,mycb)
//|   ...
//|   task run;
//|     ...
//|     `uvm_do_callbacks(my_comp, mycb, doit())
//|   endtask
//| endclass
//|
//| class my_derived_comp extends my_comp;
//|   `uvm_set_super_type(my_derived_comp,my_comp)
//|   ...
//|   task run;
//|     ...
//|     `uvm_do_callbacks(my_comp, mycb, doit())
//|   endtask
//| endclass
//-----------------------------------------------------------------------------

`define uvm_set_super_type(T,ST) \
  static local bit m_register_``T``ST = uvm_derived_callbacks#(T,ST)::register_super_type(`"T`",`"ST`"); 


//-----------------------------------------------------------------------------
// MACRO: `uvm_do_callbacks
//
// Calls the given ~METHOD~ of all callbacks of type ~CB~ registered with
// the calling object (i.e. ~this~ object), which is or is based on type ~T~.
//
// This macro executes all of the callbacks associated with the calling
// object (i.e. ~this~ object). The macro takes three arguments:
//
// - CB is the class type of the callback objects to execute. The class
//   type must have a function signature that matches the METHOD argument.
//
// - T is the type associated with the callback. Typically, an instance
//   of type T is passed as one the arguments in the ~METHOD~ call.
//
// - METHOD is the method call to invoke, with all required arguments as
//   if they were invoked directly.
//
// For example, given the following callback class definition:
//
//| virtual class mycb extends uvm_cb;
//|   pure function void my_function (mycomp comp, int addr, int data);
//| endclass
//
// A component would invoke the macro as
//
//| task mycomp::run(); 
//|    int curr_addr, curr_data;
//|    ...
//|    `uvm_do_callbacks(mycb, mycomp, my_function(this, curr_addr, curr_data))
//|    ...
//| endtask
//-----------------------------------------------------------------------------


`define uvm_do_callbacks(T,CB,METHOD_CALL) \
  `uvm_do_obj_callbacks(T,CB,this,METHOD_CALL)


//-----------------------------------------------------------------------------
// MACRO: `uvm_do_obj_callbacks
//
// Calls the given ~METHOD~ of all callbacks based on type ~CB~ registered with
// the given object, ~OBJ~, which is or is based on type ~T~.
//
// This macro is identical to <`uvm_do_callbacks> macro,
// but it has an additional ~OBJ~ argument to allow the specification of an
// external object to associate the callback with. For example, if the
// callbacks are being applied in a sequence, ~OBJ~ could be specified
// as the associated sequencer or parent sequence.
//
//|    ...
//|    `uvm_do_callbacks(mycb, mycomp, seqr, my_function(seqr, curr_addr, curr_data))
//|    ...
//-----------------------------------------------------------------------------

`define uvm_do_obj_callbacks(T,CB,OBJ,METHOD_CALL) \
   begin \
     uvm_callback_iter#(T,CB) iter = new(OBJ); \
     CB cb = iter.first(); \
     while(cb != null) begin \
       `uvm_cb_trace_noobj(cb,$sformatf(`"Executing callback method METHOD_CALL for callback %s (CB) from %s (T)`",cb.get_name(), OBJ.get_full_name())) \
       cb.METHOD_CALL; \
       cb = iter.next(); \
     end \
   end




//-----------------------------------------------------------------------------
// MACRO: `uvm_do_callbacks_exit_on
//
// Calls the given ~METHOD~ of all callbacks of type ~CB~ registered with
// the calling object (i.e. ~this~ object), which is or is based on type ~T~,
// returning upon the first callback returning the bit value given by ~VAL~.
//
// This macro executes all of the callbacks associated with the calling
// object (i.e. ~this~ object). The macro takes three arguments:
//
// - CB is the class type of the callback objects to execute. The class
//   type must have a function signature that matches the METHOD argument.
//
// - T is the type associated with the callback. Typically, an instance
//   of type T is passed as one the arguments in the ~METHOD~ call.
//
// - METHOD is the method call to invoke, with all required arguments as
//   if they were invoked directly.
//
// - VAL, if 1, says return upon the first callback invocation that
//   returns 1. If 0, says return upon the first callback invocation that
//   returns 0.
//
// For example, given the following callback class definition:
//
//| virtual class mycb extends uvm_cb;
//|   pure function bit drop_trans (mycomp comp, my_trans trans);
//| endclass
//
// A component would invoke the macro as
//
//| task mycomp::run(); 
//|    my_trans trans;
//|    forever begin
//|      get_port.get(trans);
//|      if (`uvm_do_callbacks_exit_on(mycomp, mycb, extobj, drop_trans(this,trans), 1)
//|        uvm_report_info("DROPPED",{"trans dropped: %s",trans.convert2string()});
//|      // execute transaction
//|    end
//| endtask
//-----------------------------------------------------------------------------


`define uvm_do_callbacks_exit_on(T,CB,METHOD_CALL,VAL) \
  `uvm_do_obj_callbacks_exit_on(T,CB,this,METHOD_CALL,VAL) \


//-----------------------------------------------------------------------------
// MACRO: `uvm_do_obj_callbacks_exit_on
//
// Calls the given ~METHOD~ of all callbacks of type ~CB~ registered with
// the given object ~OBJ~, which must be or be based on type ~T~, and returns
// upon the first callback that returns the bit value given by ~VAL~. It is
// exactly the same as the <`uvm_do_callbacks_exit_on> but has a specific
// object instance (instead of the implicit this instance) as the third
// argument.
//
//| ...
//|  if (`uvm_do_callbacks_exit_on(mycb, mycomp, seqr, drop_trans(seqr,trans), 1))
//| ...
//-----------------------------------------------------------------------------

`define uvm_do_obj_callbacks_exit_on(T,CB,OBJ,METHOD_CALL,VAL) \
   begin \
     uvm_callback_iter#(T,CB) iter = new(OBJ); \
     CB cb = iter.first(); \
     while(cb != null) begin \
       if (cb.METHOD_CALL == VAL) begin \
         `uvm_cb_trace_noobj(cb,$sformatf(`"Executed callback method METHOD_CALL for callback %s (CB) from %s (T) : returned value VAL (other callbacks will be ignored)`",cb.get_name(), OBJ.get_full_name())) \
         return VAL; \
       end \
       `uvm_cb_trace_noobj(cb,$sformatf(`"Executed callback method METHOD_CALL for callback %s (CB) from %s (T) : did not return value VAL`",cb.get_name(), OBJ.get_full_name())) \
       cb = iter.next(); \
     end \
     return 1-VAL; \
   end


// callback trace macros can be turned on via +define+UVM_CB_TRACE_ON

`ifdef UVM_CB_TRACE_ON

`define uvm_cb_trace(OBJ,CB,OPER) \
  begin \
    string msg; \
    msg = (OBJ == null) ? "null" : $sformatf("%s (%s@%0d)", \
      OBJ.get_full_name(), OBJ.get_type_name(), OBJ.get_inst_id()); \
    `uvm_info("UVMCB_TRC", $sformatf("%s: callback %s (%s@%0d) : to object %s",  \
       OPER, CB.get_name(), CB.get_type_name(), CB.get_inst_id(), msg), UVM_NONE) \
  end

`define uvm_cb_trace_noobj(CB,OPER) \
  begin \
    if(uvm_callbacks_base::m_tracing) \
      `uvm_info("UVMCB_TRC", $sformatf("%s : callback %s (%s@%0d)" ,  \
       OPER, CB.get_name(), CB.get_type_name(), CB.get_inst_id()), UVM_NONE) \
  end
`else

`define uvm_cb_trace_noobj(CB,OPER) /* null */
`define uvm_cb_trace(OBJ,CB,OPER) /* null */

`endif


`endif
