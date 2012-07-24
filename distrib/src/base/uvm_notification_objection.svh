typedef class uvm_objection_notification;
typedef class uvm_notification_objection_callback;
typedef class uvm_notification_objection;
typedef class uvm_objection;
typedef uvm_callbacks #(uvm_notification_objection, uvm_notification_objection_callback) uvm_notification_objection_cbs_t;

   
// Class- uvm_notification_objection_events
// Used for the wait_for_notification implementation
class uvm_notification_objection_events;
   int waiters;
   event raised;
   event dropped;
   event all_dropped;
   event raise_requested;
   event drop_requested;
   event cleared;
endclass : uvm_notification_objection_events

   
//------------------------------------------------------------------------------
// Title: Notification Objection Mechanism
//------------------------------------------------------------------------------
// The following classes define the notification-based objection mechanism.  This
// non-hierarchical objection provides a more efficient mechanism for
// coordinating status information between multiple threads than the classic
// <uvm_objection>.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Class: uvm_objection_notification
// Notification Objection Action Descriptor
//------------------------------------------------------------------------------
// The Objection Notification class provides an encapsulation
// around all possible actions which can be sent to (or received from)
// a <uvm_notification_objection>.
//------------------------------------------------------------------------------

class uvm_objection_notification extends uvm_object;

   `uvm_object_utils(uvm_objection_notification)
   
   /// Undocumented protected member variables
   ///
   /// All member variables are accessible via set/get accessors.
   /// Direct access to the variables is prevented, as the
   /// description needs to remain stable during callback
   /// executions

   // Variable- m_action_type
   // Action type described by this object
   protected uvm_objection_action_e m_action_type;

   // Variable- m_obj
   // Source on behalf of which the action is taking place
   protected uvm_object m_obj;

   // Variable- m_description
   // Optional description describing action
   protected string m_description;
   
   // Variable- m_objection
   // Objection on which the action is taking place
   protected uvm_notification_objection m_objection;

   // Variable- m_count
   // Only valid for RAISE/DROP, the count applied to
   // the action
   protected int m_count;

   // Variable- m_locked
   // Once locked, an action can no longer be modified
   // This prevents the end user from changing the details
   // of the action during/after the callback execution
   protected bit m_locked;

   // Function: new
   // Constructor
   //
   // Creates a new instance of a uvm_objection_notification.
   //
   // Parameters:
   // name - Instance name
   function new(string name="unnamed-uvm_objection_notification");
      super.new(name);
   endfunction : new

   // Function- m_lock
   // Locks the action, preventing further modification
   //
   function void m_lock();
      m_locked = 1;
   endfunction : m_lock

   // Function- m_unlock
   // Unlocks the action, allowing modification
   //
   function void m_unlock();
      m_locked = 0;
   endfunction : m_unlock

   // Function: is_locked
   // Returns the current ~lock~ state of the action descriptor
   //
   // During the internal processing of the notification, and during
   // the execution of the callback chain within the objection, the
   // library needs to ensure that the notification object remains
   // unmodified, so that all subscribers are guaranteed to see the same
   // notification.  As such, the library will place the notification into 
   // a 'locked' state.  Any attempts to modify the internal values during 
   // that time will result in an error being asserted.
   //
   // After the objection has finished processing a notification, then
   // the notification will be unlocked, allowing the original creator
   // of the notification to manipulate the fields again.  If the user
   // wishes to save off a 'safe' copy of the notification, then they
   // need to either copy or clone the locked notification when it is
   // provided to them.
   function bit is_locked();
      return m_locked;
   endfunction : is_locked

   // Function: set_action
   // Sets the type for this action
   //
   function void set_action_type(uvm_objection_action_e action_type);
      if (m_locked) begin
        `uvm_error("UVM/BASE/OBJTN/NTFCN/LOCKED/SET_TYPE",
                   "attempt to set action on locked action")
      end
      else begin
         m_action_type = action_type;
      end
   endfunction : set_action_type

   // Function: get_action
   // Returns the type for this action
   //
   function uvm_objection_action_e get_action_type();
      return m_action_type;
   endfunction : get_action_type

   // Function: set_obj
   // Sets the source object on behalf of which this action is occuring
   //
   function void set_obj(uvm_object obj);
      if (m_locked) begin
         `uvm_error("UVM/BASE/OBJTN/NTFCN/LOCKED/SET_SRC_OBJ",
                    "attempt to set source object on a locked action")
      end
      else begin
         m_obj = obj;
      end
   endfunction : set_obj

   // Function: get_obj
   // Returns the source object on behalf of which this action is occurring
   //
   function uvm_object get_obj();
      return m_obj;
   endfunction : get_obj

   // Function- m_get_source_name
   function string m_get_source_name();
      if (m_obj == null)
        return "<null>";
      else
        return m_obj.get_full_name();
   endfunction : m_get_source_name

   // Function: set_objection
   // Sets the objection on which the action is occuring
   //
   function void set_objection(uvm_notification_objection objection);
      if (m_locked) begin
         `uvm_error("UVM/BASE/NTFC_OBJCTN/ACT/LOCKED/SET_OBJCTN",
                    "attempt to set objection on a locked action")
      end
      else begin
         m_objection = objection;
      end
   endfunction : set_objection

   // Function: get_objection
   // Returns the objection on which this action is occuring
   //
   function uvm_notification_objection get_objection();
      return m_objection;
   endfunction : get_objection

   // Function: set_description
   // Sets the description string for the action
   //
   function void set_description(string description);
      if (m_locked) begin
         `uvm_error("UVM/BASE/NTFC_OBJCTN/ACT/LOCKED/SET_DESC",
                    "attempt to set description on a locked action")
      end
      else begin
         m_description = description;
      end
   endfunction : set_description

   // Function: get_description
   // Returns the description string for the action
   //
   function string get_description();
      return m_description;
   endfunction : get_description

   // Function: set_count
   // Sets the count for the action
   //
   // The count is only valid when the ~action_type~ is set
   // to ~UVM_OBJECTION_RAISED~ or ~UVM_OBJECTION_DROPPED~.  For all other types of action,
   // the count is ignored.
   //
   function void set_count(int count);
      if (m_locked) begin
         `uvm_error("UVM/BASE/NTFC_OBJTCTN/ACT/LOCKED/SET_CNT",
                    "attempt to set count on a locked action")
      end
      else begin
         m_count = count;
      end
   endfunction : set_count

   // Function: get_count
   // Returns the count for the action
   //
   // The count is only valid when the ~action_type~ is set
   // to ~UVM_OBJECTION_RAISED~ or ~UVM_OBJECTION_DROPPED~.  For all other types of action,
   // the count is ignored.
   //
   function int get_count();
      return m_count;
   endfunction : get_count

   /// Undocumented introspection functions

   // Function- do_copy
   function void do_copy (uvm_object rhs);
      uvm_objection_notification rhs_;
      super.do_copy(rhs);
      $cast(rhs_,rhs);
      if (is_locked()) begin
        `uvm_error("UVM/BASE/NTFC_OBJTCTN/ACT/LOCKED/COPY",
                   "attempt to copy into a locked action")
      end
      else begin
         this.m_action_type = rhs_.m_action_type;
         this.m_obj = rhs_.m_obj;
         this.m_objection = rhs_.m_objection;
         this.m_description = rhs_.m_description;
         this.m_count = rhs_.m_count;
      end
   endfunction : do_copy

   // Function- do_compare
   virtual function bit do_compare (uvm_object rhs,uvm_comparer comparer);
      uvm_objection_notification rhs_;
      do_compare = super.do_compare(rhs,comparer);
      $cast(rhs_,rhs);
      if (this.m_action_type != rhs_.m_action_type) begin
         do_compare = 0;
         comparer.print_msg($sformatf("action_type miscompare ('%s' != '%s')" ,
                                     this.m_action_type.name(),
                                     rhs_.m_action_type.name()));
      end
      if (this.m_obj != rhs_.m_obj) begin
         do_compare = 0;
         comparer.print_msg("source object miscompare");
      end
      if (this.m_objection != rhs_.m_objection) begin
         do_compare = 0;
         comparer.print_msg("objection miscompare");
      end
      if (this.m_description != rhs_.m_description) begin
         do_compare = 0;
         comparer.print_msg($sformatf("description miscompare ('%s' != '%s')",
                                      this.m_description,
                                      rhs_.m_description));
      end
      if (this.m_count != rhs_.m_count) begin
         do_compare = 0;
         comparer.print_msg($sformatf("count miscompare (%0d != %0d)",
                                     this.m_count,
                                     rhs_.m_count));
      end
   endfunction : do_compare

   // function- do_print
   virtual function void do_print (uvm_printer printer);
      super.do_print(printer);
      printer.print_string("action_type", this.m_action_type.name());
      //printer.print_object("obj", this.m_obj);
      printer.print_string("obj name", this.m_get_source_name());
      //printer.print_object("objection", this.m_objection);
      printer.print_string("objection name", this.m_objection.get_name());
      printer.print_string("description", this.m_description);
      if ((this.m_action_type == UVM_OBJECTION_RAISED) || 
          (this.m_action_type == UVM_OBJECTION_DROPPED))
        printer.print_int("count", this.m_count, $bits(this.m_count), UVM_DEC);
   endfunction : do_print

   // function- do_record
   function void do_record (uvm_recorder recorder);
      super.do_record(recorder);
      recorder.record_string("action_type", this.m_action_type.name());
      //recorder.record_object("obj", this.m_obj);
      recorder.record_string("obj name", this.m_get_source_name());
      recorder.record_object("objection", this.m_objection);
      recorder.record_string("description", this.m_description);
      if ((this.m_action_type == UVM_OBJECTION_RAISED) || 
          (this.m_action_type == UVM_OBJECTION_DROPPED))
        recorder.record_field("count", this.m_count, $bits(this.m_count), UVM_DEC);
   endfunction : do_record
   
endclass : uvm_objection_notification

//------------------------------------------------------------------------------
// Class: uvm_objection_prop_notification
// Extended notification used for propagation
//------------------------------------------------------------------------------
// The 'Propagation' notification is a special extended version of
// the standard <uvm_objection_notification>, which is used exclusively
// by the <uvm_objection> and its derivatives.  In addition to all of
// the fields and functionality provided by the <uvm_objection_notification>,
// this extended version provides a concept of a propagation ~source~.
//------------------------------------------------------------------------------

class uvm_objection_prop_notification extends uvm_objection_notification;

   protected uvm_object m_source_obj;

   // Undocumented, used inside of uvm_objection
   bit     m_is_top_thread;
   
   `uvm_object_utils(uvm_objection_prop_notification)

   function new(string name="unnamed-uvm_objection_prop_notification");
      super.new(name);
   endfunction : new

   // Function: set_source_obj
   // Sets the source object on behalf of which this action is occuring
   //
   function void set_source_obj(uvm_object source_obj);
      if (m_locked) begin
         `uvm_error("UVM/BASE/OBJTN/NTFCN/LOCKED/SET_TGT_OBJ",
                    "attempt to set source object on a locked action")
      end
      else begin
         m_source_obj = source_obj;
      end
   endfunction : set_source_obj

   // Function: get_source_obj
   // Returns the source object on behalf of which this action is occurring
   //
   function uvm_object get_source_obj();
      return m_source_obj;
   endfunction : get_source_obj

   // Function- m_get_source_name
   function string m_get_source_name();
      if (m_source_obj == null)
        return "<null>";
      else
        return m_source_obj.get_full_name();
   endfunction : m_get_source_name

   
   /// Undocumented introspection functions

   // Function- do_copy
   function void do_copy (uvm_object rhs);
      uvm_objection_prop_notification rhs_;
      super.do_copy(rhs);
      $cast(rhs_,rhs);
      if (!is_locked()) begin
         this.m_source_obj = rhs_.m_source_obj;
      end
   endfunction : do_copy

   // Function- do_compare
   virtual function bit do_compare (uvm_object rhs,uvm_comparer comparer);
      uvm_objection_prop_notification rhs_;
      do_compare = super.do_compare(rhs,comparer);
      $cast(rhs_,rhs);
      if (this.m_source_obj != rhs_.m_source_obj) begin
         do_compare = 0;
         comparer.print_msg("source object miscompare");
      end
   endfunction : do_compare

   // function- do_print
   virtual function void do_print (uvm_printer printer);
      super.do_print(printer);
      printer.print_string("source_obj name", this.m_get_source_name());
   endfunction : do_print

   // function- do_record
   function void do_record (uvm_recorder recorder);
      super.do_record(recorder);
      recorder.record_string("source_obj name", this.m_get_source_name());
   endfunction : do_record
   
endclass : uvm_objection_prop_notification



//------------------------------------------------------------------------------
//
// Class: uvm_notification_objection
//
//------------------------------------------------------------------------------
// Objections provide a facility for coordinating status information between
// two or more participating threads.
//
// Tracing of objection activity can be turned on to follow the activity of
// the objection mechanism. It may be turned on for a specific objection
// instance with <uvm_notification_objection::set_trace_mode>, or it can be set for all 
// objections from the command line using the option +UVM_OBJECTION_TRACE.
//------------------------------------------------------------------------------

class uvm_notification_objection extends uvm_report_object;
   `uvm_register_cb(uvm_notification_objection, uvm_notification_objection_callback)
   
   protected bit m_trace_mode;
   protected int m_source_count[uvm_object];
   protected int m_source_count_backup[uvm_object]; // used when clearing links

   protected uvm_notification_objection_events m_broadcast_event;
   protected uvm_notification_objection_events m_events [uvm_object];
   protected bit m_ds_links[uvm_notification_objection];
   protected bit m_us_links[uvm_notification_objection];

   protected uvm_root m_top = uvm_root::get();

   // Used for memory efficiency
   static local uvm_objection_notification m_notification_pool[$];
   
   // Function: new
   // Creates a new notification objection instance.
   //
   // Accesses the command line argument +UVM_OBJECTION_TRACE to
   // turn on tracing for all objection objects.
   //
   // This command line argument can be overridden on a case-by-case
   // basis by calling ~set_trace_mode~ on a notification
   // objection.
   function new(string name="unnamed-uvm_notification_objection");
      uvm_cmdline_processor clp;
      string     trace_args[$];

      super.new(name);

      m_broadcast_event = new();
      
      // Get the command line trace mode setting
      clp = uvm_cmdline_processor::get_inst();
      if (clp.get_arg_matches("+UVM_OBJECTION_TRACE", trace_args)) begin
         m_trace_mode = 1;
      end
   endfunction : new

   // Group: Objection Status
   //
   // Provides simple inspection on the internal
   // state of the objection
   //

   // Function: get_objection_count
   // Returns the current numer of objections which have been raised
   // on behalf of the given ~obj~.
   //
   // If the ~obj~ is unset, or null, then the value returned
   // will be the current objection count for ~uvm_root~.
   //
   function int get_objection_count( uvm_object obj=null );
      if (obj == null)
        obj = m_top;

      if (!m_source_count.exists(obj))
        return 0;
      return m_source_count[obj];
   endfunction : get_objection_count

   // Function: get_sum
   // Returns the sum of all counts for all objecting objects (
   // objects which have had an objection raised on their behalf,
   // but have not had it dropped).
   //
   // This is a convenience function to prevent the user from
   // having to constantly write:
   //
   // | int count = 0;
   // | uvm_object list[$];
   // | my_objection.get_objectors(list);
   // | foreach(list[i])
   // |   count += my_objection.get_objection_count(list[i]);
   //
   function int get_sum();
      get_sum = m_source_count.sum();
   endfunction : get_sum
   
   // Function- m_wait_for
   // Implementation artifact.  Allows uvm_objection to extend
   // wait_for, providing UVM_OBJECTION_ALL_DROPPED support.
   virtual task m_wait_for(uvm_objection_action_e action,
                           uvm_object obj=null);

      if (action == UVM_OBJECTION_ALL_DROPPED) begin
        `uvm_error("UVM/BASE/NTFCN_OBJCTN/NO_ALL_DROPPED",
                   $sformatf("attempt to wait for 'UVM_OBJECTION_ALL_DROPPED' on notification objection '%s' will never unblock", get_full_name()))
      end
      
      if (obj == null)  begin // broadcast
         m_broadcast_event.waiters++;
         case (action)
           UVM_OBJECTION_RAISED: @(m_broadcast_event.raised);
           UVM_OBJECTION_DROPPED: @(m_broadcast_event.dropped);
           UVM_OBJECTION_RAISE_REQUESTED: @(m_broadcast_event.raise_requested);
           UVM_OBJECTION_DROP_REQUESTED: @(m_broadcast_event.drop_requested);
           UVM_OBJECTION_CLEARED: @(m_broadcast_event.cleared);
         endcase // case (action)
         m_broadcast_event.waiters--;
      end
      else begin
         if (!m_events.exists(obj)) begin
            m_events[obj] = new;
         end

         m_events[obj].waiters++;
         case (action)
           UVM_OBJECTION_RAISED: @(m_events[obj].raised);
           UVM_OBJECTION_DROPPED: @(m_events[obj].dropped);
           UVM_OBJECTION_RAISE_REQUESTED: @(m_events[obj].raise_requested);
           UVM_OBJECTION_DROP_REQUESTED: @(m_events[obj].drop_requested);
           UVM_OBJECTION_CLEARED: @(m_events[obj].cleared);
         endcase // case (action)
         m_events[obj].waiters--;

         if (m_events[obj].waiters == 0) begin
            m_events.delete(obj);
         end
      end // else: !if(obj == null)

   endtask : m_wait_for

   // Function: get_objectors
   // Returns the current list of objecting objects (objects
   // which have had an objection raised on their behalf, but
   // have not had it dropped).
   //
   // Note that the objection does not have any form of 'history'.
   // If all of the objections which are raised on behalf of an
   // object are subsequently dropped, than that object will not
   // appear in this list.
   //
   // This clearing of dropped sources prevents accidental memory
   // leaks.
   function void get_objectors(ref uvm_object list[$]);
      list.delete();
      foreach (m_source_count[obj])
        list.push_back(obj);
   endfunction : get_objectors

   // Function- m_display_objections
   // converts the objection to a string
   protected virtual function string m_display_objections(uvm_object obj=null,
                                                          bit show_header=1);
      static string blank="                                                                                   ";

      string        s;
      int           total;
      uvm_object list[string];
      uvm_object curr_obj;
      int           depth;
      string        name;
      string        this_obj_name;
      string        curr_obj_name;

      if (obj == null) begin
         // First filter out the sources which exist just
         // because of wait_for... calls
         foreach (m_source_count[o]) begin
            uvm_object theobj = o;
            if (m_source_count[o] > 0)
              list[theobj.get_full_name()] = theobj;
         end
      end
      else begin
         list[obj.get_full_name()] = obj;
      end

      total = get_sum();

      s = $sformatf("The total objection count is %0d\n", total);

      if (total == 0)
        return s;

      s = {s, "---------------------------------------------------------\n"};
      s = {s, "           Source\n"};
      s = {s, "  Count    Object\n"}; 
      s = {s, "---------------------------------------------------------\n"};

      foreach (list[curr_obj_name]) begin
         name = (curr_obj_name == "") ? "uvm_top" : curr_obj_name;
         s = {s, $sformatf("  %-6d   %s\n",
                           m_source_count[list[curr_obj_name]],
                           name)};
      end

      s = {s,"---------------------------------------------------------\n"};

      return s;

   endfunction : m_display_objections

   function string convert2string();
      return m_display_objections(, 1);
   endfunction : convert2string
   
   // Group: Notification API
   //
   // The 'Subscriber' API is build out of various callbacks and
   // ~wait_for~ tasks.  An object can listen to the notification
   // of an objection to be alerted to all impulses for that
   // objection.
   //

   // Function- m_lock_notified
   // Locks the transaction before notifying, unlocks afterwards
   virtual function void m_lock_notified(uvm_objection_notification action);
      m_report(action);
      m_process_links(action);
      action.m_lock();
      notified(action);
      action.m_unlock();
   endfunction : m_lock_notified
   
   // Function: notified
   // Objection callback that is called whenever the activation API is triggered
   //
   // By the time the notified callback is triggered, the action descriptor should
   // be considered 'locked', ie. unchangable.
   //
   // The default implementation triggers all of the
   // <uvm_notification_objection_callback>'s which have been registered
   // with this objection.
   //
   virtual function void notified(uvm_objection_notification action);
      `uvm_do_callbacks(uvm_notification_objection, 
                        uvm_notification_objection_callback,
                        m_notified(action))

   endfunction : notified

   // Function: wait_for_objection_count
   // Waits for the objection count for ~obj~ to reach
   // ~count~ as qualified by ~op~
   //
   // If no ~op~ is passed, the wait will be for
   // the counts to be equal.
   //
   task wait_for_objection_count(uvm_object obj,
                                 int count,
                                 uvm_wait_op op=UVM_EQ);

      if (!m_source_count.exists(obj))
        m_source_count[obj] = 0;

      case (op)
        UVM_EQ: @(m_source_count[obj] == count);
        UVM_NE: @(m_source_count[obj] != count);
        UVM_LT: @(m_source_count[obj] < count);
        UVM_LTE: @(m_source_count[obj] <= count);
        UVM_GT: @(m_source_count[obj] > count);
        UVM_GTE: @(m_source_count[obj] >= count);
      endcase // case (op)

   endtask : wait_for_objection_count

   // Function: wait_for_sum
   // Waits for the sum of all objection counts to reach
   // ~count~ as qualified by ~op~
   //
   // If no ~op~ is passed, the wait will be for the count
   // to be equal to the sum.
   //
   task wait_for_sum(int count,
                     uvm_wait_op op=UVM_EQ);

      case (op)
        UVM_EQ: @(m_source_count.sum() == count);
        UVM_NE: @(m_source_count.sum() != count);
        UVM_LT: @(m_source_count.sum() < count);
        UVM_LTE: @(m_source_count.sum() <= count);
        UVM_GT: @(m_source_count.sum() > count);
        UVM_GTE: @(m_source_count.sum() >= count);
      endcase // case (op)

   endtask : wait_for_sum

   // Function: wait_for
   // Waits for the events described by <uvm_objection_action_e>
   //
   // If a waiter passes in a specific ~obj~ to wait on, then the
   // task will unblock when the given action is generated by that 
   // ~obj~.
   //
   // If no source is passed in, then the task will unblock when ~any~
   // source produces the specified ~action~.
   //
   // Supported Actions:
   // UVM_OBJECTION_RAISED
   // UVM_OBJECTION_DROPPED
   // UVM_OBJECTION_RAISE_REQUESTED
   // UVM_OBJECTION_DROP_REQUESTED
   // UVM_OBJECTION_CLEARED
   //
   task wait_for(int action,
                 uvm_object obj=null);
      m_wait_for(uvm_objection_action_e'(action), obj);
   endtask : wait_for

   // Group: Controller API
   //
   // The controller API for an objection provides an
   // object the ability to cause transitions in the objection
   // state.
   // 
   
   // Function: notify
   // Causes the notification described by ~action~ to occur
   //
   // Since the ~action~ is going to be locked by the objection prior
   // to executing the callback chain, it is cloned before processing.
   virtual       function void notify(uvm_objection_notification action);
      m_process(action);
   endfunction : notify

   // Function- m_raise
   virtual function void m_raise(uvm_objection_notification action);
      if (action.get_count() < 1) begin
         if (action.get_count() < 0) begin
            `uvm_fatal("UVM/BASE/NTFCN_OBJCTN/NEGATIVE_RAISE",
                       "attempt to raise an objection with a negative count")
              end
         return;
      end  
      
      if (m_source_count.exists(action.get_obj()))
        m_source_count[action.get_obj()] += action.get_count();
      else
        m_source_count[action.get_obj()] = action.get_count();
      
      if (m_events.exists(action.get_obj()))
        ->m_events[action.get_obj()].raised;
      ->m_broadcast_event.raised;
      
      m_lock_notified(action);
   endfunction : m_raise

   // Function- m_drop
   virtual function void m_drop(uvm_objection_notification action);

      if (action.get_count() < 1) begin
         if (action.get_count() < 0) begin
            `uvm_fatal("UVM/BASE/OBJTN/NEGATIVE_DROP",
                       "attempt to drop an objection with a negative count")
              end
         return;
      end  
      
      if (m_source_count.exists(action.get_obj())) begin
         if (m_source_count[action.get_obj()] < action.get_count()) begin
            uvm_object l_obj = action.get_obj();
            string name = l_obj.get_full_name();
            `uvm_fatal("OBJTN_ZERO",
                       {"attempt to drop objection count for source '",name,"' below zero on '", this.get_name(), "'"})
              return;
         end
         
         m_source_count[action.get_obj()] -= action.get_count();
         
         // Prevent memory leaks by clearing out the source list
         if (m_source_count[action.get_obj()] == 0)
           m_source_count.delete(action.get_obj());
         
         if (m_events.exists(action.get_obj()))
           ->m_events[action.get_obj()].dropped;
         ->m_broadcast_event.dropped;
      end
      else begin
         uvm_object l_obj = action.get_obj();
         string name = l_obj.get_full_name();
         `uvm_fatal("OBJTN_ZERO",
                    {"attempt to drop objection count for source '",name,"' below zero"})
           return;
      end // else: !if(m_source_count.exists[action.get_obj()])
      
      m_lock_notified(action);

   endfunction : m_drop      

   // Function- m_clear_check
   // Performs the check to determine if a clear should be 'warned'
   protected virtual function void m_clear_check(uvm_objection_notification action);
      string         name;
      uvm_object obj = action.get_obj();
      name = (obj == null) ? "<null>" : obj.get_full_name();
      if (name == "")
           name = "uvm_top";
      
      if (get_sum() > 0)
        uvm_report_warning("OBJTN_CLEAR",
                           {"object: '", name, "' cleared objection counts for ", get_name()});
   endfunction : m_clear_check
         
      
   
   // Function- m_process
   // Processes the various notification types
   protected virtual function void m_process(uvm_objection_notification action);

      // Do some basic tidying of the descriptor    
      if (action.get_obj() == null)
        action.set_obj(m_top);

      action.set_objection(this);

      if (action.get_action_type() == UVM_OBJECTION_CLEARED) begin
         m_clear_check(action);
         
         m_source_count_backup = m_source_count; // Save for links
         m_source_count.delete();
         if (m_events.exists(action.get_obj()))
           ->m_events[action.get_obj()].cleared;
         ->m_broadcast_event.cleared;

         m_lock_notified(action);
      end
      
      if (action.get_action_type() == UVM_OBJECTION_RAISED) begin
         m_raise(action);
      end

      if (action.get_action_type() == UVM_OBJECTION_DROPPED) begin
         m_drop(action);
      end

      if (action.get_action_type() == UVM_OBJECTION_RAISE_REQUESTED) begin
         if (m_events.exists(action.get_obj()))
           ->m_events[action.get_obj()].raise_requested;
         ->m_broadcast_event.raise_requested;

         m_lock_notified(action);
      end

      if (action.get_action_type() == UVM_OBJECTION_DROP_REQUESTED) begin
         if (m_events.exists(action.get_obj()))
           ->m_events[action.get_obj()].drop_requested;
         ->m_broadcast_event.drop_requested;

         m_lock_notified(action);
      end


   endfunction : m_process

   // Function: clear
   // Immediately clears the objection state.
   //
   // All counts are cleared, however no 'drop' related callbacks 
   // will be trigered.
   //
   // Additionally, any processes waiting on a call to 
   // wait_for_notification(UVM_OBJECTION_CLEARED, ...)
   // are released.
   //
   // The caller, if a uvm_object-based object, should pass its 
   // 'this' handle to the ~obj~ argument, and a description
   // stating why they have cleared the objection, to assist in debug.
   //
   virtual function void clear(uvm_object obj=null, string description = "");
      string     name;
      uvm_objection_notification action;

      if (m_notification_pool.size())
        action = m_notification_pool.pop_front();
      else
        action = new("notification");
      action.set_action_type(UVM_OBJECTION_CLEARED);
      action.set_obj(obj);
      action.set_objection(this);
      action.set_description(description);
      
      m_process(action);

      m_notification_pool.push_back(action);
      
   endfunction : clear

   // Function- m_report
   //
   // Internal method for reporting notifications
   virtual function void m_report(uvm_objection_notification action);
      string id = "OBJTN_TRC";
      if (!m_trace_mode ||
          !uvm_report_enabled(UVM_NONE, UVM_INFO, id))
        return;

      begin
         string msg;
         uvm_objection_action_e l_action = action.get_action_type();
         uvm_object l_obj = action.get_obj();
         string l_source_name = (l_obj == null) ? "<null>" :
                (l_obj.get_full_name() == "") ? "uvm_top" : l_obj.get_full_name();
         
         
         msg = $sformatf("'%s' sent on behalf of '%s' to '%s'",
                         l_action.name(),
                         l_source_name,
                         this.get_full_name());

         if ((l_action == UVM_OBJECTION_RAISED) || (l_action == UVM_OBJECTION_DROPPED))
           msg = {msg, $sformatf(" with count of %0d", action.get_count())};

         if (action.get_description() != "")
           msg = {msg, $sformatf(" - '%s'", action.get_description())};

         uvm_report_info(id, msg, UVM_NONE);
      end
      
   endfunction : m_report
                                   
   // Function: raise_objection
   // Raises the number of objections by ~count~, on behalf of ~obj~. 
   //
   // Raising an objection causes the following.
   // - The source objection count for ~obj~ is increased by ~count~.  
   // -	The objection's <notified> virtual method is called, and passed an 
   //   appropriate action descriptor
   //
   // Parameters:
   // obj - The source object on behalf of which the raise is occuring.
   //              Defaults to the implicit top-level component (uvm_root), if
   //              not specified or set to null.
   // description - Optional description used to describe the purpose of the
   //               raise call.  The library uses this description in tracing
   //               and debug oututs
   // count - The amount to increase the ~obj's~ objection count by.
   //         Defaults to 1 if no value is given.

   virtual function void raise_objection(uvm_object obj=null,
                                         string description="",
                                         int count = 1);

      uvm_objection_notification action;

      if (m_notification_pool.size())
        action = m_notification_pool.pop_front();
      else 
        action = new("notification");
      
      action.set_action_type(UVM_OBJECTION_RAISED);
      action.set_obj(obj);
      action.set_objection(this);
      action.set_description(description);
      action.set_count(count);
      
      m_process(action);

      m_notification_pool.push_back(action);
      
   endfunction : raise_objection

   // Function: drop_objection
   // Drops the number of objections by ~count~, on behalf of ~obj~. 
   //
   // Raising an objection causes the following.
   // - The source objection count for ~obj~ is increased by ~count~.  
   // -	The objection's <notified> virtual method is called, and passed an 
   //   appropriate action descriptor
   //
   // Parameters:
   // obj - The source object on behalf of which the drop is occuring.
   //              Defaults to the implicit top-level component (uvm_root), if
   //              not specified or set to null.
   // description - Optional description used to describe the purpose of the
   //               drop call.  The library uses this description in tracing
   //               and debug oututs
   // count - The amount to increase the ~obj's~ objection count by.
   //         Defaults to 1 if no value is given.

   virtual function void drop_objection(uvm_object obj=null,
                                         string description="",
                                         int count = 1);

      uvm_objection_notification action;

      if (m_notification_pool.size())
        action = m_notification_pool.pop_front();
      else 
        action = new("notification");
      action.set_action_type(UVM_OBJECTION_DROPPED);
      action.set_obj(obj);
      action.set_objection(this);
      action.set_description(description);
      action.set_count(count);
      
      m_process(action);

      m_notification_pool.push_back(action);
   endfunction : drop_objection

   // Function: request_to_raise
   // Sends a <UVM_OBJECTION_RAISE_REQUESTED> action to the notification API
   //
   // This method does not have any effect on the internal state
   // of the objection, instead it is simply a communication
   // from the controller API to the notification API.
   //
   // Parameters:
   // obj - The source object on behalf of which the request is occuring.
   //              Defaults to the implicit top-level component (uvm_root), if
   //              not specified or set to null.
   // description - Optional description used to describe the purpose of the
   //               request.  The library uses this description in tracing
   //               and debug oututs

   virtual function void request_to_raise(uvm_object obj=null,
                                         string description="");

      uvm_objection_notification action;

      if (m_notification_pool.size())
        action = m_notification_pool.pop_front();
      else
        action = new("notification");
      action.set_action_type(UVM_OBJECTION_RAISE_REQUESTED);
      action.set_obj(obj);
      action.set_objection(this);
      action.set_description(description);
      
      m_process(action);

      m_notification_pool.push_back(action);
   endfunction : request_to_raise

   // Function: request_to_drop
   // Sends a <UVM_OBJECTION_DROP_REQUESTED> action to the notification API
   //
   // This method does not have any effect on the internal state
   // of the objection, instead it is simply a communication
   // from the controller API to the notification API.
   //
   // Parameters:
   // obj - The source object on behalf of which the request is occuring.
   //              Defaults to the implicit top-level component (uvm_root), if
   //              not specified or set to null.
   // description - Optional description used to describe the purpose of the
   //               request.  The library uses this description in tracing
   //               and debug oututs

   virtual function void request_to_drop(uvm_object obj=null,
                                         string description="");

      uvm_objection_notification action;

      if (m_notification_pool.size()) 
        action = m_notification_pool.pop_front();
      else
        action = new("notification");
      
      action.set_action_type(UVM_OBJECTION_DROP_REQUESTED);
      action.set_obj(obj);
      action.set_objection(this);
      action.set_description(description);
      
      m_process(action);

      m_notification_pool.push_back(action);
   endfunction : request_to_drop

   // Group: Linking
   //
   // By linking objection 'A' to objection 'B', the user is
   // essentially saying "So long as anyone is objecting to ~A~,
   // they are also objecting to ~B~."
   //
   // Links are bidrectional in nature, and the direction of 
   // the notification depends on which action is occurring.
   //
   // The directionality of the flow model for the links is as follows
   // | upstream_objection.link(downstream_objection);
   //
   // UVM_OBJECTION_RAISED - If the raise results in a 0->N transition
   // of the objection sum, then downstream links will recieve a raise.
   //
   // UVM_OBJECTION_DROPPED - If the drop results in a  N->0 transition
   // of the objection sum, then downstream links will recieve a drop.
   //
   // UVM_OBJECTION_CLEARED - If the clear results in a N->0 transistion
   // of the objection sum, then downstream links will recieve a drop.  Regardless
   // of this drop, if there are any upstream links present, <clear> will get
   // called on them.
   //
   // UVM_OBJECTION_RAISE_REQUESTED - If there are any upstream links present,
   // <request_to_raise> will get called on them.
   //
   // UVM_OBJECTION_DROP_REQUESTED - if there are any upstream links present,
   // <request_to_drop> will get called no them.
   //
   // If a link is established, and the upstream objection's sum is greater
   // than zero, then the downstream objection will recieve a raise.
   //
   // If a link is destroyed, and the upstream objection's sum is greater
   // than zero, then the downstream objection will recieve a drop.
   //
   // *NOTE:* The deprecated ~uvm_test_done~ objection has a qualification
   // process which dictates that only <uvm_sequence_base> or <uvm_component>
   // derived objects can raise/drop objections.  Since ~uvm_notification_objection~
   // does not derive from either of these, it can not be the source of an
   // objection on ~uvm_test_done~.  This means that ~uvm_test_done~ is an
   // invalid downstream target for objection links (although it is perfectly
   // valid as an upstream target).
   //
   

   // Function- m_process_links
   protected virtual function void m_process_links(uvm_objection_notification action);
      if (action.get_action_type() == UVM_OBJECTION_RAISED) begin
         foreach (m_ds_links[i]) begin
            if ((action.get_count() == this.get_sum())) begin
               i.raise_objection(this, "objection link", 1);
            end
         end // foreach (m_ds_links[i])
      end // if (action.get_action_type() == UVM_OBJECTION_RAISED)

      if (action.get_action_type() == UVM_OBJECTION_DROPPED) begin
         if (this.get_sum() == 0) begin 
            foreach (m_ds_links[i]) begin
               i.drop_objection(this, "objection link", 1);
            end // foreach (m_ds_links[i])
         end
      end
      
      if (action.get_action_type() == UVM_OBJECTION_CLEARED) begin
         foreach (m_us_links[i])
           i.clear(action.get_obj(),
                   $sformatf("objection link from '%s': %s",
                             this.get_full_name(),
                             action.get_description()));

         if (m_source_count_backup.sum() > 0) begin
            foreach (m_ds_links[i]) begin
               i.drop_objection(this, "objection link", 1);
            end
            m_source_count_backup.delete();
         end
      end

      if (action.get_action_type() == UVM_OBJECTION_RAISE_REQUESTED)
        foreach (m_us_links[i])
          i.request_to_raise(action.get_obj(),
                             $sformatf("objection link from '%s': %s",
                                       this.get_full_name(),
                                       action.get_description()));
      
      if (action.get_action_type() == UVM_OBJECTION_DROP_REQUESTED)
        foreach (m_us_links[i])
          i.request_to_drop(action.get_obj(),
                            $sformatf("objection link from '%s': %s",
                                      this.get_full_name(),
                                      action.get_description()));
      
   endfunction : m_process_links

   // Function- m_link
   // virtual function uvm_objection can extend
   virtual function void m_link(uvm_notification_objection ds);
      if (ds.m_find_link(this)) begin
         `uvm_error("UVM/BASE/OBJTN/NTFCN/LINK/INFINITE_LOOP",
                    $sformatf("Objection '%s' can not be linked to '%s', because '%s' is already a downstream link of '%s'",
                              ds.get_full_name(),
                              this.get_full_name(),
                              this.get_full_name(),
                              ds.get_full_name()))
         return;
      end
      else begin
         if (m_ds_links.exists(ds)) begin
            `uvm_warning("UVM/BASE/OBJTN/NTFCN/LINK/DUPLICATE",
                         $sformatf("Attempt to link '%s' into '%s' multiple times will be ignored",
                                  ds.get_full_name(),
                                  this.get_full_name()))
            return;
         end

         m_ds_links[ds] = 1;

         if (get_sum() > 0) begin
            ds.raise_objection(this, "objection link", 1);
         end
      end
   endfunction : m_link
   
   // Function: link
   // Links this objection to a downstream objection
   //
   // The user is allowed to daisy-chain objections together if
   // so desired.
   //
   // For Example
   //| uvm_notification_objection a,b,c;
   //| a = new("a"); b = new("b"); c = new("c");
   //| a.link(b); // A now implies B
   //| b.link(c); // B now implies C (which means A implies C as well)
   //
   // While such daisy chaining is perfectly valid, it is illegal
   // to 'loop' an objection link.  Looping is defined as having
   // an objection appear downstream, or upstream, of itself.
   //
   // Example of illegal loop
   //| uvm_notification_objection a,b;
   //| a = new("a"); b = new("b");
   //| a.link(b); // A now implies B
   //| b.link(a); // Illegal!
   //
   // Such loops are illegal because they create a deadlock condition
   // if either objection is raised.
   //
   
   function void link(uvm_notification_objection ds);
      m_link(ds);
   endfunction : link

   // Function- m_unlink
   // virtual function uvm_objection can extend
   virtual function void m_unlink(uvm_notification_objection ds);
      bit found;
      found = m_ds_links.exists(ds);
      if (found) begin
         m_ds_links.delete(ds);
         
         if (get_sum() > 0) begin
            ds.drop_objection(this, "objection link", 1);
         end
      end
      else begin
         `uvm_warning("UVM/BASE/OBJTN/NTFCN/LINK/DUPLICATE",
                      $sformatf("Attempt to unlink '%s' from '%s' will be ignored, because it was not linked",
                               ds.get_full_name(),
                               this.get_full_name()))
      end
   endfunction : m_unlink

   // Function: unlink
   // Removes a downstream objection from the processing chain.
   //
   // While it is possible to daisy-chain objections together,
   // the construction of the chain and the deconstruction of the
   // chain must be symetric.
   //
   // Example of illegal code
   //| uvm_notification_objection a,b,c;
   //| a = new("a"); b = new("b"); c = new("c");
   //| a.link(b); // A now implies B
   //| b.link(c); // B now implies C (which means A implies C as well)
   //| a.unlock(c); // Illegal!  C is not directly linked to A!
   function void unlink(uvm_notification_objection ds);
      m_unlink(ds);
   endfunction : unlink

   // Function- m_find_link
   // Find linked objections, and reports an error if the source is
   // inside of the destination chain.
   function bit m_find_link(uvm_notification_objection src);
      uvm_notification_objection l_obj;
      foreach (m_ds_links[i]) begin
         l_obj = i;
         m_find_link |= ((l_obj == src) ||
                         (l_obj.m_find_link(src)));
      end
   endfunction : m_find_link
   
   // Group: Display / Reporting
   //
   
   // Function: set_trace_mode
   // Sets the tracing mode for this notification objection
   //
   function void set_trace_mode(bit mode);
      m_trace_mode = mode;
   endfunction : set_trace_mode

   // Function: get_trace_mode
   // Returns the current value of the tracing mode bit
   //
   function bit get_trace_mode();
      return m_trace_mode;
   endfunction : get_trace_mode
   
   // Function: display_objections
   // Displays the current objection information about the given ~obj~.
   //
   // If the ~obj~ is not specified, or is null, then all of the objection's
   // sources will be displayed.  The ~show_header~ argument allows control
   // of whether a header is output
   //
   // Note that this will call $display, and will bypass the UVM reporting
   // system
   function void display_objections(uvm_object obj=null,
                                    bit show_header = 1);
      $display(m_display_objections(obj, show_header));
   endfunction : display_objections


   
   // Below is all the basic data introspection stuff that is needed for
   // a uvm_object for factory registration, printing, comparing, etc.

   typedef uvm_object_registry#(uvm_notification_objection, "uvm_notification_objection") type_id;
   static function type_id get_type();
      return type_id::get();
   endfunction : get_type

   function uvm_object create (string name="");
      uvm_notification_objection tmp = new(name);
      return tmp;
   endfunction : create

   virtual function string get_type_name();
      return "uvm_notification_objection";
   endfunction : get_type_name

   virtual function void do_copy(uvm_object rhs);
      uvm_notification_objection _rhs;
      $cast(_rhs, rhs);
      m_source_count = _rhs.m_source_count;
   endfunction : do_copy

endclass : uvm_notification_objection
   
// Class: uvm_notification_objection_callback
// The callback type that defines the callback implementations 
// for a notification objection callback.  A user uses the callback
// type ~uvm_notification_objection_cbs_t~ to add callbacks to
// specific objections.
//
// For example:
//
//| class my_note_objection_cb extends uvm_notification_objection_callback;
//|  function new(string name="unnamed");
//|   super.new(name);
//|  endfunction : new
//|
//|  virtual function void notified(uvm_objection_notification action);
//|    `uvm_info("DEMO", $sformatf("Saw notification:\n%s", action.sprint()), UVM_LOW)
//|  endfunction : notified
//| endclass : my_note_objection_cb
//| ...
//| initial begin
//|  my_note_objection_cb cb =new("cb");
//|  uvm_notification_objection_cbs_t::add(null, cb); // typewide callback
//| end
   

class uvm_notification_objection_callback extends uvm_callback;
   // Group: Filters
   //
   // While the notification objection is designed to provide
   // the user with the maximum amount of information possible through
   // its callback system, it is entirely likely that the use will only
   // care about a few important events in the objection timeline.
   //
   // The notification objection callback provides built-in filters,
   // so that the user does not need to filter out the unnecessary information,
   // and their callbacks will only be triggered when the events
   // fall through the filters.
   //

   //JAR- do we want to just make a "shallow/deep" filter instead of
   //     individual raise/drop filters?  Shallow = first raise and
   //     last drop, Deep = all raises and drops?
   
   // Variable: filter_raises
   // Filters the raised callbacks to only occur when
   // the objection's sum is increasing from 0->n
   //
   // Default: 1 (enabled)
   bit filter_raises;
   
   
   // Variable: filter_drops
   // Filters the dropped callbacks to only occur when
   // the objection's sum is decreasing from n->0
   //
   // Default: 1 (enabled)
   bit filter_drops;

   // Variable: filter_obj
   // Filters raised/dropped callbacks to only occur when
   // coming from a particular ~obj~
   //
   // ~Note:~ The callback will still trigger on 'broadcast' notifications,
   // ie. ~UVM_OBJECTION_RAISE_REQUESTED~ and ~UVM_OBJECTION_DROP_REQUESTED~.
   //
   // Default: ~null~ (disabled)
   uvm_object filter_obj;

   `_protected function new(string name="");
      super.new(name);
      filter_raises = 1;
      filter_drops = 1;
   endfunction : new

   // Function- m_notified
   // Implementation artifact, allows for filters
   virtual function void m_notified(uvm_objection_notification action);
      uvm_notification_objection objection;
      uvm_objection prop_objection;
      uvm_objection_prop_notification prop_action;
      
      int  action_count;
      int  filter_total;
      if (filter_obj != null) begin
         if ((action.get_action_type() == UVM_OBJECTION_RAISED) ||
             (action.get_action_type() == UVM_OBJECTION_DROPPED)) begin
            if ($cast(prop_action, action)) begin
               if (filter_obj != prop_action.get_source_obj())
                 return;
            end
            else begin
               if (filter_obj != action.get_obj())
                 return;
            end
         end
      end

      objection = action.get_objection();
      if ($cast(prop_objection, objection)) begin
         filter_total = (filter_obj == null) ? prop_objection.get_sum() : prop_objection.get_objection_total(filter_obj);
      end
      else begin
         filter_total = (filter_obj == null) ? objection.get_sum() : objection.get_objection_count(filter_obj);
      end

      action_count = action.get_count();
      
      if (filter_raises) begin
         
         if (action.get_action_type() == UVM_OBJECTION_RAISED) begin
            if (filter_total != action_count)
              return;
         end
      end

      if (filter_drops) begin
         if (action.get_action_type() == UVM_OBJECTION_DROPPED) begin
            if (filter_total != 0)
              return;
         end
      end

      notified(action);
   endfunction : m_notified
   
   // Function: notified
   // Objection notified callback function
   //
   // Called by <uvm_notification_objection::notified>
   //
   // Parameters:
   // action - The <uvm_objection_notification> describing this
   //          notification.
   virtual function void notified (uvm_objection_notification action);
   endfunction : notified
   
endclass : uvm_notification_objection_callback

// Class: uvm_notification_objection_callback_impl#(T)
// Parameterized extension of <uvm_notification_objection_callback>
//
// While the user can create their own extension of the
// notification objection base class, the most common implementation
// would simply be a pass-through, wherein a sequence or component
// needs to be told when the callbacks occur.
//
// The uvm_notification_objection_callback_impl is a parameterized
// version of the <uvm_notification_objection_callback>, which works
// very similarly to the TLM impl's which are provided by the library.
// By simply passing a reference to the type which holds the ~objection_notified~
// before registering the callback with an objection, the user effectively
// connects the objection to their type.
//
// For example:
//
//| class my_listener;
//|  virtual function void objection_notified(uvm_objection_notification action);
//|    //... do something with the notification
//|  endfunction : objection_notified
//| endclass : my_listener
//| ...
//| initial begin
//|  my_listener lstnr = new;
//|  uvm_notification_objection_callback_impl#(my_listener) cb = new("cb");
//|  cb.set_impl(lstnr);
//|  uvm_notification_objection_cbs_t::add(null, cb); // typewide callback
//| end
   
class uvm_notification_objection_callback_impl#(type T=int) extends uvm_notification_objection_callback;
   
   protected T m_imp;

   // Function: new
   // Constructor
   function new(string name="");
      super.new(name);
   endfunction : new

   // Function: set_imp
   // Sets the implementation reference for the callback
   function void set_imp(T imp);
      m_imp = imp;
   endfunction : set_imp

   // Function: notified
   // Objection notified callback function
   virtual function void notified (uvm_objection_notification action);
      if (m_imp == null) begin
        `uvm_error("UVM/BASE/NTFCN_OBJCTN/CB/NULL_IMP",
                   "callback triggered w/ null implementation")
        return;
      end

      m_imp.objection_notified(action);
   endfunction : notified

endclass : uvm_notification_objection_callback_impl



  
