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

`ifndef UVM_OBJECT_DEFINES_SVH
`define UVM_OBJECT_DEFINES_SVH

`ifdef UVM_EMPTY_MACROS

`define uvm_field_utils
`define uvm_field_utils_begin(T) 
`define uvm_field_utils_end 
`define uvm_object_utils(T) 
`define uvm_object_param_utils(T) 
`define uvm_object_utils_begin(T) 
`define uvm_object_param_utils_begin(T) 
`define uvm_object_utils_end
`define uvm_component_utils(T)
`define uvm_component_param_utils(T)
`define uvm_component_utils_begin(T)
`define uvm_component_param_utils_begin(T)
`define uvm_component_utils_end
`define uvm_field_int(ARG,FLAG)
`define uvm_field_real(ARG,FLAG)
`define uvm_field_enum(T,ARG,FLAG)
`define uvm_field_object(ARG,FLAG)
`define uvm_field_event(ARG,FLAG)
`define uvm_field_string(ARG,FLAG)
`define uvm_field_array_enum(ARG,FLAG)
`define uvm_field_array_int(ARG,FLAG)
`define uvm_field_sarray_int(ARG,FLAG)
`define uvm_field_sarray_enum(ARG,FLAG)
`define uvm_field_array_object(ARG,FLAG)
`define uvm_field_sarray_object(ARG,FLAG)
`define uvm_field_array_string(ARG,FLAG)
`define uvm_field_sarray_string(ARG,FLAG)
`define uvm_field_queue_enum(ARG,FLAG)
`define uvm_field_queue_int(ARG,FLAG)
`define uvm_field_queue_object(ARG,FLAG)
`define uvm_field_queue_string(ARG,FLAG)
`define uvm_field_aa_int_string(ARG, FLAG)
`define uvm_field_aa_string_string(ARG, FLAG)
`define uvm_field_aa_object_string(ARG, FLAG)
`define uvm_field_aa_int_int(ARG, FLAG)
`define uvm_field_aa_int_int(ARG, FLAG)
`define uvm_field_aa_int_int_unsigned(ARG, FLAG)
`define uvm_field_aa_int_integer(ARG, FLAG)
`define uvm_field_aa_int_integer_unsigned(ARG, FLAG)
`define uvm_field_aa_int_byte(ARG, FLAG)
`define uvm_field_aa_int_byte_unsigned(ARG, FLAG)
`define uvm_field_aa_int_shortint(ARG, FLAG)
`define uvm_field_aa_int_shortint_unsigned(ARG, FLAG)
`define uvm_field_aa_int_longint(ARG, FLAG)
`define uvm_field_aa_int_longint_unsigned(ARG, FLAG)
`define uvm_field_aa_int_key(KEY, ARG, FLAG)
`define uvm_field_aa_string_int(ARG, FLAG)
`define uvm_field_aa_object_int(ARG, FLAG)

`else

//------------------------------------------------------------------------------
//
// Title: Utility and Field Macros for Components and Objects
//
// Group: Utility Macros 
//
// The utility macros provide implementations of the <uvm_object::create> method,
// which is needed for cloning, and the <uvm_object::get_type_name> method, which
// is needed for a number of debugging features. They also register the type with
// the <uvm_factory>, and they implement a ~get_type~ method, which is used when
// configuring the factory. And they implement the virtual 
// <uvm_object::get_object_type> method for accessing the factory proxy of an
// allocated object.
//
// Below is an example usage of the utility and field macros. By using the
// macros, you do not have to implement any of the data methods to get all of
// the capabilities of an <uvm_object>.
//
//|  class mydata extends uvm_object;
//| 
//|    string str;
//|    mydata subdata;
//|    int field;
//|    myenum e1;
//|    int queue[$];
//|
//|    `uvm_object_utils_begin(mydata) //requires ctor with default args
//|      `uvm_field_string(str, UVM_DEFAULT)
//|      `uvm_field_object(subdata, UVM_DEFAULT)
//|      `uvm_field_int(field, UVM_DEC) //use decimal radix
//|      `uvm_field_enum(myenum, e1, UVM_DEFAULT)
//|      `uvm_field_queue_int(queue, UVM_DEFAULT)
//|    `uvm_object_utils_end
//|
//|  endclass
//
//------------------------------------------------------------------------------

// Definitions for the user to use inside their derived data class declarations.

// MACRO: `uvm_field_utils_begin

// MACRO: `uvm_field_utils_end
//
// These macros form a block in which `uvm_field_* macros can be placed. 
// Used as
//
//|  `uvm_field_utils_begin(TYPE)
//|    `uvm_field_* macros here
//|  `uvm_field_utils_end
//
// 
// These macros do NOT perform factory registration, implement get_type_name,
// nor implement the create method. Use this form when you need custom
// implementations of these two methods, or when you are setting up field macros
// for an abstract class (i.e. virtual class).

`define uvm_field_utils_begin(T) \
   static bit m_fields_checked = 0; \
   function void m_field_automation (uvm_object tmp_data__, \
                                     int what__, \
                                     string str__); \
   begin \
     T local_data__; /* Used for copy and compare */ \
     typedef T ___local_type____; \
     string string_aa_key; /* Used for associative array lookups */ \
     /* Check the fields if not already checked */ \
     if(what__ == UVM_CHECK_FIELDS) begin \
       if(m_fields_checked) \
         return; \
       else \
         m_fields_checked = 1; \
     end \
     /* Type is verified by uvm_object::compare() */ \
     super.m_field_automation(tmp_data__, what__, str__); \
     if(tmp_data__ != null) \
       /* Allow objects in same hierarchy to be copied/compared */ \
       if(!$cast(local_data__, tmp_data__)) return;

`define uvm_field_utils_end \
     end \
   endfunction \

`define uvm_field_utils

// MACRO: `uvm_object_utils

// MACRO: `uvm_object_param_utils

// MACRO: `uvm_object_utils_begin

// MACRO: `uvm_object_param_utils_begin

// MACRO: `uvm_object_utils_end
//
// <uvm_object>-based class declarations may contain one of the above forms of
// utility macros.
// 
// For simple objects with no field macros, use
//
//|  `uvm_object_utils(TYPE)
//    
// For simple objects with field macros, use
//
//|  `uvm_object_utils_begin(TYPE)
//|    `uvm_field_* macro invocations here
//|  `uvm_object_utils_end
//    
// For parameterized objects with no field macros, use
//
//|  `uvm_object_param_utils(TYPE)
//    
// For parameterized objects, with field macros, use
//
//|  `uvm_object_param_utils_begin(TYPE)
//|    `uvm_field_* macro invocations here
//|  `uvm_object_utils_end
//
// Simple (non-parameterized) objects use the uvm_object_utils* versions, which
// do the following:
//
// o Implements get_type_name, which returns TYPE as a string
//
// o Implements create, which allocates an object of type TYPE by calling its
//   constructor with no arguments. TYPE's constructor, if defined, must have
//   default values on all it arguments.
//
// o Registers the TYPE with the factory, using the string TYPE as the factory
//   lookup string for the type.
//
// o Implements the static get_type() method which returns a factory
//   proxy object for the type.
//
// o Implements the virtual get_object_type() method which works just like the
//   static get_type() method, but operates on an already allocated object.
//
// Parameterized classes must use the uvm_object_param_utils* versions. They
// differ from <`uvm_object_utils> only in that they do not supply a type name
// when registering the object with the factory. As such, name-based lookup with
// the factory for parameterized classes is not possible.
//
// The macros with _begin suffixes are the same as the non-suffixed versions
// except that they also start a block in which `uvm_field_* macros can be
// placed. The block must be terminated by `uvm_object_utils_end.
//
// Objects deriving from uvm_sequence must use the `uvm_sequence_* macros
// instead of these macros.  See <`uvm_sequence_utils> for details.

`define uvm_object_utils(T) \
  `uvm_object_utils_begin(T) \
  `uvm_object_utils_end

`define uvm_object_param_utils(T) \
  `uvm_object_param_utils_begin(T) \
  `uvm_object_utils_end

`define uvm_object_utils_begin(T) \
   `uvm_object_registry_internal(T,T)  \
   `uvm_object_create_func(T) \
   `uvm_get_type_name_func(T) \
   `uvm_field_utils_begin(T) 

`define uvm_object_param_utils_begin(T) \
   `uvm_object_registry_param(T)  \
   `uvm_object_create_func(T) \
   `uvm_field_utils_begin(T) 

`define uvm_object_utils_end \
     end \
   endfunction \


// MACRO: `uvm_component_utils

// MACRO: `uvm_component_param_utils

// MACRO: `uvm_component_utils_begin

// MACRO: `uvm_component_param_utils_begin

// MACRO: `uvm_component_end
//
// uvm_component-based class declarations may contain one of the above forms of
// utility macros.
//
// For simple components with no field macros, use
//
//|  `uvm_component_utils(TYPE)
//
// For simple components with field macros, use
//
//|  `uvm_component_utils_begin(TYPE)
//|    `uvm_field_* macro invocations here
//|  `uvm_component_utils_end
//
// For parameterized components with no field macros, use
//
//|  `uvm_component_param_utils(TYPE)
//
// For parameterized components with field macros, use
//
//|  `uvm_component_param_utils_begin(TYPE)
//|    `uvm_field_* macro invocations here
//|  `uvm_component_utils_end
//
// Simple (non-parameterized) components must use the uvm_components_utils*
// versions, which do the following:
//
// o Implements get_type_name, which returns TYPE as a string.
//
// o Implements create, which allocates a component of type TYPE using a two
//   argument constructor. TYPE's constructor must have a name and a parent
//   argument.
//
// o Registers the TYPE with the factory, using the string TYPE as the factory
//   lookup string for the type.
//
// o Implements the static get_type() method which returns a factory
//   proxy object for the type.
//
// o Implements the virtual get_object_type() method which works just like the
//   static get_type() method, but operates on an already allocated object.
//
// Parameterized classes must use the uvm_object_param_utils* versions. They
// differ from `uvm_object_utils only in that they do not supply a type name
// when registering the object with the factory. As such, name-based lookup with
// the factory for parameterized classes is not possible.
//
// The macros with _begin suffixes are the same as the non-suffixed versions
// except that they also start a block in which `uvm_field_* macros can be
// placed. The block must be terminated by `uvm_component_utils_end.
//
// Components deriving from uvm_sequencer must use the `uvm_sequencer_* macros
// instead of these macros.  See `uvm_sequencer_utils for details.

`define uvm_component_utils(T) \
   `uvm_component_registry_internal(T,T) \
   `uvm_get_type_name_func(T) \

`define uvm_component_param_utils(T) \
   `uvm_component_registry_param(T) \

`define uvm_component_utils_begin(T) \
   `uvm_component_registry_internal(T,T) \
   `uvm_get_type_name_func(T) \
   `uvm_field_utils_begin(T) 

`define uvm_component_param_utils_begin(T) \
   `uvm_component_registry_param(T) \
   `uvm_field_utils_begin(T) 

`define uvm_component_utils_end \
     end \
   endfunction


//-----------------------------------------------------------------------------
// INTERNAL MACROS - in support of *_utils macros -- do not use directly
//-----------------------------------------------------------------------------

// uvm_new_func
// ------------

`define uvm_new_func \
  function new (string name, uvm_component parent); \
    super.new(name, parent); \
  endfunction

`define uvm_component_new_func \
  `uvm_new_func

`define uvm_new_func_data \
  function new (string name=""); \
    super.new(name); \
  endfunction

`define uvm_object_new_func \
  `uvm_new_func_data

`define uvm_named_object_new_func \
  function new (string name, uvm_component parent); \
    super.new(name, parent); \
  endfunction


// uvm_object_create_func
// ----------------------

// Zero argument create function, requires default constructor
`define uvm_object_create_func(T) \
   function uvm_object create (string name=""); \
     T tmp; \
     tmp = new(); \
     if (name!="") \
       tmp.set_name(name); \
     return tmp; \
   endfunction


// uvm_named_object_create_func
// ----------------------------

`define uvm_named_object_create_func(T) \
   function uvm_named_object create_named_object (string name, uvm_named_object parent); \
     T tmp; \
     tmp = new(.name(name), .parent(parent)); \
     return tmp; \
   endfunction


`define uvm_named_object_factory_create_func(T) \
  `uvm_named_object_create_func(T) \


// uvm_get_type_name_func
// ----------------------

`define uvm_get_type_name_func(T) \
   const static string type_name = `"T`"; \
   virtual function string get_type_name (); \
     return type_name; \
   endfunction 


// uvm_object_derived_wrapper_class
// --------------------------------

//Requires S to be a constant string
`define uvm_object_registry(T,S) \
   typedef uvm_object_registry#(T,S) type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction 
//This is needed due to an issue in of passing down strings
//created by args to lower level macros.
`define uvm_object_registry_internal(T,S) \
   typedef uvm_object_registry#(T,`"S`") type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction 


// versions of the uvm_object_registry macros above which are to be used
// with parameterized classes

`define uvm_object_registry_param(T) \
   typedef uvm_object_registry #(T) type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction 


// uvm_component_derived_wrapper_class
// ---------------------------------

`define uvm_component_registry(T,S) \
   typedef uvm_component_registry #(T,S) type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction 
//This is needed due to an issue in of passing down strings
//created by args to lower level macros.
`define uvm_component_registry_internal(T,S) \
   typedef uvm_component_registry #(T,`"S`") type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction

// versions of the uvm_component_registry macros to be used with
// parameterized classes

