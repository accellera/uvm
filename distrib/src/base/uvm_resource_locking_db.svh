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
// class: uvm_resource_locking_db
//
// The uvm_resource_locking_db#(T) class provides a convenience
// interface for the resources facility for locking resource.  In many
// cases basic operations such as creating and setting a resource or
// getting a resource could take multiple lines of code using the
// interfaces in <uvm_resource_base> or <uvm_resource#(T)>.  The
// convenience layer in uvm_resource_locking_db#(T) reduces many of
// those operations to a single line of code.
//
// All of the functions in uvm_resource_locking_db#(T) are static, so
// they must be called using the :: operator.  For example:
//
//|  uvm_resource_locking_db#(int)::set("A", "*", 17, this);
//
// The parameter value "int" identifies the resource type as
// uvm_resource#(int).  Thus, the type of the object in the resource
// container is int. This maintains the type-safety characteristics of
// resource operations.
//----------------------------------------------------------------------
class uvm_resource_locking_db #(type T=uvm_object);

  typedef uvm_locker #(T) locker_t;
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

  // function: get_by_type
  //
  // Get a resource by type.  The type is specified in the db
  // class parameter so the only argument to this function is the
  // ~scope~.

  static function rsrc_t get_by_type(string scope);
    return rsrc_t::get_by_type(scope, rsrc_t::get_type());
  endfunction

  // function: get_by_name
  //
  // Imports a resource by ~name~.  The first argument is the ~name~ of the
  // resource to be retrieved and the second argument is the current
  // ~scope~. The ~rpterr~ flag indicates whether or not to generate
  // a warning if no matching resource is found.

  static function rsrc_t get_by_name(string scope,
                                     string name,
                                     bit rpterr=1);

    return rsrc_t::get_by_name(scope, name, rpterr);
  endfunction

  // function: set_default
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


  // function: set
  //
  // Create a new resource, write a ~val~ to it, and set it into the
  // database using ~name~ and ~scope~ as the lookup parameters. The
  // ~accessor~ is used for auditting.
  static function void set(input string scope,
                           input string name,
                           T val,
                           input uvm_object accessor = null);

    rsrc_t rsrc = new(name, scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_locking_db", "try_write failed in set()");
    end
    rsrc.write(lck, accessor);
    rsrc.set();

  endfunction

  // function: set_anonymous
  //
  // Create a new resource, write a ~val~ to it, and set it into the
  // database.  The resource has no name and therefore will not be
  // entered into the name map. But is does have a ~scope~ for lookup
  // purposes. The ~accessor~ is used for auditting.
  static function void set_anonymous(input string scope,
                                     T val, input uvm_object accessor = null);

    rsrc_t rsrc = new("", scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_locking_db", "try_write failed in set_anonymous()");
    end
    rsrc.write(lck, accessor);
    rsrc.set();

  endfunction

  // function set_override
  //
  // Create a new resource, write ~val~ to it, and set it into the
  // database.  Set it at the beginning of the queue in the type map and
  // the name map so that it will be (currently) the highest priority
  // resource with the specified name and type.

  function void set_override(input string scope, input string name,
                             T val, uvm_object accessor = null);

    rsrc_t rsrc = new(name, scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_locking_db", "try_write failed in set_override()");
    end
    rsrc.write(lck, accessor);
    rsrc.set_override();
  endfunction

  // function set_override_type
  //
  // Create a new resource, write ~val~ to it, and set it into the
  // database.  Set it at the beginning of the queue in the type map so
  // that it will be (currently) the highest priority resource with the
  // specified type. It will be normal priority (i.e. at the end of the
  // queue) in the name map.

  function void set_override_type(input string scope, input string name,
                                  T val, uvm_object accessor = null);

    rsrc_t rsrc = new(name, scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_locking_db", "try_write failed in set_override_type()");
    end
    rsrc.write(lck, accessor);
    rsrc.set_override(uvm_resource_types::TYPE_OVERRIDE);
  endfunction

  // function set_override_name
  //
  // Create a new resource, write ~val~ to it, and set it into the
  // database.  Set it at the beginning of the queue in the name map so
  // that it will be (currently) the highest priority resource with the
  // specified name. It will be normal priority (i.e. at the end of the
  // queue) in the type map.

  function void set_override_name(input string scope,
                                  input string name,
                                  T val,
                                  uvm_object accessor = null);

    rsrc_t rsrc = new(name, scope);
    locker_t lck = new();

    if(!lck.try_write(val)) begin
      uvm_report_error("uvm_resource_locking_db", "try_write failed in set_override_name()");
    end
    rsrc.write(lck, accessor);
    rsrc.set_override(uvm_resource_types::NAME_OVERRIDE);
  endfunction

  // function: read_by_name
  //
  // locate a resource by ~name~ and ~scope~ and read its value. The value 
  // is returned through the ref argument ~val~.  The return value is a bit 
  // that indicates whether or not the read was successful. The ~accessor~
  // is used for auditting.

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

  // function: read_by_type
  //
  // Read a value by type.  The value is returned through the ref
  // argument ~val~.  The ~scope~ is used for the lookup. The return
  // value is a bit that indicates whether or not the read is successful.
  // The ~accessor~ is used for auditting.
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

  // function: write_by_name
  //
  // write a ~val~ into the resources database.  First, look up the
  // resource by ~name~ and ~scope~.  If it is not located then add a new 
  // resource to the database and then write its value.
  //
  // Because the ~scope~ is matched to a resource which may be a
  // regular expression, and consequently may target other scopes beyond
  // the ~scope~ argument. Care must be taken with this function. If
  // a <get_by_name> match is found for ~name~ and ~scope~ then ~val~
  // will be written to that matching resource and thus may impact
  // other scopes which also match the resource.

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

  // function: write_by_type
  //
  // write a ~val~ into the resources database.  First, look up the
  // resource by type.  If it is not located then add a new resource to
  // the database and then write its value.
  //
  // Because the ~scope~ is matched to a resource which may be a
  // regular expression, and consequently may target other scopes beyond
  // the ~scope~ argument. Care must be taken with this function. If
  // a <get_by_name> match is found for ~name~ and ~scope~ then ~val~
  // will be written to that matching resource and thus may impact
  // other scopes which also match the resource.

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

  // function: lock

  static task lock(rsrc_t rsrc);

    locker_t lckr;

    if(rsrc == null)
      return;

    lckr = rsrc.read();
    lckr.lock();
  endtask

  // function: try_lock

  static function bit try_lock(rsrc_t rsrc);

    locker_t lckr;

    if(rsrc == null)
      return 0;

    lckr = rsrc.read();
    return lckr.try_lock();
  endfunction

  // function: unlock

  static function void unlock(rsrc_t rsrc);

    locker_t lckr;

    if(rsrc == null)
      return;

    lckr = rsrc.read();
    lckr.unlock();
  endfunction

  // function: read

  static task read(rsrc_t rsrc, output T t, input uvm_object accessor = null);

    locker_t lckr;

    if(rsrc == null)
      return;

    lckr = rsrc.read(accessor);
    lckr.read(t);
  endtask

  // function: try_read

  static function bit try_read(rsrc_t rsrc, T t, input uvm_object accessor = null);

    locker_t lckr;

    if(rsrc == null)
      return 0;

    lckr = rsrc.read();
    if(!lckr.try_read(t))
      return 0;

    rsrc.record_read_access(accessor);
    return 1;
  endfunction

  // function: write

  static task write(rsrc_t rsrc, input T t, input uvm_object accessor = null);

    locker_t lckr;

    if(rsrc == null)
      return;

    lckr = rsrc.read();
    lckr.write(t);
    rsrc.record_write_access(accessor);
  endtask

  // function: try_write

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
