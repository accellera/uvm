//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2011 Mentor Graphics Corporation
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

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_class extends uvm_object;
  int foo = 3;
  string bar = "hi there";
  `uvm_object_utils_begin(my_class)
    `uvm_field_int(foo, UVM_ALL_ON | UVM_DEC)
    `uvm_field_string(bar, UVM_ALL_ON)
  `uvm_object_utils_end
  function new (string name = "unnamed-my_class");
    super.new(name);
  endfunction
endclass

class my_catcher extends uvm_report_catcher;
  virtual function action_e catch();
    my_class my_object;
    uvm_report_message_element_base elements[$];
    uvm_report_message_element_container container = get_element_container();

    elements = container.get_elements();
    foreach (elements[idx]) begin
      uvm_report_message_object_element o_e;

      if ($cast(o_e, elements[idx])) begin
        if (o_e.get_name() == "my_obj" && $cast(my_object, o_e.get_value())) begin
          if (my_object.foo == 3)
            container.delete(idx);
        end
      end
    end

    return THROW;
  endfunction
endclass

class my_server extends uvm_default_report_server;
  virtual function string compose_report_message(uvm_report_message report_message, string report_object_name = "");
    uvm_report_message_element_base elements[$];
    uvm_report_message_element_container container = report_message.get_element_container();

    elements = container.get_elements();
    foreach (elements[idx]) begin
      uvm_report_message_string_element s_e;

      if ($cast(s_e, elements[idx])) begin
        if (s_e.get_name() == "my_color" && s_e.get_value() == "red")
          container.delete(idx);
      end
    end

    compose_report_message = super.compose_report_message(report_message, report_object_name);
  endfunction
endclass

class my_handler extends uvm_report_handler;
  `uvm_object_utils(my_handler)

  function new(string name = "my_report_handler");
    super.new(name);
  endfunction

  virtual function void process_report_message(uvm_report_message report_message);
    uvm_report_message_element_base elements[$];
    uvm_report_message_element_container container = report_message.get_element_container();

    elements = container.get_elements();
    foreach (elements[idx]) begin
      uvm_report_message_string_element s_e;

      if ($cast(s_e, elements[idx])) begin
        if (s_e.get_name() == "my_string" && s_e.get_value() == "foo")
          container.delete(idx);
      end
    end

    super.process_report_message(report_message);
  endfunction
endclass



class test extends uvm_test;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent = null);
     super.new(name, parent);
  endfunction

  virtual function void uvm_process_report_message(uvm_report_message report_message);
    uvm_report_message_element_base elements[$];
    uvm_report_message_element_container container = report_message.get_element_container();
    int size;
    uvm_radix_enum radix;

    elements = container.get_elements();
    foreach (elements[idx]) begin
      uvm_report_message_int_element i_e;
      if ($cast(i_e, elements[idx])) begin
        if (i_e.get_name() == "my_int" && i_e.get_value(size, radix) == 5)
          container.delete(idx);
      end
    end

    super.uvm_process_report_message(report_message);
  endfunction


  virtual task run_phase(uvm_phase phase);
    int my_int;
    string my_string;
    my_class my_obj;

    phase.raise_objection(this);

    my_int = 5;
    my_string = "foo";
    my_obj = new("my_obj");

    $display("START OF GOLD FILE");
    `uvm_info_begin("TEST", "Testing message...", UVM_LOW)
    `uvm_message_add_tag("my_color", "red")
    `uvm_message_add_int(my_int, UVM_DEC,"",UVM_LOG)
    `uvm_message_add_string(my_string,UVM_LOG|UVM_RM_RECORD)
    `uvm_message_add_object(my_obj)
    `uvm_info_end
    $display("END OF GOLD FILE");

    phase.drop_objection(this);
  endtask

endclass

initial begin
     static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

     static uvm_factory fact = cs_.get_factory();
     static my_server server = new();
     static my_catcher catcher = new();
     uvm_report_cb::add(null, catcher);
     uvm_report_server::set_server(server);
     fact.set_type_override_by_type(uvm_report_handler::get_type(), my_handler::get_type());
     fact.print();

     run_test();
  end

endprogram
