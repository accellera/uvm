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

`ifndef UVM_MAX_STREAMBITS
`define UVM_MAX_STREAMBITS 4096
`endif


// Current problem with large vector inout decls.

parameter UVM_STREAMBITS = `UVM_MAX_STREAMBITS; 


// Type: uvm_bitstream_t
//
// The bitstream type is used as a argument type for passing integral values
// in such methods as set_int_local, get_int_local, get_config_int, report,
// pack and unpack.

typedef logic signed [UVM_STREAMBITS-1:0] uvm_bitstream_t;



// Enum: uvm_radix_enum
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
// UVM_DEEP      - Objects are deep copied (object must implement copy method)
// UVM_SHALLOW   - Objects are shallow copied using default SV copy.
// UVM_REFERENCE - Only object handles are copied.

typedef enum { 
  UVM_DEFAULT_POLICY = 0, 
  UVM_DEEP           = 'h400, 
  UVM_SHALLOW        = 'h800, 
  UVM_REFERENCE      = 'h1000
 } uvm_recursion_policy_enum;



// Parameters

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



// Group: Reporting


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
typedef uvm_action id_actions_array[string];
typedef UVM_FILE id_file_array[string];

uvm_action s_default_action_array[string]; // default is already NO_ACTION
UVM_FILE s_default_file_array[string]; // default is already 0


// Group: Port Type

// Enum: uvm_port_type_e
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


// Group: Sequences

// Enum: uvm_sequence_state_enum
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
               FINISHED  = 64} uvm_sequence_state_enum;



//------------------------------------------------------------------------------
//
// Group: Default Policy Classes
//
// Policy classes for <uvm_object> basic functions, <uvm_object::copy>,
// <uvm_object::compare>, <uvm_object::pack>, <uvm_object::unpack>, and
// <uvm_object::record>.
//
//------------------------------------------------------------------------------

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
// The default printer is a global object that is used by <uvm_object::print>
// or <uvm_object::sprint> when no specific printer is set. 
//
// The default printer may be set to any legal <uvm_printer> derived type,
// including the global line, tree, and table printers described above.

uvm_printer uvm_default_printer = uvm_default_table_printer;


// Variable: uvm_default_packer
//
// The default packer policy. If a specific packer instance is not supplied in
// calls to <uvm_object::pack> and <uvm_object::unpack>, this instance is
// selected.

uvm_packer uvm_default_packer = new();


// Variable: uvm_default_comparer
//
//
// The default compare policy. If a specific comparer instance is not supplied
// in calls to <uvm_object::compare>, this instance is selected.

uvm_comparer uvm_default_comparer = new(); // uvm_comparer::init();


// Variable: uvm_default_recorder
//
// The default recording policy. If a specific recorder instance is not
// supplied in calls to <uvm_object::record>.

uvm_recorder uvm_default_recorder = new();





