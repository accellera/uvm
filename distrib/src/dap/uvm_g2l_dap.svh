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

// Class: uvm_g2l_dap
// Provides a 'Get-To-Lock' Data Access Policy.
//
// The 'Get-To-Lock' Data Access Policy allows for any number of 'sets',
// until the value is retrieved via a 'get'.  Once 'get' has been called, 
// it is illegal to 'set' a new value.
//
// The UVM uses this policy to protect the ~starting_phase~ and ~automatic_objection~
// values in <uvm_sequence_base>.
//

class uvm_g2l_dap#(type T=int) extends uvm_set_get_dap_base#(T);

   // Used for self-references
   typedef uvm_g2l_dap#(T) this_type;
   
   // Parameterized Utils
   `uvm_object_param_utils(uvm_g2l_dap#(T))
   
   // Stored data
   local T m_value;

   // Lock state
   local bit m_locked;

   // Function: new
   // Constructor
   function new(string name="unnamed-uvm_g2l_dap#(T)");
      super.new(name);
      m_locked = 0;
   endfunction : new

   // Group: Set/Get Interface
   
   // Function: set
   // Updates the value stored within the DAP.
   //
   // ~set~ will result in an error if the value has
   // already been retrieved via a call to ~get~.
   virtual function void set(T value);
      if (m_locked)
        `uvm_error("UVM/G2L_DAP/GAS",
                   $sformatf("Attempt to set new value on '%s', but the data access policy forbids setting after a get!",
                             get_full_name()))
      else begin
         m_value = value;
      end
   endfunction : set

   // Function: try_set
   // Attempts to update the value stored within the DAP.
   //
   // ~try_set~ will return a '1' if the value was successfully
   // updated, or a '0' if the value can not be updated due
   // to ~get~ having been called.  No errors will be reported
   // if ~try_set~ fails.
   virtual function bit try_set(T value);
      if (m_locked)
        return 0;
      else begin
         m_value = value;
         return 1;
      end
   endfunction : try_set
   
   // Function: get
   // Returns the current value stored within the DAP, and 'locks' the DAP.
   //
   // After a 'get', the value contained within the DAP can not
   // be changed.
   virtual  function T get();
      m_locked = 1;
      return m_value;
   endfunction : get

   // Function: try_get
   // Retrieves the current value stored within the DAP, and 'locks' the DAP.
   //
   // ~try_get~ will always return 1.
   virtual function bit try_get(T value);
      value = get();
      return 1;
   endfunction : try_get
   
   // Group: Copy and Clone
   //
   // While the ~uvm_g2l_dap~ implements the standard
   // UVM ~copy~ and ~clone~ methods for <uvm_object>s, 
   // these methods are ~not~ allowed to violate the access 
   // policy.  
   //
   // The rules for each method are:
   // COPY - ~copy~ is treated as a 'set' on the ~destination~
   //        DAP, and a 'get' on the ~source~ DAP.  If the 
   //        ~destination~ is 'locked' prior to the ~copy~, then
   //        ~copy~ will report an error.  If 'set' is called
   //        on the ~source~ after it has been copied, then
   //        the 'set' will report an error.
   //
   // CLONE - Like ~copy~, ~clone~ is treated as a 'set' on the
   //         ~destination~, and a 'get' on the ~source~ DAP.
   //         Since the ~clone~ is creating a new DAP, there is
   //         no chance of the 'set' producing an error, however
   //         the ~source~ is still considered 'locked'.
   //

   // Function- do_copy
   // Copies values from ~rhs~ into ~this~
   //
   virtual function void do_copy(uvm_object rhs);
      this_type _rhs;
      $cast(_rhs, rhs);
      if (m_locked)
        `uvm_error("UVM/G2L_DAP/CAS",
                   $sformatf("Attempt to copy new value to '%s', but the data access policy forbids setting after a get!",
                             get_full_name()))

      // Copy the locked state before we (potentially) change it
      if (_rhs.m_locked)
        m_locked = 1;

      // Calling get will lock the source
      m_value = _rhs.get();
   endfunction : do_copy

   // Function- convert2string
   virtual function string convert2string();
      if (m_locked)
        return $sformatf("(%s) %0p [LOCKED]", `uvm_typename(m_value), m_value);
      else
        return $sformatf("(%s) %0p [UNLOCKED]", `uvm_typename(m_value), m_value);
   endfunction : convert2string
   
   // Function- do_print
   virtual function void do_print(uvm_printer printer);
      super.do_print(printer);
      printer.print_int("lock_state", m_locked, $bits(m_locked));
      printer.print_generic("value", 
                            `uvm_typename(m_value), 
                            0, 
                            $sformatf("%0p", m_value));
      
   endfunction : do_print

endclass // uvm_g2l_dap