`define uvm_component_registry_param(T) \
   typedef uvm_component_registry #(T) type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction

//------------------------------------------------------------------------------
//
// Group: Field Macros
//
// The `uvm_field_*  macros are invoked inside of the `uvm_*_utils_begin and
// `uvm_*_utils_end macro blocks to form "automatic" implementations of the
// core data methods: copy, compare, pack, unpack, record, print, and sprint.
// For example:
//
//|  class my_trans extends uvm_transaction;
//|    string my_string;
//|    `uvm_object_utils_begin(my_trans)
//|      `uvm_field_string(my_string, UVM_ALL_ON)
//|    `uvm_object_utils_end
//|  endclass
//
// Each `uvm_field_* macro is named to correspond to a particular data
// type: integrals, strings, objects, queues, etc., and each has at least two
// arguments: ~ARG~ and ~FLAG~.
//
// ~ARG~ is the instance name of the variable, whose type must be compatible with
// the macro being invoked. In the example, class variable my_string is of type
// string, so we use the `uvm_field_string macro.
//
// If ~FLAG~ is set to ~UVM_ALL_ON~, as in the example, the ARG variable will be
// included in all data methods. The FLAG, if set to something other than
// ~UVM_ALL_ON~ or ~UVM_DEFAULT~, specifies which data method implementations will
// NOT include the given variable. Thus, if ~FLAG~ is specified as ~NO_COMPARE~,
// the ARG variable will not affect comparison operations, but it will be
// included in everything else.
//
// All possible values for ~FLAG~ are listed and described below. Multiple flag
// values can be bitwise ORed together (in most cases they may be added together
// as well, but care must be taken when using the + operator to ensure that the
// same bit is not added more than once).
//
//   UVM_ALL_ON     - Set all operations on (default).
//   UVM_DEFAULT    - Use the default flag settings.
//   UVM_NOCOPY     - Do not copy this field.
//   UVM_NOCOMPARE  - Do not compare this field.
//   UVM_NOPRINT    - Do not print this field.
//   UVM_NODEFPRINT - Do not print the field if it is the same as its
//   UVM_NOPACK     - Do not pack or unpack this field.
//   UVM_PHYSICAL   - Treat as a physical field. Use physical setting in
//                      policy class for this field.
//   UVM_ABSTRACT   - Treat as an abstract field. Use the abstract setting
//                      in the policy class for this field.
//   UVM_READONLY   - Do not allow setting of this field from the set_*_local
//                      methods.
//
// A radix for printing and recording can be specified by OR'ing one of the
// following constants in the ~FLAG~ argument
//
//   UVM_BIN      - Print / record the field in binary (base-2).
//   UVM_DEC      - Print / record the field in decimal (base-10).
//   UVM_UNSIGNED - Print / record the field in unsigned decimal (base-10).
//   UVM_OCT      - Print / record the field in octal (base-8).
//   UVM_HEX      - Print / record the field in hexidecimal (base-16).
//   UVM_STRING   - Print / record the field in string format.
//   UVM_TIME     - Print / record the field in time format.
//
//   Radix settings for integral types. Hex is the default radix if none is
//   specified.
//------------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Group: `uvm_field_* macros
//
// Macros that implement data operations for scalar properties.
//
//-----------------------------------------------------------------------------

// MACRO: `uvm_field_int
//
// Implements the data operations for any packed integral property.
//
//|  `uvm_field_int(ARG,FLAG)
//
// ~ARG~ is an integral property of the class, and ~FLAG~ is a bitwise OR of
// one or more flag settings as described in <Field Macros> above.

`define uvm_field_int(ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_INT_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG !== local_data__.ARG) begin \
               void'(m_sc.comparer.compare_field(`"ARG`", ARG, local_data__.ARG, $bits(ARG))); \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          if($bits(ARG) <= 64) m_sc.packer.pack_field_int(ARG, $bits(ARG)); \
          else m_sc.packer.pack_field(ARG, $bits(ARG)); \
        end \
      UVM_UNPACK: \
        begin \
          if($bits(ARG) <= 64) ARG =  m_sc.packer.unpack_field_int($bits(ARG)); \
          else ARG = m_sc.packer.unpack_field($bits(ARG)); \
        end \
      UVM_RECORD: \
        `m_uvm_record_int(ARG, FLAG) \
      UVM_PRINT: \
        begin \
          m_sc.printer.print_field(`"ARG`", ARG, $bits(ARG), uvm_radix_enum'(FLAG&UVM_RADIX)); \
        end \
      UVM_SETINT: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          void'(uvm_object::m_do_set (str__, `"ARG`", ARG, what__, FLAG)); \
          m_sc.scope.unset_arg(`"ARG`"); \
      end \
    endcase \
  end


// MACRO: `uvm_field_object
//
// Implements the data operations for an <uvm_object>-based property.
//
//|  `uvm_field_object(ARG,FLAG)
//
// ~ARG~ is an object property of the class, and ~FLAG~ is a bitwise OR of
// one or more flag settings as described in <Field Macros> above.

`define uvm_field_object(ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_OBJ_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) begin \
            if(FLAG&UVM_REFERENCE) ARG = local_data__.ARG; \
            else begin \
              if(local_data__.ARG.get_name() == "") local_data__.ARG.set_name(`"ARG`"); \
              $cast(ARG, local_data__.ARG.clone()); \
              ARG.set_name(local_data__.ARG.get_name()); \
            end \
          end \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            void'(m_sc.comparer.compare_object(`"ARG`", ARG, local_data__.ARG)); \
            if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
          end \
        end \
      UVM_PACK: \
        begin \
          if((FLAG&UVM_NOPACK) == 0 && (FLAG&UVM_REFERENCE) == 0) \
            m_sc.packer.pack_object(ARG); \
        end \
      UVM_UNPACK: \
        begin \
          if((FLAG&UVM_NOPACK) == 0 && (FLAG&UVM_REFERENCE) == 0) \
            m_sc.packer.unpack_object(ARG); \
        end \
      UVM_RECORD: \
        `m_uvm_record_object(ARG,FLAG) \
      UVM_PRINT: \
        begin \
          if(!(FLAG&UVM_NOPRINT)) begin \
            if((FLAG&UVM_REFERENCE) != 0) \
              m_sc.printer.print_object_header(`"ARG`", ARG); \
            else \
              m_sc.printer.print_object(`"ARG`", ARG); \
          end \
        end \
      UVM_SETINT: \
        begin \
          if((ARG != null) && ((FLAG&UVM_READONLY)==0) && ((FLAG&UVM_REFERENCE)==0)) begin \
            m_sc.scope.down(`"ARG`"); \
            ARG.m_field_automation(null, UVM_SETINT, str__); \
            m_sc.scope.up(); \
          end \
        end \
      UVM_SETSTR: \
        begin \
          if((ARG != null) && ((FLAG&UVM_READONLY)==0) && ((FLAG&UVM_REFERENCE)==0)) begin \
            m_sc.scope.down(`"ARG`"); \
            ARG.m_field_automation(null, UVM_SETSTR, str__); \
            m_sc.scope.up(); \
          end \
        end \
      UVM_SETOBJ: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG &UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            else begin \
              print_field_match("set_object()", str__); \
              if($cast(ARG,uvm_object::m_sc.object)) \
                uvm_object::m_sc.status = 1; \
            end \
          end \
          else if(ARG!=null && (FLAG &UVM_READONLY) == 0) begin \
            int cnt; \
            //Only traverse if there is a possible match. \
            for(cnt=0; cnt<str__.len(); ++cnt) begin \
              if(str__[cnt] == "." || str__[cnt] == "*") break; \
            end \
            if(cnt!=str__.len()) begin \
              m_sc.scope.down(`"ARG`"); \
              ARG.m_field_automation(null, UVM_SETOBJ, str__); \
              m_sc.scope.up(); \
            end \
          end \
        end \
    endcase \
  end


// MACRO: `uvm_field_string
//
// Implements the data operations for a string property.
//
//|  `uvm_field_string(ARG,FLAG)
//
// ~ARG~ is a string property of the class, and ~FLAG~ is a bitwise OR of
// one or more flag settings as described in <Field Macros> above.

`define uvm_field_string(ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_STR_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG != local_data__.ARG) begin \
               void'(m_sc.comparer.compare_string(`"ARG`", ARG, local_data__.ARG)); \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          m_sc.packer.pack_string(ARG); \
        end \
      UVM_UNPACK: \
        begin \
          ARG = m_sc.packer.unpack_string(); \
        end \
      UVM_RECORD: \
        `m_uvm_record_string(ARG, ARG, FLAG) \
      UVM_PRINT: \
        begin \
          m_sc.printer.print_string(`"ARG`", ARG); \
        end \
      UVM_SETSTR: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            else begin \
              print_field_match("set_str()", str__); \
              ARG = uvm_object::m_sc.stringv; \
              m_sc.status = 1; \
            end \
          end \
      end \
    endcase \
  end



// MACRO: `uvm_field_enum
// 
// Implements the data operations for an enumerated property.
//
//|  `uvm_field_enum(T,ARG,FLAG)
//
// ~T~ is an enumerated _type_, ~ARG~ is an instance of that type, and
// ~FLAG~ is a bitwise OR of one or more flag settings as described in
// <Field Macros> above.

`define uvm_field_enum(T,ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_INT_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG !== local_data__.ARG) begin \
               m_sc.scope.set_arg(`"ARG`"); \
               $swrite(m_sc.stringv, "lhs = %0s : rhs = %0s", \
                 ARG.name(), local_data__.ARG.name()); \
               m_sc.comparer.print_msg(m_sc.stringv); \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          m_sc.packer.pack_field(ARG, $bits(ARG)); \
        end \
      UVM_UNPACK: \
        begin \
          ARG =  T'(m_sc.packer.unpack_field_int($bits(ARG))); \
        end \
      UVM_RECORD: \
        `m_uvm_record_string(ARG, ARG.name(), FLAG) \
      UVM_PRINT: \
        begin \
          m_sc.printer.print_generic(`"ARG`", `"T`", $bits(ARG), ARG.name()); \
        end \
      UVM_SETINT: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            else begin \
              print_field_match("set_int()", str__); \
              ARG = T'(uvm_object::m_sc.bitstream); \
              m_sc.status = 1; \
            end \
          end \
      end \
    endcase \
  end



// MACRO: `uvm_field_real
//
// Implements the data operations for any real property.
//
//|  `uvm_field_real(ARG,FLAG)
//
// ~ARG~ is an real property of the class, and ~FLAG~ is a bitwise OR of
// one or more flag settings as described in <Field Macros> above.

