//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

// Title: Sequence and Do Action Macros


//-----------------------------------------------------------------------------
//
// Group: Sequence Registration Macros
//
// The sequence-specific macros perform the same function as the set of
// `uvm_object_*_utils macros, except they also set the default sequencer type
// the sequence will run on. 
//-----------------------------------------------------------------------------

`define uvm_register_sequence(TYPE_NAME, SEQUENCER) \
  static bit is_registered_with_sequencer = SEQUENCER``::add_typewide_sequence(`"TYPE_NAME`");

// MACRO: `uvm_declare_p_sequencer
//
// This macro is used to set up a specific sequencer type with the
// sequence type the macro is placed in. This macro is implicit in the
// <uvm_sequence_utils> macro, but may be used directly in cases when
// the sequence is not to be registered in the sequencer's library.
//
// The example below shows using the the uvm_declare_p_sequencer macro
// along with the uvm_object_utils macros to set up the sequence but
// not register the sequence in the sequencer's library.
//
//| class mysequence extends uvm_sequence#(mydata);
//|   `uvm_object_utils(mysequence)
//|   `uvm_declare_p_sequencer(some_seqr_type)
//|   task body;
//|     //Access some variable in the user's custom sequencer
//|     if(p_sequencer.some_variable) begin
//|       ...
//|     end
//|   endtask
//| endclass
//

`define uvm_declare_p_sequencer(SEQUENCER) \
  SEQUENCER p_sequencer;\
  virtual function void m_set_p_sequencer();\
    super.m_set_p_sequencer(); \
    if( !$cast(p_sequencer, m_sequencer)) \
        uvm_report_fatal("DCLPSQ", \
        $psprintf("%m %s Error casting p_sequencer, please verify that this sequence/sequence item is intended to execute on this type of sequencer", get_full_name()), UVM_NONE); \
  endfunction  


// MACRO: `uvm_sequence_utils_begin
//
`define uvm_sequence_utils_begin(TYPE_NAME, SEQUENCER) \
  `uvm_register_sequence(TYPE_NAME, SEQUENCER) \
  `uvm_declare_p_sequencer(SEQUENCER) \
  `uvm_object_utils_begin(TYPE_NAME)

// MACRO: `uvm_sequence_utils_end
//
`define uvm_sequence_utils_end \
  `uvm_object_utils_end

// MACRO: `uvm_sequence_utils
//
// The sequence macros can be used in non-parameterized <uvm_sequence>
// extensions to pre-register the sequence with a given <uvm_sequencer>
// type.
//
// For sequences that do not use any `uvm_field macros:
//
//|  `uvm_sequence_utils(TYPE_NAME,SQR_TYPE_NAME)
//
// For sequences employing with field macros:
//
//|  `uvm_sequence_utils_begin(TYPE_NAME,SQR_TYPE_NAME)
//|    `uvm_field_* macro invocations here
//|  `uvm_sequence_utils_end
//
// The sequence-specific macros perform the same function as the set of
// `uvm_object_*_utils macros except that they also register the sequence's
// type, TYPE_NAME, with the given sequencer type, SQR_TYPE_NAME, and define
// the p_sequencer variable and m_set_p_sequencer method.
//
// Use `uvm_sequence_utils[_begin] for non-parameterized classes and
// `uvm_sequence_param_utils[_begin] for parameterized classes.

`define uvm_sequence_utils(TYPE_NAME, SEQUENCER) \
  `uvm_sequence_utils_begin(TYPE_NAME,SEQUENCER) \
  `uvm_sequence_utils_end


//-----------------------------------------------------------------------------
//
// Group: Sequencer Registration Macros
//
// The sequencer-specific macros perform the same function as the set of
// `uvm_componenent_*utils macros except that they also declare the plumbing
// necessary for creating the sequencer's sequence library.
//-----------------------------------------------------------------------------

