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

class uvm_r2l_dap#(type T=int) extends uvm_object;

    // Parameterized Utils
    `uvm_object_param_utils(uvm_r2l_dap#(T))

    // read state (if '1', writes cause an error
    protected bit m_read_state;

    // Stored data
    protected T m_value;

    // Function: new
    // Constructor
    function new(string name="unnamed-uvm_r2l_dap#(T)");
        super.new(name);
        m_read_state = 0;
    endfunction : new

    // Function: reset
    // Resets the 'read' state of the DAP, allowing for
    // new writes.
    virtual function void reset();
        m_read_state = 0;
    endfunction : new

    // Function: write
    // Updates the value stored within the DAP.
    //
    // ~write~ will result in an error if the DAP is in the
    // 'read' state.
    virtual function void write(T value);
        if (m_read_state)
          `uvm_error("R2L_DAP",
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
    virtual function T peek();
        return m_value;
    endfunction : peek

    // Function: read
    // Returns the current value stored within the DAP, and sets the 'read' state.
    //
    // After a 'read', no one can 'write' the value w/o resetting the DAP first.
    //
    virtual function T read();
        m_read_state = 1;
        return m_value;
    endfunction : read

endclass // uvm_r2l_dap

// Class: uvm_r2l_int_dap
// Parameterized read-to-lock Data Access Policy, for integral types
//
// Using this specialized version of ~uvm_r2l_dap#(T)~ allows for
// better reporting and recording for integral types.
//
// Parameterizing this class with a type which is NOT and integral
// type will result in compilation errors.

class uvm_r2l_int_dap#(type T=int) extends uvm_r2l_dap#(T);

    // We're still parameterized
    `uvm_object_param_decl(uvm_r2l_int_dap#(T))

    // Function: new
    // Constructor
    function new(string name="unnamed-uvm_r2l_int_dap#(T)");
        super.new(name);
    endfunction : new

    // Function: do_print
    // Implementation of <uvm_object::do_print> which prints the current value
    //
    virtual function void do_print(uvm_printer printer);
        super.do_print(printer);
    endfunction : do_print

endclass : uvm_r2l_int_dap

        
    
