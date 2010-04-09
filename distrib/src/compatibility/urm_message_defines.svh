// $Id: urm_message_defines.svh,v 1.22 2009/06/01 21:48:46 redelman Exp $
//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   Copyright 2007-2009 Cadence Design Systems, Inc.
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

`ifndef UVM_URM_MESSAGE_DEFINES_SVH
`define UVM_URM_MESSAGE_DEFINES_SVH


//------------------------------------------------------------------------------
//
// COMPONENT MACROS: the main user-level macros for messaging
//
//------------------------------------------------------------------------------


`ifdef UVM_URM_PLI
`define urm_file $psprintf("%0s",$urm_file)
`define urm_line $urm_line
`else
`define urm_file "<UNKNOWN>"
`define urm_line 0
`endif

`ifdef UVM_PKG_SV
`define uvm_urm_message uvm_pkg::uvm_urm_message
`define uvm_urm_report_server uvm_pkg::uvm_urm_report_server
`define uvm_global_reporter uvm_pkg::_global_reporter
`define uvm_urm_tmp_str uvm_pkg::uvm_urm_tmp_str
`define uvm_global_urm_report_server uvm_pkg::uvm_global_urm_report_server
`else
`define uvm_urm_message uvm_urm_message
`define uvm_urm_report_server uvm_urm_report_server
`define uvm_global_reporter _global_reporter
`define uvm_urm_tmp_str uvm_urm_tmp_str
`define uvm_global_urm_report_server uvm_global_urm_report_server
`endif

`ifdef INCA
`define UVM_AVOID_SFORMATF 1
`endif

`ifdef UVM_AVOID_SFORMATF

`define urm_msg_imp(ID,MESSAGE,TYPE,SEVERITY,VERBOSITY,HIERARCHY,CLIENT) begin \
  $swrite(uvm_urm_tmp_str,"%m"); \
  begin \
    uvm_urm_message message; \
    message = new( \
      ID, "", TYPE, SEVERITY, VERBOSITY, HIERARCHY, CLIENT, \
      `urm_file, `urm_line, uvm_urm_tmp_str \
    ); \
    if ( uvm_urm_report_server::m_message_header(message) ) begin \
      if ( uvm_urm_report_server::m_message_subheader(message) ) $display MESSAGE; \
      uvm_urm_report_server::m_message_footer(message); \
    end \
  end \
end

`define urm_pkg_msg_imp(ID,MESSAGE,TYPE,SEVERITY,VERBOSITY,HIERARCHY,CLIENT) begin \
  $swrite(`uvm_urm_tmp_str,"%m"); \
  begin \
    `uvm_urm_message message; \
    message = new( \
      ID, "", TYPE, SEVERITY, VERBOSITY, HIERARCHY, CLIENT, \
      `urm_file, `urm_line, `uvm_urm_tmp_str \
    ); \
    if ( `uvm_urm_report_server::m_message_header(message) ) begin \
      if ( `uvm_urm_report_server::m_message_subheader(message) ) $display MESSAGE; \
      `uvm_urm_report_server::m_message_footer(message); \
    end \
  end \
end

`else

`define urm_msg_imp(ID,MESSAGE,TYPE,SEVERITY,VERBOSITY,HIERARCHY,CLIENT) begin \
  $swrite(uvm_urm_tmp_str,"%m"); \
  begin \
    string image; \
    uvm_report_object client; \
    client = CLIENT; \
    uvm_urm_report_server::m_set_report_hier(HIERARCHY); \
    uvm_urm_report_server::m_set_report_scope(uvm_urm_tmp_str); \
    uvm_urm_report_server::m_set_report_type(TYPE); \
    image = $psprintf MESSAGE; \
    uvm_global_urm_report_server.report( \
      SEVERITY, client.get_full_name(), ID, image, \
      VERBOSITY, `urm_file, `urm_line, client \
    ); \
    uvm_urm_report_server::m_reset_report_flags(); \
  end \
end

`define urm_pkg_msg_imp(ID,MESSAGE,TYPE,SEVERITY,VERBOSITY,HIERARCHY,CLIENT) begin \
  $swrite(`uvm_urm_tmp_str,"%m"); \
  begin \
    string image; \
    uvm_report_object client; \
    client = CLIENT; \
    `uvm_urm_report_server::m_set_report_hier(`uvm_urm_tmp_str); \
    `uvm_urm_report_server::m_set_report_scope(`uvm_urm_tmp_str); \
    `uvm_urm_report_server::m_set_report_type(TYPE); \
    image = $psprintf MESSAGE; \
    uvm_global_urm_report_server.report( \
      SEVERITY, client.get_full_name(), ID, image, \
      VERBOSITY, `urm_file, `urm_line, client \
    ); \
    `uvm_urm_report_server::m_reset_report_flags(); \
  end \