`define uvm_declare_sequence_lib \
  protected bit m_set_sequences_called = 1;    \
  static protected string m_static_sequences[$]; \
  static protected string m_static_remove_sequences[$]; \
  static function bit add_typewide_sequence(string type_name); \
    m_static_sequences.push_back(type_name); \
    return 1; \
  endfunction\
  static function bit remove_typewide_sequence(string type_name); \
    m_static_remove_sequences.push_back(type_name); \
    for (int i = 0; i < m_static_sequences.size(); i++) begin \
      if (m_static_sequences[i] == type_name) \
        m_static_sequences.delete(i); \
    end \
    return 1;\
  endfunction\
  function void uvm_update_sequence_lib();\
    if(this.m_set_sequences_called) begin \
      set_sequences_queue(m_static_sequences); \
      this.m_set_sequences_called = 0;\
    end\
    for (int i = 0; i < m_static_remove_sequences.size(); i++) begin \
      remove_sequence(m_static_remove_sequences[i]); \
    end \
  endfunction\


// MACRO: `uvm_update_sequence_lib
//
// This macro populates the instance-specific sequence library for a sequencer.
// It should be invoked inside the sequencer¿s constructor.

`define uvm_update_sequence_lib \
  m_add_builtin_seqs(0); \
  uvm_update_sequence_lib();


// MACRO: `uvm_update_sequence_lib_and_item
//
// This macro populates the instance specific sequence library for a sequencer,
// and it registers the given ~USER_ITEM~ as an instance override for the simple
// sequence's item variable.
//
// The macro should be invoked inside the sequencer's constructor.

`define uvm_update_sequence_lib_and_item(USER_ITEM) \
  factory.set_inst_override_by_type( \
    uvm_sequence_item::get_type(), USER_ITEM::get_type(), \
    {get_full_name(), "*.item"}); \
  m_add_builtin_seqs(1); \
  uvm_update_sequence_lib();


// MACRO: `uvm_sequencer_utils

`define uvm_sequencer_utils(TYPE_NAME) \
  `uvm_sequencer_utils_begin(TYPE_NAME) \
  `uvm_sequencer_utils_end

// MACRO: `uvm_sequencer_utils_begin

`define uvm_sequencer_utils_begin(TYPE_NAME) \
  `uvm_declare_sequence_lib \
  `uvm_component_utils_begin(TYPE_NAME)

// MACRO: `uvm_sequencer_param_utils

`define uvm_sequencer_param_utils(TYPE_NAME) \
  `uvm_sequencer_param_utils_begin(TYPE_NAME) \
  `uvm_sequencer_utils_end

// MACRO: `uvm_sequencer_param_utils_begin

`define uvm_sequencer_param_utils_begin(TYPE_NAME) \
  `uvm_declare_sequence_lib \
  `uvm_component_param_utils_begin(TYPE_NAME)

// MACRO: `uvm_sequencer_utils_end
//
// The sequencer macros are used in uvm_sequencer-based class declarations
// in one of four ways.
//
// For simple sequencers, no field macros
//
//   `uvm_sequencer_utils(SQR_TYPE_NAME)
//
// For simple sequencers, with field macros
//
//   `uvm_sequencer_utils_begin(SQR_TYPE_NAME)
//     `uvm_field_* macros here
//   `uvm_sequencer_utils_end
//
// For parameterized sequencers, no field macros
//
//   `uvm_sequencer_param_utils(SQR_TYPE_NAME)
//
// For parameterized sequencers, with field macros
//
//   `uvm_sequencer_param_utils_begin(SQR_TYPE_NAME)
//     `uvm_field_* macros here
//   `uvm_sequencer_utils_end
//
// The sequencer-specific macros perform the same function as the set of
// `uvm_componenent_*utils macros except that they also declare the plumbing
// necessary for creating the sequencer's sequence library. This includes:
//
// 1. Declaring the type-based static queue of strings registered on the
//    sequencer type.
//
// 2. Declaring the static function to add strings to item #1 above.
//
// 3. Declaring the static function to remove strings to item #1 above.
//
// 4. Declaring the function to populate the instance specific sequence library
//    for a sequencer.
//
// Use `uvm_sequencer_utils[_begin] for non-parameterized classes and
// `uvm_sequencer_param_utils[_begin] for parameterized classes.

