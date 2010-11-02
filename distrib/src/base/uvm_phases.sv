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

`ifndef UVM_PHASES_SVH
`define UVM_PHASES_SVH

//-----------------------------------------------------------------------------+
// UVM1.0 phase scheduling api                                                 |
//-----------------------------------------------------------------------------+
//                                                                             |
// The API described here provides a general purpose testbench phasing         |
// solution, consisting of a phaser machine, traversing a master schedule      |
// graph, which is built by the integrator from one or more instances of       |
// template schedules provided by UVM or by 3rd-party VIP, and which supports  |
// implicit or explicit synchronization, runtime control of threads and jumps. |
//                                                                             |
// Each schedule leaf node refers to a single phase that is compatible with    |
// that VIP's components and which executes the required behavior via a        |
// functor or delegate extending the phase into component context as required. |
// Execution threads are tracked on a per-component basis and various thread   |
// semantics available to allow defined phase control and responsibility.      |
//                                                                             |
//-----------------------------------------------------------------------------+


//----------------------------------------------------------------------
// Class hierarchy:
//----------------------------------------------------------------------
//
// Two separate data class hierarchies are required to represent a phase:
// the phase schedule, which builds a graph of arbitrary serial + parallel
// phase relationships and stores current state as the phaser progresses,
// and the phase implementation which specifies required component behavior
// (by extension into component context if non-default behavior required.)
// There are further implementation-internal classes e.g. uvm_phase_thread.
//
//  +----------+                  +---------+                +-------------+
//  |uvm_object|                  |uvm_graph|                |uvm_component|
//  +----------+                  +---------+                |             |
//       ^                             ^                     |             |
//  +-------------+           +------------------+           |             |
//  |uvm_phase_imp|------1---o|uvm_phase_schedule|----1..*--o|[domains]    |
//  +-------------+\          +-------------------           |             |
//       ^          `-----------------------|---------0..*--o|[overrides]  |
//  +-------------------------------+       |                |             |
//  |uvm_task/topdown/bottomup_phase|      0..*              |             |
//  +-------------------------------+       |                |             |
//       ^                                  |                |             |
//  +--------------+               +----------------+        |             |
//  |uvm_NAME_phase|               |uvm_phase_thread|--0..*-o|[threads]    |
//  +--------------+               +----------------+        +-------------+
//       ^                                                          ^       
//  +-------------------------------------+               +----------------+
//  |uvm_NAME_phase (type T=uvm_component)| . . . . . . . |custom_component|
//  +-------------------------------------+               +----------------+

   typedef class uvm_phase_imp;      // phase implementation
   typedef class uvm_phase_schedule; // phase context and state
   typedef class uvm_phase_thread;   // phase process on a component


//----------------------------------------------------------------------
// Group: type definitions
//----------------------------------------------------------------------

// phase execution type
// --------------------
// This is an attribute of a uvm_phase_imp object. Every phase we define
// has a type. It is used only for information, as the type behavior is
// captured in three derived classes uvm_task/topdown/bottomup_phase.
//
//   TASK:     The phase is a task-based phase, a fork is done for each
//             participating component and so the traversal order is arbitrary
//   TOPDOWN:  The phase is a function phase, components are traversed from
//             top-down, allowing them to add to the component tree as they go
//   BOTTOMUP: The phase is a function phase, components are traversed from
//             the bottom up, allowing roll-up / consolidation functionality.

   typedef enum { UVM_PHASE_TASK,
                  UVM_PHASE_TOPDOWN,
                  UVM_PHASE_BOTTOMUP
                  } uvm_phase_type_t;

   string phase_type_string[uvm_phase_type_t];

   function bit m_initialize_phase_type_string;
     phase_type_string[UVM_PHASE_TASK]    = "forked task";
     phase_type_string[UVM_PHASE_TOPDOWN] = "top-down func";
     phase_type_string[UVM_PHASE_BOTTOMUP]= "bottom-up func";
     return 1;
   endfunction
   bit m_phase_type_string_initialized = m_initialize_phase_type_string();

// phase threading mode
// --------------------
// This is an attribute of a particular component's runtime usage of a phase.
// It's value is set by (1) the overall default, (2) the component can specify
// a default mode, and (3) a phase task can switch thread modes while being run
// (no lasting effect, only affects that thread).
// It is used by (a) the phaser when it spawns tasks, to decide what processes
// to keep track of, and (b) at phase end, to decide what to kill, and
// (c) in jump() operations, to decide what to kill
//
//   PROACTIVE:  An active component which dictates when the phase ends,
//               whenever its phase task returns. It's threads are managed
//               by the phaser and are cleaned up when it returns
//   REACTIVE:   A passive component (e.g. monitor) which does not object to
//               phase end even though it is still looping. It's threads are
//               managed by the phaser and are cleaned up when it returns
//   PERSISTENT: A phase whose main thread and/or forked child threads continue
//               to run after the phase has ended, they are not managed or
//               killed by the phaser, except during a jump operation.

   typedef enum { UVM_PHASE_PROACTIVE,
                  UVM_PHASE_REACTIVE,
                  UVM_PHASE_PERSISTENT
                  } uvm_thread_mode_t;

   string thread_mode_string[uvm_thread_mode_t];

   function bit m_initialize_thread_mode_string;
     thread_mode_string[UVM_PHASE_PROACTIVE]  = "proactive";
     thread_mode_string[UVM_PHASE_REACTIVE]   = "reactive";
     thread_mode_string[UVM_PHASE_PERSISTENT] = "persistent";
     return 1;
   endfunction
   bit m_thread_mode_string_initialized = m_initialize_thread_mode_string();


