//
//----------------------------------------------------------------------
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
//----------------------------------------------------------------------

`ifndef UVM_EXTERN_REPORT_SERVER_SVH
`define UVM_EXTERN_REPORT_SERVER_SVH

  //--------------------------------------------------------------------
  // report
  //
  // add line and file info later ...
  //
  // this is the public access report function. It is not
  // visible to the user but is accessed via
  // uvm_report_info, uvm_report_warning,
  // uvm_report_error and uvm_report_fatal.
  //--------------------------------------------------------------------
  function void uvm_report_server::report(
      uvm_severity severity,
      string name,
      string id,
      string message,
      int verbosity_level,
      string filename,
      int line,
      uvm_report_object client
      );
  
    string m;
    uvm_action a;
    UVM_FILE f;
    bit report_ok;
    uvm_report_handler rh;

    rh = client.get_report_handler();
    
    // filter based on verbosity level
 
    if(severity == uvm_severity'(UVM_INFO) && verbosity_level > rh.m_max_verbosity_level) begin
       return;
    end

    // determine file to send report and actions to execute

    a = rh.get_action(severity, id); 
    if( uvm_action_type'(a) == UVM_NO_ACTION )
      return;

    f = rh.get_file_handle(severity, id);

    // The hooks can do additional filtering.  If the hook function
    // return 1 then continue processing the report.  If the hook
    // returns 0 then skip processing the report.

    if(a & UVM_CALL_HOOK)
      report_ok = rh.run_hooks(client, severity, id,
                              message, verbosity_level, filename, line);
    else
      report_ok = 1;

    if(report_ok)
      report_ok = uvm_report_catcher::process_all_report_catchers(
                     this, client, severity, name, id, message,
                     verbosity_level, a, filename, line);

    if(report_ok) begin	
      m = compose_message(severity, name, id, message, filename, line); 
      process_report(severity, name, id, message, a, f, filename,
                     line, m, verbosity_level, client);
    end
    
  endfunction

  //--------------------------------------------------------------------
  // process_report
  //--------------------------------------------------------------------
  function void  uvm_report_server::process_report(
      uvm_severity severity,
      string name,
      string id,
      string message,
      uvm_action action,
      UVM_FILE file,
      string filename,
      int line,
      string composed_message,
      int verbosity_level,
      uvm_report_object client
    );

    // update counts
    incr_severity_count(severity);
    incr_id_count(id);

    if(action & UVM_DISPLAY)
      $display(composed_message);

    if(action & UVM_LOG)
      if(file != 0 || !(action & UVM_DISPLAY)) // don't display twice
        $fdisplay(file, composed_message);

    if(action & UVM_EXIT) client.die();

    if(action & UVM_COUNT) begin
      if(get_max_quit_count() != 0) begin
        incr_quit_count();
        if(is_quit_count_reached()) begin
          client.die();
        end
      end  
    end

    if (action & UVM_STOP) $stop;

  endfunction

  //--------------------------------------------------------------------
  // compose_message
  //--------------------------------------------------------------------
  function string  uvm_report_server::compose_message(
    uvm_severity severity,
    string name,
    string id,
    string message,
    string filename,
    int    line						     
);
     uvm_severity_type sv;
     string time_str;
     string line_str;
      
     sv = uvm_severity_type'(severity);
     $swrite(time_str, "%0t", $time);
   
     case(1)
       (name == "" && filename == ""):
	      return {sv.name(), " @ ", time_str, " [", id, "] ", message};
       (name != "" && filename == ""):
	      return {sv.name(), " @ ", time_str, ": ", name, " [", id, "] ", message};
       (name == "" && filename != ""):
            begin
                $swrite(line_str, "%0d", line);
		return {sv.name(), " ",filename, "(", line_str, ")", " @ ", time_str, " [", id, "] ", message};
            end
       (name != "" && filename != ""):
            begin
                $swrite(line_str, "%0d", line);
	        return {sv.name(), " ", filename, "(", line_str, ")", " @ ", time_str, ": ", name, " [", id, "] ", message};
            end
     endcase // case(1)
  endfunction 

`endif // UVM_EXTERN_REPORT_SERVER_SVH