`define uvm_sequencer_utils_end \
  `uvm_component_utils_end



//-----------------------------------------------------------------------------
//
// Group: Sequence Action Macros
//
// These macros are used to start sequences and sequence items that were either
// registered with a <`uvm-sequence_utils> macro or whose associated sequencer
// was already set using the <set_sequencer> method.
//-----------------------------------------------------------------------------

// MACRO: `uvm_create
//
// This action creates the item or sequence using the factory.  It intentionally
// does zero processing.  After this action completes, the user can manually set
// values, manipulate rand_mode and constraint_mode, etc.

`define uvm_create(UVM_SEQUENCE_ITEM) \
  begin \
  uvm_object_wrapper w_; w_ = UVM_SEQUENCE_ITEM.get_type(); \
  $cast(UVM_SEQUENCE_ITEM , create_item(w_, m_sequencer, `"UVM_SEQUENCE_ITEM`"));\
  end\


// MACRO: `uvm_do
//
// This macro takes as an argument a uvm_sequence_item variable or object.  
// uvm_sequence_item's are randomized _at the time_ the sequencer grants the
// do request. This is called late-randomization or late-generation. 
// In the case of a sequence a sub-sequence is spawned. In the case of an item,
// the item is sent to the driver through the associated sequencer.

`define uvm_do(UVM_SEQUENCE_ITEM) \
  begin \
  `uvm_create(UVM_SEQUENCE_ITEM) \
  start_item(UVM_SEQUENCE_ITEM); \
  if(!UVM_SEQUENCE_ITEM.randomize()) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_do action"); \
  end \
  finish_item(UVM_SEQUENCE_ITEM); \
  end


// MACRO: `uvm_do_pri
//
// This is the same as `uvm_do except that the sequene item or sequence is
// executed with the priority specified in the argument

`define uvm_do_pri(UVM_SEQUENCE_ITEM, PRIORITY) \
  begin \
  `uvm_create(UVM_SEQUENCE_ITEM) \
  start_item(UVM_SEQUENCE_ITEM, PRIORITY); \
  if (!UVM_SEQUENCE_ITEM.randomize()) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_do action"); \
  end \
  finish_item(UVM_SEQUENCE_ITEM, PRIORITY); \
  end


// MACRO: `uvm_do_with
//
// This is the same as `uvm_do except that the constraint block in the 2nd
// argument is applied to the item or sequence in a randomize with statement
// before execution.

`define uvm_do_with(UVM_SEQUENCE_ITEM, CONSTRAINTS) \
  begin \
  `uvm_create(UVM_SEQUENCE_ITEM) \
  start_item(UVM_SEQUENCE_ITEM);\
  if(!UVM_SEQUENCE_ITEM.randomize() with CONSTRAINTS ) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_do_with action"); \
  end\
  finish_item(UVM_SEQUENCE_ITEM);\
  end


// MACRO: `uvm_do_pri_with
//
// This is the same as `uvm_do_pri except that the given constraint block is
// applied to the item or sequence in a randomize with statement before
// execution.

`define uvm_do_pri_with(UVM_SEQUENCE_ITEM, PRIORITY, CONSTRAINTS) \
  begin \
  `uvm_create(UVM_SEQUENCE_ITEM) \
  start_item(UVM_SEQUENCE_ITEM, PRIORITY);\
  if(!UVM_SEQUENCE_ITEM.randomize() with CONSTRAINTS ) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_do_with action"); \
  end\
  finish_item(UVM_SEQUENCE_ITEM, PRIORITY);\
  end


// MACRO: `uvm_send
//
// This macro processes the item or sequence that has been created using
// `uvm_create.  The processing is done without randomization.  Essentially, an
// `uvm_do without the create or randomization.

`define uvm_send(UVM_SEQUENCE_ITEM) \
  begin \
  start_item(UVM_SEQUENCE_ITEM); \
  finish_item(UVM_SEQUENCE_ITEM);\
  end\
  

// MACRO: `uvm_send_pri
//
// This is the same as `uvm_send except that the sequene item or sequence is
// executed with the priority specified in the argument.