// schedule phase state
// --------------------
// The set of possible states of a phase. This is an attribute of a schedule
// node in the graph, not of a phase, to maintain independent per-domain state
//
//   DORMANT:   Nothing has happened with the phase in this domain.
//   SCHEDULED: At least one immediate predecessor has completed.
//              Scheduled phases block until all predecessor complete or
//              until a jump is executed.
//   EXECUTING: An executing phase is one where the phase callbacks are
//              being executed. It's process is tracked by the phaser.
//   DONE:      A phase is done after it terminated execution.  Becoming
//              done may enable a waiting successor phase to execute.
//
//    The state transitions occur as follows:
//
//     DORMANT  --> SCHEDULED --> EXECUTING --> DONE --+
//        ^                                            |
//        |          <-- jump_to                       V
//        +--------------------------------------------+

   typedef enum { UVM_PHASE_DORMANT,
                  UVM_PHASE_SCHEDULED,
                  UVM_PHASE_EXECUTING,
                  UVM_PHASE_DONE
                  } uvm_phase_state_t;

   string phase_state_string[uvm_phase_state_t];

   function bit m_initialize_phase_state_string;
     phase_state_string[UVM_PHASE_DORMANT]   = "dormant";
     phase_state_string[UVM_PHASE_SCHEDULED] = "scheduled";
     phase_state_string[UVM_PHASE_EXECUTING] = "executing";
     phase_state_string[UVM_PHASE_DONE]      = "done";
     return 1;
   endfunction
   bit m_phase_state_string_initialized = m_initialize_phase_state_string();

// phase state transition for callbacks
// ------------------------------------
// additional information that may be useful during callbacks

   typedef enum { UVM_COMPLETED = 'h01,   // phase ended normally
                  UVM_FORCED_STOP = 'h02, // phase was forced to terminate
                  UVM_SKIPPED = 'h04,     // phase was in path of a forward jump
                  UVM_RERUN = 'h08        // phase was in path of a backwards jump
                  } uvm_phase_transition_t;




//----------------------------------------------------------------------
// Class: uvm_phase_imp
//----------------------------------------------------------------------
//
// This is the base class which defines a phase's behavior (not state).
// UVM provides default extensions of this class for the standard
// runtime phases. VIP Providers can extend this class to define the
// phase functor for a particular component context as required.
//
// It defines the attributes of the phase, not what state it is in.
// Every schedule node points to a uvm_phase_imp, and calls it's virtual
// task or function methods on each participating component.
// It is the base class for phase functors, for both predefined and
// user-defined phases. Per-component overrides can use a customized imp.
//
// To create custom phases, do not extend uvm_phase_imp directly: see the
// three predefined extended classes below which encapsulate behavior for
// different phase types: task, bottom-up function and top-down function.
//
// Extend the appropriate one of these to create a uvm_YOURNAME_phase class
// (or YOURPREFIX_NAME_phase class) for each phase, containing the default
// implementation of the new phase, which must be a uvm_component-compatible
// delegate, and which may be a null implementation. Instantiate a singleton
// instance of that class for your code to use when a phase handle is required.
// If your custom phase depends on methods that are not in uvm_component, but
// are within an extended class, then extend the base YOURPREFIX_NAME_phase
// class with parameterized component class context as required, to create a
// specialized functor which calls your extended component class methods.
// This scheme ensures compile-safety for your extended component classes while
// providing homogeneous base types for APIs and underlying data structures.

