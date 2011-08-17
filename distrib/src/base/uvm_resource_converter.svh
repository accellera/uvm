//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc. 
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

class m_uvm_typename_wrapper #(type T=int);
    static function string typename(T val);
`ifdef UVM_USE_TYPENAME     
    return $typename(T);
`else
    string r;
    $uvm_type_name(r,val);
    return r;
`endif    
    endfunction
endclass

//------------------------------------------------------------------------------
//
// CLASS: uvm_resource_converter
//
// The uvm_resource_converter class provides a policy object for doing
// convertion from resource value to string.
//
//------------------------------------------------------------------------------
class uvm_resource_converter #(type T=int);
   local static uvm_resource_converter #(T) singleton;
   static function uvm_resource_converter #(T) get();
      if (singleton==null) 
         singleton = new();

      return singleton;
   endfunction
    
   // Function: convert2string
   // Convert a value of type ~T~ to a string that can be displayed.
   //
   // By default, returns the name of the type
   //
   virtual function string convert2string(T val);
        return {"(", m_uvm_typename_wrapper#(T)::typename(val), ") ?"};
   endfunction
endclass

//----------------------------------------------------------------------
//
// CLASS: uvm_resource_default_converter
// Define a default resource value converter using '%p'.
//
// May be used for almost all types, except virtual interfaces.
// Default resource converters are already defined for the
// built-in singular types using the <uvm_resource_default_converters>
// class.
//
//----------------------------------------------------------------------

class uvm_resource_default_converter#(type T=int) extends uvm_resource_converter#(T);
   local static uvm_resource_default_converter #(T) singleton;
   static function uvm_resource_default_converter #(T) get();
      if (singleton==null) 
         singleton = new();

      return singleton;
   endfunction
   
   local string name;
   
   virtual function string convert2string(T val);
      return $sformatf("(%s) %0p", name, val);
   endfunction
   
   `_local function new();
   endfunction

   // Function: register
   // Register the default resource value conversion function
   // for this resource type.
   //
   //| void'(uvm_resource_default_converter#(bit[7:0])::register());
   //
   static function void register(string name=
`ifdef UVM_USE_TYPENAME
   $typename(T)
`else
    "<unknown-r>"
`endif   
   );
         void'(uvm_resource_default_converter#(T)::get());
         singleton.m_set_name(name);
         uvm_resource#(T)::set_converter(singleton);
   endfunction
   
   virtual function void m_set_name(string name);
    this.name=name;
   endfunction
endclass


//----------------------------------------------------------------------
//
// CLASS: uvm_resource_convert2string_converter
// Define a default resource value converter using convert2string() method
//
// May be used for all class types that contain a ~convert2string()~ method,
// such as <uvm_object>.
//
//----------------------------------------------------------------------

class uvm_resource_convert2string_converter#(type T=int) extends uvm_resource_converter#(T);
   local static uvm_resource_convert2string_converter #(T) singleton;
   static function uvm_resource_convert2string_converter #(T) get();
      if (singleton==null) 
         singleton = new();

      return singleton;
   endfunction
   
   local string name;
 
   virtual function string convert2string(T val);   
      return $sformatf("(%s) %0s", m_uvm_typename_wrapper#(T)::typename(val),
                       (val == null) ? "(null)" : val.convert2string());
   endfunction

   `_local function new();
   endfunction

   // Function: register
   // Register the default resource value conversion function
   // for this resource type.
   //
   //| void'(uvm_resource_class_converter#(my_obj)::register());
   //
   static function void register();
        void'(uvm_resource_convert2string_converter#(T)::get());
        uvm_resource#(T)::set_converter(singleton);
   endfunction
endclass
    
//----------------------------------------------------------------------
//
// CLASS: uvm_resource_sprint_converter
// Define a default resource value converter using sprint() method
//
// May be used for all class types that contain a ~sprint()~ method,
// such as <uvm_object>.
//
//----------------------------------------------------------------------

class uvm_resource_sprint_converter#(type T=int) extends uvm_resource_converter#(T);
   local static uvm_resource_sprint_converter #(T) singleton;
   static function uvm_resource_sprint_converter #(T) get();
      if (singleton==null) 
         singleton = new();

      return singleton;
   endfunction

   virtual function string convert2string(T val);
      return $sformatf("(%s) %0s", m_uvm_typename_wrapper#(T)::typename(val),
                       (val == null) ? "(null)" : {"\n",val.sprint()});
   endfunction
   
   `_local function new();
   endfunction

   // Function: register
   // Register the default resource value conversion function
   // for this resource type.
   //
   //| void'(uvm_resource_sprint_converter#(my_obj)::register());
   //
   static function void register();
         void'(uvm_resource_sprint_converter#(T)::get());
         uvm_resource#(T)::set_converter(singleton);
   endfunction
endclass


//
// CLASS: m_uvm_resource_default_converters
// Singleton used to register default resource value converters
// for the built-in singular types.
//
class m_uvm_resource_default_converters;
   
   local static bit m_singleton = register();
   `_local function new();
   endfunction

   // Function: register
   // Explicitly initialize the singleton to eliminate race conditions
   //
   static function bit register();
      if (!m_singleton) begin

         `define __built_in(T) void'(uvm_resource_default_converter#(T)::register(`"T`"))
            
         `__built_in(shortint);
         `__built_in(int);
         `__built_in(longint);
         `__built_in(byte);
         `__built_in(bit);
         `__built_in(logic);
         `__built_in(reg);
         `__built_in(integer);
         `__built_in(time);
         `__built_in(real);
//         `__built_in(shortreal);
         `__built_in(realtime);
         `__built_in(string);
         `__built_in(uvm_bitstream_t);

         `undef __built_in

         m_singleton = 1;
      end
      return 1;
   endfunction
endclass

