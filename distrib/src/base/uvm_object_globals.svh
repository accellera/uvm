//
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

//This bit marks where filtering should occur to remove uvm stuff from a
//scope
bit uvm_start_uvm_declarations = 1;

//------------------------------------------------------------------------------
//
// Section: Types and Enumerations
//
//------------------------------------------------------------------------------

//------------------------
// Group: Field automation
//------------------------

// Macro: `UVM_MAX_STREAMBITS
//
// Defines the maximum bit vector size for integral types.

`ifndef UVM_MAX_STREAMBITS
`define UVM_MAX_STREAMBITS 4096
`endif

parameter UVM_STREAMBITS = `UVM_MAX_STREAMBITS; 


// Type: uvm_bitstream_t
//
// The bitstream type is used as a argument type for passing integral values
// in such methods as set_int_local, get_int_local, get_config_int, report,
// pack and unpack. 

typedef logic signed [UVM_STREAMBITS-1:0] uvm_bitstream_t;



// Enum: uvm_radix_enum
//
// Specifies the radix to print or record in.
//
// UVM_BIN       - Selects binary (%b) format
// UVM_DEC       - Selects decimal (%d) format
// UVM_UNSIGNED  - Selects unsigned decimal (%u) format
// UVM_OCT       - Selects octal (%o) format
// UVM_HEX       - Selects hexidecimal (%h) format
// UVM_STRING    - Selects string (%s) format
// UVM_TIME      - Selects time (%t) format
// UVM_ENUM      - Selects enumeration value (name) format

typedef enum {
   UVM_BIN       = 'h1000000,
   UVM_DEC       = 'h2000000,
   UVM_UNSIGNED  = 'h3000000,
   UVM_OCT       = 'h4000000,
   UVM_HEX       = 'h5000000,
   UVM_STRING    = 'h6000000,
   UVM_TIME      = 'h7000000,
   UVM_ENUM      = 'h8000000,
   UVM_NORADIX   = 0
} uvm_radix_enum;

parameter UVM_RADIX = 'hf000000; //4 bits setting the radix


// Function- uvm_radix_to_string

function string uvm_radix_to_string(uvm_radix_enum radix);
  case(radix)
    UVM_BIN:     return "'b";
    UVM_OCT:     return "'o";
    UVM_DEC:     return "'s";
    UVM_TIME:    return "'u";
    UVM_STRING:  return "'a";
    default: return "'x";
  endcase
endfunction


// Enum: uvm_recursion_policy_enum
//
// Specifies the policy for copying objects.
//
// UVM_DEEP      - Objects are deep copied (object must implement copy method)
// UVM_SHALLOW   - Objects are shallow copied using default SV copy.
// UVM_REFERENCE - Only object handles are copied.

typedef enum { 
  UVM_DEFAULT_POLICY = 0, 
  UVM_DEEP           = 'h400, 
  UVM_SHALLOW        = 'h800, 
  UVM_REFERENCE      = 'h1000
 } uvm_recursion_policy_enum;


// Enum: uvm_active_passive_enum
//
// Convenience value to define whether a component, usually an agent,
// is in "active" mode or "passive" mode.

typedef enum bit { UVM_PASSIVE=0, UVM_ACTIVE=1 } uvm_active_passive_enum;


// Parameter: `uvm_field_* macro flags
//
// Defines what operations a given field should be involved in.
// Bitwise OR all that apply.
//
// UVM_DEFAULT   - All field operations turned on
// UVM_COPY      - Field will participate in <uvm_object::copy>
// UVM_COMPARE   - Field will participate in <uvm_object::compare>
// UVM_PRINT     - Field will participate in <uvm_object::print>
// UVM_RECORD    - Field will participate in <uvm_object::record>
// UVM_PACK      - Field will participate in <uvm_object::pack>
//
// UVM_NOCOPY    - Field will not participate in <uvm_object::copy>
// UVM_NOCOMPARE - Field will not participate in <uvm_object::compare>
// UVM_NOPRINT   - Field will not participate in <uvm_object::print>
// UVM_NORECORD  - Field will not participate in <uvm_object::record>
// UVM_NOPACK    - Field will not participate in <uvm_object::pack>
//
// UVM_DEEP      - Object field will be deep copied
// UVM_SHALLOW   - Object field will be shallow copied
// UVM_REFERENCE - Object field will copied by reference
//
// UVM_READONLY  - Object field will NOT be automatically configured.


