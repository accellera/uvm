
`ifndef UVM_CMDLINE_PROCESSOR_SV
`define UVM_CMDLINE_PROCESSOR_SV

// Class: uvm_cmdline_processor
//
// This class provides an interface to the command line arguments that 
// were provided for the given simulation.  The class is intended to be
// used as a singleton, but that isn't required; the generation of the
// datastructures which hold the command line argument information 
// happens during construction of the class object.
//
// A global variable called ~uvm_cmdline_proc~ is created at initialization time
// and may be used to access command line information.
//
// The uvm_cmdline_processor class also provides support for setting various UVM
// variables from the command line such as components' verbosities and configuration
// settings for integral types and strings.  Each of these capablities is described 
// in the Built-in UVM Aware Command Line Arguments section.
//

class uvm_cmdline_processor;
  static protected uvm_cmdline_processor m_inst;

  // Group: Singleton 

  // Function: get_inst
  // Returns the singleton instance of the UVM command line processor.
  static function uvm_cmdline_processor get_inst();
    if(m_inst == null) m_inst = new;
    return m_inst;
  endfunction

  protected string m_argv[$]; 
  protected string m_plus_argv[$];
  protected string m_uvm_argv[$];

  // Group: Basic Arguments
  
  // Function: get_args
  //
  // This function returns a queue with all of the command line
  // arguments that were used to start the simulation. Note that
  // element 0 of the array will always be the name of the 
  // executable which started the simulation.

  function void get_args (output string args[$]);
    args = m_argv;
  endfunction

  // Function: get_plusargs
  //
  // This function returns a queue with all of the plus arguments
  // that were used to start the simulation. Plusarguments may be
  // used by the simulator vendor, or may be specific to a company
  // or individiual user. Plusargs never have extra arguments
  // (i.e. if there is a plusarg as the second argument on the
  // command line, the third argument is unrelated); this is not
  // necessarily the case with vendor specific dash arguments.

  function void get_plusargs (output string args[$]);
    args = m_plus_argv;
  endfunction

  // Function: get_uvmargs
  //
  // This function returns a queue with all of the uvm arguments
  // that were used to start the simulation. An UVM argument is
  // taken to be any argument that starts with a - or + and uses
  // the keyword UVM (case insensitive) as the first three
  // letters of the argument.

  function void get_uvm_args (output string args[$]);
    args = m_uvm_argv;
  endfunction

  // Function: get_arg_matches
  //
  // This function loads a queue with all of the arguments that
  // match the input expression and returns the number of items
  // that matched. If the input expression is bracketed
  // with //, then it is taken as an extended regular expression 
  // otherwise, it is taken as the beginning of an argument to match.
  // For example:
  //
  //| string myargs[$]
  //| initial begin
  //|    void'(uvm_cmdline_proc.get_arg_matches("+foo",myargs)); //matches +foo, +foobar
  //|                                                            //doesn't match +barfoo
  //|    void'(uvm_cmdline_proc.get_arg_matches("/foo/",myargs)); //matches +foo, +foobar,
  //|                                                             //foo.sv, barfoo, etc.
  //|    void'(uvm_cmdline_proc.get_arg_matches("/^foo.*\.sv",myargs)); //matches foo.sv
  //|                                                                   //and foo123.sv,
  //|                                                                   //not barfoo.sv.

  function int get_arg_matches (string match, ref string args[$]);
    chandle exp_h = null;
    int len = match.len();
    args.delete();
    if((match.len() > 2) && (match[0] == "/") && (match[match.len()-1] == "/")) begin
       match = match.substr(1,match.len()-2);
       exp_h = dpi_regcomp(match);
       if(exp_h == null) begin
         uvm_report_error("UVM_CMDLINE_PROC", {"Unable to compile the regular expression: ", match}, UVM_NONE);
         return 0;
       end
    end
    foreach (m_argv[i]) begin
      if(exp_h != null) begin
        if(!dpi_regexec(exp_h, m_argv[i]))
           args.push_back(m_argv[i]);
      end
      else if((m_argv[i].len() >= len) && (m_argv[i].substr(0,len) == match))
        args.push_back(m_argv[i]);
    end

    if(exp_h != null)
      dpi_regfree(exp_h);

    return args.size();
  endfunction


  // Group: Argument Values

  // Function: get_arg_value
  //
  // This function finds the first argument which matches the ~match~ arg and
  // returns the suffix of the argument. This is similar to the $value$plusargs
  // system task, but does not take a formating string. The return value is
  // the number of command line arguments that match the ~match~ string, and
  // ~value~ is the value of the first match.
  
  function int get_arg_value (string match, output string value);
    int chars = match.len();
    get_arg_value = 0;
    foreach (m_argv[i]) begin
      if(m_argv[i].len() >= chars) begin
        if(m_argv[i].substr(0,chars-1) == match) begin
          get_arg_value++;
          if(get_arg_value == 1)
            value = m_argv[i].substr(chars,m_argv[i].len()-1);
        end
      end
    end
  endfunction

  // Function: get_arg_values
  //
  // This function finds all the arguments which matches the ~match~ arg and
  // returns the suffix of the arguments in a list of values. The return
  // value is the number of matches that were found (it is the same as
  // values.size() ).
  // For example if '+foo=1,yes,on +foo=5,no,off' was provided on the command
  // line and the following code was executed:
  //
  //| string foo_values[$]
  //| initial begin
  //|    void'(uvm_cmdline_proc.get_arg_values("+foo=",foo_values));
  //|
  //
  // The foo_values queue would contain two entries.  These entries are shown
  // here:
  //
  //   0 - "1,yes,on"
  //   1 - "5,no,off"
  //
  // Splitting the resultant string is left to user but using the
  // uvm_split_string() function is recommended.

  function int get_arg_values (string match, ref string values[$]);
    int chars = match.len();

    values.delete();
    foreach (m_argv[i]) begin
      if(m_argv[i].len() >= chars) begin
        if(m_argv[i].substr(0,chars-1) == match)
          values.push_back(m_argv[i].substr(chars,m_argv[i].len()-1));
      end
    end
    return values.size();
  endfunction

  // Group: Tool information

  // Function: get_tool_name
  //
  // Returns the simulation tool that is executing the simlation.
  // This is a vendor specific string.

  function string get_tool_name ();
    return dpi_get_tool_name();
  endfunction

  // Function: get_tool_version
  //
  // Returns the version of the simulation tool that is executing the simlation.
  // This is a vendor specific string.

  function string  get_tool_version ();
    return dpi_get_tool_version();
  endfunction

  function new;
    string s;
    string sub;
    int last_uvm_home;
    do begin
      s = dpi_get_next_arg();
      if(s!="") begin
        m_argv.push_back(s);
        if(s[0] == "+") begin
          m_plus_argv.push_back(s);
        end 
        if(s.len() >= 4 && (s[0]=="-" || s[0]=="+")) begin
          sub = s.substr(1,3);
          sub = sub.toupper();
          if(sub == "UVM")
            m_uvm_argv.push_back(s);
        end 
        //treat uvm home special because it has an extra arg
        if(last_uvm_home)
          m_uvm_argv.push_back(s);
        sub = s.toupper();
        if(sub == "-UVMHOME")
          last_uvm_home = 1;
        else
          last_uvm_home = 0;
      end
    end while(s!=""); 
    m_do_factory_settings();
    m_do_config_settings();
  endfunction


  protected function void m_split_string (string str, byte sep, ref string values[$]);
    int s = 0, e = 0;
    values.delete();

    while(e < str.len()) begin
      for(s=e; e<str.len(); ++e)
        if(str[e] == sep) break;
      if(s != e)
        values.push_back(str.substr(s,e-1));
      e++;
    end

  endfunction

  protected function void m_process_type_override(string ovr);
    string split_val[$];
    int replace=1;

    m_split_string(ovr, ",", split_val);

    if(split_val.size() > 3 || split_val.size() < 2) begin
        uvm_report_error("UVM_CMDLINE_PROC", {"Invalid setting for +uvm_set_type_override=", ovr ,", setting must specify <requested_type>,<override_type>[,<replace>]"}, UVM_NONE);
        return;
    end

    // Replace arg is optional. If set, must be 0 or 1
    if(split_val.size() == 3) begin
      if(split_val[2]=="0") replace =  0;
      else if (split_val[2] == "1") replace = 1;
      else begin
        uvm_report_error("UVM_CMDLINE_PROC", {"Invalid replace arg for +uvm_set_type_override=", ovr ," value must be 0 or 1"}, UVM_NONE);
        return;
      end
    end

    uvm_report_info("UVM_CMDLINE_PROC", {"Applying type override from the command line: +uvm_set_type_override=", ovr}, UVM_NONE);
    factory.set_type_override_by_name(split_val[0], split_val[1], replace);
  endfunction

  protected function void m_process_inst_override(string ovr);
    string split_val[$];

    m_split_string(ovr, ",", split_val);

    if(split_val.size() != 3 ) begin
        uvm_report_error("UVM_CMDLINE_PROC", {"Invalid setting for +uvm_set_inst_override=", ovr ,", setting must specify <requested_type>,<override_type>,<instance_path>"}, UVM_NONE);
        return;
    end

    uvm_report_info("UVM_CMDLINE_PROC", {"Applying instance override from the command line: +uvm_set_inst_override=", ovr}, UVM_NONE);
    factory.set_inst_override_by_name(split_val[0], split_val[1], split_val[2]);
  endfunction

  protected function void m_process_config(string cfg, bit is_int);
    uvm_bitstream_t v=0;
    string split_val[$];

    m_split_string(cfg, ",", split_val);
    if(split_val.size() == 1) begin
      uvm_report_error("UVM_CMDLINE_PROC", {"Invalid +uvm_set_config command\"", cfg ,"\" missing field and value: component is \"", split_val[0], "\""}, UVM_NONE);
      return;
    end

    if(split_val.size() == 2) begin
      uvm_report_error("UVM_CMDLINE_PROC", {"Invalid +uvm_set_config command\"", cfg ,"\" missing value: component is \"", split_val[0], "\"  field is \"", split_val[1], "\""}, UVM_NONE);
      return;
    end

    if(split_val.size() > 3) begin
      uvm_report_error("UVM_CMDLINE_PROC", $sformatf("Invalid +uvm_set_config command\"%s\" : expected only 3 fields (component, field and value).", cfg), UVM_NONE);
      return;
    end
 
    if(is_int) begin
      if(split_val[2].len() > 2) begin
        string base, extval;
        base = split_val[2].substr(0,1);
        extval = split_val[2].substr(2,split_val[2].len()-1); 
        case(base)
          "'b" : 
            v = extval.atobin();
          "0b" : 
            v = extval.atobin();
          "'o" :
            v = extval.atooct();
          "'d" :
            v = extval.atoi();
          "'h" :
            v = extval.atohex();
          "'x" :
            v = extval.atohex();
          "0x" :
            v = extval.atohex();
          default :
            v = split_val[2].atoi();
        endcase
      end
      else begin
        v = split_val[2].atoi();
      end
      uvm_report_info("UVM_CMDLINE_PROC", {"Applying config setting from the command line: +uvm_set_config_int=", cfg}, UVM_NONE);
      uvm_top.set_config_int(split_val[0], split_val[1], v);
    end
    else begin
      uvm_report_info("UVM_CMDLINE_PROC", {"Applying config setting from the command line: +uvm_set_config_string=", cfg}, UVM_NONE);
      uvm_top.set_config_string(split_val[0], split_val[1], split_val[2]);
    end 

  endfunction

  protected function void m_do_factory_settings();
    string args[$];

    void'(get_arg_matches("/^\\+[Uu][Vv][Mm]_[Ss][Ee][Tt]_[Ii][Nn][Ss][Tt]_[Oo][Vv][Ee][Rr][Rr][Ii][Dd][Ee]=/",args));
    foreach(args[i]) begin
      m_process_inst_override(args[i].substr(23, args[i].len()-1));
    end
    void'(get_arg_matches("/^\\+[Uu][Vv][Mm]_[Ss][Ee][Tt]_[Tt][Yy][Pp][Ee]_[Oo][Vv][Ee][Rr][Rr][Ii][Dd][Ee]=/",args));
    foreach(args[i]) begin
      m_process_type_override(args[i].substr(23, args[i].len()-1));
    end
  endfunction

  protected function void m_do_config_settings();
    string args[$];

    void'(get_arg_matches("/^\\+[Uu][Vv][Mm]_[Ss][Ee][Tt]_[Cc][Oo][Nn][Ff][Ii][Gg]_[Ii][Nn][Tt]=/",args));
    foreach(args[i]) begin
      m_process_config(args[i].substr(20, args[i].len()-1), 1);
    end
    void'(get_arg_matches("/^\\+[Uu][Vv][Mm]_[Ss][Ee][Tt]_[Cc][Oo][Nn][Ff][Ii][Gg]_[Ss][Tt][Rr][Ii][Nn][Gg]=/",args));
    foreach(args[i]) begin
      m_process_config(args[i].substr(23, args[i].len()-1), 0);
    end
  endfunction

