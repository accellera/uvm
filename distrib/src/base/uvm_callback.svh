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
class uvm_callbacks #(type T=uvm_object, CB=uvm_callback, ST=uvm_object)
    extends uvm_object;

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
  // the base type is a derivative of a type which also uses CB.

  typedef uvm_callbacks #(T,CB,ST) this_type;
  typedef uvm_queue #(CB) queue_t;     //for returning. Actual queue is untyped.
  typedef uvm_queue#(uvm_callback) generic_queue_t;
  typedef uvm_pool#(uvm_object,uvm_queue#(uvm_callback)) pool_t;
  typedef uvm_callbacks #(uvm_object,uvm_callback) generic_type;

  // Setup the singleton instance. The facade uses the static interface, so
  // the singleton object is intended just for the internal functions. The
  // instance is type-unsafe so type checking is done dynamically.
  static generic_type m_inst = get_inst();
  static function generic_type get_inst();
    if(m_inst == null) begin
      m_inst = new;
    end
    return m_inst;
  endfunction

  // Add list of registered super types and derivative types.
  generic_type m_super_types[$];
  generic_type m_derived_types[$];

  // The actual pool. Need this because the callback methods add/delete
  // are the same as the pool methods.
  pool_t m_pool = new;

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
  //| class my_ip_class extends uvm_component;
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
    uvm_callbacks#(uvm_object,uvm_callback)::m_is_registered = 1;
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
  //| class my_ip_class extends uvm_component;
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
    generic_type me = uvm_callbacks#(T,CB)::get_inst();
    generic_type b = uvm_callbacks#(ST,CB)::get_inst();

    if(me == b) return 1;
    void'(uvm_callbacks#(T,CB)::register_pair());
    void'(uvm_callbacks#(T,uvm_callback)::register_pair());
    void'(uvm_callbacks#(uvm_object,uvm_callback)::register_pair());

    b.m_derived_types.push_back(me);
    me.m_super_types.push_back(b);
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

  static function queue_t get_cbs(T obj);
    generic_queue_t q = m_inst.m_pool.get(obj);
    uvm_callback cb;
    CB tcb;

    get_cbs = new;
    //if the queue is empty then add typewide callbacks, otherwise the typewide
    //cbs are already in the instance queue.
    if(!q.size()) q = m_inst.m_pool.get(null);

    for(int i=0; i<q.size(); ++i) begin
      cb = q.get(i);
      if(cb.is_enabled() && $cast(tcb,cb)) get_cbs.push_back(tcb);
    end
  endfunction


  // Function: get_all_cbs
  //
  // The function returns a queue of callbacks for ~obj~. A callback is returned
  // whether or not it is currently enabled. The callback type must be a derivative of
  // ~CB~ in order to be returned in the queue.

  static function queue_t get_all_cbs(T obj);
    generic_queue_t q = m_inst.m_pool.get(obj);
    uvm_callback cb;
    CB tcb;

    get_all_cbs = new;
    //if the queue is empty then add typewide callbacks, otherwise the typewide
    //cbs are already in the instance queue.
    if(!q.size()) q = m_inst.m_pool.get(null);

    for(int i=0; i<q.size(); ++i) begin
      cb = q.get(i);
      if($cast(tcb,cb)) get_all_cbs.push_back(tcb);
    end
  endfunction


  //Function: get_first_cb
  //
  //Returns the first enabled callback of type ~CB~ (or derivative) that lives
  //in the callback queue. If no callback is found then null is returned.
  //The ~iter~ object is set to the location in the queue where the callback
  //was found. 

  static function CB get_first_cb(ref int iter, input T obj);
    uvm_callback cb;
    CB scb;
    generic_queue_t q = m_inst.m_pool.get(obj);
    if(!q.size()) q = m_inst.m_pool.get(null);
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
    uvm_callback cb;
    CB scb;
    generic_queue_t q = m_inst.m_pool.get(obj);
    if(!q.size()) q = m_inst.m_pool.get(null);
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

    //copy the generic pool to the type specific pool
    if (inst.m_pool.first(obj))
      do begin
        if($cast(objt,obj))
          get_global_cbs.m_pool.add(objt,inst.m_pool.get(objt));
      end while (inst.m_pool.next(obj));
  endfunction


  // Group: Insertion/deletion interface

  // Function: add
  //
  // Registers the given callback object, ~cb~, with the given
  // ~obj~ handle. The ~obj~ handle can be null, which allows 
  // registration of callbacks without an object context. If
  // ~ordering~ is UVM_APPEND (default), the callback will be executed
  // after previously added callbacks, else  the callback
  // will be executed ahead of previously added callbacks.
  //
  // The callback must also be registered with super types
  // and with derived types.

  static function void add(T obj, CB cb, uvm_apprepend ordering=UVM_APPEND);
    generic_type inst = get_inst();
    if (cb == null) begin
      uvm_report_error("NULL_CB",`_UVM_CB_MSG_NULL_CB(add));
      return;
    end
    if(!m_is_registered) begin
      uvm_report_warning("CBUNREG", $sformatf("Callback type %s%s%s", 
        cb.get_type_name(), " is not registered for object ", ((obj != null) ?
        obj.get_type_name() : "(*)")), UVM_NONE);
    end
    inst.m_add(obj,cb,ordering);
    //Only add to direcly derived types
    foreach(inst.m_derived_types[i]) begin
      inst.m_derived_types[i].m_add(obj,cb,ordering);
    end
    inst.m_add_super_cbs(obj,cb,ordering);
  endfunction

  // Need to chain the super class callbacks so that all
  // of the class hierarchy is in sync.
  function void m_add_super_cbs(uvm_object obj, uvm_callback cb, uvm_apprepend ordering);
    foreach(m_super_types[i]) begin
      m_super_types[i].m_add(obj,cb,ordering);
      m_super_types[i].m_add_super_cbs(obj,cb,ordering);
    end
  endfunction

  function void m_add(uvm_object obj, uvm_callback cb, uvm_apprepend ordering);
    generic_queue_t cbq, twq;

    cbq = m_pool.get(obj);
    if (obj == null) begin
      //Adding a typewide callback. Need to add to all instances
      //as well as the typewide queue.
      if (m_pool.first(obj))
        do begin
          cbq = m_pool.get(obj);
          if(ordering==UVM_APPEND) cbq.push_back(cb);
          else cbq.push_front(cb);
        end while (m_pool.next(obj));
      return;
    end
    if(cbq.size() == 0) begin
      //add typewide callbacks
      twq = m_pool.get(null);
      for(int i=0; i<twq.size(); ++i) cbq.push_back(twq.get(i));
    end
    if (ordering==UVM_APPEND) begin
      cbq.push_back(cb);
    end
    else begin
      cbq.push_front(cb);
    end
    `uvm_cb_trace(obj,cb,"add callback")
  endfunction

  
  // Function: delete
  //
  // Removes a previously registered callback, ~cb~, for the given
  // object, ~obj~. 

  static function void delete(T obj, CB cb);
    generic_type inst = get_inst();
    if (cb == null) begin
      uvm_report_error("NULL_CB",`_UVM_CB_MSG_NULL_CB(delete));
      return;
    end
    inst.m_delete(obj,cb);
    //Only add to direcly derived types
    foreach(inst.m_derived_types[i]) inst.m_derived_types[i].m_delete(obj,cb,0);
  endfunction


  function void m_delete(T obj, CB cb, bit check_queue=1);
    generic_queue_t cbq, twq;
    uvm_object gobj = obj;
    bit found;

    if (!m_pool.exists(gobj)) begin
      if(check_queue)
        uvm_report_warning("NO_CBS",`_UVM_CB_MSG_NO_CBS(delete));
      return;
    end
    cbq = m_pool.get(gobj);

    //Chain deletes to super types
    foreach(m_super_types[i]) m_super_types[i].m_delete(obj,cb,0);

    // for typewide, need to remove from all queues
    if (gobj == null) begin
      if (m_pool.first(gobj))
        do begin
          cbq = m_pool.get(gobj); 
          for (int i=cbq.size()-1; i >= 0; i--) begin
            if (cbq.get(i) == cb) begin
              cbq.delete(i);
              `uvm_cb_trace(gobj,cb,$sformatf("delete typewide callback from positon %0d", i))
              found=1;
            end
          end
          if(cbq.size() == 0) begin
            m_pool.delete(cbq);
          end
        end while (m_pool.next(gobj));      
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
        m_pool.delete(gobj);
      end
    end

    if (!found && check_queue)
      uvm_report_error("CB_NOT_REG",`_UVM_CB_MSG_NOT_REG(delete));

  endfunction


  // Function: add_by_name
  //
  // Adds a callback to a named component. This only applies to component types,
  // all other types will result in no callbacks being applied. ~name~ is
  // a uvm full path name which can include glob style wildcards (* and ?).
  // ~root~ is a starting location for the search; if it is unspecified then
  // the search starts at uvm_top.

  static function void add_by_name(CB cb, string name, uvm_component root = null, 
      uvm_apprepend ordering=UVM_APPEND);
    uvm_component q[$];
    T t;
    void'(uvm_top.find_all(name,q,root));
    if(q.size() == 0) begin
      uvm_report_warning("CBNOMTCH", $sformatf("add_by_name(), no components matched the name '%s'", name), UVM_NONE);
      return;
    end
    foreach(q[i]) begin
      if($cast(t,q[i])) begin 
        add(t,cb,ordering); 
      end
    end
  endfunction


  // Function: delete_by_name
  //
  // Removes a callback to a named component. This only applies to component types,
  // all other types will result in no callbacks being applied. ~name~ is
  // a uvm full path name which can include glob style wildcards (* and ?).
  // ~root~ is a starting location for the search; if it is unspecified then
  // the search starts at uvm_top.

  static function void delete_by_name(CB cb, string name, uvm_component root = null);
    uvm_component q[$];
    T t;
    void'(uvm_top.find_all(name,q,root));
    if(q.size() == 0) begin
      uvm_report_warning("CBNOMTCH", $sformatf("delete_by_name(), no components matched the name '%s'", name), UVM_NONE);
      return;
    end
    foreach(q[i]) begin
      if($cast(t,q[i]))
        delete(t,cb);
    end
  endfunction


  // Group: Debugging

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

  static function void display_cbs(T obj=null,bit all=1,bit doing_all=0);
    generic_type inst = get_inst();
    generic_queue_t cbq;
    uvm_object gobj=obj;

    if (all && obj==null) begin
      if (inst.m_pool.first(gobj))
        do 
          if($cast(obj,gobj)) display_cbs(obj,0,1);
        while (inst.m_pool.next(gobj));
      else
        uvm_report_info("SHOWCBQ", "No callbacks registered", UVM_NONE);
      return;
    end

    if (inst.m_pool.exists(gobj)) begin
      cbq = inst.m_pool.get(gobj);
      if(cbq.size() || doing_all==0) begin 
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


