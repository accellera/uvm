//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
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
// access record for resources.  A set of these is stored for each
// resource by accessing object.  It's updated for each read/write.
//----------------------------------------------------------------------
typedef struct
{
  time read_time;
  time write_time;
  int unsigned read_count;
  int unsigned write_count;
} access_t;

//----------------------------------------------------------------------
// class: uvm_resource_base
//
// Non-parameterized base class for resources.  Supports interfaces for
// locking/unlocking, scope matching, and virtual functions for printing
// the resource and for printing the accessor list
//----------------------------------------------------------------------
virtual class uvm_resource_base extends uvm_object;

  protected semaphore sm;
  protected string scope;
  protected bit modified;
  protected bit read_only;

  access_t access[uvm_object];

  function new(string name, string s = "*");
    super.new(name);
    set_scope(s);
    sm = new(1);
    modified = 0;
    read_only = 0;
  endfunction

  // function: get_type_handle
  //
  // Pure virtual function that returns the type handle of the resource
  // container.
  pure virtual function uvm_resource_base get_type_handle();

  //--------------------------------------------------------------------
  // group: Locking Interface
  //
  // The task lock() and the functions try_lock() and unlock() form a
  // locking interface for resources.  These can be used for thread-safe
  // reads and writes.  The put/get interface in uvm_resource#(T) (a
  // family of resource subclasses) obey the lock when reading and
  // writing.  See documentation in uvm_resource #(T) form more
  // information on put/get.  The lock interface is a wrapper around a
  // local semaphore.
  //--------------------------------------------------------------------

  // task: lock
  //
  // Retrieves a lock for this resource.  The task blocks until the lock
  // is obtained.
  task lock();
    sm.get();
  endtask

  // function: try_lock
  //
  // Retrives the lock for this resource.  The function is nonblocking,
  // so it will return immediately.  If it was successfull in retrieving
  // the lock then a one is returned, otherwise a zero is returned.
  function bit try_lock();
    return sm.try_get();
  endfunction

  // function unlock
  //
  // Releases the lock held by this semaphore.  
  function void unlock();
    sm.put();
  endfunction

  //--------------------------------------------------------------------
  // group: Read-only interface
  //--------------------------------------------------------------------

  // function: set_read_only
  //
  // Establishes this resource as a read-only resource.  Write will i
  function void set_read_only();
    read_only = 1;
  endfunction

  // function set_read_write
  //
  // Returns the resource to normal read-write capability.
  //
  // Note: Not sure if this function is necessary.  Once a resource is
  // set to read_only no one should be able to change that.  If anyone
  // can flip the read_only bit then the resource is not truly
  // read_only.
  function void set_read_write();
    read_only = 0;
  endfunction

  // function: is_read_only
  //
  // Retruns one if this resource has been set to read-only, zero
  // otherwise
  function bit is_read_only();
    return read_only;
  endfunction

  //--------------------------------------------------------------------
  // group: Notification
  //--------------------------------------------------------------------

  // task: wait_modified
  //
  // This task blocks until the resource has been modified -- that is, a
  // read operation has been performed.  When a read is performed the
  // modified bit is set which releases the block.  Wait_modified() then
  // clears the modified bit so it can be called repeatedly.
  task wait_modified();
    wait (modified == 1);
    modified = 0;
  endtask

  //--------------------------------------------------------------------
  // group: Scope Interface
  //
  // Each resource has a name, a value and a set of scopes over which it
  // is visible. A scope is a hierarchical entity or a context.  A scope
  // name is a multi-element string that identifies a scope.  Each
  // element refers to a scope context and the elements are separated by
  // dots (.).
  // 
  //|    top.env.agent.monitor
  // 
  // Consider the example above of a scope name.  It consists of four
  // elements: "top", "env", "agent", and "monitor".  The elements are
  // strung together with a dot separating each element.  Top.env.agent
  // is the parent of top.env.agent.monitor, top.env is the parent of
  // top.env.agent, and so on.  A set of scopes can be represented by a
  // set of scope name strings.  A very straightforward way to represent
  // a set of strings is to use regular expressions.  A regular
  // expression is a special string that contains placeholders which can
  // be substituted in various ways to generate or recognized a
  // particular set of strings.  Here are a few simple examples:
  // 
  //|     top\..*	                all of the scopes whose top-level component
  //|                            is top
  //|    top\.env\..*\.monitor	all of the scopes in env that end in monitor;
  //|                            i.e. all the monitors two levels down from env
  //|    .*\.monitor	            all of the scopes that end in monitor; i.e.
  //|                            all the monitors (assuming a naming convention
  //|                            was used where all monitors are named "monitor")
  //|    top\.u[1-5]\.*	        all of the scopes rooted and named u1, u2, u3,
  //                             u4, or u5, and any of their subscopes.
  // 
  // The examples above use posix regular expression notation.  This is
  // a very general and expressive notation.  It is not always the case
  // that so much expressiveness is required.  Sometimes an expression
  // syntax that is easy to read and easy to write is useful, even if
  // the syntax is not as expressive as the full power of posix regular
  // expressions.  A popular substitute for regular expressions is
  // globs.  A glob is a simplified regular expression. It only has
  // three metacharacters -- *, +, and ?.  Character ranges are not
  // allowed and dots are not a metacharacter in globs as they are in
  // regular expressions.  The following table shows glob
  // metacharacters.
  // 
  //|      char	meaning	                regular expression
  //|                                    equivalent
  //|      *	    0 or more characters	.*
  //|      +	    1 or more characters	.+
  //|      ?	    exactly one character	.
  // 
  // Of the examples above, the first three can easily be translated
  // into globls.  The last one cannot.  It relies on notation that is
  // not available in glob syntax.
  // 
  //|    regular expression	    glob equivalent
  //|    top\..*	                top.*
  //|    top\.env\..*\.monitor	top.env.*.monitor
  //|    .*\.monitor	            *.monitor
  // 
  // The resource facility supports both regular expression and glob
  // syntax.  Regular expressions are identified as such when they begin
  // with a % (which is otherwise an invalid regular expressions
  // character).  Expressions that begin with a % have the initial
  // character stripped and are treated as regular expressions.
  // Expressions that do not begin with a % are considered to be globs.
  // They are converted from glob notation to regular expression
  // notation internally.  Regular expression compilation and matching
  // as well as glob-to-regular expression conversion are handled by
  // three DPI functions:
  // 
  //|    function int uvm_re_match(string re, string str);
  //|    function void uvm_dump_re_cache();
  //|    function string uvm_glob_to_re(string glob);
  // 
  // uvm_re_match both compiles and matches the regular expression.  It
  // uses internal caching of compiled information so that each match
  // does not necessarily require a new compilation of the regular
  // expression string.  All of the matching is done using regular
  // expressions, so globs are converted to regular expressions and then
  // processed.
  //
  //--------------------------------------------------------------------

  // function: set_scope
  //
  // Set the value of the regular expression that identifies the set of
  // scopes over which this resource is visible.  If the supplied
  // argument is a glob it will be converted to a regular expression
  // before it is stored.
  function void set_scope(string s);
    scope = uvm_glob_to_re(s);
    if(scope == "") begin
      `uvm_warning("set_scope", "Empty scope string, reverting to \"*\"");
      scope = "\.*";
    end
  endfunction

  // funciton get_scope
  //
  // Retrieve the regular expression string that identifies the set of
  // scopes over which this resource is visible.
  function string get_scope();
    return scope;
  endfunction

  // function: match_scope
  //
  // pUsing the regular expression facility, determine if this resource
  // is visible in a scope.  Return one if it is, zero otherwise.
  function bit match_scope(string s);
    int err = uvm_re_match(scope, s);
    return (err == 0);
  endfunction

  //--------------------------------------------------------------------
  // group: Utility Functions
  //--------------------------------------------------------------------

  // function convert2string
  //
  // Create a string representation of the resource value.  By default
  // we don't know how to do this so we just return a "?".  Resource
  // specializations are expected to override this function to produce a
  // proper string representation of the resource value.
  function string convert2string();
    return "?";
  endfunction

  // function: do_print
  //
  // Implementation of do_print which is called by print().
  function void do_print (uvm_printer printer);
    $display("  %s = %s [%s]", get_name(), convert2string(), get_scope());
  endfunction

  //--------------------------------------------------------------------
  // group: Audit Trail
  //
  // To find out what happened as the simulation proceeds, an audit trail of
  // each read and write is kept. The read and write methods
  // in uvm_resource#(T) each take an accessor argument.  This is a
  // handle to the object that performed that resource access.
  //
  //|    function T read(uvm_object accessor = null);
  //|    function void write(T t, uvm_object accessor = null);
  //
  // The accessor can by anything as long as it is derived from
  // uvm_object.  The accessor object can be a component or a sequence
  // or whatever object from which a read or write was invoked.
  // Typically the âthisâ handle is used as the
  // accessor.  For example:
  //
  //|    uvm_resource#(int) rint;
  //|    int i;
  //|    ...
  //|    rint.write(7, this);
  //|    i = rint.read(this);
  //
  // The accessor handle is stored as part of the audit trail.  This way
  // you can find out what object performed each resource access.  Each
  // audit record also includes the time of the access (simulation time)
  // and the particular operation performed (read or write).
  //
  //--------------------------------------------------------------------

  // function: print_accessors
  //
  // Dump the access records for this resource
  virtual function void print_accessors();

    uvm_object obj;
    uvm_component comp;
    access_t access_record;

    if(access.num() == 0)
      return;

    $display("  --------");

    foreach (access[i]) begin
      obj = i;

      if($cast(comp, obj))
        $write("  %s", comp.get_full_name());
      else
        $write("  %s", obj.get_name());

      access_record = access[obj];
      $display(" reads: %0d @ %0t  writes: %0d @ %0t",
               access_record.read_count,
               access_record.read_time,
               access_record.write_count,
               access_record.write_time);
    end

    $display();

  endfunction

  // function: init_access_record
  //
  // Initalize a new access record
  function void init_access_record (inout access_t access_record);
    access_record.read_time = 0;
    access_record.write_time = 0;
    access_record.read_count = 0;
    access_record.write_count = 0;
  endfunction

endclass

//----------------------------------------------------------------------
// class: acquire_t
//
// Instances of acquire_t are stored in the history list as a record of
// each acquire.  Failed acquisitions are indicated with rsrc set to
// null.  This is part of the audit trail facility for resources.
//----------------------------------------------------------------------
class acquire_t;
  string name;
  string scope;
  uvm_resource_base rsrc;
  time t;
endclass

//----------------------------------------------------------------------
// class: uvm_resource_pool
//
// global (singleton) resource pool
//
// Each resource is stored both by primary name and by type handle.  The
// resource pool contains two associative arrays, one with name as the
// key and one with the type handle as the key.  Each associative array
// contains a queue of resources.  Each resource has a regular
// expression that represents the set of scopes over with it is visible.
//
//|  +------+------------+                          +------------+------+
//|  | name | rsrc queue |                          | rsrc queue | type |
//|  +------+------------+                          +------------+------+
//|  |      |            |                          |            |      |
//|  +------+------------+                  +-+-+   +------------+------+
//|  |      |            |                  | | |<--+---*        |  T   |
//|  +------+------------+   +-+-+          +-+-+   +------------+------+
//|  |  A   |        *---+-->| | |           |      |            |      |
//|  +------+------------+   +-+-+           |      +------------+------+
//|  |      |            |      |            |      |            |      |
//|  +------+------------+      +-------+  +-+      +------------+------+
//|  |      |            |              |  |        |            |      |
//|  +------+------------+              |  |        +------------+------+
//|  |      |            |              V  V        |            |      |
//|  +------+------------+            +------+      +------------+------+
//|  |      |            |            | rsrc |      |            |      |
//|  +------+------------+            +------+      +------------+------+
//
// The above diagrams illustrates how a resource whose name is A and
// type is T is stored in the pool.  The pool contains an entry in the
// type map for type T and an entry in the name map for name A.  The
// queues in each of the list each contain an entry for the resource A
// whose type is T.  The name map can contain in its queue other
// resources whose name is A which may or may not have the same type as
// our resource A.  Similarly, the type map can contain in its queue
// other resources whose type is T and whose name may or may not be A.
//
// Resources are added to the pool by publishing them; they are
// retrieved from the pool by acquireing them.  The terms acquire and
// publish are relative to the object performing the operation.  An
// object creates a new resource and publishes it to the pool thereby
// making it available for other objects outside of itsef; an object
// acquires a resource when it wants to access a resource not currently
// available in its scope.
//
// The scope is stored in the resource itself (not in the pool) so
// whether you acquire by name or by type the resource's visibility is
// the same.
//
// As an auditting capability, the pool contains an acquire history.  A
// record of each acquire, whether by type or by name, is stored in the
// queue acquire_record.  Both successful and failed acquisitions are
// recorded. At the end of simulator, or any time for that matter, you
// can dump history list.  This will tell users which resources were
// successfully located and which were not.  Users can then tell if
// their expectations are met or if there is some error in name, type,
// or scope that caused a resource to not be located or incorrrectly
// located (i.e. the wrong one is located).
//
//----------------------------------------------------------------------
class uvm_resource_pool;

  static local uvm_resource_pool rp = get();

  typedef uvm_queue#(uvm_resource_base) rsrc_q_t;

  rsrc_q_t rtab [string];
  rsrc_q_t ttab [uvm_resource_base];

  acquire_t acquire_record [$];  // history of acquisitions

  // To make a proper singleton the constructor should be protected.
  // However, IUS doesn't support protected constructors so we'll just
  // the default constructor instead.  If support for protected
  // constructors ever becomes available then this comment can be
  // deleted and the protected constructor uncommented.

  //  protected function new();
  //  endfunction

  // function: get
  //
  // Returns the singleton handle to the resource pool

  static function uvm_resource_pool get();
    if(rp == null)
      rp = new();
    return rp;
  endfunction

  // function: spell_check
  //
  // Invokes the spell checker for a string s.  The universe of
  // correctly spelled strings -- i.e. the dictionary -- is the name
  // map.

  function bit spell_check(string s);
    return uvm_spell_chkr#(rsrc_q_t)::check(rtab, s);
  endfunction

  // function: publish
  //
  // Add a new resource to the resource pool.  The resource is inserted
  // into both the name map and type map so it can be located by
  // either.
  //
  // The notion of publishing a resource is relative to the object doing
  // the publishing.  That is, an object creates a resources and
  // ~publishes~ it into the resource pool.  Later, other objects that
  // want to access the resource must ~acquire~ it from the pool

  function void publish (uvm_resource_base rsrc, bit override = 0);

    rsrc_q_t rq;
    string name;
    uvm_resource_base type_handle;

    // If resource handle is null then there is nothing to do.
    if(rsrc == null)
      return;

    // insert into the name map.  Resources with empty names are
    // anonymous resources and are not entered into the name map
    name = rsrc.get_name();
    if(name != "") begin
      if(rtab.exists(name)) rq = rtab[name];
      else rq = new;

      if(override)
        rq.push_front(rsrc);
      else
        rq.push_back(rsrc);
      rtab[name] = rq;
    end

    // insert into the type map
    type_handle = rsrc.get_type_handle();
    if(ttab.exists(type_handle)) rq = ttab[type_handle];
    else rq = new;

    if(override)
      rq.push_front(rsrc);
    else
      rq.push_back(rsrc);
    ttab[type_handle] = rq;

  endfunction

  function void publish_override(uvm_resource_base rsrc);
    publish(rsrc, 1);
  endfunction

  // function: push_acquire_record
  //
  // Insert a new record into the acquire history list.

  function void push_acquire_record(string name, string scope,
                                  uvm_resource_base rsrc);
    acquire_t impt = new;

    impt.name  = name;
    impt.scope = scope;
    impt.rsrc  = rsrc;
    impt.t     = $time;

    acquire_record.push_back(impt);
  endfunction

  // function: dump_acquire_records
  //
  // Format and print the acquire history list.

  function void dump_acquire_records();

    acquire_t record;
    bit success;

    $display("--- resource acquire records ---");
    foreach (acquire_record[i]) begin
      record = acquire_record[i];
      success = (record.rsrc != null);
      $display("acquire: name=%s  scope=%s  %s @ %0t",
               record.name, record.scope,
               ((success)?"success":"fail"),
               record.t);
    end
  endfunction

  // function: acquire_by_name
  //
  // Lookup a resource by name and scope.  Whether the acquire succeeds
  // or fails, save a record of the acquire attempt.  The rpterr flag
  // indicates whether we should report errors or not.  Essentially, it
  // severes as a verbose flag.  If set then the spell checker will be
  // invoked and warnings about multiple resources will be produced.

  function uvm_resource_base acquire_by_name(string name, string scope = "", bit rpterr = 1);

    rsrc_q_t rq;
    rsrc_q_t matchq=new;
    uvm_resource_base rsrc;
    uvm_resource_base r;
    int unsigned i;
    string msg;

    // resources with empty names are anonymous and do not exist in the name map
    if(name == "")
      return null;

    // Does an entry in the name map exist with the specified name?
    // If not, then we're done
    if((rpterr && !spell_check(name)) || (!rpterr && !rtab.exists(name))) begin
      push_acquire_record(name, scope, null);
      return null;
    end

    // we search through the queue for the first resource that matches the scope
    rsrc = null;
    `uvm_clear_queue(matchq);
    rq = rtab[name];
    for(int i=0; i<rq.size(); ++i) begin 
      r = rq.get(i);
      if(r.match_scope(scope)) begin
        matchq.push_back(r);
      end
    end

    if(matchq.size() == 0) begin
      push_acquire_record(name, scope, null);
      return null;
    end

    if(rpterr && matchq.size() > 1) begin
      $sformat(msg, "There are multiple resources with name %s that are visible in scope %s.  The first one is the one that was used. The matching resources are:",
               name, scope);
      `uvm_warning("DUPRSRC", msg);
      for(int i=0; i<matchq.size(); ++i) begin 
        r = matchq.get(i);
        $display("    %s in scope %s", r.get_name(), r.get_scope());
      end
    end

    rsrc = matchq.get(0);
    push_acquire_record(name, scope, rsrc);
    return rsrc;
    
  endfunction

  // function: acquire_by_type
  //
  // Lookup a resource by type handle and scope.  Insert a record into
  // the acquire history list whether or not the acquire succeeded or
  // failed.

  function uvm_resource_base acquire_by_type(uvm_resource_base type_handle,
                                         string scope = "");

    rsrc_q_t rq;
    uvm_resource_base rsrc;
    uvm_resource_base r;
    int unsigned i;

    if(type_handle == null || !ttab.exists(type_handle)) begin
      push_acquire_record("<type>", scope, null);
      return null;
    end

    rsrc = null;
    rq = ttab[type_handle];
    for(int i=0; i<rq.size(); ++i) begin 
      r = rq.get(i);
      if(r.match_scope(scope)) begin
        rsrc = r;
        break;
      end
    end

    push_acquire_record("<type>", scope, rsrc);
    return rsrc;
    
  endfunction

  // function: retrieve_resources
  //
  // This is a utility function that answers the question: For a given
  // scope, what resources are visible to it?  Locate all the resources
  // that are visible to a particular scope.  This operation could be
  // quite expensive, as it has to traverse all of the resources in the
  // database.

  function rsrc_q_t retrieve_resources(string scope);

    rsrc_q_t rq;
    uvm_resource_base r;
    int unsigned i;
    int unsigned err;
    rsrc_q_t result_q = new;

    foreach (rtab[name]) begin
      rq = rtab[name];
      for(int i=0; i<rq.size(); ++i) begin
        r = rq.get(i);
        if(r.match_scope(scope)) begin
          if(result_q == null) result_q = new;
          result_q.push_back(r);
        end
      end
    end

    return result_q;
    
  endfunction

  // function: find_zeros
  //
  // Locate all the resources that have at least one write and no reads

  function rsrc_q_t find_zeros();

    rsrc_q_t rq;
    rsrc_q_t q = new;
    int unsigned i;
    uvm_resource_base r;
    access_t a;
    int reads;
    int writes;

    foreach (rtab[name]) begin
      rq = rtab[name];
      for(int i=0; i<rq.size(); ++i) begin
        r = rq.get(i);
        reads = 0;
        writes = 0;
        foreach(r.access[obj]) begin
          a = r.access[obj];
          reads += a.read_count;
          writes += a.write_count;
        end
        if(writes > 0 && reads == 0)
          q.push_back(r);
      end
    end

    return q;

  endfunction

  // function: print_resources
  //
  // Print the resources that are in a single queue.  This is a utility
  // function that can be used to print any collection of resources
  // stoed in a queue.  The audit flag determines whether or not the
  // audit trail is printed for each resource along with the name,
  // value, and scope regular expression.

  function void print_resources(rsrc_q_t rq, bit audit = 0);

    int unsigned i;
    uvm_resource_base r;
    static uvm_line_printer ptr=new;

    ptr.knobs.separator=""; ptr.knobs.full_name=0; ptr.knobs.identifier=0;
    ptr.knobs.type_name=0;  ptr.knobs.reference=0;

    if(rq == null && rq.size() == 0) begin
      $display("<none>");
      return;
    end

    for(int i=0; i<rq.size(); ++i) begin
      r = rq.get(i);
      r.print(ptr);
      if(audit == 1)
        r.print_accessors();
    end

  endfunction

  // function: dump
  //
  // dump the entire resource pool.  The resource pool is traversed and
  // each resource is printed.  The utility function print_resources()
  // is used to initiate the printing.

  function void dump();

    rsrc_q_t rq;
    string name;

    $display("\n=== resource pool ===");

    foreach (rtab[name]) begin
      rq = rtab[name];
      print_resources(rq);
    end

    $display("=== end of resource pool ===");

  endfunction

endclass

//----------------------------------------------------------------------
// class: uvm_resource #(T)
//
// Parameterized resource.  Provides essential access methods read and
// write.  Also provides locking access methods including put, try_put,
// get, and try_get.
//
// Read and write tracks resource access by updating access records.
//----------------------------------------------------------------------
class uvm_resource #(type T=int) extends uvm_resource_base;

  typedef uvm_resource#(T) this_type;

  // singleton handle that represents the type of this resource
  static this_type my_type = get_type();

  // Can't be rand since things like rand strings are not legal.
  protected T val;

  function new(string name="", scope="");
    super.new(name, scope);
  endfunction

  //--------------------------------------------------------------------
  // group: Type Interface
  //
  // Resources can be identified by type using a static type handle.
  // The parent class provides the virtual function interface
  // get_type_handle.  Here we implement it by returning the static type
  // handle.
  //--------------------------------------------------------------------

  // function get_type
  //
  // Static function that returns the static type handle.  The return
  // type is this_type, which is the type of the parameterized class.

  static function this_type get_type();
    if(my_type == null)
      my_type = new();
    return my_type;
  endfunction

  // function get_type_handle
  //
  // Returns the static type handle of this resource in a polymorphic
  // fashion.  The return type of get_type_handle() is
  // uvm_resource_base.  This function is not static and therefore can
  // only be used by instances of a parameterized resource.

  function uvm_resource_base get_type_handle();
    return get_type();
  endfunction

  //--------------------------------------------------------------------
  // group: Publish/Get Interface
  //
  // uvm_resource#(T) provides an interface for acquiring and publishing
  // a resource.  Specifically, a resource can publish itself.  It
  // doesn't make sense for a resource to acquire itself, since you
  // can't call a funtion on a handle you don't have.  However, a static
  // acquire interface is provided as a convenience.  This obviates the
  // need for the user to get a handle to the global resource pool as
  // this is done for him here.
  //--------------------------------------------------------------------

  // function: publish
  //
  // Simply publish this resource into the global resource pool

  function void publish();
    uvm_resource_pool rp = uvm_resource_pool::get();
    rp.publish(this);
  endfunction
  
  // function: publish_override
  //
  // Export a resource into the global resource pool as an override.
  // This means it gets put at the head of the list and is searched
  // before other existing resources that occupy the same position in
  // the name map or the type map.

  function void publish_override();
    uvm_resource_pool rp = uvm_resource_pool::get();
    rp.publish(this, 1);
  endfunction

  // function: acquire_by_name
  //
  // looks up a resource by name in the name map. The first resource
  // with the specified name that is visible in the specified scope is
  // returned, if one exists.  The rpterr flag indicates whether or not
  // an error should be reported if the search fails.  If rpterr is set
  // to one then a failure message is issued, including suggested
  // spelling alternatives gathered by the spell checker.

  static function this_type acquire_by_name(string name, string scope, bit rpterr = 1);

    uvm_resource_pool rp = uvm_resource_pool::get();
    uvm_resource_base rsrc_base;
    this_type rsrc;
    string msg;

    rsrc_base = rp.acquire_by_name(name, scope, rpterr);
    if(rsrc_base == null)
      return null;

    if(!$cast(rsrc, rsrc_base)) begin
      $sformat(msg, "Resource with name %s in scope %s has incorrect type", name, scope);
      `uvm_warning("RSRCTYPE", msg);
      return null;
    end

    return rsrc;
    
  endfunction

  // function: acquire_by_type

  // looks up a resource by type in the type map. The first resource
  // with the specified type that is visible in the specified scope is
  // returned, if one exists. Null is returned if a resource matching
  // the specifications was not located.

  static function this_type acquire_by_type(uvm_resource_base type_handle,
                                    string scope = "");

    uvm_resource_pool rp = uvm_resource_pool::get();
    uvm_resource_base rsrc_base;
    this_type rsrc;
    string msg;

    if(type_handle == null)
      return null;

    rsrc_base = rp.acquire_by_type(type_handle, scope);
    if(rsrc_base == null)
      return null;

    if(!$cast(rsrc, rsrc_base)) begin
      $sformat(msg, "Resource with specified type handle in scope %s was not located", scope);
      `uvm_warning("RSRCNF", msg);
      return null;
    end

    return rsrc;

  endfunction
  
  //--------------------------------------------------------------------
  // group: Read/Write Interface
  //
  // Read() and write() provide a type-safe interface for getting and
  // setting the object in the resource container.  The interface is
  // type safe because the value argument for write() and the return
  // value of read() are T, the type supplied in the class parameter.
  // If either of these functions is used in an incorrect type context
  // the compiler will complain.
  //--------------------------------------------------------------------

  // function: read
  //
  // Return the object stored in the resource container.  If an accessor
  // object is supplied then also update the accessor record for this
  // resource.

  function T read(uvm_object accessor = null);

    // If an accessor object is supplied then get the accessor record.
    // Otherwise create a new access record.  In either case populate
    // the access record with information about this access

    if(accessor != null) begin
      access_t access_record;
      if(access.exists(accessor))
        access_record = access[accessor];
      else
        init_access_record(access_record);
      access_record.read_count++;
      access_record.read_time = $time;
      access[accessor] = access_record;
    end

    // get the value
    return val;
  endfunction

  // function: write
  //
  // Modify the object stored in this resource container.  If the
  // resource is read-only then issue an error message and return
  // without modifying the object in the container.  If the resource is
  // not read-only and an accessor object has been supplied then also
  // update the accessor record.  Lastly, replace the object in the
  // container with the one supplied as an argument and set the modified
  // bit.  Setting the modified bit will release any processes blocked
  // on wait_modified().

  function void write(T t, uvm_object accessor = null);

    if(is_read_only()) begin
      uvm_report_error("resource", $psprintf("resource %s is read only -- cannot modify", get_name()));
      return;
    end

    // If an accessor object is supplied then get the accessor record.
    // Otherwise create a new access record.  In either case populate
    // the access record with information about this access

    if(accessor != null) begin
      access_t access_record;
      if(access.exists(accessor))
        access_record = access[accessor];
      else
        init_access_record(access_record);
      access_record.write_count++;
      access_record.write_time = $time;
      access[accessor] = access_record;
    end

    // set the value and set the dirty bit
    val = t;
    modified = 1;
  endfunction

  //--------------------------------------------------------------------
  // group: Locking Interface
  //
  // This interface is optional, you can choose to lock a resource or
  // not. These methods are wrappers around the read/write interface.
  // The difference between the read/write interface and the locking
  // interface is the use of a semaphore to guarantee exclusive access.
  // Curiously, these interface methods look a lot like TLM interface
  // methods.  Hmmm.....
  //--------------------------------------------------------------------

  // task: get
  //
  // Locking version of read().  Like read(), this returns the contents
  // of the resource container.  In addtion it obeys the lock.

  task get (output T t, input uvm_object accessor = null);
    lock();
    t = read(accessor);
    unlock();
  endtask

  // function: try_get
  //
  // Nonblocking form of get().  If the lock is availble it grabs the
  // lock and returns one.  If the lock is not available then it returns
  // a 0.  In either case the return is immediate with no blocking.

  function bit try_get(output T t, input uvm_object accessor = null);
    if(!try_lock())
      return 0;
    t = read(accessor);
    unlock();
    return 1;
  endfunction

  // task: put
  //
  // Locking form of write().  Like write(), put() sets the contents of
  // the resource container.  In addition it locks the resource before
  // doing the write and unlocks it when the write is complete.  If the
  // lock is currently not available put() will block until it is.

  task put (input T t, uvm_object accessor = null);
    lock();
    write(t, accessor);
    unlock();
  endtask

  // function: try_put
  //
  // Nonblocking form of put(). If the lock is available then the
  // write() occurs immediately and a one is returned.  If the lock is
  // not available then the write does not occur and a zero is returned.
  // IN either case try_put() returns immediately with no blocking.

  function bit try_put(input T t, uvm_object accessor = null);
    if(!try_lock())
      return 0;
    write(t, accessor);
    unlock();
    return 1;
  endfunction

endclass


//----------------------------------------------------------------------
// static global resource pool handle
//----------------------------------------------------------------------
const uvm_resource_pool uvm_resources = uvm_resource_pool::get();