virtual class uvm_phase_imp extends uvm_object;

  string m_name; // name of this phase
  uvm_phase_type_t m_phase_type; // task, topdown func or bottomup func

  // Function: new
  // Create a new phase imp, with a name and a note of its type
  //   name   - name of this phase
  //   type   - task, topdown func or bottomup func
  
  function new(string name, uvm_phase_type_t phase_type);
    super.new();
    m_name = name;
    m_phase_type = phase_type;
  endfunction

  // User-defined callbacks:

  // Function: exec_func
  // Implements the functor/delegate functionality for a function phase type
  //   comp  - the component to execute the functionality upon
  //   phase - the phase schedule that originated this phase call
  
  virtual function void exec_func(uvm_component comp, uvm_phase_schedule phase);
  endfunction

  // Function: exec_task
  // Implements the functor/delegate functionality for a task phase type
  //   comp  - the component to execute the functionality upon
  //   phase - the phase schedule that originated this phase call

  virtual task exec_task(uvm_component comp, uvm_phase_schedule phase);
  endtask

  // Function: phase_started
  // Generic notification function called prior to exec_func()/exec_task()
  //   phase - the phase schedule that originated this phase call

  virtual function void phase_started(uvm_phase_schedule phase);
  endfunction

  // Function: phase_ended
  // Generic notification function called after exec_func()/exec_task()
  //   phase - the phase schedule that originated this phase call

  virtual function void phase_ended(uvm_phase_schedule phase);
  endfunction

  // Internal phase-behavior methods: traverse and execute
  
  // Function: traverse
  // Provides the required component traversal behavior, called by schedule
  // Default is bottomup component traversal - overridden in uvm_topdown_phase
  // Override this if any nonstandard traversal is required

  virtual function void traverse(uvm_component comp, uvm_phase_schedule phase);
    string name;
    if(comp.get_first_child(name))
      do begin
        uvm_component child;
        child = comp.get_child(name);
        traverse(child,phase);
      end while(comp.get_next_child(name));
    if (comp.m_phase_domains.exists(phase.m_parent)) begin
      if (comp.m_phase_imps.exists(this))
        comp.m_phase_imps[this].execute(comp,phase);
      else
        this.execute(comp,phase);
    end
  endfunction

  // Function: execute
  // Provides the required per-component execution flow, called from traverse()
  // Default is for func phase call, overridden in uvm_task_phase class
  // Calls phase_started() / phase_ended() component API to frame the phase call
  // Override this if any nonstandard functor execution is required

  protected virtual function void execute(uvm_component comp,
                                          uvm_phase_schedule phase);
    comp.m_current_phase = phase;
    comp.phase_started(phase);
    exec_func(comp,phase);
    comp.phase_ended(phase);
  endfunction

endclass


//----------------------------------------------------------------------
// Class: uvm_bottomup_phase
//----------------------------------------------------------------------
// Virtual base class for function phases that operate bottom-up.
// The pure virtual function execute() is called for each component.
// This is the default traversal so is included only for naming.

virtual class uvm_bottomup_phase extends uvm_phase_imp;
  function new(string name);
    super.new(name,UVM_PHASE_BOTTOMUP);
  endfunction
endclass


//----------------------------------------------------------------------
// Class: uvm_topdown_phase
//----------------------------------------------------------------------
// Virtual base class for function phases that operate top-down.
// The pure virtual function execute() is called for each component.

virtual class uvm_topdown_phase extends uvm_phase_imp;
  function new(string name);
    super.new(name,UVM_PHASE_TOPDOWN);
  endfunction

  // Function: traverse
  // Provides the required component traversal behavior, called by schedule
  // Default is bottomup component traversal - overridden in uvm_topdown_phase
  // Override this if any nonstandard traversal is required

  virtual function void traverse(uvm_component comp, uvm_phase_schedule phase);
    string name;
    if (comp.m_phase_domains.exists(phase.m_parent)) begin
      if (comp.m_phase_imps.exists(this))
        comp.m_phase_imps[this].execute(comp,phase);
      else
        this.execute(comp,phase);
    end
    if(comp.get_first_child(name))
      do begin
        uvm_component child;
        child = comp.get_child(name);
        traverse(child,phase);
      end while(comp.get_next_child(name));
  endfunction
endclass


//----------------------------------------------------------------------
// Class: uvm_task_phase
//----------------------------------------------------------------------
// Base class for all task phases. exec_task() is forked for each comp
// Completion of exec_task() is a tacit agreement to shutdown.

virtual class uvm_task_phase extends uvm_phase_imp;
  function new(string name);
    super.new(name,UVM_PHASE_TASK);
  endfunction

  // Function: execute
  // Provides the required per-component execution flow, called from traverse()
  // This override to the base uvm_phase_imp is to handle forked task phases
  // Calls phase_started() / phase_ended() component API to frame the phase call
  // Override this if any nonstandard functor execution is required

  protected virtual function void execute(uvm_component comp,
                                          uvm_phase_schedule phase);
    fork
      begin
        uvm_phase_thread thread = new(phase,comp); // store thread process ID
        comp.m_current_phase = phase;
        phase.m_termination_agreement++;
        comp.phase_started(phase); //GSA TBD do this in separate traversal?
        exec_task(comp,phase);
        comp.phase_ended(phase); //GSA TBD do this in separate traversal?
        if( phase.m_termination_agreement > 0)
          phase.m_termination_agreement--;
        thread.cleanup(); // kill thread process, depending on chosen semantic
      end
    join_none
  endfunction
endclass



// Internal class to wrap a process id

class uvm_process;
  process m_process_id;  
  function new(process pid);
    m_process_id = pid;
  endfunction
endclass

//----------------------------------------------------------------------
// Class: uvm_phase_thread
//----------------------------------------------------------------------
// TBD John Rose to port for IUS compatibility
// This is a wrapper around a process handle which serves to associate
// a phase schedule with a component, capturing the process ID of the
// thread that phase is running on that component, together with the
// required thread mode. Also contained are thread maintenance methods.
// Both component and phase schedule classes have a member which lists
// the outstanding threads running on that component, or that phase.
// These are used to determine completeness and execute cleanup semantics
// TBD benchmark the assoc arrays - given that this class holds both
// TBD comp and sched handles, it is possible to use a simpler darray

