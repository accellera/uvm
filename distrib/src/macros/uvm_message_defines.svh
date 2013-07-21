//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
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
//----------------------------------------------------------------------

`ifndef UVM_MESSAGE_DEFINES_SVH
`define UVM_MESSAGE_DEFINES_SVH

`ifndef UVM_LINE_WIDTH
  `define UVM_LINE_WIDTH 120
`endif 

`ifndef UVM_NUM_LINES
  `define UVM_NUM_LINES 120
`endif

//`ifndef UVM_USE_FILE_LINE
//`define UVM_REPORT_DISABLE_FILE_LINE
//`endif

`ifdef UVM_REPORT_DISABLE_FILE_LINE
`define UVM_REPORT_DISABLE_FILE
`define UVM_REPORT_DISABLE_LINE
`endif

`ifdef UVM_REPORT_DISABLE_FILE
`define uvm_file ""
`else
`define uvm_file `__FILE__
`endif

`ifdef UVM_REPORT_DISABLE_LINE
`define uvm_line 0
`else
`define uvm_line `__LINE__
`endif

//------------------------------------------------------------------------------
//
// Title: Report Macros 
//
// This set of macros provides wrappers around the uvm_report_* <Reporting> 
// functions. The macros serve two essential purposes:
//
// - To reduce the processing overhead associated with filtered out messages,
//   a check is made against the report's verbosity setting and the action
//   for the id/severity pair before any string formatting is performed. This 
//   affects only `uvm_info reports.
//
// - The `__FILE__ and `__LINE__ information is automatically provided to the
//   underlying uvm_report_* call. Having the file and line number from where
//   a report was issued aides in debug. You can disable display of file and
//   line information in reports by defining UVM_REPORT_DISABLE_FILE_LINE on
//   the command line.
//
// The macros also enforce a verbosity setting of UVM_NONE for warnings, errors
// and fatals so that they cannot be mistakingly turned off by setting the
// verbosity level too low (warning and errors can still be turned off by 
// setting the actions appropriately).
//
// To use the macros, replace the previous call to uvm_report_* with the
// corresponding macro.
//
//| //Previous calls to uvm_report_*
//| uvm_report_info("MYINFO1", $sformatf("val: %0d", val), UVM_LOW);
//| uvm_report_warning("MYWARN1", "This is a warning");
//| uvm_report_error("MYERR", "This is an error");
//| uvm_report_fatal("MYFATAL", "A fatal error has occurred");
//
// The above code is replaced by
//
//| //New calls to `uvm_*
//| `uvm_info("MYINFO1", $sformatf("val: %0d", val), UVM_LOW)
//| `uvm_warning("MYWARN1", "This is a warning")
//| `uvm_error("MYERR", "This is an error")
//| `uvm_fatal("MYFATAL", "A fatal error has occurred")
//
// Macros represent text substitutions, not statements, so they should not be
// terminated with semi-colons.


//----------------------------------------------------------------------------
// Group:  Basic Messaging Macros
//----------------------------------------------------------------------------


// MACRO: `uvm_info
//
// Calls uvm_report_info if ~VERBOSITY~ is lower than the configured verbosity of
// the associated reporter. ~ID~ is given as the message tag and ~MSG~ is given as
// the message text. The file and line are also sent to the uvm_report_info call.
//
// |`uvm_info(ID, MSG, VERBOSITY, RO = uvm_get_report_object(), CNTXT_NAME = "")

`define uvm_info(ID, MSG, VERBOSITY, RO = uvm_get_report_object(), CNTXT_NAME = "") \
   begin \
     uvm_report_object l_report_object; \
     l_report_object = RO; \
     if (l_report_object.uvm_report_enabled(VERBOSITY,UVM_INFO,ID)) \
       l_report_object.uvm_report_info (ID, MSG, VERBOSITY, `uvm_file, `uvm_line, \
         CNTXT_NAME, 1); \
   end


// MACRO: `uvm_warning
//
// Calls uvm_report_warning with a verbosity of UVM_NONE. The message can not
// be turned off using the reporter's verbosity setting, but can be turned off
// by setting the action for the message.  ~ID~ is given as the message tag and 
// ~MSG~ is given as the message text. The file and line are also sent to the 
// uvm_report_warning call.
//
// |`uvm_warning(ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "")

