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

`ifndef UVM_ROOT_SVH
`define UVM_ROOT_SVH

`define UVM_DEFAULT_TIMEOUT 9200s

//------------------------------------------------------------------------------
//
// CLASS: uvm_root
//
// The ~uvm_root~ class serves as the implicit top-level and phase controller for
// all UVM components. Users do not directly instantiate ~uvm_root~. The UVM 
// automatically creates a single instance of <uvm_root> that users can
// access via the global (uvm_pkg-scope) variable, ~uvm_top~. 
// 
// (see uvm_ref_root.gif)
// 
// The ~uvm_top~ instance of ~uvm_root~ plays several key roles in the UVM.
// 
// Implicit top-level - The ~uvm_top~ serves as an implicit top-level component.
// Any component whose parent is specified as NULL becomes a child of ~uvm_top~. 
// Thus, all UVM components in simulation are descendants of ~uvm_top~.
//
// Phase control - ~uvm_top~ manages the phasing for all components.
// There are eight phases predefined in every component: build, connect,
// end_of_elaboration, start_of_simulation, run, extract, check, and
// report. Of these, only the run phase is a task. All others are
// functions. UVM's flexible phasing mechanism allows users to insert
// any number of custom function and task-based phases.
// See <run_test>, <insert_phase>, and <stop_request>, and others.
//
// Search - Use ~uvm_top~ to search for components based on their
// hierarchical name. See <find> and <find_all>.
//
// Report configuration - Use ~uvm_top~ to globally configure
// report verbosity, log files, and actions. For example,
// ~uvm_top.set_report_verbosity_level_hier(UVM_FULL)~ would set
// full verbosity for all components in simulation.
//
// Global reporter - Because ~uvm_top~ is globally accessible (in uvm_pkg
// scope), UVM's reporting mechanism is accessible from anywhere
// outside ~uvm_component~, such as in modules and sequences.
// See <uvm_report_error>, <uvm_report_warning>, and other global
// methods.
//
//------------------------------------------------------------------------------

typedef class uvm_test_done_objection;
typedef class uvm_cmdline_processor;

class uvm_root extends uvm_component;

  extern static function uvm_root get();

  uvm_cmdline_processor clp;

  // Task: run_test
  //
  // Phases all components through all registered phases. If the optional
  // test_name argument is provided, or if a command-line plusarg,
  // +UVM_TESTNAME=TEST_NAME, is found, then the specified component is created
  // just prior to phasing. The test may contain new verification components or
  // the entire testbench, in which case the test and testbench can be chosen from
  // the command line without forcing recompilation. If the global (package)
  // variable, finish_on_completion, is set, then $finish is called after
  // phasing completes.

  extern virtual task run_test (string test_name="");


  // Function- run_global_phase
  //
  // Note: all phasing should be started via run_test. This method is used to
  // run through (~upto~=0) or up to (~upto~=1) the given ~phase~. If null, then
  // all remaining phases will be run, effectively completing simulation.

  extern task run_global_phase (uvm_phase phase=null, bit upto=0);


  // Function- run_global_func_phase
  //
  // Note: all phasing should be started via run_test. This method is used to
  // run through (~upto~=0) or up to (~upto~=1) the given ~phase~. If null, then
  // all remaining phases will be run, effectively completing simulation.

  extern function void run_global_func_phase (uvm_phase phase=null, bit upto=0);


  // Function: stop_request
  //
  // Calling this function triggers the process of shutting down the currently
  // running task-based phase. This process involves calling all components'
  // stop tasks for those components whose enable_stop_interrupt bit is set.
  // Once all stop tasks return, or once the optional global_stop_timeout
  // expires, all components' kill method is called, effectively ending the
  // current phase. The uvm_top will then begin execution of the next phase,
  // if any.

  extern function void stop_request();

  
  // Function: in_stop_request
  //
  // This function returns 1 if a stop request is currently active, and 0
  // otherwise.

  extern function bit in_stop_request();


  // Function: insert_phase
  //
  // Inserts a new phase given by new_phase ~after~ the existing phase given by
  // exist_phase. The uvm_top maintains a queue of phases executed in
  // consecutive order. If exist_phase is null, then new_phase is inserted at
  // the head of the queue, i.e., it becomes the first phase.

  extern function void  insert_phase (uvm_phase new_phase,
                                      uvm_phase exist_phase);


  // Function: find

  extern function uvm_component find (string comp_match);

  // Function: find_all
  //
  // Returns the component handle (find) or list of components handles
  // (find_all) matching a given string. The string may contain the wildcards,
  // * and ?. Strings beginning with '.' are absolute path names. If optional
  // comp arg is provided, then search begins from that component down
  // (default=all components).

  extern function void find_all (string comp_match,
                                 ref uvm_component comps[$],
                                 input uvm_component comp=null);

  // Function: get_current_phase
  //
  // Returns the handle of the currently executing phase.

  extern function uvm_phase get_current_phase ();


  // Function: get_phase_by_name
  //
  // Returns the handle of the phase having the given ~name~.

  extern function uvm_phase get_phase_by_name (string name);


  virtual function string get_type_name(); return "uvm_root"; endfunction


  // Variable: phase_timeout

  time phase_timeout = 0;


  // Variable: stop_timeout
  //
  // These set watchdog timers for task-based phases and stop tasks. You can not
  // disable the timeouts. When set to 0, a timeout of the maximum time possible
  // is applied. A timeout at this value usually indicates a problem with your
  // testbench. You should lower the timeout to prevent "never-ending"
  // simulations. 

  time stop_timeout = 0;


  // Variable: enable_print_topology
  //
  // If set, then the entire testbench topology is printed just after completion
  // of the end_of_elaboration phase.

  bit  enable_print_topology = 0;


  // Variable: finish_on_completion
  //
  // If set, then run_test will call $finish after all phases are executed. 


  bit  finish_on_completion = 1;


  // PRIVATE members

  extern `_protected function new ();
  extern function void build();
  extern local function void m_check_set_verbs();
  extern local function void m_do_timeout_settings();
  extern local function void m_do_factory_settings();
  extern local function void m_process_inst_override(string ovr);
  extern local function void m_process_type_override(string ovr);
  extern local function void m_do_config_settings();
  extern local function void m_do_max_quit_settings();
  extern local function void m_do_dump_args();
  extern local function void m_process_config(string cfg, bit is_int);
  extern function void check_verbosity();
  extern local function void m_do_phase (uvm_component comp, uvm_phase phase);
  extern local task m_stop_process ();
  extern local task m_stop_request (time timeout=0);
  extern local task m_do_stop_all  (uvm_component comp);
  extern local function void m_reset_phase(uvm_component comp,
                                           uvm_phase phase=null);
  extern local function uvm_phase m_get_phase_master(uvm_phase phase, bit set=0);

  local  uvm_phase  m_phase_master[uvm_phase];
  local  uvm_phase  m_phase_q[uvm_phase];
  local  uvm_phase  m_first_phase = null;
  local  uvm_phase  m_last_phase = null;
  local  event      m_stop_request_e;


  uvm_phase m_curr_phase = null;
  static local uvm_root m_inst;

  // For communicating all objections dropped.
  bit m_objections_outstanding = 0;
  bit m_in_stop_request = 0;
  bit m_executing_stop_processes = 0;

  extern virtual task all_dropped (uvm_objection objection, 
           uvm_object source_obj, string description, int count);
  extern virtual function void raised (uvm_objection objection, 
           uvm_object source_obj, string description, int count);
  extern function uvm_test_done_objection test_done_objection();
  extern function void print_topology  (uvm_printer printer=null);

  // Need to create objection watcher processes from uvm_root because
  // simulators may not allow processes to be created by static initializers,
  // so the process cannot go in the objection class.
  local uvm_objection m_objection_watcher_list[$];
  extern function void m_objection_scheduler();
  extern function void m_create_objection_watcher(uvm_objection objection);
