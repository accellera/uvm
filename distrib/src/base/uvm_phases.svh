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



//------------------------------------------------------------------------------
// TITLE: Phasing
//------------------------------------------------------------------------------
//
// UVM implements an automated mechanism for phasing the execution of
// the various components in a testbench.
//


//------------------------------------------------------------------------------
//
// Class: Pre-Defined Phases
//
//------------------------------------------------------------------------------
//
// This section describes the set of pre-defined phases
// provided as a standard part of the UVM library.
//
// Group: Common Phases Global Variables
//
// The common phases are the set of function and task phases that all
// <uvm_component>s execute together.
// All <uvm_component>s are always synchronized
// with respect to the common phases.
//
// The common phases are executed in the sequence they are specified below.
//
// Variable: uvm_build_ph
//
// Creation and configuration of testbench structure
//
// <uvm_topdown_phase> that calls the
// <uvm_component::build_phase> method.
//
// Upon entry:
//  - The top-level components have been instantiated under <uvm_root>.
//  - Current simulation time is still equal to 0 but some "delta cycles" may have occurred
//
// Typical Uses:
//  - Instantiate sub-components.
//  - Instantiate register model.
//  - Get configuration values for the component being built.
//  - Set configuration values for sub-components.
//
// Exit Criteria:
//  - All <uvm_component>s have been instantiated.
//
//
// Variable: uvm_connect_ph
//
// Establish cross-component connections.
//
// <uvm_bottomup_phase> that calls the
// <uvm_component::connect_phase> method.
//
// Upon Entry:
// - All components have been instantiated.
// - Current simulation time is still equal to 0
//   but some "delta cycles" may have occurred.
//
// Typical Uses:
// - Connect TLM ports and exports.
// - Connect TLM initiator sockets and target sockets.
// - Connect register model to adapter components.
//
// Exit Criteria:
// - All cross-component connections have been established.
//
//
// Variable: uvm_end_of_elaboration_ph
//
// Fine-tuning of the testbench.
//
// <uvm_bottomup_phase> that calls the
// <uvm_component::end_of_elaboration_phase> method.
//
// Upon Entry:
// - The verification environment has been completely assembled.
// - Current simulation time is still equal to 0
//   but some "delta cycles" may have occurred.
//
// Typical Uses:
// - Display environment topology.
// - Open files.
// - Define additional configuration settings for components.
//
// Exit Criteria:
// - None.
//                              
//
// Variable: uvm_start_of_simulation_ph
//
// Get ready for DUT to be simulated.
//
// <uvm_bottomup_phase> that calls the
// <uvm_component::start_of_simulation_phase> method.
//
// Upon Entry:
// - Other simulation engines, debuggers, hardware assisted platforms and
//   all other run-time tools have been started and synchronized.
// - The verification environment has been completely configured
//   and is ready to start.
// - Current simulation time is still equal to 0
//   but some "delta cycles" may have occurred.
//
// Typical Uses:
// - Display environment topology
// - Set debugger breakpoint
// - Set run-time configuration values.
//
// Exit Criteria:
// - None.
//
//
// Variable: uvm_run_ph
//
// What to do while the DUT is simulated.
//
// <uvm_task_phase> that calls the
// <uvm_component::run_phase> method.
//
// Upon Entry:
// - Indicates that power has been applied.
// - There should not have been any active clock edges before entry
//   into this phase (e.g. x->1 transitions via initial blocks).
// - Current simulation time is still equal to 0
//   but some "delta cycles" may have occurred.
//
// Typical Uses:
// - Components implement behavior that is exhibited for the entire
//   run-time, across the various run-time phases.
// - Backward compatibility with OVM.
//
// Exit Criteria:
// - The DUT no longer needs to be simulated.
//
// The run phase terminates in one of four ways.
//
// 1. Explicit call to <global_stop_request>:
//
//   When <global_stop_request> is called, an ordered shut-down for the
//   currently running phase begins.
//   First, all enabled components' <uvm_component::stop> tasks 
//   are called bottom-up, i.e., childrens' <uvm_component::stop> tasks
//   are called before the parent's.
//
//   A component is enabled by its <uvm_component::enable_stop_interrupt> bit.
//   Each component can implement <uvm_component::stop>
//   to allow completion of in-progress transactions, flush queues,
//   and other shut-down activities.
//   Upon return from <uvm_component::stop> by all enabled components,
//   the recursive <uvm_component::do_kill_all> is called
//   on all top-level component(s).
//   If the <uvm_test_done> objection is being used,
//   this stopping procedure is deferred until all outstanding objections
//   on <uvm_test_done> have been dropped.
//
// 2. All objections to <uvm_test_done> have been dropped:
//
//   When all objections on the <uvm_test_done> objection have been dropped,
//   <global_stop_request> is called automatically, thus kicking off the
//   stopping procedure described above. See <uvm_objection> for details on
//   using the objection mechanism.
//
// 3. Explicit call to <uvm_component::kill> or <uvm_component::do_kill_all>:
//
//   When <uvm_component::kill> is called,
//   that component's <uvm_component::run_phase> processes are killed
//   immediately.
//   The <uvm_component::do_kill_all> methods applies to the component
//   and all its descendants.
//
//   Use of this method is not recommended.
//   It is better to use the stopping mechanism, which affords a more ordered,
//   safer shut-down.
//
// 4. Timeout:
//
//   The phase ends if the timeout expires before an explicit call to
//   <global_stop_request> or <uvm_component::kill>.
//   By default, the timeout is set to 9200ns.
//   You may override this via <set_global_timeout>,
//   but you cannot disable the timeout completely.
//
//   If the default timeout occurs in your simulation, or if simulation never
//   ends despite completion of your test stimulus, then it usually indicates
//   a missing call to <global_stop_request>.
//
//
//
// Variable: uvm_extract_ph
//
// Is there anything left behind?
//
// <uvm_bottomup_phase> that calls the
// <uvm_component::extract_phase> method.
//
// Upon Entry:
// - The DUT no longer needs to be simulated.
// - Simulation time will no longer advance.
//
// Typical Uses:
// - Extract any remaining data and final state information
//   from scoreboard and testbench components
// - Probe the DUT (via zero-time hierarchical references
//   and/or backdoor accesses) for final state information.
// - Compute statistics and summaries.
// - Display final state information
// - Close files.
//
// Exit Criteria:
// - All data has been collected and summarized.
//
//
// Variable: uvm_check_ph
//
// Were there any errors?
//
// <uvm_bottomup_phase> that calls the
// <uvm_component::check_phase> method.
//
// Upon Entry:
// - All data has been collected.
//
// Typical Uses:
// - Check that no unaccounted-for data remain.
//
// Exit Criteria:
// - Test is known to have passed or failed.
//
//
// Variable: uvm_report_ph
//
// What is the verdict?
//
// <uvm_bottomup_phase> that calls the
// <uvm_component::report_phase> method.
//
// Upon Entry:
// - Test is known to have passed or failed.
//
// Typical Uses:
// - Report test results.
// - Write results to file.
//
// Exit Criteria:
// - End of test.
//
//
// Variable: uvm_final_ph
//
// Tie up loose ends.
//
// <uvm_topdown_phase> that calls the
// <uvm_component::final_phase> method.
//
// Upon Entry:
// - All test-related activity has completed.
//
// Typical Uses:
// - Close files.
// - Terminate co-simulation engines.
//
// Exit Criteria:
// - Ready to exit simulator.
//
//
// Group: Run-Time Schedule Global Variables
//
// The run-time schedule is the pre-defined phase schedule
// which runs concurrently to the <uvm_run_ph> global run phase.
// By default, all <uvm_component>s using the run-time schedule
// are synchronized with respect to the pre-defined phases in the schedule.
// It is possible for components to belong to different domains
// in which case their schedules will be unsynchronized.
//
// Variable: uvm_pre_reset_ph
//
// Before reset is asserted.
//
// <uvm_task_phase> that calls the
// <uvm_component::pre_reset_phase> method.
//
// Upon Entry:
// - Indicates that power has been applied but not necessarily valid or stable.
// - There should not have been any active clock edges
//   before entry into this phase.
//
// Typical Uses:
// - Wait for power good.
// - Components connected to virtual interfaces should initialize
//   their output to X's or Z's.
// - Initialize the clock signals to a valid value
// - Assign reset signals to X (power-on reset).
// - Wait for reset signal to be asserted
//   if not driven by the verification environment.
//
// Exit Criteria:
// - Reset signal, if driven by the verification environment,
//   is ready to be asserted.
// - Reset signal, if not driven by the verification environment, is asserted.
//
//
// Variable: uvm_reset_ph
//
// Reset is asserted.
//
// <uvm_task_phase> that calls the
// <uvm_component::reset_phase> method.
//
// Upon Entry:
// - Indicates that the hardware reset signal is ready to be asserted.
//
// Typical Uses:
// - Assert reset signals.
// - Components connected to virtual interfaces should drive their output
//   to their specified reset or idle value.
// - Components and environments should initialize their state variables.
// - Clock generators start generating active edges.
// - De-assert the reset signal(s)  just before exit.
// - Wait for the reset signal(s) to be de-asserted.
//
// Exit Criteria:
// - Reset signal has just been de-asserted.
// - Main or base clock is working and stable.
// - At least one active clock edge has occurred.
// - Output signals and state variables have been initialized.
//
//
// Variable: uvm_post_reset_ph
//
// After reset is de-asserted.
//
// <uvm_task_phase> that calls the
// <uvm_component::post_reset_phase> method.
//
// Upon Entry:
// - Indicates that the DUT reset signal has been de-asserted.
//
// Typical Uses:
// - Components should start behavior appropriate for reset being inactive.
//   For example, components may start to transmit idle transactions
//   or interface training and rate negotiation.
//   This behavior typically continues beyond the end of this phase.
//
// Exit Criteria:
// - The testbench and the DUT are in a known, active state.
//
//
// Variable: uvm_pre_configure_ph
//
// Before the DUT is configured by the SW.
//
// <uvm_task_phase> that calls the
// <uvm_component::pre_configure_phase> method.
//
// Upon Entry:
// - Indicates that the DUT has been completed reset
//  and is ready to be configured.
//
// Typical Uses:
// - Procedurally modify the DUT configuration information as described
//   in the environment (and that will be eventually uploaded into the DUT).
// - Wait for components required for DUT configuration to complete
//   training and rate negotiation.
//
// Exit Criteria:
// - DUT configuration information is defined.
//
//
// Variable: uvm_configure_ph
//
// The SW configures the DUT.
//
// <uvm_task_phase> that calls the
// <uvm_component::configure_phase> method.
//
// Upon Entry:
// - Indicates that the DUT is ready to be configured.
//
// Typical Uses:
// - Components required for DUT configuration execute transactions normally.
// - Set signals and program the DUT and memories
//   (e.g. read/write operations and sequences)
//   to match the desired configuration for the test and environment.
//
// Exit Criteria:
// - The DUT has been configured and is ready to operate normally.
//
//
// Variable: uvm_post_configure_ph
//
// After the SW has configured the DUT.
//
// <uvm_task_phase> that calls the
// <uvm_component::post_configure_phase> method.
//
// Upon Entry:
// - Indicates that the configuration information has been fully uploaded.
//
// Typical Uses:
// - Wait for configuration information to fully propagate and take effect.
// - Wait for components to complete training and rate negotiation.
// - Enable the DUT.
// - Sample DUT configuration coverage.
//
// Exit Criteria:
// - The DUT has been fully configured and enabled
//   and is ready to start operating normally.
//
//
// Variable: uvm_pre_main_ph
//
// Before the primary test stimulus starts.
//
// <uvm_task_phase> that calls the
// <uvm_component::pre_main_phase> method.
//
// Upon Entry:
// - Indicates that the DUT has been fully configured.
//
// Typical Uses:
// - Wait for components to complete training and rate negotiation.
//
// Exit Criteria:
// - All components have completed training and rate negotiation.
// - All components are ready to generate and/or observe normal stimulus.
//
//
// Variable: uvm_main_ph
//
// Primary test stimulus.
//
// <uvm_task_phase> that calls the
// <uvm_component::main_phase> method.
//
// Upon Entry:
// - The stimulus associated with the test objectives is ready to be applied.
//
// Typical Uses:
// - Components execute transactions normally.
// - Data stimulus sequences are started.
// - Wait for a time-out or certain amount of time,
//   or completion of stimulus sequences.
//
// Exit Criteria:
// - Enough stimulus has been applied to meet the primary
//   stimulus objective of the test.
//
//
// Variable: uvm_post_main_ph
//
// After enough of the primary test stimulus.
//
// <uvm_task_phase> that calls the
// <uvm_component::post_main_phase> method.
//
// Upon Entry:
// - The primary stimulus objective of the test has been met.
//
// Typical Uses:
// - Included for symmetry.
//
// Exit Criteria:
// - None.
//
//
// Variable: uvm_pre_shutdown_ph
//
// Before things settle down.
//
// <uvm_task_phase> that calls the
// <uvm_component::pre_shutdown_phase> method.
//
// Upon Entry:
// - None.
//
// Typical Uses:
// - Included for symmetry.
//
// Exit Criteria:
// - None.
//
//
// Variable: uvm_shutdown_ph
//
// Letting things settle down.
//
// <uvm_task_phase> that calls the
// <uvm_component::shutdown_phase> method.
//
// Upon Entry:
// - None.
//
// Typical Uses:
// - Wait for all data to be drained out of the DUT.
// - Extract data still buffered in the DUT,
//   usually through read/write operations or sequences.
//
// Exit Criteria:
// - All data has been drained or extracted from the DUT.
// - All interfaces are idle.
//
//
// Variable: uvm_post_shutdown_ph
//
// After things have settled down.
//
// <uvm_task_phase> that calls the
// <uvm_component::post_shutdown_phase> method.
//
// Upon Entry:
// - No more "data" stimulus is applied to the DUT.
//
// Typical Uses:
// - Perform final checks that require run-time access to the DUT
//   (e.g. read accounting registers or dump the content of memories).
//
// Exit Criteria:
// - All run-time checks have been satisfied.
//
//