`define uvm_field_real(ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_INT_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG != local_data__.ARG) begin \
               void'(m_sc.comparer.compare_field_real(`"ARG`", ARG, local_data__.ARG)); \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          m_sc.packer.pack_field_int($realtobits(ARG), 64); \
        end \
      UVM_UNPACK: \
        begin \
          ARG = $bitstoreal(m_sc.packer.unpack_field_int(64)); \
        end \
      UVM_RECORD: \
        if(!(FLAG&UVM_NORECORD)) begin \
          m_sc.recorder.record_field_real(`"ARG`", ARG); \
        end \
      UVM_PRINT: \
        begin \
          m_sc.printer.print_field_real(`"ARG`", ARG); \
        end \
      UVM_SETINT: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            else begin \
              print_field_match("set_int()", str__); \
              ARG = $bitstoreal(uvm_object::m_sc.bitstream); \
              m_sc.status = 1; \
            end \
          end \
      end \
    endcase \
  end



// MACRO: `uvm_field_event
//   
// Implements the data operations for an event property.
//
//|  `uvm_field_event(ARG,FLAG)
//
// ~ARG~ is an event property of the class, and ~FLAG~ is a bitwise OR of
// one or more flag settings as described in <Field Macros> above.

`define uvm_field_event(ARG,FLAG) \
  begin \
    case (what__) \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG != local_data__.ARG) begin \
               m_sc.scope.down(`"ARG`"); \
               m_sc.comparer.print_msg(""); \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          // Events aren't packed or unpacked  \
        end \
      UVM_UNPACK: \
        begin \
        end \
      UVM_RECORD: \
        begin \
          // Events are not recorded  \
        end \
      UVM_PRINT: \
        begin \
          m_sc.printer.print_generic(`"ARG`", "event", -1, ""); \
        end \
      UVM_SETINT: \
        begin \
          // Events are not configurable via set_config \
        end \
    endcase \
  end


//-----------------------------------------------------------------------------
// Group: `uvm_field_sarray_* macros
//                            
// Macros that implement data operations for one-dimensional static array
// properties.
//-----------------------------------------------------------------------------

// MACRO: `uvm_field_sarray_int
//
// Implements the data operations for a one-dimensional static array of
// integrals.
//
//|  `uvm_field_sarray_int(ARG,FLAG)
//
// ~ARG~ is a one-dimensional static array of integrals, and ~FLAG~
// is a bitwise OR of one or more flag settings as described in
// <Field Macros> above.

`define uvm_field_sarray_int(ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_INT_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG !== local_data__.ARG) begin \
               if(m_sc.comparer.show_max == 1) begin \
                 m_sc.scope.set_arg(`"ARG`"); \
                 m_sc.comparer.print_msg(""); \
               end \
               else if(m_sc.comparer.show_max) begin \
                 foreach(ARG[i]) begin \
                   if(ARG[i] !== local_data__.ARG[i]) begin \
                     m_sc.scope.set_arg_element(`"ARG`",i); \
                     void'(m_sc.comparer.compare_field("", ARG[i], local_data__.ARG[i], $bits(ARG[i]))); \
                   end \
                 end \
               end \
               else if ((m_sc.comparer.physical&&(FLAG&UVM_PHYSICAL)) || \
                        (m_sc.comparer.abstract&&(FLAG&UVM_ABSTRACT)) || \
                        (!(FLAG&UVM_PHYSICAL) && !(FLAG&UVM_ABSTRACT)) ) \
                 m_sc.comparer.result++; \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          foreach(ARG[i])  \
            if($bits(ARG[i]) <= 64) m_sc.packer.pack_field_int(ARG[i], $bits(ARG[i])); \
            else m_sc.packer.pack_field(ARG[i], $bits(ARG[i])); \
        end \
      UVM_UNPACK: \
        begin \
          foreach(ARG[i]) \
            if($bits(ARG[i]) <= 64) ARG[i] = m_sc.packer.unpack_field_int($bits(ARG[i])); \
            else ARG[i] = m_sc.packer.unpack_field($bits(ARG[i])); \
        end \
      UVM_RECORD: \
        `m_uvm_record_qda_int(ARG, FLAG, $size(ARG))  \
      UVM_PRINT: \
        begin \
          if(((FLAG)&UVM_NOPRINT) == 0 && \
                  m_sc.printer.knobs.print_fields == 1) begin \
             `uvm_print_sarray_int3(ARG, uvm_radix_enum'((FLAG)&(UVM_RADIX)), \
                                   m_sc.printer) \
          end \
        end \
      UVM_SETINT: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            else begin \
              uvm_report_warning("RDONLY", $psprintf("%s: static arrays cannot be resized via configuraton.",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
          end \
          else if(!(FLAG&UVM_READONLY)) begin \
            foreach(ARG[i]) begin \
              m_sc.scope.set_arg_element(`"ARG`",i); \
              if(uvm_is_match(str__, m_sc.scope.get())) begin \
                print_field_match("set_int()", str__); \
                ARG[i] =  uvm_object::m_sc.bitstream; \
                m_sc.status = 1; \
              end \
            end \
          end \
        end \
    endcase \
  end


// MACRO: `uvm_field_sarray_object
//
// Implements the data operations for a one-dimensional static array of
// <uvm_object>-based objects.
//
//|  `uvm_field_sarray_object(ARG,FLAG)
//
// ~ARG~ is a one-dimensional static array of <uvm_object>-based objects,
// and ~FLAG~ is a bitwise OR of one or more flag settings as described in
// <Field Macros> above.

`define uvm_field_sarray_object(ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_OBJ_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) begin \
            if((FLAG&UVM_REFERENCE)) \
              ARG = local_data__.ARG; \
            else \
              foreach(ARG[i]) begin \
                if(ARG[i] != null && local_data__.ARG[i] != null) \
                  ARG[i].copy(local_data__.ARG[i]); \
                else if(ARG[i] == null && local_data__.ARG[i] != null) \
                  $cast(ARG[i], local_data__.ARG[i].clone()); \
                else \
                  ARG[i] = null; \
              end \
          end \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if((FLAG&UVM_REFERENCE) && (m_sc.comparer.show_max <= 1) && (ARG !== local_data__.ARG) ) begin \
               if(m_sc.comparer.show_max == 1) begin \
                 m_sc.scope.set_arg(`"ARG`"); \
                 m_sc.comparer.print_msg(""); \
               end \
               else if ((m_sc.comparer.physical&&(FLAG&UVM_PHYSICAL)) || \
                        (m_sc.comparer.abstract&&(FLAG&UVM_ABSTRACT)) || \
                        (!(FLAG&UVM_PHYSICAL) && !(FLAG&UVM_ABSTRACT)) ) \
                 m_sc.comparer.result++; \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
            else begin \
              string s; \
              foreach(ARG[i]) begin \
                if(ARG[i] != null && local_data__.ARG[i] != null) begin \
                  $swrite(s,`"ARG[%0d]`",i); \
                  void'(m_sc.comparer.compare_object(s, ARG[i], local_data__.ARG[i])); \
                end \
                if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
              end \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          foreach(ARG[i])  \
            void'(m_sc.packer.pack_object(ARG[i])); \
        end \
      UVM_UNPACK: \
        begin \
          foreach(ARG[i]) \
            void'(m_sc.packer.unpack_object(ARG[i])); \
        end \
      UVM_RECORD: \
        `m_uvm_record_qda_object(ARG,FLAG,$size(ARG)) \
      UVM_PRINT: \
        begin \
          if(((FLAG)&UVM_NOPRINT) == 0 && \
                  m_sc.printer.knobs.print_fields == 1) begin \
             `uvm_print_sarray_object3(ARG, m_sc.printer, FLAG) \
          end \
        end \
      UVM_SETOBJ: \
        begin \
          string s; \
          if(!(FLAG &UVM_READONLY)) begin \
            foreach(ARG[i]) begin \
              $swrite(s,`"ARG[%0d]`",i); \
              m_sc.scope.set_arg(s); \
              if(uvm_is_match(str__, m_sc.scope.get())) begin \
                print_field_match("set_object()", str__); \
                if($cast(ARG[i],uvm_object::m_sc.object)) \
                  uvm_object::m_sc.status = 1; \
              end \
              else if(ARG[i]!=null && !(FLAG&UVM_REFERENCE)) begin \
                int cnt; \
                //Only traverse if there is a possible match. \
                for(cnt=0; cnt<str__.len(); ++cnt) begin \
                  if(str__[cnt] == "." || str__[cnt] == "*") break; \
                end \
                if(cnt!=str__.len()) begin \
                  m_sc.scope.down(s); \
                  ARG[i].m_field_automation(null, UVM_SETOBJ, str__); \
                  m_sc.scope.up(); \
                end \
              end \
            end \
          end \
        end \
    endcase \
  end


// MACRO: `uvm_field_sarray_string
//
// Implements the data operations for a one-dimensional static array of
// strings.
//
//|  `uvm_field_sarray_string(ARG,FLAG)
//
// ~ARG~ is a one-dimensional static array of strings, and ~FLAG~ is a bitwise
// OR of one or more flag settings as described in <Field Macros> above.

`define uvm_field_sarray_string(ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_STR_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG != local_data__.ARG) begin \
               if(m_sc.comparer.show_max == 1) begin \
                 m_sc.scope.set_arg(`"ARG`"); \
                 m_sc.comparer.print_msg(""); \
               end \
               else if(m_sc.comparer.show_max) begin \
                 foreach(ARG[i]) begin \
                   if(ARG[i] != local_data__.ARG[i]) begin \
                     m_sc.scope.set_arg_element(`"ARG`",i); \
                     void'(m_sc.comparer.compare_string("", ARG[i], local_data__.ARG[i])); \
                   end \
                 end \
               end \
               else if ((m_sc.comparer.physical&&(FLAG&UVM_PHYSICAL)) || \
                        (m_sc.comparer.abstract&&(FLAG&UVM_ABSTRACT)) || \
                        (!(FLAG&UVM_PHYSICAL) && !(FLAG&UVM_ABSTRACT)) ) \
                 m_sc.comparer.result++; \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          foreach(ARG[i])  \
            m_sc.packer.pack_string(ARG[i]); \
        end \
      UVM_UNPACK: \
        begin \
          foreach(ARG[i]) \
            ARG[i] = m_sc.packer.unpack_string(); \
        end \
      UVM_RECORD: \
        begin \
          /* Issue with $size for sarray with strings */ \
          int sz; foreach(ARG[i]) sz=i; \
          `m_uvm_record_qda_string(ARG, FLAG, sz) \
        end \
      UVM_PRINT: \
        begin \
          if(((FLAG)&UVM_NOPRINT) == 0 && \
                  m_sc.printer.knobs.print_fields == 1) begin \
             `uvm_print_sarray_string2(ARG, m_sc.printer) \
          end \
        end \
      UVM_SETSTR: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            else begin \
              uvm_report_warning("RDONLY", $psprintf("%s: static arrays cannot be resized via configuraton.",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
          end \
          else if(!(FLAG&UVM_READONLY)) begin \
            foreach(ARG[i]) begin \
              m_sc.scope.set_arg_element(`"ARG`",i); \
              if(uvm_is_match(str__, m_sc.scope.get())) begin \
                print_field_match("set_int()", str__); \
                ARG[i] =  uvm_object::m_sc.stringv; \
                m_sc.status = 1; \
              end \
            end \
          end \
        end \
    endcase \
  end


// MACRO: `uvm_field_sarray_enum
//
// Implements the data operations for a one-dimensional static array of
// enums.
//
//|  `uvm_field_sarray_enum(T,ARG,FLAG)
//
// ~T~ is a one-dimensional dynamic array of enums _type_, ~ARG~ is an
// instance of that type, and ~FLAG~ is a bitwise OR of one or more flag
// settings as described in <Field Macros> above.

`define uvm_field_sarray_enum(T,ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_INT_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG !== local_data__.ARG) begin \
               if(m_sc.comparer.show_max == 1) begin \
                 m_sc.scope.set_arg(`"ARG`"); \
                 m_sc.comparer.print_msg(""); \
               end \
               else if(m_sc.comparer.show_max) begin \
                 foreach(ARG[i]) begin \
                   if(ARG[i] !== local_data__.ARG[i]) begin \
                     m_sc.scope.set_arg_element(`"ARG`",i); \
                     $swrite(m_sc.stringv, "lhs = %0s : rhs = %0s", \
                       ARG[i].name(), local_data__.ARG[i].name()); \
                     m_sc.comparer.print_msg(m_sc.stringv); \
                     if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
                   end \
                 end \
               end \
               else if ((m_sc.comparer.physical&&(FLAG&UVM_PHYSICAL)) || \
                        (m_sc.comparer.abstract&&(FLAG&UVM_ABSTRACT)) || \
                        (!(FLAG&UVM_PHYSICAL) && !(FLAG&UVM_ABSTRACT)) ) \
                 m_sc.comparer.result++; \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          foreach(ARG[i])  \
            m_sc.packer.pack_field_int(int'(ARG[i]), $bits(ARG[i])); \
        end \
      UVM_UNPACK: \
        begin \
          foreach(ARG[i]) \
            ARG[i] = T'(m_sc.packer.unpack_field_int($bits(ARG[i]))); \
        end \
      UVM_RECORD: \
        `m_uvm_record_qda_enum(ARG, FLAG, $size(ARG)) \
      UVM_PRINT: \
        begin \
          if(((FLAG)&UVM_NOPRINT) == 0 && \
                  m_sc.printer.knobs.print_fields == 1) begin \
             `uvm_print_qda_enum(ARG, m_sc.printer, array, T) \
          end \
        end \
      UVM_SETINT: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            else begin \
              uvm_report_warning("RDONLY", $psprintf("%s: static arrays cannot be resized via configuraton.",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
          end \
          else if(!(FLAG&UVM_READONLY)) begin \
            foreach(ARG[i]) begin \
              m_sc.scope.set_arg_element(`"ARG`",i); \
              if(uvm_is_match(str__, m_sc.scope.get())) begin \
                print_field_match("set_int()", str__); \
                ARG[i] =  T'(uvm_object::m_sc.bitstream); \
                m_sc.status = 1; \
              end \
            end \
          end \
        end \
    endcase \
  end



//-----------------------------------------------------------------------------
// Group: `uvm_field_array_* macros
//
// Macros that implement data operations for one-dimensional dynamic array
// properties.
//
//-----------------------------------------------------------------------------

`define M_UVM_QUEUE_RESIZE(ARG,VAL) \
  //int sz = ARG.size(); \
  //if(m_sc.packer.use_metadata) sz = m_sc.packer.unpack_field_int(32); \
  //if(sz != ARG.size()) begin \
    while(ARG.size()<sz) ARG.push_back(VAL); \
    while(ARG.size()>sz) void'(ARG.pop_front()); \
  //end

`define M_UVM_ARRAY_RESIZE(ARG,VAL) \
  //int sz; \
  //sz = ARG.size(); \
  //if(what__ == UVM_UNPACK && m_sc.packer.use_metadata) sz = m_sc.packer.unpack_field_int(32); \
  //if(sz != ARG.size()) begin \
    ARG = new[sz](ARG); \
  //end

`define M_UVM_SARRAY_RESIZE(ARG,VAL) \
  /* fixed arrays can not be resized */


// MACRO: `uvm_field_array_int
//
// Implements the data operations for a one-dimensional dynamic array of
// integrals.
//
//|  `uvm_field_array_int(ARG,FLAG)
//
// ~ARG~ is a one-dimensional dynamic array of integrals,
// and ~FLAG~ is a bitwise OR of one or more flag settings as described in
// <Field Macros> above.

`define uvm_field_array_int(ARG,FLAG) \
   `M_UVM_FIELD_QDA_INT(ARRAY,ARG,FLAG) 

/**/ /* lines flagged with this are not needed or need to be different for fixed arrays, which can not be resized  */
     /* fixed arrays do not need to pack/unpack their size either, because their size is known ; wouldn't hurt though */

`define M_UVM_FIELD_QDA_INT(TYPE,ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_INT_T); \
      UVM_COPY: \
        begin \
          if (local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if (local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG !== local_data__.ARG) begin \
               if(m_sc.comparer.show_max == 1) begin \
                 m_sc.scope.set_arg(`"ARG`"); \
                 m_sc.comparer.print_msg(""); \
               end \
               else if(m_sc.comparer.show_max) begin \
                 /**/ if(ARG.size() != local_data__.ARG.size()) begin \
                 /**/   void'(m_sc.comparer.compare_field(`"ARG.size()`", ARG.size(), local_data__.ARG.size(), 32)); \
                 /**/ end \
                 else begin \
                   foreach(ARG[i]) begin \
                     if(ARG[i] !== local_data__.ARG[i]) begin \
                       m_sc.scope.set_arg_element(`"ARG`",i); \
                       void'(m_sc.comparer.compare_field("", ARG[i], local_data__.ARG[i], $bits(ARG[i]))); \
                     end \
                   end \
                 end \
               end \
               else if ((m_sc.comparer.physical&&(FLAG&UVM_PHYSICAL)) || \
                        (m_sc.comparer.abstract&&(FLAG&UVM_ABSTRACT)) || \
                        (!(FLAG&UVM_PHYSICAL) && !(FLAG&UVM_ABSTRACT)) ) \
                 m_sc.comparer.result++; \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          /**/ if(m_sc.packer.use_metadata) m_sc.packer.pack_field_int(ARG.size(), 32); \
          foreach(ARG[i])  \
            if($bits(ARG[i]) <= 64) m_sc.packer.pack_field_int(ARG[i], $bits(ARG[i])); \
            else m_sc.packer.pack_field(ARG[i], $bits(ARG[i])); \
        end \
      UVM_UNPACK: \
        begin \
          /**/ int sz = ARG.size(); \
          /**/ if(m_sc.packer.use_metadata) sz = m_sc.packer.unpack_field_int(32); \
          if(sz != ARG.size()) begin \
          `M_UVM_``TYPE``_RESIZE (ARG,0) \
          end \
          foreach(ARG[i]) \
            if($bits(ARG[i]) <= 64) ARG[i] = m_sc.packer.unpack_field_int($bits(ARG[i])); \
            else ARG[i] = m_sc.packer.unpack_field($bits(ARG[i])); \
        end \
      UVM_RECORD: \
        `m_uvm_record_qda_int(ARG, FLAG, ARG.size()) \
      UVM_PRINT: \
        begin \
          if(((FLAG)&UVM_NOPRINT) == 0 && \
                  m_sc.printer.knobs.print_fields == 1) begin \
             `uvm_print_array_int3(ARG, uvm_radix_enum'((FLAG)&(UVM_RADIX)), \
                                   m_sc.printer) \
          end \
        end \
      UVM_SETINT: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            /**/ else begin \
            /**/   int sz =  uvm_object::m_sc.bitstream; \
            /**/   print_field_match("set_int()", str__); \
            /**/   if(ARG.size() !=  sz) begin \
            /**/     `M_UVM_``TYPE``_RESIZE(ARG,0) \
            /**/   end \
            /**/   m_sc.status = 1; \
            /**/ end \
          end \
          else if(!(FLAG&UVM_READONLY)) begin \
            foreach(ARG[i]) begin \
              m_sc.scope.set_arg_element(`"ARG`",i); \
              if(uvm_is_match(str__, m_sc.scope.get())) begin \
                print_field_match("set_int()", str__); \
                ARG[i] =  uvm_object::m_sc.bitstream; \
                m_sc.status = 1; \
              end \
            end \
          end \
        end \
    endcase \
  end


// MACRO: `uvm_field_array_object
//
// Implements the data operations for a one-dimensional dynamic array
// of <uvm_object>-based objects.
//
//|  `uvm_field_array_object(ARG,FLAG)
//
// ~ARG~ is a one-dimensional dynamic array of <uvm_object>-based objects,
// and ~FLAG~ is a bitwise OR of one or more flag settings as described in
// <Field Macros> above.

`define uvm_field_array_object(ARG,FLAG) \
  `M_UVM_FIELD_QDA_OBJECT(ARRAY,ARG,FLAG)

`define M_UVM_FIELD_QDA_OBJECT(TYPE,ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_OBJ_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) begin \
            if((FLAG&UVM_REFERENCE)) \
              ARG = local_data__.ARG; \
            else \
              foreach(ARG[i]) begin \
                if(ARG[i] != null && local_data__.ARG[i] != null) \
                  ARG[i].copy(local_data__.ARG[i]); \
                else if(ARG[i] == null && local_data__.ARG[i] != null) \
                  $cast(ARG[i], local_data__.ARG[i].clone()); \
                else \
                  ARG[i] = null; \
              end \
          end \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if((FLAG&UVM_REFERENCE) && (m_sc.comparer.show_max <= 1) && (ARG !== local_data__.ARG) ) begin \
               if(m_sc.comparer.show_max == 1) begin \
                 m_sc.scope.set_arg(`"ARG`"); \
                 m_sc.comparer.print_msg(""); \
               end \
               else if ((m_sc.comparer.physical&&(FLAG&UVM_PHYSICAL)) || \
                        (m_sc.comparer.abstract&&(FLAG&UVM_ABSTRACT)) || \
                        (!(FLAG&UVM_PHYSICAL) && !(FLAG&UVM_ABSTRACT)) ) \
                 m_sc.comparer.result++; \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
            else begin \
              string s; \
              foreach(ARG[i]) begin \
                if(ARG[i] != null && local_data__.ARG[i] != null) begin \
                  $swrite(s,`"ARG[%0d]`",i); \
                  void'(m_sc.comparer.compare_object(s, ARG[i], local_data__.ARG[i])); \
                end \
                if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
              end \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          if(m_sc.packer.use_metadata) m_sc.packer.pack_field_int(ARG.size(), 32); \
          foreach(ARG[i])  \
            void'(m_sc.packer.pack_object(ARG[i])); \
        end \
      UVM_UNPACK: \
        begin \
          int sz = ARG.size(); \
          if(m_sc.packer.use_metadata) sz = m_sc.packer.unpack_field_int(32); \
          if(sz != ARG.size()) begin \
            `M_UVM_``TYPE``_RESIZE(ARG,null) \
          end \
          foreach(ARG[i]) \
            void'(m_sc.packer.unpack_object(ARG[i])); \
        end \
      UVM_RECORD: \
        `m_uvm_record_qda_object(ARG,FLAG,ARG.size()) \
      UVM_PRINT: \
        begin \
          if(((FLAG)&UVM_NOPRINT) == 0 && \
                  m_sc.printer.knobs.print_fields == 1) begin \
             `uvm_print_array_object3(ARG, m_sc.printer,FLAG) \
          end \
        end \
      UVM_SETINT: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            else begin \
              int sz =  uvm_object::m_sc.bitstream; \
              print_field_match("set_int()", str__); \
              if(ARG.size() !=  sz) begin \
                `M_UVM_``TYPE``_RESIZE(ARG,null) \
              end \
              m_sc.status = 1; \
            end \
          end \
        end \
      UVM_SETOBJ: \
        begin \
          string s; \
          if(!(FLAG &UVM_READONLY)) begin \
            foreach(ARG[i]) begin \
              $swrite(s,`"ARG[%0d]`",i); \
              m_sc.scope.set_arg(s); \
              if(uvm_is_match(str__, m_sc.scope.get())) begin \
                print_field_match("set_object()", str__); \
                if($cast(ARG[i],uvm_object::m_sc.object)) \
                  uvm_object::m_sc.status = 1; \
              end \
              else if(ARG[i]!=null && !(FLAG&UVM_REFERENCE)) begin \
                int cnt; \
                //Only traverse if there is a possible match. \
                for(cnt=0; cnt<str__.len(); ++cnt) begin \
                  if(str__[cnt] == "." || str__[cnt] == "*") break; \
                end \
                if(cnt!=str__.len()) begin \
                  m_sc.scope.down(s); \
                  ARG[i].m_field_automation(null, UVM_SETOBJ, str__); \
                  m_sc.scope.up(); \
                end \
              end \
            end \
          end \
        end \
    endcase \
  end 


// MACRO: `uvm_field_array_string
//
// Implements the data operations for a one-dimensional dynamic array 
// of strings.
//
//|  `uvm_field_array_string(ARG,FLAG)
//
// ~ARG~ is a one-dimensional dynamic array of strings, and ~FLAG~ is a bitwise
// OR of one or more flag settings as described in <Field Macros> above.

`define uvm_field_array_string(ARG,FLAG) \
  `M_UVM_FIELD_QDA_STRING(ARRAY,ARG,FLAG)

`define M_UVM_FIELD_QDA_STRING(TYPE,ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_STR_T); \
      UVM_COPY: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(local_data__ == null) return; \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG != local_data__.ARG) begin \
               if(m_sc.comparer.show_max == 1) begin \
                 m_sc.scope.set_arg(`"ARG`"); \
                 m_sc.comparer.print_msg(""); \
               end \
               else if(m_sc.comparer.show_max) begin \
                 if(ARG.size() != local_data__.ARG.size()) begin \
                   void'(m_sc.comparer.compare_field(`"ARG.size()`", ARG.size(), local_data__.ARG.size(), 32)); \
                 end \
                 else begin \
                   foreach(ARG[i]) begin \
                     if(ARG[i] != local_data__.ARG[i]) begin \
                       m_sc.scope.set_arg_element(`"ARG`",i); \
                       void'(m_sc.comparer.compare_string("", ARG[i], local_data__.ARG[i])); \
                     end \
                   end \
                 end \
               end \
               else if ((m_sc.comparer.physical&&(FLAG&UVM_PHYSICAL)) || \
                        (m_sc.comparer.abstract&&(FLAG&UVM_ABSTRACT)) || \
                        (!(FLAG&UVM_PHYSICAL) && !(FLAG&UVM_ABSTRACT)) ) \
                 m_sc.comparer.result++; \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          if(m_sc.packer.use_metadata) m_sc.packer.pack_field_int(ARG.size(), 32); \
          foreach(ARG[i])  \
            m_sc.packer.pack_string(ARG[i]); \
        end \
      UVM_UNPACK: \
        begin \
          int sz = ARG.size(); \
          if(m_sc.packer.use_metadata) sz = m_sc.packer.unpack_field_int(32); \
          if(sz != ARG.size()) begin \
            `M_UVM_``TYPE``_RESIZE(ARG,"") \
          end \
          foreach(ARG[i]) \
            ARG[i] = m_sc.packer.unpack_string(); \
        end \
      UVM_RECORD: \
        `m_uvm_record_qda_string(ARG,FLAG,ARG.size()) \
      UVM_PRINT: \
        begin \
          if(((FLAG)&UVM_NOPRINT) == 0 && \
                  m_sc.printer.knobs.print_fields == 1) begin \
             `uvm_print_array_string2(ARG, m_sc.printer) \
          end \
        end \
      UVM_SETINT: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            else begin \
              int sz =  uvm_object::m_sc.bitstream; \
              print_field_match("set_int()", str__); \
              if(ARG.size() !=  sz) begin \
                `M_UVM_``TYPE``_RESIZE(ARG,"") \
              end \
              m_sc.status = 1; \
            end \
          end \
        end \
      UVM_SETSTR: \
        begin \
          if(!(FLAG&UVM_READONLY)) begin \
            foreach(ARG[i]) begin \
              m_sc.scope.set_arg_element(`"ARG`",i); \
              if(uvm_is_match(str__, m_sc.scope.get())) begin \
                print_field_match("set_int()", str__); \
                ARG[i] =  uvm_object::m_sc.stringv; \
                m_sc.status = 1; \
              end \
            end \
          end \
        end \
    endcase \
  end



// MACRO: `uvm_field_array_enum
//
// Implements the data operations for a one-dimensional dynamic array of
// enums.
//
//|  `uvm_field_array_enum(T,ARG,FLAG)
//
// ~T~ is a one-dimensional dynamic array of enums _type_,
// ~ARG~ is an instance of that type, and ~FLAG~ is a bitwise OR of
// one or more flag settings as described in <Field Macros> above.

`define uvm_field_array_enum(T,ARG,FLAG) \
  `M_FIELD_QDA_ENUM(ARRAY,T,ARG,FLAG) 

`define M_FIELD_QDA_ENUM(TYPE,T,ARG,FLAG) \
  begin \
    case (what__) \
      UVM_CHECK_FIELDS: \
        m_do_field_check(`"ARG`", UVM_INT_T); \
      UVM_COPY: \
        begin \
          if(!(FLAG&UVM_NOCOPY)) ARG = local_data__.ARG; \
        end \
      UVM_COMPARE: \
        begin \
          if(!(FLAG&UVM_NOCOMPARE)) begin \
            if(ARG !== local_data__.ARG) begin \
               if(m_sc.comparer.show_max == 1) begin \
                 m_sc.scope.set_arg(`"ARG`"); \
                 m_sc.comparer.print_msg(""); \
               end \
               else if(m_sc.comparer.show_max) begin \
                 /**/if(ARG.size() != local_data__.ARG.size()) begin \
                 /**/  void'(m_sc.comparer.compare_field(`"ARG.size()`", ARG.size(), local_data__.ARG.size(), 32)); \
                 /**/end \
                 /**/else begin \
                   foreach(ARG[i]) begin \
                     if(ARG[i] !== local_data__.ARG[i]) begin \
                       m_sc.scope.set_arg_element(`"ARG`",i); \
                       $swrite(m_sc.stringv, "lhs = %0s : rhs = %0s", \
                         ARG[i].name(), local_data__.ARG[i].name()); \
                       m_sc.comparer.print_msg(m_sc.stringv); \
                       if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
                     end \
                   end \
                 /**/end \
               end \
               else if ((m_sc.comparer.physical&&(FLAG&UVM_PHYSICAL)) || \
                        (m_sc.comparer.abstract&&(FLAG&UVM_ABSTRACT)) || \
                        (!(FLAG&UVM_PHYSICAL) && !(FLAG&UVM_ABSTRACT)) ) \
                 m_sc.comparer.result++; \
               if(m_sc.comparer.result && (m_sc.comparer.show_max <= m_sc.comparer.result)) return; \
            end \
          end \
        end \
      UVM_PACK: \
        begin \
          /**/if(m_sc.packer.use_metadata) m_sc.packer.pack_field_int(ARG.size(), 32); \
          foreach(ARG[i])  \
            m_sc.packer.pack_field_int(int'(ARG[i]), $bits(ARG[i])); \
        end \
      UVM_UNPACK: \
        begin \
          /**/int sz = ARG.size(); \
          /**/if(m_sc.packer.use_metadata) sz = m_sc.packer.unpack_field_int(32); \
          /**/if(sz != ARG.size()) begin \
          /**/  T tmp__; \
          /**/  `M_UVM_``TYPE``_RESIZE(ARG,tmp__) \
          /**/end \
          foreach(ARG[i]) \
            ARG[i] = T'(m_sc.packer.unpack_field_int($bits(ARG[i]))); \
        end \
      UVM_RECORD: \
        /**/`m_uvm_record_qda_enum(ARG,FLAG,ARG.size()) \
      UVM_PRINT: \
        begin \
          if(((FLAG)&UVM_NOPRINT) == 0 && \
                  m_sc.printer.knobs.print_fields == 1) begin \
             `uvm_print_qda_enum(ARG, m_sc.printer, array, T) \
          end \
        end \
      UVM_SETINT: \
        begin \
          m_sc.scope.set_arg(`"ARG`"); \
          if(uvm_is_match(str__, m_sc.scope.get())) begin \
            if(FLAG&UVM_READONLY) begin \
              uvm_report_warning("RDONLY", $psprintf("Readonly argument match %s is ignored",  \
                 m_sc.get_full_scope_arg()), UVM_NONE); \
            end \
            /**/else begin \
            /**/  int sz =  uvm_object::m_sc.bitstream; \
            /**/  print_field_match("set_int()", str__); \
            /**/  if(ARG.size() !=  sz) begin \
            /**/    T tmp__; \
            /**/    `M_UVM_``TYPE``_RESIZE(ARG,tmp__) \
            /**/  end \
            /**/  m_sc.status = 1; \
            /**/end \
          end \
          else if(!(FLAG&UVM_READONLY)) begin \
            foreach(ARG[i]) begin \
              m_sc.scope.set_arg_element(`"ARG`",i); \
              if(uvm_is_match(str__, m_sc.scope.get())) begin \
                print_field_match("set_int()", str__); \
                ARG[i] =  T'(uvm_object::m_sc.bitstream); \
                m_sc.status = 1; \
              end \
            end \
          end \
        end \
    endcase \
  end


//-----------------------------------------------------------------------------
// Group: `uvm_field_queue_* macros
//
// Macros that implement data operations for dynamic queues.
//
//-----------------------------------------------------------------------------

// MACRO: `uvm_field_queue_int
//
// Implements the data operations for a queue of integrals.
//
//|  `uvm_field_queue_int(ARG,FLAG)
//
// ~ARG~ is a one-dimensional queue of integrals,
// and ~FLAG~ is a bitwise OR of one or more flag settings as described in
// <Field Macros> above.

`define uvm_field_queue_int(ARG,FLAG) \
  `M_UVM_FIELD_QDA_INT(QUEUE,ARG,FLAG)

// MACRO: `uvm_field_queue_object
//
// Implements the data operations for a queue of <uvm_object>-based objects.
//
//|  `uvm_field_queue_object(ARG,FLAG)
//
// ~ARG~ is a one-dimensional queue of <uvm_object>-based objects,
// and ~FLAG~ is a bitwise OR of one or more flag settings as described in
// <Field Macros> above.

`define uvm_field_queue_object(ARG,FLAG) \
  `M_UVM_FIELD_QDA_OBJECT(QUEUE,ARG,FLAG)


// MACRO: `uvm_field_queue_string
//
// Implements the data operations for a queue of strings.
//
//|  `uvm_field_queue_string(ARG,FLAG)
//
// ~ARG~ is a one-dimensional queue of strings, and ~FLAG~ is a bitwise
// OR of one or more flag settings as described in <Field Macros> above.

`define uvm_field_queue_string(ARG,FLAG) \
  `M_UVM_FIELD_QDA_STRING(QUEUE,ARG,FLAG)


// MACRO: `uvm_field_queue_enum
//
// Implements the data operations for a one-dimensional queue of enums.
//
//|  `uvm_field_queue_enum(T,ARG,FLAG)
//
// ~T~ is a queue of enums _type_, ~ARG~ is an instance of that type,
// and ~FLAG~ is a bitwise OR of one or more flag settings as described
// in <Field Macros> above.

`define uvm_field_queue_enum(T,ARG,FLAG) \
  `M_FIELD_QDA_ENUM(QUEUE,T,ARG,FLAG)


//-----------------------------------------------------------------------------
// Group: `uvm_field_aa_*_string macros
//
// Macros that implement data operations for associative arrays indexed
// by ~string~.
//
//-----------------------------------------------------------------------------

// MACRO: `uvm_field_aa_int_string
//
// Implements the data operations for an associative array of integrals indexed
// by ~string~.
//
//|  `uvm_field_aa_int_string(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with string key, and ~FLAG~ is a bitwise OR of one or more flag settings as
// described in <Field Macros> above.

`define uvm_field_aa_int_string(ARG, FLAG) \
  begin \
  if(what__==UVM_CHECK_FIELDS) m_do_field_check(`"ARG`", UVM_INT_T); \
  `M_UVM_FIELD_DATA_AA_int_string(ARG,FLAG) \
  `M_UVM_FIELD_SET_AA_TYPE(string, INT, ARG, m_sc.bitstream, FLAG)  \
  end


// MACRO: `uvm_field_aa_object_string
//
// Implements the data operations for an associative array of <uvm_object>-based
// objects indexed by ~string~.
//
//|  `uvm_field_aa_object_string(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of objects
// with string key, and ~FLAG~ is a bitwise OR of one or more flag settings as
// described in <Field Macros> above.

`define uvm_field_aa_object_string(ARG, FLAG) \
  begin \
  if(what__==UVM_CHECK_FIELDS) m_do_field_check(`"ARG`", UVM_OBJ_T); \
  `M_UVM_FIELD_DATA_AA_object_string(ARG,FLAG) \
  `M_UVM_FIELD_SET_AA_OBJECT_TYPE(string, ARG, FLAG)  \
  end


// MACRO: `uvm_field_aa_string_string
//
// Implements the data operations for an associative array of strings indexed
// by ~string~.
//
//|  `uvm_field_aa_string_string(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of strings
// with string key, and ~FLAG~ is a bitwise OR of one or more flag settings as
// described in <Field Macros> above.

`define uvm_field_aa_string_string(ARG, FLAG) \
  begin \
  if(what__==UVM_CHECK_FIELDS) m_do_field_check(`"ARG`", UVM_STR_T); \
  `M_UVM_FIELD_DATA_AA_string_string(ARG,FLAG) \
  `M_UVM_FIELD_SET_AA_TYPE(string, STR, ARG, m_sc.stringv, FLAG)  \
  end


//-----------------------------------------------------------------------------
// Group: `uvm_field_aa_*_int macros
//
// Macros that implement data operations for associative arrays indexed by an
// integral type.
//
//-----------------------------------------------------------------------------

// MACRO: `uvm_field_aa_object_int
//
// Implements the data operations for an associative array of <uvm_object>-based
// objects indexed by the ~int~ data type.
//
//|  `uvm_field_aa_object_int(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of objects
// with ~int~ key, and ~FLAG~ is a bitwise OR of one or more flag settings as
// described in <Field Macros> above.

`define uvm_field_aa_object_int(ARG, FLAG) \
  begin \
  if(what__==UVM_CHECK_FIELDS) m_do_field_check(`"ARG`", UVM_OBJ_T); \
  `M_UVM_FIELD_DATA_AA_object_int(ARG,FLAG) \
  `M_UVM_FIELD_SET_AA_OBJECT_TYPE(int, ARG, FLAG)  \
  end


// MACRO: `uvm_field_aa_int_int
//
// Implements the data operations for an associative array of integral
// types indexed by the ~int~ data type.
//
//|  `uvm_field_aa_int_int(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~int~ key, and ~FLAG~ is a bitwise OR of one or more flag settings as
// described in <Field Macros> above.

`define uvm_field_aa_int_int(ARG, FLAG) \
  `uvm_field_aa_int_key(int, ARG, FLAG) \


// MACRO: `uvm_field_aa_int_int_unsigned
//
// Implements the data operations for an associative array of integral
// types indexed by the ~int unsigned~ data type.
//
//|  `uvm_field_aa_int_int_unsigned(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~int unsigned~ key, and ~FLAG~ is a bitwise OR of one or more flag
// settings as described in <Field Macros> above.

`define uvm_field_aa_int_int_unsigned(ARG, FLAG) \
  `uvm_field_aa_int_key(int unsigned, ARG, FLAG)


// MACRO: `uvm_field_aa_int_integer
//
// Implements the data operations for an associative array of integral
// types indexed by the ~integer~ data type.
//
//|  `uvm_field_aa_int_integer(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~integer~ key, and ~FLAG~ is a bitwise OR of one or more flag settings
// as described in <Field Macros> above.

`define uvm_field_aa_int_integer(ARG, FLAG) \
  `uvm_field_aa_int_key(integer, ARG, FLAG)


// MACRO: `uvm_field_aa_int_integer_unsigned
//
// Implements the data operations for an associative array of integral
// types indexed by the ~integer unsigned~ data type.
//
//|  `uvm_field_aa_int_integer_unsigned(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~integer unsigned~ key, and ~FLAG~ is a bitwise OR of one or more 
// flag settings as described in <Field Macros> above.

`define uvm_field_aa_int_integer_unsigned(ARG, FLAG) \
  `uvm_field_aa_int_key(integer unsigned, ARG, FLAG)


// MACRO: `uvm_field_aa_int_byte
//
// Implements the data operations for an associative array of integral
// types indexed by the ~byte~ data type.
//
//|  `uvm_field_aa_int_byte(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~byte~ key, and ~FLAG~ is a bitwise OR of one or more flag settings as
// described in <Field Macros> above.

`define uvm_field_aa_int_byte(ARG, FLAG) \
  `uvm_field_aa_int_key(byte, ARG, FLAG)


// MACRO: `uvm_field_aa_int_byte_unsigned
//
// Implements the data operations for an associative array of integral
// types indexed by the ~byte unsigned~ data type.
//
//|  `uvm_field_aa_int_byte_unsigned(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~byte unsigned~ key, and ~FLAG~ is a bitwise OR of one or more flag
// settings as described in <Field Macros> above.

`define uvm_field_aa_int_byte_unsigned(ARG, FLAG) \
  `uvm_field_aa_int_key(byte unsigned, ARG, FLAG)


// MACRO: `uvm_field_aa_int_shortint
//
// Implements the data operations for an associative array of integral
// types indexed by the ~shortint~ data type.
//
//|  `uvm_field_aa_int_shortint(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~shortint~ key, and ~FLAG~ is a bitwise OR of one or more flag
// settings as described in <Field Macros> above.

`define uvm_field_aa_int_shortint(ARG, FLAG) \
  `uvm_field_aa_int_key(shortint, ARG, FLAG)


// MACRO: `uvm_field_aa_int_shortint_unsigned
//
// Implements the data operations for an associative array of integral
// types indexed by the ~shortint unsigned~ data type.
//
//|  `uvm_field_aa_int_shortint_unsigned(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~shortint unsigned~ key, and ~FLAG~ is a bitwise OR of one or more
// flag settings as described in <Field Macros> above.

`define uvm_field_aa_int_shortint_unsigned(ARG, FLAG) \
  `uvm_field_aa_int_key(shortint unsigned, ARG, FLAG)


// MACRO: `uvm_field_aa_int_longint
//
// Implements the data operations for an associative array of integral
// types indexed by the ~longint~ data type.
//
//|  `uvm_field_aa_int_longint(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~longint~ key, and ~FLAG~ is a bitwise OR of one or more flag settings
// as described in <Field Macros> above.

`define uvm_field_aa_int_longint(ARG, FLAG) \
  `uvm_field_aa_int_key(longint, ARG, FLAG)


// MACRO: `uvm_field_aa_int_longint_unsigned
//
// Implements the data operations for an associative array of integral
// types indexed by the ~longint unsigned~ data type.
//
//|  `uvm_field_aa_int_longint_unsigned(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~longint unsigned~ key, and ~FLAG~ is a bitwise OR of one or more
// flag settings as described in <Field Macros> above.

`define uvm_field_aa_int_longint_unsigned(ARG, FLAG) \
  `uvm_field_aa_int_key(longint unsigned, ARG, FLAG)


// MACRO: `uvm_field_aa_int_key
//
// Implements the data operations for an associative array of integral
// types indexed by any integral key data type. 
//
//|  `uvm_field_aa_int_key(long unsigned,ARG,FLAG)
//
// ~KEY~ is the data type of the integral key, ~ARG~ is the name of a property 
// that is an associative array of integrals, and ~FLAG~ is a bitwise OR of one 
// or more flag settings as described in <Field Macros> above.

`define uvm_field_aa_int_key(KEY, ARG, FLAG) \
  begin \
  if(what__==UVM_CHECK_FIELDS) m_do_field_check(`"ARG`", UVM_INT_T); \
  `M_UVM_FIELD_DATA_AA_int_key(KEY,ARG,FLAG) \
  `M_UVM_FIELD_SET_AA_INT_TYPE(KEY, INT, ARG, m_sc.bitstream, FLAG)  \
  end


// MACRO: `uvm_field_aa_int_enumkey
//
// Implements the data operations for an associative array of integral
// types indexed by any enumeration key data type. 
//
//|  `uvm_field_aa_int_longint_unsigned(ARG,FLAG)
//
// ~ARG~ is the name of a property that is an associative array of integrals
// with ~longint unsigned~ key, and ~FLAG~ is a bitwise OR of one or more
// flag settings as described in <Field Macros> above.

`define uvm_field_aa_int_enumkey(KEY, ARG, FLAG) \
  begin \
  if(what__==UVM_CHECK_FIELDS) m_do_field_check(`"ARG`", UVM_INT_T); \
  `M_UVM_FIELD_DATA_AA_enum_key(KEY,ARG,FLAG) \
  `M_UVM_FIELD_SET_AA_INT_ENUMTYPE(KEY, INT, ARG, m_sc.bitstream, FLAG)  \
  end

//-----------------------------------------------------------------------------
//
// MACROS- recording
//
//-----------------------------------------------------------------------------

// m_uvm_record_int
// --------------

// Purpose: provide print functionality for a specific integral field. This
// macro is available for user access. If used externally, a record_options
// object must be avaialble and must have the name opt.
// 
// Postcondition: ~ARG~ is printed using the format set by the FLAGS.

`define m_uvm_record_int(ARG,FLAG) \
  if(!(FLAG&UVM_NORECORD)) begin \
    m_sc.recorder.record_field(`"ARG`", ARG,  $bits(ARG), uvm_radix_enum'((FLAG)&(UVM_RADIX))); \
  end


// m_uvm_record_string
// -----------------

// Purpose: provide record functionality for a specific string field. This
// macro is available for user access. If used externally, a record_options
// object must be avaialble and must have the name recorder.
//  
// Postcondition: ~ARG~ is recorded in string format.
      

`define m_uvm_record_string(ARG,STR,FLAG) \
  if(!(FLAG&UVM_NORECORD)) begin \
    m_sc.recorder.record_string(`"ARG`", STR); \
  end


// m_uvm_record_object
// -----------------

// Purpose: provide record functionality for a specific <uvm_object> field. This
// macro is available for user access. If used externally, a record_options
// object must be avaialble and must have the name recorder.
//
// Postcondition: ~ARG~ is recorded. The record is done recursively where the
// depth to record is set in the recorder object.


`define m_uvm_record_object(ARG,FLAG) \
  if(!(FLAG&UVM_NORECORD)) begin \
    m_sc.recorder.record_object(`"ARG`", ARG); \
  end