`define uvm_warning(ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "") \
   begin \
     uvm_report_object l_report_object; \
     l_report_object = RO; \
     if (l_report_object.uvm_report_enabled(UVM_NONE,UVM_WARNING,ID)) \
       l_report_object.uvm_report_warning (ID, MSG, UVM_NONE, `uvm_file, `uvm_line, \
         CNTXT_NAME, 1); \
   end


// MACRO: `uvm_error
//
// Calls uvm_report_error with a verbosity of UVM_NONE. The message can not
// be turned off using the reporter's verbosity setting, but can be turned off
// by setting the action for the message.  ~ID~ is given as the message tag and 
// ~MSG~ is given as the message text. The file and line are also sent to the 
// uvm_report_error call.
//
// |`uvm_error(ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "")

`define uvm_error(ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "") \
   begin \
     uvm_report_object l_report_object; \
     l_report_object = RO; \
     if (l_report_object.uvm_report_enabled(UVM_NONE,UVM_ERROR,ID)) \
       l_report_object.uvm_report_error (ID, MSG, UVM_NONE, `uvm_file, `uvm_line, \
         CNTXT_NAME, 1); \
   end


// MACRO: `uvm_fatal
//
// Calls uvm_report_fatal with a verbosity of UVM_NONE. The message can not
// be turned off using the reporter's verbosity setting, but can be turned off
// by setting the action for the message.  ~ID~ is given as the message tag and 
// ~MSG~ is given as the message text. The file and line are also sent to the 
// uvm_report_fatal call.
//
// |`uvm_fatal(ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "")

`define uvm_fatal(ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "") \
   begin \
     uvm_report_object l_report_object; \
     l_report_object = RO; \
     if (l_report_object.uvm_report_enabled(UVM_NONE,UVM_FATAL,ID)) \
       l_report_object.uvm_report_fatal (ID, MSG, UVM_NONE, `uvm_file, `uvm_line, \
         CNTXT_NAME, 1); \
   end


`ifndef UVM_NO_DEPRECATED


// MACRO- `uvm_info_context
//
//| `uvm_info_context(ID, MSG, VERBOSITY, RO, CNTXT_NAME)
//
// Operates identically to `uvm_info but requires that the
// context, or <uvm_report_object>, in which the message is printed be 
// explicitly supplied as a macro argument.

`define uvm_info_context(ID, MSG, VERBOSITY, RO) \
   begin \
     if (RO.uvm_report_enabled(VERBOSITY,UVM_INFO,ID)) \
       RO.uvm_report_info (ID, MSG, VERBOSITY, `uvm_file, `uvm_line, "", 1); \
   end


// MACRO- `uvm_warning_context
//
//| `uvm_warning_context(ID, MSG, RO, CNTXT_NAME = "")
//
// Operates identically to `uvm_warning but requires that the
// context, or <uvm_report_object>, in which the message is printed be
// explicitly supplied as a macro argument.

`define uvm_warning_context(ID, MSG, RO) \
   begin \
     if (RO.uvm_report_enabled(UVM_NONE,UVM_WARNING,ID)) \
       RO.uvm_report_warning (ID, MSG, UVM_NONE, `uvm_file, `uvm_line, "", 1); \
   end


// MACRO- `uvm_error_context
//
//| `uvm_error_context(ID, MSG, RO, CNTXT_NAME = "")
//
// Operates identically to `uvm_error but requires that the
// context, or <uvm_report_object> in which the message is printed be 
// explicitly supplied as a macro argument.

