//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics, Corp.
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

`include "uvm_macros.svh"

`ifndef UVM_CALLBACK_SVH
`define UVM_CALLBACK_SVH

// Internal convenience macros used in implementation. Not for users.
`define _UVM_CB_MSG_NULL_OBJ(FUNC) \
   `"uvm_callback::FUNC - Object argument is null`"

`define _UVM_CB_MSG_NULL_CB(FUNC) \
   $sformatf(`"uvm_callback::FUNC - Callback argument for object '%s' is null`", \
    (obj==null?"null":obj.get_full_name()))

`define _UVM_CB_MSG_NO_CBS(FUNC)  \
   $sformatf(`"uvm_callback::FUNC - No callbacks registered with object '%s'`",\
    (obj==null?"null":obj.get_full_name()))

`define _UVM_CB_MSG_NOT_REG(FUNC) \
   $sformatf(`"uvm_callback::FUNC - Callback '%s' not registered with object '%s'`",cb.get_name(), \
    (obj==null?"null":obj.get_full_name()))


//------------------------------------------------------------------------------
//
// CLASS: uvm_callbacks #(T,CB)
//
// The ~uvm_callbacks~ class provides a base class for implementing callbacks,
// which are typically used to modify or augment component behavior without
// changing the component class. To work effectively, the developer of the
// component class defines a set of "hook" methods that enable users to
// customize certain behaviors of the component in a manner that is controlled
// by the component developer. The integrity of the component's overall behavior
// is intact, while still allowing certain customizable actions by the user.
// 
// To enable compile-time type-safety, the class is parameterized on both the
// user-defined callback interface implementation as well as the object type
// associated with the callback. 
//
// To provide the most flexibility for end-user customization and reuse, it
// is recommended that the component developer also define a corresponding set
// of virtual method hooks in the component itself. This affords users the ability
// to customize via inheritance/factory overrides as well as callback object
// registration. The implementation of each virtual method would provide the
// default traversal algorithm for the particular callback being called. Being
// virtual, users can define subtypes that override the default algorithm,
// perform tasks before and/or after calling super.<method> to execute any
// registered callbacks, or to not call the base implementation, effectively
// disabling that particalar hook. A demonstration of this methodology is
// provided in an example included in the kit.
//------------------------------------------------------------------------------

