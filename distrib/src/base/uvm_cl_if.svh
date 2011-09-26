//----------------------------------------------------------------------
//   Copyright 2011 Cypress Semiconductor Corporation
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
//
// Intermediate Form for command line parser
//
//----------------------------------------------------------------------

`define UVM_DEFAULT_SCOPE "CL::*"

  typedef enum {
                UVM_TOKEN_KIND_INT,
                UVM_TOKEN_KIND_HEX,
                UVM_TOKEN_KIND_OCT,
                UVM_TOKEN_KIND_BIN,
                UVM_TOKEN_KIND_FLOAT,
                UVM_TOKEN_KIND_RAND_INT
               } uvm_token_kind_e;

//----------------------------------------------------------------------
// class token_info
//----------------------------------------------------------------------
class uvm_token_info;
  int unsigned size;
  bit is_rand;
  bit is_signed;
  bit is_logic;
  uvm_token_kind_e kind;
  real multiplier;

  function new();
    size = 32;
    is_signed = 0;
    is_rand = 0;
    is_logic = 0;
    multiplier = 1.0;
  endfunction

endclass

uvm_token_info token_info;

//----------------------------------------------------------------------
// class: uvm_cl_resources
// 
// A list of resources that were set from the command line
//----------------------------------------------------------------------
class uvm_cl_resources;

  local uvm_cl_resources cl_rsrc;
  uvm_resource_base cl_list [$];

  // protected new();

  static uvm_cl_resources function get();
    if(cl_rsrc == null)
      cl_rsrc = new();
    return cl_rsrc;
  endfunction

  function void push(uvm_resource_base r);
    cl_list.push_back(r);
  endfunction

endclass

//----------------------------------------------------------------------
// class: name_value_pair
//----------------------------------------------------------------------
class name_value_pair;
  string name;
  string value;
  string scope;

  function new(string n, string v);
    name = n;
    value = v;
    scope = `UVM_DEFAULT_SCOPE;
  endfunction

  virtual function void print();
    $display("name = %20s value = %s @ %s", name, value, scope);
  endfunction

  virtual function void gen_resource();
  endfunction
  
endclass

//----------------------------------------------------------------------
// class: nvp#(T)
//
// Parameterized name/value pair.  Contains a typed value, as opposed to
// just the string value contained in the parent class.  Contains a
// method for generating an entry in the resources database for the
// name/value pair.
//----------------------------------------------------------------------
class nvp #(type T=int) extends name_value_pair;
  
  local T t;

  function new(string n, string v);
    super.new(n, v);
  endfunction

  function void set(T _t);
    t = _t;
  endfunction

  function T get();
    return t;
  endfunction

  function void gen_resource();
    uvm_resource#(T) rsrc = new(name, scope);
    rsrc.write(t, null);
    rsrc.set();
  endfunction

endclass

//----------------------------------------------------------------------
// class: uvm_parsed_options
//
// List of UVM command line options.  This class has a method,
// gen_resources, for generating entries in the resources database for
// each entry in the list.
//----------------------------------------------------------------------
class uvm_parsed_options;

  local name_value_pair nvpq[$];

  function void push(name_value_pair nvp);
    nvpq.push_back(nvp);
  endfunction

  function void print();

    name_value_pair nvp;

    $display("\nname-value-pair queue");

    foreach (nvpq[i]) begin
      nvp = nvpq[i];
      nvp.print();
    end
  endfunction

  function void gen_resources();
    name_value_pair nv;

    foreach (nvpq[i]) begin
      nv = nvpq[i];
      nv.gen_resource();
    end
  endfunction

endclass
