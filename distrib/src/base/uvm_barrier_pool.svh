//
//------------------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
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
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// CLASS: uvm_barrier_pool
//
//------------------------------------------------------------------------------

class uvm_barrier_pool extends uvm_object; 

  const static string type_name = "uvm_barrier_pool";

  static local uvm_barrier_pool  m_global_pool;
  local uvm_barrier pool[string];

  // Function: new
  //
  // Creates a new barrier pool with the given ~name~.

  function new (string name="");
    super.new(name);
  endfunction


  // Function: get_global_pool
  //
  // Returns the singleton global barrier pool. 
  //
  // This allows barriers to be shared amongst components throughout the
  // verification environment.

  static function uvm_barrier_pool  get_global_pool ();
    if (m_global_pool==null) begin
      uvm_barrier_pool pool;
      pool = new("pool");
      m_global_pool = pool;
    end
    return m_global_pool;
  endfunction


  // Function: get
  //
  // Returns the barrier with the given ~name~.
  //
  // If no barrier exists by that name, a new barrier is created with that name
  // and returned.

  virtual function uvm_barrier get (string name);
    uvm_barrier b;
    if(pool.exists(name)) b = pool[name];
    if (b==null) begin
       b = new (name);
       pool[name] = b;
    end
    return b;
  endfunction
  

  // Function: num
  //
  // Returns the number of uniquely named barriers stored in the pool.

  virtual function int num ();
    return pool.num();
  endfunction


  // Function: delete
  //
  // Removes the barrier with the given ~name~ from the pool.

  virtual function void delete (string name);
    if (!exists(name)) begin
      uvm_report_warning("BRNTEX", $psprintf("delete: %0s doesn't exist. Ignoring delete request",name));
      return;
    end
    pool.delete(name);
  endfunction


  // Function: exists
  //
  // Returns 1 if a barrier with the given ~name~ exists in the pool,
  // 0 otherwise.

  virtual function int exists (string name);
    return pool.exists(name);
  endfunction


  // Function: first
  //
  // Returns the name of the first barrier stored in the pool.
  //
  // If the pool is empty, then ~name~ is unchanged and 0 is returned.
  //
  // If the pool is not empty, then ~name~ is name of the first barrier
  // and 1 is returned.

  virtual function int first (ref string name);
    return pool.first(name);
  endfunction


  // Function: last
  //
  // Returns the name of the last barrier stored in the pool.
  //
  // If the pool is empty, then 0 is returned and ~name~ is unchanged. 
  //
  // If the pool is not empty, then ~name~ is set to the last name in
  // the pool and 1 is returned.

  virtual function int last (ref string name);
    return pool.last(name);
  endfunction


  // Function: next
  //
  // Returns the name of the next barrier in the pool.
  //
  // If the input ~name~ is the last name in the pool, then ~name~ is
  // left unchanged and 0 is returned. 
  //
  // If a next name is found, then ~name~ is updated with that name
  // and 1 is returned.

  virtual function int next (ref string name);
    return pool.next(name);
  endfunction


  // Function: prev
  //
  // Returns the name of the previous barrier in the pool.
  //
  // If the input ~name~ is the first name in the pool, then ~name~ is
  // left unchanged and 0 is returned. 
  //
  // If a previous name is found, then ~name~ is updated with that name
  // and 1 is returned.

  virtual function int prev (ref string name);
    return pool.prev(name);
  endfunction


  virtual function uvm_object create (string name=""); 
    uvm_barrier_pool v;
    v=new(name);
    return v;
  endfunction

  virtual function string get_type_name ();
    return type_name;
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
    uvm_barrier_pool bp;
    string key;
    super.do_copy(rhs);
    if(!$cast(bp, rhs) || (bp==null)) return;
    pool.delete();
    if(bp.pool.first(key))
      do pool[key] = bp.pool[key];
      while(bp.pool.next(key));
  endfunction

endclass