typedef class uvm_topdown_phase;
typedef class uvm_bottomup_phase;
typedef class uvm_task_phase;
typedef class uvm_phase_schedule;

`uvm_builtin_topdown_phase(build)
`uvm_builtin_bottomup_phase(connect)
`uvm_builtin_bottomup_phase(end_of_elaboration)
`uvm_builtin_bottomup_phase(start_of_simulation)

`uvm_builtin_task_phase(run)

`uvm_builtin_task_phase(pre_reset)
`uvm_builtin_task_phase(reset)
`uvm_builtin_task_phase(post_reset)
`uvm_builtin_task_phase(pre_configure)
`uvm_builtin_task_phase(configure)
`uvm_builtin_task_phase(post_configure)
`uvm_builtin_task_phase(pre_main)
`uvm_builtin_task_phase(main)
`uvm_builtin_task_phase(post_main)
`uvm_builtin_task_phase(pre_shutdown)
`uvm_builtin_task_phase(shutdown)
`uvm_builtin_task_phase(post_shutdown)

`uvm_builtin_bottomup_phase(extract)
`uvm_builtin_bottomup_phase(check)
`uvm_builtin_bottomup_phase(report)
`uvm_builtin_topdown_phase(final)



//------------------------------------------------------------------------------
//
// Class: User-Defined Phases
//
//------------------------------------------------------------------------------
//
// To defined your own custom phase, use the following pattern
//
// 1. extend the appropriate base class for your phase type
//|       class my_PHASE_phase extends uvm_task_phase("PHASE");
//|       class my_PHASE_phase extends uvm_topdown_phase("PHASE");
//|       class my_PHASE_phase extends uvm_bottomup_phase("PHASE");
//
// 2. implement your exec_task or exec_func method
//|       task exec_task(uvm_component comp, uvm_phase_schedule schedule);
//|       function void exec_func(uvm_component comp, uvm_phase_schedule schedule);
//
// 3. the implementation usually calls the related method on the component
//|          comp.PHASE_phase();
//
// 4. after declaring your phase singleton class, instantiate one for global use
//|       static my_``PHASE``_phase my_``PHASE``_ph = new();
//
// 5. insert the phase in a schedule using the
//    <uvm_phase_schedule::add_phase>.method.
//
//------------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Class: Phasing Implementation
//-----------------------------------------------------------------------------
//                                                                             
// The API described here provides a general purpose testbench phasing         
// solution, consisting of a phaser machine, traversing a master schedule      
// graph, which is built by the integrator from one or more instances of       
// template schedules provided by UVM or by 3rd-party VIP, and which supports  
// implicit or explicit synchronization, runtime control of threads and jumps. 
//                                                                             
// Each schedule leaf node refers to a single phase that is compatible with    
// that VIP's components and which executes the required behavior via a        
// functor or delegate extending the phase into component context as required. 
// Execution threads are tracked on a per-component basis and various thread   
// semantics available to allow defined phase control and responsibility.      
//                                                                             
//-----------------------------------------------------------------------------
//
//
//------------------------------------------------------------------------------
// Class hierarchy:
//------------------------------------------------------------------------------
//
// Two separate data class hierarchies are required
// to represent a phase: the phase schedule,
// which builds a graph of serial and parallel
// phase relationships and stores current state as the phaser progresses,
// and the phase implementation which specifies required component behavior
// (by extension into component context if non-default behavior required.)
// There are further implementation-internal classes e.g. uvm_phase_thread.
//
//|  +----------+                  +---------+                +-------------+
//|  |uvm_object|                  |uvm_graph|                |uvm_component|
//|  +----------+                  +---------+                |             |
//|       ^                             ^                     |             |
//|  +-------------+           +------------------+           |             |
//|  |uvm_phase_imp|------1---o|uvm_phase_schedule|----1..*--o|[domains]    |
//|  +-------------+\          +-------------------           |             |
//|       ^          `-----------------------|---------0..*--o|[overrides]  |
//|  +-------------------------------+       |                |             |
//|  |uvm_task/topdown/bottomup_phase|      0..*              |             |
//|  +-------------------------------+       |                |             |
//|       ^                                  |                |             |
//|  +--------------+               +----------------+        |             |
//|  |uvm_NAME_phase|               |uvm_phase_thread|--0..*-o|[threads]    |
//|  +--------------+               +----------------+        +-------------+
//|       ^                                                          ^       
//|  +-------------------------------------+               +----------------+
//|  |uvm_NAME_phase (type T=uvm_component)| . . . . . . . |custom_component|
//|  +-------------------------------------+               +----------------+
//
// The following classes related to phasing are defined herein:
//
// <uvm_phase_imp> : The base class for defining a phase's behavior
//
// <uvm_bottomup_phase> : A phase implemenation for bottom up function phases.
//
// <uvm_topdown_phase> : A phase implemenation for topdown function phases.
//
// <uvm_task_phase> : A phase implemenation for task phases.
//
// <uvm_phase_schedule> : A node in the phase graph (a single phase or a group of phases) 
//

