//
//------------------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   Copyright 2007-2009 Cadence Design Systems, Inc. 
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
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// CLASS: uvm_event_pool
//
// The uvm_event_pool is essentially an associative array of <uvm_event> objects
// indexed by the string name of the event.
//
//------------------------------------------------------------------------------

class uvm_event_pool extends uvm_object;

  static local uvm_event_pool  m_global_pool;
  local  uvm_event              pool[string];


  // Function: new
  //
  // Creates a new event pool with the given ~name~.

  function new (string name="");
    super.new(name);
  endfunction


  // Function: get_global_pool
  //
  // Returns the singleton global event pool. 
  //
  // This allows events to be shared between components throughout the
  // verification environment.

  static function uvm_event_pool get_global_pool ();
    if (m_global_pool==null) begin
      uvm_event_pool pool;
      pool = new("pool");
      m_global_pool = pool;
    end
    return m_global_pool;
  endfunction


  // Function: get
  //
  // Returns the event with the given ~name~.
  //
  // If no event exists by that name, a new event is created with that name
  // and returned.

  virtual function uvm_event get (string name);
    uvm_event e;
    if(this.pool.exists(name)) e = this.pool[name];

    if (e==null) begin
       e = new (name);
       this.pool[name] = e;
    end
    return e;
  endfunction


  // Function: num
  //
  // Returns the number of uniquely named events stored in the pool.

  virtual function int num ();
    return this.pool.num();
  endfunction


  // Function: delete
  //
  // Removes the event with the given ~name~ from the pool.

  virtual function void delete (string name);
    if (!this.exists(name)) begin
      uvm_report_warning("EVNTX", $psprintf("delete: %0s doesn't exist. Ignoring delete request",name));
      return;
    end
    this.pool.delete(name);
  endfunction


  // Function: exists
  //
  // Returns 1 if an event with the given ~name~ exists in the pool,
  // 0 otherwise.

  virtual function int exists (string name);
    return this.pool.exists(name);
  endfunction


  // Function: first
  //
  // Returns the name of the first event stored in the pool.
  //
  // If the pool is empty, then ~name~ is unchanged and 0 is returned.
  //
  // If the pool is not empty, then ~name~ is name of the first event
  // and 1 is returned.

  virtual function int first (ref string name);
    return this.pool.first(name);
  endfunction


  // Function: last
  //
  // Returns the name of the last event stored in the pool.
  //
  // If the pool is empty, then 0 is returned and ~name~ is unchanged. 
  //
  // If the pool is not empty, then ~name~ is set to the last name in
  // the pool and 1 is returned.

  virtual function int last (ref string name);
    return this.pool.last(name);
  endfunction


  // Function: next
  //
  // Returns the name of the next event in the pool.
  //
  // If the input ~name~ is the last name in the pool, then name is unchanged
  // and 0 is returned. 
  //
  // If a next name is found, then ~name~ is updated with that name and
  // 1 is returned.

  virtual function int next (ref string name);
    return this.pool.next(name);
  endfunction


  // Function: prev
  //
  // Returns the name of the previous event in the pool.
  //
  // If the input ~name~ is the first name in the pool, then ~name~ is left
  // unchanged and 0 is returned. 
  //
  // If a previous name is found, then ~name~ is updated with that name
  // and 1 is returned.

  virtual function int prev (ref string name);
    return this.pool.prev(name);
  endfunction


  const static string type_name = "uvm_event_pool";

  virtual function string get_type_name ();
    return type_name;
  endfunction

  virtual function uvm_object create (string name=""); 
    uvm_event_pool v;
    v=new(name);
    return v;
  endfunction

  virtual function void do_print (uvm_printer printer);
    printer.print_generic("pool", "aa_object_string", pool.num(), "-");
    printer.m_scope.down("pool", null);
    foreach(pool[e]) begin
      printer.print_object(e, pool[e], "[");
    end
    printer.m_scope.up(null);
  endfunction

  virtual function void do_copy (uvm_object rhs);
    uvm_event_pool ep;
    string key;
    super.do_copy(rhs);

    if (rhs == null) return;
    if (!$cast(ep, rhs))
      uvm_report_fatal ("CASTFL", "Failed to cast rhs to type uvm_event_pool in copy", UVM_NONE);

    pool.delete();
    if(ep.pool.first(key))
      do pool[key] = ep.pool[key];
      while(ep.pool.next(key));
  endfunction

endclass