parameter UVM_MACRO_NUMFLAGS    = 17;
//A=ABSTRACT Y=PHYSICAL
//F=REFERENCE, S=SHALLOW, D=DEEP
//K=PACK, R=RECORD, P=PRINT, M=COMPARE, C=COPY
//--------------------------- AYFSD K R P M C
parameter UVM_DEFAULT     = 'b000010101010101;
parameter UVM_ALL_ON      = 'b000000101010101;
parameter UVM_FLAGS_ON    = 'b000000101010101;
parameter UVM_FLAGS_OFF   = 0;

//Values are or'ed into a 32 bit value
//and externally
parameter UVM_COPY         = (1<<0);
parameter UVM_NOCOPY       = (1<<1);
parameter UVM_COMPARE      = (1<<2);
parameter UVM_NOCOMPARE    = (1<<3);
parameter UVM_PRINT        = (1<<4);
parameter UVM_NOPRINT      = (1<<5);
parameter UVM_RECORD       = (1<<6);
parameter UVM_NORECORD     = (1<<7);
parameter UVM_PACK         = (1<<8);
parameter UVM_NOPACK       = (1<<9);
//parameter UVM_DEEP         = (1<<10);
//parameter UVM_SHALLOW      = (1<<11);
//parameter UVM_REFERENCE    = (1<<12);
parameter UVM_PHYSICAL     = (1<<13);
parameter UVM_ABSTRACT     = (1<<14);
parameter UVM_READONLY     = (1<<15);
parameter UVM_NODEFPRINT   = (1<<16);

//Extra values that are used for extra methods
parameter UVM_MACRO_EXTRAS  = (1<<UVM_MACRO_NUMFLAGS);
parameter UVM_FLAGS        = UVM_MACRO_EXTRAS+1;
parameter UVM_UNPACK       = UVM_MACRO_EXTRAS+2;
parameter UVM_CHECK_FIELDS = UVM_MACRO_EXTRAS+3;
parameter UVM_END_DATA_EXTRA = UVM_MACRO_EXTRAS+4;


//Get and set methods (in uvm_object). Used by the set/get* functions
//to tell the object what operation to perform on the fields.
parameter UVM_START_FUNCS  = UVM_END_DATA_EXTRA+1;
parameter UVM_SET           = UVM_START_FUNCS+1;
parameter UVM_SETINT        = UVM_SET;
parameter UVM_SETOBJ        = UVM_START_FUNCS+2;
parameter UVM_SETSTR        = UVM_START_FUNCS+3;
parameter UVM_END_FUNCS     = UVM_SETSTR;

//Global string variables
string uvm_aa_string_key;



//-----------------
// Group: Reporting
//-----------------

// Enum: uvm_severity
//
// Defines all possible values for report severity.
//
//   UVM_INFO    - Informative messsage.
//   UVM_WARNING - Indicates a potential problem.
//   UVM_ERROR   - Indicates a real problem. Simulation continues subject
//                 to the configured message action.
//   UVM_FATAL   - Indicates a problem from which simulation can not
//                 recover. Simulation exits via $finish after a #0 delay.

typedef bit [1:0] uvm_severity;

typedef enum uvm_severity
{
  UVM_INFO,
  UVM_WARNING,
  UVM_ERROR,
  UVM_FATAL
} uvm_severity_type;


// Enum: uvm_action
//
// Defines all possible values for report actions. Each report is configured
// to execute one or more actions, determined by the bitwise OR of any or all
// of the following enumeration constants.
//
//   UVM_NO_ACTION - No action is taken
//   UVM_DISPLAY   - Sends the report to the standard output
//   UVM_LOG       - Sends the report to the file(s) for this (severity,id) pair
//   UVM_COUNT     - Counts the number of reports with the COUNT attribute.
//                   When this value reaches max_quit_count, the simulation terminates
//   UVM_EXIT      - Terminates the simulation immediately.
//   UVM_CALL_HOOK - Callback the report hook methods 
//   UVM_STOP      - Causes ~$stop~ to be executed, putting the simulation into
//                   interactive mode.