`define uvm_error_context(ID, MSG, RO) \
   begin \
     if (RO.uvm_report_enabled(UVM_NONE,UVM_ERROR,ID)) \
       RO.uvm_report_error (ID, MSG, UVM_NONE, `uvm_file, `uvm_line, "", 1); \
   end


// MACRO- `uvm_fatal_context
//
//| `uvm_fatal_context(ID, MSG, RO, CNTXT_NAME = "")
//
// Operates identically to `uvm_fatal but requires that the
// context, or <uvm_report_object>, in which the message is printed be 
// explicitly supplied as a macro argument.

`define uvm_fatal_context(ID, MSG, RO) \
   begin \
     if (RO.uvm_report_enabled(UVM_NONE,UVM_FATAL,ID)) \
       RO.uvm_report_fatal (ID, MSG, UVM_NONE, `uvm_file, `uvm_line, "", 1); \
   end


`endif


// Not implemented.  Used to collapse macros defined below.
`define __m_uvm_report_trace_begin(TRC_MESS, ID, MSG, SEVERITY, VERBOSITY, RO, CNTXT_NAME) \
  begin \
    uvm_report_object l_report_object; \
    l_report_object = RO; \
    if (l_report_object.uvm_report_enabled(VERBOSITY,SEVERITY,ID)) begin \
      TRC_MESS = uvm_trace_message::get_trace_message(); \
      TRC_MESS.set_report_message(CNTXT_NAME, `uvm_file, `uvm_line, SEVERITY, ID, \
        MSG, VERBOSITY); \
      TRC_MESS.state = uvm_trace_message::TRC_BGN; \
      l_report_object.process_report_message(TRC_MESS); \
    end \
    else \
      TRC_MESS = null; \
  end

// Not implemented.  Used to collapse macros defined below.
`define __m_uvm_report_trace_end(TRC_MSG, MSG, TR_ID) \
  if (TRC_MSG != null) begin \
    TRC_MSG.state = uvm_trace_message::TRC_END; \
    TRC_MSG.end_message = MSG; \
    TRC_MSG.report_object.process_report_message(TRC_MSG); \
    TR_ID = TRC_MSG.tr_handle; \
    TRC_MSG.free_trace_message(TRC_MSG); \
    TRC_MSG = null; \
  end


//----------------------------------------------------------------------------
// Group:  Message Trace Macros
//----------------------------------------------------------------------------


// MACRO: `uvm_info_begin
//
// |`uvm_info_begin(TRC_MESS, ID, MSG, VERBOSITY, RO = uvm_get_report_object(),
// |    CNTXT_NAME = "")

`define uvm_info_begin(TRC_MESS, ID, MSG, VERBOSITY, RO = uvm_get_report_object(), CNTXT_NAME = "") \
  `__m_uvm_report_trace_begin(TRC_MESS, ID, MSG, UVM_INFO, VERBOSITY, RO, CNTXT_NAME)


// MACRO: `uvm_info_end
//
// This macro pair provides the ability to add elements to messages and also
// messaging events that are analagous to transaction recording.  These macros
// should be used as a functional pair for a given <uvm_trace_message> provided
// via the ~TRC_MESS~ argument.  The <`uvm_info_begin> macro otherwise just replicates
// the arguments of the <`uvm_info> macro.  
//
// |`uvm_info_end(TRC_MSG, MSG, TR_ID)
//
// The ~TR_ID~ argument can be stored in order to create link relationships between
// messages using the <`uvm_link> macro.
//
// Example usage is shown here.
//
// |// User variables
// |uvm_trace_message l_trace_message;
// |int l_tr_handle;
// |...
// |task my_task();
// |   ...
// |   `uvm_info_begin(l_trace_message, ¿ID_A", "Beginning...", UVM_LOW)
// |   ...
// |   `uvm_add_trace_tag(l_trace_message, "color", "red")
// |   `uvm_add_trace_int(l_trace_message, my_int, UVM_DEC)
// |   `uvm_add_trace_string(l_trace_message, my_string)
// |   `uvm_add_trace_object(l_trace_message, my_obj)
// |   ...
// |   `uvm_info_end(l_trace_message, "Ending...", l_tr_handle)
// |   ...
// |endtask
//

