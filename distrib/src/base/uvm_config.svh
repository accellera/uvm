//
//----------------------------------------------------------------------
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
//----------------------------------------------------------------------

`ifndef UVM_CONFIG_SVH
`define UVM_CONFIG_SVH

typedef class uvm_component;

virtual class uvm_config_setting;
  typedef enum { UVM_UNDEFINED_TYPE, UVM_STRING_TYPE, UVM_INT_TYPE, UVM_OBJECT_TYPE } uvm_config_type ;
  extern         function                 new              (string        inst, 
                                                            string        field, 
                                                            uvm_component from);
  extern         function bit             component_match  (uvm_component to);
  pure   virtual function string          value_string     ();
  pure   virtual function string          type_string      ();
  pure   virtual function uvm_config_type get_value_type   (); 
  extern         function bit             field_match      (string to);
  extern virtual function void            print_match      (uvm_component to, 
                                                            uvm_component from, 
                                                            string        field);

  extern         function void            set_override     (uvm_config_setting ov);
  extern         function void            set_used         (uvm_component      used);

  extern virtual function string          convert2string    ();
  extern         function uvm_component   get_from_component();
  extern         function void            get_to_list       (ref uvm_component list[$]);
  extern         function void            get_override_list (ref uvm_config_setting list[$]);
  extern         function int             num_overrides     ();
  extern         function int             num_used          ();

  extern         function string          unused_message    ();
  extern         function string          overridden_message();
  extern         function string          applied_message   ();

  extern virtual function string matches_string(uvm_component to, 
                                                uvm_component from);

  //These are private fields but uvm_component needs access to
  //them. Since SystemVerilog doesn't have a friend concept need to make
  //them public.
            string             m_inst;
            string             m_field;
            uvm_component      m_from;
            uvm_component      m_used_list[$];
            uvm_config_setting m_override_list[$];
            bit                m_inst_wildcard=0;
            bit                m_field_wildcard=0;
endclass

class uvm_int_config_setting extends uvm_config_setting;
  extern         function        new             (string          inst, 
                                                  string          field, 
                                                  uvm_bitstream_t value, 
                                                  uvm_component   from);
  extern virtual function string matches_string(uvm_component to, 
                                                uvm_component from);
  extern virtual function string value_string    ();
  extern virtual function string type_string     ();
  extern virtual function uvm_config_type get_value_type (); 

  //Internal field but access needed by uvm_component
  uvm_bitstream_t m_value;
endclass

class uvm_string_config_setting extends uvm_config_setting;
  extern         function        new             (string          inst, 
                                                  string          field, 
                                                  string          value, 
                                                  uvm_component   from);
  extern virtual function string matches_string(uvm_component to, 
                                                uvm_component from);
  extern virtual function string value_string    ();
  extern virtual function string type_string     ();
  extern virtual function uvm_config_type get_value_type (); 

  //Internal field but access needed by uvm_component
  string m_value;
endclass

class uvm_object_config_setting extends uvm_config_setting;
  extern function                new             (string inst, 
                                                  string field, 
                                                  uvm_object value, 
                                                  uvm_component from, 
                                                  bit clone);
  extern virtual function string matches_string(uvm_component to, 
                                                uvm_component from);
  extern virtual function string value_string    ();
  extern virtual function string type_string     ();
  extern virtual function uvm_config_type get_value_type (); 

  //Internal field but access needed by uvm_component
  uvm_object m_value;
  bit        m_clone;
endclass

`endif // UVM_CONFIG_SVH
