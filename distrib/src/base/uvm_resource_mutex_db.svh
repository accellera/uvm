//----------------------------------------------------------------------
//   Copyright 2011 Cypress Semiconductor
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

//----------------------------------------------------------------------
// class- uvm_resource_mutex_db
//
// The uvm_resource_mutex_db#(T) class provides a convenience
// interface for the resources facility for locking resource.  In many
// cases basic operations such as creating and setting a resource or
// getting a resource could take multiple lines of code using the
// interfaces in <uvm_resource_base> or <uvm_resource#(T)>.  The
// convenience layer in uvm_resource_mutex_db#(T) reduces many of
// those operations to a single line of code.

// This convenience interface provides a wrapper around resources whose
// type is uvm_mutex_locker#(T).  This layer provides static tasks for
// accessing data in the locker using the locking protocol in
// uvm_mutex_locker#(T).
//
// All of the functions in uvm_resource_mutex_db#(T) are static, so
// they must be called using the :: operator.  For example:
//
//|  uvm_resource_mutex_db#(int)::set("A", "*", 17, this);
//
// The parameter value "int" identifies the resource type as
// uvm_resource#(int).  Thus, the type of the object in the resource
// container is int. This maintains the type-safety characteristics of
// resource operations.
//----------------------------------------------------------------------
class uvm_resource_mutex_db #(type T=uvm_object);

  typedef uvm_mutex_locker #(T) locker_t;
  typedef uvm_resource #(locker_t) rsrc_t;

  // All of the functions in this class are static, so there is no need
  // to instantiate this class ever.  To make sure that the constructor
  // is never called it's good practice to make it local or at least
  // protected. However, IUS doesn't support protected constructors so
  // we'll just the default constructor instead.  If support for
  // protected constructors ever becomes available then this comment can
  // be deleted and the protected constructor uncommented.

  //  protected function new();
  //  endfunction

  // funciton- get_by_type
  //
  // Get a resource by type.  The type is specified in the db
  // class parameter so the only argument to this function is the
  // ~scope~.

  static function rsrc_t get_by_type(string scope);
    return rsrc_t::get_by_type(scope, rsrc_t::get_type());
  endfunction

  // funciton- get_by_name
  //
  // looks up a resource by ~name~.  The first argument is the ~name~ of
  // the resource to be retrieved and the second argument is the current
  // ~scope~. The ~rpterr~ flag indicates whether or not to generate a
  // warning if no matching resource is found.  Whether or not the
  // rpterr flag is set, null is returned if a resource matching the
  // supplied criteria is not found.

  static function rsrc_t get_by_name(string scope,
                                     string name,
                                     bit rpterr=1);

    return rsrc_t::get_by_name(scope, name, rpterr);
  endfunction

  // funciton- set_default
  //
  // add a new item into the resources database.  The item will not be
  // written to so it will have its default value. The resource is
  // created using ~name~ and ~scope~ as the lookup parameters.

  static function rsrc_t set_default(string scope, string name);

    rsrc_t r;
    locker_t lck;

    lck = new();
    r = new(name, scope);

    r.write(lck);
    r.set();
    return r;

  endfunction

  // funciton- set
  //
  // Create a new locker and a new resource, write ~val~ to the locker,
  // and set it into the database using ~name~ and ~scope~ as the lookup
  // parameters. The ~accessor~ is used for auditing.  This method is a
  // function so it will never block.  It uses try_lock() instead of
  // lock() to ensure that nothing changes during the write operation.
  // That odds that anything will change, or that even any other thread
  // will have access to the resource is negligible since the resource
  // is created immediately before it is used.  The reason that this
  // method is a function and not a task, is so we can call set() in
  // functions, most notably build().

  static function void set(input string scope,
                           input string name,
                           T val,
                           input uvm_object accessor = null);

    rsrc_t rsrc = new(name, scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_mutex_db", "try_write failed in set()");
    end
    rsrc.write(lck, accessor);
    rsrc.set();

  endfunction

  // funciton- set_anonymous
  //
  // Create a new resource and a locker, write ~val~ to the locker, and
  // set it into the database.  The resource has no name and therefore
  // will not be entered into the name map. But is does have a ~scope~
  // for lookup purposes. The ~accessor~ is used for auditting.  Like
  // set(), this method is a function so that it can be called from
  // other functions, such as build().

  static function void set_anonymous(input string scope,
                                     T val, input uvm_object accessor = null);

    rsrc_t rsrc = new("", scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_mutex_db", "try_write failed in set_anonymous()");
    end
    rsrc.write(lck, accessor);
    rsrc.set();

  endfunction

  // funciton- set_override
  //
  // Create a new resource and loker, write ~val~ to the locker, and set
  // it into the database.  Set it at the beginning of the queue in the
  // type map and the name map so that it will be (currently) the
  // highest priority resource with the specified name and type.  Like
  // set(), this method is a function so that it can be called from
  // other functions, such as build().

  static function void set_override(input string scope, input string name,
                                    T val, uvm_object accessor = null);

    rsrc_t rsrc = new(name, scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_mutex_db", "try_write failed in set_override()");
    end
    rsrc.write(lck, accessor);
    rsrc.set_override();
  endfunction

  // funciton- set_override_type
  //
  // Create a new resource and locker, write ~val~ to the locker, and
  // set it into the database.  Set it at the beginning of the queue in
  // the type map so that it will be (currently) the highest priority
  // resource with the specified type. It will be normal priority
  // (i.e. at the end of the queue) in the name map. Like set(), this
  // method is a function so that it can be called from other functions,
  // such as build().

  static function void set_override_type(input string scope,
                                         input string name,
                                         T val, uvm_object accessor = null);

    rsrc_t rsrc = new(name, scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_mutex_db", "try_write failed in set_override_type()");
    end
    rsrc.write(lck, accessor);
    rsrc.set_override(uvm_resource_types::TYPE_OVERRIDE);
  endfunction

  // funciton- set_override_name
  //
  // Create a new resource and locker, write ~val~ to the locker, and
  // set it into the database.  Set it at the beginning of the queue in
  // the name map so that it will be (currently) the highest priority
  // resource with the specified name. It will be normal priority
  // (i.e. at the end of the queue) in the type map. Like set(), this
  // method is a function so that it can be called from other functions,
  // such as build().

  static function void set_override_name(input string scope,
                                         input string name,
                                         T val,
                                         uvm_object accessor = null);

    rsrc_t rsrc = new(name, scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_mutex_db", "try_write failed in set_override_name()");
    end
    rsrc.write(lck, accessor);
    rsrc.set_override(uvm_resource_types::NAME_OVERRIDE);
  endfunction

  // funciton- read_by_name
  //
  // locate a locker by ~name~ and ~scope~ and read its value. The value
  // is returned through the ref argument ~val~.  The return value is a
  // bit that indicates whether or not the read was successful. The
  // ~accessor~ is used for auditting.  The locking API is used to
  // ensure mutually exclusive access to the data during the
  // operation. Read() will block until the lock is acquired.

  static task read_by_name(input string scope,
                           input string name,
                           ref T val,
                           inout bit ok,
                           input uvm_object accessor = null);

    locker_t lckr;
    rsrc_t rsrc = get_by_name(scope, name);

    if(rsrc == null) begin
      ok = 0;
      return;
    end

    lckr = rsrc.read(accessor);
    lckr.read(val);
    ok = 1;
  
  endtask

  // funciton- read_by_type
  //
  // Locate a locker by type and read its value.  The value is returned
  // through the ref argument ~val~.  The ~scope~ is used for the
  // lookup. The return value is a bit that indicates whether or not the
  // read is successful.  The ~accessor~ is used for auditting.  The
  // locking API is used to ensure mutually exclusive access to the data
  // during the operation. Read() will block until the lock is acquired.

  static task read_by_type(input string scope,
                           ref T val,
                           inout bit ok,
                           input uvm_object accessor = null);
    
    locker_t lckr;
    rsrc_t rsrc = get_by_type(scope);

    if(rsrc == null) begin
      ok = 0;
      return;
    end

    lckr = rsrc.read(accessor);
    lckr.read(val);
    ok = 1;

  endtask

  // funciton- write_by_name
  //
  // Locate a locker by name and update its value with ~val~.  Look up
  // the resource by ~name~ and ~scope~.  The locker API is used to
  // ensure mutually exclusive access to the data during the
  // operation. Write() will block until the lock is acquired.

  static task write_by_name(input string scope,
                            input string name,
                            T val,
                            inout bit ok,
                            input uvm_object accessor = null);

    locker_t lckr;
    rsrc_t rsrc = get_by_name(scope, name);

    if(rsrc == null) begin
      ok = 0;
      return;
    end

    lckr = rsrc.read();
    lckr.write(val);
    rsrc.record_write_access(accessor);
    ok = 1;

  endtask

  // funciton- write_by_type
  //
  // Locate a locker in the resource data and update its value with
  // ~val~. Look up the resource by type. The locking API is used to
  // ensure mutually exclusive access to the data during the
  // operation. Write() will block until the lock is acquired.

  static task write_by_type(input string scope,
                            input T val,
                            inout bit ok,
                            input uvm_object accessor = null);

    locker_t lckr;
    rsrc_t rsrc = get_by_type(scope);

    // resrouce was not found in the database, so let's add one
    if(rsrc == null) begin
      ok = 0;
      return;
    end

    lckr = rsrc.read();
    lckr.write(val);
    rsrc.record_write_access(accessor);
    ok = 1;

  endtask

  // funciton- lock
  //
  // Lock the resource supplied as an argument.  Lock() will block until
  // the lock is acquired.  The resource must be a "locker resource",
  // one whose type is uvm_resource#(uvm_mutext_locker#(T)).

  static task lock(rsrc_t rsrc);

    locker_t lckr;

    if(rsrc == null)
      return;

    lckr = rsrc.read();
    lckr.lock();
  endtask

  // funciton- try_lock
  //
  // Try_lock() requests the lock of the resource supplied as an
  // argument, and returns immediatly whether or not the lock was
  // acquired.  A status value is returned to indicate whether or not
  // the lock was acquired.  1 means the lock was successfully required,
  // 0 means it was not.

  static function bit try_lock(rsrc_t rsrc);

    locker_t lckr;

    if(rsrc == null)
      return 0;

    lckr = rsrc.read();
    return lckr.try_lock();
  endfunction

  // funciton- unlock
  //
  // Release the lock for the resource supplied as an argument.  The
  // lock can be released only by the process that acquired it.  This is
  // enforced in the locker policy.

  static function void unlock(rsrc_t rsrc);

    locker_t lckr;

    if(rsrc == null)
      return;

    lckr = rsrc.read();
    lckr.unlock();
  endfunction

  // funciton- read
  //
  // Read the value from a resource supplied as an argument.  The
  // resource must be a locker resource, one whose type is
  // uvm_resource#(uvm_mutex_locker#(T)).  The read() task may block
  // until the lock is acquired.  The lock is released after the
  // operation is complete.

  static task read(rsrc_t rsrc, output T t, input uvm_object accessor = null);

    locker_t lckr;

    if(rsrc == null)
      return;

    lckr = rsrc.read(accessor);
    lckr.read(t);
  endtask

  // funciton- try_read
  //
  // Nonblocking form of read.  It will return immeditaly, whether or
  // not the operation completed successfully.  If the read is
  // successfull, that is the lock is acquired and the data accessed,
  // then the output T argument will contain the value held in the
  // locker and a 1 will be returned.  If the operation is not
  // successful 0 is returned.

  static function bit try_read(rsrc_t rsrc,
                               output T t,
                               input uvm_object accessor = null);

    locker_t lckr;

    if(rsrc == null)
      return 0;

    lckr = rsrc.read();
    if(!lckr.try_read(t))
      return 0;

    rsrc.record_read_access(accessor);
    return 1;

  endfunction

  // funciton- write
  //
  // Write a new value to the resource supplied as an argument.  The
  // resource must be a locker resource, one whose type is
  // uvm_resource#(uvm_mutex_locker#(T)).  The write() task may block
  // until the lock is acquired.  The lock is released after the
  // operation is complete.

  static task write(rsrc_t rsrc, input T t, input uvm_object accessor = null);

    locker_t lckr;

    if(rsrc == null)
      return;

    lckr = rsrc.read();
    lckr.write(t);
    rsrc.record_write_access(accessor);
  endtask

  // funciton- try_write
  //
  // Nonblocking form of write.  It will return immeditaly, whether or
  // not the operation completed successfully.  If the write is
  // successfull, that is the lock is acquired and the data in the
  // locker is udated, then a 1 will be returned.  If the operation is
  // not successful 0 is returned.

  static function bit try_write(rsrc_t rsrc, T t, input uvm_object accessor = null);

    locker_t lckr;

    if(rsrc == null)
      return 0;

    lckr = rsrc.read();
    if(!lckr.try_write(t))
      return 0;

    rsrc.record_write_access(accessor);
    return 1;
  endfunction

endclass