endclass


// Class- uvm_root_report_handler
//

class uvm_root_report_handler extends uvm_report_handler;

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

    if(name == "")
      name = "reporter";

    super.report(severity, name, id, message, verbosity_level, filename, line, client);

  endfunction 

endclass

//------------------------------------------------------------------------------
// 
// Class - uvm_*_phase (predefined phases)
//
//------------------------------------------------------------------------------

`uvm_phase_func_decl(build,1)
`uvm_phase_func_decl(connect,0)
`uvm_phase_func_decl(end_of_elaboration,0)
`uvm_phase_func_decl(start_of_simulation,0)
`uvm_phase_task_decl(run,0)
`uvm_phase_func_decl(extract,0)
`uvm_phase_func_decl(check,0)
`uvm_phase_func_decl(report,0)

build_phase               #(uvm_component) build_ph;
connect_phase             #(uvm_component) connect_ph;
end_of_elaboration_phase  #(uvm_component) end_of_elaboration_ph;
start_of_simulation_phase #(uvm_component) start_of_simulation_ph;
run_phase                 #(uvm_component) run_ph;
extract_phase             #(uvm_component) extract_ph;
check_phase               #(uvm_component) check_ph;
report_phase              #(uvm_component) report_ph;

//-----------------------------------------------------------------------------
//
// IMPLEMENTATION
//
//-----------------------------------------------------------------------------

// get
// ---

function uvm_root uvm_root::get();
  if (m_inst == null)
    m_inst = new();
  return m_inst;
endfunction


// new
// ---

function uvm_root::new();

  uvm_root_report_handler rh;

  super.new("__top__", null);

  rh = new;
  set_report_handler(rh);

  clp = uvm_cmdline_processor::get_inst();

  report_header();
  print_enabled=0;
  build_ph = new;
  connect_ph = new;
  end_of_elaboration_ph = new;
  start_of_simulation_ph = new;
  run_ph = new;
  extract_ph = new;
  check_ph = new;
  report_ph = new;
  insert_phase(build_ph,              null);
  insert_phase(connect_ph,            build_ph);
  insert_phase(end_of_elaboration_ph, connect_ph);
  insert_phase(start_of_simulation_ph,end_of_elaboration_ph);
  insert_phase(run_ph,                start_of_simulation_ph);
  insert_phase(extract_ph,            run_ph);
  insert_phase(check_ph,              extract_ph);
  insert_phase(report_ph,             check_ph);

endfunction

// build
// -----

function void uvm_root::build();

  super.build();

  check_verbosity();

  m_check_set_verbs();
  m_do_timeout_settings();
  m_do_factory_settings();
  m_do_config_settings();
  m_do_max_quit_settings();
  m_do_dump_args();

endfunction

// m_check_set_verbs
// -----------------

function void uvm_root::m_check_set_verbs();
  string set_verbosity_settings[$];
  string split_vals[$];
  uvm_verbosity tmp_verb;

  // Retrieve them all into set_verbosity_settings
  void'(clp.get_arg_values("+uvm_set_verbosity=", set_verbosity_settings));

  for(int i = 0; i < set_verbosity_settings.size(); i++) begin
    uvm_split_string(set_verbosity_settings[i], ",", split_vals);
    if(split_vals.size() < 4 || split_vals.size() > 5) begin
      uvm_report_warning("INVLCMDARGS", 
        $psprintf("Invalid number of arguments found on the command line for setting '+uvm_set_verbosity=%s'.  Setting ignored.",
        set_verbosity_settings[i]), UVM_NONE, "", "");
    end
    // Invalid verbosity
    if(!clp.m_convert_verb(split_vals[2], tmp_verb)) begin
      uvm_report_warning("INVLCMDVERB", 
        $psprintf("Invalid verbosity found on the command line for setting '%s'.", 
        set_verbosity_settings[i]), UVM_NONE, "", "");
    end
  end
endfunction

// m_do_timeout_settings
// ---------------------

