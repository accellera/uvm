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

typedef class uvm_reg;
typedef class uvm_mem;
typedef class uvm_reg_backdoor;

//------------------------------------------------------------------------------
// Class: uvm_reg_cbs
//
// Façade class for field, register, memory and backdoor
// access callback methods. 
//------------------------------------------------------------------------------

virtual class uvm_reg_cbs extends uvm_callback;

   function new(string name = "uvm_reg_cbs");
      super.new(name);
   endfunction


   // Task: pre_write
   //
   // Called before a write operation.
   //
   // All registered ~pre_write~ callback methods are invoked after the
   // invocation of the ~pre_write~ method of associated object (<uvm_reg>,
   // <uvm_reg_field>, <uvm_mem>, or <uvm_reg_backdoor>). If the element being
   // written is a <uvm_reg>, all ~pre_write~ callback methods are invoked
   // before the contained <uvm_reg_fields>. 
   //
   // Backdoor - <uvm_reg_backdoor::pre_write>,
   //            <uvm_reg_cbs::pre_write> cbs for backdoor.
   //
   // Register - <uvm_reg::pre_write>,
   //            <uvm_reg_cbs::pre_write> cbs for reg,
   //            then foreach field:
   //              <uvm_reg_field::pre_write>, 
   //              <uvm_reg_cbs::pre_write> cbs for field
   //
   // RegField - <uvm_reg_field::pre_write>,
   //            <uvm_reg_cbs::pre_write> cbs for field
   //
   // Memory   - <uvm_mem::pre_write>,
   //            <uvm_reg_cbs::pre_write> cbs for mem
   //
   // The ~rw~ argument holds information about the operation.
   //
   // - Modifying the ~value~ modifies the actual value written.
   //
   // - For memories, modifying the ~offset~ modifies the offset
   //   used in the operation.
   //
   // - For non-backdoor operations, modifying the access ~path~ or
   //   address ~map~ modifies the actual path or map used in the
   //   operation.
   //
   // See <uvm_reg_item> for details on ~rw~ information.
   //
   virtual task pre_write(uvm_reg_item rw); endtask


   // Task: post_write
   //
   // Called after user-defined backdoor register write.
   //
   // All registered ~post_write~ callback methods are invoked before the
   // invocation of the ~post_write~ method of the associated object (<uvm_reg>,
   // <uvm_reg_field>, <uvm_mem>, or <uvm_reg_backdoor>). If the element being
   // written is a <uvm_reg>, all ~post_write~ callback methods are invoked
   // before the contained <uvm_reg_fields>. 
   //
   // Summary of callback order:
   //
   // Backdoor - <uvm_reg_cbs::post_write> cbs for backdoor,
   //            <uvm_reg_backdoor::post_write>
   //
   // Register - <uvm_reg_cbs::post_write> cbs for reg,
   //            <uvm_reg::post_write>,
   //            then foreach field:
   //              <uvm_reg_cbs::post_write> cbs for field,
   //              <uvm_reg_field::post_read>
   //
   // RegField - <uvm_reg_cbs::post_write> cbs for field,
   //            <uvm_reg_field::post_write>
   //
   // Memory   - <uvm_reg_cbs::post_write> cbs for mem,
   //            <uvm_mem::post_write>
   //
   // The ~rw~ argument holds information about the operation.
   //
   // - Modifying the ~status~ member modifies the returned status.
   //
   // - Modiying the ~value~ or ~offset~ members has no effect, as
   //   the operation has already completed.
   //
   // See <uvm_reg_item> for details on ~rw~ information.
   //
   virtual task post_write(uvm_reg_item rw); endtask


   // Task: pre_read
   //
   // Callback called before a read operation.
   //
   // All registered ~pre_read~ callback methods are invoked after the
   // invocation of the ~pre_read~ method of associated object (<uvm_reg>,
   // <uvm_reg_field>, <uvm_mem>, or <uvm_reg_backdoor>). If the element being
   // read is a <uvm_reg>, all ~pre_read~ callback methods are invoked before
   // the contained <uvm_reg_fields>. 
   //
   // Backdoor - <uvm_reg_backdoor::pre_read>,
   //            <uvm_reg_cbs::pre_read> cbs for backdoor
   //
   // Register - <uvm_reg::pre_read>,
   //            <uvm_reg_cbs::pre_read> cbs for reg,
   //            then foreach field:
   //              <uvm_reg_field::pre_read>,
   //              <uvm_reg_cbs::pre_read> cbs for field
   //
   // RegField - <uvm_reg_field::pre_read>,
   //            <uvm_reg_cbs::pre_read> cbs for field
   //
   // Memory   - <uvm_mem::pre_read>,
   //            <uvm_reg_cbs::pre_read> cbs for mem
   //
   // The ~rw~ argument holds information about the operation.
   //
   // - The ~value~ member of ~rw~ is not used has no effect if modified.
   //
   // - For memories, modifying the ~offset~ modifies the offset
   //   used in the operation.
   //
   // - For non-backdoor operations, modifying the access ~path~ or
   //   address ~map~ modifies the actual path or map used in the
   //   operation.
   //
   // See <uvm_reg_item> for details on ~rw~ information.
   //
   virtual task pre_read(uvm_reg_item rw); endtask


   // Task: post_read
   //
   // Callback called after a read operation.
   //
   // All registered ~post_read~ callback methods are invoked before the
   // invocation of the ~post_read~ method of the associated object (<uvm_reg>,
   // <uvm_reg_field>, <uvm_mem>, or <uvm_reg_backdoor>). If the element being read
   // is a <uvm_reg>, all ~post_read~ callback methods are invoked before the
   // contained <uvm_reg_fields>. 
   //
   // Backdoor - <uvm_reg_cbs::post_read> cbs for backdoor,
   //            <uvm_reg_backdoor::post_read>
   //
   // Register - <uvm_reg_cbs::post_read> cbs for reg,
   //            <uvm_reg::post_read>,
   //            then foreach field:
   //              <uvm_reg_cbs::post_read> cbs for field,
   //              <uvm_reg_field::post_read>
   //
   // RegField - <uvm_reg_cbs::post_read> cbs for field,
   //            <uvm_reg_field::post_read>
   //
   // Memory   - <uvm_reg_cbs::post_read> cbs for mem,
   //            <uvm_mem::post_read>
   //
   // The ~rw~ argument holds information about the operation.
   //
   // - Modifying the readback ~value~ or ~status~ modifies the actual
   //   returned value and status.
   //
   // - Modiying the ~value~ or ~offset~ members has no effect, as
   //   the operation has already completed.
   //
   // See <uvm_reg_item> for details on ~rw~ information.
   //
   virtual task post_read(uvm_reg_item rw); endtask


   // Function: encode
   //
   // Data encoder
   //
   // The registered callback methods are invoked in order of registration
   // after all the ~pre_write~ methods have been called.
   // The encoded data is passed through each invocation in sequence.
   // This allows the ~pre_write~ methods to deal with clear-text data.
   //
   // By default, the data is not modified.
   //
   virtual function void encode(ref uvm_reg_data_t data[]);
   endfunction


   // Function: decode
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
   //
   virtual function void decode(ref uvm_reg_data_t data[]);
   endfunction