`define uvm_info_end(TRC_MSG, MSG, TR_ID) \
  `__m_uvm_report_trace_end(TRC_MSG, MSG, TR_ID) \


// MACRO: `uvm_warning_begin
//
// |`uvm_warning_begin(TRC_MESS, ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "")

`define uvm_warning_begin(TRC_MESS, ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "") \
  `__m_uvm_report_trace_begin(TRC_MESS, ID, MSG, UVM_WARNING, UVM_NONE, RO, CNTXT_NAME)


// MACRO: `uvm_warning_end
//
// This macro pair operates identically to <`uvm_info_begin>/<`uvm_info_end> with
// exception that the message severity is <UVM_WARNING> and has no verbosity threshhold.
//
// |`uvm_warning_end(TRC_MSG, MSG, TR_ID)
//
// The usage shown in <`uvm_info_end> works identically for this pair.
//

`define uvm_warning_end(TRC_MSG, MSG, TR_ID) \
  `__m_uvm_report_trace_end(TRC_MSG, MSG, TR_ID) \


// MACRO: `uvm_error_begin
//
// |`uvm_error_begin(TRC_MESS, ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "")

`define uvm_error_begin(TRC_MESS, ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "") \
  `__m_uvm_report_trace_begin(TRC_MESS, ID, MSG, UVM_ERROR, UVM_NONE, RO, CNTXT_NAME)


// MACRO: `uvm_error_end
//
// This macro pair operates identically to <`uvm_info_begin>/<`uvm_info_end> with
// exception that the message severity is <UVM_ERROR> and has no verbosity threshhold.
//
// |`uvm_error_end(TRC_MSG, MSG, TR_ID)
//
// The usage shown in <`uvm_info_end> works identically for this pair.
//

`define uvm_error_end(TRC_MSG, MSG, TR_ID) \
  `__m_uvm_report_trace_end(TRC_MSG, MSG, TR_ID) \


// MACRO: `uvm_fatal_begin
//
// |`uvm_fatal_begin(TRC_MESS, ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "")

`define uvm_fatal_begin(TRC_MESS, ID, MSG, RO = uvm_get_report_object(), CNTXT_NAME = "") \
  `__m_uvm_report_trace_begin(TRC_MESS, ID, MSG, UVM_FATAL, UVM_NONE, RO, CNTXT_NAME)

// MACRO: `uvm_fatal_end
//
// This macro pair operates identically to <`uvm_info_begin>/<`uvm_info_end> with
// exception that the message severity is <UVM_FATAL> and has no verbosity threshhold.
//
// |`uvm_fatal_end(TRC_MSG, MSG, TR_ID)
//
// The usage shown in <`uvm_info_end> works identically for this pair.
//

`define uvm_fatal_end(TRC_MSG, MSG, TR_ID) \
  `__m_uvm_report_trace_end(TRC_MSG, MSG, TR_ID) \


//----------------------------------------------------------------------------
// Group:  Messge Element Macros
//----------------------------------------------------------------------------


// MACRO: `uvm_add_trace_tag
//
// |`uvm_add_trace_tag(TRC_MSG, NAME, VALUE)
//

`define uvm_add_trace_tag(TRC_MESS, NAME, VALUE) \
  if (TRC_MESS != null) \
    TRC_MESS.add_tag(NAME, VALUE);


// MACRO: `uvm_add_trace_int
//
// |`uvm_add_trace_int(TRC_MSG, VAR, RADIX, LABEL = "")
//

