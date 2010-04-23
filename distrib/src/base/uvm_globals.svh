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


// Title: Globals

//------------------------------------------------------------------------------
//
// Group: Simulation Control
//
//------------------------------------------------------------------------------

// Task: run_test
//
// Convenience function for uvm_top.run_test(). See uvm_root for more
// information.

task run_test (string test_name="");
  uvm_root top;
  top = uvm_root::get();
  top.run_test(test_name);
endtask


// Variable: uvm_test_done
//
// An instance of the <uvm_test_done_objection> class, this object is
// used by components to coordinate when to end the currently running
// task-based phase. When all participating components have dropped their
// raised objections, an implicit call to <global_stop_request> is issued
// to end the run phase (or any other task-based phase).

uvm_test_done_objection uvm_test_done = uvm_test_done_objection::get();



// Method: global_stop_request 
//
// Convenience function for uvm_top.stop_request(). See uvm_root for more
// information.

function void global_stop_request();
  uvm_root top;
  top = uvm_root::get();
  top.stop_request();
endfunction


// Method: set_global_timeout 
//
// Convenience function for uvm_top.phase_timeout = timeout. See uvm_root
// for more information.

function void set_global_timeout(time timeout);
  uvm_root top;
  top = uvm_root::get();
  top.phase_timeout = timeout;
endfunction


// Function: set_global_stop_timeout
//
// Convenience function for uvm_top.stop_timeout = timeout.
// See uvm_root for more information.

function void set_global_stop_timeout(time timeout);
  uvm_root top;
  top = uvm_root::get();
  top.stop_timeout = timeout;
endfunction


//----------------------------------------------------------------------------
//
// Group: Reporting
//
//----------------------------------------------------------------------------

// Function: uvm_report_enabled
//
// Returns 1 if the configured verbosity in <uvm_top> is greater than 
// ~verbosity~ and the action associated with the given ~severity~ and ~id~
// is not UVM_NO_ACTION, else returns 0.
// 
// See also <uvm_report_object::uvm_report_enabled>.
//
//
// Static methods of an extension of uvm_report_object, e.g. uvm_compoent-based
// objects, can not call ~uvm_report_enabled~ because the call will resolve to
// the <uvm_report_object::uvm_report_enabled>, which is non-static.
// Static methods can not call non-static methods of the same class. 

function bit uvm_report_enabled (int verbosity,
                                 uvm_severity severity=UVM_INFO, string id="");
  return uvm_top.uvm_report_enabled(verbosity,severity,id);
endfunction


// Function: uvm_report_info

function void uvm_report_info(string id,
			      string message,
                              int verbosity = UVM_MEDIUM,
			      string filename = "",
			      int line = 0);
  uvm_top.uvm_report_info(id, message, verbosity, filename, line);
endfunction


// Function: uvm_report_warning

function void uvm_report_warning(string id,
                                 string message,
                                 int verbosity = UVM_MEDIUM,
				 string filename = "",
				 int line = 0);
  uvm_top.uvm_report_warning(id, message, verbosity, filename, line);
endfunction


// Function: uvm_report_error

function void uvm_report_error(string id,
                               string message,
                               int verbosity = UVM_LOW,
			       string filename = "",
			       int line = 0);
  uvm_top.uvm_report_error(id, message, verbosity, filename, line);
endfunction


// Function: uvm_report_fatal
//
// These methods, defined in package scope, are convenience functions that
// delegate to the corresponding component methods in ~uvm_top~. They can be
// used in module-based code to use the same reporting mechanism as class-based
// components. See <uvm_report_object> for details on the reporting mechanism. 
//
// Note: Verbosity is ignored for warnings, errors, and fatals to ensure users
// do not inadvertently filter them out. It remains in the methods for backward
// compatibility.

function void uvm_report_fatal(string id,
	                       string message,
                               int verbosity = UVM_NONE,
			       string filename = "",
			       int line = 0);
  uvm_top.uvm_report_fatal(id, message, verbosity, filename, line);
endfunction

  
//------------------------------------------------------------------------------
//
// Group: Configuration
//
//------------------------------------------------------------------------------

// Function: set_config_int
//
// This is the global version of set_config_int in <uvm_component>. This
// function places the configuration setting for an integral field in a
// global override table, which has highest precedence over any
// component-level setting.  See <uvm_component::set_config_int> for
// details on setting configuration.

function void  set_config_int  (string inst_name,
                                string field_name,
                                uvm_bitstream_t value);
  uvm_root top;
  top = uvm_root::get();
  top.set_config_int(inst_name, field_name, value);
endfunction


// Function: set_config_object
//
// This is the global version of set_config_object in <uvm_component>. This
// function places the configuration setting for an object field in a
// global override table, which has highest precedence over any
// component-level setting.  See <uvm_component::set_config_object> for
// details on setting configuration.