function void uvm_root::m_do_timeout_settings();
  string timeout_settings[$];
  string timeout;
  string split_timeout[$];
  int timeout_count;
  int timeout_int;
  timeout_count = clp.get_arg_values("+UVM_TIMEOUT=", timeout_settings);
  if (timeout_count ==  0)
    return;
  else begin
    timeout = timeout_settings[0];
    if (timeout_count > 1) begin
      string timeout_list;
      string sep;
      for (int i = 0; i < timeout_settings.size(); i++) begin
        if (i != 0)
          sep = "; ";
        timeout_list = {timeout_list, sep, timeout_settings[i]};
      end
      uvm_report_warning("MULTTIMOUT", 
        $psprintf("Multiple (%0d) +UVM_TIMEOUT arguments provided on the command line.  '%s' will be used.  Provided list: %s.", 
        timeout_count, timeout, timeout_list), UVM_NONE);
    end
    uvm_report_info("TIMOUTSET",
      $psprintf("'+UVM_TIMEOUT=%s' provided on the command line is being applied.", timeout), UVM_NONE);
    uvm_split_string(timeout, ",", split_timeout);
    timeout_int = split_timeout[0].atoi();
    case(split_timeout[1])
      "YES"   : set_global_timeout(timeout_int, 1);
      "NO"    : set_global_timeout(timeout_int, 0);
      default : set_global_timeout(timeout_int, 1);
    endcase
  end
endfunction

// m_do_factory_settings
// ---------------------

function void uvm_root::m_do_factory_settings();
  string args[$];

  void'(clp.get_arg_matches("/^\\+[Uu][Vv][Mm]_[Ss][Ee][Tt]_[Ii][Nn][Ss][Tt]_[Oo][Vv][Ee][Rr][Rr][Ii][Dd][Ee]=/",args));
  foreach(args[i]) begin
    m_process_inst_override(args[i].substr(23, args[i].len()-1));
  end
  void'(clp.get_arg_matches("/^\\+[Uu][Vv][Mm]_[Ss][Ee][Tt]_[Tt][Yy][Pp][Ee]_[Oo][Vv][Ee][Rr][Rr][Ii][Dd][Ee]=/",args));
  foreach(args[i]) begin
    m_process_type_override(args[i].substr(23, args[i].len()-1));
  end
endfunction

// m_process_inst_override
// -----------------------

function void uvm_root::m_process_inst_override(string ovr);
  string split_val[$];
  uvm_factory fact = uvm_factory::get();

  uvm_split_string(ovr, ",", split_val);

  if(split_val.size() != 3 ) begin
    uvm_report_error("UVM_CMDLINE_PROC", {"Invalid setting for +uvm_set_inst_override=", ovr,
      ", setting must specify <requested_type>,<override_type>,<instance_path>"}, UVM_NONE);
    return;
  end

  uvm_report_info("INSTOVR", {"Applying instance override from the command line: +uvm_set_inst_override=", ovr}, UVM_NONE);
  fact.set_inst_override_by_name(split_val[0], split_val[1], split_val[2]);
endfunction

// m_process_type_override
// -----------------------

function void uvm_root::m_process_type_override(string ovr);
  string split_val[$];
  int replace=1;
  uvm_factory fact = uvm_factory::get();

  uvm_split_string(ovr, ",", split_val);

  if(split_val.size() > 3 || split_val.size() < 2) begin
    uvm_report_error("UVM_CMDLINE_PROC", {"Invalid setting for +uvm_set_type_override=", ovr,
      ", setting must specify <requested_type>,<override_type>[,<replace>]"}, UVM_NONE);
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
  fact.set_type_override_by_name(split_val[0], split_val[1], replace);
endfunction

// m_process_config
// ----------------

function void uvm_root::m_process_config(string cfg, bit is_int);
  uvm_bitstream_t v=0;
  string split_val[$];
  uvm_root m_uvm_top = uvm_root::get();

  uvm_split_string(cfg, ",", split_val);
  if(split_val.size() == 1) begin
    uvm_report_error("UVM_CMDLINE_PROC", {"Invalid +uvm_set_config command\"", cfg,
      "\" missing field and value: component is \"", split_val[0], "\""}, UVM_NONE);
    return;
  end

  if(split_val.size() == 2) begin
    uvm_report_error("UVM_CMDLINE_PROC", {"Invalid +uvm_set_config command\"", cfg,
      "\" missing value: component is \"", split_val[0], "\"  field is \"", split_val[1], "\""}, UVM_NONE);
    return;
  end

  if(split_val.size() > 3) begin
    uvm_report_error("UVM_CMDLINE_PROC", 
      $sformatf("Invalid +uvm_set_config command\"%s\" : expected only 3 fields (component, field and value).", cfg), UVM_NONE);
    return;
  end
 
  if(is_int) begin
    if(split_val[2].len() > 2) begin
      string base, extval;
      base = split_val[2].substr(0,1);
      extval = split_val[2].substr(2,split_val[2].len()-1); 
      case(base)
        "'b" : v = extval.atobin();
        "0b" : v = extval.atobin();
        "'o" : v = extval.atooct();
        "'d" : v = extval.atoi();
        "'h" : v = extval.atohex();
        "'x" : v = extval.atohex();
        "0x" : v = extval.atohex();
        default : v = split_val[2].atoi();
      endcase
    end
    else begin
      v = split_val[2].atoi();
    end
    uvm_report_info("UVM_CMDLINE_PROC", {"Applying config setting from the command line: +uvm_set_config_int=", cfg}, UVM_NONE);
    m_uvm_top.set_config_int(split_val[0], split_val[1], v);
  end
  else begin
    uvm_report_info("UVM_CMDLINE_PROC", {"Applying config setting from the command line: +uvm_set_config_string=", cfg}, UVM_NONE);
    m_uvm_top.set_config_string(split_val[0], split_val[1], split_val[2]);
  end 

endfunction

// m_do_config_settings
// --------------------