class uvm_phase_thread extends uvm_process;

  uvm_phase_schedule m_phase;      // the phase this thread was spawned from
  uvm_component m_comp;            // the component this thread is running on
  uvm_thread_mode_t m_thread_mode; // threading semantics in force for this pid

  // Function: new
  // Register a new thread with it's collaborating phase schedule and component
  // nodes. Capture the PID for future tracking and cleanup. Set the default
  // thread semantics from the component.

  function new(uvm_phase_schedule phase, uvm_component comp);
    // process ID of this phase/component thread
    super.new(process::self());
    m_phase = phase;
    m_comp = comp;
    if (m_comp.m_phase_threads.exists(m_phase)) begin // sanity check
      uvm_report_fatal("DUPTHREAD",$sformatf(
        "component %s already has an active phase thread for phase %s",
          m_comp.get_name(), m_phase.get_name()));
    end
    if (m_phase.m_threads.exists(m_comp)) begin // sanity check
      uvm_report_fatal("DUPTHREAD",$sformatf(
        "phase %s already running an active thread on component %s",
          m_phase.get_name(), m_comp.get_name()));
    end
    m_comp.m_phase_threads[m_phase] = this;
    m_phase.m_threads[m_comp] = this;
    m_thread_mode = m_comp.m_phase_thread_mode;
  endfunction

  function void set_thread_mode(uvm_thread_mode_t thread_mode);
    uvm_thread_mode_t prev_thread_mode;
    prev_thread_mode = m_thread_mode;
    m_thread_mode = thread_mode;
  endfunction

  function void cleanup(int forced=0);
    if (m_thread_mode != UVM_PHASE_PERSISTENT || forced) begin
      m_comp.m_phase_threads.delete(m_phase);
      m_phase.m_threads.delete(m_comp);
      m_process_id.kill();
    end
  endfunction

  function int is_active();
    return (m_process_id.status() != process::FINISHED &&
            m_process_id.status != process::KILLED);
  endfunction

  function int is_current_process();
    process pid = process::self();
    return (m_process_id == pid);
  endfunction

endclass




//----------------------------------------------------------------------
// Class: uvm_phase_schedule
//----------------------------------------------------------------------
// This is the base class which defines a phase's context/state (not behavior).
// A schedule is a coherent group of one or mode phase/state nodes linked
// together by an underlying graph structure, allowing arbitrary linear/parallel
// relationships to be specified, and executed by stepping through them in the
// graph order.
// Each schedule node points to a phase and holds the execution state of that
// phase, and has optional links to other nodes for synchronization.
//
// The main build operations are: construct, add phases, and instantiate
// hierarchically within another schedule.

