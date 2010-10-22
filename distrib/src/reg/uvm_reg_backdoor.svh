//
// -------------------------------------------------------------
//    Copyright 2004-2009 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
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

//
// Title: User-Defined Backdoor Access
//
// The following declarations and classes
// are used to specify HDL paths and
// user-defined backdoor access to registers and memories.
//
// The following types are defined herein:
//
// <uvm_hdl_path_slice> : slice of an HDL path
//
// <uvm_hdl_path_concat> : array of HDL path slices
//
// The following classes are defined herein:
//
// <uvm_reg_backdoor> : base for user-defined backdoor register access
//
// <uvm_mem_backdoor> : base for user-defined backdoor memory access
//
// <uvm_reg_backdoor_cbs> : base for user-defined register backdoor access callbacks
//
// <uvm_mem_backdoor_cbs> : base for user-defined memory backdoor access callbacks
//

//------------------------------------------------------------------------------
// TYPE: uvm_hdl_path_slice
//
// Slice of an HDL path
//
// Struct that specifies the HDL variable that corresponds to all
// or a portion of a register.
//
// path    - Path to the HDL variable.
// offset  - Offset of the LSB in the register that this variable implements
// size    - Number of bits (toward the MSB) that this variable implements
//
// If the HDL variable implements all of the register, ~offset~ and ~size~
// are specified as -1. For example:
//|
//| r1.add_hdl_path('{ '{"r1", -1, -1} });
//|
//

typedef struct {
   string path;
   int offset;
   int size;
} uvm_hdl_path_slice;


//------------------------------------------------------------------------------
// TYPE: uvm_hdl_path_concat
//
// Concatenation of HDL variables
//
// Array of <uvm_hdl_path_slice> specifing a concatenation
// of HDL variables that implement a register in the HDL.
//
// Slices must be specified in most-to-least significant order.
// Slices must not overlap. Gaps may exists in the concatentation
// if portions of the registers are not implemented.
//
// For example, the following register
//|
//|        1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0
//| Bits:  5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
//|       +-+---+-------------+---+-------+
//|       |A|xxx|      B      |xxx|   C   |
//|       +-+---+-------------+---+-------+
//|
//
// would be specified using the following literal value:
//|
//|    '{ '{"A_reg", 15, 1},
//|       '{"B_reg",  6, 7},
//|       '{'C_reg",  0, 4} }
//
// If the register is implementd using a single HDL variable,
// The array should specify a single slice with its ~offset~ and ~size~
// specified as -1. For example:
//|
//| r1.add_hdl_path('{ '{"r1", -1, -1} });
//|
//

typedef uvm_hdl_path_slice uvm_hdl_path_concat[];


// concat2string

function string uvm_hdl_concat2string(uvm_hdl_path_concat slices);
   string image = "{";
   
   if (slices.size() == 1) return slices[0].path;

   foreach (slices[i]) begin
      uvm_hdl_path_slice slice;
      slice = slices[i];

      image = { image, (i == 0) ? "" : ", ", slice.path };
      if (slice.offset >= 0)
         image = { image, "@", $psprintf("[%0d +: %0d]", slice.offset, slice.size) };
   end

   image = { image, "}" };

   return image;
endfunction


