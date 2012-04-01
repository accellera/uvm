 
typedef class uvm_report_server;
typedef class uvm_report_handler;
 

class uvm_message_element;

  typedef enum {INT, STRING, OBJECT, MESS_TAG} element_type_e;

  element_type_e m_element_type;
  string m_element_name;
  int m_int_value;
  uvm_radix_enum m_int_radix;
  string m_string_value;
  uvm_object m_object;

endclass

//FIXME Need to support printing (via convert2string()) and recording
//of additional elements.  TBD

// uvm_report_message
// Base message class.  Holds the basics of a message.
class uvm_report_message extends uvm_object;

  uvm_report_object ro;
  uvm_report_handler rh;
  uvm_report_server rs;
  string context_name;
  UVM_FILE file;
  string filename;
  int line;
  uvm_action action; 
  uvm_severity_type severity; 
  string id;
  string message;
  int verbosity;
  int tr_handle;

  uvm_message_element elements[$];

  // HAND IMPLEMENT THESE
  `uvm_object_utils_begin(uvm_report_message)
    `uvm_field_object(ro, UVM_ALL_ON | UVM_REFERENCE)
    `uvm_field_object(rh, UVM_ALL_ON | UVM_REFERENCE)
    `uvm_field_object(rs, UVM_ALL_ON | UVM_REFERENCE)
    `uvm_field_string(context_name, UVM_ALL_ON)
    `uvm_field_int(file, UVM_ALL_ON | UVM_NORECORD)
    `uvm_field_string(filename, UVM_ALL_ON)
    `uvm_field_int(line, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(action, UVM_ALL_ON)
    `uvm_field_enum(uvm_severity_type, severity, UVM_ALL_ON | UVM_NORECORD)
    `uvm_field_string(id, UVM_ALL_ON)
    `uvm_field_string(message, UVM_ALL_ON)
    `uvm_field_int(verbosity, UVM_ALL_ON | UVM_NORECORD)
    `uvm_field_int(tr_handle, UVM_ALL_ON | UVM_NORECORD)
  `uvm_object_utils_end

  function new(string name = "uvm_report_message");
    super.new(name);
  endfunction

  function string convert2string();
    if(elements.size() != 0) begin
      // append the elements to the message
    end
    return message;
  endfunction

  function void delete_elements();
    elements.delete();
  endfunction

  function void add_tag(string name, string value);
    uvm_message_element ume = new();
    ume.m_element_type = uvm_message_element::MESS_TAG;
    ume.m_element_name = name;
    ume.m_string_value = value;
    elements.push_back(ume);
  endfunction

  function void add_int(string name, int value, uvm_radix_enum radix);
    uvm_message_element ume = new();
    ume.m_element_type = uvm_message_element::INT;
    ume.m_element_name = name;
    ume.m_int_value = value;
    ume.m_int_radix = radix;
    elements.push_back(ume);
  endfunction

  function void add_string(string name, string value);
    uvm_message_element ume = new();
    ume.m_element_type = uvm_message_element::STRING;
    ume.m_element_name = name;
    ume.m_string_value = value;
    elements.push_back(ume);
  endfunction

  function void add_object(string name, uvm_object obj);
    uvm_message_element ume = new();
    ume.m_element_type = uvm_message_element::OBJECT;
    ume.m_element_name = name;
    ume.m_object = obj;
    elements.push_back(ume);
  endfunction

  function void do_print(uvm_printer printer);
    // Lots to do here
    super.do_print(printer);
    for(int i = 0; i < elements.size(); i++) begin
      if (elements[i].m_element_type == uvm_message_element::MESS_TAG) begin
        printer.print_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_message_element::INT) begin
        printer.print_int(elements[i].m_element_name, elements[i].m_int_value, 
          $bits(elements[i].m_int_value), elements[i].m_int_radix);
      end
      if (elements[i].m_element_type == uvm_message_element::STRING) begin
        printer.print_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_message_element::OBJECT) begin
        printer.print_object(elements[i].m_element_name, elements[i].m_object);
      end
    end 
  endfunction

  function void do_record(uvm_recorder recorder);
    // Lots to do here
    super.do_record(recorder);
    for(int i = 0; i < elements.size(); i++) begin
      if (elements[i].m_element_type == uvm_message_element::MESS_TAG) begin
        recorder.record_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_message_element::INT) begin
        recorder.record_field(elements[i].m_element_name, elements[i].m_int_value, 
          $bits(elements[i].m_int_value), elements[i].m_int_radix);
      end
      if (elements[i].m_element_type == uvm_message_element::STRING) begin
        recorder.record_string(elements[i].m_element_name, elements[i].m_string_value);
      end
      if (elements[i].m_element_type == uvm_message_element::OBJECT) begin
        recorder.record_object(elements[i].m_element_name, elements[i].m_object);
      end
    end
  endfunction

endclass


// FIXME add report message linking class