endclass

// Group: Built-in UVM Aware Command Line Arguments
//
// Variable: +UVM_TESTNAME
// ~+UVM_TESTNAME=<class name>~ allows the user to specify which uvm_test (or
// uvm_component) should be created via the factory and cycled through the UVM phases.
// If multiple of these settings are provided, the first occurrence is used and a warning
// is issued for subsequent settings.  For example:
//
//| <sim command> +UVM_TESTNAME=read_modify_write_test
//
// Variable: +UVM_VERBOSITY
// ~+UVM_VERBOSITY=<verbosity>~ allows the user to specify the initial verbosity 
// for all components.  If multiple of these settings are provided, the first occurrence
// is used and a warning is issued for subsequent settings.  For example:
//
//| <sim command> +UVM_VERBOSITY=UVM_HIGH
//
// Variable: +uvm_set_verbosity
// ~+uvm_set_verbosity=<comp>,<verbosity>,<phase>~ and
// ~+uvm_set_verbosity=<comp>,<verbosity>,time,<time>~ allow the users to manipulate the
// verbosity of specific components at specific phases (and times during the "run" phases)
// of the simulation.  If a user wishes to affect the verbosity for the build() phase of
// components, +UVM_VERBOSITY should be used.  Settings for non-"run" phases are executed
// in order of occurrence on the command line.  Settings for "run" phases (times) are
// sorted by time and then executed in order of occurrence for settings of the same time.
// For example:
//
//| <sim command> +uvm_set_verbosity=uvm_test_top.env0.agent1.*,UVM_FULL,time,800
//
// Variable: +uvm_set_id_verbosity
// ~+uvm_set_id_verbosity=<comp>,<id>,<verbosity>,<phase>~ and
// ~+uvm_set_id_verbosity=<comp>,<id>,<verbosity>,time,<time>~ allow the users to manipulate the
// verbosity of specific IDs for given components at specific phases (and times during the "run" phases)
// of the simulation.  This is similar to ~+uvm_set_verbosity=~ with the added ability to
// target specific message IDs.  These settings are applied AFTER the ~+uvm_set_verbosity=~ have
// been applied since these settings are more specific in nature.  For example:
//
//| <sim command> +uvm_set_id_verbosity=uvm_test_top.*,PERF_REP,UVM_FULL,time,2000
//
// Variable: +uvm_set_action
// ~+uvm_set_action=<comp>,<id>,<severity>,<action>~ provides the equivalent of
// various uvm_report_object::set_report_*_action APIs.  The special keyword, 
// <underscore>ALL<underscore>,
// can be provided for both/either the <id> and/or <severity> arguments.  The
// action can be UVM_NO_ACTION or a | separated list of the other UVM message
// actions.  For example:
//
//| <sim command> +uvm_set_action=uvm_test_top.env0.*,_ALL_,UVM_ERROR,UVM_NO_ACTION
//
// Variable: +uvm_set_severity
// ~+uvm_set_severity=<comp>,<id>,<current severity>,<new severity>~ provides the
// equivalent of the various uvm_report_object::set_report_*_ovrd_severity APIs. The
// special keyword, <underscore>ALL<underscore>, can be provided for both/either the <id> and/or
// <current severity> arguments.  For example:
//
//| <sim command> +uvm_set_severity=uvm_test_top.env0.*,BAD_CRC,UVM_ERROR,UVM_WARNING
//
// Variable: +uvm_timeout
// ~+uvm_timeout=<timeout>,<overridable>~ allows users to change the global timeout of the UVM
// framework.  The <overridable> argument ('0' or '1') specifies whether user code can subsequently
// change this value.  If set to '0' and the user code tries to change the global timeout value, an
// warning message will be generated.
//
//| <sim command> +uvm_timeout=200000,0
//
// Variable: +uvm_max_quit_count
// ~+uvm_max_quit_count=<count>,<overridable>~ allows users to change max quit count for the report
// server.  The <overridable> argument ('0' or '1') specifies whether user code can subsequently
// change this value.  If set to '0' and the user code tries to change the max quit count value, an
// warning message will be generated.
//
//| <sim command> +uvm_max_quit_count=5,0
//
// Variable: +uvm_set_config_int, +uvm_set_config_string
// ~+uvm_set_config_int=<comp>,<field>,<value>~ and
// ~+uvm_set_config_string=<comp>,<field>,<value>~ work like their
// procedural counterparts: set_config_int() and set_config_string(). For
// the value of int config settings, 'b (0b), 'o, 'd, 'h ('x or 0x) 
// as the first two characters of the value are treated as base specifiers
// for interpreting the base of the number. Size specifiers are not used
// since SystemVerilog does not allow size specifiers in string to
// value conversions.  For example:
//
//| <sim command> +uvm_set_config_int=uvm_test_top.soc_env,mode,5
//
// No equivalent of set_config_object() exists since no way exists to pass an
// uvm_object into the simulation via the command line.
//
// Variable: +uvm_set_inst_override, +uvm_set_type_override
// ~+uvm_set_inst_override=<req_type>,<override_type>,<full_inst_path>~ and
// ~+uvm_set_type_override=<req_type>,<override_type>[,<replace>]~ work
// like the name based overrides in the factory: 
// factory.set_inst_override_by_name() and factory.set_type_override_by_name().
// For uvm_set_type_override, the third argument is 0 or 1 (the default is
// 1 if this argument is left off); this argument specifies whether previous
// type overrides for the type should be replaced.  For example:
//
//| <sim command> +uvm_set_type_override=eth_packet,short_eth_packet
//