function void uvm_root::m_do_config_settings();
  string args[$];

  void'(clp.get_arg_matches("/^\\+[Uu][Vv][Mm]_[Ss][Ee][Tt]_[Cc][Oo][Nn][Ff][Ii][Gg]_[Ii][Nn][Tt]=/",args));
  foreach(args[i]) begin
    m_process_config(args[i].substr(20, args[i].len()-1), 1);
  end
  void'(clp.get_arg_matches("/^\\+[Uu][Vv][Mm]_[Ss][Ee][Tt]_[Cc][Oo][Nn][Ff][Ii][Gg]_[Ss][Tt][Rr][Ii][Nn][Gg]=/",args));
  foreach(args[i]) begin
    m_process_config(args[i].substr(23, args[i].len()-1), 0);
  end
endfunction

// m_do_max_quit_settings
// ----------------------

function void uvm_root::m_do_max_quit_settings();
  uvm_report_server srvr;
  string max_quit_settings[$];
  int max_quit_count;
  string max_quit;
  string split_max_quit[$];
  int max_quit_int;
  srvr = get_report_server();
  max_quit_count = clp.get_arg_values("+UVM_MAX_QUIT_COUNT=", max_quit_settings);
  if (max_quit_count ==  0)
    return;
  else begin
    max_quit = max_quit_settings[0];
    if (max_quit_count > 1) begin
      string max_quit_list;
      string sep;
      for (int i = 0; i < max_quit_settings.size(); i++) begin
        if (i != 0)
          sep = "; ";
        max_quit_list = {max_quit_list, sep, max_quit_settings[i]};
      end
      uvm_report_warning("MULTMAXQUIT", 
        $psprintf("Multiple (%0d) +UVM_MAX_QUIT_COUNT arguments provided on the command line.  '%s' will be used.  Provided list: %s.", 
        max_quit_count, max_quit, max_quit_list), UVM_NONE);
    end
    uvm_report_info("MAXQUITSET",
      $psprintf("'+UVM_MAX_QUIT_COUNT=%s' provided on the command line is being applied.", max_quit), UVM_NONE);
    uvm_split_string(max_quit, ",", split_max_quit);
    max_quit_int = split_max_quit[0].atoi();
    case(split_max_quit[1])
      "YES"   : srvr.set_max_quit_count(max_quit_int, 1);
      "NO"    : srvr.set_max_quit_count(max_quit_int, 0);
      default : srvr.set_max_quit_count(max_quit_int, 1);
    endcase
  end
endfunction

// m_do_dump_args
// --------------

function void uvm_root::m_do_dump_args();
  string dump_args[$];
  string all_args[$];
  string out_string;
  if(clp.get_arg_matches("+UVM_DUMP_CMDLINE_ARGS", dump_args)) begin
    void'(clp.get_args(all_args));
    for (int i = 0; i < all_args.size(); i++) begin
      if (all_args[i] == "__-f__")
        continue;
      out_string = {out_string, all_args[i], " "};
    end
    uvm_report_info("DUMPARGS", out_string, UVM_NONE);
  end
endfunction

// check_verbosity
// ---------------

function void uvm_root::check_verbosity();

  string verb_string;
  string verb_settings[$];
  int verb_count;
  int plusarg;
  int verbosity = UVM_MEDIUM;

  // Retrieve the verbosities provided on the command line.
  verb_count = clp.get_arg_values("+UVM_VERBOSITY=", verb_settings);

  // If none provided, provide message about the default being used.
  //if (verb_count == 0)
  //  uvm_report_info("DEFVERB", ("No verbosity specified on the command line.  Using the default: UVM_MEDIUM"), UVM_NONE);

  // If at least one, use the first.
  if (verb_count > 0) begin
    verb_string = verb_settings[0];
    plusarg = 1;
  end

  // If more than one, provide the warning stating how many, which one will
  // be used and the complete list.
  if (verb_count > 1) begin
    string verb_list;
    string sep;
    for (int i = 0; i < verb_settings.size(); i++) begin
      if (i != 0)
        sep = ", ";
      verb_list = {verb_list, sep, verb_settings[i]};
    end
    uvm_report_warning("MULTVERB", 
      $psprintf("Multiple (%0d) +UVM_VERBOSITY arguments provided on the command line.  '%s' will be used.  Provided list: %s.", verb_count, verb_string, verb_list), UVM_NONE);
  end

  if(plusarg == 1) begin
    case(verb_string)
      "UVM_NONE"    : verbosity = UVM_NONE;
      "NONE"        : verbosity = UVM_NONE;
      "UVM_LOW"     : verbosity = UVM_LOW;
      "LOW"         : verbosity = UVM_LOW;
      "UVM_MEDIUM"  : verbosity = UVM_MEDIUM;
      "MEDIUM"      : verbosity = UVM_MEDIUM;
      "UVM_HIGH"    : verbosity = UVM_HIGH;
      "HIGH"        : verbosity = UVM_HIGH;
      "UVM_FULL"    : verbosity = UVM_FULL;
      "FULL"        : verbosity = UVM_FULL;
      "UVM_DEBUG"   : verbosity = UVM_DEBUG;
      "DEBUG"       : verbosity = UVM_DEBUG;
      default       : begin
        verbosity = verb_string.atoi();
        if(verbosity > 0)
          uvm_report_info("NSTVERB", $psprintf("Non-standard verbosity value, using provided '%0d'.", verbosity), UVM_NONE);
        if(verbosity == 0) begin
          verbosity = UVM_MEDIUM;
          uvm_report_warning("ILLVERB", "Illegal verbosity value, using default of UVM_MEDIUM.", UVM_NONE);
        end
      end
    endcase
  end

  set_report_verbosity_level_hier(verbosity);

endfunction


//------------------------------------------------------------------------------

// Variable: uvm_top
//
// This is the top-level that governs phase execution and provides component
// search interface. See <uvm_root> for more information.

const uvm_root uvm_top = uvm_root::get();

// for backward compatibility
const uvm_root _global_reporter = uvm_root::get();


//------------------------------------------------------------------------------
//
// Primary Simulation Entry Points
//
//------------------------------------------------------------------------------

// run_test
// --------

