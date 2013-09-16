//
//------------------------------------------------------------------------------
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
// CLASS- uvm_report_message_element_*
//
// Implementation detail -- not documented.
//
//------------------------------------------------------------------------------

virtual class uvm_report_message_element_base;
   typedef enum {NONE = 0, 
                 PRINT = 1, 
                 RECORD = 2, 
                 BOTH = 3} action_e;
   action_e _action;

   // Name
   //
   string       _name;
     
   function void print(uvm_printer printer);
      if (_action & PRINT)
        do_print(printer);
   endfunction : print
   function void record(uvm_recorder recorder);
      if (_action & RECORD)
        do_record(recorder);
   endfunction : record
   function void copy(uvm_report_message_element_base rhs);
      do_copy(rhs);
   endfunction : copy
   function uvm_report_message_element_base clone();
      return do_clone();
   endfunction : clone

   pure virtual function void do_print(uvm_printer printer);
   pure virtual function void do_record(uvm_recorder recorder);
   pure virtual function void do_copy(uvm_report_message_element_base rhs);
   pure virtual function uvm_report_message_element_base do_clone();
   
endclass : uvm_report_message_element_base

class uvm_report_message_int_element extends uvm_report_message_element_base;
   typedef uvm_report_message_int_element this_type;
   
   uvm_bitstream_t _val;
   int             _size;
   uvm_radix_enum  _radix;
   
   virtual function void do_print(uvm_printer printer);
      printer.print_int(_name, _val, _size, _radix);
   endfunction : do_print

   virtual function void do_record(uvm_recorder recorder);
      recorder.record_field(_name, _val, _size, _radix);
   endfunction : do_record

   virtual function void do_copy(uvm_report_message_element_base rhs);
      this_type _rhs;
      $cast(_rhs, rhs);
      _name = _rhs._name;
      _val = _rhs._val;
      _size = _rhs._size;
      _radix = _rhs._radix;
      _action = rhs._action;
   endfunction : do_copy

   virtual function uvm_report_message_element_base do_clone(); 
     this_type tmp = new; 
     tmp.copy(this); 
     return tmp; 
   endfunction : do_clone
endclass : uvm_report_message_int_element

class uvm_report_message_string_element extends uvm_report_message_element_base;
   typedef uvm_report_message_string_element this_type;
   string  _val;

   virtual function void do_print(uvm_printer printer);
      printer.print_string(_name, _val);
   endfunction : do_print

   virtual function void do_record(uvm_recorder recorder);
      recorder.record_string(_name, _val);
   endfunction : do_record

   virtual function void do_copy(uvm_report_message_element_base rhs);
      this_type _rhs;
      $cast(_rhs, rhs);
      _name = _rhs._name;
      _val = _rhs._val;
      _action = rhs._action;
   endfunction : do_copy
   
   virtual function uvm_report_message_element_base do_clone(); 
     this_type tmp = new; 
     tmp.copy(this); 
     return tmp; 
   endfunction : do_clone
endclass : uvm_report_message_string_element

class uvm_report_message_object_element extends uvm_report_message_element_base;
   typedef uvm_report_message_object_element this_type;
   uvm_object _val;
   bit _is_meta;

   virtual function void do_print(uvm_printer printer);
      if (!_is_meta)
         printer.print_object(_name, _val);
   endfunction : do_print

   virtual function void do_record(uvm_recorder recorder);
      if (!_is_meta)
         recorder.record_object(_name, _val);
      else
         recorder.record_meta(_name, _val);
   endfunction : do_record

   virtual function void do_copy(uvm_report_message_element_base rhs);
      this_type _rhs;
      $cast(_rhs, rhs);
      _name = _rhs._name;
      _val = _rhs._val;
      _is_meta = _rhs._is_meta;
      _action = rhs._action;
   endfunction : do_copy
   
   virtual function uvm_report_message_element_base do_clone(); 
     this_type tmp = new; 
     tmp.copy(this); 
     return tmp; 
   endfunction : do_clone
endclass : uvm_report_message_object_element