// m_uvm_record_any_object
// ---------------------

// Purpose: provide record functionality for a user specific class object. This
// macro is available for user access. If used externally, a record_options
// object must be availble and must have the name recorder.
//
// Postcondition: The reference value of ~ARG~ is recorded.

`define m_uvm_record_any_object(ARG) \
  //recorder.record_object(`"ARG`", ARG);  


//-----------------------------------------------------------------------------
//
// INTERNAL MACROS - do not use directly
//
//-----------------------------------------------------------------------------


// Purpose: Provide a way for a derived class to override the flag settings in
// the base class.
//

`define uvm_set_flags(ARG,FLAG) \
  begin \
   if(what__ == UVM_FLAGS) begin \
   end \
  end


`define uvm_unpack_array_enum(T,ARG,FLAG) \
  if((what__ == UVM_UNPACK) && !(UVM_NOPACK&(FLAG))) begin \
    if((((FLAG)&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) || \
        (!((FLAG)&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin \
      if(uvm_auto_options_object.packer.use_metadata) begin \
        int s_; \
        s_ = uvm_auto_options_object.packer.unpack_field_int(32); \
        ARG = new[s_]; \
      end \
      foreach(ARG[i]) \
        ARG[i] = T'(uvm_auto_options_object.packer.unpack_field($bits(ARG[i]))); \
    end \
  end


`define uvm_unpack_queue_enum(T,ARG,FLAG) \
  if((what__ == UVM_UNPACK) && !(UVM_NOPACK&(FLAG))) begin \
    if((((FLAG)&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) || \
        (!((FLAG)&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) begin \
      if(uvm_auto_options_object.packer.use_metadata) begin \
        int s_; \
        s_ = uvm_auto_options_object.packer.unpack_field_int(32); \
        while(ARG.size() > s_) void'(ARG.pop_front()); \
        while(ARG.size() < s_) ARG.push_back(T'(0)); \
      end \
      foreach(ARG[i]) \
        ARG[i] = T'(uvm_auto_options_object.packer.unpack_field($bits(ARG[i]))); \
    end \
  end \


`define uvm_pack_unpack_sarray_enum(T,ARG,FLAG) \
  if((what__ == UVM_PACK) && !(UVM_NOPACK&(FLAG))) begin \
    if((((FLAG)&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) || \
        (!((FLAG)&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) \
      foreach(ARG[i]) \
        uvm_auto_options_object.packer.pack_field(ARG[i],$bits(ARG[i])); \
  end \
  else if((what__ == UVM_UNPACK) && !(UVM_NOPACK&(FLAG))) begin \
    if((((FLAG)&UVM_ABSTRACT) && uvm_auto_options_object.packer.abstract) || \
        (!((FLAG)&UVM_ABSTRACT) && uvm_auto_options_object.packer.physical)) \
      foreach(ARG[i]) \
        ARG[i] = T'(uvm_auto_options_object.packer.unpack_field($bits(ARG[i]))); \
  end \


`define uvm_field_qda_enum(T,ARG,FLAG) \
  begin \
    T lh__, rh__; \
    m_sc.scope.down(`"ARG`",null); \
    if(what__ == UVM_CHECK_FIELDS) \
      m_do_field_check(`"ARG`", UVM_INT_T); \
    if((what__ == UVM_PRINT) && !(UVM_NOPRINT&(FLAG))) \
      `uvm_print_qda_enum(ARG, uvm_auto_options_object.printer, array, T) \
    else if((what__ == UVM_RECORD) && !(UVM_NORECORD&(FLAG))) \
      `m_uvm_record_qda_enum(T,ARG, uvm_auto_options_object.recorder) \
    else if((what__ == UVM_COMPARE) && !(UVM_NOCOMPARE&(FLAG))) begin \
      $cast(local_data__, tmp_data__); \
      if(ARG.size() != local_data__.ARG.size()) begin \
        int s1__, s2__; \
        m_sc.stringv = ""; \
        s1__ = ARG.size(); s2__ = local_data__.ARG.size(); \
        $swrite(m_sc.stringv, "lhs size = %0d : rhs size = %0d", s1__, s2__);\
        uvm_auto_options_object.comparer.print_msg(m_sc.stringv); \
      end \
      for(int i__=0; i__<ARG.size() && i__<local_data__.ARG.size(); ++i__) \
        if(ARG[i__] !== local_data__.ARG[i__]) begin \
          lh__ = ARG[i__]; \
          rh__ = local_data__.ARG[i__]; \
          uvm_auto_options_object.comparer.scope.down_element(i__, null);\
          $swrite(m_sc.stringv, "lhs = %0s : rhs = %0s", \
            lh__.name(), rh__.name()); \
          uvm_auto_options_object.comparer.print_msg(m_sc.stringv); \
          uvm_auto_options_object.comparer.scope.up_element(null);\
        end \
    end \
    if((what__ == UVM_COPY) && !(UVM_NOCOPY&(FLAG))) begin \
      $cast(local_data__, tmp_data__); \
      if(local_data__ != null) ARG = local_data__.ARG; \
    end \
    else if((what__ == UVM_PACK) && !(UVM_NOPACK&(FLAG))) begin \
      if(uvm_auto_options_object.packer.use_metadata == 1) \
        uvm_auto_options_object.packer.pack_field_int(ARG.size(), 32); \
      foreach(ARG[i]) \
        uvm_auto_options_object.packer.pack_field(int'(ARG[i]), $bits(ARG[i])); \
    end \
    m_sc.scope.up(null); \
  end


// uvm_new_func
// ------------

`define uvm_new_func \
  function new (string name, uvm_component parent); \
    super.new(name, parent); \
  endfunction

`define uvm_component_new_func \
  `uvm_new_func

`define uvm_new_func_data \
  function new (string name=""); \
    super.new(name); \
  endfunction

`define uvm_object_new_func \
  `uvm_new_func_data

`define uvm_named_object_new_func \
  function new (string name, uvm_component parent); \
    super.new(name, parent); \
  endfunction


// uvm_object_create_func
// ----------------------

// Zero argument create function, requires default constructor
`define uvm_object_create_func(T) \
   function uvm_object create (string name=""); \
     T tmp; \
     tmp = new(); \
     if (name!="") \
       tmp.set_name(name); \
     return tmp; \
   endfunction


// uvm_named_object_create_func
// ----------------------------

`define uvm_named_object_create_func(T) \
   function uvm_named_object create_named_object (string name, uvm_named_object parent); \
     T tmp; \
     tmp = new(.name(name), .parent(parent)); \
     return tmp; \
   endfunction


`define uvm_named_object_factory_create_func(T) \
  `uvm_named_object_create_func(T) \


// uvm_object_factory_create_func
// ------------------------------

`define uvm_object_factory_create_func(T) \
   function uvm_object create_object (string name=""); \
     T tmp; \
     tmp = new(); \
     if (name!="") \
       tmp.set_name(name); \
     return tmp; \
   endfunction \
   \
   static function T create(string name="", uvm_component parent=null, string contxt=""); \
     uvm_factory f; \
     f = uvm_factory::get(); \
     if (contxt == "" && parent != null) \
       contxt = parent.get_full_name(); \
     if(!$cast(create,f.create_object_by_type(get(),contxt,name))) \
        `uvm_fatal_context("FACTFL", {"Factory did not return an object of type, ",type_name}, uvm_top) \
   endfunction


// uvm_component_factory_create_func
// ---------------------------------

`define uvm_component_factory_create_func(T) \
   function uvm_component create_component (string name, uvm_component parent); \
     T tmp; \
     tmp = new(.name(name), .parent(parent)); \
     return tmp; \
   endfunction \
   \
   static function T create(string name, uvm_component parent, string contxt=""); \
     uvm_factory f; \
     f = uvm_factory::get(); \
     if (contxt == "" && parent != null) \
       contxt = parent.get_full_name(); \
     if(!$cast(create,f.create_component_by_type(get(),contxt,name,parent))) \
        `uvm_report_fatal("FACTFL", {"Factory did not return a component of type, ",type_name}, uvm_top.) \
   endfunction


// uvm_get_type_name_func
// ----------------------

`define uvm_get_type_name_func(T) \
   const static string type_name = `"T`"; \
   virtual function string get_type_name (); \
     return type_name; \
   endfunction 


// uvm_object_derived_wrapper_class
// --------------------------------

//Requires S to be a constant string
`define uvm_object_registry(T,S) \
   typedef uvm_object_registry#(T,S) type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction 
//This is needed due to an issue in of passing down strings
//created by args to lower level macros.
`define uvm_object_registry_internal(T,S) \
   typedef uvm_object_registry#(T,`"S`") type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction 


// versions of the uvm_object_registry macros above which are to be used
// with parameterized classes

`define uvm_object_registry_param(T) \
   typedef uvm_object_registry #(T) type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction 


// uvm_component_derived_wrapper_class
// ---------------------------------

`define uvm_component_registry(T,S) \
   typedef uvm_component_registry #(T,S) type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction 
//This is needed due to an issue in of passing down strings
//created by args to lower level macros.
`define uvm_component_registry_internal(T,S) \
   typedef uvm_component_registry #(T,`"S`") type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction

// versions of the uvm_component_registry macros to be used with
// parameterized classes

`define uvm_component_registry_param(T) \
   typedef uvm_component_registry #(T) type_id; \
   static function type_id get_type(); \
     return type_id::get(); \
   endfunction \
   virtual function uvm_object_wrapper get_object_type(); \
     return type_id::get(); \
   endfunction


// uvm_print_msg_enum
// ------------------

`define uvm_print_msg_enum(LHS,RHS) \
  begin \
    uvm_comparer comparer; \
    comparer = uvm_auto_options_object.comparer; \
    if(comparer==null) comparer = uvm_default_comparer; \
    comparer.result++; \
/*    $swrite(comparer.miscompares,"%s%s: lhs = %s : rhs = %s\n",*/ \
/*       comparer.miscompares, comparer.scope.get_arg(), LHS, RHS );*/ \
    $swrite(comparer.miscompares,"%s%s: lhs = %0d : rhs = %0d\n", \
       comparer.miscompares, comparer.scope.get_arg(), LHS, RHS ); \
  end


// m_uvm_record_array_int
// --------------------

`define m_uvm_record_array_int(ARG, RADIX, RECORDER) \
  begin \
    if(RECORDER.tr_handle != 0) begin\
      if(RADIX == UVM_ENUM) begin \
        if(!m_sc.array_warning_done) begin \
           m_sc.array_warning_done = 1; \
           uvm_object::m_sc.scratch1 = \
             `"Recording not supported for array enumerations: ARG`"; \
           `uvm_warning_context("RCDNTS", uvm_object::m_sc.scratch1, _global_reporter) \
        end \
      end \
      else begin \
        for(int i__=0; i__<ARG.size(); ++i__) \
          RECORDER.record_field($psprintf(`"ARG[%0d]`",i__), ARG[i__], $bits(ARG[i__]), uvm_radix_enum'(RADIX)); \
      end \
    end \
  end


// m_uvm_record_array_object
// --------------------

`define m_uvm_record_array_object(ARG, RECORDER) \
  begin \
    if(RECORDER.tr_handle != 0) begin\
      uvm_object obj__; \
      for(int i__=0; i__<ARG.size(); ++i__) begin \
        if($cast(obj__, ARG[i__]))\
          if(obj__ != null) begin \
            m_sc.scope.down_element(i__, null);\
            obj__.m_field_automation(null, what__, str__); \
            m_sc.scope.up_element(null);\
          end \
      end \
    end \
  end


`define m_uvm_record_qda_int(ARG, FLAG, SZ) \
  begin \
    if(!(FLAG&UVM_NORECORD)) begin \
      int sz__ = SZ; \
      if(sz__ == 0) begin \
        m_sc.recorder.record_field("ARG.size()", 0, 32, UVM_DEC); \
      end \
      else if(sz__ < 10) begin \
        foreach(ARG[i]) begin \
           m_sc.scope.set_arg_element(`"ARG`",i); \
           m_sc.recorder.record_field(m_sc.scope.get(), ARG[i], $bits(ARG[i]), uvm_radix_enum'((FLAG)&UVM_RADIX)); \
        end \
      end \
      else begin \
        for(int i=0; i<5; ++i) begin \
           m_sc.scope.set_arg_element(`"ARG`", i); \
           m_sc.recorder.record_field(m_sc.scope.get(), ARG[i], $bits(ARG[i]), uvm_radix_enum'((FLAG)&UVM_RADIX)); \
        end \
        for(int i=sz__-5; i<sz__; ++i) begin \
           m_sc.scope.set_arg_element(`"ARG`", i); \
           m_sc.recorder.record_field(m_sc.scope.get(), ARG[i], $bits(ARG[i]), uvm_radix_enum'((FLAG)&UVM_RADIX)); \
        end \
      end \
    end \
  end


// m_uvm_record_qda_enum
// ---------------------

`define m_uvm_record_qda_enum(ARG, FLAG, SZ) \
  begin \
    if(!(FLAG&UVM_NORECORD) && (m_sc.recorder.tr_handle != 0)) begin \
      int sz__ = SZ; \
      if(sz__ == 0) begin \
        m_sc.recorder.record_field("ARG.size()", 0, 32, UVM_DEC); \
      end \
      else if(sz__ < 10) begin \
        foreach(ARG[i]) begin \
           m_sc.scope.set_arg_element(`"ARG`",i); \
           m_sc.recorder.record_string(m_sc.scope.get(), ARG[i].name()); \
        end \
      end \
      else begin \
        for(int i=0; i<5; ++i) begin \
           m_sc.scope.set_arg_element(`"ARG`", i); \
           m_sc.recorder.record_string(m_sc.scope.get(), ARG[i].name()); \
        end \
        for(int i=sz__-5; i<sz__; ++i) begin \
           m_sc.scope.set_arg_element(`"ARG`", i); \
           m_sc.recorder.record_string(m_sc.scope.get(), ARG[i].name()); \
        end \
      end \
    end \
  end


`define m_uvm_record_qda_object(ARG, FLAG, SZ) \
  begin \
    if(!(FLAG&UVM_NORECORD)) begin \
      int sz__ = SZ; \
      string s; \
      if(sz__ == 0 ) begin \
        m_sc.recorder.record_field("ARG.size()", 0, 32, UVM_DEC); \
      end \
      if(sz__ < 10) begin \
        foreach(ARG[i]) begin \
           $swrite(s,`"ARG[%0d]`", i); \
           m_sc.recorder.record_object(s, ARG[i]); \
        end \
      end \
      else begin \
        for(int i=0; i<5; ++i) begin \
           $swrite(s,`"ARG[%0d]`", i); \
           m_sc.recorder.record_object(s, ARG[i]); \
        end \
        for(int i=sz__-5; i<sz__; ++i) begin \
           $swrite(s,`"ARG[%0d]`", i); \
           m_sc.recorder.record_object(s, ARG[i]); \
        end \
      end \
    end \
  end

`define m_uvm_record_qda_string(ARG, FLAG, SZ) \
  begin \
    int sz__ = SZ; \
    if(!(FLAG&UVM_NORECORD)) begin \
      if(sz__ == 0) begin \
        m_sc.recorder.record_field("ARG.size()", 0, 32, UVM_DEC); \
      end \
      else if(sz__ < 10) begin \
        foreach(ARG[i]) begin \
           m_sc.scope.set_arg_element(`"ARG`",i); \
           m_sc.recorder.record_string(m_sc.scope.get(), ARG[i]); \
        end \
      end \
      else begin \
        for(int i=0; i<5; ++i) begin \
           m_sc.scope.set_arg_element(`"ARG`", i); \
           m_sc.recorder.record_string(m_sc.scope.get(), ARG[i]); \
        end \
        for(int i=sz__-5; i<sz__; ++i) begin \
           m_sc.scope.set_arg_element(`"ARG`", i); \
           m_sc.recorder.record_string(m_sc.scope.get(), ARG[i]); \
        end \
      end \
    end \
  end


// M_UVM_FIELD_DATA_AA_generic
// -------------------------

`define M_UVM_FIELD_DATA_AA_generic(TYPE, KEY, ARG, FLAG) \
  begin \
    if((what__ & (FLAG)) || (what__ >= UVM_MACRO_EXTRAS)) begin \
      case (what__) \
        UVM_COMPARE: \
           begin \
            if(!((FLAG)&UVM_NOCOMPARE) && (tmp_data__ != null) ) \
            begin \
              $cast(local_data__, tmp_data__); \
              if(ARG.num() != local_data__.ARG.num()) begin \
                 int s1__, s2__; \
                 m_sc.stringv = ""; \
                 s1__ = ARG.num(); s2__ = local_data__.ARG.num(); \
                 $swrite(m_sc.stringv, "lhs size = %0d : rhs size = %0d", \
                    s1__, s2__);\
                 m_sc.comparer.print_msg(m_sc.stringv); \
              end \
              string_aa_key = ""; \
              while(ARG.next(string_aa_key)) begin \
                m_sc.scope.set_arg({"[",string_aa_key,"]"}); \
                void'(m_do_data({`"ARG[`", string_aa_key, "]"}, \
                    ARG[string_aa_key], \
                    local_data__.ARG[string_aa_key], what__, \
                    $bits(ARG[string_aa_key]), FLAG)); \
                m_sc.scope.unset_arg(string_aa_key); \
              end \
            end \
           end \
        UVM_COPY: \
          begin \
            if(!((FLAG)&UVM_NOCOPY) && (tmp_data__ != null) ) \
            begin \
              $cast(local_data__, tmp_data__); \
              ARG.delete(); \
              string_aa_key = ""; \
              while(local_data__.ARG.next(string_aa_key)) \
                ARG[string_aa_key] = local_data__.ARG[string_aa_key]; \
            end \
          end \
        UVM_PRINT: \
          `uvm_print_aa_``KEY``_``TYPE``3(ARG, uvm_radix_enum'((FLAG)&(UVM_RADIX)), \
             m_sc.printer) \
      endcase \
    end \
  end


// M_UVM_FIELD_DATA_AA_int_string
// ----------------------------

`define M_UVM_FIELD_DATA_AA_int_string(ARG, FLAG) \
  `M_UVM_FIELD_DATA_AA_generic(int, string, ARG, FLAG)

// M_UVM_FIELD_DATA_AA_int_int
// ----------------------------

`define M_UVM_FIELD_DATA_AA_int_key(KEY, ARG, FLAG) \
  begin \
    if((what__ & (FLAG)) || (what__ >= UVM_MACRO_EXTRAS)) begin \
      KEY aa_key; \
      case (what__) \
        UVM_COMPARE: \
           begin \
            if(!((FLAG)&UVM_NOCOMPARE) && (tmp_data__ != null) ) \
            begin \
              $cast(local_data__, tmp_data__); \
              if(ARG.num() != local_data__.ARG.num()) begin \
                 int s1__, s2__; \
                 m_sc.stringv = ""; \
                 s1__ = ARG.num(); s2__ = local_data__.ARG.num(); \
                 $swrite(m_sc.stringv, "lhs size = %0d : rhs size = %0d", \
                    s1__, s2__);\
                 m_sc.comparer.print_msg(m_sc.stringv); \
              end \
              if(ARG.first(aa_key)) \
                do begin \
                  $swrite(string_aa_key, "%0d", aa_key); \
                  m_sc.scope.set_arg({"[",string_aa_key,"]"}); \
                  void'(m_do_data({`"ARG[`", string_aa_key, "]"}, \
                    ARG[aa_key], \
                    local_data__.ARG[aa_key], what__, \
                    $bits(ARG[aa_key]), FLAG)); \
                  m_sc.scope.unset_arg(string_aa_key); \
                end while(ARG.next(aa_key)); \
            end \
           end \
        UVM_COPY: \
          begin \
            if(!((FLAG)&UVM_NOCOPY) && (tmp_data__ != null) ) \
            begin \
              $cast(local_data__, tmp_data__); \
              ARG.delete(); \
              if(local_data__.ARG.first(aa_key)) \
                do begin \
                  ARG[aa_key] = local_data__.ARG[aa_key]; \
                end while(local_data__.ARG.next(aa_key)); \
            end \
          end \
        UVM_PRINT: \
          `uvm_print_aa_int_key4(KEY,ARG, uvm_radix_enum'((FLAG)&(UVM_RADIX)), \
             m_sc.printer) \
      endcase \
    end \
  end


// M_UVM_FIELD_DATA_AA_enum_key
// ----------------------------

`define M_UVM_FIELD_DATA_AA_enum_key(KEY, ARG, FLAG) \
  begin \
    if((what__ & (FLAG)) || (what__ >= UVM_MACRO_EXTRAS)) begin \
      KEY aa_key; \
      case (what__) \
        UVM_COMPARE: \
           begin \
            if(!((FLAG)&UVM_NOCOMPARE) && (tmp_data__ != null) ) \
            begin \
              $cast(local_data__, tmp_data__); \
              if(ARG.num() != local_data__.ARG.num()) begin \
                 int s1__, s2__; \
                 m_sc.stringv = ""; \
                 s1__ = ARG.num(); s2__ = local_data__.ARG.num(); \
                 $swrite(m_sc.stringv, "lhs size = %0d : rhs size = %0d", \
                    s1__, s2__);\
                 m_sc.comparer.print_msg(m_sc.stringv); \
              end \
              if(ARG.first(aa_key)) \
                do begin \
                  void'(m_sc.comparer.compare_field_int({`"ARG[`",aa_key.name(),"]"}, \
                    ARG[aa_key], local_data__.ARG[aa_key], $bits(ARG[aa_key]), \
                    uvm_radix_enum'((FLAG)&UVM_RADIX) )); \
                end while(ARG.next(aa_key)); \
            end \
           end \
        UVM_COPY: \
          begin \
            if(!((FLAG)&UVM_NOCOPY) && (tmp_data__ != null) ) \
            begin \
              $cast(local_data__, tmp_data__); \
              ARG.delete(); \
              if(local_data__.ARG.first(aa_key)) \
                do begin \
                  ARG[aa_key] = local_data__.ARG[aa_key]; \
                end while(local_data__.ARG.next(aa_key)); \
            end \
          end \
        UVM_PRINT: \
          begin \
            uvm_printer p__ = m_sc.printer; \
            p__.print_array_header (`"ARG`", ARG.num(),`"aa_``KEY`"); \
            if((p__.knobs.depth == -1) || (m_sc.printer.m_scope.depth() < p__.knobs.depth+1)) \
            begin \
              if(ARG.first(aa_key)) \
                do begin \
                  m_sc.printer.print_field( \
                    {"[",aa_key.name(),"]"}, ARG[aa_key], $bits(ARG[aa_key]), \
                    uvm_radix_enum'((FLAG)&UVM_RADIX), "[" ); \
                end while(ARG.next(aa_key)); \
            end \
            p__.print_array_footer(ARG.num()); \
            p__.print_footer(); \
          end \
      endcase \
    end \
  end 

// M_UVM_FIELD_DATA_AA_object_string
// -------------------------------

`define M_UVM_FIELD_DATA_AA_object_string(ARG, FLAG) \
  begin \
    if((what__ & (FLAG)) || (what__ >= UVM_MACRO_EXTRAS)) begin \
      case (what__) \
        UVM_COMPARE: \
           begin \
            if(!((FLAG)&UVM_NOCOMPARE) && (tmp_data__ != null) ) \
            begin \
              $cast(local_data__, tmp_data__); \
              if(ARG.num() != local_data__.ARG.num()) begin \
                 int s1__, s2__; \
                 m_sc.stringv = ""; \
                 s1__ = ARG.num(); s2__ = local_data__.ARG.num(); \
                 $swrite(m_sc.stringv, "lhs size = %0d : rhs size = %0d", \
                          s1__, s2__);\
                 m_sc.comparer.print_msg(m_sc.stringv); \
              end \
              string_aa_key = ""; \
              while(ARG.next(string_aa_key)) begin \
                uvm_object tmp; \
                /* Since m_do_data_object is inout, need a uvm_object for */ \
                /* assignment compatibility. We must cast back the return. */ \
                tmp = ARG[string_aa_key]; \
                m_sc.scope.down({"[",string_aa_key,"]"}); \
                void'(m_do_data_object({"[", string_aa_key, "]"}, tmp, \
                    local_data__.ARG[string_aa_key], what__, FLAG)); \
                m_sc.scope.up_element(); \
              end \
            end \
          end \
        UVM_COPY: \
          begin \
           if(!((FLAG)&UVM_NOCOPY) && (tmp_data__ != null) ) \
           begin \
            $cast(local_data__, tmp_data__); \
            ARG.delete(); \
            if(local_data__.ARG.first(string_aa_key)) \
             do \
               if((FLAG)&UVM_REFERENCE) \
                ARG[string_aa_key] = local_data__.ARG[string_aa_key]; \
             /*else if((FLAG)&UVM_SHALLOW)*/ \
             /* ARG[string_aa_key] = new local_data__.ARG[string_aa_key];*/ \
               else begin\
                $cast(ARG[string_aa_key],local_data__.ARG[string_aa_key].clone());\
                ARG[string_aa_key].set_name({`"ARG`","[",string_aa_key, "]"});\
               end \
             while(local_data__.ARG.next(string_aa_key)); \
           end \
          end \
        UVM_PRINT: \
          `uvm_print_aa_string_object3(ARG, m_sc.printer,FLAG) \
      endcase \
    end \
  end

// M_UVM_FIELD_DATA_AA_object_int
// -------------------------------

`define M_UVM_FIELD_DATA_AA_object_int(ARG, FLAG) \
  begin \
    int key__; \
    if((what__ & (FLAG)) || (what__ >= UVM_MACRO_EXTRAS)) begin \
      case (what__) \
        UVM_COMPARE: \
           begin \
            if(!((FLAG)&UVM_NOCOMPARE) && (tmp_data__ != null) ) \
            begin \
              $cast(local_data__, tmp_data__); \
              if(ARG.num() != local_data__.ARG.num()) begin \
                 int s1__, s2__; \
                 m_sc.stringv = ""; \
                 s1__ = ARG.num(); s2__ = local_data__.ARG.num(); \
                 $swrite(m_sc.stringv, "lhs size = %0d : rhs size = %0d", \
                          s1__, s2__);\
                 m_sc.comparer.print_msg(m_sc.stringv); \
              end \
              if(ARG.first(key__)) begin \
                do begin \
                  uvm_object tmp__; \
                  /* Since m_do_data_object is inout, need a uvm_object for */ \
                  /* assignment compatibility. We must cast back the return. */ \
                  tmp__ = ARG[key__]; \
                  $swrite(m_sc.stringv, "[%0d]", key__); \
                  m_sc.scope.down_element(key__); \
                  void'(m_do_data_object(m_sc.stringv, tmp__, \
                      local_data__.ARG[key__], what__, FLAG)); \
                  m_sc.scope.up_element(); \
                end while(ARG.next(key__)); \
              end \
            end \
          end \
        UVM_COPY: \
          begin \
           if(!((FLAG)&UVM_NOCOPY) && (tmp_data__ != null) ) \
           begin \
            $cast(local_data__, tmp_data__); \
            ARG.delete(); \
            if(local_data__.ARG.first(key__)) \
             do begin \
               if((FLAG)&UVM_REFERENCE) \
                ARG[key__] = local_data__.ARG[key__]; \
             /*else if((FLAG)&UVM_SHALLOW)*/ \
             /* ARG[key__] = new local_data__.ARG[key__];*/ \
               else begin\
                 uvm_object tmp_obj; \
                 tmp_obj = local_data__.ARG[key__].clone(); \
                 if(tmp_obj != null) \
                   $cast(ARG[key__], tmp_obj); \
                 else \
                   ARG[key__]=null; \
               end \
             end while(local_data__.ARG.next(key__)); \
           end \
         end \
        UVM_PRINT: \
          `uvm_print_aa_int_object3(ARG, m_sc.printer,FLAG) \
      endcase \
    end \
  end

// M_UVM_FIELD_DATA_AA_string_string
// -------------------------------

`define M_UVM_FIELD_DATA_AA_string_string(ARG, FLAG) \
  begin \
    if((what__ & (FLAG)) || (what__ >= UVM_MACRO_EXTRAS)) begin \
      case (what__) \
        UVM_COMPARE: \
           begin \
            if(!((FLAG)&UVM_NOCOMPARE) && (tmp_data__ != null) ) \
            begin \
              $cast(local_data__, tmp_data__); \
              if(ARG.num() != local_data__.ARG.num()) begin \
                 int s1__, s2__; \
                 m_sc.stringv = ""; \
                 s1__ = ARG.num(); s2__ = local_data__.ARG.num(); \
                 $swrite(m_sc.stringv, "lhs size = %0d : rhs size = %0d", \
                    s1__, s2__);\
                 m_sc.comparer.print_msg(m_sc.stringv); \
              end \
              string_aa_key = ""; \
              while(ARG.next(string_aa_key)) begin \
                m_sc.scope.set_arg({"[",string_aa_key,"]"}); \
                void'(m_do_data_string({`"ARG[`", string_aa_key, "]"}, \
                    ARG[string_aa_key], \
                    local_data__.ARG[string_aa_key], what__, FLAG) ); \
                m_sc.scope.unset_arg(string_aa_key); \
              end \
            end \
           end \
        UVM_COPY: \
          begin \
            if(!((FLAG)&UVM_NOCOPY) && (local_data__ !=null)) \
            begin \
              ARG.delete(); \
              string_aa_key = ""; \
              while(local_data__.ARG.next(string_aa_key)) \
                ARG[string_aa_key] = local_data__.ARG[string_aa_key]; \
            end \
          end \
        UVM_PRINT: \
          `uvm_print_aa_string_string2(ARG, m_sc.printer) \
      endcase \
    end \
  end


`define M_UVM_FIELD_SET_AA_TYPE(INDEX_TYPE, ARRAY_TYPE, ARRAY, RHS, FLAG) \
  if((what__ >= UVM_START_FUNCS && what__ <= UVM_END_FUNCS) && (((FLAG)&UVM_READONLY) == 0)) begin \
    bit wildcard_index__; \
    INDEX_TYPE index__; \
    index__ = uvm_get_array_index_``INDEX_TYPE(str__, wildcard_index__); \
    if(what__==UVM_SET``ARRAY_TYPE) \
    begin \
      if(uvm_is_array(str__) ) begin\
        if(wildcard_index__) begin \
          if(ARRAY.first(index__)) \
          do begin \
            if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)}) ||  \
               uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0s]", index__)})) begin \
              ARRAY[index__] = RHS; \
              m_sc.status = 1; \
            end \
          end while(ARRAY.next(index__));\
        end \
        else if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)})) begin \
          ARRAY[index__] = RHS; \
          m_sc.status = 1; \
        end \
        else if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0s]", index__)})) begin \
          ARRAY[index__] = RHS; \
          m_sc.status = 1; \
        end \
      end \
    end \
 end

