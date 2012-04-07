//
//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc. 
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

`ifndef UVM_REPORT_HANDLER_SVH
`define UVM_REPORT_HANDLER_SVH

typedef class uvm_report_object;
typedef class uvm_report_server;
typedef uvm_pool#(string, uvm_action) uvm_id_actions_array;
typedef uvm_pool#(string, UVM_FILE) uvm_id_file_array;
typedef uvm_pool#(string, int) uvm_id_verbosities_array;
typedef uvm_pool#(uvm_severity, uvm_severity) uvm_sev_override_array;

//------------------------------------------------------------------------------
//
// CLASS: uvm_report_handler
//
// The uvm_report_handler is the class to which most methods in
// <uvm_report_object> delegate. It stores the maximum verbosity, actions,
// and files that affect the way reports are handled. 
//
// The report handler is not intended for direct use. See <uvm_report_object>
// for information on the UVM reporting mechanism.
//
// The relationship between <uvm_report_object> (a base class for uvm_component)
// and uvm_report_handler is typically one to one, but it can be many to one
// if several uvm_report_objects are configured to use the same
// uvm_report_handler_object. See <uvm_report_object::set_report_handler>.
//
// The relationship between uvm_report_handler and <uvm_report_server> is many
// to one. 
//
//------------------------------------------------------------------------------

