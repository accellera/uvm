// $Id: urm_message.sv,v 1.28 2009/06/05 22:46:18 redelman Exp $
//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   Copyright 2007-2009 Cadence Design Systems, Inc.
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


`include "compatibility/urm_message.svh"


// Utility Functions


function string m_urm_mask_worker(int multi_i, string multi_s, int mask, string text);
  if ( multi_i & mask ) begin
    if ( multi_s == "" ) begin m_urm_mask_worker = text; end
    else begin m_urm_mask_worker = { multi_s, "|", text }; end
  end
  else begin m_urm_mask_worker = multi_s; end
endfunction

function string m_urm_msg_style_string(int style_i);
  string style_s;
  case (style_i)
    UVM_URM_STYLE_NONE:  begin style_s = "NO_STYLE"; end
    UVM_URM_LONG:        begin style_s = "LONG"; end
    UVM_URM_RAW:         begin style_s = "RAW"; end
    UVM_URM_SHORT:       begin style_s = "SHORT"; end
    default: begin
      style_s = "";
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_FILE,"FILE");
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_HIERARCHY,"HIERARCHY");
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_LINE,"LINE");
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_MESSAGE_TEXT,"MESSAGE_TEXT");
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_SCOPE,"SCOPE");
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_SEVERITY,"SEVERITY");
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_TAG,"TAG");
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_TIME,"TIME");
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_UNIT,"UNIT");
      style_s = m_urm_mask_worker(style_i,style_s,UVM_URM_STYLE_VERBOSITY,"VERBOSITY");
    end
  endcase
  return style_s;
endfunction

function string m_urm_destination_string(int destination_i);
  string destination_s;
  $swrite(destination_s,"%0h",destination_i);
  return destination_s;
endfunction

function string m_urm_severity_string(int severity_i);
  string severity_s;
  case (severity_i)
    UVM_INFO:    begin severity_s = uvm_urm_message_format::info_text; end
    UVM_WARNING: begin severity_s = uvm_urm_message_format::warning_text; end
    UVM_ERROR:   begin severity_s = uvm_urm_message_format::error_text; end
    UVM_FATAL:   begin severity_s = uvm_urm_message_format::fatal_text; end
    default: begin 
               $swrite(severity_s,"%s%0d",uvm_urm_message_format::info_text,severity_i);
             end
  endcase
  return severity_s;
endfunction

// I, W, E, F -- used by URM formatter
function string m_urm_severity_S(int severity_i);
  case (severity_i)
    UVM_WARNING: begin m_urm_severity_S = "W"; end
    UVM_ERROR:   begin m_urm_severity_S = "E"; end
    UVM_FATAL:   begin m_urm_severity_S = "F"; end
    default: begin m_urm_severity_S = "I"; end
  endcase
endfunction

// Info, Warning, Error, Fatal, used for DUT messages
function string m_urm_severity_Severity(int severity_i);
  string severity_s;
  case (severity_i)
    UVM_WARNING: begin severity_s = "Warning"; end
    UVM_ERROR:   begin severity_s = "Error"; end
    UVM_FATAL:   begin severity_s = "Fatal"; end
    default: begin severity_s = "Info"; end
  endcase
  return severity_s;
endfunction

// info, warning, error, fatal, used for DUT messages
function string m_urm_severity_severity(int severity_i);
  string severity_s;
  case (severity_i)
    UVM_WARNING: begin severity_s = "warning"; end
    UVM_ERROR:   begin severity_s = "error"; end
    UVM_FATAL:   begin severity_s = "fatal"; end
    default: begin severity_s = "info"; end
  endcase
  return severity_s;
endfunction

// use when accessing verbosity via get_*verbosity
function string m_urm_verbosity_string(int verbosity_i);
  string verbosity_s;
  case (verbosity_i)
    UVM_NONE:        begin verbosity_s = uvm_urm_message_format::none_text; end
    UVM_LOW:         begin verbosity_s = uvm_urm_message_format::low_text; end
    UVM_MEDIUM:      begin verbosity_s = uvm_urm_message_format::medium_text; end
    UVM_HIGH:        begin verbosity_s = uvm_urm_message_format::high_text; end
    UVM_FULL:        begin verbosity_s = uvm_urm_message_format::full_text; end
    default:      begin 
                    $swrite(verbosity_s,"%s%0d",uvm_urm_message_format::info_text,verbosity_i);
                  end
  endcase
  return verbosity_s;
endfunction

function string m_urm_action_string(int action_i);
  string action_s;
  action_s = "";
  // special handling for UVM_NO_ACTION
  if (uvm_action_type'(action_i) == UVM_NO_ACTION) action_s = "NO_ACTION";
  else begin
     action_s = m_urm_mask_worker(action_i,action_s,UVM_CALL_HOOK,"CALL_HOOK");
     action_s = m_urm_mask_worker(action_i,action_s,UVM_COUNT,"COUNT");
     action_s = m_urm_mask_worker(action_i,action_s,UVM_DISPLAY,"DISPLAY");
     action_s = m_urm_mask_worker(action_i,action_s,UVM_EXIT,"EXIT");
     action_s = m_urm_mask_worker(action_i,action_s,UVM_LOG,"LOG");
     action_s = m_urm_mask_worker(action_i,action_s,UVM_STOP,"STOP");
  end
  return action_s;
endfunction

function string m_urm_actions_string_worker(uvm_report_object h, uvm_severity severity_val);
  uvm_report_handler m_rh; m_rh = h.get_report_handler();
  return {
    "  actions[", m_urm_severity_string(severity_val), "]: ",
    m_urm_action_string(m_rh.severity_actions[severity_val])
  };
endfunction

function string m_urm_actions_string(uvm_report_object h);
  string image;
  image = {        m_urm_actions_string_worker(h,UVM_INFO), "\n" };
  image = { image, m_urm_actions_string_worker(h,UVM_WARNING), "\n" };
  image = { image, m_urm_actions_string_worker(h,UVM_ERROR), "\n" };
  image = { image, m_urm_actions_string_worker(h,UVM_FATAL) };
  return image;
endfunction


//----------------------------------------------------------------------------
//
// CLASS- uvm_urm_message
//
//----------------------------------------------------------------------------


function uvm_urm_message::new(
  string id, string text, int typ, uvm_severity sev, int verbosity, string hier,
  uvm_report_object client, string file, int line, string scope
);

  uvm_component ch;
  uvm_report_handler m_rh; 

  uvm_urm_report_server::init_urm_report_server();

  if ( client == null ) client = _global_reporter;
  m_rh = client.get_report_handler();

  if ( urm_msg_type'(typ) == UVM_URM_MSG_DUT ) begin
    sev = uvm_global_urm_report_server.m_global_severity;
  end

  if ( urm_msg_type'(typ) == UVM_URM_MSG_DEBUG && uvm_severity_type'(sev) != UVM_INFO ) begin
    typ = UVM_URM_MSG_DUT;
  end

  if ( urm_msg_type'(typ) == UVM_URM_MSG_DUT ) begin
    verbosity = UVM_NONE;
  end

  if ( file == "" && line == 0 ) file = "<unknown>";

  if ( scope == "" ) begin
    if ( client == _global_reporter ) scope = "__global__";
    else scope = client.get_full_name();
  end

  if ( hier == "" ) begin
    if ( client == _global_reporter ) hier = scope;
    else hier = client.get_full_name();
  end

  m_id = id;
  m_text = text;
  m_type = typ;
  m_severity = sev;
  m_verbosity = verbosity;
  m_max_verbosity = m_rh.m_max_verbosity_level;
  m_style = uvm_urm_report_server::get_global_debug_style();
  m_client = client;
  m_file = file;
  m_line = line;
  m_action = m_rh.get_action(sev,id);
  m_destination = m_rh.get_file_handle(sev,id);
  m_scope = scope;
  m_hierarchy = hier;
  m_name = client.get_full_name();

endfunction


//----------------------------------------------------------------------------
//
// CLASS- uvm_urm_override_request
//
//----------------------------------------------------------------------------


function uvm_urm_override_request::new(string hierarchy="", 
                                   string scope="", 
                                   string name="", 
		                   string file="", 
                                   int line=-1, 
                                   string text="", 
                                   string tag="",
		                   uvm_urm_override_operator op=null);
   match_hierarchy = hierarchy;
   match_scope = scope;
   match_name = name;
   match_file = file;
   match_line = line;
   match_text = text;
   match_tag = tag;
   operator = op;
endfunction


function bit uvm_urm_override_request::is_applicable_to_message(uvm_urm_message msg);
   // breaking into multiple if-statements instead of one large ||
   // to stop matching as soon as the first one fails... 
   if ( !uvm_is_match(match_hierarchy, msg.m_hierarchy) )
      return(0);
   else if ( !uvm_is_match(match_scope, msg.m_scope) )
      return(0);
   else if ( !uvm_is_match(match_name, msg.m_name) )
      return(0);
   else if ( !uvm_is_match(match_text, msg.m_text) )
      return(0);
   else if ( !uvm_is_match(match_tag, msg.m_id) )
      return(0);
   else if ( !uvm_is_match(match_file, msg.m_file) )
      return(0);
   else if ( (match_line != -1) && (match_line != msg.m_line) ) 
      return(0);
   else
      return(1);
endfunction


function void uvm_urm_override_request::apply_override(uvm_urm_message msg);
   if (operator != null)  operator.apply_overrides(msg);
endfunction


function string uvm_urm_override_request::dump_request_details();
   string result;

   if (operator == null) return("Invalid request - null operator");
   result = "uvm_message ";
   if (match_hierarchy != "*")
      result = { result, "-hierarchy \"", match_hierarchy, "\" "};

   if (match_scope != "*")
      result = { result, "-scope \"", match_scope, "\" " };

   if (match_name != "*")
      result = { result, "-name \"", match_name, "\" " };

   if (match_file != "*")
      result = { result, "-file \"", match_file, "\" " };

   if (match_line != -1)
      result = { result, "-line ", $psprintf("%0d ", match_line) };

   if (match_text != "*")
      result = { result, "-text \"", match_text, "\" "};

   if (match_tag != "*")
      result = { result, "-tag \"", match_tag, "\" "};

   result = { result, operator.dump_override_details()};
   return(result);
endfunction


//----------------------------------------------------------------------------
//
// CLASS- uvm_urm_override_operator
//
//----------------------------------------------------------------------------


function void uvm_urm_override_operator::apply_overrides(uvm_urm_message msg);
   if (m_enable_style)       msg.m_style = m_style;
   if (m_enable_verbosity)   msg.m_max_verbosity = m_verbosity;
   if (m_enable_destination) msg.m_destination = m_destination;

   if (m_enable_severity) begin
      uvm_report_handler m_rh; 
      uvm_severity adjusted_severity;
      m_rh = msg.m_client.get_report_handler();
      msg.m_severity = m_severity;
      if ((uvm_severity_type'(m_severity) >= UVM_INFO) && (uvm_severity_type'(m_severity) <= UVM_FATAL))
        adjusted_severity = m_severity;
      else 
        adjusted_severity = UVM_INFO;
      msg.m_action = m_rh.get_action(adjusted_severity,msg.m_id);
   end

   if (m_enable_action  &&  (msg.m_severity == m_severity_for_action))
      msg.m_action = m_action;
endfunction


function string uvm_urm_override_operator::dump_override_details();
   string result;
   result = "";

   if (m_enable_style) 
      result = { result, "-set_style ", m_urm_msg_style_string(m_style), " "};

   if (m_enable_verbosity)
      result = { result, "-set_verbosity ", m_urm_verbosity_string(m_verbosity), " "};

   if (m_enable_destination)
      result = { result, "-set_destination ", $psprintf("%0d", m_destination), " "};
   
   if (m_enable_severity)
      result = { result, "-set_severity ", m_urm_severity_string(m_severity), " "};

   if (m_enable_action)
      result = { result, "-severity ",  m_urm_severity_string(m_severity_for_action),
	                 " -set_actions ", m_urm_action_string(m_action) };

   return(result);

endfunction


//----------------------------------------------------------------------------
//
// CLASS- uvm_urm_report_server
//
//----------------------------------------------------------------------------


function uvm_urm_report_server::new();
  super.new();
  if ( m_initialized != 1 ) begin
    m_initialized = 1;
    m_global_debug_style = UVM_URM_SHORT;
    m_global_hier = "";
    m_global_scope = "";
    m_global_severity = UVM_ERROR;
    m_global_default_type = UVM_URM_MSG_DEBUG;
    m_global_type = UVM_URM_MSG_DEBUG;
  end
endfunction

function void uvm_urm_report_server::report(
  uvm_severity severity,
  string name,
  string id,
  string message,
  int verbosity_level,
  string filename,
  int line,
  uvm_report_object client
);
  static bit m_action_change_warn_once=1;
  uvm_urm_message msg;

  msg = new(
    id, message, m_global_type, severity, verbosity_level, m_global_hier,
    client, filename, line, m_global_scope
  );
  m_apply_override_requests(msg);

  if (uvm_action_type'(msg.m_action) == UVM_NO_ACTION) return;
  // consolidate destination information
  if ( ! ( msg.m_action & UVM_LOG ) ) msg.m_destination = 0;
  if ( msg.m_action & UVM_DISPLAY ) msg.m_destination |= 1;

  // enforce limitations on `message actions
  if ( urm_msg_type'(msg.m_type) == UVM_URM_MSG_DEBUG ) begin
    if ((msg.m_action & ~(UVM_DISPLAY|UVM_LOG))&&(m_action_change_warn_once)) begin
      $display("UVM messaging ignores UVM_CALL_HOOK, UVM_COUNT, UVM_EXIT and UVM_STOP actions on messages created via `message. ");
      m_action_change_warn_once = 0;
    end
    msg.m_action &= (UVM_DISPLAY|UVM_LOG);
  end

  // if ( ! msg.handler.filter(msg) ) return;
  if ( msg.m_verbosity > msg.m_max_verbosity ) return;

  // update counts
  uvm_global_urm_report_server.incr_severity_count(msg.m_severity);
  uvm_global_urm_report_server.incr_id_count(msg.m_id);

  if ( msg.m_destination != 0 ) begin

    case (msg.m_type)

      UVM_URM_MSG_DEBUG : begin
        bit first;
        first = 1;
        if ( msg.m_style & UVM_URM_STYLE_TIME ) begin
          first = 0;
          $fwrite(msg.m_destination,"[%0t]",$time);
        end
        if ( msg.m_style & UVM_URM_STYLE_VERBOSITY ) begin
          if ( first ) first = 0; else $write(" ");
          $fwrite(msg.m_destination,"(%0s)",m_urm_verbosity_string(msg.m_verbosity));
        end
        if ( msg.m_style & UVM_URM_STYLE_SEVERITY ) begin
          if ( first ) first = 0; else $write(" ");
          $fwrite(msg.m_destination,"severity=%0s",m_urm_severity_string(msg.m_severity));
        end
        if ( msg.m_style & UVM_URM_STYLE_TAG ) begin
          if ( first ) first = 0; else $write(" ");
          $fwrite(msg.m_destination,"tag=%0s",msg.m_id);
        end
        if ( msg.m_style & UVM_URM_STYLE_SCOPE ) begin
          if ( first ) first = 0; else $write(" ");
          $fwrite(msg.m_destination,"scope=%0s",msg.m_scope);
        end
        if ( msg.m_style & UVM_URM_STYLE_HIERARCHY ) begin
          if ( first ) first = 0; else $write(" ");
          $fwrite(msg.m_destination,"hier=%0s",msg.m_hierarchy);
        end
        if ( msg.m_style & UVM_URM_STYLE_MESSAGE_TEXT ) begin
          if ( ! first ) $fwrite(msg.m_destination,": ");
          $fdisplay(msg.m_destination,"%s",msg.m_text);
        end
        else begin
          if ( ! first ) $fdisplay(msg.m_destination);
        end
        first = 1;
        if ( ( msg.m_style & UVM_URM_STYLE_FILE ) && ( msg.m_style & UVM_URM_STYLE_LINE ) ) begin
          first = 0;
          $fwrite(msg.m_destination,"%0s, %0d",msg.m_file,msg.m_line);
        end
        else if ( msg.m_style & UVM_URM_STYLE_FILE ) begin
          first = 0;
          $fwrite(msg.m_destination,"%0s",msg.m_file);
        end
        else if ( msg.m_style & UVM_URM_STYLE_LINE ) begin
          first = 0;
          $fwrite(msg.m_destination,"%0d",msg.m_line);
        end
        if ( ( msg.m_style & UVM_URM_STYLE_UNIT ) ) begin
          uvm_component ch;
          if ( $cast(ch,msg.m_client) ) begin
            if ( first ) first = 0; else $fwrite(msg.m_destination," ");
            $fwrite(msg.m_destination,"%0s",ch.get_full_name());
          end
        end
        if ( ! first ) $fdisplay(msg.m_destination);
      end

      UVM_URM_MSG_DUT : begin
        $fdisplay(
          msg.m_destination,
          "*** UVM: DUT %s at time %0t\nChecked at line %0d in %s\nIn %s",
          m_urm_severity_severity(msg.m_severity),
          $time, msg.m_line, msg.m_file,
          msg.m_hierarchy
        );
        $fdisplay(msg.m_destination,"%s",msg.m_text);
        if ( msg.m_action & (UVM_EXIT|UVM_STOP) ) begin
          uvm_report_handler m_rh; 
          m_rh = msg.m_client.get_report_handler();
          $fdisplay(
            msg.m_destination,
            "Will stop execution immediately (check effect is %0s)",
            m_rh.format_action(msg.m_action)
          );
        end
        $fdisplay(
            msg.m_destination,
          "*** %0s: A DUT %0s has occurred\n",
          m_urm_severity_Severity(msg.m_severity),
          m_urm_severity_severity(msg.m_severity)
        );
      end

      UVM_URM_MSG_TOOL : begin
        $fwrite(
          msg.m_destination,
          "uvm: *%s,%s (%s,%0d): ",
          m_urm_severity_S(msg.m_severity), msg.m_id,
          msg.m_file, msg.m_line
        );
        $fdisplay(msg.m_destination,"%s",msg.m_text);
      end

      UVM_URM_MSG_UVM : begin
        string image;
        image = uvm_global_urm_report_server.compose_message(
          msg.m_severity, msg.m_name, msg.m_id,
          msg.m_text, msg.m_file, msg.m_line
        );
        $fdisplay(msg.m_destination,"%s",image);
      end

    endcase

  end

  if ( msg.m_action & UVM_COUNT ) begin
    if ( uvm_global_urm_report_server.get_max_quit_count() != 0 ) begin
      uvm_global_urm_report_server.incr_quit_count();
      if ( uvm_global_urm_report_server.is_quit_count_reached() ) begin
        $display("** ERROR LIMIT REACHED **");
        msg.m_action |= UVM_EXIT;
      end
    end
  end

  if ( msg.m_action & UVM_EXIT )
    if( (msg.m_action & UVM_COUNT) && uvm_global_urm_report_server.is_quit_count_reached() )
      msg.m_client.die();

  if ( msg.m_action & UVM_STOP ) $stop;

endfunction

function int uvm_urm_report_server::get_global_max_quit_count();
  uvm_urm_report_server::init_urm_report_server();
  return uvm_global_urm_report_server.get_max_quit_count();
endfunction

function void uvm_urm_report_server::set_global_max_quit_count(int value);
  uvm_urm_report_server::init_urm_report_server();
  uvm_global_urm_report_server.set_max_quit_count(value);
endfunction

function int uvm_urm_report_server::get_global_debug_style();
  uvm_urm_report_server::init_urm_report_server();
  return uvm_global_urm_report_server.m_global_debug_style;
endfunction

function void uvm_urm_report_server::set_global_debug_style(int value);
  uvm_urm_report_server::init_urm_report_server();
  uvm_global_urm_report_server.m_global_debug_style = value;
endfunction

function void uvm_urm_report_server::set_message_debug_style(
    string hierarchy,    // wildcard for message hierarchy, default "*"
    string scope,        // wildcard for message scope, default "*"
    string name,         // wildcard for message name, default "*"
    string file,         // wildcard for file name, default "*"
    int line,            // wildcard for line number, default -1 (matches all)
    string text,         // wildcard for message text, default "*"
    string tag,          // wildcard for message tag, default "*"
    bit remove,          // FALSE --> add rule, TRUE --> remove it
    int value
  );
   uvm_urm_override_operator op;
   uvm_urm_override_request  new_req;
   op = new;
   if (! op.set_style(value)) return;
   new_req = new(hierarchy, scope, name, file, line, text, tag, op);
   m_handle_new_request(new_req, remove);
endfunction

function int uvm_urm_report_server::get_global_verbosity();
  uvm_report_handler m_rh; 
  uvm_urm_report_server::init_urm_report_server();
  m_rh = _global_reporter.get_report_handler();
  return m_rh.m_max_verbosity_level;
endfunction

function void uvm_urm_report_server::set_global_verbosity(int value);
  uvm_report_handler m_rh; 
  uvm_urm_report_server::init_urm_report_server();
  m_rh = _global_reporter.get_report_handler();
  m_rh.m_max_verbosity_level = value;
endfunction

function void uvm_urm_report_server::set_message_verbosity(
    string hierarchy,    // wildcard for message hierarchy, default "*"
    string scope,        // wildcard for message scope, default "*"
    string name,         // wildcard for message name, default "*"
    string file,         // wildcard for file name, default "*"
    int line,            // wildcard for line number, default -1 (matches all)
    string text,         // wildcard for message text, default "*"
    string tag,          // wildcard for message tag, default "*"
    bit remove,          // FALSE --> add rule, TRUE --> remove it
    int value
  );
   uvm_urm_override_operator op;
   uvm_urm_override_request  new_req;
   op = new;
   if (! op.set_verbosity(value)) return;
   // verbosity is applied by default to messages with a "DEBUG" tag
   if (tag == "*") tag = "DEBUG";
   new_req = new(hierarchy, scope, name, file, line, text, tag, op);
   m_handle_new_request(new_req, remove);
endfunction

function int uvm_urm_report_server::get_global_destination();
  uvm_report_handler m_rh; 
  uvm_urm_report_server::init_urm_report_server();
  m_rh = _global_reporter.get_report_handler();
  return m_rh.default_file_handle;
endfunction

function void uvm_urm_report_server::set_global_destination(int value);
  uvm_report_handler m_rh; 
  uvm_urm_report_server::init_urm_report_server();
  m_rh = _global_reporter.get_report_handler();
  `ifdef UVM_AVOID_SFORMATF
    `urm_static_warning(("Changing destination on messages is not supported in this version of URM"))
  `else
    m_rh.default_file_handle = value;
  `endif
endfunction

function void uvm_urm_report_server::set_message_destination(
    string hierarchy,    // wildcard for message hierarchy, default "*"
    string scope,        // wildcard for message scope, default "*"
    string name,         // wildcard for message name, default "*"
    string file,         // wildcard for file name, default "*"
    int line,            // wildcard for line number, default -1 (matches all)
    string text,         // wildcard for message text, default "*"
    string tag,          // wildcard for message tag, default "*"
    bit remove,          // FALSE --> add rule, TRUE --> remove it
    int value
  );
   uvm_urm_override_operator op;
   uvm_urm_override_request  new_req;
   `ifdef UVM_AVOID_SFORMATF
      if ( remove )
         `urm_warning(("Cannot find a matching rule to remove. Ignoring."))
      else
         `urm_warning(("Changing destination on messages is not supported in this version of URM"))
   `else
      op = new;
      if (! op.set_destination(value)) return;
      new_req = new(hierarchy, scope, name, file, line, text, tag, op);
      m_handle_new_request(new_req, remove);
   `endif
endfunction

function uvm_severity uvm_urm_report_server::get_global_severity();
  uvm_urm_report_server::init_urm_report_server();
  return uvm_global_urm_report_server.m_global_severity;
endfunction

function void uvm_urm_report_server::set_global_severity(uvm_severity value);
  uvm_urm_report_server::init_urm_report_server();
  uvm_global_urm_report_server.m_global_severity = value;
endfunction

function void uvm_urm_report_server::set_message_severity(
    string hierarchy,    // wildcard for message hierarchy, default "*"
    string scope,        // wildcard for message scope, default "*"
    string name,         // wildcard for message name, default "*"
    string file,         // wildcard for file name, default "*"
    int line,            // wildcard for line number, default -1 (matches all)
    string text,         // wildcard for message text, default "*"
    string tag,          // wildcard for message tag, default "*"
    bit remove,          // FALSE --> add rule, TRUE --> remove it
    uvm_severity value
  );
   uvm_urm_override_operator op;
   uvm_urm_override_request  new_req;
   op = new;
   if (! op.set_severity(value)) return;
   // severity is applied by default to messages with a "DUT" tag
   if (tag == "*") tag = "DUT";
   new_req = new(hierarchy, scope, name, file, line, text, tag, op);
   m_handle_new_request(new_req, remove);
endfunction

function int uvm_urm_report_server::get_global_actions(uvm_severity sev);
  uvm_report_handler m_rh; 
  uvm_urm_report_server::init_urm_report_server();
  m_rh = _global_reporter.get_report_handler();
  return m_rh.severity_actions[sev];
endfunction

function void uvm_urm_report_server::set_global_actions(uvm_severity sev, int value);
  uvm_report_handler m_rh; 
  uvm_urm_report_server::init_urm_report_server();
  m_rh = _global_reporter.get_report_handler();
  m_rh.severity_actions[sev] = value;
endfunction

function void uvm_urm_report_server::set_message_actions(
    string hierarchy,    // wildcard for message hierarchy, default "*"
    string scope,        // wildcard for message scope, default "*"
    string name,         // wildcard for message name, default "*"
    string file,         // wildcard for file name, default "*"
    int line,            // wildcard for line number, default -1 (matches all)
    string text,         // wildcard for message text, default "*"
    string tag,          // wildcard for message tag, default "*"
    bit remove,          // FALSE --> add rule, TRUE --> remove it
    uvm_severity severity_val,
    int value
  );
   uvm_urm_override_operator op;
   uvm_urm_override_request  new_req;
   op = new;
   if (! op.set_action(severity_val, value)) return;
   new_req = new(hierarchy, scope, name, file, line, text, tag, op);
   m_handle_new_request(new_req, remove);
endfunction

function void uvm_urm_report_server::init_urm_report_server();
  if ( uvm_global_urm_report_server == null ) begin
    uvm_report_handler m_rh; 
    uvm_report_global_server glob;
    uvm_global_urm_report_server = new;
    glob = new;
    glob.set_server(uvm_global_urm_report_server);
    m_rh = _global_reporter.get_report_handler();
    m_rh.set_severity_action(UVM_INFO,UVM_DISPLAY);
    m_rh.set_severity_action(UVM_WARNING,UVM_DISPLAY);
    m_rh.set_severity_action(UVM_ERROR,UVM_COUNT|UVM_DISPLAY|UVM_EXIT);
    m_rh.set_severity_action(UVM_FATAL,UVM_COUNT|UVM_DISPLAY|UVM_EXIT);
  end
endfunction

function void uvm_urm_report_server::set_default_report_type(int value);
  uvm_urm_report_server::init_urm_report_server();
  uvm_global_urm_report_server.m_global_default_type = value;
  uvm_global_urm_report_server.m_global_type = value;
endfunction

function bit uvm_urm_report_server::m_message_header(uvm_urm_message message);
static bit m_action_change_warn_once =1;

  m_apply_override_requests(message);
  // consolidate destination information
  if ( ! ( message.m_action & UVM_LOG ) ) message.m_destination = 0;
  if ( message.m_action & UVM_DISPLAY ) message.m_destination |= 1;

  // enforce limitations on `message actions
  if ( urm_msg_type'(message.m_type) == UVM_URM_MSG_DEBUG ) begin
    if ((message.m_action & ~(UVM_DISPLAY|UVM_LOG))&&(m_action_change_warn_once)) begin
      $display("UVM messaging ignores UVM_CALL_HOOK, UVM_COUNT, UVM_EXIT and UVM_STOP actions on messages created via `message. ");
      m_action_change_warn_once = 0;
    end
    message.m_action &= (UVM_DISPLAY|UVM_LOG);
  end

  // return message.handler.filter(message);
  return message.m_verbosity <= message.m_max_verbosity;
endfunction

function bit uvm_urm_report_server::m_message_subheader(uvm_urm_message message);

  // update counts
  uvm_global_urm_report_server.incr_severity_count(message.m_severity);
  uvm_global_urm_report_server.incr_id_count(message.m_id);

  if ( message.m_destination == 0 ) return 0;

  case (message.m_type)

    UVM_URM_MSG_DEBUG : begin
      bit first;
      first = 1;
      if ( message.m_style & UVM_URM_STYLE_TIME ) begin
        first = 0;
        $write("[%0t]",$time);
      end
      if ( message.m_style & UVM_URM_STYLE_VERBOSITY ) begin
        if ( first ) first = 0; else $write(" ");
        $write("(%0s)",m_urm_verbosity_string(message.m_verbosity));
      end
      if ( message.m_style & UVM_URM_STYLE_SEVERITY ) begin
        if ( first ) first = 0; else $write(" ");
        $write("severity=%0s",m_urm_severity_string(message.m_severity));
      end
      if ( message.m_style & UVM_URM_STYLE_TAG ) begin
        if ( first ) first = 0; else $write(" ");
        $write("tag=%0s",message.m_id);
      end
      if ( message.m_style & UVM_URM_STYLE_SCOPE ) begin
        if ( first ) first = 0; else $write(" ");
        $write("scope=%0s",message.m_scope);
      end
      if ( message.m_style & UVM_URM_STYLE_HIERARCHY ) begin
        if ( first ) first = 0; else $write(" ");
        $write("hier=%0s",message.m_hierarchy);
      end
      if ( message.m_style & UVM_URM_STYLE_MESSAGE_TEXT ) begin
        if ( ! first ) $write(": ");
        return 1;
      end
      else begin
        if ( ! first ) $display;
        return 0;
      end
    end

    UVM_URM_MSG_DUT : begin
      $display(
        "\n*** UVM: DUT %s at time %0t\n   Checked at line %0d in %s\n   In %s\n",
        m_urm_severity_severity(message.m_severity),
        $time, message.m_line, message.m_file,
        message.m_hierarchy
      );
    end

    UVM_URM_MSG_TOOL : begin
      $write(
        "uvm: *%s,%s (%s,%0d): ",
        m_urm_severity_S(message.m_severity), message.m_id,
        message.m_file, message.m_line
      );
    end

    UVM_URM_MSG_UVM : begin
      string image;
      image = uvm_global_urm_report_server.compose_message(
        message.m_severity, message.m_name, message.m_id,
        "", message.m_file, message.m_line
      );
      $write("%s",image);
    end

  endcase

  return 1;

endfunction

function void uvm_urm_report_server::m_message_footer(uvm_urm_message message);

  if ( message.m_destination != 0 ) begin

    case (message.m_type)

      UVM_URM_MSG_DEBUG : begin
        bit first;
        first = 1;
        if ( ( message.m_style & UVM_URM_STYLE_FILE ) && ( message.m_style & UVM_URM_STYLE_LINE ) ) begin
          first = 0;
          $write("%0s, %0d",message.m_file,message.m_line);
        end
        else if ( message.m_style & UVM_URM_STYLE_FILE ) begin
          first = 0;
          $write("%0s",message.m_file);
        end
        else if ( message.m_style & UVM_URM_STYLE_LINE ) begin
          first = 0;
          $write("%0d",message.m_line);
        end
        if ( ( message.m_style & UVM_URM_STYLE_UNIT ) ) begin
          uvm_component ch;
          if ( $cast(ch,message.m_client) ) begin
            if ( first ) first = 0; else $write(" ");
            $write("%0s",ch.get_full_name());
          end
        end
        if ( ! first ) $display;
      end

      UVM_URM_MSG_DUT : begin
        if ( message.m_action & (UVM_EXIT|UVM_STOP) ) begin
          uvm_report_handler m_rh; 
          m_rh =  message.m_client.get_report_handler();
          $display(
            "Will stop execution immediately (check effect is %0s)",
            m_rh.format_action(message.m_action)
          );
        end
        $display(
          "*** %0s: A DUT %0s has occurred\n",
          m_urm_severity_Severity(message.m_severity),
          m_urm_severity_severity(message.m_severity)
        );
      end

    endcase

  end

  if ( message.m_action & UVM_COUNT ) begin
    if ( uvm_global_urm_report_server.get_max_quit_count() != 0 ) begin
      uvm_global_urm_report_server.incr_quit_count();
      if ( uvm_global_urm_report_server.is_quit_count_reached() ) begin
        $display("** ERROR LIMIT REACHED **");
        message.m_action |= UVM_EXIT;
      end
    end
  end

  if ( message.m_action & UVM_EXIT )
    if( (message.m_action & UVM_COUNT) && uvm_global_urm_report_server.is_quit_count_reached() )
      message.m_client.die();

  if ( message.m_action & UVM_STOP ) $stop;

endfunction

function void uvm_urm_report_server::m_set_report_hier(string hier);
  uvm_urm_report_server::init_urm_report_server();
  uvm_global_urm_report_server.m_global_hier = hier;
endfunction

function void uvm_urm_report_server::m_set_report_scope(string scope);
  uvm_urm_report_server::init_urm_report_server();
  uvm_global_urm_report_server.m_global_scope = scope;
endfunction

function void uvm_urm_report_server::m_set_report_type(int typ);
  uvm_urm_report_server::init_urm_report_server();
  uvm_global_urm_report_server.m_global_type = typ;
endfunction

function void uvm_urm_report_server::m_reset_report_flags();
  uvm_urm_report_server::init_urm_report_server();
  uvm_global_urm_report_server.m_global_hier = "";
  uvm_global_urm_report_server.m_global_scope = "";
  uvm_global_urm_report_server.m_global_type = uvm_global_urm_report_server.m_global_default_type;
endfunction

function string uvm_urm_report_server::m_dump_global_debug_style();
  int style_e;
  style_e = get_global_debug_style();
  return m_urm_msg_style_string(style_e);
endfunction

function string uvm_urm_report_server::m_dump_rules_debug_style();
   string result;
   result = "";
   for (int i=0 ; i<m_override_requests.size(); i++)
      if (m_override_requests[i].is_style_override())
         result = { result, m_override_requests[i].dump_request_details(), "\n"};
   return (result);
endfunction

function string uvm_urm_report_server::m_dump_global_verbosity();
  int verbosity_i;
  verbosity_i = get_global_verbosity();
  return m_urm_verbosity_string(verbosity_i);
endfunction

function string uvm_urm_report_server::m_dump_rules_verbosity();
   string result;
   result = "";
   for (int i=0 ; i<m_override_requests.size(); i++)
      if (m_override_requests[i].is_verbosity_override())
         result = { result, m_override_requests[i].dump_request_details(), "\n"};
   return (result);
endfunction

function string uvm_urm_report_server::m_dump_global_destination();
  int destination_i;
  destination_i = get_global_destination();
  return m_urm_destination_string(destination_i);
endfunction

function string uvm_urm_report_server::m_dump_rules_destination();
   string result;
   result = "";
   for (int i=0 ; i<m_override_requests.size(); i++)
      if (m_override_requests[i].is_destination_override())
         result = { result, m_override_requests[i].dump_request_details(), "\n"};
   return (result);
endfunction

function string uvm_urm_report_server::m_dump_global_severity();
  int severity_i;
  severity_i = get_global_severity();
  return m_urm_severity_string(severity_i);
endfunction

function string uvm_urm_report_server::m_dump_rules_severity();
   string result;
   result = "";
   for (int i=0 ; i<m_override_requests.size(); i++)
      if (m_override_requests[i].is_severity_override())
         result = { result, m_override_requests[i].dump_request_details(), "\n"};
   return (result);
endfunction

function string uvm_urm_report_server::m_dump_global_actions();
  uvm_urm_report_server::init_urm_report_server();
  return m_urm_actions_string(_global_reporter);
endfunction

function string uvm_urm_report_server::m_dump_rules_actions();
   string result;
   result = "";
   for (int i=0 ; i<m_override_requests.size(); i++)
      if (m_override_requests[i].is_action_override())
         result = { result, m_override_requests[i].dump_request_details(), "\n"};
   return (result);
endfunction

function void uvm_urm_report_server::m_handle_new_request(
  uvm_urm_override_request new_req, bit remove
);
   int existing_req_loc;
   `ifdef UVM_AVOID_SFORMATF
      if ( new_req.match_text != "*" && ! remove ) begin
         `urm_warning(("%s%s",
            "Filtering message overrides by message text is not supported ",
            "in this version of UVM; this override will be ignored"
         ))
         return;
      end
   `endif
   existing_req_loc = m_find_last_matching_request_loc(new_req);
   if (remove) begin
      if (existing_req_loc != -1)
         m_override_requests.delete(existing_req_loc);
      else
	 `urm_warning(("Cannot find a matching rule to remove. Ignoring."))
   end
   else begin // !remove
      if (  (m_override_requests.size() == 0)
            || 
            (existing_req_loc != m_override_requests.size()-1))
	  m_override_requests.push_back(new_req);
      else
	  `urm_warning(("Repeating the same command as the last one. Ignoring."))
   end
endfunction
	
function int uvm_urm_report_server::m_find_last_matching_request_loc(
  uvm_urm_override_request req
);
   for (int i=m_override_requests.size()-1;  i >= 0 ; i--)
      if (m_override_requests[i].compare(req)) return(i);
   return(-1);
endfunction

function void uvm_urm_report_server::m_apply_override_requests(uvm_urm_message msg);
   for (int i=0; i < m_override_requests.size(); i++)
      if (m_override_requests[i].is_applicable_to_message(msg))
	  m_override_requests[i].apply_override(msg);
endfunction