class uvm_phase_schedule extends uvm_graph;

  // data structure linkage
  
  protected string m_schedule_name; // schedule unique name
  uvm_phase_schedule m_parent;      // our 'begin' node [or points 'up' one level]
  uvm_phase_schedule m_sync[];      // schedule instance to which we are synced
  uvm_phase_imp      m_phase;       // phase imp to call when we execute this node

  // current state of this phase node
  
  local uvm_phase_state_t m_state;  // readiness/execution state of this node
  local int m_run_count;            // no of times this phase has executed
  int unsigned m_termination_agreement; // phase-end pseudo-objection //TBD protected
  uvm_phase_thread m_threads[uvm_component];      // all active process threads


  // Group: Construction
  // Schedule Construction API - create schedule and add phases or sub-schedules


  // Function: new
  // Create new schedule structure, ready to add phases, or create new node in schedule
  //
  // Constructing a new schedule creates and returns the begin node which is a
  // special sentinel node with a null phase and no state.
  // A second sentinel node 'end' is created at the same time and
  // is linked to execute after 'begin'. These nodes frame the schedule; they
  // exist only to ensure that arbitrary phase structures added to the schedule
  // have a single entry point and a single exit point.
  // A handle to this 'schedule' node is used for most API operations. Each other
  // node in the schedule has an 'm_parent' handle which points to this node.
  //
  //   name - a name for the new schedule or for the new phase added to an existing one
  //   parent - handle to an existing structure, or null to create a new empty one
  
  extern function new(string name, uvm_phase_schedule parent=null);

  // Function: get_schedule_name
  // Accessor to return the schedule name associated with this schedule
  
  function string get_schedule_name(); return m_schedule_name; endfunction

  // Function: get_phase_name
  // Accessor to return the phase name associated with this schedule node
  
  function string get_phase_name(); return (m_phase) ? m_phase.m_name : ""; endfunction

  // Function: get_run_count
  // Accessor to return the integer number of times this phase has executed
  
  function int get_run_count(); return m_run_count; endfunction

  // Function get_state
  // Accessor to return current state of this phase
  
  function uvm_phase_state_t get_state(); return m_state; endfunction

  // Function: add_phase
  // Build up a schedule structure inserting phase by phase, specifying linkage
  //
  // Phases can be added anywhere, in series or parallel with existing nodes
  //
  //   phase        - handle of singleton derived imp containing actual functor.
  //                  by default the new phase is appended to the schedule
  //   with_phase   - specify to add the new phase in parallel with this one
  //   after_phase  - specify to add the new phase as successor to this one
  //   before_phase - specify to add the new phase as predecessor to this one

  extern function void add_phase(uvm_phase_imp phase,
                                 uvm_phase_schedule with_phase=null,
                                 uvm_phase_schedule after_phase=null,
                                 uvm_phase_schedule before_phase=null);

  // Function: add_schedule
  // Build up schedule structure by adding another schedule flattened within it.
  //
  // Inserts a schedule structure hierarchically within the enclosing schedule's
  // graph. It is essentially flattened graph-wise, but the hierarchy is preserved
  // by the 'm_parent' handles which point to that schedule's begin node.
  //
  //   schedule     - handle of new schedule to insert within this one
  //   with_phase   - specify to add the schedule in parallel with this phase node
  //   after_phase  - specify to add the schedule as successor to this phase node
  //   before_phase - specify to add the schedule as predecessor to this phase node

  extern function void add_schedule(uvm_phase_schedule schedule,
                                    uvm_phase_schedule with_phase=null,
                                    uvm_phase_schedule after_phase=null,
                                    uvm_phase_schedule before_phase=null);

  // Miscellaneous VIP-integrator API - looking up schedules and phases
  
  // Function: find_schedule
  // Locate a phase node with the specified phase name and return its schedule, or null
  //   name - phase name to search for
  
  extern function uvm_phase_schedule find_schedule(string name);

  // Function: find_phase
  // Locate a phase node with the specified phase name and return its phase imp, or null
  //   name - phase name to search for

  extern function uvm_phase_imp find_phase(string name);


  // Group: Synchronization
  // Synchronization API - add soft sync relationships between nodes
  //
  // Summary of usage:
  // target::sync(.source(domain)
  //              [,.phase(phase)[,.with/after/before_phase(phase)]]);
  // target::unsync(.source(domain)
  //                [,.phase(phase)[,.with/after/before_phase(phase)]]);
  //
  // Components in different schedule domains can be phased independently or in sync
  // with each other. An API is provided to specify synchronization rules between any
  // two domains. Synchronization can be done at any of three levels:
  // - the domain's whole phase schedule can be synchronized
  // - a phase can be specified, to sync that phase with a matching counterpart
  // - or a more detailed arbitrary synchronization between any two phases
  // Each kind of synchronization causes the same underlying data structures to
  // be managed. Like other APIs, we use the parameter dot-notation to allow
  // optional parameters and specify relationships using the keywords 'before'
  // to specify a successor, or 'after' to specify a predecessor, or 'with' to
  // specify parallel.
  //
  // When a domain is synced with another domain, all of the matching phases in
  // the two domains get a 'with' relationship between them. Likewise, if a domain
  // is unsynched, all of the matching phases that have a 'with' relationship have
  // the dependency removed. It is possible to sync two domains and then just
  // remove a single phase from the dependency relationship by unsyncing just
  // the one phase.

  // Function: sync
  // Synchonize two domains, fully or partially
  //   target       - handle of target schedule to synchronize this one to
  //   phase        - optional single phase to synchronize, otherwise all
  //   with_phase   - optional different target-domain phase to synchronize with
  //   after_phase  - optional diff target-domain phase to synchronize after
  //   before_phase - optional diff target-domain phase to synchronize before

  extern function void sync(uvm_phase_schedule target,
                            uvm_phase_imp phase=null,
                            uvm_phase_imp with_phase=null,
                            uvm_phase_imp after_phase=null,
                            uvm_phase_imp before_phase=null);

  // Function: unsync
  // Remove synchonization between two domains, fully or partially
  //   target       - handle of target schedule to remove synchronization from
  //   phase        - optional single phase to un-synchronize, otherwise all
  //   with_phase   - optional different target-domain phase to un-synchronize with
  //   after_phase  - optional diff target-domain phase to un-synchronize after
  //   before_phase - optional diff target-domain phase to un-synchronize before

  extern function void unsync(uvm_phase_schedule target,
                              uvm_phase_imp phase=null,
                              uvm_phase_imp with_phase=null,
                              uvm_phase_imp after_phase=null,
                              uvm_phase_imp before_phase=null);

  // Group: Jumping
  // Jumping API - force change of phase forwards or backwards in schedule
  //
  // A phasing domain can execute a jump from its current phase to any other.
  // A jump passes phasing control in the current domain from the current phase
  // to a target phase. There are two kinds of jump scope:
  // - local jump to another phase within the current schedule, back- or forwards
  // - global jump of all domains together, either to a point in the master
  //   schedule outwith the current schedule, or by calling jump_all()
  // A jump preserves the existing soft synchronization, so the domain that is
  // ahead of schedule relative to another synchronized domain, as a result of
  // a jump in either domain, will await the domain that is behind schedule.
  //
  // Note: a jump out of the local schedule causes other schedules that have
  // the jump node in their schedule to jump as well. In some cases, it is
  // desirable to jump to a local phase in the schedule but to have all
  // schedules that share that phase to jump as well. In that situation, the
  // jump_all static function should be used. This function causes all schedules
  // that share a phase to jump to that phase.
  
  extern function void jump(uvm_phase_imp phase);
  extern static function void jump_all(uvm_phase_imp phase);

  // internal - implementation

  local process m_phase_proc; // the master process for this phase - TBD move

  // implementation: local members that control forward and backward jumping
  local bit m_jump_bkwd;
  local bit m_jump_fwd;
  local uvm_phase_schedule m_jump_phase; //GSA TBD reconcile uvm_phase_schedule split

  // implementation methods
  extern function void clear(uvm_phase_state_t state = UVM_PHASE_DORMANT);
  extern function void clear_successors(
                                   uvm_phase_state_t state = UVM_PHASE_DORMANT);
  extern task execute();
  extern function void jump_OLD(string name); // TBD refactoring in progress

  extern function void agree_to_terminate_phase();
  extern function void disagree_to_terminate_phase();
  extern function void terminate_phase();
  extern function void print_termination_state();

  extern function void kill();
  extern function void kill_successors();

  // debug GSA TBD
  function string convert2string();
    return $sformatf("phase: %s parent=%s  %s",m_name,
           (m_parent==null) ? "null" : m_parent.m_schedule_name, super.convert2string());
  endfunction

