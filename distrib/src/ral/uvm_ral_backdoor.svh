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


//------------------------------------------------------------------------------
// TYPE: uvm_ral_hdl_path_slice
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
} uvm_ral_hdl_path_slice;


//------------------------------------------------------------------------------
// TYPE: uvm_ral_hdl_path_concat
//
// Concatenation of HDL variables
//
// Array of <uvm_ral_hdl_path_slice> specifing a concatenation
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

typedef uvm_ral_hdl_path_slice uvm_ral_hdl_path_concat[];


// concat2string

function string uvm_ral_concat2string(uvm_ral_hdl_path_concat slices);
   string image = "{";
   
   if (slices.size() == 1) return slices[0].path;

   foreach (slices[i]) begin
      uvm_ral_hdl_path_slice slice;
      slice = slices[i];

      image = { image, (i == 0) ? "" : ", ", slice.path };
      if (slice.offset >= 0)
         image = { image, "@", $psprintf("[%0d +: %0d]", slice.offset, slice.size) };
   end

   image = { image, "}" };

   return image;
endfunction


//------------------------------------------------------------------------------
// CLASS: uvm_ral_reg_backdoor_callbacks
//
// Façade class for register backdoor access callback methods. 
//------------------------------------------------------------------------------
virtual class uvm_ral_reg_backdoor_callbacks extends uvm_callback;

    string fname = "";
    int lineno = 0;


   //--------------------------------------------------------------------------
   // TASK: pre_read
   //
   // Called before user-defined backdoor register read.
   //
   // The registered callback methods are invoked after the invocation
   // of the <uvm_ral_reg_backdoor::pre_read()> method.
   //--------------------------------------------------------------------------
    virtual task pre_read(input uvm_ral_reg rg,
                          input uvm_sequence_base parent,
                          input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: post_read
   //
   // Called after user-defined backdoor register read.
   //
   // The registered callback methods are invoked before the invocation
   // of the <uvm_ral_reg_backdoor::post_read()> method.
   //--------------------------------------------------------------------------
    virtual task post_read(input uvm_ral_reg       rg,
                           inout uvm_ral::status_e status,
                           inout uvm_ral_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: pre_write
   //
   // Called before user-defined backdoor register write.
   //
   // The registered callback methods are invoked after the invocation
   // of the <uvm_ral_reg_backdoor::pre_write()> method.
   //
   // The written value, if modified, modifies the actual value that
   // will be written.
   //--------------------------------------------------------------------------
    virtual task pre_write(input uvm_ral_reg       rg,
                           inout uvm_ral_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: post_write
   //
   // Called after user-defined backdoor register write.
   //
   // The registered callback methods are invoked before the invocation
   // of the <uvm_ral_reg_backdoor::post_write()> method.
   //--------------------------------------------------------------------------
    virtual task post_write(input uvm_ral_reg        rg,
                            inout uvm_ral::status_e status,
                            input uvm_ral_data_t    data,
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
    virtual function uvm_ral_data_t  encode(uvm_ral_data_t data);
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
    virtual function uvm_ral_data_t  decode(uvm_ral_data_t data);
      return data;
    endfunction


endclass




//------------------------------------------------------------------------------
// CLASS: uvm_ral_mem_backdoor_callbacks
//
// Façade class for memory backdoor access callback methods. 
//------------------------------------------------------------------------------
virtual class uvm_ral_mem_backdoor_callbacks extends uvm_callback;

    string fname = "";
    int lineno = 0;
    

   //--------------------------------------------------------------------------
   // TASK: pre_read
   //
   // Called before user-defined backdoor memory read.
   //
   // The registered callback methods are invoked after the invocation
   // of the <uvm_ral_mem_backdoor::pre_read()> method.
   //--------------------------------------------------------------------------
    virtual task pre_read(input uvm_ral_mem       mem,
                          inout uvm_ral_addr_t    offset,
                          input uvm_sequence_base parent,
                          input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: post_read
   //
   // Called after user-defined backdoor memory read.
   //
   // The registered callback methods are invoked before the invocation
   // of the <uvm_ral_mem_backdoor::post_read()> method.
   //--------------------------------------------------------------------------
    virtual task post_read(input uvm_ral_mem       mem,
                           inout uvm_ral::status_e status,
                           inout uvm_ral_addr_t    offset,
                           inout uvm_ral_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: pre_write
   //
   // Called before user-defined backdoor memory write.
   //
   // The registered callback methods are invoked after the invocation
   // of the <uvm_ral_mem_backdoor::pre_write()> method.
   //
   // The written value, if modified, modifies the actual value that
   // will be written.
   //--------------------------------------------------------------------------
    virtual task pre_write(input uvm_ral_mem       mem,
                           inout uvm_ral_addr_t    offset,
                           inout uvm_ral_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object extension);
    endtask


   //--------------------------------------------------------------------------
   // TASK: post_write
   // 
   // Called after user-defined backdoor memory write.
   //
   // The registered callback methods are invoked before the invocation
   // of the <uvm_ral_mem_backdoor::post_write()> method.
   //--------------------------------------------------------------------------
    virtual task post_write(input uvm_ral_mem       mem,
                            inout uvm_ral::status_e status,
                            inout uvm_ral_addr_t    offset,
                            input uvm_ral_data_t    data,
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
    virtual function uvm_ral_data_t  encode(uvm_ral_data_t  data);
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
    virtual function uvm_ral_data_t  decode(uvm_ral_data_t  data);
      return data;
    endfunction

endclass



//------------------------------------------------------------------------------
// CLASS: uvm_ral_reg_backdoor
//
// Base class for user-defined back-door register access.
//
// This class can be extended by users to provide
// user-specific back-door access to registers
// that are not implemented in pure SystemVerilog
// or that are not accessible using the default DPI backdoor mechanism.
//------------------------------------------------------------------------------
class uvm_ral_reg_backdoor extends uvm_object;
   string fname = "";
   int lineno = 0;
   uvm_ral_reg rg;
   local uvm_ral_reg_backdoor_callbacks backdoor_callbacks[$];

   local process update_thread;

   `uvm_object_utils(uvm_ral_reg_backdoor)


   //--------------------------------------------------------------------------
   // FUNCTION: new
   //
   // Create an instance of this class
   //
   // Create an instance of the user-defined backdoor class
   // for the specified register
   //--------------------------------------------------------------------------
   function new(input uvm_ral_reg rg=null);
      super.new(rg.get_full_name());
      this.rg = rg;
   endfunction: new


   //--------------------------------------------------------------------------
   // TASK: do_pre_read
   //
   // Execute the pre-read callbacks
   //
   // This method ~must~ be called as the first statement in
   // a user extension of the <read()> method.
   //--------------------------------------------------------------------------
   protected task do_pre_read(input uvm_sequence_base parent,
                              input uvm_object        extension);
      pre_read(parent, extension);
      `uvm_do_obj_callbacks(uvm_ral_reg_backdoor,
                            uvm_ral_reg_backdoor_callbacks,
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
   protected task do_post_read(inout uvm_ral::status_e status,
                               inout uvm_ral_data_t    data,
                               input uvm_sequence_base parent,
                               input uvm_object        extension);
      begin
         uvm_callback_iter#(uvm_ral_reg_backdoor,
                            uvm_ral_reg_backdoor_callbacks) iter = new(this);
         for(uvm_ral_reg_backdoor_callbacks cb = iter.last();
             cb != null;
             cb = iter.prev()) data = cb.decode(data);
      end
      `uvm_do_obj_callbacks(uvm_ral_reg_backdoor,
                            uvm_ral_reg_backdoor_callbacks,
                            this,
                            post_read(rg, status, data, parent, extension))
      post_read(status, data, parent, extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: do_pre_write
   //
   // Execute the pre-write callbacks
   //
   // This method ~must~ be called as the first statement in
   // a user extension of the <write()> method.
   //--------------------------------------------------------------------------
   protected task do_pre_write(inout uvm_ral_data_t    data,
                               input uvm_sequence_base parent,
                               input uvm_object        extension);
      pre_write(data, parent, extension);
      `uvm_do_obj_callbacks(uvm_ral_reg_backdoor,
                            uvm_ral_reg_backdoor_callbacks,
                            this,
                            pre_write(rg, data, parent, extension))
      begin
         uvm_callback_iter#(uvm_ral_reg_backdoor,
                            uvm_ral_reg_backdoor_callbacks) iter = new(this);
         for(uvm_ral_reg_backdoor_callbacks cb = iter.first();
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
   protected task do_post_write(inout uvm_ral::status_e status,
                                input uvm_ral_data_t    data,
                                input uvm_sequence_base parent,
                                input uvm_object        extension);
      `uvm_do_obj_callbacks(uvm_ral_reg_backdoor,
                            uvm_ral_reg_backdoor_callbacks,
                            this,
                            post_write(rg, status, data, parent, extension))
      post_write(status, data, parent, extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: write
   //
   // User-defined backdoor write operation.
   //
   // Call <do_pre_write()>.
   // Deposit the specified value in the register corresponding
   // to the instance of this class.
   // Call <do_post_write()>
   // Returns an indication of the success of the operation.
   //
   //--------------------------------------------------------------------------
   extern virtual task write(output uvm_ral::status_e status,
                             input  uvm_ral_data_t    data,
                             input uvm_sequence_base  parent,
                             input uvm_object extension);


   //--------------------------------------------------------------------------
   // TASK: read
   //
   // User-defined backdoor read operation.
   //
   // Overload this method only if the backdoor requires the use of task.
   //
   // Call <do_pre_read()>.
   // Peek the current value in the register corresponding
   // to the instance of this class.
   // Call <do_post_read()>
   // Returns the current value and an indication of the success of
   // the operation.
   //
   // By default, calls <read_func()>.
   //--------------------------------------------------------------------------
   extern virtual task read(output uvm_ral::status_e  status,
                            output uvm_ral_data_t     data,
                            input  uvm_sequence_base  parent,
                            input  uvm_object         extension);

   //--------------------------------------------------------------------------
   // FUNCTION: read_func
   //
   // User-defined backdoor read operation.
   //
   // Peek the current value in the register corresponding
   // to the instance of this class.
   // Returns the current value and an indication of the success of
   // the operation.
   //--------------------------------------------------------------------------
   extern virtual function uvm_ral::status_e read_func(
                            output uvm_ral::status_e  status,
                            output uvm_ral_data_t     data,
                            input  uvm_sequence_base  parent,
                            input  uvm_object         extension);


   //--------------------------------------------------------------------------
   // FUNCTION: is_auto_updated
   //
   // Indicates if wait_for_change() method is implemented
   //
   // Implement to return TRUE if and only if
   // <wait_for_change()> is implemented.
   //--------------------------------------------------------------------------
   extern virtual function bit is_auto_updated(string fieldname);


   //--------------------------------------------------------------------------
   // TASK: wait_for_change
   //
   // Wait for a change in the value of the register in the DUT.
   //
   // When this method returns, the mirror value for the register
   // corresponding to this instance of the backdoor class will be updated
   // via a backdoor read operation.
   //--------------------------------------------------------------------------
   extern virtual task wait_for_change();

  
   /*local*/ extern function void start_update_thread(uvm_ral_reg rg);
   /*local*/ extern function void kill_update_thread();


   //--------------------------------------------------------------------------
   // TASK: pre_read
   //
   // Called before user-defined backdoor register read.
   //
   // The registered callback methods are invoked after the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task pre_read(uvm_sequence_base parent,
                         input uvm_object extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: post_read
   //
   // Called after user-defined backdoor register read.
   //
   // The registered callback methods are invoked before the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task post_read(inout uvm_ral::status_e status,
                          inout uvm_ral_data_t    data,
                          input uvm_sequence_base parent,
                          input uvm_object extension);
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
   virtual task pre_write(inout uvm_ral_data_t    data,
                          input uvm_sequence_base parent,
                          input uvm_object extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: post_write
   //
   // Called after user-defined backdoor register write.
   //
   // The registered callback methods are invoked before the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task post_write(inout uvm_ral::status_e status,
                           input uvm_ral_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object extension);
   endtask
endclass: uvm_ral_reg_backdoor



//------------------------------------------------------------------------------
// CLASS: uvm_ral_mem_backdoor
//
// Base class for user-defined back-door memory access.
//
// This class can be extended by users to provide
// user-specific back-door access to a memory
// that are not implemented in pure SystemVerilog
// or that are not accessible using the default DPI backdoor mechanism.
//------------------------------------------------------------------------------
class uvm_ral_mem_backdoor extends uvm_object;
   string fname = "";
   int lineno = 0;
   uvm_ral_mem mem;
   local uvm_ral_mem_backdoor_callbacks backdoor_callbacks[$];

   `uvm_object_utils(uvm_ral_mem_backdoor)


   //--------------------------------------------------------------------------
   // FUNCTION: new
   //
   // Create an instance of this class
   //
   // Create an instance of the user-defined backdoor class
   // for the specified register
   //--------------------------------------------------------------------------
   function new(input uvm_ral_mem mem=null);
      super.new(mem.get_full_name());
      this.mem = mem;
   endfunction


   //--------------------------------------------------------------------------
   // TASK: do_pre_read
   //
   // Execute the pre-read callbacks
   //
   // This method ~must~ be called as the first statement in
   // a user extension of the <read()> method.
   //--------------------------------------------------------------------------
   protected task do_pre_read(inout uvm_ral_addr_t    offset,
                              input uvm_sequence_base parent,
                              input uvm_object        extension);
      pre_read(offset, parent, extension);
      `uvm_do_obj_callbacks(uvm_ral_mem_backdoor,
                            uvm_ral_mem_backdoor_callbacks,
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
   protected task do_post_read(inout uvm_ral::status_e status,
                               input uvm_ral_addr_t    offset,
                               inout uvm_ral_data_t    data,
                               input uvm_sequence_base parent,
                               input uvm_object        extension);
      begin
         uvm_callback_iter#(uvm_ral_mem_backdoor,
                            uvm_ral_mem_backdoor_callbacks) iter = new(this);
         for(uvm_ral_mem_backdoor_callbacks cb = iter.last();
             cb != null;
             cb = iter.prev()) data = cb.decode(data);
      end
      `uvm_do_obj_callbacks(uvm_ral_mem_backdoor,
                            uvm_ral_mem_backdoor_callbacks,
                            this,
                            post_read(mem, status, offset, data, parent, extension))
      post_read(status, offset, data, parent, extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: do_pre_write
   //
   // Execute the pre-write callbacks
   //
   // This method ~must~ be called as the first statement in
   // a user extension of the <write()> method.
   //--------------------------------------------------------------------------
   protected task do_pre_write(inout uvm_ral_addr_t    offset,
                               inout uvm_ral_data_t    data,
                               input uvm_sequence_base parent,
                               input uvm_object         extension);
      pre_write(offset, data, parent, extension);
      `uvm_do_obj_callbacks(uvm_ral_mem_backdoor,
                            uvm_ral_mem_backdoor_callbacks,
                            this,
                            pre_write(mem, offset, data, parent, extension))
      begin
         uvm_callback_iter#(uvm_ral_mem_backdoor,
                            uvm_ral_mem_backdoor_callbacks) iter = new(this);
         for(uvm_ral_mem_backdoor_callbacks cb = iter.first();
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
   protected task do_post_write(inout uvm_ral::status_e status,
                                input uvm_ral_addr_t    offset,
                                input uvm_ral_data_t    data,
                                input uvm_sequence_base parent,
                                input uvm_object        extension);
      `uvm_do_obj_callbacks(uvm_ral_mem_backdoor,
                            uvm_ral_mem_backdoor_callbacks,
                            this,
                            post_write(mem, status, offset, data, parent, extension))
      post_write(status, offset, data, parent, extension);
   endtask


   //--------------------------------------------------------------------------
   // TASK: write
   //
   // User-defined backdoor write operation.
   //
   // Call <do_pre_write()>.
   // Deposit the specified value in the memory location corresponding
   // to the instance of this class.
   // Call <do_post_write()>
   // Returns an indication of the success of the operation.
   //
   //--------------------------------------------------------------------------
   extern virtual task write(output uvm_ral::status_e              status,
                             input  uvm_ral_addr_t  offset,
                             input  uvm_ral_data_t  data,
                             input  uvm_sequence_base parent,
                             input uvm_object extension);


   //--------------------------------------------------------------------------
   // TASK: read
   //
   // User-defined backdoor read operation.
   //
   // Overload this method only if the backdoor requires the use of task.
   //
   // Call <do_pre_read()>.
   // Peek the current value in the memory corresponding
   // to the instance of this class.
   // Call <do_post_read()>
   // Returns the current value and an indication of the success of
   // the operation.
   //
   // By default, calls <read_func()>.
   //--------------------------------------------------------------------------
   extern virtual task read(output uvm_ral::status_e  status,
                            input  uvm_ral_addr_t     offset,
                            output uvm_ral_data_t     data,
                            input  uvm_sequence_base  parent,
                            input  uvm_object         extension);

   //--------------------------------------------------------------------------
   // FUNCTION: read_func
   //
   // User-defined backdoor read operation.
   //
   // Peek the current value in the memory corresponding
   // to the instance of this class.
   // Returns the current value and an indication of the success of
   // the operation.
   //--------------------------------------------------------------------------
   extern virtual function uvm_ral::status_e read_func(
                                       output uvm_ral::status_e  status,
                                       input  uvm_ral_addr_t     offset,
                                       output uvm_ral_data_t     data,
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
   virtual task pre_read(inout uvm_ral_addr_t    offset,
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
   virtual task post_read(inout uvm_ral::status_e status,
                          inout uvm_ral_addr_t    offset,
                          inout uvm_ral_data_t    data,
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
   virtual task pre_write(inout uvm_ral_addr_t    offset,
                          inout uvm_ral_data_t    data,
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
   virtual task post_write(inout uvm_ral::status_e status,
                           inout uvm_ral_addr_t    offset,
                           input uvm_ral_data_t    data,
                           input uvm_sequence_base parent,
                           input uvm_object        extension);
   endtask
endclass: uvm_ral_mem_backdoor


//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

function bit uvm_ral_reg_backdoor::is_auto_updated(string fieldname);
   `uvm_fatal("RAL", "uvm_ral_reg_backdoor::is_auto_updated() method has not been overloaded");
  return 0;
endfunction

task uvm_ral_reg_backdoor::wait_for_change();
   `uvm_fatal("RAL", "uvm_ral_reg_backdoor::wait_for_change() method has not been overloaded");
endtask

function void uvm_ral_reg_backdoor::start_update_thread(uvm_ral_reg rg);
   if (this.update_thread != null) begin
      this.kill_update_thread();
   end

   fork
      begin
         uvm_ral_field fields[$];

         this.update_thread = process::self();
         rg.get_fields(fields);
         forever begin
            uvm_ral::status_e status;
            uvm_ral_data_t  val;
            this.read(status, val, null, null);
            if (status != uvm_ral::IS_OK) begin
               `uvm_error("RAL", $psprintf("Backdoor read of register '%s' failed.",
                          rg.get_name()));
            end
            foreach (fields[i]) begin
               if (this.is_auto_updated(fields[i].get_name())) begin
                  uvm_ral_data_t  fld_val
                     = val >> fields[i].get_lsb_pos_in_register();
                  fld_val = fld_val & ((1 << fields[i].get_n_bits())-1);
                  void'(fields[i].predict(fld_val));
               end
            end
            this.wait_for_change();
         end
      end
   join_none
endfunction

function void uvm_ral_reg_backdoor::kill_update_thread();
   if (this.update_thread != null) begin
      this.update_thread.kill();
   end
endfunction

task uvm_ral_reg_backdoor::write(output uvm_ral::status_e status,
                                 input  uvm_ral_data_t    data,
                                 input  uvm_sequence_base parent,
                                 input uvm_object         extension);

   `uvm_fatal("RAL", "uvm_ral_reg_backdoor::write() method has not been overloaded");

endtask: write


task uvm_ral_reg_backdoor::read(output uvm_ral::status_e status,
                                output uvm_ral_data_t    data,
                                input  uvm_sequence_base parent,
                                input  uvm_object        extension);
   do_pre_read(parent, extension);
   status = read_func(status, data,parent,extension);
   do_post_read(status, data, parent, extension);
endtask: read


function uvm_ral::status_e uvm_ral_reg_backdoor::read_func(
                            output uvm_ral::status_e status,
                            output uvm_ral_data_t    data,
                            input uvm_sequence_base  parent,
                            input uvm_object         extension);
   `uvm_fatal("RAL", "uvm_ral_reg_backdoor::read_func() method has not been overloaded");
   return uvm_ral::ERROR;
endfunction


task uvm_ral_mem_backdoor::write(output uvm_ral::status_e status,
                                 input  uvm_ral_addr_t    offset,
                                 input  uvm_ral_data_t    data,
                                 input  uvm_sequence_base parent,
                                 input  uvm_object        extension);

   `uvm_fatal("RAL", "uvm_ral_mem_backdoor::write() method has not been overloaded");

endtask: write


task uvm_ral_mem_backdoor::read(output uvm_ral::status_e status,
                                input  uvm_ral_addr_t    offset,
                                output uvm_ral_data_t    data,
                                input  uvm_sequence_base parent,
                                input  uvm_object        extension);
   do_pre_read(offset, parent, extension);
   status = read_func(status, offset, data, parent,extension);
   do_post_read(status, offset, data, parent, extension);
endtask: read


function uvm_ral::status_e uvm_ral_mem_backdoor::read_func(
                                       output uvm_ral::status_e status,
                                       input  uvm_ral_addr_t    offset,
                                       output uvm_ral_data_t    data,
                                       input  uvm_sequence_base parent,
                                       input  uvm_object        extension);
   `uvm_fatal("RAL", "uvm_ral_mem_backdoor::read_func() method has not been overloaded");
   return uvm_ral::ERROR;
endfunction
