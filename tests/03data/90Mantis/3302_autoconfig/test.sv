//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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
//------------------------------------------------------------------------------

`include "uvm_macros.svh"




module test();

  import uvm_pkg::*;

class my_object extends uvm_object;
  int field;
  string msg;
  
  
  `uvm_object_utils_begin(my_object);
  `uvm_field_int(field,UVM_PRINT)
  `uvm_field_string(msg,UVM_PRINT)
  `uvm_object_utils_end

  function new(string name="my_object");
     super.new(name);
  endfunction

endclass
  
class my_component extends uvm_component;
  my_object object,object2;
  my_object array[2];
  
  `uvm_component_utils_begin(my_component)
    `uvm_field_object(object,UVM_ALL_ON)
    `uvm_field_object(object2,UVM_ALL_ON)
    `uvm_field_sarray_object(array,UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name,parent);

    object = my_object::type_id::create("object");
    object2 = my_object::type_id::create("object");
    array[0] = my_object::type_id::create("array[0]");
    array[1] = my_object::type_id::create("array[1]");
    
  endfunction

  function void build();
    super.build();
  endfunction

endclass


  
class test extends uvm_test;
  `uvm_component_utils(test)

  my_component component;
  int object_field, array_field;
  string object_msg, array_msg;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build();
    super.build();
    component = my_component::type_id::create("component",this);
    
    // Works
    object_field = 'hbe;
    set_config_int("component","object.field",object_field);

    // Works
    object_msg = "goodbye";
    set_config_string("component","object.msg",object_msg);

    // Didn't work
    array_field = 'h7a;
    set_config_int("component","array[0].field",array_field);

    // Didn't work
    array_msg = "hello";
    set_config_string("component","array[1].msg",array_msg);

  endfunction

  function void end_of_elaboration();
    bit failed = 0;
    if( component.object.field != object_field ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.object.field == %0h, but saw %0h",
                           object_field, component.object.field) )
    end


    if( component.object.msg != object_msg ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.object.msg == %s, but saw %s",
                           object_msg, component.object.msg) )
    end


    if( component.array[0].field != array_field ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array[0].field == %0h, but saw %0h",
                           array_field, component.array[0].field) )
    end

    if( component.array[1].msg != array_msg ) begin
      failed = 1;
      `uvm_error(get_type_name(),
                 $sformatf("expected component.array[1].msg == %s, but saw %s",
                           array_msg, component.array[1].msg) )
    end

    if (!failed) begin
      $display("*** UVM TEST PASSED ***");
    end
    else begin
      $display("*** UVM TEST FAILED ***");
    end

    uvm_top.print_topology();
  endfunction

endclass

  initial run_test("test");
  
endmodule
  
