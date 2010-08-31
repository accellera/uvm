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
// class: uvm_resource_proxy
//----------------------------------------------------------------------
class uvm_resource_proxy #(type T=int);

  typedef uvm_resource #(T) rsrc_t;

  // all the functions are static, no need to instantiate this class
  protected function new();
  endfunction

  static function rsrc_t import_by_type(string scope);
    return rsrc_t::import_by_type(rsrc_t::get_type(), scope);
  endfunction

  static function rsrc_t import_by_name(string name, string scope);
    return rsrc_t::import_by_name(name, scope);
  endfunction

  // function: export_resource 
  //
  // add a new item into the resources database.  The item will not be
  // written to so it will have its default value
  static function rsrc_t export_resource(string name, string scope);

    rsrc_t r;
    
    r = new(name, scope);
    uvm_resources.export_resource(r);
    return r;
  endfunction

  // function: export_and_write
  //
  // Create a new resource, write a value to it, and export it into the
  // database.
  static function void export_and_write(input string name, input string scope,
                                        T val, input uvm_object accessor = null);

    rsrc_t rsrc = new(name, scope);
    rsrc.write(val, accessor);
    rsrc.export_resource();

  endfunction;

  // function: export_and_write_anonymous
  //
  // Create a new resource, write a value to it, and export it into the
  // database.  The resource has no name and therefore will not be
  // entered into the name map
  static function void export_and_write_anonymous(input string scope,
                                                  T val, input uvm_object accessor = null);

    rsrc_t rsrc = new("", scope);
    rsrc.write(val, accessor);
    rsrc.export_resource();

  endfunction;


  // function read_by_name
  //
  // locate a resource by name and read its value. The value is returned
  // through the ref argument.  The return value is a bit that indicates
  // whether or not the read was successful.
  static function bit read_by_name(input string name, input string scope,
                                   ref T val, input uvm_object accessor = null);

    rsrc_t rsrc = import_by_name(name, scope);

    if(rsrc == null)
      return 0;

    val = rsrc.read(accessor);
    return 1;
  
  endfunction

  // function read_by_type
  //
  // Read a value by type.  The value is returned through the ref
  // argument.  The return value is a bit that indicates whether or not
  // the read is successful.
  static function bit read_by_type(input string scope,
                                   ref T val, input uvm_object accessor = null);
    
    rsrc_t rsrc = import_by_type(scope);

    if(rsrc == null)
      return 0;

    val = rsrc.read(accessor);
    return 1;

  endfunction

  // function: write_by_name
  //
  // write a value into the resources database.  First, look up the
  // resource by name.  If it is not located then add a new resource to
  // the database and then write its value.
  static function bit write_by_name(input string name, input string scope,
                                     T val, input uvm_object accessor = null);

    rsrc_t rsrc = import_by_name(name, scope);

    if(rsrc == null)
      return 0;

    rsrc.write(val, accessor);
    return 1;

  endfunction

  // function: write_by_type
  //
  // write a value into the resources database.  First, look up the
  // resource by type.  If it is not located then add a new resource to
  // the database and then write its value.
  static function bit write_by_type(input string scope,
                                    input T val, input uvm_object accessor = null);

    rsrc_t rsrc = import_by_type(scope);

    // resrouce was not found in the database, so let's add one
    if(rsrc == null)
      return 0;

    rsrc.write(val, accessor);
    return 1;
  endfunction

endclass
