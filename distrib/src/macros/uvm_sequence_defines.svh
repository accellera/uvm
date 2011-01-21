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

// Title: Do Action and Sequencer Macros


//-----------------------------------------------------------------------------
//
// Group: Sequence Action Macros
//
// These macros are used to start sequences and sequence items on the default
// sequencer, <uvm_sequence_base::m_sequencer>. The default sequencer is set
// any number of ways. 
// - the sequencer handle provided in the <uvm_sequence_base::start> method
// - the sequencer used by the parent sequence, the were either
// registered with a <`uvm_sequence_utils> macro or whose associated sequencer
// was already set using the <uvm_sequence_item::set_sequencer> method.
//-----------------------------------------------------------------------------

// MACRO: `uvm_create
//
// This action creates the item or sequence using the factory.  It intentionally
// does zero processing.  After this action completes, the user can manually set
// values, manipulate rand_mode and constraint_mode, etc.

`define uvm_create(UVM_SEQUENCE_ITEM) \
  `uvm_create_on(UVM_SEQUENCE_ITEM, m_sequencer)


// MACRO: `uvm_do
//
// This macro takes as an argument a uvm_sequence_item variable or object.  
// uvm_sequence_item's are randomized ~at the time~ the sequencer grants the
// do request. This is called late-randomization or late-generation. 
// In the case of a sequence a sub-sequence is spawned. In the case of an item,
// the item is sent to the driver through the associated sequencer.

`define uvm_do(UVM_SEQUENCE_ITEM) \
  `uvm_do_on_pri_with(UVM_SEQUENCE_ITEM, m_sequencer, -1, {})


// MACRO: `uvm_do_pri
//
// This is the same as `uvm_do except that the sequene item or sequence is
// executed with the priority specified in the argument

`define uvm_do_pri(UVM_SEQUENCE_ITEM, PRIORITY) \
  `uvm_do_on_pri_with(UVM_SEQUENCE_ITEM, m_sequencer, PRIORITY, {})


// MACRO: `uvm_do_with
//
// This is the same as `uvm_do except that the constraint block in the 2nd
// argument is applied to the item or sequence in a randomize with statement
// before execution.

`define uvm_do_with(UVM_SEQUENCE_ITEM, CONSTRAINTS) \
  `uvm_do_on_pri_with(UVM_SEQUENCE_ITEM, m_sequencer, -1, CONSTRAINTS)


// MACRO: `uvm_do_pri_with
//
// This is the same as `uvm_do_pri except that the given constraint block is
// applied to the item or sequence in a randomize with statement before
// execution.

`define uvm_do_pri_with(UVM_SEQUENCE_ITEM, PRIORITY, CONSTRAINTS) \
  `uvm_do_on_pri_with(UVM_SEQUENCER_ITEM, m_sequencer, PRIORITY, CONSTRAINTS)


//-----------------------------------------------------------------------------
//
// Group: Sequence on Sequencer Action Macros
//
// These macros are used to start sequences and sequence items on a specific
// sequencer. The sequence or item is created and executed on the given
// sequencer.
//-----------------------------------------------------------------------------

// MACRO: `uvm_create_on
//
// This is the same as <`uvm_create> except that it also sets the parent sequence
// to the sequence in which the macro is invoked, and it sets the sequencer to
// the specified ~SEQUENCER_REF~ argument.

`define uvm_create_on(UVM_SEQUENCE_ITEM, SEQUENCER_REF) \
  begin \
  uvm_object_wrapper w_; \
  w_ = UVM_SEQUENCE_ITEM.get_type(); \
  $cast(UVM_SEQUENCE_ITEM , create_item(w_, SEQUENCER_REF, `"UVM_SEQUENCE_ITEM`"));\
  end


// MACRO: `uvm_do_on
//
// This is the same as <`uvm_do> except that it also sets the parent sequence to
// the sequence in which the macro is invoked, and it sets the sequencer to the
// specified ~SEQUENCER_REF~ argument.

`define uvm_do_on(UVM_SEQUENCE_ITEM, SEQUENCER_REF) \
  `uvm_do_on_pri_with(UVM_SEQUENCE_ITEM, SEQUENCER_REF, -1, {})


// MACRO: `uvm_do_on_pri
//
// This is the same as <`uvm_do_pri> except that it also sets the parent sequence
// to the sequence in which the macro is invoked, and it sets the sequencer to
// the specified ~SEQUENCER_REF~ argument.