typedef int uvm_action;

typedef enum
{
  UVM_NO_ACTION = 'b000000,
  UVM_DISPLAY   = 'b000001,
  UVM_LOG       = 'b000010,
  UVM_COUNT     = 'b000100,
  UVM_EXIT      = 'b001000,
  UVM_CALL_HOOK = 'b010000,
  UVM_STOP      = 'b100000
} uvm_action_type;


// Enum: uvm_verbosity
//
// Defines standard verbosity levels for reports.
//
//  UVM_NONE   - Report is always printed. Verbosity level setting can not
//               disable it.
//  UVM_LOW    - Report is issued if configured verbosity is set to UVM_LOW
//               or above.
//  UVM_MEDIUM - Report is issued if configured verbosity is set to UVM_MEDIUM
//               or above.
//  UVM_HIGH   - Report is issued if configured verbosity is set to UVM_HIGH
//               or above.
//  UVM_FULL   - Report is issued if configured verbosity is set to UVM_FULL
//               or above.

typedef enum {
  UVM_NONE   = 0,
  UVM_LOW    = 100,
  UVM_MEDIUM = 200,
  UVM_HIGH   = 300,
  UVM_FULL   = 400,
  UVM_DEBUG  = 500
} uvm_verbosity;


typedef int UVM_FILE;


//-----------------
// Group: Port Type
//-----------------

// Enum: uvm_port_type_e
//
// Specifies the type of port
//
// UVM_PORT           - The port requires the interface that is its type
//                      parameter.
// UVM_EXPORT         - The port provides the interface that is its type
//                      parameter via a connection to some other export or
//                      implementation.
// UVM_IMPLEMENTATION - The port provides the interface that is its type
//                      parameter, and it is bound to the component that
//                      implements the interface.

typedef enum {
  UVM_PORT ,
  UVM_EXPORT ,
  UVM_IMPLEMENTATION
} uvm_port_type_e;


//-----------------
// Group: Sequences
//-----------------

// Enum: uvm_sequencer_arb_mode
//
// Specifies a sequencer's arbitration mode
//
// SEQ_ARB_FIFO          - Requests are granted in FIFO order (default)
// SEQ_ARB_WEIGHTED      - Requests are granted randomly by weight
// SEQ_ARB_RANDOM        - Requests are granted randomly
// SEQ_ARB_STRICT_FIFO   - Requests at highest priority granted in fifo order
// SEQ_ARB_STRICT_RANDOM - Requests at highest priority granted in randomly
// SEQ_ARB_USER          - Arbitration is delegated to the user-defined 
//                         function, user_priority_arbitration. That function
//                         will specify the next sequence to grant.


typedef enum { SEQ_ARB_FIFO,
               SEQ_ARB_WEIGHTED,
               SEQ_ARB_RANDOM,
               SEQ_ARB_STRICT_FIFO,
               SEQ_ARB_STRICT_RANDOM,
               SEQ_ARB_USER
} uvm_sequencer_arb_mode;


typedef uvm_sequencer_arb_mode SEQ_ARB_TYPE; // backward compat


// Enum: uvm_sequence_state_enum
//
// Defines current sequence state
//
// CREATED            - The sequence has been allocated.
// PRE_BODY           - The sequence is started and the pre_body task is
//                      being executed.
// BODY               - The sequence is started and the body task is being
//                      executed.
// POST_BODY          - The sequence is started and the post_body task is
//                      being executed.
// ENDED              - The sequence has ended by the completion of the body
//                      task.
// STOPPED            - The sequence has been forcibly ended by issuing a
//                      kill() on the sequence.
// FINISHED           - The sequence is completely finished executing.

