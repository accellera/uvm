typedef class uvm_report_server;
typedef class uvm_report_handler;
 

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

  `uvm_object_utils(uvm_report_message)

  function new(string name = "uvm_report_message");
    super.new(name);
  endfunction

  function string convert2string();
    return message;
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
    // Nothing to do for this class since all fields populated in call chain
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

  function void do_record(uvm_recorder recorder);

    string l_string;
    uvm_verbosity l_verbosity;

    super.do_record(recorder);

    // Replace these with recording macros when vendor supported.
    if (context_name != "")
      recorder.record_string("context_name", context_name);
    recorder.record_string("filename", filename);
    l_string.itoa(line);
    recorder.record_string("line", l_string);
    recorder.record_string("action", uvm_report_handler::format_action(action));
    recorder.record_string("severity", severity.name());
    recorder.record_string("id", id);
    recorder.record_string("message", message);
    if ($cast(l_verbosity, verbosity))
      recorder.record_string("verbosity", l_verbosity.name());
    else begin
      string l_str;
      l_string.itoa(verbosity);
      recorder.record_string("verbosity", l_string);
    end

  endfunction

endclass


// Implementation detail -- not documented.

class uvm_trace_message_element;

  typedef enum {INT, STRING, OBJECT, MESS_TAG} element_type_e;

  element_type_e m_element_type;
  string m_element_name;
  int m_int_value;
  uvm_radix_enum m_int_radix;
  string m_string_value;
  uvm_object m_object;

endclass


// Implementation detail -- not documented.

class uvm_trace_message_element_container extends uvm_object;

  uvm_trace_message_element elements[$];

  `uvm_object_utils(uvm_trace_message_element_container)

  function new(string name = "Trace Message Elements");
    super.new(name);
  endfunction

  function void add_tag(string name, string value);
    uvm_trace_message_element ume = new();
    ume.m_element_type = uvm_trace_message_element::MESS_TAG;
    ume.m_element_name = name;
    ume.m_string_value = value;
    elements.push_back(ume);
  endfunction

  function void add_int(string name, int value, uvm_radix_enum radix);
    uvm_trace_message_element ume = new();
    ume.m_element_type = uvm_trace_message_element::INT;
    ume.m_element_name = name;
    ume.m_int_value = value;
    ume.m_int_radix = radix;
    elements.push_back(ume);
  endfunction

  function void add_string(string name, string value);
    uvm_trace_message_element ume = new();
    ume.m_element_type = uvm_trace_message_element::STRING;
    ume.m_element_name = name;
    ume.m_string_value = value;
    elements.push_back(ume);
  endfunction

  function void add_object(string name, uvm_object obj);
    uvm_trace_message_element ume = new();
    ume.m_element_type = uvm_trace_message_element::OBJECT;
    ume.m_element_name = name;
    ume.m_object = obj;
    elements.push_back(ume);
  endfunction

  function void do_print(uvm_printer printer);
    super.do_print(printer);
    for(int i = 0; i < elements.size(); i++) begin
      if (elements[i].m_element_type == uvm_trace_message_element::MESS_TAG) begin
        printer.print_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_trace_message_element::INT) begin
        printer.print_int(elements[i].m_element_name, elements[i].m_int_value, 
          $bits(elements[i].m_int_value), elements[i].m_int_radix);
      end
      if (elements[i].m_element_type == uvm_trace_message_element::STRING) begin
        printer.print_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_trace_message_element::OBJECT) begin
        printer.print_object(elements[i].m_element_name, elements[i].m_object);
      end
    end 
  endfunction

  function void do_record(uvm_recorder recorder);
    super.do_record(recorder);
    for(int i = 0; i < elements.size(); i++) begin
      if (elements[i].m_element_type == uvm_trace_message_element::MESS_TAG) begin
        recorder.record_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_trace_message_element::INT) begin
        recorder.record_field(elements[i].m_element_name, elements[i].m_int_value, 
          $bits(elements[i].m_int_value), elements[i].m_int_radix);
      end
      if (elements[i].m_element_type == uvm_trace_message_element::STRING) begin
        recorder.record_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_trace_message_element::OBJECT) begin
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

  // Needs enum to say it BEGIN_TR, END_TR, or UNKNOWN?

  `uvm_object_utils(uvm_trace_message)

  uvm_trace_message_element_container trace_message_element_container;

  function new(string name = "uvm_trace_message");
    super.new(name);
    trace_message_element_container = new();
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
    return {message, "\n", trace_message_element_container.sprint()};
  endfunction

  virtual function void clear();
    delete_elements();
  endfunction

  function void do_print(uvm_printer printer);
    super.do_print(printer);
    trace_message_element_container.print(printer);
  endfunction

  function void do_record(uvm_recorder recorder);
    super.do_record(recorder);
    trace_message_element_container.record(recorder);
  endfunction

  function void delete_elements();
    trace_message_element_container.elements.delete();
  endfunction

  function void add_tag(string name, string value);
    trace_message_element_container.add_tag(name, value);
  endfunction

  function void add_int(string name, int value, uvm_radix_enum radix);
    trace_message_element_container.add_int(name, value, radix);
  endfunction

  function void add_string(string name, string value);
    trace_message_element_container.add_string(name, value);
  endfunction

  function void add_object(string name, uvm_object obj);
    trace_message_element_container.add_object(name, obj);
  endfunction

endclass


// FIXME add report message linking class