typedef class uvm_phase_imp;          // phase implementation
typedef class uvm_phase_schedule; // phase context and state
typedef class uvm_phase_thread;   // phase process on a component
typedef class uvm_test_done_objection;
typedef class uvm_sequencer_base;

//------------------------------------------------------------------------------
//
// Class: uvm_phase_imp
//
//------------------------------------------------------------------------------
//
// This is the virtual base class which defines a phase's behavior (not state).
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

  uvm_phase_type m_phase_type; // task, topdown func or bottomup func

  // Function: new
  //
  // Create a new phase imp, with a name and a note of its type
  //   name   - name of this phase
  //   type   - task, topdown func or bottomup func
  
  function new(string name, uvm_phase_type phase_type);
    super.new(name);
    m_phase_type = phase_type;
  endfunction


  // Function: get_phase_type
  //
  // Returns the phase type as defined by <uvm_phase_type>
  //
  function uvm_phase_type get_phase_type();
    return m_phase_type;
  endfunction


  //-----------------
  // Group: Callbacks
  //-----------------

  // Function: exec_func
  //
  // Implements the functor/delegate functionality for a function phase type
  //   comp  - the component to execute the functionality upon
  //   phase - the phase schedule that originated this phase call
  //
  virtual function void exec_func(uvm_component comp, uvm_phase_schedule phase);
  endfunction


  // Function: exec_task
  //
  // Implements the functor/delegate functionality for a task phase type
  //   comp  - the component to execute the functionality upon
  //   phase - the phase schedule that originated this phase call
  //
  virtual task exec_task(uvm_component comp, uvm_phase_schedule phase);
  endtask


  // Function: phase_started
  //
  // Generic notification function called prior to exec_func()/exec_task()
  //   phase - the phase schedule that originated this phase call
  //
  virtual function void phase_started(uvm_phase_schedule phase);
  endfunction


  // Function: phase_ended
  //
  // Generic notification function called after exec_func()/exec_task()
  //   phase - the phase schedule that originated this phase call
  //
  virtual function void phase_ended(uvm_phase_schedule phase);
  endfunction


  //-----------------------
  // Group: Phase Execution
  //-----------------------
  
  // Function: traverse
  //
  // Provides the required component traversal behavior. Called by
  // <uvm_phase_schedule::execute>.
  //
  pure virtual function void traverse(uvm_component comp,
                                      uvm_phase_schedule phase,
                                      uvm_phase_state state);


  // Function: execute
  //
  // Provides the required per-component execution flow. Called by <traverse>.
  //
  pure virtual protected function void execute(uvm_component comp,
                                               uvm_phase_schedule phase);

endclass


//------------------------------------------------------------------------------
//
// Class: uvm_bottomup_phase
//
//------------------------------------------------------------------------------
// Virtual base class for function phases that operate bottom-up.
// The pure virtual function execute() is called for each component.
// This is the default traversal so is included only for naming.