task uvm_root::run_test(string test_name="");

  uvm_factory factory;
  bit testname_plusarg;
  int test_name_count;
  string test_names[$];
  string msg;
  uvm_component uvm_test_top;

  factory = uvm_factory::get();

  testname_plusarg = 0;

  // Set up the process that watches objections to handle the all_dropped
  // situation to be safe from killing threads. Needs to be done in run_test
  // since it needs to be in an initial block to fork a process.
  m_objection_scheduler();

  // Retrieve the test names provided on the command line.  Command line
  // overrides the argument.
  test_name_count = clp.get_arg_values("+UVM_TESTNAME=", test_names);

  // If at least one, use first in queue.
  if (test_name_count > 0) begin
    test_name = test_names[0];
    testname_plusarg = 1;
  end

  // If multiple, provided the warning giving the number, which one will be
  // used and the complete list.
  if (test_name_count > 1) begin
    string test_list;
    string sep;
    for (int i = 0; i < test_names.size(); i++) begin
      if (i != 0)
        sep = ", ";
      test_list = {test_list, sep, test_names[i]};
    end
    uvm_report_warning("MULTTST", 
      $psprintf("Multiple (%0d) +UVM_TESTNAME arguments provided on the command line.  '%s' will be used.  Provided list: %s.", test_name_count, test_name, test_list), UVM_NONE);
  end

  // if test now defined, create it using common factory
  if (test_name != "") begin
    if(m_children.exists("uvm_test_top")) begin
      uvm_report_fatal("TTINST",
          "An uvm_test_top already exists via a previous call to run_test", UVM_NONE);
      #0; // forces shutdown because $finish is forked
    end
    $cast(uvm_test_top, factory.create_component_by_name(test_name,
          "uvm_test_top", "uvm_test_top", null));

    if (uvm_test_top == null) begin
      msg = testname_plusarg ? "command line +UVM_TESTNAME=": "call to run_test(";
      uvm_report_fatal("INVTST",
          {"Requested test from ",msg, test_name, ") not found." }, UVM_NONE);
    end
  end

  if (m_children.num() == 0) begin
    uvm_report_fatal("NOCOMP",
          {"No components instantiated. You must either instantiate",
           " at least one component before calling run_test or use",
           " run_test to do so. To run a test using run_test,",
           " use +UVM_TESTNAME or supply the test name in",
           " the argument to run_test(). Exiting simulation."}, UVM_NONE);
    return;
  end

  uvm_report_info("RNTST", {"Running test ",test_name, "..."}, UVM_LOW);

  fork 
    // isolated from calling process
    run_global_phase();
  join_any

  report_summarize();

  if (finish_on_completion) begin
    // forking allows current delta to complete
    fork
      $finish;
    join_none
  end

endtask


// m_reset_phase
// -------------

function void uvm_root::m_reset_phase(uvm_component comp, uvm_phase phase=null);
  string name;

  if (comp.get_first_child(name))
    do
      this.m_reset_phase(comp.get_child(name));
    while (comp.get_next_child(name));

  comp.m_curr_phase=phase;

endfunction


// m_get_phase_master
// ------------------

function uvm_phase uvm_root::m_get_phase_master(uvm_phase phase, bit set=0);
  // Returns the master phase if one hase been initialized. Otherwise, finds
  // a master by name. If none is found then the master is initialized
  // to itself.
  if(phase == null) return phase;
  if(m_phase_master.exists(phase)) return m_phase_master[phase];
  foreach(m_phase_master[i])
    if(m_phase_master[i].get_name() == phase.get_name()) begin
      if(set == 1) m_phase_master[phase] = m_phase_master[i];
      return m_phase_master[i];
    end

  if(set == 1) m_phase_master[phase] = phase;
  return phase;
endfunction


//------------------------------------------------------------------------------
// Phase control
//------------------------------------------------------------------------------


// run_global_func_phase
// ---------------------

// Limitations on usage:
//
// Given phase can not be ahead of any un-executed task-based phases.
//
// The #0 after triggering the phase's start and done events can not occur
// in a function. Any processes waiting on a function-based phase to start
// or finish will not resume until all phases up through the given phase
// have executed.

