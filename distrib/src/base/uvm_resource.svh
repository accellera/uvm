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

// access record for resources.  A set of these is stored for each
// resource by accessing object.  It's updated for each read/write.
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

  pure virtual function uvm_resource_base get_type_handle();

  task lock();
    sm.get();
  endtask

  function bit try_lock();
    return sm.try_get();
  endfunction

  function void unlock();
    sm.put();
  endfunction

  function void set_read_only();
    read_only = 1;
  endfunction

  // Note: Not sure if this function is necessary.  Once a resource is
  // set to read_only no one should be able to change that.  If anyone
  // can flip the read_only bit then the resource is not truly
  // read_only.
  function void set_read_write();
    read_only = 0;
  endfunction

  function bit is_read_only();
    return read_only;
  endfunction

  task wait_modified();
    wait (modified == 1);
    modified = 0;
  endtask

  function void set_scope(string s);
    scope = uvm_glob_to_re(s);
  endfunction

  function string get_scope();
    return scope;
  endfunction

  // Using the regular expression facility, determine if this resource
  // is visible in a scope
  function bit match_scope(string s);
    int err = uvm_re_match(scope, s);
    return (err == 0);
  endfunction

  // create a string representation of the resource value.  By default
  // we don't know how to do this so we just return a "?".  Resource
  // specializations are expected to override this function to produce a
  // proper string representation of the resource value.
  function string convert2string();
    return "?";
  endfunction

  function void do_print (uvm_printer printer=null);
    $display("  %s = %s [%s]", get_name(), convert2string(), get_scope());
  endfunction

  virtual function void print_accessors();

    uvm_object obj;
    uvm_component comp;
    access_t access_record;

    if(access.size() == 0)
      return;

    $display("  --------");

    foreach (access[obj]) begin

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

  function void init_access_record (inout access_t access_record);
    access_record.read_time = 0;
    access_record.write_time = 0;
    access_record.read_count = 0;
    access_record.write_count = 0;
  endfunction


endclass

//----------------------------------------------------------------------
// uvm_resource_pool
//
// global (singleton) resource pool
//
// Each resource is stored both by primary name and by type handle.  The
// resource pool contains two associative arrays, one with name as the
// key and one with the type handle as the key.  Each associative array
// contains a queue of resources.  Each resource has a regular
// expression that represents the set of scopes over with it is visible.
//
// +------+------------+                          +------------+------+
// | name | rsrc queue |                          | rsrc queue | type |
// +------+------------+                          +------------+------+
// |      |            |                          |            |      |
// +------+------------+                  +-+-+   +------------+------+
// |      |            |                  | | |<--+---*        |  T   |
// +------+------------+   +-+-+          +-+-+   +------------+------+
// |  A   |        *---+-->| | |           |      |            |      |
// +------+------------+   +-+-+           |      +------------+------+
// |      |            |      |            |      |            |      |
// +------+------------+      +-------+  +-+      +------------+------+
// |      |            |              |  |        |            |      |
// +------+------------+              |  |        +------------+------+
// |      |            |              V  V        |            |      |
// +------+------------+            +------+      +------------+------+
// |      |            |            | rsrc |      |            |      |
// +------+------------+            +------+      +------------+------+
//
// The above diagrams illustrates how a resource whose name is A and
// type is T is stored in the pool.  The pool contains an entry in the
// type list for type T and an entry in the name list for name A.  The
// queues in each of the list each contain an entry for the resource A
// whose type is T.  The name list can contain in its queue other
// resources whose name is A which may or may not have the same type as
// our resource A.  Similarly, the type list can contain in its queue
// other resources whose type is T and whose name may or may not be A.
//
// Resources are added to the pool by exporting them; they are retrieved
// from the pool by importing them.  The terms import and export are
// relative to the object performing the operation.  An object creates a
// new resource and exports it to the pool, making it available for
// other objects outside of itsef; an object imports a resource when it
// wants to access a resource not currently available in its scope.
//
// The scope is stored in the resource itself (not in the pool) so
// whether you import by name or by type the resource's visibility is
// the same.
//
// As an auditting capability, the pool contains an import history.  A
// record of each import, whether by type or by name, is stored in the
// queue import_record.  Both successful and failed imports are
// recorded. At the end of simulator, or any time for that matter, you
// can dump history list.  This will tell users which resources were
// successfully located and which were not.  Users can then tell if
// their expectations are met or if there is some error in name, type,
// or scope that caused a resource to not be located or incorrrectly
// located (i.e. the wrong one is located).
//
//----------------------------------------------------------------------

//
// Instances of import_t are stored in the history list as a record of
// each import.  Failed imports are indicated with rsrc set to null.
//
typedef struct
{
  string name;
  string scope;
  uvm_resource_base rsrc;
  time t;
} import_t;