`define uvm_add_trace_int(TRC_MESS, VAR, RADIX, LABEL = "") \
  if (TRC_MESS != null) \
    if (LABEL == "") \
      TRC_MESS.add_int(`"VAR`", VAR, $bits(VAR), RADIX); \
    else \
      TRC_MESS.add_int(LABEL, VAR, $bits(VAR), RADIX);


// MACRO: `uvm_add_trace_string
//
// |`uvm_add_trace_string(TRC_MSG, VAR, LABEL = "")
//

`define uvm_add_trace_string(TRC_MESS, VAR, LABEL = "") \
  if (TRC_MESS != null) \
    if (LABEL == "") \
      TRC_MESS.add_string(`"VAR`", VAR); \
    else \
      TRC_MESS.add_string(LABEL, VAR);


// MACRO: `uvm_add_trace_object
//
// These macros allow the user to provide elements that are associated with
// <uvm_report_message>s.  Separate macros are provided such that the
// user can supply arbitrary string/string pairs using <`uvm_add_trace_tag>,
// integral types along with a radix using <`uvm_add_trace_int>, string 
// using <`uvm_add_trace_string> and <uvm_object>s using 
// <`uvm_add_trace_object>.
//
// |`uvm_add_trace_object(TRC_MSG, VAR, LABEL = "")
//
// Example usage is shown in <`uvm_info_end>.
//

`define uvm_add_trace_object(TRC_MESS, VAR, LABEL = "") \
  if (TRC_MESS != null) \
    if (LABEL == "") \
      TRC_MESS.add_object(`"VAR`", VAR); \
    else \
      TRC_MESS.add_object(LABEL, VAR);

// `uvm_add_trace_meta
//

`define uvm_add_trace_meta(TRC_MESS, VAR, LABEL = "") \
  if (TRC_MESS != null) \
    if (LABEL == "") \
      TRC_MESS.add_meta(`"VAR'", VAR); \
    else \
      TRC_MESS.add_meta(LABEL, VAR);


//----------------------------------------------------------------------------
// Group:  Messge Linking Macros
//----------------------------------------------------------------------------


// MACRO: `uvm_link
//
// This macro allows the user to create link relationships between two 
// tr_handles (or transaction ids).  A display/log message is provided when
// doing so.
//
// |`uvm_link(TR_ID0, TR_ID1, REL, ID, VERBOSITY, RO = uvm_get_report_object(),
// |   CNTXT_NAME = "") \
//
// Example usage is shown here.
//
// |   `uvm_info_begin(l_trace_messageA, "TEST_A", "Beginning A...", UVM_LOW)
// |    ...
// |    #10 `uvm_info_begin(l_trace_messageB, "TEST_B", "Beginning B...", UVM_LOW)
// |    ...
// |    #20 `uvm_info_end(l_trace_messageA, "Ending A...", l_tr_handle0)
// |    ...
// |    #30 `uvm_link(l_tr_handle0, l_trace_messageB.tr_handle, "child", "TEST_L", UVM_LOW)
// |    ...
// |    #25 `uvm_info_end(l_trace_messageB, "Ending B...", l_tr_handle1)
//

`define uvm_link(TR_ID0, TR_ID1, REL, ID, VERBOSITY, RO = uvm_get_report_object(), CNTXT_NAME = "") \
  begin \
    uvm_report_object l_report_object; \
    uvm_link_message l_link_message; \
    l_report_object = RO; \
    if (l_report_object.uvm_report_enabled(VERBOSITY,UVM_INFO,ID)) begin \
      l_link_message = uvm_link_message::get_link_message(); \
      l_link_message.set_report_message(CNTXT_NAME, `uvm_file, `uvm_line, UVM_INFO, ID, \
        "", VERBOSITY); \
      l_link_message.tr_id0 = TR_ID0; \
      l_link_message.tr_id1 = TR_ID1; \
      l_link_message.relationship = REL; \
      l_report_object.process_report_message(l_link_message); \
      l_link_message.free_link_message(l_link_message); \
    end \
  end


`endif //UVM_MESSAGE_DEFINES_SVH