uvm_cmdline_processor uvm_cmdline_proc = uvm_cmdline_processor::get();

// Import DPI functions used by the interface to generate the
// lists.

import "DPI-C" function string dpi_get_next_arg_c ();
function string dpi_get_next_arg();
  return dpi_get_next_arg_c();
endfunction

import "DPI-C" function string dpi_get_tool_name_c ();
function string dpi_get_tool_name();
  return dpi_get_tool_name_c();
endfunction

import "DPI-C" function string dpi_get_tool_version_c ();
function string dpi_get_tool_version();
  return dpi_get_tool_version_c();
endfunction

import "DPI-C" function chandle dpi_regcomp(string regex);
import "DPI-C" function int dpi_regexec(chandle preg, string str);
import "DPI-C" function void dpi_regfree(chandle preg);

`endif //UVM_CMDLINE_PROC_PKG_SV
// Command line parsing to set verbosity at the end of each phase

class uvm_cmd_line_verb extends uvm_object;

  uvm_verbosity verb;
  int exec_time;

  function new(string name = "");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(uvm_cmd_line_verb)
    `uvm_field_enum(uvm_verbosity, verb, UVM_ALL_ON)
    `uvm_field_int(exec_time, UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end

endclass

class uvm_cmd_line_verb_settings extends uvm_object;

  string wait_ph_name;
  uvm_cmd_line_verb settings[$];

  function new(string name = "");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(uvm_cmd_line_verb_settings)
    `uvm_field_string(wait_ph_name, UVM_ALL_ON)
    `uvm_field_queue_object(settings, UVM_ALL_ON)
  `uvm_object_utils_end