function void set_config_object (string inst_name,
                                 string field_name,
                                 uvm_object value,
                                 bit clone=1);
  uvm_root top;
  top = uvm_root::get();
  top.set_config_object(inst_name, field_name, value, clone);
endfunction


// Function: set_config_string
//
// This is the global version of set_config_string in <uvm_component>. This
// function places the configuration setting for an string field in a
// global override table, which has highest precedence over any
// component-level setting.  See <uvm_component::set_config_string> for
// details on setting configuration.

function void set_config_string (string inst_name,  
                                 string field_name,
                                 string value);
  uvm_root top;
  top = uvm_root::get();
  top.set_config_string(inst_name, field_name, value);
endfunction



//----------------------------------------------------------------------------
//
// Group: Miscellaneous
//
//----------------------------------------------------------------------------


// Function: uvm_is_match
//
// Returns 1 if the two strings match, 0 otherwise.
//
// The first string, ~expr~, is a string that may contain '*' and '?'
// characters. A * matches zero or more characters, and ? matches any single
// character. The 2nd argument, ~str~, is the string begin matched against.
// It must not contain any wildcards.
//
//----------------------------------------------------------------------------

`ifdef UVM_DPI
import "DPI" function bit uvm_is_match (string expr, string str);
`else
function bit uvm_is_match (string expr, string str);

  int e, es, s, ss;
  string tmp;
  e  = 0; s  = 0;
  es = 0; ss = 0;

  if(expr.len() == 0)
    return 1;

  // The ^ used to be used to remove the implicit wildcard, but now we don't
  // use implicit wildcard so this character is just stripped.
  if(expr[0] == "^")
    expr = expr.substr(1, expr.len()-1);

  //This loop is only needed when the first character of the expr may not
  //be a *. 
  while (s != str.len() && expr.getc(e) != "*") begin
    if ((expr.getc(e) != str.getc(s)) && (expr.getc(e) != "?"))
      return 0;
    e++; s++;
  end

  while (s != str.len()) begin
    if (expr.getc(e) == "*") begin
      e++;
      if (e == expr.len()) begin
        return 1;
      end
      es = e;
      ss = s+1;
    end
    else if (expr.getc(e) == str.getc(s) || expr.getc(e) == "?") begin
      e++;
      s++;
    end
    else begin
      e = es;
      s = ss++;
    end
  end
  while (expr.getc(e) == "*")
    e++;
  if(e == expr.len()) begin
    return 1;
  end
  else begin
    return 0;
  end
endfunction
`endif


`ifndef UVM_LINE_WIDTH
  `define UVM_LINE_WIDTH 120
`endif 
parameter UVM_LINE_WIDTH = `UVM_LINE_WIDTH;

`ifndef UVM_NUM_LINES
  `define UVM_NUM_LINES 120
`endif
parameter UVM_NUM_LINES = `UVM_NUM_LINES;

parameter UVM_SMALL_STRING = UVM_LINE_WIDTH*8-1;
parameter UVM_LARGE_STRING = UVM_LINE_WIDTH*UVM_NUM_LINES*8-1;


//----------------------------------------------------------------------------
//
// Function: uvm_string_to_bits
//
// Converts an input string to its bit-vector equivalent. Max bit-vector
// length is approximately 14000 characters.
//----------------------------------------------------------------------------

function logic[UVM_LARGE_STRING:0] uvm_string_to_bits(string str);
  $swrite(uvm_string_to_bits, "%0s", str);
endfunction


//----------------------------------------------------------------------------
//
// Function: uvm_bits_to_string
//
// Converts an input bit-vector to its string equivalent. Max bit-vector
// length is approximately 14000 characters.
//----------------------------------------------------------------------------

function string uvm_bits_to_string(logic [UVM_LARGE_STRING:0] str);
  $swrite(uvm_bits_to_string, "%0s", str);
endfunction


//----------------------------------------------------------------------------
//
// Task: uvm_wait_for_nba_region
//
// Call this task to wait for a delta cycle. Program blocks don't have an nba
// so just delay for a #0 in a program block.
//----------------------------------------------------------------------------

task uvm_wait_for_nba_region;

  string s;

  bit nba;
  bit nba_scheduled;

  //If `included directly in a program block, can't use a non-blocking assign,
  //but it isn't needed since program blocks are in a seperate region.
`ifndef UVM_PROGRAM_BLOCK
  if (nba_scheduled == 0) begin
    nba_scheduled = 1;
    nba = 0;
    nba <= 1;
    @(posedge nba) nba_scheduled = 0;
  end
  else begin
    @(posedge nba);
  end
`else
  #0;
`endif


endtask