class uvm_callbacks #(type T=int, CB=int) extends uvm_pool #(T,uvm_queue #(CB));
  // Parameter: T
  //
  // This type parameter specifies the base object type with which the
  // <CB> callback objects will be registered.

  // Parameter: CB
  //
  // This type parameter specifies the base callback type that will be
  // managed by this callback class. The callback type is typically a
  // interface class, which defines one or more virtual method prototypes 
  // that users can override in subtypes.
  
  typedef uvm_callbacks #(T,CB) this_type;
  typedef uvm_queue #(CB) queue_t;
  typedef uvm_pool #(T,queue_t) pool_t;

  static uvm_report_object reporter = new("cb_tracer");

  // `uvm_object_param_utils(this_type)

  // Function: new
  //
  // Creates a new uvm_callbacks object, giving it an optional ~name~.

  function new(string name="uvm_callback");
    super.new(name);
  endfunction


  // Function: get_global_cbs
  //
  // Returns the global callback pool for this type.
  //
  // This allows items to be shared amongst components throughout the
  // verification environment.

  static this_type m_global_cbs;

  static function this_type get_global_cbs ();
    if (m_global_cbs==null)
      m_global_cbs = new("pool");
    return m_global_cbs;
  endfunction


  // Function: add_cb
  //
  // Registers the given callback object, ~cb~, with the given
  // ~obj~ handle. The ~obj~ handle can be null, which allows 
  // registration of callbacks without an object context. If
  // ~append~ is 1 (default), the callback will be executed
  // after previously added callbacks, else  the callback
  // will be executed ahead of previously added callbacks.

  virtual function void add_cb(T obj, CB cb, bit append=1);
    queue_t cbq;
    if (obj == null) begin
      uvm_report_error("NULL_OBJ",`_UVM_CB_MSG_NULL_OBJ(add_cb));
      return;
    end
    if (cb == null) begin
      uvm_report_error("NULL_CB",`_UVM_CB_MSG_NULL_CB(add_cb));
      return;
    end
    cbq = get(obj);
    if (append)
      cbq.push_back(cb);
    else
      cbq.push_front(cb);
    `uvm_cb_trace(obj,cb,"add callback")
  endfunction

  
  // Function: delete_cb
  //
  // Removes a previously registered callback, ~cb~, for the given
  // object, ~obj~. 

  virtual function void delete_cb(T obj, CB cb);
    queue_t cbq;
    bit found;
    if (obj == null) begin
      uvm_report_error("NULL_OBJ",`_UVM_CB_MSG_NULL_OBJ(add_cb));
      return;
    end
    if (!exists(obj)) begin
      uvm_report_warning("NO_CBS",`_UVM_CB_MSG_NO_CBS(delete_cb));
      return;
    end
    if (cb == null) begin
      uvm_report_error("NULL_CB",`_UVM_CB_MSG_NULL_CB(delete_cb));
      return;
    end
    cbq = get(obj);
    for (int i=cbq.size()-1; i >= 0; i--) begin
      if (cbq.get(i) == cb) begin
        cbq.delete(i);
        `uvm_cb_trace(obj,cb,$sformatf("delete callback from positon %0d", i))
        found=1;
      end
    end
    if (!found)
      uvm_report_error("CB_NOT_REG",`_UVM_CB_MSG_NOT_REG(delete_cb));
    else
      if(cbq.size() == 0)
        delete(obj);

  endfunction


  // Function: trace_mode
  //
  // This function takes a single argument to turn on (1) or off (0) tracing.
  // The default is to turn tracing on.

  function void trace_mode(bit mode);
    if(mode)
      reporter.set_report_id_action("TRACE_CB", UVM_DISPLAY|UVM_LOG);
    else
      reporter.set_report_id_action("TRACE_CB", UVM_NO_ACTION);
  endfunction


  // Function: display_cbs
  //
  // Displays information about all registered callbacks for the
  // given ~obj~ handle. If ~obj~ is not provided or is null, then
  // information about all callbacks for all objects is displayed.

  function void display_cbs(T obj=null);

    if (obj == null) begin
      if (first(obj))
        do 
          display_cbs(obj);
        while (next(obj));
      else
        uvm_report_info("SHOWCBQ", "No callbacks registered", UVM_NONE);
      return;
    end

    if (exists(obj)) begin
      queue_t cbq;
      cbq = get(obj);
      uvm_report_info("SHOWCBQ", 
        $sformatf("The callback queue for object '%s' has %0d elements",
         (obj==null?"null":obj.get_full_name()), cbq.size()), UVM_NONE);
      for (int i=0;i<cbq.size();i++) begin
        CB cb;
        cb = cbq.get(i);
        $display("    %0d:  name=%s type=%s (%s)",
          i, cb.get_name(), cb.get_type_name(),
          cb.is_enabled() ? "enabled" : "disabled");
      end
    end
    else begin
      uvm_report_info("SHOWCBQ",
        {"The callback queue for object '", obj.get_full_name(),
          "' is empty."}, UVM_NONE);
    end
  endfunction
  
endclass


//------------------------------------------------------------------------------
// CLASS: uvm_callback
//
// The ~uvm_callback~ class is the base class for user-defined callback classes.
// Typically, the component developer defines an application-specific callback
// class that extends from this class. In it, he defines one or more virtual
// methods, called a ~callback interface~, that represent the hooks available
// for user override. 
//
// Methods intended for optional override should not be declared ~pure.~ Usually,
// all the callback methods are defined with empty implementations so users have
// the option of overriding any or all of them.
//
// The prototypes for each hook method are completely application specific with
// no restrictions.
//------------------------------------------------------------------------------

class uvm_callback extends uvm_object;

  static uvm_report_object reporter = new("cb_tracer");

  protected bit m_enabled = 1;

  // Function: new
  //
  // Creates a new uvm_callback object, giving it an optional ~name~.

  function new(string name="uvm_callback");
    super.new(name);
  endfunction

  // Function: callback_mode
  //
  // Enable/disable callbacks (modeled like rand_mode and constraint_mode).

  function void callback_mode(bit on);
    `uvm_cb_trace_noobj(this,$sformatf("callback_mode(%0d) %s (%s)",
                         on, get_name(), get_type_name(), this))
    m_enabled = on;
  endfunction

  // Function: is_enabled
  //
  // Returns 1 if the callback is enabled, 0 otherwise.

  function bit is_enabled();
    return m_enabled;
  endfunction

  static string type_name = "uvm_callback";

  // Function: get_type_name
  //
  // Returns the type name of this callback object.

  virtual function string get_type_name();
     return type_name;
  endfunction

endclass


`endif // UVM_CALLBACK_SVH


