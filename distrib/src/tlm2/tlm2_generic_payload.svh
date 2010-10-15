//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
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
// Generic Payload
//----------------------------------------------------------------------

`define TLM_ADDR_SIZE 64
const int unsigned addr_size = `TLM_ADDR_SIZE;
typedef bit[`TLM_ADDR_SIZE-1:0] tlm_addr_t;

typedef enum
{
    TLM_READ_COMMAND,
    TLM_WRITE_COMMAND,
    TLM_IGNORE_COMMAND
} tlm_command_e;

typedef enum
{
    TLM_OK_RESPONSE = 1,
    TLM_INCOMPLETE_RESPONSE = 0,
    TLM_GENERIC_ERROR_RESPONSE = -1,
    TLM_ADDRESS_ERROR_RESPONSE = -2,
    TLM_COMMAND_ERROR_RESPONSE = -3,
    TLM_BURST_ERROR_RESPONSE = -4,
    TLM_BYTE_ENABLE_ERROR_RESPONSE = -5
} tlm_response_status_e;

//----------------------------------------------------------------------
// TLM extensions
//----------------------------------------------------------------------

// class: tlm_extension_base
//
// The class tlm_extension_base is the non-parameerized base class for
// all generic payload extensions.  It includes the utility do_copy()
// and create().  The pure virtual function get_type_handle() allows you
// to get a unique handles that represents the derived type.  This is
// implemented in derived classes.
virtual class tlm_extension_base extends uvm_object;

  // function: new
  //
  // creates a new extension object.  Since this class is virtual this
  // function is always called from the constructor of the derived class
  // and not directly.

  function new(string name = "");
    super.new(name);
  endfunction

  // function: get_type_handle
  //
  // An interface to polymorphically retrieve a handle that uniquely
  // identifies the type of the sub-class

  pure virtual function tlm_extension_base get_type_handle();

  function void do_copy(uvm_object rhs);
    super.do_copy(rhs);
  endfunction

  function uvm_object create (string name="");
    tlm_extension_base t = new(name);
    return t;
  endfunction

endclass

//----------------------------------------------------------------------
// class: tlm_extension#(T)
//

// TLM extension class. The class is parameterized with arbitrary type
// which represents the type of the extension. An instance of the
// generic payload can contain one extension object of each type; it
// cannot contain two instances of the same extension type.  An
// extension object can identify its type vial the static variable
// my_type.  The function get_type() provides an interface to retrieve
// the type handle.
//
// You can derive a new class from this class to contain any arbitry
// data or code required for an extension.
//----------------------------------------------------------------------

class tlm_extension #(type T=int) extends tlm_extension_base;

  typedef tlm_extension#(T) this_type;

  static this_type my_type = get_type();

  function new(string name="");
    super.new(name);
  endfunction

  static function this_type get_type();
    if(my_type == null)
      my_type = new();
    return my_type;
  endfunction

  function tlm_extension_base get_type_handle();
    return get_type();
  endfunction

  function void do_copy(uvm_object rhs);
    super.do_copy(rhs);
  endfunction

  function uvm_object create (string name="");
    this_type t = new(name);
    return t;
  endfunction

endclass

//----------------------------------------------------------------------
// class: tlm_generic_payload
//
// This class provides a transaction architecture commonly used in
// memory-mapped bus-based systems.  It's intended to be a general
// purpose transaction class that lends itself to many applications. The
// class is derived from uvm_sequence_item which enables it to be
// generated in sequences and transported to drivers through sequencers.
//----------------------------------------------------------------------
class tlm_generic_payload extends uvm_sequence_item;

   rand tlm_addr_t             m_address;
   rand tlm_command_e          m_command;
   rand byte                   m_data[];
   rand int unsigned           m_length;
   rand tlm_response_status_e  m_response_status;
   rand bit                    m_dmi;
   rand byte                   m_byte_enable[];
   rand int unsigned           m_byte_enable_length;
   rand int unsigned           m_streaming_width;

  // function: new
  //
  // Create a new instance of the generic payload.  Initialize all the
  // members to their default values.

  function new(string name="");
    super.new(name);
    m_address = 0;
    m_command = TLM_IGNORE_COMMAND;
    m_length = 0;
    m_response_status = TLM_INCOMPLETE_RESPONSE;
    m_dmi = 0;
    m_byte_enable_length = 0;
    m_streaming_width = 0;
  endfunction

  // function: convert2string
  //
  // Convert the contents of the class to a string suitable for
  // printing.

  function string convert2string();

    string msg;
    string addr_fmt;
    string s;
    int unsigned addr_chars = (addr_size >> 2) + ((addr_size & 'hf) > 0);

    $sformat(addr_fmt, "%%%0dx", addr_chars);
    $sformat(s, addr_fmt, m_address);
    $sformat(msg, "%s [%s] =", m_command.name(), s);

    for(int unsigned i = 0; i < m_data.size(); i++) begin
      $sformat(s, " %02x", m_data[i]);
      msg = { msg , s };
    end

    if(m_response_status != TLM_INCOMPLETE_RESPONSE)
      msg = { msg, " <-- ", get_response_string() };

    return msg;

  endfunction

  //--------------------------------------------------------------------
  // accessors
  //--------------------------------------------------------------------

  // function: get_command
  // return the command type.

  virtual function tlm_command_e get_command();
    return m_command;
  endfunction

  // function: set_command
  // set the command

  virtual function void set_command(tlm_command_e command);
    m_command = command;
  endfunction

  // function: is_read
  // return a one if the command typs is TLM_READ_COMMAND, a zero
  // otherwise.

  virtual function bit is_read();
    return (m_command == TLM_READ_COMMAND);
  endfunction

  // function: set_read
  // set the command to TLM_READ_COMMAND

  virtual function void set_read();
    set_command(TLM_READ_COMMAND);
  endfunction

  // function: is_write
  // return a one if the command type is TLM_WRITE_COMMAND, a zero
  // otherwise.

  virtual function bit is_write();
    return (m_command == TLM_WRITE_COMMAND);
  endfunction

  virtual function void set_write();
    set_command(TLM_WRITE_COMMAND);
  endfunction
  
  // address
  virtual function void set_address(tlm_addr_t addr);
    m_address = addr;
  endfunction

  virtual function tlm_addr_t get_address();
    return m_address;
  endfunction

  virtual function void get_data (output byte p []);
    p = m_data;
  endfunction

  virtual function void set_data_ptr(ref byte p []);
    m_data = p;
  endfunction

  virtual function int unsigned get_data_length();
    return m_length;
  endfunction

  virtual function void set_data_length(int unsigned length);
    m_length = length;
  endfunction

  virtual function int unsigned get_streaming_width();
    return m_streaming_width;
  endfunction

  virtual function void set_streaming_width(int unsigned width);
    m_streaming_width = width;
  endfunction

  virtual function void get_byte_enable(output byte p[]);
    p = m_byte_enable;
  endfunction

  virtual function void set_byte_enable(ref byte p[]);
    m_byte_enable = p;
  endfunction

  virtual function int unsigned get_byte_enable_length();
    return m_byte_enable_length;
  endfunction

  virtual function void set_byte_enable_length(int unsigned length);
    m_byte_enable_length = length;
  endfunction

 // DMI hint void set_dmi_allowed( bool );
  virtual function void set_dmi_allowed(bit dmi);
    m_dmi = dmi;
  endfunction

  virtual function bit is_dmi_allowed();
    return m_dmi;
  endfunction

  virtual function tlm_response_status_e get_response_status();
    return m_response_status;
  endfunction

  virtual function void set_response_status(tlm_response_status_e status);
    m_response_status = status;
  endfunction

  virtual function bit is_response_ok();
    return (m_response_status > 0);
  endfunction

  virtual function bit is_response_error();
    return !is_response_ok();
  endfunction

  // function: get_response_string
  //
  // return an abbreviated response string

  virtual function string get_response_string();

    case(m_response_status)
      TLM_OK_RESPONSE                : return "OK";
      TLM_INCOMPLETE_RESPONSE        : return "INCOMPLETE";
      TLM_GENERIC_ERROR_RESPONSE     : return "GENERIC_ERROR";
      TLM_ADDRESS_ERROR_RESPONSE     : return "ADDRESS_ERROR";
      TLM_COMMAND_ERROR_RESPONSE     : return "COMMAND_ERROR";
      TLM_BURST_ERROR_RESPONSE       : return "BURST_ERROR";
      TLM_BYTE_ENABLE_ERROR_RESPONSE : return "BYTE_ENABLE_ERROR";
    endcase

    // we should never get here
    return "UNKNOWN_RESPONSE";

  endfunction

  //--------------------------------------------------------------------
  // extensions mechanism
  //--------------------------------------------------------------------

  protected tlm_extension_base m_extensions [tlm_extension_base];

  // Function: set_extension
  //
  // Add an instance-specific extension.
  // The specified extension is bound to the generic payload by ts type
  // handle.
   
  function tlm_extension_base set_extension(tlm_extension_base ext);
    tlm_extension_base ext_handle = ext.get_type_handle();
    tlm_extension_base old_ext = m_extensions[ext_handle];
    m_extensions[ext_handle] = ext;
    return old_ext;
  endfunction

  // Function: get_num_extensions
  //
  // Return the current number of instance specific extensions.
   
  function int get_num_extensions();
    return m_extensions.num();
  endfunction: get_num_extensions
   
  // Function: get_extension
  //
  // Return the instance specific extension bound under the specified key.
  // If no extension is bound under that key, ~null~ is returned.
   
  function tlm_extension_base get_extension(tlm_extension_base ext_handle);
    if(!m_extensions.exists(ext_handle))
      return null;
    return m_extensions[ext_handle];
  endfunction
   
  // Function: clear_extension
  //
  // Remove the instance-specific extension bound under the specified key.
   
  function void clear_extension(tlm_extension_base ext_handle);
    if(!m_extensions.exists(ext_handle))
      return;
    m_extensions.delete(ext_handle);
  endfunction: clear_extension

  // Function: clear_extensions
  //
  // Remove all instance-specific extensions
   
  function void clear_extensions();
    m_extensions.delete();
  endfunction
    
endclass