`define uvm_send_pri(UVM_SEQUENCE_ITEM, PRIORITY) \
  begin \
  start_item(UVM_SEQUENCE_ITEM, PRIORITY); \
  finish_item(UVM_SEQUENCE_ITEM, PRIORITY);\
  end\
  

// MACRO: `uvm_rand_send
//
// This macro processes the item or sequence that has been already been
// allocated (possibly with `uvm_create). The processing is done with
// randomization.  Essentially, an `uvm_do without the create.

`define uvm_rand_send(UVM_SEQUENCE_ITEM) \
  begin \
  start_item(UVM_SEQUENCE_ITEM); \
  if (!UVM_SEQUENCE_ITEM.randomize()) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_rand_send action"); \
  end \
  finish_item(UVM_SEQUENCE_ITEM);\
  end\


// MACRO: `uvm_rand_send_pri
//
// This is the same as `uvm_rand_send except that the sequene item or sequence
// is executed with the priority specified in the argument.

`define uvm_rand_send_pri(UVM_SEQUENCE_ITEM, PRIORITY) \
  begin \
  start_item(UVM_SEQUENCE_ITEM, PRIORITY); \
  if (!UVM_SEQUENCE_ITEM.randomize()) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_rand_send action"); \
  end \
  finish_item(UVM_SEQUENCE_ITEM, PRIORITY);\
  end\


// MACRO: `uvm_rand_send_with
//
// This is the same as `uvm_rand_send except that the given constraint block is
// applied to the item or sequence in a randomize with statement before
// execution.

`define uvm_rand_send_with(UVM_SEQUENCE_ITEM, CONSTRAINTS) \
  begin \
  start_item(UVM_SEQUENCE_ITEM); \
  if (!UVM_SEQUENCE_ITEM.randomize() with CONSTRAINTS ) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_rand_send_with action"); \
  end \
  finish_item(UVM_SEQUENCE_ITEM);\
  end\


// MACRO: `uvm_rand_send_pri_with
//
// This is the same as `uvm_rand_send_pri except that the given constraint block
// is applied to the item or sequence in a randomize with statement before
// execution.

`define uvm_rand_send_pri_with(UVM_SEQUENCE_ITEM, PRIORITY, CONSTRAINTS) \
  begin \
  start_item(UVM_SEQUENCE_ITEM, PRIORITY); \
  if (!UVM_SEQUENCE_ITEM.randomize() with CONSTRAINTS ) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_rand_send_with action"); \
  end \
  finish_item(UVM_SEQUENCE_ITEM, PRIORITY);\
  end\


//-----------------------------------------------------------------------------
//
// Group: Sequence on Sequencer Action Macros
//
// These macros are used to start sequences and sequence items on a specific
// sequencer, given in a macro argument.
//-----------------------------------------------------------------------------

// MACRO: `uvm_create_on
//
// This is the same as <`uvm_create> except that it also sets the parent sequence
// to the sequence in which the macro is invoked, and it sets the sequencer to
// the specified ~SEQUENCER_REF~ argument.

`define uvm_create_on(UVM_SEQUENCE_ITEM, SEQUENCER_REF) \
  begin \
  uvm_object_wrapper w_; w_ = UVM_SEQUENCE_ITEM.get_type(); \
  $cast(UVM_SEQUENCE_ITEM , create_item(w_, SEQUENCER_REF, `"UVM_SEQUENCE_ITEM`"));\
  end


// MACRO: `uvm_do_on
//
// This is the same as <`uvm_do> except that it also sets the parent sequence to
// the sequence in which the macro is invoked, and it sets the sequencer to the
// specified ~SEQUENCER_REF~ argument.

`define uvm_do_on(UVM_SEQUENCE_ITEM, SEQUENCER_REF) \
  begin \
  `uvm_create_on(UVM_SEQUENCE_ITEM, SEQUENCER_REF) \
  start_item(UVM_SEQUENCE_ITEM); \
  if (!UVM_SEQUENCE_ITEM.randomize()) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_do action"); \
  end \
  finish_item(UVM_SEQUENCE_ITEM); \
  end


