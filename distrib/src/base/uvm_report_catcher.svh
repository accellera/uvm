// $Id: uvm_report_catcher.svh,v 1.1.2.10 2010/04/09 15:03:25 janick Exp $
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

`ifndef UVM_REPORT_CATCHER_SVH
`define UVM_REPORT_CATCHER_SVH

typedef class uvm_report_object;
typedef class uvm_report_handler;
typedef class uvm_report_server;

//------------------------------------------------------------------------------
//
// CLASS: uvm_report_catcher
// The uvm_report_catcher is used to catch messages reports issued by the uvm report
// server. Multiple report catchers can be registered with the report server.
// The catchers can be registered as default catchers which catch all uvm reports,
// based on id, based on serverity and both severity and id. User extensions of
// uvm_report_catcher must implement the catch() method in which the action to be
// taken on catching the report is specified. The catch method can return CAUGHT
// ,in which case further processing of the report is immediately stopped, or return
// TRHOW in which case the (possibly modified) report is passed on to other registered
// catchers. The catchers are processed in the order in which they are registered.
//
// On catching a report the catch() method can modify the severity, id, action,
// verbosity or the report string itself before the report is finally issued by
// the report server.
// The report can be immediately issued from within the catcher class by calling the
// issue method
//
// The catcher maintains a count of all reports with FATAL,ERROR or WARNING severity
// and a count of all reports with FATAL, ERROR or WARNING severity whose severity
// was lowered. These statistics are reported in the summary of the uvm_report_server.
//------------------------------------------------------------------------------