typedef enum { CREATED   = 1,
               PRE_BODY  = 2,
               BODY      = 4,
               POST_BODY = 8,
               ENDED     = 16,
               STOPPED   = 32,
               FINISHED  = 64
} uvm_sequence_state;

typedef uvm_sequence_state uvm_sequence_state_enum; // backward compat



//---------------
// Group: Phasing
//---------------

// Enum: uvm_phase_type
//
// This is an attribute of a <uvm_phase_imp> object which defines the phase
// execution type. Every phase we define has a type. It is used only for 
// information, as the type behavior is captured in three derived classes 
// uvm_task/topdown/bottomup_phase.
//
//   UVM_PHASE_TASK - The phase is a task-based phase, a fork is done for 
//   each participating component and so the traversal order is arbitrary
//
//   UVM_PHASE_TOPDOWN -  The phase is a function phase, components are 
//   traversed from top-down, allowing them to add to the component tree 
//   as they go.
//
//   UVM_PHASE_BOTTOMUP - The phase is a function phase, components are 
//   traversed from the bottom up, allowing roll-up / consolidation 
//   functionality.
//
typedef enum { UVM_PHASE_TASK,
               UVM_PHASE_TOPDOWN,
               UVM_PHASE_BOTTOMUP
} uvm_phase_type;


/*
// Enum: uvm_thread_mode
//
// Defines whether an implicit objection is raised before calling a component's
// task-based phase method and dropped upon return from that method. This has
// the effect of preventing a phase from ending until all implicitly and
// explicitly raised objections have been dropped. 
// for a given component. 
//
//   UVM_PHASE_NO_IMPLICIT_OBJECTION -  Do not raise an implicit objection.
//               The component will either raise/drop explicitly, or may
//               not even return from the task. The component task may
//               never end on its own accord, such as with many driver and
//               monitor implementations. This components' threads are killed
//               by the phasing mechanism when all components that actively
//               object to end-of-phase drop their objections.
//
//   UVM_PHASE_IMPLICIT_OBJECTION - Raise an implicit objection before calling
//               the phase task, then drop it upon return. Components setting
//               themselves to this mode ~must~ return from task else the
//               phase will never end.
//
typedef enum { UVM_PHASE_NO_IMPLICIT_OBJECTION,
               UVM_PHASE_IMPLICIT_OBJECTION,
               UVM_PHASE_MODE_DEFAULT
} uvm_thread_mode;
*/


// Enum: uvm_phase_state
// ---------------------
//
// The set of possible states of a phase. This is an attribute of a schedule
// node in the graph, not of a phase, to maintain independent per-domain state
//
//   UVM_PHASE_DORMANT -  Nothing has happened with the phase in this domain.
//
//   UVM_PHASE_SCHEDULED - At least one immediate predecessor has completed.
//              Scheduled phases block until all predecessors complete or
//              until a jump is executed.
//
//   UVM_PHASE_STARTED - phase ready to execute, running phase_started() callback
//
//   UVM_PHASE_EXECUTING - An executing phase is one where the phase callbacks are
//              being executed. It's process is tracked by the phaser.
//
//   UVM_PHASE_READY_TO_END - no objections remain, awaiting completion of
//              predecessors of its successors. For example, when phase 'run'
//              is ready to end, its successor will be 'extract', whose
//              predecessors are 'run' and 'post_shutdown'. Therefore, 'run'
//              will be waiting for 'post_shutdown' to be ready to end.
//
//   UVM_PHASE_ENDED - phase completed execution, now running phase_ended() callback
//
//   UVM_PHASE_CLEANUP - all processes related to phase are being killed
//
//   UVM_PHASE_DONE - A phase is done after it terminated execution.  Becoming
//              done may enable a waiting successor phase to execute.
//
//    The state transitions occur as follows:
//
//|     DORMANT -->SCHEDULED-->STARTED-->EXECUTING-->ENDED-->CLEANUP-->DONE --+
//|        ^                                                   |
//|        |          <-- jump_to                              v
//|        +---------------------------------------------------+

   typedef enum { UVM_PHASE_DORMANT      = 1,
                  UVM_PHASE_SCHEDULED    = 2,
                  UVM_PHASE_STARTED      = 4,
                  UVM_PHASE_EXECUTING    = 8,
                  UVM_PHASE_READY_TO_END = 16,
                  UVM_PHASE_ENDED        = 32,
                  UVM_PHASE_CLEANUP      = 64,
                  UVM_PHASE_DONE         = 128
                  } uvm_phase_state;