endclass


//----------------------------------------------------------------------
// Implementation - public and friend methods
//----------------------------------------------------------------------

function uvm_phase_schedule::new(string name, uvm_phase_schedule parent=null);
  super.new();
  if (parent == null) begin
    uvm_phase_schedule end_node;
    m_parent = this;
    set_name("begin");
    m_schedule_name = name;
    end_node = new("end",.parent(this));
    insert_successor(end_node);
  end else begin
    m_parent = parent;
    set_name(name);
    m_schedule_name = m_parent.m_schedule_name;
    m_run_count = 0;
  end
endfunction


function void uvm_phase_schedule::add_phase(
                                    uvm_phase_imp phase,
                                    uvm_phase_schedule with_phase=null,
                                    uvm_phase_schedule after_phase=null,
                                    uvm_phase_schedule before_phase=null);
  uvm_phase_schedule new_node;
  assert(phase != null);
  new_node = new(phase.m_name,this);
  new_node.m_phase = phase;
  if (with_phase != null && (after_phase != null || before_phase != null)) begin
    uvm_report_fatal("BADSCHEDADD",
      "cannot specify both 'with' and 'before'/'after' phase relationships");
  end
  if (with_phase == null && after_phase == null && before_phase == null) begin
    assert($cast(before_phase,find("end")));
  end
  //TBD error checks if param nodes are actually in this schedule or not
  if (with_phase != null) begin
    // add all its predecessors as our predecessors
    foreach (with_phase.m_predecessors[i]) begin
      new_node.insert_predecessor(with_phase.m_predecessors[i]);
    end
    // add all its successors as our successors
    foreach (with_phase.m_successors[i]) begin
      new_node.insert_successor(with_phase.m_successors[i]);
    end
  end else if (before_phase != null && after_phase == null) begin
    // just before? add all preds and one succ
    // add all its predecessors as our predecessors
    foreach (before_phase.m_predecessors[i]) begin
      new_node.insert_predecessor(before_phase.m_predecessors[i]);
    end
    before_phase.m_predecessors.delete();
    new_node.insert_successor(before_phase);
  end else if (before_phase == null && after_phase != null) begin
    // just after? add 1 pred and all succs
    // add all its successors as our successors
    foreach (after_phase.m_successors[i]) begin
      new_node.insert_successor(after_phase.m_successors[i]);
    end
    after_phase.m_successors.delete();
    new_node.insert_predecessor(after_phase);
  end else if (before_phase != null && after_phase != null) begin
    // before and after? add 1 pred and 1 succ
    new_node.insert_predecessor(after_phase);
    new_node.insert_successor(before_phase);
  end
endfunction


function void uvm_phase_schedule::add_schedule(uvm_phase_schedule schedule,
                                               uvm_phase_schedule with_phase=null,
                                               uvm_phase_schedule after_phase=null,
                                               uvm_phase_schedule before_phase=null);
  uvm_phase_schedule begin_node, end_node;
  assert(schedule != null);
  begin_node = schedule.m_parent;
  end_node = schedule.find_schedule("end");
  assert(begin_node != null);
  assert(end_node != null);

  if (with_phase != null && (after_phase != null || before_phase != null)) begin
    uvm_report_fatal("BADSCHEDADD",
      "cannot specify both 'with' and 'before'/'after' phase relationships");
  end
  if (with_phase == null && after_phase == null && before_phase == null) begin
    assert($cast(before_phase,find("end")));
  end
  //TBD error checks if param nodes are actually in this schedule or not
  if (with_phase != null) begin
    // add all its predecessors as our predecessors
    foreach (with_phase.m_predecessors[i]) begin
      begin_node.insert_predecessor(with_phase.m_predecessors[i]);
    end
    // add all its successors as our successors
    foreach (with_phase.m_successors[i]) begin
      end_node.insert_successor(with_phase.m_successors[i]);
    end
  end else if (before_phase != null && after_phase == null) begin
    // just before? add all preds and one succ
    // add all its predecessors as our predecessors
    foreach (before_phase.m_predecessors[i]) begin
      begin_node.insert_predecessor(before_phase.m_predecessors[i]);
    end
    before_phase.m_predecessors.delete();
    end_node.insert_successor(before_phase);
  end else if (before_phase == null && after_phase != null) begin
    // just after? add 1 pred and all succs
    // add all its successors as our successors
    foreach (after_phase.m_successors[i]) begin
      end_node.insert_successor(after_phase.m_successors[i]);
    end
    after_phase.m_successors.delete();
    begin_node.insert_predecessor(after_phase);
  end else if (before_phase != null && after_phase != null) begin
    // before and after? add 1 pred and 1 succ
    begin_node.insert_predecessor(after_phase);
    end_node.insert_successor(before_phase);
  end

