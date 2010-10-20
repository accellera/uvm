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
// TBD
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

class uvm_root extends uvm_component;

  extern static function uvm_root get();

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
  extern function void check_verbosity();
  extern local task m_stop_process ();
  extern local task m_stop_request (time timeout=0);
  extern local task m_do_stop_all  (uvm_component comp);

  /*NEW*/ // phasing - // GSA TBD cleanup
  /*NEW*/ local mailbox #(uvm_phase_schedule) phase_hopper;
  /*NEW*/ process active_list [uvm_phase_schedule];
  /*NEW*/ local bit phases_all_done;
  /*NEW*/ extern local task phase_runner(); // main phase machine
  /*NEW*/ extern function void initiate_phase(uvm_phase_schedule phase);
  /*NEW*/ extern function void all_done(); // tell phase machine its time to die //TBD local?
  /*NEW*/ extern local function void terminate(uvm_phase_schedule phase);
  /*NEW*/ extern local function void print_active_phases();
  /*NEW*/ extern function int unsigned active_list_size(); // TBD local
   
  local  event      m_stop_request_e;


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

/*NEW*/ // There are macros (see macros/uvm_phase_defines.svh) to help repetitive declarations
/*NEW*/ // These both declare and instantiate the phase default imp class. If you are doing
/*NEW*/ // one manually for your own custom phase, use the following template:
/*NEW*/ //
/*NEW*/ // 1. extend the appropriate base class for your phase type
/*NEW*/ //        class uvm_PHASE_phase extends uvm_task_phase("PHASE","uvm");
/*NEW*/ //        class uvm_PHASE_phase extends uvm_topdown_phase("PHASE","uvm");
/*NEW*/ //        class uvm_PHASE_phase extends uvm_bottomup_phase("PHASE","uvm");
/*NEW*/ //
/*NEW*/ // 2. implement your exec_task or exec_func method:
/*NEW*/ //          task void exec_task(uvm_component comp, uvm_phase_schedule schedule);
/*NEW*/ //          function void exec_func(uvm_component comp, uvm_phase_schedule schedule);
/*NEW*/ //
/*NEW*/ // 3. the default ones simply call the related method on the component:
/*NEW*/ //            comp.PHASE();
/*NEW*/ //
/*NEW*/ // 4. after declaring your phase singleton class, instantiate one for global use:
/*NEW*/ //        uvm_``PHASE``_phase uvm_``PHASE``_ph = new();
/*NEW*/ //
/*NEW*/ // Note that the macros and template above are specific to UVM builtin phases.
/*NEW*/ // User custom phases should use a vendor string other than "uvm" and instantiate
/*NEW*/ // the singleton class in their own package with a prefix other than uvm_.
/*NEW*/ 
/*NEW*/ `uvm_builtin_topdown_phase(build)
/*NEW*/ `uvm_builtin_bottomup_phase(connect)
/*NEW*/ `uvm_builtin_bottomup_phase(end_of_elaboration)
/*NEW*/ `uvm_builtin_bottomup_phase(start_of_simulation)
/*NEW*/ 
/*NEW*/ `uvm_builtin_task_phase(run)
/*NEW*/ 
/*NEW*/ `uvm_builtin_task_phase(pre_reset)
/*NEW*/ `uvm_builtin_task_phase(reset)
/*NEW*/ `uvm_builtin_task_phase(post_reset)
/*NEW*/ `uvm_builtin_task_phase(pre_configure)
/*NEW*/ `uvm_builtin_task_phase(configure)
/*NEW*/ `uvm_builtin_task_phase(post_configure)
/*NEW*/ `uvm_builtin_task_phase(pre_main)
/*NEW*/ `uvm_builtin_task_phase(main)
/*NEW*/ `uvm_builtin_task_phase(post_main)
/*NEW*/ `uvm_builtin_task_phase(pre_shutdown)
/*NEW*/ `uvm_builtin_task_phase(shutdown)
/*NEW*/ `uvm_builtin_task_phase(post_shutdown)
/*NEW*/ 
/*NEW*/ `uvm_builtin_bottomup_phase(extract)
/*NEW*/ `uvm_builtin_bottomup_phase(check)
/*NEW*/ `uvm_builtin_bottomup_phase(report)
/*NEW*/ `uvm_builtin_topdown_phase(finalize)
/*NEW*/ 
/*NEW*/ 
/*NEW*/ 
/*NEW*/ //----------------------------------------------------------------------
/*NEW*/ // global list of named domain schedules which link the above phases
/*NEW*/ //----------------------------------------------------------------------
/*NEW*/ 
/*NEW*/ uvm_phase_schedule uvm_phase_domains[string];


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

  check_verbosity();

  report_header();
  print_enabled=0;

  /*NEW*/ // construct phase schedules for the common domain and default uvm runtime domain
  /*NEW*/
  /*NEW*/ // the "common" domain is common to all uvm_component instances
  /*NEW*/ // - it is a linear list of phases as follows:
  /*NEW*/ uvm_phase_domains["common"] = new("common");
  /*NEW*/ uvm_phase_domains["common"].add_phase(uvm_build_ph);
  /*NEW*/ uvm_phase_domains["common"].add_phase(uvm_connect_ph);
  /*NEW*/ uvm_phase_domains["common"].add_phase(uvm_end_of_elaboration_ph);
  /*NEW*/ uvm_phase_domains["common"].add_phase(uvm_start_of_simulation_ph);
  /*NEW*/ uvm_phase_domains["common"].add_phase(uvm_run_ph);
  /*NEW*/ uvm_phase_domains["common"].add_phase(uvm_extract_ph);
  /*NEW*/ uvm_phase_domains["common"].add_phase(uvm_check_ph);
  /*NEW*/ uvm_phase_domains["common"].add_phase(uvm_report_ph);
  /*NEW*/ uvm_phase_domains["common"].add_phase(uvm_finalize_ph);
  /*NEW*/
  /*NEW*/ // the "uvm" domain is the default instance of the uvm runtime task phases
  /*NEW*/ // - components must subscribe to it (or to a copy of it) by calling set_domain()
  /*NEW*/ // - it is a linear list of task phases as follows:
  /*NEW*/ uvm_phase_domains["uvm"] = new("uvm");
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_pre_reset_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_reset_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_post_reset_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_pre_configure_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_configure_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_post_configure_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_pre_main_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_main_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_post_main_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_pre_shutdown_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_shutdown_ph);
  /*NEW*/ uvm_phase_domains["uvm"].add_phase(uvm_post_shutdown_ph);
  /*NEW*/
  /*NEW*/ // the "uvm" domain is integrated hierarchically within the "common" domain
  /*NEW*/ // - it appears in parallel to the common "run" phase
  /*NEW*/ //uvm_phase_domains["common"].add_schedule(uvm_phase_domains["uvm"],"uvm",
  /*NEW*/ // TBD once jumping code in       .with_phase(uvm_phase_domains["common"].find("run")));
  /*NEW*/ begin :DEBUG_TBD_DELETE_ME
  /*NEW*/   $display("");$display("Phase Schedule Debug (GSA TBD REMOVE)");
  /*NEW*/   uvm_phase_domains["common"].bfs(); uvm_phase_domains["common"].print();
  /*NEW*/   $display();
  /*NEW*/ end
  /*NEW*/
  /*NEW*/ // initialize phasing machine
  /*NEW*/ phase_hopper = new();
  /*NEW*/ phases_all_done = 0;

endfunction


// check_verbosity
// ---------------

function void uvm_root::check_verbosity();

  string s;
  int plusarg;
  string msg;
  int verbosity= UVM_MEDIUM;

  case(1)
    $value$plusargs("UVM_VERBOSITY=%s", s) > 0 : plusarg = 1;
    $value$plusargs("uvm_verbosity=%s", s) > 0 : plusarg = 1;
    $value$plusargs("VERBOSITY=%s", s)     > 0 : plusarg = 1;
    $value$plusargs("verbosity=%s", s)     > 0 : plusarg = 1;
    default                                    : plusarg = 0;
  endcase

  if(plusarg == 1) begin
    case(s.toupper())
      "UVM_NONE"    : verbosity = UVM_NONE;
      "NONE"        : verbosity = UVM_NONE;
      "UVM_LOW"     : verbosity = UVM_LOW;
      "LOW"         : verbosity = UVM_LOW;
      "LO"          : verbosity = UVM_LOW;
      "UVM_MEDIUM"  : verbosity = UVM_MEDIUM;
      "UVM_MED"     : verbosity = UVM_MEDIUM;
      "MEDIUM"      : verbosity = UVM_MEDIUM;
      "MED"         : verbosity = UVM_MEDIUM;
      "UVM_HIGH"    : verbosity = UVM_HIGH;
      "UVM_HI"      : verbosity = UVM_HIGH;
      "HIGH"        : verbosity = UVM_HIGH;
      "HI"          : verbosity = UVM_HIGH;
      "UVM_FULL"    : verbosity = UVM_FULL;
      "FULL"        : verbosity = UVM_FULL;
      "UVM_DEBUG"   : verbosity = UVM_DEBUG;
      "DEBUG"       : verbosity = UVM_DEBUG;
      default       : begin
                        verbosity = s.atoi();
                        if(verbosity == 0) begin
                          verbosity = UVM_MEDIUM;
                          $sformat(msg, "illegal verbosity value, using default of %0d",
                                   UVM_MEDIUM);
                         uvm_report_warning("verbosity", msg, UVM_NONE);
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

  uvm_factory factory = uvm_factory::get();
  bit testname_plusarg;
  string msg;
  uvm_component uvm_test_top;

  /*NEW*/ process phase_runner_proc; // store thread forked below for final cleanup

  testname_plusarg = 0;

  // plusarg overrides argument
  if ($value$plusargs("UVM_TESTNAME=%s", test_name))
    testname_plusarg = 1;

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
          {"No components instantiated. You must instantiate",
           " at least one component before calling run_test. To run",
           " a test, use +UVM_TESTNAME or supply the test name in",
           " the argument to run_test(). Exiting simulation."}, UVM_NONE);
    return;
  end

  uvm_report_info("RNTST", {"Running test ",test_name, "..."}, UVM_LOW);

  /*NEW*/ // phase runner, isolated from calling process
  /*NEW*/ fork
  /*NEW*/   begin
  /*NEW*/     // spawn the phase runner task
  /*NEW*/     phase_runner_proc = process::self();
  /*NEW*/     phase_runner();
  /*NEW*/   end
  /*NEW*/ join_none
  /*NEW*/
  /*NEW*/ // initiate phasing by starting the first phase in the common domain
  /*NEW*/ #0; // let the phase runner start
  /*NEW*/ void'(phase_hopper.try_put(uvm_phase_domains["common"]));
  /*NEW*/
  /*NEW*/ // wait for all phasing to be completed
  /*NEW*/ // - blocks until phases_all_done == 1
  /*NEW*/ // - phases_all_done is set to 1 by the global_all_done() function
  /*NEW*/ // - this is called at the end of the global_stop_request process or will
  /*NEW*/ //   be called by a phase schedule when there are no more phases in the
  /*NEW*/ //   active phase list and the current phase has no successors
  /*NEW*/ wait (phases_all_done == 1);
  /*NEW*/ uvm_report_info("PHDONE","** phasing all done **", UVM_DEBUG);
  /*NEW*/
  /*NEW*/ // clean up after ourselves
  /*NEW*/ phase_runner_proc.kill();

  report_summarize();

  if (finish_on_completion) begin
    // forking allows current delta to complete
    fork
      $finish;
    join_none
  end

endtask


/*NEW*/ //--------------------------------------------------------------------
/*NEW*/ // Task: phase_runner
/*NEW*/ //
/*NEW*/ // This task contains the top-level process that owns all the phase
/*NEW*/ // processes.  By hosting the phase processes here we avoid problems
/*NEW*/ // associated with phase processes related as parents/children
/*NEW*/ //--------------------------------------------------------------------
/*NEW*/ task uvm_root::phase_runner(); // GSA TBD cleanup
/*NEW*/   forever begin
/*NEW*/     uvm_phase_schedule phase;
/*NEW*/     process proc;
/*NEW*/     phase_hopper.get(phase);
/*NEW*/     fork
/*NEW*/       begin
/*NEW*/         proc = process::self();
/*NEW*/         phase.execute();
/*NEW*/       end
/*NEW*/     join_none
/*NEW*/     active_list[phase] = proc;
/*NEW*/     #0;  // let the process start running
/*NEW*/   end
/*NEW*/ endtask
/*NEW*/ 
/*NEW*/ //--------------------------------------------------------------------
/*NEW*/ // initiate_phase
/*NEW*/ //--------------------------------------------------------------------
/*NEW*/ function void uvm_root::initiate_phase(uvm_phase_schedule phase);
/*NEW*/   void'(phase_hopper.try_put(phase));
/*NEW*/  endfunction
/*NEW*/ 
/*NEW*/ //--------------------------------------------------------------------
/*NEW*/ // all_done
/*NEW*/ // signal to the run_test process that it's time to end phasing
/*NEW*/ //--------------------------------------------------------------------
/*NEW*/ function void uvm_root::all_done(); // GSA TBD cleanup
/*NEW*/   phases_all_done = 1;
/*NEW*/ endfunction


/*NEW*/  //--------------------------------------------------------------------
/*NEW*/  // terminate
/*NEW*/  // terminate a phase buy removing it from the active list
/*NEW*/  //--------------------------------------------------------------------
/*NEW*/  function void uvm_root::terminate(uvm_phase_schedule phase); // GSA TBD cleanup
/*NEW*/    if(!active_list.exists(phase)) begin
/*NEW*/      uvm_report_fatal("PHBADTERM",$psprintf("terminate(%s) - phase is not in active list", phase.get_name()));
/*NEW*/      return;
/*NEW*/    end
/*NEW*/    active_list.delete(phase);
/*NEW*/  endfunction


/*NEW*/  //--------------------------------------------------------------------
/*NEW*/  // print_active_phases
/*NEW*/  // print the phases in the active list
/*NEW*/  //--------------------------------------------------------------------
/*NEW*/  function void uvm_root::print_active_phases(); // GSA TBD cleanup
/*NEW*/    string s;
/*NEW*/    s = "active phases:";
/*NEW*/    foreach (active_list[p]) begin
/*NEW*/      uvm_phase_state_t state;
/*NEW*/      state = p.get_state();
/*NEW*/      s = $psprintf("%s %s[%s]", s, p.get_name(), phase_state_string[state]);
/*NEW*/    end
/*NEW*/    uvm_report_info("PHPRACT",s);
/*NEW*/  endfunction


/*NEW*/  //--------------------------------------------------------------------
/*NEW*/  // active_list_size
/*NEW*/  // return the number of phases currently in the active list
/*NEW*/  //--------------------------------------------------------------------
/*NEW*/  function int unsigned uvm_root::active_list_size(); // GSA TBD cleanup
/*NEW*/    return active_list.size();
/*NEW*/  endfunction



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
  uvm_report_fatal("DEV","TBD in uvm_root::m_stop_request() needs coded");
  //TBD if (m_curr_phase == null || !m_curr_phase.is_task()) begin
  //TBD   uvm_report_warning("STPNA",
  //TBD     $psprintf("Stop-request has no effect outside non-time-consuming phases%s%s",
  //TBD               "current phase is ",m_curr_phase==null?
  //TBD               "none (not started":m_curr_phase.get_name()), UVM_NONE);
  //TBD   return;
  //TBD end
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
        #timeout uvm_report_warning("STPTO","TBD cannot resolve m_curr_phase.get_name() yet");
        //TBD #timeout uvm_report_warning("STPTO",
        //TBD  $psprintf("Stop-request timeout of %0t expired. Stopping phase '%0s'",
        //TBD                    timeout, m_curr_phase.get_name()), UVM_NONE);
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
      #timeout uvm_report_warning("STPTO","TBD cannot resolve m_curr_phase.get_name() yet");
      //TBD #timeout uvm_report_warning("STPTO",
      //TBD  $psprintf("Stop-request timeout of %0t expired. Stopping phase '%0s'",
      //TBD                    timeout, m_curr_phase.get_name()), UVM_NONE);
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
      comp.stop("TBD"); // TBD (m_curr_phase.get_name());
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


`endif //UVM_ROOT_SVH
