// 
// -------------------------------------------------------------
//    Copyright 2009-2010 Synopsys, Inc.
//    All Rights Reserved Worldwide
//
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 

typedef uvm_object uvm_tlm_extension;
typedef class uvm_sequence_item;


class uvm_tlm_gp extends uvm_sequence_item;

   typedef enum {TLM_READ_COMMAND   = 0,
		 TLM_WRITE_COMMAND  = 1,
    	         TLM_IGNORE_COMMAND = 2
                 } tlm_command;

   typedef enum {TLM_OK_RESPONSE                = 1,
                 TLM_INCOMPLETE_RESPONSE        = 0,
                 TLM_GENERIC_ERROR_RESPONSE     = -1,
                 TLM_ADDRESS_ERROR_RESPONSE     = -2,
                 TLM_COMMAND_ERROR_RESPONSE     = -3,
                 TLM_BURST_ERROR_RESPONSE       = -4,
                 TLM_BYTE_ENABLE_ERROR_RESPONSE = -5
                 } tlm_response_status; 

   rand longint              m_address; 
   rand tlm_command          m_command;  
   rand byte                 m_data[]; 
   local tlm_response_status m_response_status;
   rand bit                  m_byte_enable[]; 

   rand int unsigned         m_streaming_width;

   local uvm_tlm_extension   m_extensions[string];
    
   `uvm_object_utils_begin(uvm_tlm_gp)
      `uvm_field_int(m_address, UVM_ALL_ON)
      `uvm_field_enum(tlm_command, m_command, UVM_ALL_ON)
      `uvm_field_array_int(m_data, UVM_ALL_ON)
      `uvm_field_enum(tlm_response_status, m_response_status, UVM_ALL_ON)
      `uvm_field_array_int(m_byte_enable, UVM_ALL_ON)
      `uvm_field_int(m_streaming_width, UVM_ALL_ON)
      `uvm_field_aa_object_string(m_extensions, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "");
      super.new(name);
   endfunction	

   function  tlm_command get_command() ;
      return m_command ;
   endfunction: get_command

   function void set_command(tlm_command lcmd) ;
      m_command = lcmd ;
   endfunction: set_command

   function bit is_read () ;
      return this.m_command == uvm_tlm_gp::TLM_READ_COMMAND;
   endfunction: is_read

   function void set_read() ;
      m_command = uvm_tlm_gp::TLM_READ_COMMAND ;
   endfunction: set_read

   function bit is_write () ;
      return this.m_command == uvm_tlm_gp::TLM_WRITE_COMMAND;
   endfunction: is_write

   function void set_write() ;
      m_command = uvm_tlm_gp::TLM_WRITE_COMMAND ;
   endfunction: set_write

   function longint get_address() ;
      return m_address ;
   endfunction: get_address

   function void set_address(longint laddr) ;
      m_address = laddr ;
   endfunction: set_address

    function void get_data (ref byte data[]) ;
       data = m_data ;
    endfunction: get_data

    function void set_data(ref byte data[]) ;
       m_data = data ;
    endfunction: set_data
    
   function int unsigned get_data_length() ;
      return m_data.size() ;
   endfunction: get_data_length


   function int unsigned get_streaming_width() ;
      return m_streaming_width ;
   endfunction: get_streaming_width

   function void set_streaming_width(int unsigned lbel) ;
      m_streaming_width = lbel ;
   endfunction: set_streaming_width

    function void get_byte_enable (ref bit be[]) ;
       be = m_byte_enable ;
    endfunction: get_byte_enable

    function void set_byte_enable (ref bit be[]) ;
       m_byte_enable = be ;
    endfunction: set_byte_enable

   function int unsigned get_byte_enable_length() ;
      return m_byte_enable.size() ;
   endfunction: get_byte_enable_length


   function tlm_response_status get_response_status() ;
      return m_response_status ;
   endfunction: get_response_status

   function void set_response_status(tlm_response_status lrs) ;
      m_response_status = lrs ;
   endfunction: set_response_status

   function string get_response_string() ;
      return m_response_status.name() ;
   endfunction: get_response_string

   function bit is_response_ok() ;
      return m_response_status == uvm_tlm_gp::TLM_OK_RESPONSE;
   endfunction: is_response_ok

   function bit is_response_error() ;
      return m_response_status != uvm_tlm_gp::TLM_OK_RESPONSE;
   endfunction: is_response_error


   function uvm_tlm_extension set_extension(uvm_tlm_extension ext, string key = "");
      if (key == "") key = ext.get_type_name();
      if (m_extensions.exists(key)) set_extension = m_extensions[key];
      else set_extension = null;
      m_extensions[key] = ext;
   endfunction: set_extension

   function int get_num_extensions();
      return m_extensions.num();
   endfunction: get_num_extensions
   
   function uvm_tlm_extension get_extension(string key);
      if (!m_extensions.exists(key)) return null;
      return m_extensions[key];
   endfunction: get_extension
   
   function void clear_extension(string key);
      if (!m_extensions.exists(key)) return;
      m_extensions.delete(key);
   endfunction: clear_extension

   function void clear_extensions();
      m_extensions.delete();
   endfunction: clear_extensions

endclass: uvm_tlm_gp

typedef uvm_tlm_gp uvm_tlm_generic_payload;