// Enum: uvm_phase_transition
//
// These are the phase state transition for callbacks which provide
// additional information that may be useful during callbacks
//
// UVM_COMPLETED   - the phase completed normally
// UVM_FORCED_STOP - the phase was forced to terminate prematurely
// UVM_SKIPPED     - the phase was in the path of a forward jump
// UVM_RERUN       - the phase was in the path of a backwards jump
//
typedef enum { UVM_COMPLETED   = 'h01, 
               UVM_FORCED_STOP = 'h02,
               UVM_SKIPPED     = 'h04, 
               UVM_RERUN       = 'h08   
} uvm_phase_transition;


// Enum: uvm_wait_op
//
// Specifies the operand when using methods like <uvm_phase::wait_for_state>.
//
// UVM_EQ  - equal
// UVM_NE  - not equal
// UVM_LT  - less than
// UVM_LTE - less than or equal to
// UVM_GT  - greater than
// UVM_GTE - greater than or equal to
//
typedef enum { UVM_LT,
               UVM_LTE,
               UVM_NE,
               UVM_EQ,
               UVM_GT,
               UVM_GTE
} uvm_wait_op;


//------------------
// Group: Objections
//------------------

// Enum: uvm_objection_event
//
// Enumerated the possible objection events one could wait on. See
// <uvm_objection::wait_for>.
//
// UVM_RAISED      - an objection was raised
// UVM_DROPPED     - an objection was raised
// UVM_ALL_DROPPED - all objections have been dropped
//
typedef enum { UVM_RAISED      = 'h01, 
               UVM_DROPPED     = 'h02,
               UVM_ALL_DROPPED = 'h04
} uvm_objection_event;



//------------------------------
// Group: Default Policy Classes
//------------------------------
//
// Policy classes copying, comparing, packing, unpacking, and recording
// <uvm_object>-based objects.


typedef class uvm_printer;
typedef class uvm_table_printer;
typedef class uvm_tree_printer;
typedef class uvm_line_printer;
typedef class uvm_comparer;
typedef class uvm_packer;
typedef class uvm_recorder;

// Variable: uvm_default_table_printer
//
// The table printer is a global object that can be used with
// <uvm_object::do_print> to get tabular style printing.

uvm_table_printer uvm_default_table_printer = new();


// Variable: uvm_default_tree_printer
//
// The tree printer is a global object that can be used with
// <uvm_object::do_print> to get multi-line tree style printing.

uvm_tree_printer uvm_default_tree_printer  = new();


// Variable: uvm_default_line_printer
//
// The line printer is a global object that can be used with
// <uvm_object::do_print> to get single-line style printing.

uvm_line_printer uvm_default_line_printer  = new();


// Variable: uvm_default_printer
//
// The default printer policy. Used when calls to <uvm_object::print>
// or <uvm_object::sprint> do not specify a printer policy.
//
// The default printer may be set to any legal <uvm_printer> derived type,
// including the global line, tree, and table printers described above.

uvm_printer uvm_default_printer = uvm_default_table_printer;


// Variable: uvm_default_packer
//
// The default packer policy. Used when calls to <uvm_object::pack>
// and <uvm_object::unpack> do not specify a packer policy.

uvm_packer uvm_default_packer = new();


// Variable: uvm_default_comparer
//
//
// The default compare policy. Used when calls to <uvm_object::compare>
// do not specify a comparer policy.

uvm_comparer uvm_default_comparer = new(); // uvm_comparer::init();


// Variable: uvm_default_recorder
//
// The default recording policy. Used when calls to <uvm_object::record>
// do not specify a recorder policy.

uvm_recorder uvm_default_recorder = new();