virtual class uvm_bottomup_phase extends uvm_phase_imp;

  // Function: new
  //
  // Create a new instance of a bottom-up phase.
  //
  function new(string name);
    super.new(name,UVM_PHASE_BOTTOMUP);
  endfunction


  // Function: traverse
  //
  // Traverses the component tree in bottom-up order, calling <execute> for
  // each component.
  //
  virtual function void traverse(uvm_component comp,
                                 uvm_phase_schedule phase,
                                 uvm_phase_state state);
    string name;
    if (comp.get_first_child(name))
      do
        traverse(comp.get_child(name), phase, state);
      while(comp.get_next_child(name));

    if (comp.m_phase_domains.exists(phase.m_parent)) begin
      case (state)
        UVM_PHASE_STARTED: begin
          comp.m_current_phase = phase;
          comp.phase_started(phase);
          end
        UVM_PHASE_EXECUTING: begin
          uvm_phase_imp ph = this; 
          if (comp.m_phase_imps.exists(this))
            ph = comp.m_phase_imps[this];
          ph.execute(comp, phase);
          end
        UVM_PHASE_ENDED: begin
          comp.phase_started(phase);
          comp.m_current_phase = null;
          end
        default:
          `uvm_fatal("PH_BADEXEC","bottomup phase traverse internal error")
      endcase
    end
  endfunction


  // Function: execute
  //
  // Executes the bottom-up phase ~phase~ for the component ~comp~. 
  //
  protected virtual function void execute(uvm_component comp,
                                          uvm_phase_schedule phase);
    comp.m_current_phase = phase;
    comp.phase_started(phase);
    exec_func(comp,phase);
    comp.phase_ended(phase);
  endfunction

endclass


//------------------------------------------------------------------------------
//
// Class: uvm_topdown_phase
//
//------------------------------------------------------------------------------
// Virtual base class for function phases that operate top-down.
// The pure virtual function execute() is called for each component.
virtual class uvm_topdown_phase extends uvm_phase_imp;


  // Function: new
  //
  // Create a new instance of a top-down phase
  //
  function new(string name);
    super.new(name,UVM_PHASE_TOPDOWN);
  endfunction


  // Function: traverse
  //
  // Traverses the component tree in top-down order, calling <execute> for
  // each component.
  //
  virtual function void traverse(uvm_component comp,
                                 uvm_phase_schedule phase,
                                 uvm_phase_state state);
    string name;
    if (comp.m_phase_domains.exists(phase.m_parent)) begin
      if(phase.get_name() != "build" || comp.m_build_done == 0) begin
        case (state)
          UVM_PHASE_STARTED: begin
            comp.m_current_phase = phase;
            comp.phase_started(phase);
            end
          UVM_PHASE_EXECUTING: begin
            uvm_phase_imp ph = this; 
            if (comp.m_phase_imps.exists(this))
              ph = comp.m_phase_imps[this];
            ph.execute(comp, phase);
            end
          UVM_PHASE_ENDED: begin
            comp.phase_ended(phase);
            comp.m_current_phase = null;
            end
          default:
            `uvm_fatal("PH_BADEXEC","topdown phase traverse internal error")
        endcase
      end
    end
    if(comp.get_first_child(name))
      do
        traverse(comp.get_child(name), phase, state);
      while(comp.get_next_child(name));
  endfunction


  // Function: execute
  //
  // Executes the top-down phase ~phase~ for the component ~comp~. 
  //
  protected virtual function void execute(uvm_component comp,
                                          uvm_phase_schedule phase);
    comp.m_current_phase = phase;
    comp.phase_started(phase);
    exec_func(comp,phase);
    comp.phase_ended(phase);
  endfunction

endclass


//------------------------------------------------------------------------------
//
// Class: uvm_task_phase
//
//------------------------------------------------------------------------------
// Base class for all task phases. exec_task() is forked for each comp
// Completion of exec_task() is a tacit agreement to shutdown.

virtual class uvm_task_phase extends uvm_phase_imp;

  int m_procs_not_yet_started;
  int m_num_procs_not_yet_returned;

  // Function: new
  //
  // Create a new instance of a task-based phase
  //
  function new(string name);
    super.new(name,UVM_PHASE_TASK);
  endfunction


  // Function: traverse
  //
  // Traverses the component tree in bottom-up order, calling <execute> for
  // each component. The actual order for task-based phases doesn't really
  // matter, as each component task is executed in a separate process whose
  // starting order is not deterministic.
  //
  virtual function void traverse(uvm_component comp,
                                 uvm_phase_schedule phase,
                                 uvm_phase_state state);
    m_procs_not_yet_started = 0;
    m_num_procs_not_yet_returned = 0;
    m_traverse(comp, phase, state);
  endfunction

  function void m_traverse(uvm_component comp,
                           uvm_phase_schedule phase,
                           uvm_phase_state state);
    string name;
    
    if (comp.get_first_child(name))
      do
        m_traverse(comp.get_child(name), phase, state);
      while(comp.get_next_child(name));

    if (comp.m_phase_domains.exists(phase.m_parent)) begin
      case (state)
        UVM_PHASE_STARTED: begin
          comp.m_current_phase = phase;
          comp.phase_started(phase);
          end
        UVM_PHASE_EXECUTING: begin
          uvm_phase_imp ph = this; 
          if (comp.m_phase_imps.exists(this))
            ph = comp.m_phase_imps[this];
          ph.execute(comp, phase);
          end
        UVM_PHASE_ENDED: begin
          comp.phase_ended(phase);
          comp.m_current_phase = null;
          end
        default:
          `uvm_fatal("PH_BADEXEC","task phase traverse internal error")
      endcase
    end

  endfunction


  // Function: execute
  //
  // Executes the task-based phase ~phase~ for the component ~comp~. 
  //
  // Task-based phase execution occurs in a separate forked process for each
  // component.  When there is no longer any objections to ending a phase,
  // as governed by the <uvm_phase_schedule::phase_done> objection, the
  // forked process and all its children are terminated before proceeding
  // to the next phase.
  //
  protected virtual function void execute(uvm_component comp,
                                          uvm_phase_schedule phase);

    m_procs_not_yet_started++;

    fork
      begin
        uvm_phase_thread thread;
        uvm_sequencer_base seqr;
        
        // initialize a thread object for this top-level process for
        // for this component instance in the executing phase
        thread = new(phase,comp);

        m_procs_not_yet_started--;
        m_num_procs_not_yet_returned++;

        // hold back everybody until all reach this point; a kind of barrier
        wait(m_procs_not_yet_started==0);

        if ($cast(seqr,comp))
          seqr.start_phase_sequence(phase);

        // execute the task for this component
        exec_task(comp,phase);

        // inform the thread manager the task returned
        thread.task_ended();

        m_num_procs_not_yet_returned--;

        // let somebody else decide when to kill (based on objections)
        //wait(0);

      end
    join_none

  endfunction
endclass



//------------------------------------------------------------------------------
//
// Class - uvm_process
//
//------------------------------------------------------------------------------
// Workaround container for process construct.

//`ifdef INCA
class uvm_process;

  protected process m_process_id;  

  function new(process pid);
    m_process_id = pid;
  endfunction

  function process self();
    return m_process_id;
  endfunction

  virtual function void kill();
    m_process_id.kill();
  endfunction