endfunction


function uvm_phase_schedule uvm_phase_schedule::find_schedule(string name);
  uvm_phase_schedule phase;
  uvm_graph graph_node;
  graph_node = super.find(name);
  assert($cast(phase, graph_node));
  return phase;
endfunction


function uvm_phase_imp uvm_phase_schedule::find_phase(string name);
  uvm_phase_schedule phase;
  phase = this.find_schedule(name);
  return (phase != null) ? phase.m_phase : null;
endfunction


function void uvm_phase_schedule::jump(uvm_phase_imp phase);
  // TBD integration task ongoing
endfunction // void


function void uvm_phase_schedule::jump_all(uvm_phase_imp phase);
  // TBD integration task ongoing
endfunction


// clear() is for internal graph maintenance after a forward jump
// - called only by clear_successors()
function void uvm_phase_schedule::clear(
                                   uvm_phase_state_t state = UVM_PHASE_DORMANT);
  m_state = state;
  m_phase_proc = null;
  m_termination_agreement = 0;
endfunction

// clear_successors() is for internal graph maintenance after a forward jump
// - called only by execute()
// - depth-first traversal of the DAG, calliing clear() on each node
function void uvm_phase_schedule::clear_successors(
                                   uvm_phase_state_t state = UVM_PHASE_DORMANT);
  clear(state);
  foreach(m_successors[i]) begin
    uvm_phase_schedule p;
    assert($cast(p, m_successors[i]));
    p.clear_successors(state);
  end
endfunction


