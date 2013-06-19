//
//------------------------------------------------------------------------------
//   FIXME Copyright
//   Copyright 2007-2010 Mentor Graphics Corporation
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

`ifndef UVM_REPORT_MESSAGE_SVH
`define UVM_REPORT_MESSAGE_SVH


typedef class uvm_report_server;
typedef class uvm_report_handler;
typedef class uvm_root;
 

//------------------------------------------------------------------------------
//
// CLASS- uvm_report_message_element
//
// Implementation detail -- not documented.
//
//------------------------------------------------------------------------------

class uvm_report_message_element;

  typedef enum {INT, STRING, OBJECT, MESS_TAG} element_type_e;

  element_type_e m_element_type;
  string m_element_name;
  int m_int_value;
  uvm_radix_enum m_int_radix;
  string m_string_value;
  uvm_object m_object;

endclass


//------------------------------------------------------------------------------
//
// CLASS- uvm_report_message_element
//
// Implementation detail -- not documented.
//
//------------------------------------------------------------------------------

class uvm_report_message_element_container extends uvm_object;

  uvm_report_message_element elements[$];

  `uvm_object_utils(uvm_report_message_element_container)

  function new(string name = "element_container");
    super.new(name);
  endfunction

  function void add_tag(string name, string value);
    uvm_report_message_element urme = new();
    urme.m_element_type = uvm_report_message_element::MESS_TAG;
    urme.m_element_name = name;
    urme.m_string_value = value;
    elements.push_back(urme);
  endfunction

  function void add_int(string name, int value, uvm_radix_enum radix);
    uvm_report_message_element urme = new();
    urme.m_element_type = uvm_report_message_element::INT;
    urme.m_element_name = name;
    urme.m_int_value = value;
    urme.m_int_radix = radix;
    elements.push_back(urme);
  endfunction

  function void add_string(string name, string value);
    uvm_report_message_element urme = new();
    urme.m_element_type = uvm_report_message_element::STRING;
    urme.m_element_name = name;
    urme.m_string_value = value;
    elements.push_back(urme);
  endfunction

  function void add_object(string name, uvm_object obj);
    uvm_report_message_element urme = new();
    urme.m_element_type = uvm_report_message_element::OBJECT;
    urme.m_element_name = name;
    urme.m_object = obj;
    elements.push_back(urme);
  endfunction

  function void do_print(uvm_printer printer);
    super.do_print(printer);
    for(int i = 0; i < elements.size(); i++) begin
      if (elements[i].m_element_type == uvm_report_message_element::MESS_TAG) begin
        printer.print_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_report_message_element::INT) begin
        printer.print_int(elements[i].m_element_name, elements[i].m_int_value, 
          $bits(elements[i].m_int_value), elements[i].m_int_radix);
      end
      if (elements[i].m_element_type == uvm_report_message_element::STRING) begin
        printer.print_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_report_message_element::OBJECT) begin
        printer.print_object(elements[i].m_element_name, elements[i].m_object);
      end
    end 
  endfunction

  function void do_record(uvm_recorder recorder);
    super.do_record(recorder);
    for(int i = 0; i < elements.size(); i++) begin
      if (elements[i].m_element_type == uvm_report_message_element::MESS_TAG) begin
        recorder.record_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_report_message_element::INT) begin
        recorder.record_field(elements[i].m_element_name, elements[i].m_int_value, 
          $bits(elements[i].m_int_value), elements[i].m_int_radix);
      end
      if (elements[i].m_element_type == uvm_report_message_element::STRING) begin
        recorder.record_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_report_message_element::OBJECT) begin
        recorder.record_object(elements[i].m_element_name, elements[i].m_object);
      end
    end
  endfunction

endclass


//------------------------------------------------------------------------------
//
// Title: UVM Report Message Classes
// 
// The report message classes provide the ability to produce basic messages,
// messages that emulate transation recording in terms of having a begin/end
// time and containing additional propeties, and finally messages that create
// links between two messaging events.
//
// Basic users need not be concerned with these classes when using the 
// messaging macros.
// 
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// CLASS: uvm_report_message
//
// The uvm_report_message is the basic UVM object message class.  It provides 
// the fields that are common to all messages.  It also provides the APIs 
// necessary to add tags, integral types, strings and uvm_objects to a message.
//
//------------------------------------------------------------------------------

class uvm_report_message extends uvm_object;

  // FIXME fix the m_ on methods usage!!!


  // Function: new
  // 
  // Creates a new uvm_report_message object.
  //

  function new(string name = "uvm_report_message");
    super.new(name);
    tr_handle = -1;
    report_message_element_container = new();
    l_printer = new();
    //l_printer.knobs.header = 0;
    //l_printer.knobs.footer = 0;
    l_printer.knobs.prefix = " +";
  endfunction


  // Function: print
  //
  // The uvm_report_messge implements the uvm_object::do_print() such that
  // uvm_report_message::print() method provides UVM printer formatted output
  // of the message.  A snippet of example output is shown here:
  //
  // |Need to add the output from a log.

  function void do_print(uvm_printer printer);
    super.do_print(printer);
    // Fix to include all the properties!!!
    if (report_message_element_container.elements.size() != 0)
      report_message_element_container.print(printer);
  endfunction


  //----------------------------------------------------------------------------
  // Group:  Infrastructure References
  //----------------------------------------------------------------------------


  // Variable: report_object
  //
  // This variable is the uvm_report_object that originated the message.

  uvm_report_object report_object;
 

  // Variable: report_object
  //
  // This variable is the uvm_report_handler that is responsible for checking
  // whether the message is enabled, should be upgraded/downgraded, etc.

  uvm_report_handler report_handler;

  // Variable: report_server
  //
  // This variable is the uvm_report_server that is responsible for servicing
  // the message's actions.  

  uvm_report_server report_server;


  //----------------------------------------------------------------------------
  // Group:  Message Fields
  //----------------------------------------------------------------------------


  // Variable: severity
  //
  // This variable is the severity (UVM_INFO, UVM_WARNING, UVM_ERROR or 
  // UVM_FATAL) of the message.  The value of this field is determined via
  // the API used (`uvm_info(), `uvm_waring(), etc.) and populated for the user.

  uvm_severity_type severity; 


  // Variable: id
  //
  // This variable is the id of the message.  The value of this field is 
  // completely under user discretion.  Users are recommended to follow a
  // consistent convention.  Settings in the uvm_report_handler allow various
  // messaging controls based on this field.  See <uvm_report_handler>.

  string id;


  // Variable: message 
  //
  // This variable is the user message content string.

  string message;


  // Variable: verbosity
  //
  // This variable is the message threshhold value.  This value is compared
  // against settings in the <uvm_report_handler> to determine whether this
  // message should be executed.

  int verbosity;


  // Variable: filename
  //
  // This variable is the file from which the message originates.  This value
  // is automatically populated by the messaging macros.

  string filename;


  // Variable: line
  //
  // This variable is the line in the <file> from which the message originates.
  // This value is automatically populate by the messaging macros.

  int line;


  // Variable: context_name
  //
  // This optional variable is the user-supplied string that is meant to convey
  // the context of the message.  It can be useful in scopes that are not
  // inherently UVM like modules, interfaces, etc.

  string context_name;

 
  // Variable:  action
  //
  // This variable is the action(s) that the uvm_report_server should perform
  // for this message.  This field is populated by the uvm_report_handler during
  // message execution flow.

  uvm_action action; 


  // Variable: file
  //
  // This variable is the file that the message is to be written to when the 
  // message's action is UVM_LOG.  This field is populated by the 
  // uvm_report_handler during message execution flow.

  UVM_FILE file;


  // Variable: tr_handle
  //
  // This variable is the tr_handle (or transaction id) for the message that is
  // assigned by the uvm_recorder when the message's action contains 
  // UVM_RM_RECORD.

  int tr_handle;


  // Not documented.
  static local uvm_report_message report_messages[$];

  // Not documented.
  static int m_ro_stream_handles[uvm_report_object];

  // Not documented.
  uvm_report_message_element_container report_message_element_container;

  // Not documented.
  uvm_table_printer l_printer;


  `uvm_object_utils(uvm_report_message)


  // Not documented.
  static function uvm_report_message get_report_message();
    if (report_messages.size() != 0)
      return report_messages.pop_front();
    else begin
      uvm_report_message l_report_message = new("uvm_report_message");
      return l_report_message;
    end
  endfunction


  // Not documented.
  function void m_set_report_message(string context_name, string filename,
    int line, uvm_severity_type severity, string id,
    string message, int verbosity);
    this.context_name = context_name;
    this.filename = filename;
    this.line = line;
    this.severity = severity;
    this.id = id;
    this.message = message;
    this.verbosity = verbosity;
  endfunction


  // Not documented.
  virtual function void free_report_message(uvm_report_message report_message);
    report_message.m_clear();
    report_messages.push_back(report_message);
  endfunction


  // Not documented.
  virtual function void m_clear();
    tr_handle = -1;
    if (report_message_element_container.elements.size() != 0)
      delete_elements();
  endfunction


  // Not documented.
  function string convert2string();
    if (report_message_element_container.elements.size() == 0)
      return message;
    else
      convert2string = {message, "\n", report_message_element_container.sprint(l_printer)};
  endfunction


  // do_pack() not needed
  // do_unpack() not needed
  // do_compare() not needed


  // Not documented.  Should messages really support copying???
  virtual function void do_copy (uvm_object rhs);
    uvm_report_message report_message;

    super.do_copy(rhs);

    if(!$cast(report_message, rhs) || (rhs==null))
      return;

    report_object = report_message.report_object;
    report_handler = report_message.report_handler;
    report_server = report_message.report_server;
    context_name = report_message.context_name;
    file = report_message.file;
    filename = report_message.filename;
    line = report_message.line;
    action = report_message.action;
    severity = report_message.severity;
    id = report_message.id;
    message = report_message.message;
    verbosity = report_message.verbosity;
    tr_handle = report_message.tr_handle;

    // FIXME Need to implement copy of the element container

  endfunction


  // Not documented.
  virtual function int m_get_stream_id(uvm_recorder recorder);

    uvm_report_object l_ro;

    if(!m_ro_stream_handles.exists(report_object)) begin
      string l_string;
      if (report_object != uvm_root::get())
        l_string = report_object.get_full_name();
      else
        l_string = "reporter";
      m_ro_stream_handles[report_object] = 
        recorder.create_stream(l_string, "uvm_report_message stream", "UVM");
    end

    return m_ro_stream_handles[report_object];

  endfunction


  //----------------------------------------------------------------------------
  // Group:  Message Recording
  //----------------------------------------------------------------------------


  // Function: record_message
  // 
  // This method causes the message to be recorded using the supplied recorder.
  // If no recorder is provided, the uvm_default_recorder is used.  When this
  // method returns, the tr_handle of the message is populated.
  //

  virtual function void record_message(uvm_recorder recorder);
  
    int l_stream_id;

    if(recorder == null) 
      recorder = uvm_default_recorder;

    l_stream_id = m_get_stream_id(recorder);

    // Use uvm_report_message-ID-#
    tr_handle = recorder.begin_tr("uvm_report_message", l_stream_id,
      get_name(), "", "", $time);

    recorder.tr_handle = tr_handle;
    this.record(recorder);
    recorder.end_tr(tr_handle, $time);

  endfunction


  // Not documented.
  virtual function void m_record_message(uvm_recorder recorder);
    recorder.record_string("message", message);
  endfunction


  // Not documented.
  virtual function void m_record_core_properties(uvm_recorder recorder);

    string l_string;
    uvm_verbosity l_verbosity;

    // Replace these with recording macros when vendor supported.
    // Should everything really be a string?  Reconsider.
    if (context_name != "")
      recorder.record_string("context_name", context_name);
    recorder.record_string("filename", filename);
    l_string.itoa(line);
    recorder.record_string("line", l_string);
    //recorder.record_string("action", uvm_report_handler::format_action(action));
    recorder.record_string("severity", severity.name());
    recorder.record_string("id", id);
    m_record_message(recorder);
    if ($cast(l_verbosity, verbosity))
      recorder.record_string("verbosity", l_verbosity.name());
    else begin
      string l_str;
      l_string.itoa(verbosity);
      recorder.record_string("verbosity", l_string);
    end

  endfunction

  // Not documented.
  function void do_record(uvm_recorder recorder);

    super.do_record(recorder);

    m_record_core_properties(recorder);
    report_message_element_container.record(recorder);

  endfunction


  //----------------------------------------------------------------------------
  // Group:  Message Element APIs
  //----------------------------------------------------------------------------


  // Function: add_tag
  // 
  // This method adds a tag of the name ~name~ and value ~value~ to the message.
  //

  function void add_tag(string name, string value);
    report_message_element_container.add_tag(name, value);
  endfunction


  // Function: add_int
  // 
  // This method adds an integral type of the name ~name~ and value ~value~ to
  // the message.  The required ~radix~ field determines how to display and 
  // record the field.
  //

  // Fix argument size.
  function void add_int(string name, int value, uvm_radix_enum radix);
    report_message_element_container.add_int(name, value, radix);
  endfunction


  // Function: add_string
  // 
  // This method adds a string of the name ~name~ and value ~value~ to the 
  // message.  The required ~radix~ field determines how to display and record
  // the field.
  //

  function void add_string(string name, string value);
    report_message_element_container.add_string(name, value);
  endfunction


  // Function: add_string
  // 
  // This method adds a uvm_object of the name ~name~ and reference ~obj~ to
  // the message.  The required ~radix~ field determines how to display and 
  // record the field.
  //

  function void add_object(string name, uvm_object obj);
    report_message_element_container.add_object(name, obj);
  endfunction


  // Function: delete_elements
  // 
  // This method deletes all elements currently associated with the message.
  //

  function void delete_elements();
    report_message_element_container.elements.delete();
  endfunction

