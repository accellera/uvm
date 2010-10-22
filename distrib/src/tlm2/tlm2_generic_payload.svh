//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
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

//----------------------------------------------------------------------
// Title: TLM Extensions & Generic Payload
//----------------------------------------------------------------------
//

// Topic: Globals
// Defines, Constants, enums.
//
// <`TLM_ADDR_SIZE>        : Define generic addr_size width of TLM GP
//
// <addr_size>             : Constant to hold default TLM GP Address size
//
// <tlm_command_e>         : Command atribute type definition

// Topic: TLM extensions
// An extension is an arbitrary object stored in an extension container. 
// The set of extensions for any particular generic payload object are 
// stored in an associative array indexed by the type handle of the extension 
// container
//
// <tlm_response_status_e> : Respone status attribute type definition
//
// <tlm_extension_base>    : non-parameerized base class
//
// <tlm_extension>         : parameterized with arbitrary type
//

// Topic: Generic Payload
// TLM_GP definition
//
// <tlm_generic_payload>   : base object, called the generic payload, for 
// moving data between components. In SystemC this is the primary 
// transaction vehicle. In SystemVerilog this is the default transaction 
// type, but it is not the only type that can be used.
//

// Section: Globals

//------------------------------------------------------------------------------
// MACRO: `TLM_ADDR_SIZE
// 
// Define generic addr_size width of TLM GP

`define TLM_ADDR_SIZE 64

// const: addr_size
//
// Constant to hold default TLM GP Address size.
//

const int unsigned addr_size = `TLM_ADDR_SIZE;

