typedef class uvm_report_server;
typedef class uvm_report_handler;
typedef class uvm_root;
 
// FIXME fix the m_ on methods usage!!!

// uvm_report_message.  Base message class.  Holds the basics of a message.

class uvm_report_message extends uvm_object;

  static local uvm_report_message report_messages[$];
 
  uvm_report_object report_object;
  uvm_report_handler report_handler;
  uvm_report_server report_server;
  string context_name;
  UVM_FILE file;
  string filename;
  int line;
  uvm_severity_type severity; 
  string id;
  string message;
  int verbosity;
  uvm_action action; 
  int tr_handle;

  static int m_ro_stream_handles[uvm_report_object];

  `uvm_object_utils(uvm_report_message)

  function new(string name = "uvm_report_message");
    super.new(name);
    tr_handle = -1;
  endfunction

  static function uvm_report_message get_report_message();
    if (report_messages.size() != 0)
      return report_messages.pop_front();
    else begin
      uvm_report_message l_report_message = new("uvm_report_message");
      return l_report_message;
    end
  endfunction

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

  virtual function void free_report_message(uvm_report_message report_message);
    report_message.clear();
    report_messages.push_back(report_message);
  endfunction

  virtual function void clear();
    tr_handle = -1;
  endfunction

  function string convert2string();
    return message;
  endfunction

  // do_print() not needed
  // do_pack() not needed
  // do_unpack() not needed
  // do_compare() not needed

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

  endfunction

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

  virtual function void record_message(uvm_recorder recorder);
  
    int l_stream_id;

    if(recorder == null) 
      recorder = uvm_default_recorder;

    l_stream_id = m_get_stream_id(recorder);

    tr_handle = recorder.begin_tr("uvm_report_message", l_stream_id,
      get_name(), "", "", $time);

    recorder.tr_handle = tr_handle;
    this.record(recorder);
    recorder.end_tr(tr_handle, $time);

  endfunction

  virtual function void m_record_message(uvm_recorder recorder);
    recorder.record_string("message", message);
  endfunction

  virtual function void m_record_core_properties(uvm_recorder recorder);

    string l_string;
    uvm_verbosity l_verbosity;

    // Replace these with recording macros when vendor supported.
    if (context_name != "")
      recorder.record_string("context_name", context_name);
    recorder.record_string("filename", filename);
    l_string.itoa(line);
    recorder.record_string("line", l_string);
    //recorder.record_string("action", uvm_report_handler::format_action(action));
    recorder.record_string("severity", severity.name());
    recorder.record_string("id", id);
    //recorder.record_string("message", message);
    m_record_message(recorder);
    if ($cast(l_verbosity, verbosity))
      recorder.record_string("verbosity", l_verbosity.name());
    else begin
      string l_str;
      l_string.itoa(verbosity);
      recorder.record_string("verbosity", l_string);
    end

  endfunction

  function void do_record(uvm_recorder recorder);

    super.do_record(recorder);

    m_record_core_properties(recorder);

  endfunction

endclass


// Implementation detail -- not documented.

class uvm_trace_element;

  typedef enum {INT, STRING, OBJECT, MESS_TAG} element_type_e;

  element_type_e m_element_type;
  string m_element_name;
  int m_int_value;
  uvm_radix_enum m_int_radix;
  string m_string_value;
  uvm_object m_object;

endclass


// Implementation detail -- not documented.

class uvm_trace_element_container extends uvm_object;

  uvm_trace_element elements[$];

  `uvm_object_utils(uvm_trace_element_container)

  function new(string name = "trace_element_container");
    super.new(name);
  endfunction

  function void add_tag(string name, string value);
    uvm_trace_element ume = new();
    ume.m_element_type = uvm_trace_element::MESS_TAG;
    ume.m_element_name = name;
    ume.m_string_value = value;
    elements.push_back(ume);
  endfunction

  function void add_int(string name, int value, uvm_radix_enum radix);
    uvm_trace_element ume = new();
    ume.m_element_type = uvm_trace_element::INT;
    ume.m_element_name = name;
    ume.m_int_value = value;
    ume.m_int_radix = radix;
    elements.push_back(ume);
  endfunction

  function void add_string(string name, string value);
    uvm_trace_element ume = new();
    ume.m_element_type = uvm_trace_element::STRING;
    ume.m_element_name = name;
    ume.m_string_value = value;
    elements.push_back(ume);
  endfunction

  function void add_object(string name, uvm_object obj);
    uvm_trace_element ume = new();
    ume.m_element_type = uvm_trace_element::OBJECT;
    ume.m_element_name = name;
    ume.m_object = obj;
    elements.push_back(ume);
  endfunction

  function void do_print(uvm_printer printer);
    super.do_print(printer);
    for(int i = 0; i < elements.size(); i++) begin
      if (elements[i].m_element_type == uvm_trace_element::MESS_TAG) begin
        printer.print_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_trace_element::INT) begin
        printer.print_int(elements[i].m_element_name, elements[i].m_int_value, 
          $bits(elements[i].m_int_value), elements[i].m_int_radix);
      end
      if (elements[i].m_element_type == uvm_trace_element::STRING) begin
        printer.print_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_trace_element::OBJECT) begin
        printer.print_object(elements[i].m_element_name, elements[i].m_object);
      end
    end 
  endfunction

  function void do_record(uvm_recorder recorder);
    super.do_record(recorder);
    for(int i = 0; i < elements.size(); i++) begin
      if (elements[i].m_element_type == uvm_trace_element::MESS_TAG) begin
        recorder.record_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_trace_element::INT) begin
        recorder.record_field(elements[i].m_element_name, elements[i].m_int_value, 
          $bits(elements[i].m_int_value), elements[i].m_int_radix);
      end
      if (elements[i].m_element_type == uvm_trace_element::STRING) begin
        recorder.record_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_trace_element::OBJECT) begin
        recorder.record_object(elements[i].m_element_name, elements[i].m_object);
      end
    end
  endfunction