//----------------------------------------------------------------------
// uvm_resource_pool
//----------------------------------------------------------------------
class uvm_resource_pool;

  static local uvm_resource_pool rp = get();

  typedef uvm_resource_base rsrc_q_t [$];

  rsrc_q_t rtab [string];
  rsrc_q_t ttab [uvm_resource_base];

  import_t import_record [$];  // history of imports

  protected function new();
  endfunction

  static function uvm_resource_pool get();
    if(rp == null)
      rp = new();
    return rp;
  endfunction


  //--------------------------------------------------------------------
  // spell_check
  //--------------------------------------------------------------------
  function bit spell_check(string s);
    return uvm_spell_chkr#(rsrc_q_t)::check(rtab, s);
  endfunction

  //--------------------------------------------------------------------
  // export_resource
  //
  // Add a new resource to the resource pool.  The resource is inserted
  // into both the name list and type list so it can be located by
  // either.
  //
  // The notion of exporting a resource is relative to the object doing
  // the exporting.  That is, an object creates a resources and exports
  // it into the resource pool.  Later, other objects that want to
  // access the resource must import it from the pool
  //--------------------------------------------------------------------
  function void export_resource (uvm_resource_base rsrc, bit override = 0);

    rsrc_q_t rq;
    string name;
    uvm_resource_base type_handle;

    // If resource handle is null then there is nothing to do.
    if(rsrc == null)
      return;

    // insert into the name list.  Resources with empty names are
    // anonymous resources and are not entered into the name map
    name = rsrc.get_name();
    if(name != "") begin
      rq = (rtab.exists(name)) ? rtab[name] : {};
      if(override)
        rq.push_front(rsrc);
      else
        rq.push_back(rsrc);
      rtab[name] = rq;
    end

    // insert into the type list
    type_handle = rsrc.get_type_handle();
    rq = (ttab.exists(type_handle)) ? ttab[type_handle] : {};
      if(override)
        rq.push_front(rsrc);
      else
        rq.push_back(rsrc);
    ttab[type_handle] = rq;

  endfunction

  function void export_resource_override(uvm_resource_base rsrc);
    export_resource(rsrc, 1);
  endfunction

  //--------------------------------------------------------------------
  // push_import_record
  //
  // Insert a new record into the import history list.
  //--------------------------------------------------------------------
  function void push_import_record(string name, string scope,
                                  uvm_resource_base rsrc);
    import_t impt;

    impt.name  = name;
    impt.scope = scope;
    impt.rsrc  = rsrc;
    impt.t     = $time;

    import_record.push_back(impt);
  endfunction

  //--------------------------------------------------------------------
  // dump_import_records
  //
  // Format and print the import history list.
  //--------------------------------------------------------------------
  function void dump_import_records();

    import_t record;
    bit success;

    $display("--- resource import records ---");
    foreach (import_record[i]) begin
      record = import_record[i];
      success = (record.rsrc != null);
      $display("import: name=%s  scope=%s  %s @ %0t",
               record.name, record.scope,
               ((success)?"success":"fail"),
               record.t);
    end
  endfunction

  //--------------------------------------------------------------------
  // import_by_name
  //
  // Lookup a resource by name and scope.  Whether the import succeeds
  // or fails, save a record of the import attempt.  The rpterr flag
  // indicates whether we should report errors or not.  Essentially, it
  // severes as a verbose flag.  If set then the spell checker will be
  // invoked and warnings about multiple resources will be produced.
  //--------------------------------------------------------------------
  function uvm_resource_base import_by_name(string name, string scope = "", bit rpterr = 1);

    rsrc_q_t rq;
    rsrc_q_t matchq;
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
      push_import_record(name, scope, null);
      return null;
    end

    // we search through the queue for the first resource that matches the scope
    rsrc = null;
    matchq = {};
    rq = rtab[name];
    foreach (rq [i]) begin
      r = rq[i];
      if(r.match_scope(scope)) begin
        matchq.push_back(r);
      end
    end

    if(matchq.size() == 0) begin
      push_import_record(name, scope, null);
      return null;
    end

    if(rpterr && matchq.size() > 1) begin
      $sformat(msg, "There are multiple resources with name %s that are visible in scope %s.  The first one is the one that was used. The matching resources are:",
               name, scope);
      `uvm_warning("DUPRSRC", msg);
      foreach(matchq[i]) begin
        r = matchq[i];
        $display("    %s in scope %s", r.get_name(), r.get_scope());
      end
    end

    rsrc = matchq[0];
    push_import_record(name, scope, rsrc);
    return rsrc;
    
  endfunction

  //--------------------------------------------------------------------
  // import_by_type
  //
  // Lookup a resource by type handle and scope.  Insert a record into
  // the import history list whether or not the import succeeded or
  // failed.
  //--------------------------------------------------------------------
  function uvm_resource_base import_by_type(uvm_resource_base type_handle,
                                         string scope = "");

    rsrc_q_t rq;
    uvm_resource_base rsrc;
    uvm_resource_base r;
    int unsigned i;

    if(type_handle == null || !ttab.exists(type_handle)) begin
      push_import_record("<type>", scope, null);
      return null;
    end

    rsrc = null;
    rq = ttab[type_handle];
    foreach (rq [i]) begin
      r = rq[i];
      if(r.match_scope(scope)) begin
        rsrc = r;
        break;
      end
    end

    push_import_record("<type>", scope, rsrc);
    return rsrc;
    
  endfunction

  //--------------------------------------------------------------------
  // retrieve_resources
  //
  // This is a utility function that answers the question: For a given
  // scope, what resources are visible to it?  Locate all the resources
  // that are visible to a particular scope.  This operation could be
  // quite expensive, as it has to traverse all of the resources in the
  // database.
  //--------------------------------------------------------------------
  function rsrc_q_t retrieve_resources(string scope);

    rsrc_q_t rq;
    uvm_resource_base r;
    int unsigned i;
    int unsigned err;
    rsrc_q_t result_q;

    foreach (rtab[name]) begin
      rq = rtab[name];
      foreach (rq [i]) begin
        r = rq[i];
        if(r.match_scope(scope)) begin
          result_q.push_back(r);
        end
      end
    end

    return result_q;
    
  endfunction

  //--------------------------------------------------------------------
  // find_zeros
  //
  // Locate all the resources that have at least one write and no reads
  //--------------------------------------------------------------------
  function rsrc_q_t find_zeros();

    rsrc_q_t rq;
    rsrc_q_t q;
    int unsigned i;
    uvm_resource_base r;
    access_t a;
    int reads;
    int writes;

    foreach (rtab[name]) begin
      rq = rtab[name];
      foreach (rq [i]) begin
        r = rq[i];
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

  //--------------------------------------------------------------------
  // print_resources
  //
  // Print the resources that are in a single queue
  //--------------------------------------------------------------------
  function void print_resources(rsrc_q_t rq, bit audit = 0);

    int unsigned i;
    uvm_resource_base r;

    if(rq.size() == 0) begin
      $display("<none>");
      return;
    end

    foreach (rq[i]) begin
      r = rq[i];
      r.print();
      if(audit == 1)
        r.print_accessors();
    end

  endfunction

  //--------------------------------------------------------------------
  // dump
  //
  // dump the entire resource pool
  //--------------------------------------------------------------------
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
// uvm_resource
//
// Parameterized resource.  Provides essential access methods read and
// write.  Also provides locking access methods including put, try_put,
// get, and try_get.
//
// Read and write tracks resource access by updating access records.
//----------------------------------------------------------------------
class uvm_resource #(type T=int) extends uvm_resource_base;

  typedef uvm_resource#(T) this_type;
  static this_type my_type = get_type();

  // database that contains all the resources
  static uvm_resource_pool rp = uvm_resource_pool::get();

  rand protected T val;

  function new(string name="", scope="");
    super.new(name, scope);
  endfunction

  static function this_type get_type();
    if(my_type == null)
      my_type = new();
    return my_type;
  endfunction

  function uvm_resource_base get_type_handle();
    return get_type();
  endfunction

  //--------------------------------------------------------------------
  // export_resource
  //--------------------------------------------------------------------
  function void export_resource ();
    rp.export_resource(this);
  endfunction
  
  //--------------------------------------------------------------------
  // export_resource
  //--------------------------------------------------------------------
  function void export_resource_override();
    rp.export_resource(this, 1);
  endfunction

  //--------------------------------------------------------------------
  // import_by_name
  //--------------------------------------------------------------------
  static function this_type import_by_name(string name, string scope, bit rpterr = 1);

    uvm_resource_base rsrc_base;
    this_type rsrc;
    string msg;

    rsrc_base = rp.import_by_name(name, scope, rpterr);
    if(rsrc_base == null)
      return null;

    if(!$cast(rsrc, rsrc_base)) begin
      $sformat(msg, "Resource with name %s in scope %s has incorrect type", name, scope);
      `uvm_warning("RSRCTYPE", msg);
      return null;
    end

    return rsrc;
    
  endfunction

  //--------------------------------------------------------------------
  // import_by_type
  //--------------------------------------------------------------------
  static function this_type import_by_type(uvm_resource_base type_handle,
                                    string scope = "");

    uvm_resource_base rsrc_base;
    this_type rsrc;
    string msg;

    if(type_handle == null)
      return null;

    rsrc_base = rp.import_by_type(type_handle, scope);
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
  // read
  //--------------------------------------------------------------------
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

  //--------------------------------------------------------------------
  // write
  //--------------------------------------------------------------------
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
  // locking interface
  //
  // This interface is optional, you can choose to lock a resource or
  // not. These methods are wrappers around the read/write interface.
  // The difference between the read/write interface and the locking
  // interface is the use of a semaphore to guarantee exclusive access.
  // Curiously, these interface methods look a lot like TLM interface
  // methods.  Hmmm.....
  //--------------------------------------------------------------------

  task get (output T t, input uvm_object accessor = null);
    lock();
    t = read(accessor);
    unlock();
  endtask

  function bit try_get(output T t, input uvm_object accessor = null);
    if(!try_lock())
      return 0;
    t = read(accessor);
    unlock();
    return 1;
  endfunction

  task put (input T t, uvm_object accessor = null);
    lock();
    write(t, accessor);
    unlock();
  endtask

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