//------------------------------------------------------------------------------
// CLASS: uvm_reg_backdoor
// Base class for user-defined back-door register access.
//
// This class can be extended by users to provide
// user-specific back-door access to registers
// that are not implemented in pure SystemVerilog
// or that are not accessible using the default DPI backdoor mechanism.
//------------------------------------------------------------------------------
typedef class uvm_reg_backdoor_cbs;
class uvm_reg_backdoor extends uvm_object;
   string fname = "";
   int lineno = 0;
   local uvm_reg_backdoor_cbs backdoor_cbs[$];

   local process m_update_thread[uvm_reg];

   `uvm_object_utils(uvm_reg_backdoor)
   `uvm_register_cb(uvm_reg_backdoor, uvm_reg_backdoor_cbs)


   //--------------------------------------------------------------------------
   // FUNCTION: new
   //
   // Create an instance of this class
   //
   // Create an instance of the user-defined backdoor class
   // for the specified register
   //--------------------------------------------------------------------------
   function new(string name = "");
      super.new(name);
   endfunction: new

   
   //--------------------------------------------------------------------------
   // TASK: do_pre_read
   //
   // Execute the pre-read callbacks
   //
   // This method ~must~ be called as the first statement in
   // a user extension of the <read()> method.
   //--------------------------------------------------------------------------
   protected task do_pre_read(input uvm_reg       rg,
                              input uvm_sequence_base parent,
                              input uvm_object        extension);
      pre_read(rg, parent, extension);
      `uvm_do_obj_callbacks(uvm_reg_backdoor,
                            uvm_reg_backdoor_cbs,
                            this, pre_read(rg, parent, extension))
   endtask


   //--------------------------------------------------------------------------
   // TASK: do_post_read
   //
   // Execute the post-read callbacks
   //
   // This method ~must~ be called as the last statement in
   // a user extension of the <read()> method.
   //--------------------------------------------------------------------------
   protected task do_post_read(input uvm_reg       rg,
                               inout uvm_status_e status,
                               inout uvm_reg_data_t    data,
                               input uvm_sequence_base parent,
                               input uvm_object        extension);
      begin
         uvm_callback_iter#(uvm_reg_backdoor,
                            uvm_reg_backdoor_cbs) iter = new(this);
         for(uvm_reg_backdoor_cbs cb = iter.last();
             cb != null;
             cb = iter.prev()) data = cb.decode(data);
      end
      `uvm_do_obj_callbacks(uvm_reg_backdoor,
                            uvm_reg_backdoor_cbs,
                            this,
                            post_read(rg, status, data, parent, extension))
      post_read(rg, status, data, parent, extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: do_pre_write
   //
   // Execute the pre-write callbacks
   //
   // This method ~must~ be called as the first statement in
   // a user extension of the <write()> method.
   //--------------------------------------------------------------------------
   protected task do_pre_write(input uvm_reg       rg,
                               inout uvm_reg_data_t    data,
                               input uvm_sequence_base parent,
                               input uvm_object        extension);
      pre_write(rg, data, parent, extension);
      `uvm_do_obj_callbacks(uvm_reg_backdoor,
                            uvm_reg_backdoor_cbs,
                            this,
                            pre_write(rg, data, parent, extension))
      begin
         uvm_callback_iter#(uvm_reg_backdoor,
                            uvm_reg_backdoor_cbs) iter = new(this);
         for(uvm_reg_backdoor_cbs cb = iter.first();
             cb != null;
             cb = iter.next()) data = cb.encode(data);
      end
   endtask


   //--------------------------------------------------------------------------
   // TASK: do_post_write
   //
   // Execute the post-write callbacks
   //
   // This method ~must~ be called as the last statement in
   // a user extension of the <write()> method.
   //--------------------------------------------------------------------------
   protected task do_post_write(input uvm_reg       rg,
                                inout uvm_status_e status,
                                input uvm_reg_data_t    data,
                                input uvm_sequence_base parent,
                                input uvm_object        extension);
      `uvm_do_obj_callbacks(uvm_reg_backdoor,
                            uvm_reg_backdoor_cbs,
                            this,
                            post_write(rg, status, data, parent, extension))
      post_write(rg, status, data, parent, extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: write
   //
   // User-defined backdoor write operation.
   //
   // Call <do_pre_write()>.
   // Deposit the specified value in the specified register HDL implementation
   // Call <do_post_write()>
   // Returns an indication of the success of the operation.
   //
   //--------------------------------------------------------------------------
   extern virtual task write(input  uvm_reg       rg,
                             output uvm_status_e status,
                             input  uvm_reg_data_t    data,
                             input  uvm_sequence_base parent,
                             input  uvm_object        extension);


   //--------------------------------------------------------------------------
   // TASK: read
   //
   // User-defined backdoor read operation.
   //
   // Overload this method only if the backdoor requires the use of task.
   //
   // Call <do_pre_read()>.
   // Peek the current value of the specified register HDL implementation
   // Call <do_post_read()>
   // Returns the current value and an indication of the success of
   // the operation.
   //
   // By default, calls <read_func()>.
   //--------------------------------------------------------------------------
   extern virtual task read(input  uvm_reg        rg,
                            output uvm_status_e  status,
                            output uvm_reg_data_t     data,
                            input  uvm_sequence_base  parent,
                            input  uvm_object         extension);

   //--------------------------------------------------------------------------
   // FUNCTION: read_func
   //
   // User-defined backdoor read operation.
   //
   // Peek the current value in the register HDL implementation
   // Returns the current value and an indication of the success of
   // the operation.
   //--------------------------------------------------------------------------
   extern virtual function uvm_status_e read_func(
                            input  uvm_reg        rg,
                            output uvm_status_e  status,
                            output uvm_reg_data_t     data,
                            input  uvm_sequence_base  parent,
                            input  uvm_object         extension);


   //--------------------------------------------------------------------------
   // FUNCTION: is_auto_updated
   //
   // Indicates if wait_for_change() method is implemented
   //
   // Implement to return TRUE if and only if
   // <wait_for_change()> is implemented to watch for changes
   // in the HDL implementation of the specified field
   //--------------------------------------------------------------------------
   extern virtual function bit is_auto_updated(uvm_reg_field field);


   //--------------------------------------------------------------------------
   // TASK: wait_for_change
   //
   // Wait for a change in the value of the register in the DUT.
   //
   // When this method returns, the mirror value for the register
   // corresponding to this instance of the backdoor class will be updated
   // via a backdoor read operation.
   //--------------------------------------------------------------------------
   extern virtual local task wait_for_change(uvm_reg rg);

  
   /*local*/ extern function void start_update_thread(uvm_reg rg);
   /*local*/ extern function void kill_update_thread(uvm_reg rg);
   /*local*/ extern function bit has_update_threads();


   //--------------------------------------------------------------------------
   // TASK: pre_read
   //
   // Called before user-defined backdoor register read.
   //
   // The registered callback methods are invoked after the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task pre_read(input uvm_reg       rg,
                         input uvm_sequence_base parent,
                         input uvm_object        extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: post_read
   //
   // Called after user-defined backdoor register read.
   //
   // The registered callback methods are invoked before the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task post_read(input uvm_reg       rg,
                          inout uvm_status_e status,
                          inout uvm_reg_data_t    data,
                          input uvm_sequence_base parent,
                          input uvm_object        extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: pre_write
   //
   // Called before user-defined backdoor register write.
   //
   // The registered callback methods are invoked after the invocation
   // of this method.
   //
   // The written value, if modified, modifies the actual value that
   // will be written.
   //--------------------------------------------------------------------------
   virtual task pre_write(input uvm_reg       rg,
                          inout uvm_reg_data_t    data,
                          input uvm_sequence_base parent,
                          input uvm_object        extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: post_write
   //
   // Called after user-defined backdoor register write.
   //
   // The registered callback methods are invoked before the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task post_write(input uvm_reg       rg,
                           inout uvm_status_e status,
                           input uvm_reg_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object        extension);
   endtask
endclass: uvm_reg_backdoor



//------------------------------------------------------------------------------
// CLASS: uvm_mem_backdoor
//
// Base class for user-defined back-door memory access.
//
// This class can be extended by users to provide
// user-specific back-door access to a memory
// that are not implemented in pure SystemVerilog
// or that are not accessible using the default DPI backdoor mechanism.
//------------------------------------------------------------------------------
typedef class uvm_mem_backdoor_cbs;
class uvm_mem_backdoor extends uvm_object;
   string fname = "";
   int lineno = 0;
   uvm_mem mem;
   local uvm_mem_backdoor_cbs backdoor_cbs[$];

   `uvm_object_utils(uvm_mem_backdoor)
   `uvm_register_cb(uvm_mem_backdoor, uvm_mem_backdoor_cbs)


   //--------------------------------------------------------------------------
   // FUNCTION: new
   //
   // Create an instance of this class
   //
   // Create an instance of the user-defined backdoor class
   // for the specified register
   //--------------------------------------------------------------------------
   function new(string name = "");
      super.new(name);
   endfunction: new


   //--------------------------------------------------------------------------
   // TASK: do_pre_read
   //
   // Execute the pre-read callbacks
   //
   // This method ~must~ be called as the first statement in
   // a user extension of the <read()> method.
   //--------------------------------------------------------------------------
   protected task do_pre_read(input uvm_mem       mem,
                              inout uvm_reg_addr_t    offset,
                              input uvm_sequence_base parent,
                              input uvm_object        extension);
      pre_read(mem, offset, parent, extension);
      `uvm_do_obj_callbacks(uvm_mem_backdoor,
                            uvm_mem_backdoor_cbs,
                            this, pre_read(mem, offset, parent, extension))
   endtask


   //--------------------------------------------------------------------------
   // TASK: do_post_read
   //
   // Execute the post-read callbacks
   //
   // This method ~must~ be called as the last statement in
   // a user extension of the <read()> method.
   //--------------------------------------------------------------------------
   protected task do_post_read(input uvm_mem       mem,
                               inout uvm_status_e status,
                               input uvm_reg_addr_t    offset,
                               inout uvm_reg_data_t    data,
                               input uvm_sequence_base parent,
                               input uvm_object        extension);
      begin
         uvm_callback_iter#(uvm_mem_backdoor,
                            uvm_mem_backdoor_cbs) iter = new(this);
         for(uvm_mem_backdoor_cbs cb = iter.last();
             cb != null;
             cb = iter.prev()) data = cb.decode(data);
      end
      `uvm_do_obj_callbacks(uvm_mem_backdoor,
                            uvm_mem_backdoor_cbs,
                            this,
                            post_read(mem, status, offset, data, parent, extension))
      post_read(mem, status, offset, data, parent, extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: do_pre_write
   //
   // Execute the pre-write callbacks
   //
   // This method ~must~ be called as the first statement in
   // a user extension of the <write()> method.
   //--------------------------------------------------------------------------
   protected task do_pre_write(input uvm_mem       mem,
                               inout uvm_reg_addr_t    offset,
                               inout uvm_reg_data_t    data,
                               input uvm_sequence_base parent,
                               input uvm_object         extension);
      pre_write(mem, offset, data, parent, extension);
      `uvm_do_obj_callbacks(uvm_mem_backdoor,
                            uvm_mem_backdoor_cbs,
                            this,
                            pre_write(mem, offset, data, parent, extension))
      begin
         uvm_callback_iter#(uvm_mem_backdoor,
                            uvm_mem_backdoor_cbs) iter = new(this);
         for(uvm_mem_backdoor_cbs cb = iter.first();
             cb != null;
             cb = iter.next()) data = cb.encode(data);
      end
   endtask


   //--------------------------------------------------------------------------
   // TASK: do_post_write
   //
   // Execute the post-write callbacks
   //
   // This method ~must~ be called as the last statement in
   // a user extension of the <write()> method.
   //--------------------------------------------------------------------------
   protected task do_post_write(input uvm_mem       mem,
                                inout uvm_status_e status,
                                input uvm_reg_addr_t    offset,
                                input uvm_reg_data_t    data,
                                input uvm_sequence_base parent,
                                input uvm_object        extension);
      `uvm_do_obj_callbacks(uvm_mem_backdoor,
                            uvm_mem_backdoor_cbs,
                            this,
                            post_write(mem, status, offset, data, parent, extension))
      post_write(mem, status, offset, data, parent, extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: write
   //
   // User-defined backdoor write operation.
   //
   // Call <do_pre_write()>.
   // Deposit the specified value in the memory location HDL implementation
   // Call <do_post_write()>
   // Returns an indication of the success of the operation.
   //
   //--------------------------------------------------------------------------
   extern virtual task write(input  uvm_mem        mem,
                             output uvm_status_e  status,
                             input  uvm_reg_addr_t     offset,
                             input  uvm_reg_data_t     data,
                             input  uvm_sequence_base  parent,
                             input uvm_object          extension);


   //--------------------------------------------------------------------------
   // TASK: read
   //
   // User-defined backdoor read operation.
   //
   // Overload this method only if the backdoor requires the use of task.
   //
   // Call <do_pre_read()>.
   // Peek the current value in the memory location HDL implementation
   // Call <do_post_read()>
   // Returns the current value and an indication of the success of
   // the operation.
   //
   // By default, calls <read_func()>.
   //--------------------------------------------------------------------------
   extern virtual task read(input  uvm_mem        mem,
                            output uvm_status_e  status,
                            input  uvm_reg_addr_t     offset,
                            output uvm_reg_data_t     data,
                            input  uvm_sequence_base  parent,
                            input  uvm_object         extension);

   //--------------------------------------------------------------------------
   // FUNCTION: read_func
   //
   // User-defined backdoor read operation.
   //
   // Peek the current value in the memory location HDL implementation
   // Returns the current value and an indication of the success of
   // the operation.
   //--------------------------------------------------------------------------
   extern virtual function uvm_status_e read_func(
                                       input  uvm_mem        mem,
                                       output uvm_status_e  status,
                                       input  uvm_reg_addr_t     offset,
                                       output uvm_reg_data_t     data,
                                       input  uvm_sequence_base  parent,
                                       input  uvm_object         extension);


   //--------------------------------------------------------------------------
   // TASK: pre_read
   //
   // Called before user-defined backdoor memory read.
   //
   // The registered callback methods are invoked after the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task pre_read(input uvm_mem       mem,
                         inout uvm_reg_addr_t    offset,
                         input uvm_sequence_base parent,
                         input uvm_object        extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: post_read
   //
   // Called after user-defined backdoor memory read.
   //
   // The registered callback methods are invoked before the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task post_read(input uvm_mem       mem,
                          inout uvm_status_e status,
                          inout uvm_reg_addr_t    offset,
                          inout uvm_reg_data_t    data,
                          input uvm_sequence_base parent,
                          input uvm_object        extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: pre_write
   //
   // Called before user-defined backdoor register write.
   //
   // The registered callback methods are invoked after the invocation
   // of this method.
   //
   // The written value, if modified, modifies the actual value that
   // will be written.
   //--------------------------------------------------------------------------
   virtual task pre_write(input uvm_mem       mem,
                          inout uvm_reg_addr_t    offset,
                          inout uvm_reg_data_t    data,
                          input uvm_sequence_base parent,
                          input uvm_object        extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: post_write
   //
   // Called after user-defined backdoor memory write.
   //
   // The registered callback methods are invoked before the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task post_write(input uvm_mem       mem,
                           inout uvm_status_e status,
                           inout uvm_reg_addr_t    offset,
                           input uvm_reg_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object        extension);
   endtask
endclass: uvm_mem_backdoor


//------------------------------------------------------------------------------
// CLASS: uvm_reg_backdoor_cbs
//
// Façade class for register backdoor access callback methods. 
//------------------------------------------------------------------------------
virtual class uvm_reg_backdoor_cbs extends uvm_callback;

    string fname = "";
    int lineno = 0;


   //--------------------------------------------------------------------------
   // TASK: pre_read
   //
   // Called before user-defined backdoor register read.
   //
   // The registered callback methods are invoked after the invocation
   // of the <uvm_reg_backdoor::pre_read()> method.
   //--------------------------------------------------------------------------
    virtual task pre_read(input uvm_reg rg,
                          input uvm_sequence_base parent,
                          input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: post_read
   //
   // Called after user-defined backdoor register read.
   //
   // The registered callback methods are invoked before the invocation
   // of the <uvm_reg_backdoor::post_read()> method.
   //--------------------------------------------------------------------------
    virtual task post_read(input uvm_reg       rg,
                           inout uvm_status_e status,
                           inout uvm_reg_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: pre_write
   //
   // Called before user-defined backdoor register write.
   //
   // The registered callback methods are invoked after the invocation
   // of the <uvm_reg_backdoor::pre_write()> method.
   //
   // The written value, if modified, modifies the actual value that
   // will be written.
   //--------------------------------------------------------------------------
    virtual task pre_write(input uvm_reg       rg,
                           inout uvm_reg_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: post_write
   //
   // Called after user-defined backdoor register write.
   //
   // The registered callback methods are invoked before the invocation
   // of the <uvm_reg_backdoor::post_write()> method.
   //--------------------------------------------------------------------------
    virtual task post_write(input uvm_reg        rg,
                            inout uvm_status_e status,
                            input uvm_reg_data_t    data,
                            input uvm_sequence_base parent,
                            input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // FUNCTION: encode
   //
   // Data encoder
   //
   // The registered callback methods are invoked in order of registration
   // after all the ~pre_write~ methods have been called.
   // The encoded data is passed through each invocation in sequence.
   // This allows the ~pre_write~ methods to deal with clear-text data.
   //
   // By default, the data is not modified.
   //--------------------------------------------------------------------------
    virtual function uvm_reg_data_t  encode(uvm_reg_data_t data);
      return data;
    endfunction


   //--------------------------------------------------------------------------
   // FUNCTION: decode
   //
   // Data decode
   //
   // The registered callback methods are invoked in ~reverse order~
   // of registration before all the ~post_read~ methods are called.
   // The decoded data is passed through each invocation in sequence.
   // This allows the ~post_read~ methods to deal with clear-text data.
   //
   // The reversal of the invocation order is to allow the decoding
   // of the data to be performed in the opposite order of the encoding
   // with both operations specified in the same callback extension.
   // 
   // By default, the data is not modified.
   //--------------------------------------------------------------------------
    virtual function uvm_reg_data_t  decode(uvm_reg_data_t data);
      return data;
    endfunction


endclass


//
// Type: uvm_reg_bd_cb
// Convenience callback type declaration
//
// Use this declaration to register register backdoor callbacks rather than
// the more verbose parameterized class
//
//
// Type: uvm_reg_bd_cb_iter
// Convenience callback iterator type declaration
//
// Use this declaration to iterate over registered register backdoor callbacks
// rather than the more verbose parameterized class
//

typedef class uvm_reg_backdoor;
typedef uvm_callbacks#(uvm_reg_backdoor, uvm_reg_backdoor_cbs) uvm_reg_bd_cb;

typedef uvm_callback_iter#(uvm_reg_backdoor, uvm_reg_backdoor_cbs) uvm_reg_bd_cb_iter;



//------------------------------------------------------------------------------
// CLASS: uvm_mem_backdoor_cbs
//
// Façade class for memory backdoor access callback methods. 
//------------------------------------------------------------------------------
virtual class uvm_mem_backdoor_cbs extends uvm_callback;

    string fname = "";
    int lineno = 0;
    

   //--------------------------------------------------------------------------
   // TASK: pre_read
   //
   // Called before user-defined backdoor memory read.
   //
   // The registered callback methods are invoked after the invocation
   // of the <uvm_mem_backdoor::pre_read()> method.
   //--------------------------------------------------------------------------
    virtual task pre_read(input uvm_mem       mem,
                          inout uvm_reg_addr_t    offset,
                          input uvm_sequence_base parent,
                          input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: post_read
   //
   // Called after user-defined backdoor memory read.
   //
   // The registered callback methods are invoked before the invocation
   // of the <uvm_mem_backdoor::post_read()> method.
   //--------------------------------------------------------------------------
    virtual task post_read(input uvm_mem       mem,
                           inout uvm_status_e status,
                           inout uvm_reg_addr_t    offset,
                           inout uvm_reg_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: pre_write
   //
   // Called before user-defined backdoor memory write.
   //
   // The registered callback methods are invoked after the invocation
   // of the <uvm_mem_backdoor::pre_write()> method.
   //
   // The written value, if modified, modifies the actual value that
   // will be written.
   //--------------------------------------------------------------------------
    virtual task pre_write(input uvm_mem       mem,
                           inout uvm_reg_addr_t    offset,
                           inout uvm_reg_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: post_write
   // 
   // Called after user-defined backdoor memory write.
   //
   // The registered callback methods are invoked before the invocation
   // of the <uvm_mem_backdoor::post_write()> method.
   //--------------------------------------------------------------------------
    virtual task post_write(input uvm_mem       mem,
                            inout uvm_status_e status,
                            inout uvm_reg_addr_t    offset,
                            input uvm_reg_data_t    data,
                            input uvm_sequence_base parent,
                            input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // FUNCTION: encode
   //
   // Data encoder
   //
   // The registered callback methods are invoked in order of registration
   // after all the ~pre_write~ methods have been called.
   // The encoded data is passed through each invocation in sequence.
   // This allows the ~pre_write~ methods to deal with clear-text data.
   //
   // By default, the data is not modified.
   //--------------------------------------------------------------------------
    virtual function uvm_reg_data_t  encode(uvm_reg_data_t  data);
      return data;
    endfunction


   //--------------------------------------------------------------------------
   // FUNCTION: decode
   //
   // Data decode
   //
   // The registered callback methods are invoked in ~reverse order~
   // of registration before all the ~post_read~ methods are called.
   // The decoded data is passed through each invocation in sequence.
   // This allows the ~post_read~ methods to deal with clear-text data.
   //
   // The reversal of the invocation order is to allow the decoding
   // of the data to be performed in the opposite order of the encoding
   // with both operations specified in the same callback extension.
   // 
   // By default, the data is not modified.
   //--------------------------------------------------------------------------
    virtual function uvm_reg_data_t  decode(uvm_reg_data_t  data);
      return data;
    endfunction

endclass


//
// Type: uvm_mem_bd_cb
// Convenience callback type declaration
//
// Use this declaration to register memory backdoor callbacks rather than
// the more verbose parameterized class
//

//
// Type: uvm_mem_bd_cb_iter
// Convenience callback iterator type declaration
//
// Use this declaration to iterate over registered memory backdoor callbacks
// rather than the more verbose parameterized class
//
typedef class uvm_mem_backdoor;
typedef uvm_callbacks#(uvm_mem_backdoor, uvm_mem_backdoor_cbs) uvm_mem_bd_cb;

typedef uvm_callback_iter#(uvm_mem_backdoor, uvm_mem_backdoor_cbs) uvm_mem_bd_cb_iter;


//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

function bit uvm_reg_backdoor::is_auto_updated(uvm_reg_field field);
   return 0;
endfunction

task uvm_reg_backdoor::wait_for_change(uvm_reg rg);
   `uvm_fatal("RegModel", "uvm_reg_backdoor::wait_for_change() method has not been overloaded");
endtask

function void uvm_reg_backdoor::start_update_thread(uvm_reg rg);
   if (this.m_update_thread.exists(rg)) begin
      this.kill_update_thread(rg);
   end

   fork
      begin
         uvm_reg_field fields[$];

         this.m_update_thread[rg] = process::self();
         rg.get_fields(fields);
         forever begin
            uvm_status_e status;
            uvm_reg_data_t  val;
            this.read(rg, status, val, null, null);
            if (status != UVM_IS_OK) begin
               `uvm_error("RegModel", $psprintf("Backdoor read of register '%s' failed.",
                          rg.get_name()));
            end
            foreach (fields[i]) begin
               if (this.is_auto_updated(fields[i])) begin
                  uvm_reg_data_t  fld_val
                     = val >> fields[i].get_lsb_pos_in_register();
                  fld_val = fld_val & ((1 << fields[i].get_n_bits())-1);
                  void'(fields[i].predict(fld_val));
               end
            end
            this.wait_for_change(rg);
         end
      end
   join_none
endfunction

function void uvm_reg_backdoor::kill_update_thread(uvm_reg rg);
   if (this.m_update_thread.exists(rg)) begin
      this.m_update_thread[rg].kill();
      this.m_update_thread.delete(rg);
   end
endfunction

function bit uvm_reg_backdoor::has_update_threads();
   return this.m_update_thread.num() > 0;
endfunction

task uvm_reg_backdoor::write(input  uvm_reg       rg,
                                 output uvm_status_e status,
                                 input  uvm_reg_data_t    data,
                                 input  uvm_sequence_base parent,
                                 input  uvm_object        extension);

   `uvm_fatal("RegModel", "uvm_reg_backdoor::write() method has not been overloaded");

endtask: write


task uvm_reg_backdoor::read(input  uvm_reg       rg,
                                output uvm_status_e status,
                                output uvm_reg_data_t    data,
                                input  uvm_sequence_base parent,
                                input  uvm_object        extension);
   do_pre_read(rg, parent, extension);
   status = read_func(rg, status, data,parent,extension);
   do_post_read(rg, status, data, parent, extension);
endtask: read


function uvm_status_e uvm_reg_backdoor::read_func(
                            input  uvm_reg       rg,
                            output uvm_status_e status,
                            output uvm_reg_data_t    data,
                            input  uvm_sequence_base parent,
                            input  uvm_object        extension);
   `uvm_fatal("RegModel", "uvm_reg_backdoor::read_func() method has not been overloaded");
   return UVM_NOT_OK;
endfunction


task uvm_mem_backdoor::write(input  uvm_mem       mem,
                                 output uvm_status_e status,
                                 input  uvm_reg_addr_t    offset,
                                 input  uvm_reg_data_t    data,
                                 input  uvm_sequence_base parent,
                                 input  uvm_object        extension);

   `uvm_fatal("RegModel", "uvm_mem_backdoor::write() method has not been overloaded");

endtask: write


task uvm_mem_backdoor::read(input  uvm_mem       mem,
                                output uvm_status_e status,
                                input  uvm_reg_addr_t    offset,
                                output uvm_reg_data_t    data,
                                input  uvm_sequence_base parent,
                                input  uvm_object        extension);
   do_pre_read(mem, offset, parent, extension);
   status = read_func(mem, status, offset, data, parent,extension);
   do_post_read(mem, status, offset, data, parent, extension);
endtask: read


function uvm_status_e uvm_mem_backdoor::read_func(
                                       input  uvm_mem       mem,
                                       output uvm_status_e status,
                                       input  uvm_reg_addr_t    offset,
                                       output uvm_reg_data_t    data,
                                       input  uvm_sequence_base parent,
                                       input  uvm_object        extension);
   `uvm_fatal("RegModel", "uvm_mem_backdoor::read_func() method has not been overloaded");
   return UVM_NOT_OK;
endfunction
