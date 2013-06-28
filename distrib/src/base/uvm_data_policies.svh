// 
//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010-2011 Synopsys, Inc.
//   Copyright 2013      NVIDIA Corporation
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

// Title: Data Access Policies
//
// The UVM provides the following objects as utility classes for applying
// common policies to data access (such as 'locking' data, or ensuring
// that it remains constant after being read).
//
// This is not intended to be a comprehensive use of all Data Access policies,
// and the user is encouraged to write there own, and potentially contribute them
// to the community.
//

// Group: Read-To-Lock

// Class: uvm_r2l_dap
// Provides a "lock-on-read" Data Access Policy.
//
// The ~uvm_r2l_dap#(T)~ class allows for any number of writes
// to the internally stored ~T~, up until the first read.  After
// the first read, it becomes illegal to write a new value.
//
// If ~uvm_r2l_dap~ is parameterized with ~string~ or ~uvm_object~,
// then enhanced reporting/recording are available.  For all other
// types, the ~value~ stored within the DAP can not be reported or
// recoreded.
//
// For integral types or <uvm_object>~-derived~ types, consider using
// <uvm_r2l_int_dap> or <uvm_r2l_object_dap> for enhanced
// reporting and recording capabilities.
//

class uvm_r2l_dap#(type T=int) extends uvm_object;

   // Parameterized Utils
   `uvm_object_param_utils(uvm_r2l_dap#(T))
   
   // read state (if '1', writes cause an error
   protected bit m_read_state;
   
   // Stored data
   protected T m_value;

   // Is this a known type (that we can print/record)?
   protected bit m_known_type;
   
   // Function: new
    // Constructor
   function new(string name="unnamed-uvm_r2l_dap#(T)");
      super.new(name);
      m_read_state = 0;
      m_known_type = 0;
   endfunction : new
   
   // Function: reset
   // Resets the 'read' state of the DAP, allowing for
   // new writes.
   virtual       function void reset();
      m_read_state = 0;
   endfunction : new
   
   // Function: write
   // Updates the value stored within the DAP.
   //
   // ~write~ will result in an error if the DAP is in the
   // 'read' state.
    virtual function void write(T value);
       if (m_read_state)
         `uvm_error("UVM/R2L_DAP/WAR",
                    $sformatf("Attempt to write new value to '%s', but the data access policy forbids writing after a read!",
                              get_full_name()))
       else
         m_value = value;
    endfunction : write
   
   // Function: peek
   // Returns the current value stored within the DAP, without changing the 'read' state.
   //
   // The 'peek' method can be employed to determine whether or not a 'write'
   // is called for.
   //
   virtual  function T peek();
      return m_value;
   endfunction : peek
   
   // Function: read
   // Returns the current value stored within the DAP, and sets the 'read' state.
   //
   // After a 'read', no one can 'write' the value w/o resetting the DAP first.
   //
   virtual  function T read();
      m_read_state = 1;
      return m_value;
   endfunction : read

   // Function: get_read_state
   // Returns the current 'read' state of the DAP
   //
   // Returns '1' if no reads have occurred, and it is
   // safe to issue a <write>.
   //
   // Returns '0' if a read has occurred, and it is no
   // longer safe to issue a <write> without <reset>ing
   // the DAP.
   virtual  function bit get_read_state();
      return m_read_state;
   endfunction : get_read_state
   
   // Function- do_print
   // Prints the read state, but doesn't print the value
   // because we don't know the type.
   virtual  function void do_print(uvm_printer printer);
      uvm_r2l_dap#(string) sdap;
      uvm_r2l_dap#(uvm_object) odap;
      super.do_print(printer);
      printer.print_int("read_state", m_read_state, $bits(m_read_state));
      if ($cast(sdap, this)) begin
         // We're a string type, we can print this
         printer.print_string("value", sdap.m_value);
      end
      else if ($cast(odap, this)) begin
         // We're an object, we can print this too
         printer.print_object("value", odap.m_value);
      end
      else if (!m_known_type) begin
         // We're not extended, so we can't print the value
         printer.print_generic("value", "unknown", 0, "?");
      end
   endfunction : do_print

   // Function- do_copy
   // Copying a data access policy doesn't really make sense, because then
   // you'd have two seperate state variables.
   //
   // We throw the error, but do copy the value and the read state, just in
   // case someone wants to disable the error (which they _really_ shouldn't
   // do).
   virtual  function void do_copy (uvm_object rhs);
      uvm_r2l_dap#(T) _rhs;
      `uvm_error("UVM/R2L_DAP/COPY", $sformatf("Illegal attempt to copy uvm_r2l_dap '%s'",
                                               get_full_name()))
      super.do_copy(rhs);
      $cast(_rhs, rhs);
      m_value = _rhs.m_value;
      m_read_state = _rhs.m_read_state;
   endfunction : do_copy
endclass // uvm_r2l_dap

// Class: uvm_r2l_int_dap
// Parameterized read-to-lock Data Access Policy, for integral types
//
// Using this specialized version of ~uvm_r2l_dap#(T)~ allows for
// better reporting and recording for integral types.
//
// Parameterizing this class with a type which is NOT an integral
// type will result in compilation errors.
//

class uvm_r2l_int_dap#(type T=int) extends uvm_r2l_dap#(T);

   // Variable: radix
   // The radix variable defines how the ~value~ will be
   // reported/recorded.
   //
   // The ~radix~ can be changed without any effect on the
   // 'read' state.
   uvm_radix_enum radix = UVM_HEX;
   
   // We're still parameterized
   `uvm_object_param_decl(uvm_r2l_int_dap#(T))
   
   // Function: new
   // Constructor
   function new(string name="unnamed-uvm_r2l_int_dap#(T)");
      super.new(name);
      m_known_type = 1; // Allows us report/record the value
   endfunction : new
   
   // Function: do_print
   // Implementation of <uvm_object::do_print> which prints the current value
   //
   virtual  function void do_print(uvm_printer printer);
      super.do_print(printer);
      printer.print_int("value", m_value, $bits(value), radix);
   endfunction : do_print

   // Function: do_record
   // Implementation of <uvm_object::do_record> which records the current value
   //
   virtual  function void do_record(uvm_recorder recorder);
      super.do_record(recorder);
      recorder.record_field("value", m_value, $bits(value), radix);
   endfunction : do_record
      
endclass : uvm_r2l_int_dap

// Class: uvm_r2l_object_dap
// Parameterized read-to-lock Data Access Policy, for <uvm_object>-derived
// classes.
//
// Using this specialized version of <uvm_r2l_dap> allows for
// better reporting and recording for object-based types.
//
// Parameterizing this class with a type which is NOT derived from 
// <uvm_object> type will result in compilation errors.
//

class uvm_r2l_object_dap#(type T=int) extends uvm_r2l_dap#(T);

   // We're still parameterized
   `uvm_object_param_decl(uvm_r2l_object_dap#(T))
   
   // Function: new
   // Constructor
   function new(string name="unnamed-uvm_r2l_object_dap#(T)");
      super.new(name);
      m_known_type = 1; // Allows us report/record the value
   endfunction : new
   
   // Function: do_print
   // Implementation of <uvm_object::do_print> which prints the current value
   //
   virtual  function void do_print(uvm_printer printer);
      super.do_print(printer);
      printer.print_object("value", m_value);
   endfunction : do_print

   // Function: do_record
   // Implementation of <uvm_object::do_record> which records the current value
   //
   virtual  function void do_record(uvm_recorder recorder);
      super.do_record(recorder);
      recorder.record_object("value", m_value);
   endfunction : do_record
      
endclass : uvm_r2l_object_dap

        
    
