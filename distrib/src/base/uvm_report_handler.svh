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

`ifndef UVM_REPORT_HANDLER_SVH
`define UVM_REPORT_HANDLER_SVH

typedef class uvm_report_object;
typedef class uvm_report_server;
typedef class uvm_report_global_server;

`ifdef UVM_USE_AAOFAA_WA
    class uvm_hash #(type T=int, I1=int, I2=int);
      local T d[string];
      function void set(I1 i1, I2 i2, T t);
        string s;
        $swrite(s,i1,":",i2);
        d[s] = t;
      endfunction
      function T get(I1 i1,I2 i2);
        string s;
        $swrite(s,i1,":",i2);
        return d[s];
      endfunction
      function int exists(I1 i1, I2 i2);
        string s;
        if(d.num() == 0) return 0;
        $swrite(s,i1,":",i2);
        return d.exists(s);
      endfunction
      function int first(string index);
        return d.first(index);
      endfunction
      function int next(string index);
        return d.next(index);
      endfunction
      function T fetch(string index);
        return d[index];
      endfunction
    endclass : uvm_hash
`endif
   

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

class uvm_report_handler;

  uvm_report_global_server m_glob;

  int m_max_verbosity_level;

  // internal variables

  uvm_action severity_actions[uvm_severity];

  `ifndef UVM_USE_AAOFAA_WA
  id_actions_array id_actions;
  id_actions_array severity_id_actions[uvm_severity];

  // file handles : default, severity, action, (severity,id)
  UVM_FILE default_file_handle;
  UVM_FILE severity_file_handles[uvm_severity];
  id_file_array id_file_handles;
  id_file_array severity_id_file_handles[uvm_severity];
  `endif

  `ifdef UVM_USE_AAOFAA_WA
  uvm_action id_actions[string];
  uvm_hash #(uvm_action,uvm_severity,string) severity_id_actions = new;

  UVM_FILE default_file_handle;
  UVM_FILE severity_file_handles[uvm_severity];
  UVM_FILE id_file_handles[string];
  uvm_hash #(UVM_FILE,uvm_severity,string) severity_id_file_handles = new;
  `endif


  // Function: new
  // 
  // Creates and initializes a new uvm_report_handler object.

  function new();
    m_glob = new();
    initialize;
  endfunction


  // Function- get_server
  //
  // Internal method called by <uvm_report_object::get_report_server>.

  function uvm_report_server get_server();
    return m_glob.get_server();
  endfunction


  // Function- set_max_quit_count
  //
  // Internal method called by <uvm_report_object::set_report_max_quit_count>.

  function void set_max_quit_count(int max_count);
    uvm_report_server srvr;
    srvr = m_glob.get_server();
    srvr.set_max_quit_count(max_count);
  endfunction


  // Function- summarize
  //
  // Internal method called by <uvm_report_object::report_summarize>.

  function void summarize(UVM_FILE file = 0);
    uvm_report_server srvr;
    srvr = m_glob.get_server();
    srvr.summarize(file);
  endfunction


  // Function- report_header
  //
  // Internal method called by <uvm_report_object::report_header>

  function void report_header(UVM_FILE file = 0);

    uvm_report_server srvr;

    srvr = m_glob.get_server();
    srvr.f_display(file,
      "----------------------------------------------------------------");
    srvr.f_display(file, uvm_revision_string());
    srvr.f_display(file, uvm_mgc_copyright);
    srvr.f_display(file, uvm_cdn_copyright);
    srvr.f_display(file, uvm_snps_copyright);
    srvr.f_display(file,
      "----------------------------------------------------------------");
  endfunction


  // Function- initialize
  // 
  // This method is called by the constructor to initialize the arrays and
  // other variables described above to their default values.

  function void initialize();
    set_default_file(0);
    m_max_verbosity_level = UVM_MEDIUM;
    set_defaults();
  endfunction


  // Function: run_hooks
  //
  // The run_hooks method is called if the <UVM_CALL_HOOK> action is set for a
  // report. It first calls the client's <report_hook> method, followed by the
  // appropriate severity-specific hook method. If either returns 0, then the
  // report is not processed.

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

  
  // Function- get_severity_id_file
  //
  // Return the file id based on the severity and the id

  local function UVM_FILE get_severity_id_file(uvm_severity severity, string id);

   `ifndef UVM_USE_AAOFAA_WA
    id_file_array array;

    if(severity_id_file_handles.exists(severity)) begin
      array = severity_id_file_handles[severity];      
      if(array.exists(id))
        return array[id];
    end
   `else
    if (severity_id_file_handles.exists(severity,id))
      return severity_id_file_handles.get(severity,id);
   `endif


    if(id_file_handles.exists(id))
      return id_file_handles[id];

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


  // Function: get_verbosity_level
  //
  // Returns the configured maximum verbosity level.

  function int get_verbosity_level();
    return m_max_verbosity_level;
  endfunction


  // Function: get_action
  //
  // Returns the action associated with the given ~severity~ and ~id~.
  // 
  // First, if there is an action associated with the ~(severity,id)~ pair,
  // return that.  Else, if there is an action associated with the ~id~, return
  // that.  Else, if there is an action associated with the ~severity~, return
  // that. Else, return the default action associated with the ~severity~.

  function uvm_action get_action(uvm_severity severity, string id);

   `ifndef UVM_USE_AAOFAA_WA
    id_actions_array array;

    if(severity_id_actions.exists(severity)) begin
      array = severity_id_actions[severity];
      if(array.exists(id))
        return array[id];
    end
   `else
    if (severity_id_actions.exists(severity,id))
      return severity_id_actions.get(severity,id);
   `endif

    if(id_actions.exists(id))
      return id_actions[id];

    return severity_actions[severity];

  endfunction


  // Function: get_file_handle
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
      file = id_file_handles[id];
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


  // Function: report
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
 
    uvm_report_server srvr;
    srvr = m_glob.get_server();
    srvr.report(severity,name,id,message,verbosity_level,filename,line,client);
    
  endfunction


  // Function: format_action
  //
  // Returns a string representation of the ~action~, e.g., "DISPLAY".

  function string format_action(uvm_action action);
    string s;

    if(uvm_action_type'(action) == UVM_NO_ACTION) begin
      s = "NO ACTION";
    end
    else begin
      s = "";
      if(action & UVM_DISPLAY)   s = {s, "DISPLAY "};
      if(action & UVM_LOG)       s = {s, "LOG "};
      if(action & UVM_COUNT)     s = {s, "COUNT "};
      if(action & UVM_EXIT)      s = {s, "EXIT "};
      if(action & UVM_CALL_HOOK) s = {s, "CALL_HOOK "};
      if(action & UVM_STOP)      s = {s, "STOP "};
    end

    return s;
  endfunction


  // Function- set_default
  //
  // Internal method for initializing report handler.

  function void set_defaults();
    set_severity_action(UVM_INFO,    UVM_DISPLAY);
    set_severity_action(UVM_WARNING, UVM_DISPLAY);
    set_severity_action(UVM_ERROR,   UVM_DISPLAY | UVM_COUNT);
    set_severity_action(UVM_FATAL,   UVM_DISPLAY | UVM_EXIT);

    set_severity_file(UVM_INFO, default_file_handle);
    set_severity_file(UVM_WARNING, default_file_handle);
    set_severity_file(UVM_ERROR,   default_file_handle);
    set_severity_file(UVM_FATAL,   default_file_handle);
  endfunction


  // Function- set_severity_action
  // Function- set_id_action
  // Function- set_severity_id_action
  //
  // Internal methods called by uvm_report_object.

  function void set_severity_action(input uvm_severity severity,
                                    input uvm_action action);
    severity_actions[severity] = action;
  endfunction

  function void set_id_action(input string id, input uvm_action action);
    id_actions[id] = action;
  endfunction

  function void set_severity_id_action(uvm_severity severity,
                                       string id,
                                       uvm_action action);
    `ifndef UVM_USE_AAOFAA_WA
    severity_id_actions[severity][id] = action;
    `else
    severity_id_actions.set(severity,id,action);
    `endif
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
    id_file_handles[id] = file;
  endfunction

  function void set_severity_id_file(uvm_severity severity,
                                     string id, UVM_FILE file);
  
    `ifndef UVM_USE_AAOFAA_WA
    severity_id_file_handles[severity][id] = file;
    `else
    severity_id_file_handles.set(severity,id,file);
    `endif
  endfunction

  
  // Function- dump_state
  //
  // Internal method for debug.

  function void dump_state();

    string s;
    uvm_severity_type severity;
    uvm_action a;
    string idx;
    UVM_FILE file;
    uvm_report_server srvr;
 
   `ifndef UVM_USE_AAOFAA_WA
     id_actions_array id_a_ary;
     id_file_array id_f_ary;
   `else
     UVM_FILE id_f_ary[string];
   `endif

    srvr = m_glob.get_server();

    srvr.f_display(0,
      "----------------------------------------------------------------------");
    srvr.f_display(0, "report handler state dump");
    srvr.f_display(0, "");

    $sformat(s, "max verbosity level = %d", m_max_verbosity_level);
    srvr.f_display(0, s);

    // actions

    srvr.f_display(0, "");   
    srvr.f_display(0, "+-------------+");
    srvr.f_display(0, "|   actions   |");
    srvr.f_display(0, "+-------------+");
    srvr.f_display(0, "");   

    srvr.f_display(0, "*** actions by severity");
    foreach( severity_actions[severity] ) begin
      $sformat(s, "%s = %s",
       uvm_severity_type'(severity), format_action(severity_actions[severity]));
      srvr.f_display(0, s);
    end

    srvr.f_display(0, "");
    srvr.f_display(0, "*** actions by id");

    foreach( id_actions[idx] ) begin
      $sformat(s, "[%s] --> %s", idx, format_action(id_actions[idx]));
      srvr.f_display(0, s);
    end

    // actions by id

    srvr.f_display(0, "");
    srvr.f_display(0, "*** actions by id and severity");

    `ifndef UVM_USE_AAOFAA_WA
    foreach( severity_id_actions[severity] ) begin
      // ADAM: is id_a_ary __copied__?
      id_a_ary = severity_id_actions[severity];
      foreach( id_a_ary[idx] ) begin
        $sformat(s, "%s:%s --> %s",
           uvm_severity_type'(severity), idx, format_action(id_a_ary[idx]));
        srvr.f_display(0, s);        
      end
    end
    `else
    begin
      string idx;
      if ( severity_id_actions.first( idx ) )
        do begin
            $sformat(s, "%s --> %s", idx,
              format_action(severity_id_actions.fetch(idx)));
            srvr.f_display(0, s);        
        end
        while ( severity_id_actions.next( idx ) );
    end
    `endif

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
      file = severity_file_handles[severity];
      $sformat(s, "%s = %d", uvm_severity_type'(severity), file);
      srvr.f_display(0, s);
    end

    srvr.f_display(0, "");
    srvr.f_display(0, "*** files by id");

    foreach ( id_file_handles[idx] ) begin
      file = id_file_handles[idx];
      $sformat(s, "id %s --> %d", idx, file);
      srvr.f_display(0, s);
    end

    srvr.f_display(0, "");
    srvr.f_display(0, "*** files by id and severity");

    `ifndef UVM_USE_AAOFAA_WA
    foreach( severity_id_file_handles[severity] ) begin
      id_f_ary = severity_id_file_handles[severity];
      foreach ( id_f_ary[idx] ) begin
        $sformat(s, "%s:%s --> %d", uvm_severity_type'(severity), idx, id_f_ary[idx]);
        srvr.f_display(0, s);
      end
    end
    `else
    begin
      string idx;
      if ( severity_id_file_handles.first( idx ) )
        do begin
            $sformat(s, "%s --> %s", idx,
              format_action(severity_id_file_handles.fetch(idx)));
            srvr.f_display(0, s);        
        end
        while ( severity_id_file_handles.next( idx ) );
    end
    `endif

    srvr.dump_server_state();
    
    srvr.f_display(0,
      "----------------------------------------------------------------------");
  endfunction

endclass : uvm_report_handler


//------------------------------------------------------------------------------

class uvm_default_report_server;

  uvm_report_global_server glob;

  function new();
    glob = new;
  endfunction

  function uvm_report_server get_server();
    return glob.get_server();
  endfunction
  
endclass

`endif // UVM_REPORT_HANDLER_SVH