`define M_UVM_FIELD_SET_AA_OBJECT_TYPE(INDEX_TYPE, ARRAY, FLAG) \
  if((what__ >= UVM_START_FUNCS && what__ <= UVM_END_FUNCS) && (((FLAG)&UVM_READONLY) == 0)) begin \
    bit wildcard_index__; \
    INDEX_TYPE index__; \
    index__ = uvm_get_array_index_``INDEX_TYPE(str__, wildcard_index__); \
    if(what__==UVM_SETOBJ) \
    begin \
      if(uvm_is_array(str__) ) begin\
        if(wildcard_index__) begin \
          if(ARRAY.first(index__)) \
          do begin \
            if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)}) || \
               uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0s]", index__)})) begin \
              if (m_sc.object != null) \
                $cast(ARRAY[index__], m_sc.object); \
              m_sc.status = 1; \
            end \
          end while(ARRAY.next(index__));\
        end \
        else if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)})) begin \
          if (m_sc.object != null) \
            $cast(ARRAY[index__], m_sc.object); \
          m_sc.status = 1; \
        end \
        else if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0s]", index__)})) begin \
          if (m_sc.object != null) \
            $cast(ARRAY[index__], m_sc.object); \
          m_sc.status = 1; \
        end \
      end \
    end \
 end

`define M_UVM_FIELD_SET_AA_INT_TYPE(INDEX_TYPE, ARRAY_TYPE, ARRAY, RHS, FLAG) \
  if((what__ >= UVM_START_FUNCS && what__ <= UVM_END_FUNCS) && (((FLAG)&UVM_READONLY) == 0)) begin \
    bit wildcard_index__; \
    INDEX_TYPE index__; \
    string idx__; \
    index__ = uvm_get_array_index_int(str__, wildcard_index__); \
    if(what__==UVM_SET``ARRAY_TYPE) \
    begin \
      if(uvm_is_array(str__) ) begin\
        if(wildcard_index__) begin \
          if(ARRAY.first(index__)) \
          do begin \
            $swrite(idx__, m_sc.scope.get(), "[", index__, "]"); \
            if(uvm_is_match(str__, idx__)) begin \
              ARRAY[index__] = RHS; \
              m_sc.status = 1; \
            end \
          end while(ARRAY.next(index__));\
        end \
        else if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)})) begin \
          ARRAY[index__] = RHS; \
          m_sc.status = 1; \
        end  \
      end \
    end \
 end