virtual class uvm_report_catcher extends uvm_object;

  typedef enum { UNKNOWN_ACTION, THROW, CAUGHT} action_e;

  class sev_id_struct;
    bit sev_specified ;
    bit id_specified ;
    uvm_severity sev ;
    string  id ;
    bit is_on ;
  endclass

  local static uvm_severity m_modified_severity;
  local static int m_modified_verbosity;
  local static string m_modified_id;
  local static string m_modified_message;
  local static string m_file_name;
  local static int m_line_number;
  local static uvm_report_object m_client;
  local static uvm_action m_modified_action;
  local static uvm_report_server m_server;
  local static string m_name;
  
  local static sev_id_struct m_sev_id_array[uvm_report_catcher];
  local static uvm_report_catcher m_catcher_q[$];

  local static int m_demoted_fatal   = 0;
  local static int m_demoted_error   = 0; 
  local static int m_demoted_warning = 0; 
  local static int m_caught_fatal    = 0;
  local static int m_caught_error    = 0;
  local static int m_caught_warning  = 0;

  const static int DO_NOT_CATCH      = 1; 
  const static int DO_NOT_MODIFY     = 2; 
  local static int m_debug_flags     = 0;

  local static  uvm_severity  m_orig_severity;
  local static  uvm_action    m_orig_action;
  local static  string        m_orig_id;
  local static  int           m_orig_verbosity;
  local static  string        m_orig_message;

  local static  bit do_report = 0;
  
  // new
  //
  //

  function new(string name = "uvm_report_catcher");
    super.new(name);

    do_report = 1;
  endfunction    

  //catcher_mode
  //
  //
  
  function void catcher_mode(bit on=1);
    this.m_sev_id_array[this].is_on = on;
  endfunction
  
  //is_enabled
  //
  //
  
  function bit is_enabled();
    return this.m_sev_id_array[this].is_on;
  endfunction      

  //get_client
  //
  //

  function uvm_report_object get_client();
    return this.m_client; 
  endfunction

  //get_severity
  //
  //

  function uvm_severity get_severity();
    return this.m_modified_severity;
  endfunction
  
  //get_verbosity
  //
  //
  
  function int get_verbosity();
    return this.m_modified_verbosity;
  endfunction
  
  //get_id
  //
  //
  
  function string get_id();
    return this.m_modified_id;
  endfunction
  
  //get_message
  //
  //
  
  function string get_message();
     return this.m_modified_message;
  endfunction
  
  //get_action
  //
  //
  
  function uvm_action get_action();
    return this.m_modified_action;
  endfunction
  
  //get_fname
  //
  //
  
  function string get_fname();
    return this.m_file_name;
  endfunction             

  //get_line
  //
  //

  function int get_line();
    return this.m_line_number;
  endfunction
  
  //set_severity
  //
  //
  
  protected function void set_severity(uvm_severity severity);
    this.m_modified_severity = severity;
  endfunction
  
  //set_verbosity
  //
  //

  protected function void set_verbosity(int verbosity);
    this.m_modified_verbosity = verbosity;
  endfunction      

  //set_id
  //
  //

  protected function void set_id(string id);
    this.m_modified_id = id;
  endfunction
  
  //set_message
  //
  //

  protected function void set_message(string message);
    this.m_modified_message = message;
  endfunction
  
  //set_action
  //
  //
  
  protected function void set_action(uvm_action action);
    this.m_modified_action = action;
  endfunction
  
       
  //add_report_default_catcher
  //
  //

  static function void add_report_default_catcher(uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
    sev_id_struct sev_id;
    if(catcher == null) begin
      uvm_top.uvm_report_error("RPTCTHR", "NULL uvm_report_catcher object passed to uvm_report_catcher::add_report_default_catcher()", UVM_NONE, `uvm_file, `uvm_line);
      return;
    end
    
    if(m_sev_id_array.exists(catcher)) begin
      catcher.uvm_report_warning("RPTCTHR", "Catcher instance already registered. Ignoring subsequent call to uvm_report_catcher::add_report_default_catcher()", UVM_NONE, `uvm_file, `uvm_line);   
      return;
    end    

    if (ordering == UVM_APPEND) m_catcher_q.push_back(catcher);
    else m_catcher_q.push_front(catcher);

    sev_id = new;
    sev_id.is_on             = 1;
    m_sev_id_array[catcher]  = sev_id;
  endfunction

  
  //add_report_severity_catcher
  //
  //

  static function void add_report_severity_catcher(uvm_severity severity, uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
    sev_id_struct sev_id;
    if(catcher == null) begin
      uvm_top.uvm_report_error("RPTCTHR", "NULL uvm_report_catcher object passed to uvm_report_catcher::add_report_severity_catcher()", UVM_NONE, `uvm_file, `uvm_line);
      return;
    end
    
    if(m_sev_id_array.exists(catcher)) begin
      catcher.uvm_report_warning("RPTCTHR", "Catcher instance already registered. Ignoring subsequent call to uvm_report_catcher::add_report_severity_catcher()", UVM_NONE, `uvm_file, `uvm_line);   
      return;
    end    

    if (ordering == UVM_APPEND) m_catcher_q.push_back(catcher);
    else m_catcher_q.push_front(catcher);

    sev_id = new;
    sev_id.sev_specified     = 1;
    sev_id.sev               = severity;
    sev_id.is_on             = 1;
    m_sev_id_array[catcher]  = sev_id;
  endfunction


  //add_report_id_catcher
  //
  //

  static function void add_report_id_catcher(string id, uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
    sev_id_struct sev_id;
    if(catcher == null) begin
      uvm_top.uvm_report_error("RPTCTHR", "NULL uvm_report_catcher object passed to uvm_report_catcher::add_report_id_catcher()", UVM_NONE, `uvm_file, `uvm_line);
      return;
    end
    
    if(m_sev_id_array.exists(catcher)) begin
      catcher.uvm_report_warning("RPTCTHR", "Catcher instance already registered. Ignoring subsequent call to uvm_report_catcher::add_report_id_catcher()", UVM_NONE, `uvm_file, `uvm_line);   
      return;
    end    

    if(id == "") begin
      catcher.uvm_report_error("RPTCTHR", "Empty id string passed to uvm_report_catcher::add_report_id_catcher(). ", UVM_NONE, `uvm_file, `uvm_line);
      return;
    end  

    if (ordering == UVM_APPEND) m_catcher_q.push_back(catcher);
    else m_catcher_q.push_front(catcher);

    sev_id = new;
    sev_id.id_specified      = 1;
    sev_id.id                = id;
    sev_id.is_on             = 1;
    m_sev_id_array[catcher]  = sev_id;
  endfunction

  
  //add_report_severity_id_catcher
  //
  //
  
  static function void add_report_severity_id_catcher(uvm_severity severity, string id, uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
    sev_id_struct sev_id;
    if(catcher == null) begin
      uvm_top.uvm_report_error("RPTCTHR", "NULL uvm_report_catcher object passed to uvm_report_catcher::add_report_severity_id_catcher()", UVM_NONE, `uvm_file, `uvm_line);
      return;
    end
    
    if(m_sev_id_array.exists(catcher)) begin
      catcher.uvm_report_warning("RPTCTHR", "Catcher instance already registered. Ignoring subsequent call to uvm_report_catcher::add_report_severity_id_catcher()", UVM_NONE, `uvm_file, `uvm_line);   
      return;
    end    

    if(id == "") begin
      catcher.uvm_report_error("RPTCTHR", "Empty id string passed to uvm_report_catcher::add_report_severity_id_catcher().", UVM_NONE, `uvm_file, `uvm_line);    
      return;
    end  

    if (ordering == UVM_APPEND) m_catcher_q.push_back(catcher);
    else m_catcher_q.push_front(catcher);

    sev_id = new;
    sev_id.id_specified      = 1;
    sev_id.id                = id;
    sev_id.sev_specified     = 1;
    sev_id.sev               = severity;
    sev_id.is_on             = 1;
    m_sev_id_array[catcher]  = sev_id;
  endfunction
  
  //get_report_catcher
  //
  //
  
  static function uvm_report_catcher get_report_catcher(string name);
    foreach(m_catcher_q[i]) begin
      if(m_catcher_q[i].get_name() == name)
        return m_catcher_q[i];
    end
    return null;
  endfunction
  
  //remove_report_catcher(uvm_report_catcher catcher)
  //
  //

  static function bit remove_report_catcher(uvm_report_catcher catcher);
    foreach(m_catcher_q[i]) begin
      if(m_catcher_q[i] == catcher) begin
        m_catcher_q.delete(i);
        m_sev_id_array.delete(catcher);
        return 1;    
      end
    end
    return 0;  
  endfunction

  //remove_all_report_catchers
  //
  //

  static function void remove_all_report_catchers();
    m_catcher_q.delete();
    m_sev_id_array.delete();
  endfunction

  //print_catchers()
  //
  //

  static function void print_catcher(UVM_FILE file=0);
    string msg;
    sev_id_struct sev_id;
    uvm_report_catcher catcher;

    f_display(file, "-------------UVM REPORT CATCHERS----------------------------");

    foreach(m_catcher_q[i]) begin
      string id         = "*";
      string sev_name   = " *    ";
      string enabled    = "ON ";

      catcher = m_catcher_q[i];
      sev_id  = m_sev_id_array[catcher];

      if(sev_id.sev_specified) begin
        case(sev_id.sev)
          UVM_NONE  : sev_name = "NONE  ";
          UVM_LOW   : sev_name = "LOW   ";
          UVM_MEDIUM: sev_name = "MEDIUM";
          UVM_HIGH  : sev_name = "HIGH  ";
          UVM_FULL  : sev_name = "FULL  ";
          default   : $swrite(sev_name, "%6d", sev_id.sev);
        endcase
      end  

      if(sev_id.id_specified)
        id = sev_id.id;    

       if(!sev_id.is_on)
        enabled = "OFF";        
      
      $swrite(msg, "%20s : %s : %16s : %s", m_catcher_q[i].get_name(),
              enabled, id, sev_name);
      f_display(file, msg);
    end
    f_display(file, "--------------------------------------------------------------");
  endfunction
  
  //debug_report_catcher
  //
  //

  static function void debug_report_catcher(int what= 0);
    m_debug_flags = what;
  endfunction        
   
   //catch
   //
   //

   pure virtual function action_e catch();
     

   //uvm_report_fatal
   //
   //
   
   protected function void uvm_report_fatal(string id, string message, int verbosity, string fname = "", int line = 0 );
     string m;
     uvm_action a;
     UVM_FILE f;
     uvm_report_handler rh;
     
     rh   = this.m_client.get_report_handler();
     a    = rh.get_action(UVM_FATAL,id);
     f    = rh.get_file_handle(UVM_FATAL,id);
     
     m    = this.m_server.compose_message(UVM_FATAL,this.m_name, id, message, fname, line);
     this.m_server.process_report(UVM_FATAL, this.m_name, id, message, a, f, fname, line,
                                  m, verbosity, this.m_client);
   endfunction  


   //uvm_report_error
   //
   //
   
   protected function void uvm_report_error(string id, string message, int verbosity, string fname = "", int line = 0 );
     string m;
     uvm_action a;
     UVM_FILE f;
     uvm_report_handler rh;
     
     rh   = this.m_client.get_report_handler();
     a    = rh.get_action(UVM_ERROR,id);
     f    = rh.get_file_handle(UVM_ERROR,id);
     
     m    = this.m_server.compose_message(UVM_ERROR,this.m_name, id, message, fname, line);
     this.m_server.process_report(UVM_ERROR, this.m_name, id, message, a, f, fname, line,
                                  m, verbosity, this.m_client);
   endfunction  


   //uvm_report_warning
   //
   //
   
   protected function void uvm_report_warning(string id, string message, int verbosity, string fname = "", int line = 0 );
     string m;
     uvm_action a;
     UVM_FILE f;
     uvm_report_handler rh;
     
     rh   = this.m_client.get_report_handler();
     a    = rh.get_action(UVM_WARNING,id);
     f    = rh.get_file_handle(UVM_WARNING,id);
     
     m    = this.m_server.compose_message(UVM_WARNING,this.m_name, id, message, fname, line);
     this.m_server.process_report(UVM_WARNING, this.m_name, id, message, a, f, fname, line,
                                  m, verbosity, this.m_client);
   endfunction  


   //uvm_report_info
   //
   //
   
   protected function void uvm_report_info(string id, string message, int verbosity, string fname = "", int line = 0 );
     string m;
     uvm_action a;
     UVM_FILE f;
     uvm_report_handler rh;
     
     rh    = this.m_client.get_report_handler();
     a    = rh.get_action(UVM_INFO,id);
     f     = rh.get_file_handle(UVM_INFO,id);
     
     m     = this.m_server.compose_message(UVM_INFO,this.m_name, id, message, fname, line);
     this.m_server.process_report(UVM_INFO, this.m_name, id, message, a, f, fname, line,
                                  m, verbosity, this.m_client);
  endfunction  

  //issue
  //immediately issue the message if called from within catch
  //issuing a message will update the report_server stats, possibly multiple times

  protected function void issue();
     string m;
     uvm_action a;
     UVM_FILE f;
     uvm_report_handler rh;
     
     rh = this.m_client.get_report_handler();
     a  =  this.m_modified_action;
     f  = rh.get_file_handle(this.m_modified_severity,this.m_modified_id);
     
     m  = this.m_server.compose_message(this.m_modified_severity, this.m_name,
                                        this.m_modified_id,
                                        this.m_modified_message,
                                        this.m_file_name, this.m_line_number);
     this.m_server.process_report(this.m_modified_severity, this.m_name,
                                  this.m_modified_id, this.m_modified_message,
                                  a, f, this.m_file_name, this.m_line_number,
                                  m, this.m_modified_verbosity,this.m_client);
  endfunction


  //process_all_report_catchers
  //method called by report_server.report to process catchers
  //

  static function int process_all_report_catchers( 
    input uvm_report_server server,
    input uvm_report_object client,
    ref uvm_severity severity, 
    input string name, 
    ref string id,
    ref string message,
    ref int verbosity_level,
    ref uvm_action action,
    input string filename,
    input int line 
  );
  
    int thrown = 1;
    uvm_severity orig_severity;
    static bit in_catcher;

    if(in_catcher == 1) begin
        return 1;
    end
    in_catcher = 1;    

    m_server             = server;
    m_client             = client;
    orig_severity        = severity;
    m_name               = name;
    m_file_name          = filename;
    m_line_number        = line;
    m_modified_id        = id;
    m_modified_severity  = severity;
    m_modified_message   = message;
    m_modified_verbosity = verbosity_level;
    m_modified_action    = action;

    m_orig_severity  = severity;
    m_orig_id        = id;
    m_orig_verbosity = verbosity_level;
    m_orig_action    = action;
    m_orig_message   = message;      
    
    foreach(m_catcher_q[i]) begin
      if (!m_catcher_q[i].is_enabled()) continue;
      thrown = m_catcher_q[i].process_report_catcher(); 

      if(thrown == 0) begin 
        case(orig_severity)
          UVM_FATAL:   m_caught_fatal++;
          UVM_ERROR:   m_caught_error++;
          UVM_WARNING: m_caught_warning++;
         endcase   
         break;
      end 
    end //foreach   

    //update counters if message was returned with demoted severity
    case(orig_severity)
      UVM_FATAL:    
        if(m_modified_severity < orig_severity)
          m_demoted_fatal++;
      UVM_ERROR:
        if(m_modified_severity < orig_severity)
          m_demoted_error++;
      UVM_WARNING:
        if(m_modified_severity < orig_severity)
          m_demoted_warning++;
    endcase
   
    in_catcher = 0;

    severity        = m_modified_severity;
    id              = m_modified_id;
    message         = m_modified_message;
    verbosity_level = m_modified_verbosity;
    action          = m_modified_action;

    return thrown; 
  endfunction


  //process_report_catcher
  //internal method to call user catch() method
  //

  local function int process_report_catcher();

    action_e act;
    sev_id_struct sev_id;

    sev_id = m_sev_id_array[this];

    if(!sev_id.is_on) 
      return 1;

    if(sev_id.sev_specified && (sev_id.sev != m_modified_severity))
      return 1;

    if(sev_id.id_specified && (sev_id.id != m_modified_id))
      return 1;
       
    act = this.catch();

    if(act == UNKNOWN_ACTION)
      this.uvm_report_error("RPTCTHR", {"uvm_report_this.catch() in catcher instance ", this.get_name(), " must return THROW or CAUGHT"}, UVM_NONE, `uvm_file, `uvm_line);

    if(m_debug_flags & DO_NOT_MODIFY) begin
      m_modified_severity    = m_orig_severity;
      m_modified_id          = m_orig_id;
      m_modified_verbosity   = m_orig_verbosity;
      m_modified_action      = m_orig_action;
      m_modified_message     = m_orig_message;
    end     

    if(act == CAUGHT  && !(m_debug_flags & DO_NOT_CATCH)) begin
      return 0;
    end  

    return 1;

  endfunction

  //f_display
  //internal method to check if file is open
  //
  
  local static function void f_display(UVM_FILE file, string str);
    if (file == 0)
      $display(str);
    else
      $fdisplay(file, str);
  endfunction

  //summarize_report_catcher
  //called in uvm_report_server::summarize()
  //prints the stats for the catcher

  static function void summarize_report_catcher(UVM_FILE file);
    string s;
    if(do_report) begin
      f_display(file, "");   
      f_display(file, "--- UVM Report catcher Summary ---");
      f_display(file, "");   
      f_display(file, "");
  
      $sformat(s, "Number of demoted UVM_FATAL reports  :%5d", m_demoted_fatal);
      f_display(file,s);
  
      $sformat(s, "Number of demoted UVM_ERROR reports  :%5d", m_demoted_error);
      f_display(file,s);
  
      $sformat(s, "Number of demoted UVM_WARNING reports:%5d", m_demoted_warning);
      f_display(file,s);

      $sformat(s, "Number of caught UVM_FATAL reports   :%5d", m_caught_fatal);
      f_display(file,s);
  
      $sformat(s, "Number of caught UVM_ERROR reports   :%5d", m_caught_error);
      f_display(file,s);
  
      $sformat(s, "Number of caught UVM_WARNING reports :%5d", m_caught_warning);
      f_display(file,s);
    end
  endfunction

endclass

`endif // UVM_REPORT_SERVER_SVH