endclass



// Type: uvm_reg_cb
//
// Convenience callback type declaration
//
// Use this declaration to register register callbacks rather than
// the more verbose parameterized class
//
typedef uvm_callbacks#(uvm_reg, uvm_reg_cbs) uvm_reg_cb;


// Type: uvm_reg_cb_iter
//
// Convenience callback iterator type declaration
//
// Use this declaration to iterate over registered register callbacks
// rather than the more verbose parameterized class
//
typedef uvm_callback_iter#(uvm_reg, uvm_reg_cbs) uvm_reg_cb_iter;


// Type: uvm_reg_bd_cb
//
// Convenience callback type declaration
//
// Use this declaration to register register backdoor callbacks rather than
// the more verbose parameterized class
//
typedef uvm_callbacks#(uvm_reg_backdoor, uvm_reg_cbs) uvm_reg_bd_cb;


// Type: uvm_reg_bd_cb_iter
// Convenience callback iterator type declaration
//
// Use this declaration to iterate over registered register backdoor callbacks
// rather than the more verbose parameterized class
//

typedef uvm_callback_iter#(uvm_reg_backdoor, uvm_reg_cbs) uvm_reg_bd_cb_iter;


// Type: uvm_mem_cb
//
// Convenience callback type declaration
//
// Use this declaration to register memory callbacks rather than
// the more verbose parameterized class
//
typedef uvm_callbacks#(uvm_mem, uvm_reg_cbs) uvm_mem_cb;


// Type: uvm_mem_cb_iter
//
// Convenience callback iterator type declaration
//
// Use this declaration to iterate over registered memory callbacks
// rather than the more verbose parameterized class
//
typedef uvm_callback_iter#(uvm_mem, uvm_reg_cbs) uvm_mem_cb_iter;


// Type: uvm_reg_field_cb
//
// Convenience callback type declaration
//
// Use this declaration to register field callbacks rather than
// the more verbose parameterized class
//
typedef uvm_callbacks#(uvm_reg_field, uvm_reg_cbs) uvm_reg_field_cb;


// Type: uvm_reg_field_cb_iter
//
// Convenience callback iterator type declaration
//
// Use this declaration to iterate over registered field callbacks
// rather than the more verbose parameterized class
//
typedef uvm_callback_iter#(uvm_reg_field, uvm_reg_cbs) uvm_reg_field_cb_iter;