`define uvm_do_on_pri(UVM_SEQUENCE_ITEM, SEQUENCER_REF, PRIORITY) \
  `uvm_do_on_pri_with(UVM_SEQUENCE_ITEM, SEQUENCER_REF, PRIORITY, {})


// MACRO: `uvm_do_on_with
//
// This is the same as <`uvm_do_with> except that it also sets the parent
// sequence to the sequence in which the macro is invoked, and it sets the
// sequencer to the specified ~SEQUENCER_REF~ argument.
// The user must supply brackets around the constraints.

`define uvm_do_on_with(UVM_SEQUENCE_ITEM, SEQUENCER_REF, CONSTRAINTS) \
  `uvm_do_on_pri_with(UVM_SEQUENCE_ITEM, SEQUENCER_REF, -1, CONSTRAINTS)


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
    `uvm_warning("RNDFLD", "Randomization failed in uvm_do_with action") \
  end\
  finish_item(UVM_SEQUENCE_ITEM, PRIORITY);\
  end


//-----------------------------------------------------------------------------
//
// Group: Sequence Action Macros for Pre-Existing Sequences
//
// These macros are used to start sequences and sequence items that have
// already been allocated, i.e. do not need to be created. 
//-----------------------------------------------------------------------------


// MACRO: `uvm_send
//
// This macro processes the item or sequence that has been created using
// `uvm_create.  The processing is done without randomization.  Essentially, an
// `uvm_do without the create or randomization.

`define uvm_send(UVM_SEQUENCE_ITEM) \
  `uvm_send_pri(UVM_SEQUENCE_ITEM, -1)
  

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
  `uvm_rand_send_pri_with(UVM_SEQUENCE_ITEM, -1, {})


// MACRO: `uvm_rand_send_pri
//
// This is the same as `uvm_rand_send except that the sequene item or sequence
// is executed with the priority specified in the argument.

`define uvm_rand_send_pri(UVM_SEQUENCE_ITEM, PRIORITY) \
  `uvm_rand_send_pri_with(UVM_SEQUENCE_ITEM, PRIORITY, {})


// MACRO: `uvm_rand_send_with
//
// This is the same as `uvm_rand_send except that the given constraint block is
// applied to the item or sequence in a randomize with statement before
// execution.

`define uvm_rand_send_with(UVM_SEQUENCE_ITEM, CONSTRAINTS) \
  `uvm_rand_send_pri_with(UVM_SEQUENCE_ITEM, -1, CONSTRAINTS)


// MACRO: `uvm_rand_send_pri_with
//
// This is the same as `uvm_rand_send_pri except that the given constraint block
// is applied to the item or sequence in a randomize with statement before
// execution.

`define uvm_rand_send_pri_with(UVM_SEQUENCE_ITEM, PRIORITY, CONSTRAINTS) \
  begin \
  start_item(UVM_SEQUENCE_ITEM, PRIORITY); \
  if (!UVM_SEQUENCE_ITEM.randomize() with CONSTRAINTS ) begin \
    `uvm_warning("RNDFLD", "Randomization failed in uvm_rand_send_with action") \
  end \
  finish_item(UVM_SEQUENCE_ITEM, PRIORITY);\
  end\


`define uvm_create_seq(UVM_SEQ, SEQR_CONS_IF) \
  `uvm_create_on(UVM_SEQ, SEQR_CONS_IF.consumer_seqr) \

`define uvm_do_seq(UVM_SEQ, SEQR_CONS_IF) \
  `uvm_do_on(UVM_SEQ, SEQR_CONS_IF.consumer_seqr) \

`define uvm_do_seq_with(UVM_SEQ, SEQR_CONS_IF, CONSTRAINTS) \
  `uvm_do_on_with(UVM_SEQ, SEQR_CONS_IF.consumer_seqr, CONSTRAINTS) \



// Group: Sequencer Subtypes


// MACRO: `uvm_declare_p_sequencer
//
// This macro is used to set up a specific sequencer type with the
// sequence type the macro is placed in. This macro is implicit in the
// <`uvm_sequence_utils> macro, but may be used directly in cases when
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
        `uvm_fatal("DCLPSQ", \
        $psprintf("%m %s Error casting p_sequencer, please verify that this sequence/sequence item is intended to execute on this type of sequencer", get_full_name())) \
  endfunction  