`ifdef UVM_USE_FPC
  virtual function process::state status();
    return m_process_id.status();
  endfunction

  task await();
    m_process_id.await();
  endtask

  task suspend();
   m_process_id.suspend();
  endtask

  function void resume();
   m_process_id.resume();
  endfunction
`else
  virtual function int status();
    return m_process_id.status();
  endfunction
`endif

endclass
//`else
//typedef process uvm_process;
//`endif


//------------------------------------------------------------------------------
//
// Class - uvm_phase_thread
//
//------------------------------------------------------------------------------
// This is a wrapper around a process handle which serves to associate
// a phase schedule with a component, capturing the process ID of the
// thread that phase is running on that component, together with the
// required thread mode. Also contained are thread maintenance methods.
// Both component and phase schedule classes have a member which lists
// the outstanding threads running on that component, or that phase.
// These are used to determine completeness and execute cleanup semantics.

// TBD benchmark the assoc arrays - given that this class holds both
// TBD comp and sched handles, it is possible to use a simpler darray

class uvm_phase_thread extends uvm_process;

  uvm_phase_schedule m_phase; // the phase this thread was spawned from
  uvm_component      m_comp;  // the component this thread is running on
  uvm_thread_mode    m_mode;  // threading semantics in force for this pid
  bit m_task_ended = 0;

  // Function - new
  //
  // Register a new thread with it's collaborating phase schedule and component
  // nodes. Capture the PID for future tracking and cleanup. Set the default
  // thread semantics from the component.

  function new(uvm_phase_schedule phase, uvm_component comp);
    // process ID of this phase/component thread
    super.new(process::self());
    m_phase = phase;
    m_comp  = comp;

    //assert (!m_comp.m_phase_threads.exists(m_phase)); // sanity check
    //assert (!m_phase.m_threads.exists(m_comp));       // sanity check

    m_comp.m_phase_threads[m_phase] = this;
    m_phase.m_threads[m_comp] = this;

    m_mode = m_comp.m_def_phase_thread_mode;

    if (m_mode == UVM_PHASE_MODE_DEFAULT)
      m_mode = UVM_PHASE_NO_IMPLICIT_OBJECTION;

    if (m_mode == UVM_PHASE_IMPLICIT_OBJECTION)
      m_phase.phase_done.raise_objection(m_comp, {"raise implicit ",
           m_phase.get_name(), " objection for ", m_comp.get_full_name()});
  endfunction

  function void task_ended();
    if (m_mode == UVM_PHASE_IMPLICIT_OBJECTION)
      if(m_phase.phase_done.get_objection_count(m_comp) > 0) // why this conditional?
         m_phase.phase_done.drop_objection(m_comp, {"drop implicit ",
              m_phase.get_name(), " objection for ", m_comp.get_full_name()});
  endfunction

`ifdef NOT_DEFINED 
  virtual function state status();
    if (m_task_ended)
      return process::FINISHED;
    return proc.status();
  endfunction
`endif
  virtual function void kill();
    m_comp.m_phase_threads.delete(m_phase);
    m_phase.m_threads.delete(m_comp);
    super.kill();
  endfunction
  
  function void set_thread_mode(uvm_thread_mode mode);
    // if passive -> active, we need to raise an implicit objection now
    if (m_mode == UVM_PHASE_NO_IMPLICIT_OBJECTION &&
          mode == UVM_PHASE_IMPLICIT_OBJECTION)
      m_phase.phase_done.raise_objection(m_comp, {"mode change- raise implicit ",
            m_phase.get_name(), " objection for ", m_comp.get_full_name()});

    // if active -> passive, we need to drop the implicit objection now
    if (m_mode == UVM_PHASE_NO_IMPLICIT_OBJECTION &&
          mode == UVM_PHASE_IMPLICIT_OBJECTION)
      m_phase.phase_done.drop_objection(m_comp, {"mode change- drop implicit ",
            m_phase.get_name(), " objection for ", m_comp.get_full_name()});

    m_mode = mode;
  endfunction

  function int is_current_process();
    process pid = process::self();
    return (m_process_id == pid);
  endfunction
endclass