// MACRO: `uvm_do_on_pri
//
// This is the same as <`uvm_do_pri> except that it also sets the parent sequence
// to the sequence in which the macro is invoked, and it sets the sequencer to
// the specified ~SEQUENCER_REF~ argument.

`define uvm_do_on_pri(UVM_SEQUENCE_ITEM, SEQUENCER_REF, PRIORITY) \
  begin \
  `uvm_create_on(UVM_SEQUENCE_ITEM, SEQUENCER_REF) \
  start_item(UVM_SEQUENCE_ITEM, PRIORITY); \
  if (!UVM_SEQUENCE_ITEM.randomize()) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_do action"); \
  end \
  finish_item(UVM_SEQUENCE_ITEM, PRIORITY); \
  end


// MACRO: `uvm_do_on_with
//
// This is the same as <`uvm_do_with> except that it also sets the parent
// sequence to the sequence in which the macro is invoked, and it sets the
// sequencer to the specified ~SEQUENCER_REF~ argument.
// The user must supply brackets around the constraints.

`define uvm_do_on_with(UVM_SEQUENCE_ITEM, SEQUENCER_REF, CONSTRAINTS) \
  begin \
  `uvm_create_on(UVM_SEQUENCE_ITEM, SEQUENCER_REF) \
  start_item(UVM_SEQUENCE_ITEM);\
  if (!UVM_SEQUENCE_ITEM.randomize() with CONSTRAINTS ) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_do_with action"); \
  end\
  finish_item(UVM_SEQUENCE_ITEM);\
  end


// MACRO: `uvm_do_on_pri_with
//
// This is the same as `uvm_do_pri_with except that it also sets the parent
// sequence to the sequence in which the macro is invoked, and it sets the
// sequencer to the specified ~SEQUENCER_REF~ argument.

`define uvm_do_on_pri_with(UVM_SEQUENCE_ITEM, SEQUENCER_REF, PRIORITY, CONSTRAINTS) \
  begin \
  `uvm_create_on(UVM_SEQUENCE_ITEM, SEQUENCER_REF) \
  start_item(UVM_SEQUENCE_ITEM, PRIORITY);\
  if (!UVM_SEQUENCE_ITEM.randomize() with CONSTRAINTS ) begin \
    uvm_report_warning("RNDFLD", "Randomization failed in uvm_do_with action"); \
  end\
  finish_item(UVM_SEQUENCE_ITEM, PRIORITY);\
  end


`define uvm_create_seq(UVM_SEQ, SEQR_CONS_IF) \
  begin \
  `uvm_create_on(UVM_SEQ, SEQR_CONS_IF.consumer_seqr) \
  end

`define uvm_do_seq(UVM_SEQ, SEQR_CONS_IF) \
  begin \
  `uvm_do_on(UVM_SEQ, SEQR_CONS_IF.consumer_seqr) \
  end

`define uvm_do_seq_with(UVM_SEQ, SEQR_CONS_IF, CONSTRAINTS) \
  begin\
  `uvm_do_on_with(UVM_SEQ, SEQR_CONS_IF.consumer_seqr, CONSTRAINTS) \
  end


//-----------------------------------------------------------------------------
//
// MACRO- `uvm_package
//
// Use `uvm_package to define the SV package and to create a bogus type to help 
// automate triggering the static initializers of the package.
// Use uvm_end_package to endpackage.
//-----------------------------------------------------------------------------

`define uvm_package(PKG) \
  package PKG; \
  class uvm_bogus_class extends uvm::uvm_sequence;\
  endclass

`define uvm_end_package \
   endpackage


//-----------------------------------------------------------------------------
//
// MACRO- `uvm_sequence_library_package
//
// This macro is used to trigger static initializers in packages. `uvm_package
// creates a bogus type which gets referred to by uvm_sequence_library_package
// to make a package-based variable of the bogus type.
//-----------------------------------------------------------------------------

`define uvm_sequence_library_package(PKG_NAME) \
  import PKG_NAME``::*; \
  PKG_NAME``::uvm_bogus_class M_``PKG_NAME``uvm_bogus_class