class uvm_report_handler extends uvm_object;

  // internal variables

  int m_max_verbosity_level;

  // id verbosity settings : default and severity
  uvm_id_verbosities_array id_verbosities;
  uvm_id_verbosities_array severity_id_verbosities[uvm_severity];

  // actions
  uvm_id_actions_array id_actions;
  uvm_action severity_actions[uvm_severity];
  uvm_id_actions_array severity_id_actions[uvm_severity];

  // severity overrides
  uvm_sev_override_array sev_overrides;
  uvm_sev_override_array sev_id_overrides [string];

  // file handles : default, severity, action, (severity,id)
  UVM_FILE default_file_handle;
  uvm_id_file_array id_file_handles;
  UVM_FILE severity_file_handles[uvm_severity];
  uvm_id_file_array severity_id_file_handles[uvm_severity];


  `uvm_object_utils(uvm_report_handler)


  // Function: new
  // 
  // Creates and initializes a new uvm_report_handler object.

  function new(string name = "uvm_report_handler");
    super.new(name);
    initialize();
  endfunction


  // Print to show report server state
  virtual function void do_print (uvm_printer printer);

    uvm_verbosity l_verbosity;
    uvm_severity l_severity;
    string idx;
    int l_int;

    // max verb
    if ($cast(l_verbosity, m_max_verbosity_level))
      printer.print_generic("max_verbosity_level", "uvm_verbosity", 32, 
        l_verbosity.name());
    else
      printer.print_int("max_verbosity_level", m_max_verbosity_level, 32, UVM_DEC,
        ".", "int");

    // id verbs
    if(id_verbosities.first(idx)) begin
      printer.print_array_header("id_verbosities",id_verbosities.num(),
        "uvm_pool");
      do begin
        l_int = id_verbosities.get(idx);
        if ($cast(l_verbosity, l_int))
          printer.print_generic($sformatf("[%s]", idx), "uvm_verbosity", 32, 
            l_verbosity.name());
        else begin
          string l_str;
          l_str.itoa(l_int);
          printer.print_generic($sformatf("[%s]", idx), "int", 32, 
            l_str);
        end
      end while(id_verbosities.next(idx));
      printer.print_array_footer();
    end

    // sev and id verbs
    if(severity_id_verbosities.size() != 0) begin
      int _total_cnt;
      foreach (severity_id_verbosities[l_severity])
        _total_cnt += severity_id_verbosities[l_severity].num();
      printer.print_array_header("severity_id_verbosities", _total_cnt,
        "array");
      if(severity_id_verbosities.first(l_severity)) begin
        do begin
          uvm_severity_type sev = uvm_severity_type'(l_severity);
          uvm_id_verbosities_array id_v_ary = severity_id_verbosities[l_severity];
          if(id_v_ary.first(idx))
          do begin
            l_int = id_v_ary.get(idx);
            if ($cast(l_verbosity, l_int))
              printer.print_generic($sformatf("[%s:%s]", sev, idx), "uvm_verbosity", 32, 
                l_verbosity.name());
            else begin
              string l_str;
              l_str.itoa(l_int);
              printer.print_generic($sformatf("[%s:%s]", sev, idx), "int", 32, l_str);
            end
          end while(id_v_ary.next(idx));
        end while(severity_id_verbosities.next(l_severity));
      end
      printer.print_array_footer();
    end

    // id actions
    if(id_actions.first(idx)) begin
      printer.print_array_header("id_actions",id_actions.num(),
        "uvm_pool");
      do begin
        l_int = id_actions.get(idx);
        printer.print_generic($sformatf("[%s]", idx), "uvm_action", 32, 
          format_action(l_int));
      end while(id_actions.next(idx));
      printer.print_array_footer();
    end

    // severity actions
    if(severity_actions.first(l_severity)) begin
      printer.print_array_header("severity_actions",4,"array");
      do begin
        uvm_severity_type sev = uvm_severity_type'(l_severity);
        printer.print_generic($sformatf("[%s]", sev), "uvm_action", 32, 
          format_action(severity_actions[l_severity]));
      end while(severity_actions.next(l_severity));
      printer.print_array_footer();
    end

    // sev and id actions 
    if(severity_id_actions.size() != 0) begin
      int _total_cnt;
      foreach (severity_id_actions[l_severity])
        _total_cnt += severity_id_actions[l_severity].num();
      printer.print_array_header("severity_id_actions", _total_cnt,
        "array");
      if(severity_id_actions.first(l_severity)) begin
        do begin
          uvm_severity_type sev = uvm_severity_type'(l_severity);
          uvm_id_actions_array id_a_ary = severity_id_actions[l_severity];
          if(id_a_ary.first(idx))
          do begin
            printer.print_generic($sformatf("[%s:%s]", sev, idx), "uvm_action", 32, 
              format_action(id_a_ary.get(idx)));
          end while(id_a_ary.next(idx));
        end while(severity_id_actions.next(l_severity));
      end
      printer.print_array_footer();
    end

    // sev overrides
    if(sev_overrides.first(l_severity)) begin
      printer.print_array_header("sev_overrides",sev_overrides.num(),
        "uvm_pool");
      do begin
        uvm_severity_type l_severity_orig = uvm_severity_type'(l_severity);
        uvm_severity_type l_severity_new 
          = uvm_severity_type'(sev_overrides.get(l_severity));
        printer.print_generic($sformatf("[%s]", l_severity_orig.name()),
          "uvm_severity", 32, l_severity_new.name());
      end while(sev_overrides.next(l_severity));
      printer.print_array_footer();
    end

    // sev and id overrides
    if(sev_id_overrides.size() != 0) begin
      int _total_cnt;
      foreach (sev_id_overrides[idx])
        _total_cnt += sev_id_overrides[idx].num();
      printer.print_array_header("sev_id_overrides", _total_cnt,
        "array");
      if(sev_id_overrides.first(idx)) begin
        do begin
          uvm_sev_override_array sev_o_ary = sev_id_overrides[idx];
          if(sev_o_ary.first(l_severity))
          do begin
            uvm_severity_type old_sev = uvm_severity_type'(l_severity);
            uvm_severity_type new_sev = uvm_severity_type'(sev_o_ary.get(l_severity));
            printer.print_generic($sformatf("[%s:%s]", old_sev.name(), idx), 
              "uvm_severity", 32, new_sev.name());
          end while(sev_o_ary.next(l_severity));
        end while(sev_id_overrides.next(idx));
      end
      printer.print_array_footer();
    end

    // default file handle
    printer.print_int("default_file_handle", default_file_handle, 32, UVM_HEX,
      ".", "int");

    // id files 
    if(id_file_handles.first(idx)) begin
      printer.print_array_header("id_file_handles",id_file_handles.num(),
        "uvm_pool");
      do begin
        printer.print_int($sformatf("[%s]", idx), id_file_handles.get(idx), 32,
          UVM_HEX, ".", "UVM_FILE");
      end while(id_file_handles.next(idx));
      printer.print_array_footer();
    end

    // severity files
    if(severity_file_handles.first(l_severity)) begin
      printer.print_array_header("severity_file_handles",4,"array");
      do begin
        uvm_severity_type sev = uvm_severity_type'(l_severity);
        printer.print_int($sformatf("[%s]", sev.name()), 
          severity_file_handles[l_severity], 32, UVM_HEX, ".", "UVM_FILE");
      end while(severity_file_handles.next(l_severity));
      printer.print_array_footer();
    end

    // sev and id files
    if(severity_id_file_handles.size() != 0) begin
      int _total_cnt;
      foreach (severity_id_file_handles[l_severity])
        _total_cnt += severity_id_file_handles[l_severity].num();
      printer.print_array_header("severity_id_file_handles", _total_cnt,
        "array");
      if(severity_id_file_handles.first(l_severity)) begin
        do begin
          uvm_severity_type sev = uvm_severity_type'(l_severity);
          uvm_id_file_array id_f_ary = severity_id_file_handles[l_severity];
          if(id_f_ary.first(idx))
          do begin
            printer.print_int($sformatf("[%s:%s]", sev.name(), idx),
              id_f_ary.get(idx), 32, UVM_HEX, ".", "UVM_FILE");
          end while(id_f_ary.next(idx));
        end while(severity_id_file_handles.next(l_severity));
      end
      printer.print_array_footer();
    end

  endfunction

  
  // Function: process_report_message
  //
  // This is the common handler method used by the four core reporting methods
  // (e.g., uvm_report_error) in <uvm_report_object>.

  virtual function void process_report_message(uvm_report_message report_message);

    uvm_report_server srvr = uvm_report_server::get_server();

    // Check for severity overrides and apply them before calling the server.
    // An id specific override has precedence over a generic severity override.
    if(sev_id_overrides.exists(report_message.id)) begin
      if(sev_id_overrides[report_message.id].exists(int'(report_message.severity)))
        report_message.severity = 
          uvm_severity_type'(sev_id_overrides[report_message.id].get(report_message.severity));
    end
    else begin
      if(sev_overrides.exists(report_message.severity))
        report_message.severity = 
          uvm_severity_type'(sev_overrides.get(int'(report_message.severity)));
    end

    report_message.file = get_file_handle(report_message.severity, report_message.id);
    report_message.report_handler = this;
    report_message.action = get_action(report_message.severity, report_message.id);
    srvr.m_process_report_message(report_message);
    
  endfunction


  // Function: format_action
  //
  // Returns a string representation of the ~action~, e.g., "DISPLAY".

  static function string format_action(uvm_action action);
    string s;

    if(uvm_action_type'(action) == UVM_NO_ACTION) begin
      s = "NO ACTION";
    end
    else begin
      s = "";
      if(action & UVM_DISPLAY)   s = {s, "DISPLAY "};
      if(action & UVM_LOG)       s = {s, "LOG "};
      if(action & UVM_RM_RECORD) s = {s, "RM_RECORD "};
      if(action & UVM_COUNT)     s = {s, "COUNT "};
      if(action & UVM_CALL_HOOK) s = {s, "CALL_HOOK "};
      if(action & UVM_EXIT)      s = {s, "EXIT "};
      if(action & UVM_STOP)      s = {s, "STOP "};
    end

    return s;
  endfunction


  // Function- initialize
  //
  // Internal method for initializing report handler.

  function void initialize();

    set_default_file(0);
    m_max_verbosity_level = UVM_MEDIUM;

    id_actions=new();
    id_verbosities=new();
    id_file_handles=new();
    sev_overrides=new();

    set_severity_action(UVM_INFO,    UVM_DISPLAY);
    set_severity_action(UVM_WARNING, UVM_DISPLAY);
    set_severity_action(UVM_ERROR,   UVM_DISPLAY | UVM_COUNT);
    set_severity_action(UVM_FATAL,   UVM_DISPLAY | UVM_EXIT);

    set_severity_file(UVM_INFO, default_file_handle);
    set_severity_file(UVM_WARNING, default_file_handle);
    set_severity_file(UVM_ERROR,   default_file_handle);
    set_severity_file(UVM_FATAL,   default_file_handle);

  endfunction

  
  // Function- get_severity_id_file
  //
  // Return the file id based on the severity and the id

  local function UVM_FILE get_severity_id_file(uvm_severity severity, string id);

    uvm_id_file_array array;

    if(severity_id_file_handles.exists(severity)) begin
      array = severity_id_file_handles[severity];      
      if(array.exists(id))
        return array.get(id);
    end


    if(id_file_handles.exists(id))
      return id_file_handles.get(id);

    if(severity_file_handles.exists(severity))
      return severity_file_handles[severity];

    return default_file_handle;

  endfunction


  // Function- set_verbosity_level
  //
  // Internal method called by uvm_report_object.

  function void set_verbosity_level(int verbosity_level);
    m_max_verbosity_level = verbosity_level;
  endfunction


  // Function- get_verbosity_level
  //
  // Returns the verbosity associated with the given ~severity~ and ~id~.
  // 
  // First, if there is a verbosity associated with the ~(severity,id)~ pair,
  // return that.  Else, if there is an verbosity associated with the ~id~, return
  // that.  Else, return the max verbosity setting.

  function int get_verbosity_level(uvm_severity severity=UVM_INFO, string id="" );

    uvm_id_verbosities_array array;
    if(severity_id_verbosities.exists(severity)) begin
      array = severity_id_verbosities[severity];
      if(array.exists(id)) begin
        return array.get(id);
      end
    end

    if(id_verbosities.exists(id)) begin
      return id_verbosities.get(id);
    end

    return m_max_verbosity_level;

  endfunction


  // Function- get_action
  //
  // Returns the action associated with the given ~severity~ and ~id~.
  // 
  // First, if there is an action associated with the ~(severity,id)~ pair,
  // return that.  Else, if there is an action associated with the ~id~, return
  // that.  Else, if there is an action associated with the ~severity~, return
  // that. Else, return the default action associated with the ~severity~.

  function uvm_action get_action(uvm_severity severity, string id);

    uvm_id_actions_array array;
    if(severity_id_actions.exists(severity)) begin
      array = severity_id_actions[severity];
      if(array.exists(id))
        return array.get(id);
    end

    if(id_actions.exists(id))
      return id_actions.get(id);

    return severity_actions[severity];

  endfunction


  // Function- get_file_handle
  //
  // Returns the file descriptor associated with the given ~severity~ and ~id~.
  //
  // First, if there is a file handle associated with the ~(severity,id)~ pair,
  // return that. Else, if there is a file handle associated with the ~id~, return
  // that. Else, if there is an file handle associated with the ~severity~, return
  // that. Else, return the default file handle.

  function UVM_FILE get_file_handle(uvm_severity severity, string id);
    UVM_FILE file;
  
    file = get_severity_id_file(severity, id);
    if (file != 0)
      return file;
  
    if (id_file_handles.exists(id)) begin
      file = id_file_handles.get(id);
      if (file != 0)
        return file;
    end

    if (severity_file_handles.exists(severity)) begin
      file = severity_file_handles[severity];
      if(file != 0)
        return file;
    end

    return default_file_handle;
  endfunction


  // Function- set_severity_action
  // Function- set_id_action
  // Function- set_severity_id_action
  // Function- set_id_verbosity
  // Function- set_severity_id_verbosity
  //
  // Internal methods called by uvm_report_object.

  function void set_severity_action(input uvm_severity severity,
                                    input uvm_action action);
    severity_actions[severity] = action;
  endfunction

  function void set_id_action(input string id, input uvm_action action);
    id_actions.add(id, action);
  endfunction

  function void set_severity_id_action(uvm_severity severity,
                                       string id,
                                       uvm_action action);
    if(!severity_id_actions.exists(severity))
      severity_id_actions[severity] = new;
    severity_id_actions[severity].add(id,action);
  endfunction
  
  function void set_id_verbosity(input string id, input int verbosity);
    id_verbosities.add(id, verbosity);
  endfunction

  function void set_severity_id_verbosity(uvm_severity severity,
                                       string id,
                                       int verbosity);
    if(!severity_id_verbosities.exists(severity))
      severity_id_verbosities[severity] = new;
    severity_id_verbosities[severity].add(id,verbosity);
  endfunction

  // Function- set_default_file
  // Function- set_severity_file
  // Function- set_id_file
  // Function- set_severity_id_file
  //
  // Internal methods called by uvm_report_object.

  function void set_default_file (UVM_FILE file);
    default_file_handle = file;
  endfunction

  function void set_severity_file (uvm_severity severity, UVM_FILE file);
    severity_file_handles[severity] = file;
  endfunction

  function void set_id_file (string id, UVM_FILE file);
    id_file_handles.add(id, file);
  endfunction

  function void set_severity_id_file(uvm_severity severity,
                                     string id, UVM_FILE file);
    if(!severity_id_file_handles.exists(severity))
      severity_id_file_handles[severity] = new;
    severity_id_file_handles[severity].add(id, file);
  endfunction

  function void set_severity_override(uvm_severity cur_severity,
                                      uvm_severity new_severity);
    sev_overrides.add(cur_severity, new_severity);
  endfunction

  function void set_severity_id_override(uvm_severity cur_severity,
                                         string id,
                                         uvm_severity new_severity);
    // has precedence over set_severity_override
    // silently override previous setting
    uvm_sev_override_array arr;
    if(!sev_id_overrides.exists(id))
      sev_id_overrides[id] = new;
 
    sev_id_overrides[id].add(cur_severity, new_severity);
  endfunction

  
`ifndef UVM_NO_DEPRECATED


  // Function- report
  //
  // This is the common handler method used by the four core reporting methods
  // (e.g., uvm_report_error) in <uvm_report_object>.

  virtual function void report(
      uvm_severity severity,
      string name,
      string id,
      string message,
      int verbosity_level,
      string filename,
      int line,
      uvm_report_object client
      );

    bit l_report_enabled = 0;
    uvm_report_message l_report_message;
    if (!uvm_report_enabled(verbosity_level, UVM_INFO, id))
      return;
    l_report_message = uvm_report_message::get_report_message();
    l_report_message.report_object = client;
    l_report_message.context_name = "";
    l_report_message.filename = filename;
    l_report_message.line = line;
    l_report_message.action = get_action(severity,id);
    l_report_message.severity = uvm_severity_type'(severity);
    l_report_message.id = id;
    l_report_message.message = message;
    l_report_message.verbosity = verbosity_level;
    process_report_message(l_report_message);
    l_report_message.free_report_message(l_report_message);

  endfunction


  // Function- run_hooks
  //
  // The run_hooks method is called if the <UVM_CALL_HOOK> action is set for a
  // report. It first calls the client's <uvm_report_object::report_hook> method, 
  // followed by the appropriate severity-specific hook method. If either 
  // returns 0, then the report is not processed.

  virtual function bit run_hooks(uvm_report_object client,
                                 uvm_severity severity,
                                 string id,
                                 string message,
                                 int verbosity,
                                 string filename,
                                 int line);

    bit ok;

    ok = client.report_hook(id, message, verbosity, filename, line);

    case(severity)
      UVM_INFO:
       ok &= client.report_info_hook   (id, message, verbosity, filename, line);
      UVM_WARNING:
       ok &= client.report_warning_hook(id, message, verbosity, filename, line);
      UVM_ERROR:
       ok &= client.report_error_hook  (id, message, verbosity, filename, line);
      UVM_FATAL:
       ok &= client.report_fatal_hook  (id, message, verbosity, filename, line);
    endcase

    return ok;

  endfunction


  // Function- dump_state
  //
  // Internal method for debug.

  function void dump_state();

    string s;
    uvm_action a;
    string idx;
    UVM_FILE file;
    uvm_report_server srvr;
 
    uvm_id_actions_array id_a_ary;
    uvm_id_verbosities_array id_v_ary;
    uvm_id_file_array id_f_ary;

    srvr = uvm_report_server::get_server();

    srvr.f_display(0,
      "----------------------------------------------------------------------");
    srvr.f_display(0, "report handler state dump");
    srvr.f_display(0, "");

    // verbosities

    srvr.f_display(0, "");   
    srvr.f_display(0, "+-----------------+");
    srvr.f_display(0, "|   Verbosities   |");
    srvr.f_display(0, "+-----------------+");
    srvr.f_display(0, "");   

    $sformat(s, "max verbosity level = %d", m_max_verbosity_level);
    srvr.f_display(0, s);

    srvr.f_display(0, "*** verbosities by id");

    if(id_verbosities.first(idx))
    do begin
      uvm_verbosity v = uvm_verbosity'(id_verbosities.get(idx));
      $sformat(s, "[%s] --> %s", idx, v.name());
      srvr.f_display(0, s);
    end while(id_verbosities.next(idx));

    // verbosities by id

    srvr.f_display(0, "");
    srvr.f_display(0, "*** verbosities by id and severity");

    foreach( severity_id_verbosities[severity] ) begin
      uvm_severity_type sev = uvm_severity_type'(severity);
      id_v_ary = severity_id_verbosities[severity];
      if(id_v_ary.first(idx))
      do begin
        uvm_verbosity v = uvm_verbosity'(id_v_ary.get(idx));
        $sformat(s, "%s:%s --> %s",
           sev.name(), idx, v.name());
        srvr.f_display(0, s);        
      end while(id_v_ary.next(idx));
    end

    // actions

    srvr.f_display(0, "");   
    srvr.f_display(0, "+-------------+");
    srvr.f_display(0, "|   actions   |");
    srvr.f_display(0, "+-------------+");
    srvr.f_display(0, "");   

    srvr.f_display(0, "*** actions by severity");
    foreach( severity_actions[severity] ) begin
      uvm_severity_type sev = uvm_severity_type'(severity);
      $sformat(s, "%s = %s",
       sev.name(), format_action(severity_actions[severity]));
      srvr.f_display(0, s);
    end

    srvr.f_display(0, "");
    srvr.f_display(0, "*** actions by id");

    if(id_actions.first(idx))
    do begin
      $sformat(s, "[%s] --> %s", idx, format_action(id_actions.get(idx)));
      srvr.f_display(0, s);
    end while(id_actions.next(idx));

    // actions by id

    srvr.f_display(0, "");
    srvr.f_display(0, "*** actions by id and severity");

    foreach( severity_id_actions[severity] ) begin
      uvm_severity_type sev = uvm_severity_type'(severity);
      id_a_ary = severity_id_actions[severity];
      if(id_a_ary.first(idx))
      do begin
        $sformat(s, "%s:%s --> %s",
           sev.name(), idx, format_action(id_a_ary.get(idx)));
        srvr.f_display(0, s);        
      end while(id_a_ary.next(idx));
    end

    // Files

    srvr.f_display(0, "");
    srvr.f_display(0, "+-------------+");
    srvr.f_display(0, "|    files    |");
    srvr.f_display(0, "+-------------+");
    srvr.f_display(0, "");   

    $sformat(s, "default file handle = %d", default_file_handle);
    srvr.f_display(0, s);

    srvr.f_display(0, "");
    srvr.f_display(0, "*** files by severity");
    foreach( severity_file_handles[severity] ) begin
      uvm_severity_type sev = uvm_severity_type'(severity);
      file = severity_file_handles[severity];
      $sformat(s, "%s = %d", sev.name(), file);
      srvr.f_display(0, s);
    end

    srvr.f_display(0, "");
    srvr.f_display(0, "*** files by id");

    if(id_file_handles.first(idx))
    do begin
      file = id_file_handles.get(idx);
      $sformat(s, "id %s --> %d", idx, file);
      srvr.f_display(0, s);
    end while (id_file_handles.next(idx));

    srvr.f_display(0, "");
    srvr.f_display(0, "*** files by id and severity");

    foreach( severity_id_file_handles[severity] ) begin
      uvm_severity_type sev = uvm_severity_type'(severity);
      id_f_ary = severity_id_file_handles[severity];
      if(id_f_ary.first(idx))
      do begin
        $sformat(s, "%s:%s --> %d", sev.name(), idx, id_f_ary.get(idx));
        srvr.f_display(0, s);
      end while(id_f_ary.next(idx));
    end

    srvr.dump_server_state();
    
    srvr.f_display(0,
      "----------------------------------------------------------------------");
  endfunction


`endif


endclass : uvm_report_handler

`endif // UVM_REPORT_HANDLER_SVH