//------------------------------------------------------------------------------
//
// Class: uvm_phase_schedule
//
//------------------------------------------------------------------------------
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


  //--------------------
  // Group: Construction
  //--------------------

  // Create schedules and add phases or sub-schedules.

  // Function: new
  //
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
  // 
  extern function new(string name, uvm_phase_schedule parent=null);


  // Function: get_schedule_name
  //
  // Accessor to return the schedule name associated with this schedule
  //
  extern function string get_schedule_name();


  // Function: get_phase_name
  //
  // Accessor to return the phase name associated with this schedule node
  //
  extern function string get_phase_name();


  // Function: get_run_count
  //
  // Accessor to return the integer number of times this phase has executed
  //
  extern function int get_run_count();


  // Function: get_state
  //
  // Accessor to return current state of this phase
  //
  extern function uvm_phase_state get_state();


  // Function: add_phase
  //
  // Build up a schedule structure inserting phase by phase, specifying linkage
  //
  // Phases can be added anywhere, in series or parallel with existing nodes
  //
  //   phase        - handle of singleton derived imp containing actual functor.
  //                  by default the new phase is appended to the schedule
  //   with_phase   - specify to add the new phase in parallel with this one
  //   after_phase  - specify to add the new phase as successor to this one
  //   before_phase - specify to add the new phase as predecessor to this one
  //
  extern function void add_phase(uvm_phase_imp phase,
                                 uvm_phase_schedule with_phase=null,
                                 uvm_phase_schedule after_phase=null,
                                 uvm_phase_schedule before_phase=null);

  // Function: add_schedule
  //
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
  //
  extern function void add_schedule(uvm_phase_schedule schedule,
                                    uvm_phase_schedule with_phase=null,
                                    uvm_phase_schedule after_phase=null,
                                    uvm_phase_schedule before_phase=null);


  // Miscellaneous VIP-integrator API - looking up schedules and phases
  

  // Function: find_schedule
  //
  // Locate a phase node with the specified ~name~ and return its handle.
  //
  extern function uvm_phase_schedule find_schedule(string name);


  // Function: find_phase
  //
  // Locate a phase with the specified phase ~name~ and return its handle.
  //
  extern function uvm_phase_imp find_phase(string name);


  //-----------------------
  // Group: Synchronization
  //-----------------------

  // Function: raise_objection
  //
  // Raise an objection to ending this phase
  // Components es greater control over the phase flow for
  // processes which are not implicit objectors to the phase.
  //
  // For example, a phase process may be set as <UVM_PHASE_NO_IMPLICIT_OBJECTION>,
  // but may need to raise and drop objections when certain 
  // conditions occur.
  //
  //| task main;
  //|   set_thread_mode(UVM_PHASE_NO_IMPLICIT_OBJECTION);
  //|   while(1) begin
  //|     some_phase.raise_objection(this);
  //|     ...
  //|     some_phase.drop_objection(this);
  //|   end 
  //|   ...
  //
  extern virtual function void raise_objection (uvm_object obj, 
                                                string description="",
                                                int count=1);

  // Function: drop_objection
  //
  // Drop an objection to ending this phase
  //
  // The drop is expected to be matched with an earlier raise.
  //
  extern virtual function void drop_objection (uvm_object obj, 
                                               string description="",
                                               int count=1);


  // Add soft sync relationships between nodes
  //
  // Summary of usage:
  //| target::sync(.source(domain)
  //|              [,.phase(phase)[,.with/after/before_phase(phase)]]);
  //| target::unsync(.source(domain)
  //|                [,.phase(phase)[,.with/after/before_phase(phase)]]);
  //
  // Components in different schedule domains can be phased independently or in sync
  // with each other. An API is provided to specify synchronization rules between any
  // two domains. Synchronization can be done at any of three levels:
  //
  // - the domain's whole phase schedule can be synchronized
  // - a phase can be specified, to sync that phase with a matching counterpart
  // - or a more detailed arbitrary synchronization between any two phases
  //
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
  //
  // Synchonize two domains, fully or partially
  //
  //   target       - handle of target schedule to synchronize this one to
  //   phase        - optional single phase to synchronize, otherwise all
  //   with_phase   - optional different target-domain phase to synchronize with
  //   after_phase  - optional diff target-domain phase to synchronize after
  //   before_phase - optional diff target-domain phase to synchronize before
  //
  extern function void sync(uvm_phase_schedule target,
                            uvm_phase_imp phase=null,
                            uvm_phase_imp with_phase=null,
                            uvm_phase_imp after_phase=null,
                            uvm_phase_imp before_phase=null);

  // Function: unsync
  //
  // Remove synchonization between two domains, fully or partially
  //
  //   target       - handle of target schedule to remove synchronization from
  //   phase        - optional single phase to un-synchronize, otherwise all
  //   with_phase   - optional different target-domain phase to un-synchronize with
  //   after_phase  - optional diff target-domain phase to un-synchronize after
  //   before_phase - optional diff target-domain phase to un-synchronize before
  //
  extern function void unsync(uvm_phase_schedule target,
                              uvm_phase_imp phase=null,
                              uvm_phase_imp with_phase=null,
                              uvm_phase_imp after_phase=null,
                              uvm_phase_imp before_phase=null);

  //---------------
  // Group: Jumping
  //---------------

  // Force phases to jump forward or backward in a schedule
  //
  // A phasing domain can execute a jump from its current phase to any other.
  // A jump passes phasing control in the current domain from the current phase
  // to a target phase. There are two kinds of jump scope:
  //
  // - local jump to another phase within the current schedule, back- or forwards
  // - global jump of all domains together, either to a point in the master
  //   schedule outwith the current schedule, or by calling jump_all()
  //
  // A jump preserves the existing soft synchronization, so the domain that is
  // ahead of schedule relative to another synchronized domain, as a result of
  // a jump in either domain, will await the domain that is behind schedule.
  //
  // *Note*: A jump out of the local schedule causes other schedules that have
  // the jump node in their schedule to jump as well. In some cases, it is
  // desirable to jump to a local phase in the schedule but to have all
  // schedules that share that phase to jump as well. In that situation, the
  // jump_all static function should be used. This function causes all schedules
  // that share a phase to jump to that phase.
 
  // Function: jump
  //
  // Jump to a specified ~phase~. The jump happens within the current 
  // phase schedule. If the jump-to ~phase~ is outside of the current schedule
  // then the jump affects other schedules which share the phase.
  //
  extern function void jump(uvm_phase_imp phase);


  // Function: jump_all
  //
  // Make all schedules jump to a specified ~phase~. The jump happens to all
  // phase schedules that contain the jump-to ~phase~, i.e. a global jump. 
  //
  extern static function void jump_all(uvm_phase_imp phase);


  //--------------------------
  // internal - implementation
  //--------------------------

  local uvm_phase_state    m_state;
  local int                m_run_count; // num times this phase has executed
  local process            m_phase_proc;
  local bit                m_jump_bkwd;
  local bit                m_jump_fwd;
  local uvm_phase_schedule m_jump_phase;

  protected string         m_schedule_name; // schedule unique name
  uvm_phase_schedule       m_parent;        // our 'begin' node [or points 'up' one level]
  uvm_phase_schedule       m_sync[];        // schedule instance to which we are synced
  uvm_phase_imp            m_phase;         // phase imp to call when we execute this node
  uvm_objection            phase_done;      // phase done objection
  uvm_phase_thread         m_threads[uvm_component]; // all active process threads
  event                    m_ready_to_end;


  local static mailbox #(uvm_phase_schedule) m_phase_hopper = new();
  local static uvm_process m_phase_top_procs[uvm_phase_schedule];
  local bit m_exit_on_task_return = 0;
  static bit m_has_rt_phases;

  extern static task m_run_phases();

  extern function void clear       (uvm_phase_state state = UVM_PHASE_DORMANT);
  extern function void clear_successors(
                                   uvm_phase_state state = UVM_PHASE_DORMANT);

  extern task          execute();
  extern function void terminate_phase();
  extern function void print_termination_state();
  extern function void kill();
  extern function void kill_successors();


  // TBD add more useful debug
  function string convert2string();
    return $sformatf("phase: %s parent=%s  %s",m_name,
           (m_parent==null) ? "null" : m_parent.m_schedule_name, super.convert2string());
  endfunction


endclass



//------------------------------------------------------------------------------
//                               IMPLEMENTATION
//------------------------------------------------------------------------------
typedef class uvm_cmdline_processor;

// new
// ---

function uvm_phase_schedule::new(string name, uvm_phase_schedule parent=null);
  string trace_args[$];
  uvm_cmdline_processor clp;

  super.new(name);

  clp = uvm_cmdline_processor::get_inst();
  if(clp.get_arg_matches("+UVM_EXIT_RUN_ON_TASK_RETURN", trace_args))
    m_exit_on_task_return = 1;

  if (name == "run") begin
    phase_done = uvm_test_done_objection::get();
  end
  else
    phase_done = new(name);

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


// get_schedule_name
// -----------------

function string uvm_phase_schedule::get_schedule_name();
  return m_schedule_name;
endfunction


// get_phase_name
// --------------

function string uvm_phase_schedule::get_phase_name();
  return (m_phase) ? m_phase.get_name() : "";
endfunction


// get_run_count
// -------------

function int uvm_phase_schedule::get_run_count();
  return m_run_count;
endfunction


// get_state
// ---------

function uvm_phase_state uvm_phase_schedule::get_state();
  return m_state;
endfunction


// add_phase
// ---------