// execute() - execute a phase
// - recursively exec successors
// - manage phase jumps
// - called from outside by uvm_root::phase_runner()
// - calls uvm_phase_imp::traverse using our phase handle
task uvm_phase_schedule::execute();
  uvm_root top;
  top = uvm_root::get();

  if(m_state == UVM_PHASE_SCHEDULED)
    return;
  m_state = UVM_PHASE_SCHEDULED;
  
  // are the predecessors done, or are there no predecessors?
  // block until all the predecessors are done
  foreach (m_predecessors[i]) begin
    uvm_phase_schedule p;
    assert($cast(p, m_predecessors[i]));
    wait (p.m_state == UVM_PHASE_DONE);
  end
  
  // are the synchronized phases executing yet, or are there none?
  // block until all the synced phases are executing
  // GSA avoid lockup
  foreach (m_sync[i]) begin
    uvm_phase_schedule p;
    assert($cast(p, m_sync[i]));
    wait (p.m_state != UVM_PHASE_DORMANT);
  end
  
  // deal with race conditions, particular for function phases, where
  // multiple threads reach the same phase at the same time. In that
  // case, the first one through wins, the rest are attenuated.
  if(m_state == UVM_PHASE_DONE)
    return;
  
  // run this phase
  m_state = UVM_PHASE_EXECUTING;
  m_run_count++;
  m_termination_agreement = 0;
  uvm_report_info("STARTPH",
                  $psprintf("STARTING PHASE %0s (in schedule %0s)",
                            this.get_name(),this.get_schedule_name()),int'(UVM_FULL)+1);
  
  // fork two processes, one that executes the phase callbacks and the
  // other that serves as a termination watchdog.  The fork is
  // terminated with a join_any, so the first process to complete will
  // cause the fork construct to exit.  The following disable fork
  // kills whichever forked process is still remaining.
  if (m_phase != null) begin
    // skip sentinel node with no phase imp to do
    fork
      begin
        #0; // force this process to run last
        wait (m_termination_agreement == 0);
        kill();
      end
      begin
        m_phase_proc = process::self();
        m_phase.traverse(top,this);
        wait fork;
      end
    join_any
          
    // kill child processes which includes the component task processes
    // and the terminations process.
    // TDB move this functionality to the thread class
    disable fork;
  end

  // This phase is now done
    uvm_report_info("ENDPH",
      $psprintf("ENDING PHASE %0s (in schedule %0s)",
                this.get_name(),this.get_schedule_name()),int'(UVM_FULL)+1);
    m_state = UVM_PHASE_DONE;
    m_phase_proc = null;

    // If jump_to() was called then we need to kill all the successor
    // phases which may still be running and then initiate the new
    // phase.  The return is necessary so we don't start new successor
    // phases.  If we are doing a forward jump then we want to set the
    // state of this phase's successors to UVM_PHASE_DONE.  This
    // will let us pretend that all the phases between here and there
    // were executed and completed.  Thus any dependencies will be
    // satisfied preventing deadlocks.
    // GSA TBD insert new jump support
    if(m_jump_fwd || m_jump_bkwd) begin
      kill_successors();
      if(m_jump_fwd) begin
        clear_successors(UVM_PHASE_DONE);
      end
      m_jump_phase.clear_successors();
      m_jump_fwd = 0;
      m_jump_bkwd = 0;
      phase_initiate(m_jump_phase);
      return;
    end

    // if there are no successors then we are all done.  Otherwise, run
    // all the successor phases.
    // GSA TBD insert new global_stop_request support
    if(top.phase_process_count() == 0 && m_successors.size() == 0) begin
      $display("TBD about to call top.phase_all_done as nothing to do");
      top.phase_all_done(); //TBD linkage? top singleton inst? global_all_done()
    end 
    else begin
      // execute all the successors
      foreach (m_successors[i]) begin
        uvm_phase_schedule phase;
        assert($cast(phase, m_successors[i]));
        if(phase.m_state != UVM_PHASE_SCHEDULED) begin
          phase_initiate(phase);
        end
      end
    end

  endtask


//--------------------------------------------------------------------
// sync
//--------------------------------------------------------------------

function void uvm_phase_schedule::sync(uvm_phase_schedule target,
                                       uvm_phase_imp phase=null,
                                       uvm_phase_imp with_phase=null,
                                       uvm_phase_imp after_phase=null,
                                       uvm_phase_imp before_phase=null);
endfunction

function void uvm_phase_schedule::unsync(uvm_phase_schedule target,
                                         uvm_phase_imp phase=null,
                                         uvm_phase_imp with_phase=null,
                                         uvm_phase_imp after_phase=null,
                                         uvm_phase_imp before_phase=null);
endfunction

//--------------------------------------------------------------------
// jump_to
//
// Jump to a new phase, either forward (to a successor) or backward
// (to a predecessor).  Note that this function does not directly
// alter the flow of control.  That is, the new phase is not initiated
// in this funciton.  Rather, flags are set which execute() uses to
// determine that a jump has been requested and pe3rforms the jump.
//--------------------------------------------------------------------
//TBD jump and global_stop_request are still in progress of being implemented

function void uvm_phase_schedule::jump_OLD(string name);
  uvm_graph d;

  // If the named phase (i.e. the name passed in as the function
  // argument) is in the set of predecessors then we are jumping
  // backwards.  If, on the other hand, the named phase is in the set
  // of successors then we are jumping forwards.  If neither, then we
  // have an error.
  //
  // If the phase is non-existant and thus we don't where to jump we
  // have a situation whwhere the only thing to do is to call
  // uvm_report_fatal and terminate_phase.  By calling this function
  // the intent was to jump to some other phase. So, continuing in the
  // current phase doesn't make any sense.  And we don't have a valid
  // phase to jump to.  So we're done.

  d = find_predecessor(name);
  if(d == null) begin
    d = find_successor(name);
    if(d == null) begin
      string msg;
      $sformat(msg,{"phase %s is neither a predecessor or successor of ",
                    "phase %s or is non-existant, so we cannot jump to it.  ",
                    "Phase control flow is now undefined so the simulation ",
                    "must terminate"}, name, get_name());
      uvm_report_fatal("phase jump", msg);
    end
    else begin
      m_jump_fwd = 1;
      uvm_report_info("PHJUMPF",$psprintf("jumping forward to phase %s", name),
                      UVM_DEBUG);
    end
  end
  else begin
    m_jump_bkwd = 1;
    uvm_report_info("PHJUMPB",$psprintf("jumping backward to phase %s", name),
                    UVM_DEBUG);
  end
  
  assert($cast(m_jump_phase, d));
  terminate_phase();
endfunction


//--------------------------------------------------------------------
// agree_to_terminate_phase
//--------------------------------------------------------------------
function void uvm_phase_schedule::agree_to_terminate_phase();
  m_termination_agreement--;
endfunction


//--------------------------------------------------------------------
// disagree_to_terminate_phase
//--------------------------------------------------------------------
function void uvm_phase_schedule::disagree_to_terminate_phase();
  m_termination_agreement++;
endfunction


//--------------------------------------------------------------------
// terminate_phase
//--------------------------------------------------------------------
function void uvm_phase_schedule::terminate_phase();
  m_termination_agreement = 0;
endfunction


function void uvm_phase_schedule::print_termination_state();
  uvm_report_info("PHTERMS",$psprintf("phase %s termination state = %0d",
                                get_name(), m_termination_agreement),UVM_DEBUG);
endfunction


//--------------------------------------------------------------------
// kill
//--------------------------------------------------------------------
function void uvm_phase_schedule::kill();
  uvm_report_info("PHKILL",$psprintf("killing phase %s", get_name()),UVM_DEBUG);
  if(m_phase_proc != null) begin
    m_phase_proc.kill();
    m_phase_proc = null;
  end
endfunction


//--------------------------------------------------------------------
// kill_successors
//
// Using a depth-first traversal, kill all the successor phases of the
// current phase.
//--------------------------------------------------------------------
function void uvm_phase_schedule::kill_successors();
  foreach (m_successors[i]) begin
    uvm_phase_schedule phase;
    uvm_graph graph_node;
    graph_node = m_successors[i];
    assert($cast(phase, graph_node));
    phase.kill_successors();
  end
  kill();
endfunction


//----------------------------------------------------------------------
// End
//----------------------------------------------------------------------

`endif // UVM_PHASES_SVH