function void uvm_root::run_global_func_phase(uvm_phase phase=null, bit upto=0);

  bit run_all_phases;

  //Get the master phase in case the input phase is an alias.
  phase = m_get_phase_master(phase);

  if (phase != null) begin
    if (!m_phase_q.exists(phase)) begin
      uvm_report_fatal("PHNTFD", {"Phase %0s not registered.",phase.get_name()}, UVM_NONE); 
      return;
    end
    if (upto) begin
      uvm_phase prev_ph;
      if (phase == m_first_phase)
        return;
      prev_ph = m_first_phase;
      while (phase != m_phase_q[prev_ph])
        prev_ph = m_phase_q[prev_ph];
      phase = prev_ph;
    end
    // make sure we've something to do
    if (phase.is_done()) begin
      uvm_report_warning("PHDONE", {"Phase ", phase.get_name()," already executed."}, UVM_NONE);
      return;
    end

  end
  else begin
    run_all_phases = 1;
    phase = m_last_phase;
  end

  while (m_curr_phase != phase) begin

    if (m_curr_phase == null)
      m_curr_phase = m_first_phase;
    else
      m_curr_phase = m_phase_q[m_curr_phase];

    if (m_curr_phase.is_task()) begin
        uvm_report_fatal("TASKPH",
          {"Phase ", m_curr_phase.get_name(),
          " is a time-consuming method. Cannot be run using",
          " uvm_root::run_global_phase_func()"}, UVM_NONE);
        return;
    end

    // Trigger phase's in_progress event.
    m_curr_phase.m_set_in_progress();
    // #0; can't call this in a func

    uvm_report_info("STARTPH",
      $psprintf("STARTING PHASE %0s",m_curr_phase.get_name()),int'(UVM_FULL)+1);

      m_do_phase(this,m_curr_phase);

    uvm_report_info("ENDPH",
      $psprintf("ENDING PHASE %0s",m_curr_phase.get_name()),int'(UVM_FULL)+1);

    // Trigger phase's done event.
    m_curr_phase.m_set_done();
    // #0; can't call this in a func

    // If error occurred during elaboration, exit with FATAL.
    if (m_curr_phase == end_of_elaboration_ph) begin
      uvm_report_server srvr;
      srvr = get_report_server();
      if(srvr.get_severity_count(UVM_ERROR) > 0) begin
        uvm_report_fatal("uvm", "elaboration errors", UVM_NONE);
        //#0; // $finish is called in a forked process in uvm_report_object::die.
            // this forces that process to start, preventing us from continuing
        return;
      end

      if (enable_print_topology)
        print_topology();
    end

    // if next phase is end_of_elab, the resolve all connections
    if (m_phase_q[m_curr_phase] == end_of_elaboration_ph)
      do_resolve_bindings();

    if (run_all_phases)
      phase = m_last_phase;

  end

endfunction



// run_global_phase
// ----------------

task uvm_root::run_global_phase(uvm_phase phase=null, bit upto=0);

  static semaphore sema=new(1);

  time timeout;
  bit run_all_phases;

  sema.get();

  //Get the master phase in case the input phase is an alias.
  phase = m_get_phase_master(phase);

  if (phase != null) begin
    if (!m_phase_q.exists(phase)) begin
      uvm_report_fatal("PHNTFD", {"Phase ", phase.get_name()," not registered."}, UVM_NONE);
      return;
    end
    // if only running up to the given phase, run through previous phase 
    if (upto) begin
      uvm_phase prev_ph;
      if (phase == m_first_phase)
        return;
      prev_ph = m_first_phase;
      while (phase != m_phase_q[prev_ph])
        prev_ph = m_phase_q[prev_ph];
      phase = prev_ph;
    end
    // make sure we've something to do
    if (phase.is_done()) begin
      uvm_report_warning("PHDONE", {"Phase ", phase.get_name()," already executed."}, UVM_NONE);
      return;
    end
      
  end
  else begin
    run_all_phases = 1;
    phase = m_last_phase;
  end


  // MAIN LOOP: Executes all phases from the current phase
  // through the phase given in the argument. If 'phase' is null,
  // will run through all phases, even those that may have been added in
  // phases that have yet to run.

  while (m_curr_phase != phase) begin

    if (m_curr_phase == null)
      m_curr_phase = m_first_phase;
    else
      m_curr_phase = m_phase_q[m_curr_phase];
    // Trigger phase's in_progress event.
    // The #0 allows any waiting processes to resume before we continue.
    m_curr_phase.m_set_in_progress();
    #0;

    uvm_report_info("STARTPH",
      $psprintf("STARTING PHASE %0s",m_curr_phase.get_name()),int'(UVM_FULL)+1);

    // TASK-based phase
    if (m_curr_phase.is_task()) begin
      // Before starting a phase see if a timeout has been configured, and
      // if so, use it. Doing this just before the timeout is used allows
      // the timeout to be configured in preceeding function based phases.
      void'(get_config_int("timeout", phase_timeout));

      timeout = (phase_timeout==0) ?  `UVM_DEFAULT_TIMEOUT - $time :
                                      phase_timeout;

      `ifdef UVM_USE_ALT_PHASING

        // Disabling named forks is ill-defined for fork-join_any/join_none.
        // The phasing is implemented using both the standard disable-fork
        // mechanism as well as the disable named fork mechanism.
        fork // guard process
        begin

        fork

          // Start an independent process that kills the phase, else the killing
          // stops prematurely at the component that issued the request.
          m_stop_process();

          begin // guard process
            fork
              begin
                #0; // ensures stop_process active before potential stop_request
                m_do_phase(this,m_curr_phase);
                wait fork;
              end
              begin
                #timeout uvm_report_error("TIMOUT",
                      $psprintf("Watchdog timeout of '%0t' expired.", timeout), UVM_NONE);
              end
            join_any
            disable fork;
          end // end guard process

        join_any
        disable fork;

        end
        join // end guard process

      `else // UVM_USE_ALT_PHASING

        fork : task_based_phase
          m_stop_process();
          begin
            #0 m_do_phase(this,m_curr_phase);
            wait fork;
          end
          begin
            #timeout uvm_report_error("TIMOUT",
                $psprintf("Watchdog timeout of '%0t' expired.", timeout), UVM_NONE);
          end
        join_any
        disable task_based_phase;

      `endif // UVM_USE_ALT_PHASING

      if(uvm_test_done.get_objection_total(uvm_root::get()) != 0) begin
        uvm_test_done.uvm_report_warning("OBJOUT", $psprintf("%0d objection(s) are still outstanding", uvm_test_done.get_objection_total(uvm_root::get())));
        uvm_report_info("SHOW_OBJECTIONS",uvm_test_done.convert2string());
      end

    end // if (is_task)

    // FUNCTION-based phase
    else begin
      m_do_phase(this,m_curr_phase);
    end

    uvm_report_info("ENDPH",
      $psprintf("ENDING PHASE %0s",m_curr_phase.get_name()),int'(UVM_FULL)+1);

    // Trigger phase's done event.
    // The #0 allows any waiting processes to resume before we continue.
    m_curr_phase.m_set_done();
    #0;

    // If error occurred during elaboration, exit with FATAL.
    if (m_curr_phase == end_of_elaboration_ph) begin
      uvm_report_server srvr;
      srvr = get_report_server();
      if(srvr.get_severity_count(UVM_ERROR) > 0) begin
        uvm_report_fatal("uvm", "elaboration errors", UVM_NONE);
        #0; // $finish is called in a forked process in uvm_report_object::die.
            // this forces that process to start, preventing us from continuing
      end

      if (enable_print_topology)
        print_topology();
    end

    // if next phase is end_of_elab, the resolve all connections
    if (m_phase_q[m_curr_phase] == end_of_elaboration_ph)
      do_resolve_bindings();

    if (m_curr_phase == report_ph) 
      check_config_usage();
    if (run_all_phases)
      phase = m_last_phase;

  end

  sema.put();

endtask


// m_do_phase
// --------

function void uvm_root::m_do_phase (uvm_component comp, uvm_phase phase);

  // run_global_phase calls this private function for each phase in consecutive
  // order.  If the phase is a function, then all components' functions are
  // called sequentially in top-down or bottom-up order. If the phase is a
  // task, all components' tasks are forked and we return with no waiting.
  // The caller can subsequently call 'wait fork' to wait for the forked
  // tasks to complete.

  uvm_phase curr_phase;
  bit done[string];

  phase = m_get_phase_master(phase);
  curr_phase = comp.m_curr_phase;

  // This while loop is needed in case new componenents are created
  // several phases into a simulation.

  while (curr_phase != phase) begin

    uvm_phase ph;
    done.delete();

    if (curr_phase == null)
      curr_phase = m_first_phase;
    else
      curr_phase = m_phase_q[curr_phase];
    // bottom-up
    if (!curr_phase.is_top_down()) begin
      string name;
      if (comp.get_first_child(name)) begin
        do begin
          this.m_do_phase(comp.get_child(name),curr_phase);
          done[name] = 1;
        end
        while (comp.get_next_child(name));
      end
    end

    uvm_report_info("COMPPH", $psprintf("*** comp %0s (%0s) curr_phase is %0s",
      comp.get_full_name(),comp.get_type_name(),
      curr_phase.get_name()),int'(UVM_FULL)+1);

    if (curr_phase.is_task()) begin
      // We fork here to ensure that do_task_phase, a user-overridable task,
      // does not inadvertently block this process
      fork
        comp.do_task_phase(curr_phase);
      join_none
    end
    else
      comp.do_func_phase(curr_phase);

    // bottom-up 2nd pass: phase newly created components, if any
    if (!curr_phase.is_top_down()) begin

      while (comp.get_num_children() != done.num()) begin
        string name;
        if (comp.get_first_child(name)) begin
          do begin
            if (!done.exists(name)) begin
              this.m_do_phase(comp.get_child(name),curr_phase);
              done[name] = 1;
            end
          end
          while (comp.get_next_child(name));
        end
      end
    end

    // top-down
    else begin
      string name;
      if (comp.get_first_child(name))
        do begin
          this.m_do_phase(comp.get_child(name),curr_phase);
        end
        while (comp.get_next_child(name));
    end

  end
endfunction


// get_current_phase
// -----------------

function uvm_phase uvm_root::get_current_phase();
  return m_curr_phase;
endfunction


//------------------------------------------------------------------------------
// Stopping
//------------------------------------------------------------------------------

// stop_request
// ------------

function void uvm_root::stop_request();
  ->m_stop_request_e;
endfunction


// m_stop_process
// --------------

task uvm_root::m_stop_process();
  @m_stop_request_e;
  m_stop_request(stop_timeout);
endtask

// in_stop_request
// ---------------

function bit uvm_root::in_stop_request();
  return m_in_stop_request;
endfunction

// m_stop_request
// --------------

task uvm_root::m_stop_request(time timeout=0);

  if (timeout == 0)
    timeout = `UVM_DEFAULT_TIMEOUT - $time;

  // stop request valid for running task-based phases only
  if (m_curr_phase == null || !m_curr_phase.is_task()) begin
    uvm_report_warning("STPNA",
      $psprintf("Stop-request has no effect outside non-time-consuming phases%s%s",
                "current phase is ",m_curr_phase==null?
                "none (not started":m_curr_phase.get_name()), UVM_NONE);
    return;
  end
  m_in_stop_request=1;

  // All stop tasks are forked from a single thread so 'wait fork'
  // can be used. We fork the single thread as well so that 'wait fork'
  // does not wait for threads previously started by the caller's thread.

  `ifdef UVM_USE_FPC

  fork begin // guard process
    fork
      begin
        //If objections are outstanding, wait for them to finish first
        wait(m_objections_outstanding==0);
        m_executing_stop_processes = 1;
        m_do_stop_all(this);
        wait fork;
        m_executing_stop_processes = 0;
      end
      begin
        #timeout uvm_report_warning("STPTO",
         $psprintf("Stop-request timeout of %0t expired. Stopping phase '%0s'",
                           timeout, m_curr_phase.get_name()), UVM_NONE);
      end
    join_any
    disable fork;
  end
  join

  `else  // not using FPC

  fork : stop_tasks
    begin
      //If objections are outstanding, wait for them to finish first
      wait(m_objections_outstanding==0);
      m_executing_stop_processes = 1;
      m_do_stop_all(this);
      wait fork;
      m_executing_stop_processes = 0;
    end
    begin
      #timeout uvm_report_warning("STPTO",
       $psprintf("Stop-request timeout of %0t expired. Stopping phase '%0s'",
                         timeout, m_curr_phase.get_name()), UVM_NONE);
    end
  join_any
  disable stop_tasks;

  `endif // UVM_USE_FPC

  // all stop processes have completed, or a timeout has occured
  this.do_kill_all();

  m_in_stop_request=0;
endtask


// m_do_stop_all
// -------------

task uvm_root::m_do_stop_all(uvm_component comp);

  string name;

  // we use an external traversal to ensure all forks are 
  // made from a single threaad.
  if (comp.get_first_child(name))
    do begin
      m_do_stop_all(comp.get_child(name));
    end
    while (comp.get_next_child(name));

  if (comp.enable_stop_interrupt) begin
    fork begin
      comp.stop(m_curr_phase.get_name());
    end
    join_none
  end

endtask


// This objection is used to communicate all objections dropped at the
// root level so that the uvm_top can start the shutdown.

// Function: raised
//
//

function void uvm_root::raised (uvm_objection objection, uvm_object source_obj, 
                              string description, int count);
  if(objection != test_done_objection()) return;
  if (m_executing_stop_processes) begin
    string desc = description == "" ? "" : {" (\"", description, "\") "};
    uvm_report_warning("ILLRAISE", {"An uvm_test_done objection ", desc, "was raised during the execution of component stop processes for the stop_request. The objection is ignored by the stop process."}, UVM_NONE);
  end
  else
    m_objections_outstanding = 1;
endfunction


// Task: all_dropped
//
//

task uvm_root::all_dropped (uvm_objection objection, uvm_object source_obj, 
                          string description, int count);
  if(objection != test_done_objection()) return;
  m_objections_outstanding = 0;
endtask

//------------------------------------------------------------------------------
// Phase Insertion
//------------------------------------------------------------------------------

// insert_phase
// ------------

function void uvm_root::insert_phase(uvm_phase new_phase,
                                     uvm_phase exist_phase);
  uvm_phase exist_ph;
  uvm_phase master_ph;
  string s;

  // Get the phase object that is in charge of a given named phase. Since we
  // are inserting the phase, set the master if not set.
  master_ph = m_get_phase_master(new_phase, 1);
  exist_phase = m_get_phase_master(exist_phase);

  if (build_ph.is_done()) begin
    uvm_report_fatal("PHINST", "Phase insertion after build phase prohibited.", UVM_NONE);
    return;
  end

  if (exist_phase != null && exist_phase.is_done() ||
      exist_phase == null && m_curr_phase != null) begin 
    uvm_report_fatal("PHINST", {"Can not insert a phase at a point that has ",
      "already executed. Current phase is '", m_curr_phase.get_name(),"'."}, UVM_NONE);
    return;
  end

  if (new_phase == null) begin
    uvm_report_fatal("PHNULL", "Phase argument is null.", UVM_NONE);
    return;
  end

  if (exist_phase != null && !m_phase_q.exists(exist_phase)) begin
    //could be an aliased phase. The phase may not exist in the queue, but if
    //the name matches one in the queue then it is a possible alias
    if(get_phase_by_name(exist_phase.get_name()) == null) begin
      uvm_report_fatal("PHNTFD", {"Phase '",exist_phase.get_name(),
                      "' is not registered."}, UVM_NONE);
      return;
    end
  end

  // If the new phase being added is an alias object, add the alias and
  // return.
  if(master_ph != new_phase) begin
    master_ph.add_alias(new_phase, exist_phase);
    return;
  end
  else

  if (m_phase_q.exists(new_phase)) begin
    if ((exist_phase == null && m_first_phase != new_phase) ||
        (exist_phase != null && m_phase_q[exist_phase] != new_phase)) begin
      uvm_report_error("PHDUPL", {"Phase '", new_phase.get_name(),
        "' is already registered in a different order."}, UVM_NONE);
    end
    return;
  end

  new_phase.set_insertion_phase(exist_phase);
  if (exist_phase == null) begin
    m_phase_q[new_phase] = m_first_phase;
    m_first_phase = new_phase;
  end
  else begin
    m_phase_q[new_phase] = m_phase_q[exist_phase];
    m_phase_q[exist_phase] = new_phase;
  end

  if (m_phase_q[new_phase] == null)
    m_last_phase = new_phase;

endfunction


// get_phase_by_name
// -----------------

function uvm_phase uvm_root::get_phase_by_name (string name);
  uvm_phase m_ph;
  foreach (m_phase_q[ph]) begin
    m_ph = ph;
    if(m_ph.get_name() == name) 
      return ph;
  end
  return null;
endfunction


//------------------------------------------------------------------------------
// Component Search & Printing
//------------------------------------------------------------------------------


// find_all
// --------

function void uvm_root::find_all(string comp_match, ref uvm_component comps[$],
                                 input uvm_component comp=null); 
  string name;

  if (comp==null)
    comp = this;

  if (comp.get_first_child(name))
    do begin
      this.find_all(comp_match,comps,comp.get_child(name));
    end
    while (comp.get_next_child(name));
  if (uvm_is_match(comp_match, comp.get_full_name()) &&
       comp.get_name() != "") /* uvm_top */
    comps.push_back(comp);

endfunction


// find
// ----

function uvm_component uvm_root::find (string comp_match);
  uvm_component comp_list[$];

  find_all(comp_match,comp_list);

  if (comp_list.size() > 1)
    uvm_report_warning("MMATCH",
    $psprintf("Found %0d components matching '%s'. Returning first match, %0s.",
              comp_list.size(),comp_match,comp_list[0].get_full_name()), UVM_NONE);

  if (comp_list.size() == 0) begin
    uvm_report_warning("CMPNFD",
      {"Component matching '",comp_match,
       "' was not found in the list of uvm_components"}, UVM_NONE);
    return null;
  end

  return comp_list[0];
endfunction


// print_topology
// --------------

function void uvm_root::print_topology(uvm_printer printer=null);

  string s;

  uvm_report_info("UVMTOP", "UVM testbench topology:", UVM_LOW);

  if (m_children.num()==0) begin
    uvm_report_warning("EMTCOMP", "print_topology - No UVM components to print.", UVM_NONE);
    return;
  end

  if (printer==null)
    printer = uvm_default_printer;

  if (printer.knobs.sprint)
    s = printer.m_string;

  foreach (m_children[c]) begin
    if(m_children[c].print_enabled) begin
      printer.print_object("", m_children[c]);  
      if(printer.knobs.sprint)
        s = {s, printer.m_string};
    end
  end

  printer.m_string = s;

endfunction


function void uvm_root::m_create_objection_watcher(uvm_objection objection);
  m_objection_watcher_list.push_back(objection);
endfunction


function void uvm_root::m_objection_scheduler();
  fork begin
    while(1) begin
      wait(m_objection_watcher_list.size() != 0);
      foreach(m_objection_watcher_list[i]) begin
        automatic uvm_objection obj = m_objection_watcher_list[i];
        fork begin
          obj.m_execute_scheduled_forks();
        end join_none
      end
      `uvm_clear_queue(m_objection_watcher_list);
    end
  end join_none
endfunction

`endif //UVM_ROOT_SVH