function void uvm_phase_schedule::add_phase(uvm_phase_imp phase,
                                            uvm_phase_schedule with_phase=null,
                                            uvm_phase_schedule after_phase=null,
                                            uvm_phase_schedule before_phase=null);
  uvm_phase_schedule new_node;
  assert(phase != null);
  new_node = new(phase.get_name(),this);
  new_node.m_phase = phase;
  if (with_phase != null && (after_phase != null || before_phase != null)) begin
    `uvm_fatal("PH_BADPHADD",
               "cannot specify both 'with' and 'before'/'after' phase relationships");
  end
  if (with_phase == null && after_phase == null && before_phase == null) begin
    assert($cast(before_phase,find("end")));
  end
  //TBD error checks if param nodes are actually in this schedule or not
  // TBD Mantis enhancement to check if before_phase / after_phase order is legal
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
      // unstitch redundant links - TBD optimize
      foreach (before_phase.m_predecessors[i].m_successors[j]) begin
        if (before_phase.m_predecessors[i].m_successors[j] == before_phase) begin
          before_phase.m_predecessors[i].m_successors.delete(j);
        end
      end
    end
    before_phase.m_predecessors.delete();
    new_node.insert_successor(before_phase);
  end else if (before_phase == null && after_phase != null) begin
    // just after? add 1 pred and all succs
    // add all its successors as our successors
    foreach (after_phase.m_successors[i]) begin
      new_node.insert_successor(after_phase.m_successors[i]);
      // unstitch redundant links - TBD optimize
      foreach (after_phase.m_successors[i].m_predecessors[j]) begin
        if (after_phase.m_successors[i].m_predecessors[j] == after_phase) begin
          after_phase.m_successors[i].m_predecessors.delete(j);
        end
      end
    end
    after_phase.m_successors.delete();
    new_node.insert_predecessor(after_phase);
  end else if (before_phase != null && after_phase != null) begin
    // before and after? add 1 pred and 1 succ
    new_node.insert_predecessor(after_phase);
    new_node.insert_successor(before_phase);
    // unstitch redundant links - TBD optimize
    foreach (after_phase.m_successors[i]) begin
      if (after_phase.m_successors[i] == before_phase) begin
        after_phase.m_successors.delete(i);
      end
    end
    foreach (before_phase.m_predecessors[i]) begin
      if (before_phase.m_predecessors[i] == after_phase) begin
        before_phase.m_predecessors.delete(i);
      end
    end
  end
endfunction


// add_schedule
// ------------

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
    `uvm_fatal("PH_BADSCHADD",
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


// find_schedule
// -------------

function uvm_phase_schedule uvm_phase_schedule::find_schedule(string name);
  uvm_phase_schedule phase;
  uvm_graph graph_node;
  graph_node = super.find(name);
  assert($cast(phase, graph_node));
  return phase;
endfunction


// find_phase
// ----------

function uvm_phase_imp uvm_phase_schedule::find_phase(string name);
  uvm_phase_schedule phase;
  phase = this.find_schedule(name);
  return (phase != null) ? phase.m_phase : null;
endfunction


// jump
// ----
//
// Note that this function does not directly alter flow of control.
// That is, the new phase is not initiated in this function.
// Rather, flags are set which execute() uses to determine
// that a jump has been requested and performs the jump.

function void uvm_phase_schedule::jump(uvm_phase_imp phase);
  uvm_graph d;

  `uvm_info("PH_JUMP",
            $psprintf("schedule %s phase %s is jumping to phase %s",
                      get_schedule_name(), get_phase_name(), phase.get_name()),
            UVM_DEBUG);

  // A jump can be either forward or backwards in the phase graph.
  // If the specified phase (name) is found in the set of predecessors
  // then we are jumping backwards.  If, on the other hand, the phase is in the set
  // of successors then we are jumping forwards.  If neither, then we
  // have an error.
  //
  // If the phase is non-existant and thus we don't know where to jump
  // we have a situation where the only thing to do is to uvm_report_fatal
  // and terminate_phase.  By calling this function the intent was to
  // jump to some other phase. So, continuing in the current phase doesn't
  // make any sense.  And we don't have a valid phase to jump to.  So we're done.

  d = find_predecessor(phase.get_name());
  if(d == null) begin
    d = find_successor(phase.get_name());
    if(d == null) begin
      string msg;
      $sformat(msg,{"phase %s is neither a predecessor or successor of ",
                    "phase %s or is non-existant, so we cannot jump to it.  ",
                    "Phase control flow is now undefined so the simulation ",
                    "must terminate"}, phase.get_name(), get_name());
      `uvm_fatal("PH_BADJUMP", msg);
    end
    else begin
      m_jump_fwd = 1;
      `uvm_info("PH_JUMPF",$psprintf("jumping forward to phase %s", phase.get_name()),
                UVM_DEBUG);
    end
  end
  else begin
    m_jump_bkwd = 1;
    `uvm_info("PH_JUMPB",$psprintf("jumping backward to phase %s", phase.get_name()),
              UVM_DEBUG);
  end
  
  assert($cast(m_jump_phase, d));
  terminate_phase();
endfunction


// jump_all
// --------

function void uvm_phase_schedule::jump_all(uvm_phase_imp phase);
  // TBD integration task ongoing
endfunction


// clear
// -----
// for internal graph maintenance after a forward jump
function void uvm_phase_schedule::clear(
                                   uvm_phase_state state = UVM_PHASE_DORMANT);
  m_state = state;
  m_phase_proc = null;
  phase_done.clear();
endfunction


// clear_successors
// ----------------
// for internal graph maintenance after a forward jump
// - called only by execute()
// - depth-first traversal of the DAG, calliing clear() on each node
function void uvm_phase_schedule::clear_successors(
                                   uvm_phase_state state = UVM_PHASE_DORMANT);
  clear(state);
  foreach(m_successors[i]) begin
    uvm_phase_schedule p;
    assert($cast(p, m_successors[i]));
    p.clear_successors(state);
  end
endfunction


// kill
// ----

function void uvm_phase_schedule::kill();

  `uvm_info("PH_KILL", {"killing phase '", get_name(),"'"}, UVM_DEBUG);

  if (m_phase_proc != null) begin
    m_phase_proc.kill();
    m_phase_proc = null;
  end

endfunction


// kill_successors
// ---------------

// Using a depth-first traversal, kill all the successor phases of the
// current phase.
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


// m_run_phases
// ------------

// This task contains the top-level process that owns all the phase
// processes.  By hosting the phase processes here we avoid problems
// associated with phase processes related as parents/children
task uvm_phase_schedule::m_run_phases();
  uvm_root top = uvm_root::get();

  // initiate by starting first phase in common domain
  void'(m_phase_hopper.try_put(top.find_phase_schedule("uvm_pkg::common","common")));

  forever begin
    uvm_phase_schedule phase;
    uvm_process proc;
    m_phase_hopper.get(phase);
    fork
      begin
        proc = new(process::self());
        phase.execute();
      end
    join_none
    m_phase_top_procs[phase] = proc;
    #0;  // let the process start running
  end
endtask


// execute
// -------
//
// Execute a phase.
// - recursively exec successors
// - manage phase jumps
// - called by m_run_phases
// - calls uvm_phase_imp::traverse using our phase handle

task uvm_phase_schedule::execute();

  uvm_root top;
  top = uvm_root::get();

  // are the predecessors done, or are there no predecessors?
  // block until all the predecessors are done
  foreach (m_predecessors[i]) begin
    uvm_phase_schedule p;
    assert($cast(p, m_predecessors[i]));
    wait (p.m_state == UVM_PHASE_DONE);
  end

  /** kill predecessor procs here **/
  
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
  
  m_run_count++;

  `uvm_info("PH_START", $psprintf("STARTING PHASE %0s (in schedule %0s)",
                        this.get_name(),this.get_schedule_name()), UVM_DEBUG);
 
  if (m_phase != null) begin

    // TODO: Needed?
    //if (m_phase.get_name() == "run")
    //  phase_done = uvm_test_done_objection::get();

    //---------
    // STARTED:
    //---------
    // Phase execution is starting
    // Threads started in phase_started functions are not cleaned up
    m_state = UVM_PHASE_STARTED;
    #0; // LET ANY WAITERS WAKE UP
    m_phase.traverse(top,this,UVM_PHASE_STARTED);

    if (m_phase.get_phase_type() != UVM_PHASE_TASK) begin

      //-----------
      // EXECUTING: (function phases)
      //-----------
      m_state = UVM_PHASE_EXECUTING;
      #0; // LET ANY WAITERS WAKE UP
      m_phase.traverse(top,this,UVM_PHASE_EXECUTING);

    end
    else begin

      uvm_task_phase task_phase;
      assert($cast(task_phase,m_phase));

      fork : master_phase_process
        begin

          m_phase_proc = process::self();

          //-----------
          // EXECUTING: (task phases)
          //-----------
          m_state = UVM_PHASE_EXECUTING;
          task_phase.traverse(top,this,UVM_PHASE_EXECUTING);

          wait(0); // stay alive for later kill

        end
      join_none

      uvm_wait_for_nba_region(); //Give sequences, etc. a chance to object
      wait (task_phase.m_procs_not_yet_started == 0);

      // Now wait for one of three criterion for end-of-phase.
      fork
      begin // guard
         fork
           // EXIT CRITERIA 1: All objections dropped
           begin
             phase_done.wait_for(UVM_ALL_DROPPED, top);
           end
           // EXIT CRITERIA 2: All phase tasks return and no objections
           begin
               if (m_exit_on_task_return || m_phase.get_name() != "run") begin
                 wait (task_phase.m_num_procs_not_yet_returned == 0);
                 if (phase_done.get_objection_total() != 0)
                   wait (0);
               end
               else
                 wait (0);
           end
           // EXIT CRITERIA 3: Phase timeout
           begin
             if (top.phase_timeout == 0)
               wait(top.phase_timeout != 0);
             #(top.phase_timeout);
             `uvm_error("PH_TIMEOUT",
                 $sformatf("Phase timeout of %0t hit, phase '%s' ready to end",
                           top.phase_timeout, get_name()))
             phase_done.clear(this);
           end
         join_any
         disable fork;
      end
      join // guard

    end

  end

  //--------------
  // READY_TO_END:
  //--------------
  // Phase exit criterion met (no objections)
  // stay in READY_TO_END state for at least a delta
  `uvm_info("PH_READY_TO_END", $psprintf("PHASE READY TO END %0s (in schedule %0s) %0d",
                      this.get_name(),this.get_schedule_name(), get_inst_id()), UVM_DEBUG);
  m_state = UVM_PHASE_READY_TO_END;
  ->m_ready_to_end;


  //-----------------------
  // WAIT FOR PREDECESSORS:
  //-----------------------
  // to our successor(s) to be ready to proceed
  //$display("  ** Successors to phase '",get_name(),"':");
  //foreach (m_successors[i])
  //  $display("  **   ",m_successors[i].get_name());
  begin
    bit pred_of_succ[uvm_graph];

    foreach (m_successors[i]) begin
      uvm_graph succ = m_successors[i];
      foreach(succ.m_predecessors[j])
        pred_of_succ[ succ.m_predecessors[j] ] = 1;
    end
    pred_of_succ.delete(this);
    foreach (pred_of_succ[pred]) begin
      uvm_phase_schedule sched;
      assert($cast(sched, pred));
      //$display("  ** ", get_name(), " Waiting for phase '",
      //   sched.get_name(),"' (",sched.get_inst_id(),") to be ready to end");
      //$display("  ** ", get_name(), "    Current state is ",sched.m_state.name());
      if (sched.m_state != UVM_PHASE_READY_TO_END)
        //wait (sched.m_state == UVM_PHASE_READY_TO_END);
        wait(sched.m_ready_to_end.triggered);
      #0; // prevents any waiters from falling through until all reach ready-to-end
      //$display("  ** ", get_name(), " Released: Phase '",sched.get_name(),"' is now ready to end");
    end
  end
  #0; // LET ANY WAITERS WAKE UP


  //-------
  // ENDED:
  //-------
  // execeute 'phase_ended' callbacks
  `uvm_info("PH_END", $psprintf("ENDING PHASE %0s (in schedule %0s)",
                      this.get_name(),this.get_schedule_name()), UVM_DEBUG);
  m_state = UVM_PHASE_ENDED;
  if (m_phase != null)
    m_phase.traverse(top,this,UVM_PHASE_ENDED);
  #0; // LET ANY WAITERS WAKE UP


  //---------
  // CLEANUP:
  //---------
  // kill this phase's threads
  m_state = UVM_PHASE_CLEANUP;
  if (m_phase_proc != null) begin
    m_phase_proc.kill();
    m_phase_proc = null;
  end
  #0; // LET ANY WAITERS WAKE UP



  //------
  // DONE:
  //------
  // If no successors, we're done. (Presumes final node is always shared.)
  // Otherwise, schedule all the successor phases.
  `uvm_info("PH_DONE", $psprintf("PHASE DONE %0s (in schedule %0s)",
                      this.get_name(),this.get_schedule_name()), UVM_DEBUG);
  m_state = UVM_PHASE_DONE;
  m_phase_proc = null;
  #0; // LET ANY WAITERS WAKE UP


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
    void'(m_phase_hopper.try_put(m_jump_phase));
    return;
  end


  //-----------
  // SCHEDULED:
  //-----------
  // If more successors, schedule them to run now
  if(m_successors.size() == 0) begin
    top.m_phase_all_done=1;
  end 
  else begin
    // execute all the successors
    foreach (m_successors[i]) begin
      uvm_phase_schedule phase;
      assert($cast(phase, m_successors[i]));
      if(phase.m_state != UVM_PHASE_SCHEDULED) begin
        phase.m_state = UVM_PHASE_SCHEDULED; // moved here from begin of execute()
        #0; // LET ANY WAITERS WAKE UP
        void'(m_phase_hopper.try_put(phase));
      end
    end
  end

endtask


// raise_objection
// ---------------

function void uvm_phase_schedule::raise_objection (uvm_object obj, 
                                                   string description="",
                                                   int count=1);
  phase_done.raise_objection(obj,description,count);
endfunction


// drop_objection
// --------------

function void uvm_phase_schedule::drop_objection (uvm_object obj, 
                                                  string description="",
                                                  int count=1);
  phase_done.drop_objection(obj,description,count);
endfunction


// sync
// ----

function void uvm_phase_schedule::sync(uvm_phase_schedule target,
                                       uvm_phase_imp phase=null,
                                       uvm_phase_imp with_phase=null,
                                       uvm_phase_imp after_phase=null,
                                       uvm_phase_imp before_phase=null);
endfunction


// unsync
// ------

function void uvm_phase_schedule::unsync(uvm_phase_schedule target,
                                         uvm_phase_imp phase=null,
                                         uvm_phase_imp with_phase=null,
                                         uvm_phase_imp after_phase=null,
                                         uvm_phase_imp before_phase=null);
endfunction


// terminate_phase
// ---------------

function void uvm_phase_schedule::terminate_phase();
  phase_done.clear();
endfunction


// print_termination_state
// -----------------------

function void uvm_phase_schedule::print_termination_state();
  `uvm_info("PH_TERMSTATE",
            $psprintf("phase %s outstanding objections = %0d",
                      get_name(), phase_done.get_objection_total(uvm_top)),
            UVM_DEBUG);
endfunction


//----------------------------------------------------------------------
// End
//----------------------------------------------------------------------

`endif // UVM_PHASES_SVH