`define M_UVM_FIELD_SET_AA_INT_ENUMTYPE(INDEX_TYPE, ARRAY_TYPE, ARRAY, RHS, FLAG) \
  if((what__ >= UVM_START_FUNCS && what__ <= UVM_END_FUNCS) && (((FLAG)&UVM_READONLY) == 0)) begin \
    bit wildcard_index__; \
    INDEX_TYPE index__; \
    string idx__; \
    index__ = INDEX_TYPE'(uvm_get_array_index_int(str__, wildcard_index__)); \
    if(what__==UVM_SET``ARRAY_TYPE) \
    begin \
      if(uvm_is_array(str__) ) begin\
        if(wildcard_index__) begin \
          if(ARRAY.first(index__)) \
          do begin \
            $swrite(idx__, m_sc.scope.get(), "[", index__, "]"); \
            if(uvm_is_match(str__, idx__)) begin \
              ARRAY[index__] = RHS; \
              m_sc.status = 1; \
            end \
          end while(ARRAY.next(index__));\
        end \
        else if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)})) begin \
          ARRAY[index__] = RHS; \
          m_sc.status = 1; \
        end  \
      end \
    end \
 end


/*
`define M_UVM_FIELD_SET_ARRAY_TYPE(ARRAY_TYPE, ARRAY, RHS, FLAG) \
  if((what__ >= UVM_START_FUNCS && what__ <= UVM_END_FUNCS) && (((FLAG)&UVM_READONLY) == 0)) begin \
    int index__; \
    bit wildcard_index__; \
    index__ = uvm_get_array_index_int(str__, wildcard_index__); \
    if(what__==UVM_SET``ARRAY_TYPE) \
    begin \
      if(uvm_is_array(str__) ) begin\
        if(wildcard_index__) begin \
          for(int index__=0; index__<ARRAY.size(); ++index__) begin \
            if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)})) begin \
              ARRAY[index__] = RHS; \
              m_sc.status = 1; \
            end \
          end \
        end \
        else if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)})) begin \
          ARRAY[index__] = RHS; \
          m_sc.status = 1; \
        end \
        else if(what__==UVM_SET && uvm_is_match(str__, m_sc.scope.get())) begin \
          int size__; \
          size__ = m_sc.bitstream; \
          ARRAY = new[size__](ARRAY); \
          m_sc.status = 1; \
        end \
      end \
      else if(what__==UVM_SET && uvm_is_match(str__, m_sc.scope.get())) begin \
        int size__; \
        size__ = m_sc.bitstream; \
        ARRAY = new[size__](ARRAY); \
        m_sc.status = 1; \
      end \
    end \
    else if(what__==UVM_SET && uvm_is_match(str__, m_sc.scope.get())) begin \
     int size__; \
     size__ = m_sc.bitstream; \
     ARRAY = new[size__](ARRAY); \
     m_sc.status = 1; \
    end \
 end