endclass

class uvm_cmdline_mngr extends uvm_component;

  protected bit m_debug_on;

  protected uvm_tdb_report_server otrs;

  protected string all_settings[$];
  protected uvm_cmd_line_verb_settings connect_settings;
  protected uvm_cmd_line_verb_settings end_of_elaboration_settings;
  protected uvm_cmd_line_verb_settings start_of_simulation_settings;
  protected uvm_cmd_line_verb_settings run_settings;
  protected uvm_cmd_line_verb_settings extract_settings;
  protected uvm_cmd_line_verb_settings check_settings;
  protected uvm_cmd_line_verb_settings report_settings;

  `uvm_component_utils_begin(uvm_cmdline_mngr)
    `uvm_field_queue_string(all_settings, UVM_ALL_ON)
    `uvm_field_object(connect_settings, UVM_ALL_ON)
    `uvm_field_object(end_of_elaboration_settings, UVM_ALL_ON)
    `uvm_field_object(start_of_simulation_settings, UVM_ALL_ON)
    `uvm_field_object(run_settings, UVM_ALL_ON)
    `uvm_field_object(extract_settings, UVM_ALL_ON)
    `uvm_field_object(check_settings, UVM_ALL_ON)
    `uvm_field_object(report_settings, UVM_ALL_ON)
  `uvm_component_utils_end

  static protected uvm_cmdline_mngr cmdline_mngr;

  function new (string name, uvm_component parent); 
    string tmp_q[$];
    super.new(name, parent); 
    // get the report server
    otrs = uvm_tdb_report_server::get();
    // connect, waits for build
    connect_settings = new("connect");
    connect_settings.wait_ph_name = "build";
    // end_of_elaboration, waits for connect
    end_of_elaboration_settings = new("end_of_elaboration");
    end_of_elaboration_settings.wait_ph_name = "connect";
    // start_of_simulation, waits for end_of_elaboration
    start_of_simulation_settings = new("start_of_simulation");
    start_of_simulation_settings.wait_ph_name = "end_of_elaboration";
    // run, waits for start_of_simulation and the time
    run_settings = new("run");
    run_settings.wait_ph_name = "start_of_simulation";
    // extract, waits for run
    extract_settings = new("extract");
    extract_settings.wait_ph_name = "run";
    // check, waits for extract
    check_settings = new("check");
    check_settings.wait_ph_name = "extract";
    // report, waits for check
    report_settings = new("report");
    report_settings.wait_ph_name = "check";
    // Get debug flag
    if(uvm_cmdline_proc.get_arg_values("+__cmd_line_verb_debug", tmp_q)) begin
      otrs.report(UVM_INFO, "", get_type_name(), "Enabling command line processor debug", 
        UVM_NONE, "", "", uvm_top);
      m_debug_on = 1;
    end
    process_cmd_line();
  endfunction

  static function uvm_cmdline_mngr get_inst();
    if (cmdline_mngr == null)
      cmdline_mngr = uvm_cmdline_mngr::type_id::create("cmdline_mngr", uvm_top);
    return cmdline_mngr;
  endfunction

  protected function void m_split_string (string str, byte sep, ref string values[$]);
    int s = 0, e = 0;
    values.delete();
    while(e < str.len()) begin
      for(s=e; e<str.len(); ++e)
        if(str[e] == sep) break;
      if(s != e)
        values.push_back(str.substr(s,e-1));
      e++;
    end
  endfunction

  function bit check_phase(string phase);
    if(phase inside {"connect", "end_of_elaboration", "start_of_simulation", "run",
      "extract", "check", "report"}) begin
      return 1; 
    end
  endfunction

  function bit convert_verb(string verb_str, output uvm_verbosity verb_enum);
    case (verb_str)
      "UVM_NONE" : begin
        verb_enum = UVM_NONE;
        return 1;
      end
      "UVM_LOW" : begin
        verb_enum = UVM_LOW;
        return 1;
      end
      "UVM_MEDIUM" : begin
        verb_enum = UVM_MEDIUM;
        return 1;
      end
      "UVM_HIGH" : begin
        verb_enum = UVM_HIGH;
        return 1;
      end
      "UVM_FULL" : begin
        verb_enum = UVM_FULL;
        return 1;
      end
      default : begin
        uvm_report_warning(get_type_name(), 
          $psprintf("Unkown verbosity found on the command line--%s.  Using UVM_LOW.",
          verb_str), UVM_NONE, "", "");
        verb_enum = UVM_LOW;
        return 0;
      end
    endcase
  endfunction

  function void process_cmd_line();
    string track_mode_settings[$];
    string format_mode_settings[$];
    string file_line_settings[$];
    string comp_name_settings[$];
    string die_delay_settings[$];
    string test_done_verb_settings[$];
    string split_vals[$];
    uvm_table_printer cmd_line_verb_printer = new();
    cmd_line_verb_printer.knobs.name_width = 40;
    cmd_line_verb_printer.knobs.type_width = 0;
    cmd_line_verb_printer.knobs.size_width = 0;
    cmd_line_verb_printer.knobs.value_width = 70;

    // +uvm_set_verbosity section
    void'(uvm_cmdline_proc.get_arg_values("+uvm_set_verbosity=", all_settings));
    // Split each, process, place in the queues.
    //   a. First split (phase) must be connect, end_of_elaboration,
    //   start_of_simulation, run, extract, check or report.
    //   b. Second split (components) is used as-is.
    //   c. Third split (verbosity) must be UVM_NONE, UVM_LOW, UVM_MEDIUM,
    //   UVM_HIGH or UVM_FULL
    //   d. Fourth split--only valid if phase is run--is the time the setting
    //   should take effect.
    for(int i = 0; i < all_settings.size(); i++) begin
      uvm_verbosity tmp_verb;
      uvm_cmd_line_verb verb_entry;
      m_split_string(all_settings[i], ",", split_vals);
      // Invalid number of arguments
      if(split_vals.size() < 3 || split_vals.size() > 4) begin
        uvm_report_info(get_type_name(), 
          $psprintf("Invalid number of arguments supplied.  Setting '%s' ignored.",
          all_settings[i]), UVM_NONE, "", "");
        continue;
      end
      // Invalid phase name
      if(!check_phase(split_vals[0])) begin
        uvm_report_info(get_type_name(), 
          $psprintf("Invalid phase name supplied.  Setting '%s' ignored.",
          all_settings[i]), UVM_NONE, "", "");
        continue;
      end
      // Invalid verbosity
      if(!convert_verb(split_vals[2], tmp_verb)) begin
        uvm_report_info(get_type_name(), 
          $psprintf("Invalid verbosity supplied.  Setting '%s' ignored.",
          all_settings[i]), UVM_NONE, "", "");
        continue;
      end
      verb_entry = new(split_vals[1]);
      //verb_entry.comp_path = split_vals[1];
      verb_entry.verb = tmp_verb;
      if(split_vals.size() == 4) begin
        verb_entry.exec_time = split_vals[3].atoi();
      end
      case (split_vals[0])
        "connect": begin
          connect_settings.settings.push_front(verb_entry);
        end
        "end_of_elaboration": begin
          end_of_elaboration_settings.settings.push_front(verb_entry);
        end
        "start_of_simulation": begin
          start_of_simulation_settings.settings.push_front(verb_entry);
        end
        "run": begin
          int num_run_settings;
          num_run_settings = run_settings.settings.size();
          // Stuff first entry
          if (num_run_settings == 0) begin
            run_settings.settings.push_front(verb_entry);
          end
          // setting exec_time is before 0th exec_time, put it on front
          else if (run_settings.settings[0].exec_time > verb_entry.exec_time) begin
            run_settings.settings.push_front(verb_entry);
          end
          // setting exec_time is after Nth exec_time, put it on back
          else if (run_settings.settings[num_run_settings - 1].exec_time 
            <= verb_entry.exec_time) begin
            run_settings.settings.push_back(verb_entry);
          end
          // the easy ones are out, so find where to stick it
          else begin
            for(int j = 0; j < num_run_settings; j++) begin
              if(run_settings.settings[j].exec_time <= verb_entry.exec_time) begin
                continue;
              end
              else begin
                run_settings.settings = {run_settings.settings[0:j-1], verb_entry,
                  run_settings.settings[j:$]};
              end
            end
          end
        end
        "extract": begin
          extract_settings.settings.push_front(verb_entry);
        end
        "check": begin
          check_settings.settings.push_front(verb_entry);
        end
        "report": begin
          report_settings.settings.push_front(verb_entry);
        end
        default: begin
          uvm_report_error(get_type_name(), $psprintf("Unknown format.  Setting '%s' ignored.",
            all_settings[i]), UVM_NONE, "", "");
        end
      endcase
    end
    if (m_debug_on) begin
      this.print(cmd_line_verb_printer);
    end
    fork
      execute_settings();
    join_none

  endfunction

  task execute_settings();
    execute_phase_settings(connect_settings);
    execute_phase_settings(end_of_elaboration_settings);
    execute_phase_settings(start_of_simulation_settings);
    execute_phase_settings(run_settings);
    execute_phase_settings(extract_settings);
    execute_phase_settings(check_settings);
    execute_phase_settings(report_settings);
  endtask

  task execute_phase_settings(uvm_cmd_line_verb_settings settings);
    uvm_phase m_phase;
    m_phase = uvm_top.get_phase_by_name(settings.wait_ph_name);
    m_phase.wait_done();
    uvm_report_info(get_type_name(), 
      $psprintf("%s() phase done.  %0d %s() phase settings to apply.",
      settings.wait_ph_name, settings.settings.size(), settings.get_name()), 
      UVM_NONE, "", "");
    for (int i = 0; i < settings.settings.size(); i++) begin
      uvm_component comp_q[$];
      uvm_top.find_all(settings.settings[i].get_name(), comp_q, uvm_test_top);
      if(settings.get_name() == "run") begin
        if (settings.settings[i].exec_time != 0) begin
          int cur_time;
          cur_time = $time;
          #(settings.settings[i].exec_time - cur_time);
        end
      end
      uvm_report_info(get_type_name(),
        $psprintf("%s() phase setting of %s being applied to %0d components ('%s').", 
        settings.get_name(), settings.settings[i].verb.name(), comp_q.size(), 
        settings.settings[i].get_name()), UVM_NONE, "", "");
      for (int j = 0; j < comp_q.size(); j++) begin
        if(m_debug_on) begin
          $display("  [%6d] %s", j, comp_q[j].get_full_name());
        end
        comp_q[j].set_report_verbosity_level(settings.settings[i].verb);
      end
    end
  endtask

endclass

uvm_cmdline_mngr cmdline_mngr = uvm_cmdline_mngr::get_inst();