//------------------------------------------------------------------------------
//
// CLASS- uvm_report_message_element_container
//
// Implementation detail -- not documented.
//
//------------------------------------------------------------------------------

class uvm_report_message_element_container extends uvm_object;

  uvm_report_message_element_base elements[$];

  `uvm_object_utils(uvm_report_message_element_container)

  function new(string name = "element_container");
    super.new(name);
  endfunction

  function void delete_elements();
     elements.delete();
  endfunction

  function void add_int(string name, uvm_bitstream_t value, 
                        int size, uvm_radix_enum radix, bit print = 1, bit record = 1);
     uvm_report_message_int_element urme = new();
     urme._name = name;
     urme._val = value;
     urme._size = size;
     urme._radix = radix;
     urme._action = uvm_report_message_element_base::action_e'({record,print});
     elements.push_back(urme);
  endfunction

  function void add_string(string name, string value, bit print = 1, bit record = 1);
     uvm_report_message_string_element urme = new();
     urme._name = name;
     urme._val = value;
     urme._action = uvm_report_message_element_base::action_e'({record,print});
     elements.push_back(urme);
  endfunction

  function void add_object(string name, uvm_object obj, bit meta, bit print = 1, bit record = 1);
     uvm_report_message_object_element urme = new();
     urme._name = name;
     urme._val = obj;
     urme._is_meta = meta;
     urme._action = uvm_report_message_element_base::action_e'({record,print});
     elements.push_back(urme);
  endfunction

  function void do_print(uvm_printer printer);
    super.do_print(printer);
    for(int i = 0; i < elements.size(); i++) begin
       elements[i].print(printer);
    end 
  endfunction

  function void do_record(uvm_recorder recorder);
    super.do_record(recorder);
    for(int i = 0; i < elements.size(); i++) begin
       elements[i].record(recorder);
    end
  endfunction

  function void do_copy(uvm_object rhs);
    uvm_report_message_element_container urme_container;

    super.do_copy(rhs);

    if(!$cast(urme_container, rhs) || (rhs==null))
      return;

    delete_elements();
    foreach (urme_container.elements[i])
      elements.push_back(urme_container.elements[i].clone());

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
// necessary to add integral types, strings and uvm_objects to a message.
//
//------------------------------------------------------------------------------

class uvm_report_message extends uvm_object;

  //----------------------------------------------------------------------------
  // Group:  Infrastructure References
  //----------------------------------------------------------------------------


  // Variable: report_object
  //
  // This variable is the uvm_report_object that originated the message.

  uvm_report_object report_object;
 

  // Variable: report_handler
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

  // This can be used for testing performance of the queue structures
  // By default, value = 0, no reuse
  // Experiment by simply changing the value.
  static int max_reused_messages;

  // Not documented.
  static int m_ro_stream_handles[uvm_report_handler];

  // Not documented.
  uvm_report_message_element_container report_message_element_container;


  // Function: new
  // 
  // Creates a new uvm_report_message object.
  //

  function new(string name = "uvm_report_message");
    super.new(name);
    tr_handle = -1;
    report_message_element_container = new();
  endfunction


  // Function: print
  //
  // The uvm_report_messge implements the uvm_object::do_print() such that
  // uvm_report_message::print() method provides UVM printer formatted output
  // of the message.  A snippet of example output is shown here:
  //
  // --------------------------------------------------------
  // Name               Type               Size  Value
  // --------------------------------------------------------
  // uvm_trace_message  uvm_trace_message  -     @532
  //   severity         uvm_severity_type  2     UVM_INFO
  //   id               string             10    TEST_ID
  //   message          string             12    A message...
  //   verbosity        uvm_verbosity      32    UVM_LOW
  //   filename         string             7     test.sv
  //   line             integral           32    'd58
  //   context_name     string             0     ""
  //   color            string             3     red
  //   my_int           integral           32    'd5
  //   my_string        string             3     foo
  //   my_obj           my_class           -     @531
  //     foo            integral           32    'd3
  //     bar            string             8     hi there


  function void do_print(uvm_printer printer);
    uvm_verbosity l_verbosity;

    super.do_print(printer);

    printer.print_generic("severity", "uvm_severity_type", 
                          $bits(severity), severity.name());
    printer.print_string("id", id);
    printer.print_string("message",message);
    if ($cast(l_verbosity, verbosity))
      printer.print_generic("verbosity", "uvm_verbosity", 
                            $bits(l_verbosity), l_verbosity.name());
    else
      printer.print_int("verbosity", l_verbosity, $bits(l_verbosity), UVM_HEX);
    printer.print_string("filename", filename);
    printer.print_int("line", line, $bits(line), UVM_UNSIGNED);
    printer.print_string("context_name", context_name);

    if (report_message_element_container.elements.size() != 0)
      report_message_element_container.print(printer);
  endfunction


  `uvm_object_utils(uvm_report_message)

  // Not documented.
  function void set_report_message(string filename,
    int line, uvm_severity_type severity, string id,
    string message, int verbosity, string context_name);
    this.context_name = context_name;
    this.filename = filename;
    this.line = line;
    this.severity = severity;
    this.id = id;
    this.message = message;
    this.verbosity = verbosity;
  endfunction

  // Not documented.
  function string convert2string();
    if (report_message_element_container.elements.size() == 0)
      return message;
    else begin
      string prefix = uvm_default_printer.knobs.prefix;
      uvm_default_printer.knobs.prefix = " +";
      convert2string = {message, "\n", report_message_element_container.sprint()};
      uvm_default_printer.knobs.prefix = prefix;
    end
  endfunction


  // do_pack() not needed
  // do_unpack() not needed
  // do_compare() not needed


  // Not documented.
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

    report_message_element_container.copy(report_message.report_message_element_container);
  endfunction


  // Not documented.
  virtual function int m_get_stream_id(uvm_recorder recorder);

    if(!m_ro_stream_handles.exists(report_handler)) begin
      string l_scope, l_name;
      l_scope = report_handler.get_name();
      l_name = report_object.get_name();
      m_ro_stream_handles[report_handler] = 
        recorder.create_stream(l_name, "MESSAGES", l_scope);
    end

    return m_ro_stream_handles[report_handler];

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
    tr_handle = recorder.begin_tr(get_type_name(), l_stream_id,
      get_name(), id, message, $time);

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

    if (context_name != "")
      recorder.record_string("context_name", context_name);
    recorder.record_string("filename", filename);
    recorder.record_field("line", line, $bits(line), UVM_UNSIGNED);
    recorder.record_string("severity", severity.name());
    if ($cast(l_verbosity, verbosity))
      recorder.record_string("verbosity", l_verbosity.name());
    else begin
      l_string.itoa(verbosity);
      recorder.record_string("verbosity", l_string);
    end

    recorder.record_string("id", id);
    m_record_message(recorder);
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


  // Function: add_int
  // 
  // This method adds an integral type of the name ~name~ and value ~value~ to
  // the message.  The required ~size~ field indicates the size of ~value~. 
  // The required ~radix~ field determines how to display and 
  // record the field.
  //

  function void add_int(string name, uvm_bitstream_t value, 
                        int size, uvm_radix_enum radix, bit print = 1, bit record = 1);
    report_message_element_container.add_int(name, value, size, radix, print, record);
  endfunction


  // Function: add_string
  // 
  // This method adds a string of the name ~name~ and value ~value~ to the 
  // message. 
  //

  function void add_string(string name, string value, bit print = 1, bit record = 1);
    report_message_element_container.add_string(name, value, print, record);
  endfunction


  // Function: add_object
  // 
  // This method adds a uvm_object of the name ~name~ and reference ~obj~ to
  // the message.  
  //

  function void add_object(string name, uvm_object obj, bit print = 1, bit record = 1);
    report_message_element_container.add_object(name, obj, 0, print, record);
  endfunction

   
  // Function: add_meta
  //
  // This method adds meta data of the name ~name~ and reference ~meta~ to
  // the message. Meata data will not be printed out, and by default, will
  // not be recorded, but extended recorder can use it for extensibility.
  //
  
  function void add_meta(string name, uvm_object meta);
    report_message_element_container.add_object(name, meta, 1, 0, 1);
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
 
  // Function: new
  // 
  // Creates a new uvm_report_message object.
  //

  function new(string name = "uvm_trace_message");
    super.new(name);
    state = TRC_INIT;
  endfunction

  `uvm_object_utils(uvm_trace_message)

  // Not documented.
  function string convert2string();
    if (state == TRC_BGN)
      convert2string = {$sformatf("%s(id:%0d) : ", state.name(), tr_handle),
        message};
    if (state == TRC_END) begin
      convert2string = {$sformatf("%s(id:%0d) : ", state.name(), tr_handle),
        end_message};
      if (report_message_element_container.elements.size() != 0) begin
        string prefix = uvm_default_printer.knobs.prefix;
        uvm_default_printer.knobs.prefix = " +";
        convert2string = {convert2string, "\n", report_message_element_container.sprint()};
        uvm_default_printer.knobs.prefix = prefix;
      end
    end
  endfunction

  // do_print() not needed
  // do_pack() not needed
  // do_unpack() not needed
  // do_compare() not needed

  // Not documented.
  virtual function void m_record_message(uvm_recorder recorder);
    recorder.record_string("begin_message", message);
//    recorder.record_string("end message", end_message);
  endfunction

  // Not documented.
  virtual function void record_message(uvm_recorder recorder);
  
    int l_stream_id;

    if(recorder == null) 
      recorder = uvm_default_recorder;

    l_stream_id = m_get_stream_id(recorder);

    if (state == TRC_BGN) begin
      tr_handle = recorder.begin_tr(get_type_name(), l_stream_id,
        get_name(), id, message, $time);
      recorder.tr_handle = tr_handle;
      this.record(recorder);
    end

    if (state == TRC_END) begin
      recorder.tr_handle = tr_handle;
      this.record(recorder);
      recorder.end_tr(tr_handle, $time);
    end

  endfunction

  // Not documented.
  function void do_record(uvm_recorder recorder);

    if (state == TRC_BGN) 
      m_record_core_properties(recorder);

    if (state == TRC_END) begin
      recorder.record_string("end_message", end_message);
      report_message_element_container.record(recorder);
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
  // The relationship is expressed, e.g.:
  //
  // "Linking id0: 12 and id1: 25 with relationship of parent_child."
  //

  string relationship;


  // Function: link
  //
  // Link tr_handles (or transaction ids) ~id0~ and ~id1~ with relationship
  // of ~rel~.
  //

  function void link(int id0, int id1, string rel);
    tr_id0 = id0;
    tr_id1 = id1;
    relationship = rel;
  endfunction
    

  // Not documented.
  static local uvm_link_message link_messages[$];
 


  // Not documented.
  static function uvm_link_message get_link_message();
    if (link_messages.size() != 0)
      return link_messages.pop_front();
    else begin
      process p;
      string randstate;
      uvm_link_message l_link_message;

      p = process::self();
      randstate = p.get_randstate();
      l_link_message = new("uvm_link_message");
      p.set_randstate(randstate);

      return l_link_message;
    end
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
          $sformatf("Linking 'id0: %0d' and 'id1: %0d' with relationship of '%s'.", 
          tr_id0, tr_id1, relationship);
    else
      convert2string = "Link attempted but the UVM_RM_RECORD action is not set.";
  endfunction


  // do_print() not needed
  // do_pack() not needed
  // do_unpack() not needed
  // do_compare() not needed


  // Not documented.
  virtual function void record_message(uvm_recorder recorder);
  
    if(recorder == null) 
      recorder = uvm_default_recorder;

    if ( (tr_id0 != -1) && (tr_id1 != -1) ) begin
      recorder.link_tr(tr_id0, tr_id1, relationship);
    end

  endfunction


endclass


`endif