typedef bit[`TLM_ADDR_SIZE-1:0] tlm_addr_t;

// Enum: tlm_command_e
//
// Command atribute type definition
//
// TLM_READ_COMMAND      - Bus read operation
//
// TLM_WRITE_COMMAND     - Bus write operation
//
// TLM_IGNORE_COMMAND    - No bus operation.

typedef enum
{
    TLM_READ_COMMAND,
    TLM_WRITE_COMMAND,
    TLM_IGNORE_COMMAND
} tlm_command_e;

// Enum: tlm_response_status_e
//
// Respone status attribute type definition
//
// TLM_OK_RESPONSE                - Bus operation completed succesfully
//
// TLM_INCOMPLETE_RESPONSE        - Transaction was not delivered to target
//
// TLM_GENERIC_ERROR_RESPONSE     - Bus operation had an error
//
// TLM_ADDRESS_ERROR_RESPONSE     - Invalid address specified
//
// TLM_COMMAND_ERROR_RESPONSE     - Invalid command specified
//
// TLM_BURST_ERROR_RESPONSE       - Invalid burst specified
//
// TLM_BYTE_ENABLE_ERROR_RESPONSE - Invalid byte enabling specified
//

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
// Section: TLM extensions
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Class: tlm_extension_base
//
// The class tlm_extension_base is the non-parameterized base class for
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

  // function: create
  //
   
  pure virtual function uvm_object create (string name="");

endclass

//----------------------------------------------------------------------
// Class: tlm_extension
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
// Section: Generic Payload
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Class: tlm_generic_payload
//
// This class provides a transaction architecture commonly used in
// memory-mapped bus-based systems.  It's intended to be a general
// purpose transaction class that lends itself to many applications. The
// class is derived from uvm_sequence_item which enables it to be
// generated in sequences and transported to drivers through sequencers.
//----------------------------------------------------------------------

class tlm_generic_payload extends uvm_sequence_item;
   
   // Variable: m_address
   //
   // Address for the bus operation.
   // Should be set or read using the <set_address> and <get_address>
   // methods. The variable should be used only when constraining.
   //
   // For a read command or a write command, the target shall
   // interpret the current value of the address attribute as the start
   // address in the system memory map of the contiguous block of data
   // being read or written.
   // The address associated with any given byte in the data array is
   // dependent upon the address attribute, the array index, the
   // streaming width attribute, the endianness and the width of the physical bus.
   //
   // If the target is unable to execute the transaction with
   // the given address attribute (because the address is out-of-range,
   // for example) it shall generate a standard error response. The
   // recommended response status is ~TLM_ADDRESS_ERROR_RESPONSE~.

   rand tlm_addr_t             m_address;
 
   // Variable: m_command
   //
   // Bus operation type.
   // Should be set using the <set_command>, <set_read> or <set_write> methods
   // and read using the <get_command>, <is_read> or <is_write> methods.
   // The variable should be used only when constraining.
   //
   // If the target is unable to execute a read or write command, it
   // shall generate a standard error response. The
   // recommended response status is TLM_COMMAND_ERROR_RESPONSE.
   //
   // On receipt of a generic payload transaction with the command
   // attribute equal to TLM_IGNORE_COMMAND, the target shall not execute
   // a write command or a read command not modify any data.
   // The target may, however, use the value of any attribute in
   // the generic payload, including any extensions.
   //
   // The command attribute shall be set by the initiator, and shall
   // not be overwritten by any interconnect

   rand tlm_command_e          m_command;
   
   // Variable: m_data
   //
   // Data read or to be written.
   // Should be set and read using the <set_data> or <get_data> methods
   // The variable should be used only when constraining.
   //
   // For a read command or a write command, the target shall copy data
   // to or from the data array, respectively, honoring the semantics of
   // the remaining attributes of the generic payload.
   //
   // For a write command or TLM_IGNORE_COMMAND, the contents of the
   // data array shall be set by the initiator, and shall not be
   // overwritten by any interconnect component or target. For a read
   // command, the contents of the data array shall be overwritten by the
   // target (honoring the semantics of the byte enable) but by no other
   // component.

   rand byte                   m_data[];
   rand int unsigned           m_length;
   
   // Variable: m_response_status
   //
   // Status of the bus operation.
   // Should be set using the <set_response_status> method
   // and read using the <get_response_status>, <get_response_string>,
   // <is_response_ok> or <is_response_error> methods.
   // The variable should be used only when constraining.
   //
   // The response status attribute shall be set to
   // TLM_INCOMPLETE_RESPONSE by the initiator, and may
   // be overwritten by the target. The response status attribute
   // should not be overwritten by any interconnect
   // component, because the default value TLM_INCOMPLETE_RESPONSE
   // indicates that the transaction was not delivered to the target.
   //
   // The target may set the response status attribute to TLM_OK_RESPONSE
   // to indicate that it was able to execute the command
   // successfully, or to one of the five error responses
   // to indicate an error. The target should choose the appropriate
   // error response depending on the cause of the error.
   // If a target detects an error but is unable to select a specific
   // error response, it may set the response status to
   // TLM_GENERIC_ERROR_RESPONSE.
   //
   // The target shall be responsible for setting the response status
   // attribute at the appropriate point in the
   // lifetime of the transaction. In the case of the blocking
   // transport interface, this means before returning
   // control from b_transport. In the case of the non-blocking
   // transport interface and the base protocol, this
   // means before sending the BEGIN_RESP phase or returning a value of TLM_COMPLETED.
   //
   // It is recommended that the initiator should always check the
   // response status attribute on receiving a
   // transition to the BEGIN_RESP phase or after the completion of
   // the transaction. An initiator may choose
   // to ignore the response status if it is known in advance that the
   // value will be TLM_OK_RESPONSE,
   // perhaps because it is known in advance that the initiator is
   // only connected to targets that always return
   // TLM_OK_RESPONSE, but in general this will not be the case. In
   // other words, the initiator ignores the
   // response status at its own risk.

   rand tlm_response_status_e  m_response_status;

   // un doc'ed variable used for dmi functions    
   rand bit                    m_dmi;
   
   // Variable: m_byte_enable
   //
   // Indicates valid <m_data> array elements.
   // Should be set and read using the <set_byte_enable> or <get_byte_enable> methods
   // The variable should be used only when constraining.
   //
   // The elements in the byte enable array shall be interpreted as
   // follows. A value of 0 shall indicate that that
   // corresponding byte is disabled, and a value of 1 shall
   // indicate that the corresponding byte is enabled.
   //
   // Byte enables may be used to create burst transfers where the
   // address increment between each beat is
   // greater than the number of significant bytes transferred on each
   // beat, or to place words in selected byte
   // lanes of a bus. At a more abstract level, byte enables may be
   // used to create "lacy bursts" where the data array of the generic
   // payload has an arbitrary pattern of holes punched in it.
   //
   // The byte enable mask may be defined by a small pattern applied
   // repeatedly or by a large pattern covering the whole data array.
   // The byte enable array may be empty, in which case byte enables
   // shall not be used for the current transaction.
   //
   // The byte enable array shall be set by the initiator and shall
   // not be overwritten by any interconnect component or target.
   //
   // If the byte enable pointer is non-null, the target shall either
   // implement the semantics of the byte enable as defined below or
   // shall generate a standard error response. The recommended response
   // status is TLM_BYTE_ENABLE_ERROR_RESPONSE.
   //
   // In the case of a write command, any interconnect component or
   // target should ignore the values of any disabled bytes in the
   // <m_data> array. In the case of a read command, any interconnect
   // component or target should not modify the values of disabled
   // bytes in the <m_data> array.
   
   rand byte                   m_byte_enable[];

   // undoc'ed variable that shuld always be m_byte_enable.size()
   rand int unsigned           m_byte_enable_length;

   // Variable: m_byte_enable
   //
   // Indicates valid <m_data> array elements.
   // Should be set and read using the <set_byte_enable> or <get_byte_enable> methods
   // The variable should be used only when constraining.
   //
   // The elements in the byte enable array shall be interpreted as
   // follows. A value of 0 shall indicate that that
   // corresponding byte is disabled, and a value of 1 shall
   // indicate that the corresponding byte is enabled.
   //
   // Byte enables may be used to create burst transfers where the
   // address increment between each beat is
   // greater than the number of significant bytes transferred on each
   // beat, or to place words in selected byte
   // lanes of a bus. At a more abstract level, byte enables may be
   // used to create "lacy bursts" where the data array of the generic
   // payload has an arbitrary pattern of holes punched in it.
   //
   // The byte enable mask may be defined by a small pattern applied
   // repeatedly or by a large pattern covering the whole data array.
   // The byte enable array may be empty, in which case byte enables
   // shall not be used for the current transaction.
   //
   // The byte enable array shall be set by the initiator and shall
   // not be overwritten by any interconnect component or target.
   //
   // If the byte enable pointer is non-null, the target shall either
   // implement the semantics of the byte enable as defined below or
   // shall generate a standard error response. The recommended response
   // status is TLM_BYTE_ENABLE_ERROR_RESPONSE.
   //
   // In the case of a write command, any interconnect component or
   // target should ignore the values of any disabled bytes in the
   // <m_data> array. In the case of a read command, any interconnect
   // component or target should not modify the values of disabled
   // bytes in the <m_data> array.
   
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
  // Topic: accessors
  // The accessor functions let you set and get each of the members of the 
  // generic payload. All of the accessor methods are virtual. This implies 
  // a slightly different use model for the generic payload than 
  // in SsytemC. The way the generic payload is defined in SystemC does 
  // not encourage you to create new transaction types derived from 
  // tlm_generic_payload. Instead, you would use the extensions mechanism. 
  // Thus in SystemC none of the accessors are virtual.
  //--------------------------------------------------------------------

   // Function: get_command
   //
   // Get the value of the <m_command> variable

  virtual function tlm_command_e get_command();
    return m_command;
  endfunction

   // Function: set_command
   //
   // Set the value of the <m_command> variable
   
  virtual function void set_command(tlm_command_e command);
    m_command = command;
  endfunction

   // Function: is_read
   //
   // Returns true if the current value of the <m_command> variable
   // is ~TLM_READ_COMMAND~.
   
  virtual function bit is_read();
    return (m_command == TLM_READ_COMMAND);
  endfunction
 
   // Function: set_read
   //
   // Set the current value of the <m_command> variable
   // to ~TLM_READ_COMMAND~.
   
  virtual function void set_read();
    set_command(TLM_READ_COMMAND);
  endfunction

   // Function: is_write
   //
   // Returns true if the current value of the <m_command> variable
   // is ~TLM_WRITE_COMMAND~.
 
  virtual function bit is_write();
    return (m_command == TLM_WRITE_COMMAND);
  endfunction
 
   // Function: set_write
   //
   // Set the current value of the <m_command> variable
   // to ~TLM_WRITE_COMMAND~.

  virtual function void set_write();
    set_command(TLM_WRITE_COMMAND);
  endfunction
  
   // Function: set_address
   //
   // Set the value of the <m_address> variable
  virtual function void set_address(tlm_addr_t addr);
    m_address = addr;
  endfunction

   // Function: get_address
   //
   // Get the value of the <m_address> variable
 
  virtual function tlm_addr_t get_address();
    return m_address;
  endfunction

   // Function: get_data
   //
   // Return the value of the <m_data> array
 
  virtual function void get_data (output byte p []);
    p = m_data;
  endfunction

   // Function: set_data_ptr
   //
   // Set the value of the <m_data> array  

  virtual function void set_data_ptr(ref byte p []);
    m_data = p;
  endfunction 
  
   // Function: get_data_length
   //
   // Return the current size of the <m_data> array
   
  virtual function int unsigned get_data_length();
    return m_length;
  endfunction

  // function: set_data_length
  // Set the value of the <m_length>
   
   virtual function void set_data_length(int unsigned length);
    m_length = length;
  endfunction

   // Function: get_streaming_width
   //
   // Get the value of the <m_streaming_width> array
  
  virtual function int unsigned get_streaming_width();
    return m_streaming_width;
  endfunction

 
   // Function: set_streaming_width
   //
   // Set the value of the <m_streaming_width> array
   
  virtual function void set_streaming_width(int unsigned width);
    m_streaming_width = width;
  endfunction

   // Function: get_byte_enable
   //
   // Return the value of the <m_byte_enable> array
  virtual function void get_byte_enable(output byte p[]);
    p = m_byte_enable;
  endfunction

   // Function: set_byte_enable
   //
   // Set the value of the <m_byte_enable> array
   
  virtual function void set_byte_enable(ref byte p[]);
    m_byte_enable = p;
  endfunction

   // Function: get_byte_enable_length
   //
   // Return the current size of the <m_byte_enable> array
   
  virtual function int unsigned get_byte_enable_length();
    return m_byte_enable_length;
  endfunction

   // Function: set_byte_enable_length
   //
   // Set the size <m_byte_enable_length> of the <m_byte_enable> array
   // i.e  <m_byte_enable>.size()
   
 virtual function void set_byte_enable_length(int unsigned length);
    m_byte_enable_length = length;
  endfunction

   // Function: set_dmi_allowed
   //
   // DMI hint. Set the internal flag <m_dmi> to allow dmi access
   
  virtual function void set_dmi_allowed(bit dmi);
    m_dmi = dmi;
  endfunction
   
   // Function: is_dmi_allowed
   //
   // DMI hint. Query the internal flag <m_dmi> if allowed dmi access 

 virtual function bit is_dmi_allowed();
    return m_dmi;
  endfunction

   // Function: get_response_status
   //
   // Return the current value of the <m_response_status> variable
   
  virtual function tlm_response_status_e get_response_status();
    return m_response_status;
  endfunction

   // Function: set_response_status
   //
   // Set the current value of the <m_response_status> variable

  virtual function void set_response_status(tlm_response_status_e status);
    m_response_status = status;
  endfunction

   // Function: is_response_ok
   //
   // Return TRUE if the current value of the <m_response_status> variable
   // is ~TLM_OK_RESPONSE~

  virtual function bit is_response_ok();
    return (m_response_status > 0);
  endfunction

   // Function: is_response_error
   //
   // Return TRUE if the current value of the <m_response_status> variable
   // is not ~TLM_OK_RESPONSE~

  virtual function bit is_response_error();
    return !is_response_ok();
  endfunction

   // Function: get_response_string
   //
   // Return the current value of the <m_response_status> variable
   // as a string

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
  // Topic: Extensions Mechanism
  //
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