end

`endif


// module-based msg macros
// -----------------------


`ifdef UVM_PKG_SV

`define MESSAGE(VERBOSITY,MESSAGE) \
  do `urm_pkg_msg_imp("DEBUG",MESSAGE,uvm_pkg::UVM_URM_MSG_DEBUG,uvm_pkg::UVM_INFO,VERBOSITY,"",`uvm_global_reporter) \
  while (0)

`define DUT_ERROR(MESSAGE) \
  do `urm_pkg_msg_imp("DUT",MESSAGE,uvm_pkg::UVM_URM_MSG_DUT,uvm_pkg::UVM_ERROR,uvm_pkg::UVM_NONE,"",`uvm_global_reporter) \
  while (0)

`else 

`define MESSAGE(VERBOSITY,MESSAGE) \
  do `urm_pkg_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,VERBOSITY,"",`uvm_global_reporter) \
  while (0)

`define DUT_ERROR(MESSAGE) \
  do `urm_pkg_msg_imp("DUT",MESSAGE,UVM_URM_MSG_DUT,UVM_ERROR,UVM_NONE,"",`uvm_global_reporter) \
  while (0)

`endif

// static msg macros
// -----------------

`define static_message(VERBOSITY,MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,VERBOSITY,"",_global_reporter)

`define static_dut_error(MESSAGE) \
  `urm_msg_imp("DUT",MESSAGE,UVM_URM_MSG_DUT,UVM_ERROR,UVM_NONE,"",_global_reporter)

`define urm_static_data_debug(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_DEBUG,"",_global_reporter)

`define urm_static_flow_debug(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_DEBUG,"",_global_reporter)

`define urm_static_code_debug(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_DEBUG,"",_global_reporter)

`define urm_static_debug(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_DEBUG,"",_global_reporter)

`define urm_static_info4(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_FULL,"",_global_reporter)

`define urm_static_info3(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_HIGH,"",_global_reporter)

`define urm_static_info2(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_MEDIUM,"",_global_reporter)

`define urm_static_info1(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_LOW,"",_global_reporter)

`define urm_static_info0(D,MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,int'(D),"",_global_reporter)

`define urm_static_info(MESSAGE) \
  `urm_msg_imp("URM",MESSAGE,UVM_URM_MSG_TOOL,UVM_INFO,UVM_NONE,"",_global_reporter)

`define urm_static_warning(MESSAGE) \
  `urm_msg_imp("URM",MESSAGE,UVM_URM_MSG_TOOL,UVM_WARNING,UVM_NONE,"",_global_reporter)

`define urm_static_error(MESSAGE) \
  `urm_msg_imp("URM",MESSAGE,UVM_URM_MSG_TOOL,UVM_ERROR,UVM_NONE,"",_global_reporter)

`define urm_static_fatal(MESSAGE) \
  `urm_msg_imp("URM",MESSAGE,UVM_URM_MSG_TOOL,UVM_FATAL,UVM_NONE,"",_global_reporter)

`define urm_static_info_id(ID,MESSAGE) \
  `urm_msg_imp(ID,MESSAGE,UVM_URM_MSG_TOOL,UVM_INFO,UVM_NONE,"",_global_reporter)

`define urm_static_warning_id(ID,MESSAGE) \
  `urm_msg_imp(ID,MESSAGE,UVM_URM_MSG_TOOL,UVM_WARNING,UVM_NONE,"",_global_reporter)

`define urm_static_error_id(ID,MESSAGE) \
  `urm_msg_imp(ID,MESSAGE,UVM_URM_MSG_TOOL,UVM_ERROR,UVM_NONE,"",_global_reporter)

`define urm_static_fatal_id(ID,MESSAGE) \
  `urm_msg_imp(ID,MESSAGE,UVM_URM_MSG_TOOL,UVM_FATAL,UVM_NONE,"",_global_reporter)


// non-static msg macros
// ---------------------

`define message(VERBOSITY,MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,VERBOSITY,get_full_name(),m_get_report_object())

`define dut_error(MESSAGE) \
  `urm_msg_imp("DUT",MESSAGE,UVM_URM_MSG_DUT,UVM_ERROR,UVM_NONE,get_full_name(),m_get_report_object())

`define urm_data_debug(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_DEBUG,get_full_name(),m_get_report_object())

`define urm_flow_debug(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_DEBUG,get_full_name(),m_get_report_object())

`define urm_code_debug(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_DEBUG,get_full_name(),m_get_report_object())

`define urm_debug(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_DEBUG,get_full_name(),m_get_report_object())

`define urm_info4(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_FULL,get_full_name(),m_get_report_object())

`define urm_info3(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_HIGH,get_full_name(),m_get_report_object())

`define urm_info2(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_MEDIUM,get_full_name(),m_get_report_object())

`define urm_info1(MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,UVM_LOW,get_full_name(),m_get_report_object())

`define urm_info0(D,MESSAGE) \
  `urm_msg_imp("DEBUG",MESSAGE,UVM_URM_MSG_DEBUG,UVM_INFO,int'(D),get_full_name(),m_get_report_object())

`define urm_info(MESSAGE) \
  `urm_msg_imp("URM",MESSAGE,UVM_URM_MSG_TOOL,UVM_INFO,UVM_NONE,get_full_name(),m_get_report_object())

`define urm_warning(MESSAGE) \
  `urm_msg_imp("URM",MESSAGE,UVM_URM_MSG_TOOL,UVM_WARNING,UVM_NONE,get_full_name(),m_get_report_object())

`define urm_error(MESSAGE) \
  `urm_msg_imp("URM",MESSAGE,UVM_URM_MSG_TOOL,UVM_ERROR,UVM_NONE,get_full_name(),m_get_report_object())

`define urm_fatal(MESSAGE) \
  `urm_msg_imp("URM",MESSAGE,UVM_URM_MSG_TOOL,UVM_FATAL,UVM_NONE,get_full_name(),m_get_report_object())

`define urm_info_id(ID,MESSAGE) \
  `urm_msg_imp(ID,MESSAGE,UVM_URM_MSG_TOOL,UVM_INFO,UVM_NONE,get_full_name(),m_get_report_object())

`define urm_warning_id(ID,MESSAGE) \
  `urm_msg_imp(ID,MESSAGE,UVM_URM_MSG_TOOL,UVM_WARNING,UVM_NONE,get_full_name(),m_get_report_object())

`define urm_error_id(ID,MESSAGE) \
  `urm_msg_imp(ID,MESSAGE,UVM_URM_MSG_TOOL,UVM_ERROR,UVM_NONE,get_full_name(),m_get_report_object())

`define urm_fatal_id(ID,MESSAGE) \
  `urm_msg_imp(ID,MESSAGE,UVM_URM_MSG_TOOL,UVM_FATAL,UVM_NONE,get_full_name(),m_get_report_object())


// may not remain visible
// ----------------------

`define urm_msg_detail(DETAIL) \
  (uvm_verbosity'(m_rh.m_max_verbosity_level) >= (DETAIL))

`define urm_static_msg_detail(DETAIL) \
  (`uvm_urm_report_server::get_global_verbosity() >= (DETAIL))


//------------------------------------------------------------------------------
// ANSI Escape Sequences
//
// ESC [ <parameters> m
// 
//     ESC = \033
//     leave no spaces in sequence 
// 
//     Set Graphics Mode: Calls the graphics functions specified by the
//     following values. These specified functions remain active until the next
//     occurrence of this escape sequence. Graphics mode changes the colors and
//     attributes of text (such as bold and underline) displayed on the
//     screen.
//------------------------------------------------------------------------------

`define ANSI_RESET      "\033[0m"
`define ANSI_BRIGHT     "\033[1m"
`define ANSI_DIM        "\033[2m"
`define ANSI_UNDERSCORE "\033[4m"
`define ANSI_BOLD       "\033[5m"
`define ANSI_REVERSE    "\033[7m"

`define ANSI_FG_BLACK   "\033[30m"
`define ANSI_FG_RED     "\033[31m"
`define ANSI_FG_GREEN   "\033[32m"
`define ANSI_FG_YELLOW  "\033[33m"
`define ANSI_FG_BLUE    "\033[34m"
`define ANSI_FG_MAGENTA "\033[35m"
`define ANSI_FG_CYAN    "\033[36m"
`define ANSI_FG_WHITE   "\033[37m"

`define ANSI_BG_BLACK   "\033[40m"
`define ANSI_BG_RED     "\033[41m"
`define ANSI_BG_GREEN   "\033[42m"
`define ANSI_BG_YELLOW  "\033[43m"
`define ANSI_BG_BLUE    "\033[44m"
`define ANSI_BG_MAGENTA "\033[45m"
`define ANSI_BG_CYAN    "\033[46m"
`define ANSI_BG_WHITE   "\033[47m"

`endif // UVM_URM_MESSAGE_DEFINES_SVH
