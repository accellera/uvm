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
   $sformatf(`"uvm_callback::FUNC - Callback '%s' not registered with object '%s'`",cb.get_type_name(), \
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

typedef class uvm_callback;

// Pool has to be generic so that type checking can be done and derivative
// types can be mapped to base types.
class uvm_callbacks #(type T=uvm_object, CB=uvm_callback, ST=T, SCB=CB) 
    extends uvm_pool #(uvm_object,uvm_queue #(uvm_callback));

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

  // Parameter: ST
  //
  // This type parameter specifies the super type of the base object type 
  // with which the <CB> callback objects will be registered. This parameter
  // is only required during registration of T-CB pairs for a case where
  // either the base type or the cb type is a derivative which must use
  // the queue from the ST-SCB pair. 

  // Parameter: SCB
  //
  // This type parameter specifies the super type of the base callback type 
  // that will be managed by this callback class. The callback type is typically a
  // interface class, which defines one or more virtual method prototypes 
  // that users can override in subtypes. This parameter is only needed during
  // registration of a derivative CB type that is used in multiple object types
  // that are in the same class hierarchy.

 
  typedef uvm_callbacks #(T,CB,ST,SCB) this_type;
  typedef uvm_queue #(CB) queue_t;     //for returning. Actual queue is untyped.
  typedef uvm_queue#(uvm_callback) generic_queue_t;
  typedef uvm_callbacks #(uvm_object,uvm_callback) generic_type;

  // Setup the singleton instance. The facade uses the static interface, so
  // the singleton object is intended just for the internal functions.
  static generic_type m_inst = get_inst();
  static function generic_type get_inst();
    if(m_inst == null) begin
      m_inst = new;
    end
    //Check if this is a derivative type and if so, set the instance to
    //use to be the derivative.
    if(m_inst != uvm_callbacks#(ST,SCB)::m_inst) begin 
      m_inst=uvm_callbacks#(ST,SCB)::get_inst();
    end
    return m_inst;
  endfunction

  // A list of all of the callback queues. Contains all registered and 
  // unregistered queues. If a queue is unregistered then that is noted
  // if the queue is printed.

  static bit m_queues[generic_queue_t];

  // Reporter object for this callback object.
  static uvm_report_object reporter = new("cb_tracer");

  `uvm_object_param_utils(this_type)

  // Function: new
  //
  // Creates a new uvm_callbacks object, giving it an optional ~name~.

  function new(string name="uvm_callbacks");
    super.new(name);
  endfunction

  // Group: Type Safety Registration

  // Function: register_pair
  //
  // This function registers a type/callback pair. This should be called
  // inside of the IP which uses the type/callback pair. If an end user
  // attempts to add/remove/access a callback for an unregistered type/callback
  // pairing, a warning is issued. The macro <`uvm_register_cb> may
  // be used in the IP class as a simple way of doing the registration.
  //
  //| virtual class mycb extends uvm_callback;
  //|   pure virtual function void doit();
  //| endclass
  //| class my_ip_class extends ovm_component;
  //|   `uvm_register_cb(my_ip_class,mycb)
  //|   ...
  //|   task doit;
  //|     `uvm_do_callbacks(mycb,my_ip_class,doit())
  //|     ...
  //|   endtask
  //| endclass

  static bit m_is_registered = 0;

  static function bit register_pair();
    m_is_registered = 1;
  endfunction

  // Function: register_derived_pair
  //
  // This function registers a type/callback pair for a derivative type that
  // is using the same callback (or a derivative) callback as is used in its
  // super type. The effect of the registration is to ensure that the callback
  // queue is associated with the super type so that any callbacks that should
  // apply to both the super type and this type will be used in both contexts.
  // The macro <`uvm_register_extended_cb> may be used in the IP class as a simple 
  // way of doing the registration.
  //
  //| virtual class mycb extends uvm_callback;
  //|   pure virtual function void doit();
  //| endclass
  //| class my_ip_class extends ovm_component;
  //|   `uvm_register_cb(my_ip_class,mycb)
  //|   ...
  //|   task doit;
  //|     `uvm_do_callbacks(mycb,my_ip_class,doit())
  //|     ...
  //|   endtask
  //| endclass
  //| class my_extended_ip_class extends my_ip_class;
  //|   `uvm_register_derived_cb(my_ip_class,mycb,my_extended_ip_class,mycb)
  //|   ...
  //|   task a_new_task;
  //|     `uvm_do_callbacks(mycb,my_ip_class,doit())
  //|     ...
  //|   endtask
  //| endclass



  static function bit register_derived_pair();
    if(uvm_callbacks#(T,CB,T,CB)::get_inst() != uvm_callbacks#(T,CB,ST,SCB)::get_inst()) begin
      //WARNING, REDEFINING BASE CLASS
    end
    //Set the inst for both the 4 arg and 2 arg versions of the type to point
    //to the super type singleton.
    m_inst = uvm_callbacks#(ST,SCB)::get_inst();
    uvm_callbacks#(T,SCB)::m_inst = m_inst;
    uvm_callbacks#(T,CB,T,CB)::m_inst = m_inst;
    uvm_callbacks#(T,CB)::m_inst = m_inst;

    //Register the legal variants
    void'(uvm_callbacks#(T,CB,T,CB)::register_pair());
    void'(uvm_callbacks#(T,CB)::register_pair());
    void'(uvm_callbacks#(T,SCB)::register_pair());
    void'(uvm_callbacks#(ST,SCB,ST,SCB)::register_pair());
  endfunction

  // Group: Iterators
  //
  // The iterator functions provide a convienient way to traverse the callback queue, or
  // to get a copy of the callback queue. The example below shows how to iterate the
  // callback queue accessing all of the enabled callbacks:
  //
  //| int iter;
  //| for (mycb cb = uvm_callbacks#(mytype,mycb)::get_first_cb(iter,this);
  //|           cb != null; cb = uvm_callbacks#(mytype,mycb)::get_next_cb(iter,this))
  //|   begin
  //|     cb.do_cb_function();
  //|   end

  // Function: get_cbs
  //
  // The function returns a queue of callbacks for ~obj~. A callback is only returned
  // if it is currently enabled. Also, the callback type must be a derivative of
  // ~CB~ in order to be returned in the queue.

  static function uvm_queue#(SCB) get_cbs(T obj);
    SCB cb;
    generic_queue_t q = m_inst.m_get_cbs(obj,get_inst());
    get_cbs = new;
    for(int i=0; i<q.size(); ++i) if($cast(cb,q.get(i))) get_cbs.push_back(cb);
  endfunction

  function generic_queue_t m_get_cbs(T obj, generic_type inst);
    generic_queue_t q = inst.get(obj);
    uvm_callback cb;

    m_get_cbs = new;
    //if the queue is empty then add typewide callbacks, otherwise the typewide
    //cbs are already in the instance queue.
    if(!q.size()) q = inst.get(null);

    for(int i=0; i<q.size(); ++i) begin
      cb = q.get(i);
      if(cb.is_enabled()) m_get_cbs.push_back(cb);
    end
  endfunction


  // Function: get_all_cbs
  //
  // The function returns a queue of callbacks for ~obj~. A callback is returned
  // whether or not it is currently enabled. The callback type must be a derivative of
  // ~CB~ in order to be returned in the queue.

  static function queue_t get_all_cbs(T obj);
    uvm_callback cb;
    CB scb;
    generic_queue_t q = m_inst.m_get_all_cbs(obj, get_inst()); 

    get_all_cbs = new;
    for(int i=0; i<q.size(); ++i) begin
      cb = q.get(i);
      if($cast(scb,cb)) get_all_cbs.push_back(scb);
    end
  endfunction

  //For efficiency of the iterators, the m_get_all_cbs returns a pointer
  //to the actual queue. This avoids a lot of unnecessary allocation and
  //copying during iteration.

  function generic_queue_t m_get_all_cbs(T obj, generic_type inst);
    m_get_all_cbs = inst.get(obj);

    //If the inst queue is empty return just the typewide queue.    
    if(!m_get_all_cbs.size()) m_get_all_cbs = inst.get(null);
  endfunction


  //Function: get_first_cb
  //
  //Returns the first enabled callback of type ~CB~ (or derivative) that lives
  //in the callback queue. If no callback is found then null is returned.
  //The ~iter~ object is set to the location in the queue where the callback
  //was found. 

  static function CB get_first_cb(ref int iter, input T obj);
    $cast(get_first_cb,m_inst.m_get_first_cb(iter,obj,get_inst()));
  endfunction

  function CB m_get_first_cb(ref int iter, input T obj,generic_type m_inst);
    uvm_callback cb;
    CB scb;
    uvm_queue#(uvm_callback) q = m_inst.m_get_all_cbs(obj,m_inst);
    for(int i=0; i<q.size(); ++i) begin
      cb = q.get(i);
      if(cb.is_enabled() && $cast(scb,cb)) begin
        iter = i;
        return scb;
      end
    end
    return null;
  endfunction


  //Function: get_next_cb
  //
  //Returns the next enabled callback of type ~CB~ (or derivative) that lives
  //in the callback queue using ~iter~ as the starting point for the search. 
  //If no callback is found then null is returned. The ~iter~ object is set to the 
  //location in the queue where the callback was found. 

  static function CB get_next_cb(ref int iter, input T obj);
    $cast(get_next_cb,m_inst.m_get_next_cb(iter,obj,get_inst()));
  endfunction

  function CB m_get_next_cb(ref int iter, input T obj, generic_type m_inst);
    uvm_callback cb;
    CB scb;
    uvm_queue#(uvm_callback) q = m_inst.m_get_all_cbs(obj,m_inst);
    for(int i=iter+1; i<q.size(); ++i) begin
      cb = q.get(i);
      if(cb.is_enabled() && $cast(scb,cb)) begin
        iter = i;
        return scb;
      end
    end
    return null;
  endfunction


  // Function: get_global_cbs
  //
  // Returns the global callback pool for this type.
  //
  // This allows items to be shared amongst components throughout the
  // verification environment.

  static function  uvm_callbacks #(T,CB) get_global_cbs ();
    generic_type inst = get_inst();
    uvm_object obj;
    T objt;

    get_global_cbs = new;

    if (inst.first(obj))
      do begin
        if($cast(objt,obj))
          get_global_cbs.add(objt,inst.get(objt));
      end while (inst.next(obj));
  endfunction


  // Group: Insertion/deletion interface

  // Function: add_cb
  //
  // Registers the given callback object, ~cb~, with the given
  // ~obj~ handle. The ~obj~ handle can be null, which allows 
  // registration of callbacks without an object context. If
  // ~append~ is 1 (default), the callback will be executed
  // after previously added callbacks, else  the callback
  // will be executed ahead of previously added callbacks.

//  virtual function void add_cb(T obj, CB cb, bit append=1);
  static function void add_cb(T obj, CB cb, bit append=1);
    generic_type inst = get_inst();
    generic_queue_t cbq, twq;
    uvm_object gobj=obj;

    if (cb == null) begin
      uvm_report_error("NULL_CB",`_UVM_CB_MSG_NULL_CB(add_cb));
      return;
    end
    if(!m_is_registered) begin
      uvm_report_warning("CBUNREG", $sformatf("Callback type %s%s%s", 
        cb.get_type_name(), " is not registered for object ", ((obj != null) ?
        obj.get_full_name() : "(*)")), UVM_NONE);
    end
    cbq = inst.get(gobj);
    if (gobj == null) begin
      //Adding a typewide callback. Need to add to all instances
      //as well as the typewide queue.
      if (inst.first(gobj))
        do begin
          cbq = inst.get(gobj);
          if(append) cbq.push_back(cb);
          else cbq.push_front(cb);
        end while (inst.next(gobj));
      return;
    end
    if(cbq.size() == 0) begin
      m_queues[cbq] = 1;
      //add typewide callbacks
      twq = inst.get(null);
      for(int i=0; i<twq.size(); ++i) cbq.push_back(twq.get(i));
    end
    if (append)
      cbq.push_back(cb);
    else
      cbq.push_front(cb);
    `uvm_cb_trace(gobj,cb,"add callback")
  endfunction

  
  // Function: delete_cb
  //
  // Removes a previously registered callback, ~cb~, for the given
  // object, ~obj~. 

//  virtual function void delete_cb(T obj, CB cb);
  static function void delete_cb(T obj, CB cb);
    generic_type inst = get_inst();
    generic_queue_t cbq, twq;
    uvm_object gobj = obj;
    bit found;

    if (!inst.exists(gobj)) begin
      uvm_report_warning("NO_CBS",`_UVM_CB_MSG_NO_CBS(delete_cb));
      return;
    end
    if (cb == null) begin
      uvm_report_error("NULL_CB",`_UVM_CB_MSG_NULL_CB(delete_cb));
      return;
    end
    cbq = inst.get(gobj);

    // for typewide, need to remove from all queues
    if (gobj == null) begin
      if (inst.first(gobj))
        do begin
          cbq = inst.get(gobj); 
          for (int i=cbq.size()-1; i >= 0; i--) begin
            if (cbq.get(i) == cb) begin
              cbq.delete(i);
              `uvm_cb_trace(gobj,cb,$sformatf("delete typewide callback from positon %0d", i))
              found=1;
            end
          end
          if(cbq.size() == 0) begin
            inst.delete(cbq);
            m_queues.delete(cbq);
          end
        end while (inst.next(gobj));      
    end
    else begin
      for (int i=cbq.size()-1; i >= 0; i--) begin
        if (cbq.get(i) == cb) begin
          cbq.delete(i);
          `uvm_cb_trace(gobj,cb,$sformatf("delete callback from positon %0d", i))
          found=1;
        end
      end
      if(cbq.size() == 0) begin
        inst.delete(gobj);
        m_queues.delete(cbq);
      end
    end

    if (!found)
      uvm_report_error("CB_NOT_REG",`_UVM_CB_MSG_NOT_REG(delete_cb));

  endfunction


  // Function: trace_mode
  //
  // This function takes a single argument to turn on (1) or off (0) tracing.
  // The default is to turn tracing on.

  static function void trace_mode(bit mode);
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

//  virtual function void display_cbs(T obj=null,bit all=1);
  static function void display_cbs(T obj=null,bit all=1);
    generic_type inst = get_inst();
    generic_queue_t cbq;
    uvm_object gobj=obj;
    if (all && obj==null) begin
      if (inst.first(gobj))
        do 
          if($cast(obj,gobj)) display_cbs(obj,0);
        while (inst.next(gobj));
      else
        uvm_report_info("SHOWCBQ", "No callbacks registered", UVM_NONE);
      return;
    end

    if (inst.exists(gobj)) begin
      cbq = inst.get(gobj);
      uvm_report_info("SHOWCBQ", 
        $sformatf("The callback queue for object '%s' has %0d elements",
         (gobj==null?"(*)":gobj.get_full_name()), cbq.size()), UVM_NONE);
      for (int i=0;i<cbq.size();i++) begin
        uvm_callback cb;
        cb = cbq.get(i);
        $display("    %0d:  name=%s type=%s (%s)",
          i, cb.get_name(), cb.get_type_name(),
          cb.is_enabled() ? "enabled" : "disabled");
      end
    end
    else begin
      uvm_report_info("SHOWCBQ",
        $sformatf("The callback queue for object '%s' is empty", 
          (gobj==null?"(*)":gobj.get_full_name())), UVM_NONE); 
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