endclass


// Class: uvm_trace_message
//
// This class adds the ability to add elements (ints, strings and/or uvm_objects)
// to a uvm_report_message.

class uvm_trace_message extends uvm_report_message;

  typedef enum { TRC_INIT, TRC_BGN, TRC_END } state_e;

  uvm_table_printer l_printer;
  state_e state;
  string end_message;

  `uvm_object_utils(uvm_trace_message)

  uvm_trace_element_container trace_element_container;

  function new(string name = "uvm_trace_message");
    super.new(name);
    state = TRC_INIT;
    trace_element_container = new();
    l_printer = new();
    //l_printer.knobs.header = 0;
    //l_printer.knobs.footer = 0;
    l_printer.knobs.prefix = "  ";
  endfunction

  static local uvm_trace_message trace_messages[$];
 
  static function uvm_trace_message get_trace_message();
    if (trace_messages.size() != 0)
      return trace_messages.pop_front();
    else begin
      uvm_trace_message l_trace_message = new("uvm_trace_message");
      return l_trace_message;
    end
  endfunction
 
  virtual function void free_trace_message(uvm_trace_message trace_message);
    trace_message.clear();
    trace_messages.push_back(trace_message);
  endfunction

  function string convert2string();
    if (state == TRC_BGN)
      convert2string = {$sformatf("%s(id:%0d) : ", state.name(), tr_handle),
        message};
    if (state == TRC_END) begin
      convert2string = {$sformatf("%s(id:%0d) : ", state.name(), tr_handle),
        end_message};
      if (trace_element_container.elements.size() != 0)
        convert2string = {convert2string, "\n", 
          trace_element_container.sprint(l_printer)};
    end
  endfunction

  virtual function void clear();
    super.clear();
    end_message = "";
    delete_elements();
  endfunction

  // do_print() not needed
  // do_pack() not needed
  // do_unpack() not needed
  // do_compare() not needed

  // FIXME Need to implement the do_copy()
  //virtual function void do_copy (uvm_object rhs);

  function void do_print(uvm_printer printer);
    super.do_print(printer);
    if (state == TRC_END)
      trace_element_container.print(printer);
  endfunction

  virtual function void m_record_message(uvm_recorder recorder);
    recorder.record_string("begin message", message);
    recorder.record_string("end message", end_message);
  endfunction

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

  function void do_record(uvm_recorder recorder);
    super.do_record(recorder);
    trace_element_container.record(recorder);
  endfunction

  function void delete_elements();
    trace_element_container.elements.delete();
  endfunction

  function void add_tag(string name, string value);
    trace_element_container.add_tag(name, value);
  endfunction

  function void add_int(string name, int value, uvm_radix_enum radix);
    trace_element_container.add_int(name, value, radix);
  endfunction

  function void add_string(string name, string value);
    trace_element_container.add_string(name, value);
  endfunction

  function void add_object(string name, uvm_object obj);
    trace_element_container.add_object(name, obj);
  endfunction

endclass


// Link message class.  Adds the ability to provide two tr_ids and a
// relationship between them.
class uvm_link_message extends uvm_report_message;

  int tr_id0;
  int tr_id1;
  string relationship;

  function new(string name = "uvm_link_message");
    super.new(name);
  endfunction

  static local uvm_link_message link_messages[$];
 
  static function uvm_link_message get_link_message();
    if (link_messages.size() != 0)
      return link_messages.pop_front();
    else begin
      uvm_link_message l_link_message = new("uvm_link_message");
      return l_link_message;
    end
  endfunction
 
  virtual function void free_link_message(uvm_link_message link_message);
    link_message.clear();
    link_messages.push_back(link_message);
  endfunction

  virtual function void clear();
    super.clear();
    tr_id0 = -1;
    tr_id1 = -1;
    relationship = "";
  endfunction

  function string convert2string();
    if(action & UVM_RM_RECORD)
      if ( (tr_id0 == -1) || (tr_id1 == -1) )
        convert2string = 
          $sformatf("Invalid link attempted. id0: %0d, id1: %0d", tr_id0, 
          tr_id1);
      else
        convert2string = 
          $sformatf("Link of '%s' created between id0: %0d and id1: %0d", 
          relationship, tr_id0, tr_id1);
    else
      convert2string = "Link attempted but the UVM_RM_RECORD action is not set.";
  endfunction

  // do_print() not needed
  // do_pack() not needed
  // do_unpack() not needed
  // do_compare() not needed

  // FIXME Need to implement the do_copy()
  //virtual function void do_copy (uvm_object rhs);

  virtual function void record_message(uvm_recorder recorder);
  
    int l_stream_id;

    if(recorder == null) 
      recorder = uvm_default_recorder;

    if ( (tr_id0 != -1) && (tr_id1 != -1) ) begin
      recorder.link_tr(tr_id0, tr_id1, relationship);
    end

  endfunction

endclass