endclass


//------------------------------------------------------------------------------
//
// Class: uvm_trace_message
//
// This class provides the ability for report message objects to be created that 
// result in multiple message outputs and allow transaction recording of 
// properties.  The resultant recording reflects the begin time of end time of
// the action.  See the <`uvm_info_begin> and <`uvm_info_end> macros.
//
//------------------------------------------------------------------------------

class uvm_trace_message extends uvm_report_message;


  // Function: new
  // 
  // Creates a new uvm_report_message object.
  //

  function new(string name = "uvm_trace_message");
    super.new(name);
    state = TRC_INIT;
  endfunction

  `uvm_object_utils(uvm_trace_message)


  //----------------------------------------------------------------------------
  // Group:  Message Fields
  //----------------------------------------------------------------------------


  // Variable: end_message 
  //
  // This variable is the user message content string for ending of the message.
  // This is provided in addition to the <message> field such that both can be
  // recorded.

  string end_message;


  // Not documtend.
  typedef enum { TRC_INIT, TRC_BGN, TRC_END } state_e;

  // Not documented.
  state_e state;

  // Not documented.
  static local uvm_trace_message trace_messages[$];
 
  // Not documented.
  static function uvm_trace_message get_trace_message();
    if (trace_messages.size() != 0)
      return trace_messages.pop_front();
    else begin
      uvm_trace_message l_trace_message = new("uvm_trace_message");
      return l_trace_message;
    end
  endfunction
 
  // Not documented.
  virtual function void free_trace_message(uvm_trace_message trace_message);
    trace_message.m_clear();
    trace_messages.push_back(trace_message);
  endfunction

  // Not documented.
  function string convert2string();
    if (state == TRC_BGN)
      convert2string = {$sformatf("%s(id:%0d) : ", state.name(), tr_handle),
        message};
    if (state == TRC_END) begin
      convert2string = {$sformatf("%s(id:%0d) : ", state.name(), tr_handle),
        end_message};
      if (report_message_element_container.elements.size() != 0)
        convert2string = {convert2string, "\n", 
          report_message_element_container.sprint(l_printer)};
    end
  endfunction

  // Not documented.
  virtual function void m_clear();
    super.m_clear();
    end_message = "";
  endfunction

  // do_print() not needed
  // do_pack() not needed
  // do_unpack() not needed
  // do_compare() not needed

  // Not documented.
  virtual function void m_record_message(uvm_recorder recorder);
    recorder.record_string("begin message", message);
    recorder.record_string("end message", end_message);
  endfunction

  // Not documented.
  virtual function void record_message(uvm_recorder recorder);
  
    int l_stream_id;

    if(recorder == null) 
      recorder = uvm_default_recorder;

    l_stream_id = m_get_stream_id(recorder);

    if (state == TRC_BGN)
      tr_handle = recorder.begin_tr("uvm_trace_message", l_stream_id,
        get_name(), "", "", $time);

    if (state == TRC_END) begin
      recorder.tr_handle = tr_handle;
      this.record(recorder);
      recorder.end_tr(tr_handle, $time);
    end

  endfunction

endclass


//------------------------------------------------------------------------------
//
// Class: uvm_link_message
//
// This class provides the ability to create link relationships between the two 
// provided tr_handles (or transaction ids).  The tr_handles (~tr_id0~ and
// ~tr_id1~) are not user provided and should be retrieved from 
// uvm_report_message objects.  The ~relationship~ is a user provided string.
//
//------------------------------------------------------------------------------

class uvm_link_message extends uvm_report_message;


  // Function: new
  // 
  // Creates a new uvm_report_message object.
  //

  function new(string name = "uvm_link_message");
    super.new(name);
  endfunction


  //----------------------------------------------------------------------------
  // Group:  Linking Fields
  //----------------------------------------------------------------------------


  // Variable: tr_id0
  //
  // This variable is one of the user supplied tr_handles (or transaction ids)
  // that is retrieved from a uvm_report_message that has recorded.

  int tr_id0;


  // Variable: tr_id1
  //
  // This variable is one of the user supplied tr_handles (or transaction ids)
  // that is retrieved from a uvm_report_message that has recorded.

  int tr_id1;


  // Variable: relationship
  //
  // This variable specifies the relationship between ~tr_id0~ and ~tr_id1~.
  // The relationship is expressed:
  //
  // |Add final real output, TBD due to feedback.
  //

  string relationship;


  // Not documented.
  static local uvm_link_message link_messages[$];
 

  // Not documented.
  static function uvm_link_message get_link_message();
    if (link_messages.size() != 0)
      return link_messages.pop_front();
    else begin
      uvm_link_message l_link_message = new("uvm_link_message");
      return l_link_message;
    end
  endfunction
 

  // Not documented.
  virtual function void free_link_message(uvm_link_message link_message);
    link_message.m_clear();
    link_messages.push_back(link_message);
  endfunction


  // Not documented.
  virtual function void m_clear();
    super.m_clear();
    tr_id0 = -1;
    tr_id1 = -1;
    relationship = "";
  endfunction


  // Not documented.
  function string convert2string();
    if(action & UVM_RM_RECORD)
      if ( (tr_id0 == -1) || (tr_id1 == -1) )
        convert2string = 
          $sformatf("Invalid link attempted. id0: %0d, id1: %0d", tr_id0, 
          tr_id1);
      else
        convert2string = 
          $sformatf("Linking 'id0: %0d' as a '%s' of 'id1: %0d'", 
          tr_id0, relationship, tr_id1);
    else
      convert2string = "Link attempted but the UVM_RM_RECORD action is not set.";
  endfunction


  // do_print() not needed
  // do_pack() not needed
  // do_unpack() not needed
  // do_compare() not needed


  // Not documented.
  virtual function void record_message(uvm_recorder recorder);
  
    int l_stream_id;

    if(recorder == null) 
      recorder = uvm_default_recorder;

    if ( (tr_id0 != -1) && (tr_id1 != -1) ) begin
      recorder.link_tr(tr_id0, tr_id1, relationship);
    end

  endfunction


endclass


`endif
