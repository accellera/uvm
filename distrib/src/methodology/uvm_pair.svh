//
//-----------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------

`ifndef UVM_PAIR_SVH
`define UVM_PAIR_SVH

//-----------------------------------------------------------------------------
// CLASS: uvm_pair #(T1,T2)
//
// Container holding handles to two objects whose types are specified by the
// type parameters, T1 and T2.
//-----------------------------------------------------------------------------

class uvm_class_pair #(type T1=int, T2=T1) extends uvm_transaction;

  typedef uvm_class_pair #(T1, T2 ) this_type;
  
  const static string type_name = "uvm_class_pair #(T1,T2)";

  T1 first;
  T2 second;

  // Function: new
  //
  // Creates an instance of uvm_pair that holds a handle to two objects,
  // as provided by the first two arguments. The optional ~name~ argument
  // gives a name to the new pair object.

  function new (T1 f=null, T2 s=null, string name="");

    super.new(name);

    if (f == null)
      first = new;
    else
      first = f;

    if (s == null)
      second = new;
    else
      second = s;

  endfunction  
  
  virtual function uvm_object create (string name=""); 
    this_type v;
    v = new(.name(name));
    return v;
  endfunction

  virtual function string get_type_name ();
    return type_name;
  endfunction

  virtual function string convert2string;
    string s;
    $sformat(s, "pair : %s, %s",
             first.convert2string(), second.convert2string());
    return s;    
  endfunction

  function bit comp(this_type t);
    return t.first.comp(first) && t.second.comp(second);
  endfunction

  function void copy (this_type t);
    first.copy(t.first);
    second.copy(t.second);
  endfunction

  virtual function uvm_object clone();
    this_type t;
    t = new;
    t.copy(this);
    return t;
  endfunction
  
endclass

//-----------------------------------------------------------------------------
// CLASS: uvm_built_in_pair #(T1,T2)
//
// Container holding two variables of built-in types (int, string, etc.). The
// types are specified by the type parameters, T1 and T2.
//-----------------------------------------------------------------------------

class uvm_built_in_pair #(type T1=int, T2=T1) extends uvm_transaction;

  typedef uvm_built_in_pair #(T1,T2) this_type;
  
  const static string type_name = "uvm_built_in_pair #(T1,T2)";

  T1 first;
  T2 second;
  
  // Function: new
  //
  // Creates an instance of uvm_pair that holds a handle to two elements,
  // as provided by the first two arguments. The optional name argument
  // gives a name to the new pair object.

  function new (T1 f, T2 s, string name="");
    super.new(name);
    first = f;
    second = s;
  endfunction  
  
  virtual function uvm_object create (string name=""); 
    this_type v;
    v = new(first,second,name);
    return v;
  endfunction

  virtual function string get_type_name ();
    return type_name;
  endfunction

  virtual function string convert2string;
    string s;
    `ifdef UVM_USE_P_FORMAT
      $sformat(s, "built-in pair : %p, %p", first, second);
    `else
      $swrite( s, "built-in pair : ", first, ", ", second);
    `endif
    return s;
  endfunction

  function bit comp (this_type t);
    return t.first == first && t.second == second;
  endfunction

  function void copy (this_type t);
    first = t.first;
    second = t.second;
  endfunction
  
  virtual function uvm_object clone();
    this_type t;
    t = new(first,second);
    return t;
  endfunction

endclass

`endif // UVM_PAIR_SVH