`define M_UVM_FIELD_SET_ARRAY_ENUM(T, ARRAY, RHS, FLAG) \
  if((what__ >= UVM_START_FUNCS && what__ <= UVM_END_FUNCS) && (((FLAG)&UVM_READONLY) == 0)) begin \
    int index__; \
    bit wildcard_index__; \
    index__ = uvm_get_array_index_int(str__, wildcard_index__); \
    if(what__==UVM_SETINT) \
    begin \
      if(uvm_is_array(str__) ) begin\
        if(wildcard_index__) begin \
          for(int index__=0; index__<ARRAY.size(); ++index__) begin \
            if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)})) begin \
              ARRAY[index__] = T'(RHS); \
              m_sc.status = 1; \
            end \
          end \
        end \
        else if(uvm_is_match(str__, {m_sc.scope.get(),$psprintf("[%0d]", index__)})) begin \
          ARRAY[index__] = T'(RHS); \
          m_sc.status = 1; \
        end \
        else if(what__==UVM_SET && uvm_is_match(str__, m_sc.scope.get())) begin \
          int size__; \
          size__ = m_sc.bitstream; \
          ARRAY = new[size__](ARRAY); \
          m_sc.status = 1; \
        end \
      end \
      else if(what__==UVM_SET && uvm_is_match(str__, m_sc.scope.get())) begin \
        int size__; \
        size__ = m_sc.bitstream; \
        ARRAY = new[size__](ARRAY); \
        m_sc.status = 1; \
      end \
    end \
    else if(what__==UVM_SET && uvm_is_match(str__, m_sc.scope.get())) begin \
     int size__; \
     size__ = m_sc.bitstream; \
     ARRAY = new[size__](ARRAY); \
     m_sc.status = 1; \
    end \
 end
 */


`endif //UVM_EMPTY_MACROS

`endif  // UVM_OBJECT_DEFINES_SVH

