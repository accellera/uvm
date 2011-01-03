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

typedef class uvm_objection;

//------------------------------------------------------------------------------
//
// CLASS: uvm_component
//
// The uvm_component class is the root base class for UVM components. In
// addition to the features inherited from <uvm_object> and <uvm_report_object>,
// uvm_component provides the following interfaces:
//
// Hierarchy - provides methods for searching and traversing the component
//     hierarchy.
//
// Phasing - defines a phased test flow that all components follow, with a
//     group of standard phase methods and an API for custom phases and
//     multiple independent phasing domains to mirror DUT behavior e.g. power
//
// Configuration - provides methods for configuring component topology and other
//     parameters ahead of and during component construction.
//
// Reporting - provides a convenience interface to the <uvm_report_handler>. All
//     messages, warnings, and errors are processed through this interface.
//
// Transaction recording - provides methods for recording the transactions
//     produced or consumed by the component to a transaction database (vendor
//     specific). 
//
// Factory - provides a convenience interface to the <uvm_factory>. The factory
//     is used to create new components and other objects based on type-wide and
//     instance-specific configuration.
//
// The uvm_component is automatically seeded during construction using UVM
// seeding, if enabled. All other objects must be manually reseeded, if
// appropriate. See <uvm_object::reseed> for more information.
//
//------------------------------------------------------------------------------

virtual class uvm_component extends uvm_report_object;

  // Function: new
  //
  // Creates a new component with the given leaf instance ~name~ and handle to
  // to its ~parent~.  If the component is a top-level component (i.e. it is
  // created in a static module or interface), ~parent~ should be null.
  //
  // The component will be inserted as a child of the ~parent~ object, if any.
  // If ~parent~ already has a child by the given ~name~, an error is produced.
  //
  // If ~parent~ is null, then the component will become a child of the
  // implicit top-level component, ~uvm_top~.
  //
  // All classes derived from uvm_component must call super.new(name,parent).

  extern function new (string name, uvm_component parent);


  //----------------------------------------------------------------------------
  // Group: Hierarchy Interface
  //----------------------------------------------------------------------------
  //
  // These methods provide user access to information about the component
  // hierarchy, i.e., topology.
  // 
  //----------------------------------------------------------------------------

  // Function: get_parent
  //
  // Returns a handle to this component's parent, or null if it has no parent.

  extern virtual function uvm_component get_parent ();


  // Function: get_full_name
  //
  // Returns the full hierarchical name of this object. The default
  // implementation concatenates the hierarchical name of the parent, if any,
  // with the leaf name of this object, as given by <uvm_object::get_name>. 

  extern virtual function string get_full_name ();


  // Function: get_child
  extern function uvm_component get_child (string name);

  // Function: get_next_child
  extern function int get_next_child (ref string name);

  // Function: get_first_child
  //
  // These methods are used to iterate through this component's children, if
  // any. For example, given a component with an object handle, ~comp~, the
  // following code calls <uvm_object::print> for each child:
  //
  //|    string name;
  //|    uvm_component child;
  //|    if (comp.get_first_child(name))
  //|      do begin
  //|        child = comp.get_child(name);
  //|        child.print();
  //|      end while (comp.get_next_child(name));

  extern function int get_first_child (ref string name);


  // Function: get_num_children
  //
  // Returns the number of this component's children. 

  extern function int get_num_children ();


  // Function: has_child
  //
  // Returns 1 if this component has a child with the given ~name~, 0 otherwise.

  extern function int has_child (string name);


  // Function: set_name
  //
  // Renames this component to ~name~ and recalculates all descendants'
  // full names.

  extern virtual function void set_name (string name);

  
  // Function: lookup
  //
  // Looks for a component with the given hierarchical ~name~ relative to this
  // component. If the given ~name~ is preceded with a '.' (dot), then the search
  // begins relative to the top level (absolute lookup). The handle of the
  // matching component is returned, else null. The name must not contain
  // wildcards.

  extern function uvm_component lookup (string name);


  // Function: get_depth
  //
  // Returns the component's depth from the root level. uvm_top has a
  // depth of 0. The test and any other top level components have a depth
  // of 1, and so on.

  extern function int unsigned get_depth();


  //----------------------------------------------------------------------------
  // Group: Phasing Interface
  //----------------------------------------------------------------------------
  //
  // These methods implement an interface which allows all components to step
  // through a standard schedule of phases, or a customized schedule, and
  // also an API to allow independent phase domains which can jump like state
  // machines to reflect behavior e.g. power domains on the DUT in different
  // portions of the testbench
  //
  //----------------------------------------------------------------------------


  // Function: build
  //
  // The build phase callback is the first of several methods automatically
  // called during the course of simulation. The build phase is the second of
  // a two-pass construction process (the first is the built-in new method).
  //
  // The build phase can add additional hierarchy based on configuration
  // information not available at time of initial construction. 
  // Any override should call super.build().
  //
  // Starting after the initial construction phase (<new> method) has completed,
  // the build phase consists of calling all components' build methods
  // recursively top-down, i.e., parents' build are executed before the
  // children. This is the only phase that executes top-down, except finalize()
  //
  // The build phase of the uvm_component class executes the automatic
  // configuration of fields registed in the component by calling 
  // <apply_config_settings>.  To turn off automatic configuration for a component, 
  // do not call super.build() in the subtype's build method.
  //
  // See <uvm_phases> for more information on phases.

  extern virtual function void build();

  // Function: connect
  //
  // The connect phase callback is one of several predefined phase
  // methods automatically called during the course of simulation.
  //
  // Starting after the <build> phase has completed, the connect phase consists
  // of calling all components' connect methods recursively in depth-first,
  // bottom-up order, i.e., children are executed before their parents.
  //
  // Generally, derived classes should override this method to make port and
  // export connections via the similarly-named <uvm_port_base #(IF)::connect>
  // method. Any override should call super.connect().
  //
  // This method should never be called directly. 
  //
  // See <uvm_phases> for more information on phases.

  extern virtual function void connect();

  // Function: end_of_elaboration
  //
  // The end_of_elaboration phase callback is one of several predefined phase
  // methods automatically called during the course of simulation.
  //
  // Starting after the <connect> phase has completed, this phase consists of
  // calling all components' end_of_elaboration methods recursively in
  // depth-first, bottom-up order, i.e., children are executed before their
  // parents. 
  //
  // Generally, derived classes should override this method to perform any
  // checks on the elaborated hierarchy before the simulation phases begin.
  // Any override should call super.end_of_elaboration().
  //
  // This method should never be called directly.
  //
  // See <uvm_phases> for more information on phases.

  extern virtual function void end_of_elaboration();

  // Function: start_of_simulation
  //
  // The start_of_simulation phase callback is one of several predefined phase
  // methods automatically called during the course of simulation.
  //
  // Starting after the <end_of_elaboration> phase has completed, this phase
  // consists of calling all components' start_of_simulation methods recursively
  // in depth-first, bottom-up order, i.e. children are executed before their
  // parents. 
  //
  // Generally, derived classes should override this method to perform component-
  // specific pre-run operations, such as discovery of the elaborated hierarchy,
  // printing banners, etc. Any override should call super.start_of_simulation().
  //
  // This method should never be called directly.
  //
  // See <uvm_phases> for more information on phases.

  extern virtual function void start_of_simulation();

  // Task: run
  //
  // The run phase callback is a predefined phase that is time-consuming,
  // i.e., task-based. It executes after the <start_of_simulation> phase has
  // completed. Derived classes should override this method to perform the bulk
  // of its functionality, forking additional processes if needed.
  //
  // In the run phase, all components' run tasks are forked as independent
  // processes.  Returning from its run task does not signify completion of a
  // component's run phase; any processes forked by run continue to run.
  //
  // The run phase terminates in one of four ways.
  //
  // 1 - explicit call to <global_stop_request> - 
  //   When <global_stop_request> is called, an ordered shut-down for the
  //   currently running phase begins. First, all enabled components' status
  //   tasks are called bottom-up, i.e., childrens' <stop> tasks are called before
  //   the parent's. A component is enabled by its enable_stop_interrupt bit.
  //   Each component can implement stop to allow completion of in-progress
  //   transactions, flush queues, and other shut-down activities. Upon return
  //   from stop by all enabled components, the recursive do_kill_all is called
  //   on all top-level component(s).  If the <uvm_test_done> objection> is being
  //   used, this stopping procedure is deferred until all outstanding objections
  //   on <uvm_test_done> have been dropped.
  //
  // 2 - all objections to <uvm_test_done> have been dropped -
  //   When all objections on the <uvm_test_done> objection have been dropped,
  //   <global_stop_request> is called automatically, thus kicking off the
  //   stopping procedure described above. See <uvm_objection> for details on
  //   using the objection mechanism.
  //
  // 3 - explicit call to <kill> or <do_kill_all> -
  //   When <kill> is called, this component's run processes are killed immediately.
  //   The <do_kill_all> methods applies to this component and all its
  //   descendants. Use of this method is not recommended. It is better to use
  //   the stopping mechanism, which affords a more ordered, safer shut-down.
  //
  // 4 - timeout -
  //   The phase ends if the timeout expires before an explicit call to
  //   <global_stop_request> or kill. By default, the timeout is set to near the
  //   maximum simulation time possible. You may override this via
  //   <set_global_timeout>, but you cannot disable the timeout completely.
  //
  //   If the default timeout occurs in your simulation, or if simulation never
  //   ends despite completion of your test stimulus, then it usually indicates
  //   a missing call to <global_stop_request>.
  //
  // The run task should never be called directly.
  //
  // See <uvm_phases> for more information on phases.

  extern virtual task run();

  // Function: extract
  //
  // The extract phase callback is one of several predefined phase
  // methods automatically called during the course of simulation.
  //
  // Starting after the <run> phase has completed, the extract phase consists of
  // calling all components' extract methods recursively in depth-first,
  // bottom-up order, i.e., children are executed before their parents. 
  //
  // Generally, derived classes should override this method to collect
  // information for the subsequent <check> phase when such information needs to
  // be collected in a hierarchical, bottom-up manner. Any override should
  // call super.extract().
  //
  // This method should never be called directly.
  //
  // See <uvm_phases> for more information on phases.

  extern virtual function void extract();

  // Function: check
  //
  // The check phase callback is one of several predefined phase
  // methods automatically called during the course of simulation.
  //
  // Starting after the <extract> phase has completed, the check phase consists of
  // calling all components' check methods recursively in depth-first, bottom-up
  // order, i.e., children are executed before their parents. 
  //
  // Generally, derived classes should override this method to perform component
  // specific, end-of-test checks. Any override should call super.check().
  //
  // This method should never be called directly.
  //
  // See <uvm_phases> for more information on phases.

  extern virtual function void check();

  // Function: report
  //
  // The report phase callback is one of several predefined phase
  // methods automatically called during the course of simulation.
  //
  // Starting after the <check> phase has completed, the report phase consists
  // of calling all components' report methods recursively in depth-first,
  // bottom-up order, i.e., children are executed before their parents. 
  //
  // Generally, derived classes should override this method to perform
  // component-specific reporting of test results. Any override should
  // call super.report().
  //
  // This method should never be called directly.
  //
  // See <uvm_phases> for more information on phases.

  extern virtual function void report();

  // Function: finalize
  //
  // The report phase callback is the last of several predefined phase
  // methods automatically called during the course of simulation.
  //
  // Starting after the <report> phase has completed, the finalize phase consists
  // of calling all components' finalize methods recursively in top-down
  // order, i.e., parents are executed before their children. 
  //
  // The finalize phase callback is used to support multiple concatenated
  // test schemes where the build..report phases (or subset of them) are
  // executed repeatedly once per test, looping back after the report phase.
  // This provides one final phase after that looping, before simulation exit.
  //
  // This method should never be called directly.
  //
  // See <uvm_phases> for more information on phases.
  
  extern virtual function void finalize();

  // Task: pre_reset
  //
  // UVM standard runtime phase
  // This is the first UVM runtime phase commencing in parallel with run()

  extern virtual task pre_reset();

  // Task: reset
  //
  // UVM standard runtime phase

  extern virtual task reset();

  // Task: post_reset
  //
  // UVM standard runtime phase

  extern virtual task post_reset();

  // Task: pre_configure
  //
  // UVM standard runtime phase

  extern virtual task pre_configure();

  // Task: configure
  //
  // UVM standard runtime phase

  extern virtual task configure();

  // Task: post_configure
  //
  // UVM standard runtime phase

  extern virtual task post_configure();

  // Task: pre_main
  //
  // UVM standard runtime phase

  extern virtual task pre_main();

  // Task: main
  //
  // UVM standard runtime phase

  extern virtual task main();

  // Task: post_main
  //
  // UVM standard runtime phase
  // Not normally used - included only for symmetry

  extern virtual task post_main();

  // Task: pre_shutdown
  //
  // UVM standard runtime phase
  // Not normally used - included only for symmetry

  extern virtual task pre_shutdown();

  // Task: shutdown
  //
  // UVM standard runtime phase
  // This phase is the one jumped to at end of test / global stop request

  extern virtual task shutdown();

  // Task: post_shutdown
  //
  // UVM standard runtime phase
  // This is the last UVM runtime task-based phase before the extract phase

  extern virtual task post_shutdown();


  //--------------------------------------------------------------------
  // current phase convenience API
  //--------------------------------------------------------------------


  // Function: phase_started
  // Phase transition callback, invoked at beginning of each phase
  //   phase - the current phase schedule node in the graph

  extern virtual function void phase_started (uvm_phase_schedule phase);

  // Function: phase_ended
  // Phase transition callback, invoked at end of each phase
  //   phase - the current phase schedule node in the graph
  
  extern virtual function void phase_ended (uvm_phase_schedule phase);
  
  // Function: get_current_phase
  // Return the phase schedule node which initiated the current process thread

  extern function uvm_phase_schedule get_current_phase();

  // Function: find_phase_domain
  // Return the domain name set for our uvm schedule (or another specific schedule)
  //   schedule_name - the schedule name to return domain for - default 'uvm'
  
  extern function string find_phase_domain(string schedule_name="uvm_pkg::uvm");

  // Function: find_phase_schedule
  // Locate a schedule/domain pair in this component's list, "*" matches any name

  extern function uvm_phase_schedule find_phase_schedule(string name, string domain);

  // Function: add_phase_schedule
  // insert a new schedule/domain entry in this component's domain membership list

  extern function void add_phase_schedule(uvm_phase_schedule schedule, string domain);

  // Function: delete_phase_schedule
  // delete a schedule entry from this component's domain membership list

  extern function void delete_phase_schedule(uvm_phase_schedule schedule);


  //--------------------------------------------------------------------
  // phase / schedule / domain API
  //--------------------------------------------------------------------

  
  // Function: set_phase_domain
  // Apply a phase domain to this component (by default, also to it's children)
  // Sets up all schedule data structures in master phasing graph if a new domain.

  extern virtual function void set_phase_domain(string domain_name, int hier=1);

  // Function: set_phase_schedule
  //
  // Defines the phase schedule for this base type of component, adds it to the master.
  //
  // Here we define the structure and organization of a schedule for this component
  // base type (uvm_component). We give that schedule a name ('uvm') and we add a named
  // instance of the schedule (a 'domain') to the master phasing schedule graph, if it
  // does not already exist there.
  //
  // Custom component base classes requiring a custom phasing schedule to augment or
  // replace the default UVM schedule can override this method. They can inherit the
  // parent schedule and build on it by calling super.set_phase_schedule(domain_name)
  // or they can create a new schedule from scratch by not calling the super method.

  extern virtual function void set_phase_schedule(string domain_name);

  // Function: set_phase_imp
  //
  // Override the default implementation for a phase on this component (tree) with a
  // custom one, which must be created as a singleton object extending the default
  // one and implementing required behavior in exec and traverse methods
  //
  // Can choose whether to apply the custom functor to the whole tree or just component

  extern function void set_phase_imp(uvm_phase_imp phase, uvm_phase_imp imp, int hier=1);

  // Function: raise_objection
  //
  // Raises an objection to the end of the current phase. The current phase
  // ends when all objections to the phase have been dropped. The ~phase~
  // argument must be provided. If null, uvm will call <get_current_phase>
  // but this is only successful if the function call is made in the
  // main phase process (not from a child process). It is a good practice
  // to get the phase process before forking any child process. For example:
  //
  //| task main;
  //|   uvm_phase_schedule phase = get_current_phase();
  //|   fork begin
  //|     raise_objection(phase);
  //|     ...
  //|     drop_objection(phase);
  //|   end join_none
  //|   ...
  //| endtask

  extern function void raise_objection(uvm_phase_schedule phase=null);


  // Function: drop_objection
  //
  // Drops an objection to the end of the current phase. The current phase
  // ends when all objections to the phase have been dropped. The ~phase~
  // argument must be provided. If null, uvm will call <get_current_phase>
  // but this is only successful if the function call is made in the
  // main phase process (not from a child process). It is a good practice
  // to get the phase process before forking any child process. 

  extern function void drop_objection(uvm_phase_schedule phase=null); 


  // Function: terminate_phase
  //
  // Forces all objections to the ~phase~ to be immediately dropped
  // so that the phase can end.

  extern function void terminate_phase(uvm_phase_schedule phase=null);

  
  // Function: jump
  extern function void jump(uvm_phase_imp phase);
  
  // Function: jump_all_domains
  extern function void jump_all_domains(uvm_phase_imp phase);
  
  // Function: set_default_thread_mode
  // Specify default thread semantic for all phases on this component
  extern function void set_default_thread_mode(uvm_thread_mode_t thread_mode);
  
  // Function: set_thread_mode
  // Override default thread semantic for the current phase on this component
  extern function void set_thread_mode(uvm_thread_mode_t thread_mode);
  
  // Phasing implementation
  // Internal members for phasing process control, hierarchical schedules, functors
  
  string             m_phase_domains[uvm_phase_schedule]; // domain(s) we have set, per schedule
  uvm_phase_thread   m_phase_threads[uvm_phase_schedule]; // phases we have active threads for
  uvm_phase_imp      m_phase_imps[uvm_phase_imp];         // functors to override ovm_root defaults
  uvm_thread_mode_t  m_phase_thread_mode;                 // default thread semantic for this comp
  uvm_phase_schedule m_current_phase;                     // the most recently executed phase
  /*protected*/ bit  m_build_done=0;


  // Task: suspend
  //
  // Suspends the process tree spawned from this component's currently
  // executing task-based phase, e.g. <run>.

  extern virtual task suspend ();


  // Task: resume
  //
  // Resumes the process tree spawned from this component's currently
  // executing task-based phase, e.g. <run>.

  extern virtual task resume ();


  // Function: status
  //
  // Returns the status of the parent process associated with the currently
  // running task-based phase, e.g., <run>.

  extern function string status ();

 
  // Function: kill
  //
  // Kills the process tree associated with this component's currently running
  // task-based phase, e.g., <run>.
  //
  // An alternative mechanism for stopping the <run> phase is the stop request.
  // Calling <global_stop_request> causes all components' run processes to be
  // killed, but only after all components have had the opportunity to complete
  // in progress transactions and shutdown cleanly via their <stop> tasks.

  extern virtual function void kill ();


  // Function: do_kill_all
  //
  // Recursively calls <kill> on this component and all its descendants,
  // which abruptly ends the currently running task-based phase, e.g., <run>.
  // See <run> for better options to ending a task-based phase.

  extern virtual  function void  do_kill_all ();


  // Task: stop
  //
  // The stop task is called when this component's <enable_stop_interrupt> bit
  // is set and <global_stop_request> is called during a task-based phase,
  // e.g., <run>.
  //
  // Before a phase is abruptly ended, e.g., when a test deems the simulation
  // complete, some components may need extra time to shut down cleanly. Such
  // components may implement stop to finish the currently executing
  // transaction, flush the queue, or perform other cleanup. Upon return from
  // its stop, a component signals it is ready to be stopped. 
  //
  // The stop method will not be called if <enable_stop_interrupt> is 0.
  //
  // The default implementation of stop is empty, i.e., it will return immediately.
  //
  // This method should never be called directly.

  extern virtual task stop (string ph_name);


  // Variable: enable_stop_interrupt
  //
  // This bit allows a component to raise an objection to the stopping of the
  // current phase. It affects only time consuming phases (such as the <run>
  // phase).
  //
  // When this bit is set, the <stop> task in the component is called as a result
  // of a call to <global_stop_request>. Components that are sensitive to an
  // immediate killing of its run-time processes should set this bit and
  // implement the stop task to prepare for shutdown.

  protected int enable_stop_interrupt = 0;


  // Function: resolve_bindings
  //
  // Processes all port, export, and imp connections. Checks whether each port's
  // min and max connection requirements are met.
  //
  // It is called just before the <end_of_elaboration> phase.
  //
  // Users should not call directly.

  extern virtual function void resolve_bindings ();



  //----------------------------------------------------------------------------
  // Group: Configuration Interface
  //----------------------------------------------------------------------------
  //
  // Components can be designed to be user-configurable in terms of its
  // topology (the type and number of children it has), mode of operation, and
  // run-time parameters (knobs). The configuration interface accommodates
  // this common need, allowing component composition and state to be modified
  // without having to derive new classes or new class hierarchies for
  // every configuration scenario. 
  //
  //----------------------------------------------------------------------------


  // Used for caching config settings
  static bit m_config_set = 1;

  extern function string massage_scope(string scope);

  // Function: set_config_int

  extern virtual function void set_config_int (string inst_name,  
                                               string field_name,
                                               uvm_bitstream_t value);

  // Function: set_config_string

  extern virtual function void set_config_string (string inst_name,  
                                                  string field_name,
                                                  string value);

  // Function: set_config_object
  //
  // Calling set_config_* causes configuration settings to be created and
  // placed in a table internal to this component. There are similar global
  // methods that store settings in a global table. Each setting stores the
  // supplied ~inst_name~, ~field_name~, and ~value~ for later use by descendent
  // components during their construction. (The global table applies to
  // all components and takes precedence over the component tables.)
  //
  // When a descendant component calls a get_config_* method, the ~inst_name~
  // and ~field_name~ provided in the get call are matched against all the
  // configuration settings stored in the global table and then in each
  // component in the parent hierarchy, top-down. Upon the first match, the
  // value stored in the configuration setting is returned. Thus, precedence is
  // global, following by the top-level component, and so on down to the
  // descendent component's parent.
  //
  // These methods work in conjunction with the get_config_* methods to
  // provide a configuration setting mechanism for integral, string, and
  // uvm_object-based types. Settings of other types, such as virtual interfaces
  // and arrays, can be indirectly supported by defining a class that contains
  // them.
  //
  // Both ~inst_name~ and ~field_name~ may contain wildcards.
  //
  // - For set_config_int, ~value~ is an integral value that can be anything
  //   from 1 bit to 4096 bits.
  //
  // - For set_config_string, ~value~ is a string.
  //
  // - For set_config_object, ~value~ must be an <uvm_object>-based object or
  //   null.  Its clone argument specifies whether the object should be cloned.
  //   If set, the object is cloned both going into the table (during the set)
  //   and coming out of the table (during the get), so that multiple components
  //   matched to the same setting (by way of wildcards) do not end up sharing
  //   the same object.
  //
  //   The following message tags are used for configuration setting. You can
  //   use the standard uvm report messaging interface to control these
  //   messages.
  //     CFGNTS    -- The configuration setting was not used by any component.
  //                  This is a warning.
  //     CFGOVR    -- The configuration setting was overridden by a setting above.
  //     CFGSET    -- The configuration setting was used at least once.
  //
  //
  // See <get_config_int>, <get_config_string>, and <get_config_object> for
  // information on getting the configurations set by these methods.


  extern virtual function void set_config_object (string inst_name,  
                                                  string field_name,
                                                  uvm_object value,  
                                                  bit clone=1);


  // Function: get_config_int

  extern virtual function bit get_config_int (string field_name,
                                              inout uvm_bitstream_t value);

  // Function: get_config_string

  extern virtual function bit get_config_string (string field_name,
                                                 inout string value);

  // Function: get_config_object
  //
  // These methods retrieve configuration settings made by previous calls to
  // their set_config_* counterparts. As the methods' names suggest, there is
  // direct support for integral types, strings, and objects.  Settings of other
  // types can be indirectly supported by defining an object to contain them.
  //
  // Configuration settings are stored in a global table and in each component
  // instance. With each call to a get_config_* method, a top-down search is
  // made for a setting that matches this component's full name and the given
  // ~field_name~. For example, say this component's full instance name is
  // top.u1.u2. First, the global configuration table is searched. If that
  // fails, then it searches the configuration table in component 'top',
  // followed by top.u1. 
  //
  // The first instance/field that matches causes ~value~ to be written with the
  // value of the configuration setting and 1 is returned. If no match
  // is found, then ~value~ is unchanged and the 0 returned.
  //
  // Calling the get_config_object method requires special handling. Because
  // ~value~ is an output of type <uvm_object>, you must provide an uvm_object
  // handle to assign to (_not_ a derived class handle). After the call, you can
  // then $cast to the actual type.
  //
  // For example, the following code illustrates how a component designer might
  // call upon the configuration mechanism to assign its ~data~ object property,
  // whose type myobj_t derives from uvm_object.
  //
  //|  class mycomponent extends uvm_component;
  //|
  //|    local myobj_t data;
  //|
  //|    function void build();
  //|      uvm_object tmp;
  //|      super.build();
  //|      if(get_config_object("data", tmp))
  //|        if (!$cast(data, tmp))
  //|          $display("error! config setting for 'data' not of type myobj_t");
  //|        endfunction
  //|      ...
  //
  // The above example overrides the <build> method. If you want to retain
  // any base functionality, you must call super.build().
  //
  // The ~clone~ bit clones the data inbound. The get_config_object method can
  // also clone the data outbound.
  //
  // See Members for information on setting the global configuration table.

  extern virtual function bit get_config_object (string field_name,
                                                 inout uvm_object value,  
                                                 input bit clone=1);


  // Function: check_config_usage
  //
  // Check all configuration settings in a components configuration table
  // to determine if the setting has been used, overridden or not used.
  // When ~recurse~ is 1 (default), configuration for this and all child
  // components are recursively checked. This function is automatically
  // called in the check phase, but can be manually called at any time.
  //
  // Additional detail is provided by the following message tags:
  // * CFGOVR -- lists all configuration settings that have been overridden
  // from above.  
  // * CFGSET -- lists all configuration settings that have been set.
  //
  // To get all configuration information prior to the run phase, do something 
  // like this in your top object:
  //|  function void start_of_simulation();
  //|    set_report_id_action_hier("CFGOVR", UVM_DISPLAY);
  //|    set_report_id_action_hier("CFGSET", UVM_DISPLAY);
  //|    check_config_usage();
  //|  endfunction

  extern function void check_config_usage (bit recurse=1);


  // Function: apply_config_settings
  //
  // Searches for all config settings matching this component's instance path.
  // For each match, the appropriate set_*_local method is called using the
  // matching config setting's field_name and value. Provided the set_*_local
  // method is implemented, the component property associated with the
  // field_name is assigned the given value. 
  //
  // This function is called by <uvm_component::build>.
  //
  // The apply_config_settings method determines all the configuration
  // settings targeting this component and calls the appropriate set_*_local
  // method to set each one. To work, you must override one or more set_*_local
  // methods to accommodate setting of your component's specific properties.
  // Any properties registered with the optional `uvm_*_field macros do not
  // require special handling by the set_*_local methods; the macros provide
  // the set_*_local functionality for you. 
  //
  // If you do not want apply_config_settings to be called for a component,
  // then the build() method should be overloaded and you should not call
  // super.build(). Likewise, apply_config_settings can be overloaded to
  // customize automated configuration.
  //
  // When the ~verbose~ bit is set, all overrides are printed as they are
  // applied. If the component's <print_config_matches> property is set, then
  // apply_config_settings is automatically called with ~verbose~ = 1.

  extern virtual function void apply_config_settings (bit verbose=0);


  // Function: print_config_settings
  //
  // Called without arguments, print_config_settings prints all configuration
  // information for this component, as set by previous calls to set_config_*.
  // The settings are printing in the order of their precedence.
  // 
  // If ~field~ is specified and non-empty, then only configuration settings
  // matching that field, if any, are printed. The field may not contain
  // wildcards. 
  //
  // If ~comp~ is specified and non-null, then the configuration for that
  // component is printed.
  //
  // If ~recurse~ is set, then configuration information for all ~comp~'s
  // children and below are printed as well.
  //
  // This function has been deprecated.  Use print_config instead.

  extern function void print_config_settings (string field="", 
                                              uvm_component comp=null, 
                                              bit recurse=0);

  // Function: print_config
  //
  // Print_config_settings prints all configuration information for this
  // component, as set by previous calls to set_config_* and exports to
  // the resources pool.  The settings are printing in the order of
  // their precedence.
  //
  // If ~recurse~ is set, then configuration information for all
  // children and below are printed as well.
  //
  // if ~audit~ is set then the audit trail for each resource is printed
  // along with the resource name and value

  extern function void print_config(bit recurse = 0, bit audit = 0);

  // Function: print_config_with_audit
  //
  // Operates the same as print_config except that the audit bit is
  // forced to 1.  This interface makes user code a bit more readable as
  // it avoids multiple arbitrary bit settings in the argument list.
  //
  // If ~recurse~ is set, then configuration information for all
  // children and below are printed as well.

  extern function void print_config_with_audit(bit recurse = 0);

  // Variable: print_config_matches
  //
  // Setting this static variable causes get_config_* to print info about
  // matching configuration settings as they are being applied.

  static bit print_config_matches = 0; 


  //----------------------------------------------------------------------------
  // Group: Objection Interface
  //----------------------------------------------------------------------------
  //
  // These methods provide object level hooks into the <uvm_objection> 
  // mechanism.
  // 
  //----------------------------------------------------------------------------


  // Function: raised
  //
  // The raised callback is called when a decendant of the component instance
  // raises the specfied ~objection~. The ~source_obj~ is the object which
  // originally raised the object. ~count~ is an optional count that was used
  // to indicate a number of objections which were raised.

  virtual function void raised (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
  endfunction


  // Function: dropped
  //
  // The dropped callback is called when a decendant of the component instance
  // raises the specfied ~objection~. The ~source_obj~ is the object which
  // originally dropped the object. ~count~ is an optional count that was used
  // to indicate a number of objections which were dropped.

  virtual function void dropped (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
  endfunction


  // Task: all_dropped
  //
  // The all_dropped callback is called when a decendant of the component instance
  // raises the specfied ~objection~. The ~source_obj~ is the object which
  // originally all_dropped the object. ~count~ is an optional count that was used
  // to indicate a number of objections which were dropped. This callback is
  // time-consuming and the all_dropped conditional will not be propagated
  // up to the object's parent until the callback returns.

  virtual task all_dropped (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
  endtask


  //----------------------------------------------------------------------------
  // Group: Factory Interface
  //----------------------------------------------------------------------------
  //
  // The factory interface provides convenient access to a portion of UVM's
  // <uvm_factory> interface. For creating new objects and components, the
  // preferred method of accessing the factory is via the object or component
  // wrapper (see <uvm_component_registry #(T,Tname)> and
  // <uvm_object_registry #(T,Tname)>). The wrapper also provides functions
  // for setting type and instance overrides.
  //
  //----------------------------------------------------------------------------

  // Function: create_component
  //
  // A convenience function for <uvm_factory::create_component_by_name>,
  // this method calls upon the factory to create a new child component
  // whose type corresponds to the preregistered type name, ~requested_type_name~,
  // and instance name, ~name~. This method is equivalent to:
  //
  //|  factory.create_component_by_name(requested_type_name,
  //|                                   get_full_name(), name, this);
  //
  // If the factory determines that a type or instance override exists, the type
  // of the component created may be different than the requested type. See
  // <set_type_override> and <set_inst_override>. See also <uvm_factory> for
  // details on factory operation.

  extern function uvm_component create_component (string requested_type_name, 
                                                  string name);


  // Function: create_object
  //
  // A convenience function for <uvm_factory::create_object_by_name>,
  // this method calls upon the factory to create a new object
  // whose type corresponds to the preregistered type name,
  // ~requested_type_name~, and instance name, ~name~. This method is
  // equivalent to:
  //
  //|  factory.create_object_by_name(requested_type_name,
  //|                                get_full_name(), name);
  //
  // If the factory determines that a type or instance override exists, the
  // type of the object created may be different than the requested type.  See
  // <uvm_factory> for details on factory operation.

  extern function uvm_object create_object (string requested_type_name,
                                            string name="");


  // Function: set_type_override_by_type
  //
  // A convenience function for <uvm_factory::set_type_override_by_type>, this
  // method registers a factory override for components and objects created at
  // this level of hierarchy or below. This method is equivalent to:
  //
  //|  factory.set_type_override_by_type(original_type, override_type,replace);
  //
  // The ~relative_inst_path~ is relative to this component and may include
  // wildcards. The ~original_type~ represents the type that is being overridden.
  // In subsequent calls to <uvm_factory::create_object_by_type> or
  // <uvm_factory::create_component_by_type>, if the requested_type matches the
  // ~original_type~ and the instance paths match, the factory will produce
  // the ~override_type~. 
  //
  // The original and override type arguments are lightweight proxies to the
  // types they represent. See <set_inst_override_by_type> for information
  // on usage.

  extern static function void set_type_override_by_type
                                             (uvm_object_wrapper original_type, 
                                              uvm_object_wrapper override_type,
                                              bit replace=1);


  // Function: set_inst_override_by_type
  //
  // A convenience function for <uvm_factory::set_inst_override_by_type>, this
  // method registers a factory override for components and objects created at
  // this level of hierarchy or below. In typical usage, this method is
  // equivalent to:
  //
  //|  factory.set_inst_override_by_type({get_full_name(),".",
  //|                                     relative_inst_path},
  //|                                     original_type,
  //|                                     override_type);
  //
  // The ~relative_inst_path~ is relative to this component and may include
  // wildcards. The ~original_type~ represents the type that is being overridden.
  // In subsequent calls to <uvm_factory::create_object_by_type> or
  // <uvm_factory::create_component_by_type>, if the requested_type matches the
  // ~original_type~ and the instance paths match, the factory will produce the
  // ~override_type~. 
  //
  // The original and override types are lightweight proxies to the types they
  // represent. They can be obtained by calling ~type::get_type()~, if
  // implemented by ~type~, or by directly calling ~type::type_id::get()~, where 
  // ~type~ is the user type and ~type_id~ is the name of the typedef to
  // <uvm_object_registry #(T,Tname)> or <uvm_component_registry #(T,Tname)>.
  //
  // If you are employing the `uvm_*_utils macros, the typedef and the get_type
  // method will be implemented for you. For details on the utils macros
  // refer to <Utility and Field Macros for Components and Objects>.
  //
  // The following example shows `uvm_*_utils usage:
  //
  //|  class comp extends uvm_component;
  //|    `uvm_component_utils(comp)
  //|    ...
  //|  endclass
  //|
  //|  class mycomp extends uvm_component;
  //|    `uvm_component_utils(mycomp)
  //|    ...
  //|  endclass
  //|
  //|  class block extends uvm_component;
  //|    `uvm_component_utils(block)
  //|    comp c_inst;
  //|    virtual function void build();
  //|      set_inst_override_by_type("c_inst",comp::get_type(),
  //|                                         mycomp::get_type());
  //|    endfunction
  //|    ...
  //|  endclass

  extern function void set_inst_override_by_type(string relative_inst_path,  
                                                 uvm_object_wrapper original_type,
                                                 uvm_object_wrapper override_type);


  // Function: set_type_override
  //
  // A convenience function for <uvm_factory::set_type_override_by_name>,
  // this method configures the factory to create an object of type
  // ~override_type_name~ whenever the factory is asked to produce a type
  // represented by ~original_type_name~.  This method is equivalent to:
  //
  //|  factory.set_type_override_by_name(original_type_name,
  //|                                    override_type_name, replace);
  //
  // The ~original_type_name~ typically refers to a preregistered type in the
  // factory. It may, however, be any arbitrary string. Subsequent calls to
  // create_component or create_object with the same string and matching
  // instance path will produce the type represented by override_type_name.
  // The ~override_type_name~ must refer to a preregistered type in the factory. 

  extern static function void set_type_override(string original_type_name, 
                                                string override_type_name,
                                                bit    replace=1);


  // Function: set_inst_override
  //
  // A convenience function for <uvm_factory::set_inst_override_by_type>, this
  // method registers a factory override for components created at this level
  // of hierarchy or below. In typical usage, this method is equivalent to:
  //
  //|  factory.set_inst_override_by_name({get_full_name(),".",
  //|                                     relative_inst_path},
  //|                                      original_type_name,
  //|                                     override_type_name);
  //
  // The ~relative_inst_path~ is relative to this component and may include
  // wildcards. The ~original_type_name~ typically refers to a preregistered type
  // in the factory. It may, however, be any arbitrary string. Subsequent calls
  // to create_component or create_object with the same string and matching
  // instance path will produce the type represented by ~override_type_name~.
  // The ~override_type_name~ must refer to a preregistered type in the factory. 

  extern function void set_inst_override(string relative_inst_path,  
                                         string original_type_name,
                                         string override_type_name);


  // Function: print_override_info
  //
  // This factory debug method performs the same lookup process as create_object
  // and create_component, but instead of creating an object, it prints
  // information about what type of object would be created given the
  // provided arguments.

  extern function void print_override_info(string requested_type_name,
                                           string name="");


  //----------------------------------------------------------------------------
  // Group: Hierarchical Reporting Interface
  //----------------------------------------------------------------------------
  //
  // This interface provides versions of the set_report_* methods in the
  // <uvm_report_object> base class that are applied recursively to this
  // component and all its children.
  //
  // When a report is issued and its associated action has the LOG bit set, the
  // report will be sent to its associated FILE descriptor.
  //----------------------------------------------------------------------------

  // Function: set_report_id_verbosity_hier

  extern function void set_report_id_verbosity_hier (string id,
                                                  int verbosity);

  // Function: set_report_severity_id_verbosity_hier
  //
  // These methods recursively associate the specified verbosity with reports of
  // the given ~severity~, ~id~, or ~severity-id~ pair. An verbosity associated
  // with a particular severity-id pair takes precedence over an verbosity
  // associated with id, which takes precedence over an an verbosity associated
  // with a severity.
  //
  // For a list of severities and their default verbosities, refer to
  // <uvm_report_handler>.

  extern function void set_report_severity_id_verbosity_hier(uvm_severity severity,
                                                          string id,
                                                          int verbosity);


  // Function: set_report_severity_action_hier

  extern function void set_report_severity_action_hier (uvm_severity severity,
                                                        uvm_action action);


  // Function: set_report_id_action_hier

  extern function void set_report_id_action_hier (string id,
                                                  uvm_action action);

  // Function: set_report_severity_id_action_hier
  //
  // These methods recursively associate the specified action with reports of
  // the given ~severity~, ~id~, or ~severity-id~ pair. An action associated
  // with a particular severity-id pair takes precedence over an action
  // associated with id, which takes precedence over an an action associated
  // with a severity.
  //
  // For a list of severities and their default actions, refer to
  // <uvm_report_handler>.

  extern function void set_report_severity_id_action_hier(uvm_severity severity,
                                                          string id,
                                                          uvm_action action);



  // Function: set_report_default_file_hier

  extern function void set_report_default_file_hier (UVM_FILE file);

  // Function: set_report_severity_file_hier

  extern function void set_report_severity_file_hier (uvm_severity severity,
                                                      UVM_FILE file);

  // Function: set_report_id_file_hier

  extern function void set_report_id_file_hier (string id,
                                                UVM_FILE file);

  // Function: set_report_severity_id_file_hier
  //
  // These methods recursively associate the specified FILE descriptor with
  // reports of the given ~severity~, ~id~, or ~severity-id~ pair. A FILE
  // associated with a particular severity-id pair takes precedence over a FILE
  // associated with id, which take precedence over an a FILE associated with a
  // severity, which takes precedence over the default FILE descriptor.
  //
  // For a list of severities and other information related to the report
  // mechanism, refer to <uvm_report_handler>.

  extern function void set_report_severity_id_file_hier(uvm_severity severity,
                                                        string id,
                                                        UVM_FILE file);


  // Function: set_report_verbosity_level_hier
  //
  // This method recursively sets the maximum verbosity level for reports for
  // this component and all those below it. Any report from this component
  // subtree whose verbosity exceeds this maximum will be ignored.
  // 
  // See <uvm_report_handler> for a list of predefined message verbosity levels
  // and their meaning.

    extern function void set_report_verbosity_level_hier (int verbosity);
  

  //----------------------------------------------------------------------------
  // Group: Recording Interface
  //----------------------------------------------------------------------------
  // These methods comprise the component-based transaction recording
  // interface. The methods can be used to record the transactions that
  // this component "sees", i.e. produces or consumes.
  //
  // The API and implementation are subject to change once a vendor-independent
  // use-model is determined.
  //----------------------------------------------------------------------------

  // Function: accept_tr
  //
  // This function marks the acceptance of a transaction, ~tr~, by this
  // component. Specifically, it performs the following actions:
  //
  // - Calls the ~tr~'s <uvm_transaction::accept_tr> method, passing to it the
  //   ~accept_time~ argument.
  //
  // - Calls this component's <do_accept_tr> method to allow for any post-begin
  //   action in derived classes.
  //
  // - Triggers the component's internal accept_tr event. Any processes waiting
  //   on this event will resume in the next delta cycle. 

  extern function void accept_tr (uvm_transaction tr, time accept_time=0);


  // Function: do_accept_tr
  //
  // The <accept_tr> method calls this function to accommodate any user-defined
  // post-accept action. Implementations should call super.do_accept_tr to
  // ensure correct operation.
    
  extern virtual protected function void do_accept_tr (uvm_transaction tr);


  // Function: begin_tr
  //
  // This function marks the start of a transaction, ~tr~, by this component.
  // Specifically, it performs the following actions:
  //
  // - Calls ~tr~'s <uvm_transaction::begin_tr> method, passing to it the
  //   ~begin_time~ argument. The ~begin_time~ should be greater than or equal
  //   to the accept time. By default, when ~begin_time~ = 0, the current
  //   simulation time is used.
  //
  //   If recording is enabled (recording_detail != UVM_OFF), then a new
  //   database-transaction is started on the component's transaction stream
  //   given by the stream argument. No transaction properties are recorded at
  //   this time.
  //
  // - Calls the component's <do_begin_tr> method to allow for any post-begin
  //   action in derived classes.
  //
  // - Triggers the component's internal begin_tr event. Any processes waiting
  //   on this event will resume in the next delta cycle. 
  //
  // A handle to the transaction is returned. The meaning of this handle, as
  // well as the interpretation of the arguments ~stream_name~, ~label~, and
  // ~desc~ are vendor specific.

  extern function integer begin_tr (uvm_transaction tr,
                                    string stream_name="main",
                                    string label="",
                                    string desc="",
                                    time begin_time=0);


  // Function: begin_child_tr
  //
  // This function marks the start of a child transaction, ~tr~, by this
  // component. Its operation is identical to that of <begin_tr>, except that
  // an association is made between this transaction and the provided parent
  // transaction. This association is vendor-specific.

  extern function integer begin_child_tr (uvm_transaction tr,
                                          integer parent_handle=0,
                                          string stream_name="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);


  // Function: do_begin_tr
  //
  // The <begin_tr> and <begin_child_tr> methods call this function to
  // accommodate any user-defined post-begin action. Implementations should call
  // super.do_begin_tr to ensure correct operation.

  extern virtual protected 
                 function void do_begin_tr (uvm_transaction tr,
                                            string stream_name,
                                            integer tr_handle);


  // Function: end_tr
  //
  // This function marks the end of a transaction, ~tr~, by this component.
  // Specifically, it performs the following actions:
  //
  // - Calls ~tr~'s <uvm_transaction::end_tr> method, passing to it the
  //   ~end_time~ argument. The ~end_time~ must at least be greater than the
  //   begin time. By default, when ~end_time~ = 0, the current simulation time
  //   is used.
  //
  //   The transaction's properties are recorded to the database-transaction on
  //   which it was started, and then the transaction is ended. Only those
  //   properties handled by the transaction's do_record method (and optional
  //   `uvm_*_field macros) are recorded.
  //
  // - Calls the component's <do_end_tr> method to accommodate any post-end
  //   action in derived classes.
  //
  // - Triggers the component's internal end_tr event. Any processes waiting on
  //   this event will resume in the next delta cycle. 
  //
  // The ~free_handle~ bit indicates that this transaction is no longer needed.
  // The implementation of free_handle is vendor-specific.

  extern function void end_tr (uvm_transaction tr,
                               time end_time=0,
                               bit free_handle=1);


  // Function: do_end_tr
  //
  // The <end_tr> method calls this function to accommodate any user-defined
  // post-end action. Implementations should call super.do_end_tr to ensure
  // correct operation.

  extern virtual protected function void do_end_tr (uvm_transaction tr,
                                                    integer tr_handle);


  // Function: record_error_tr
  //
  // This function marks an error transaction by a component. Properties of the
  // given uvm_object, ~info~, as implemented in its <uvm_object::do_record> method,
  // are recorded to the transaction database.
  //
  // An ~error_time~ of 0 indicates to use the current simulation time. The
  // ~keep_active~ bit determines if the handle should remain active. If 0,
  // then a zero-length error transaction is recorded. A handle to the
  // database-transaction is returned. 
  //
  // Interpretation of this handle, as well as the strings ~stream_name~,
  // ~label~, and ~desc~, are vendor-specific.

  extern function integer record_error_tr (string stream_name="main",
                                           uvm_object info=null,
                                           string label="error_tr",
                                           string desc="",
                                           time   error_time=0,
                                           bit    keep_active=0);


  // Function: record_event_tr
  //
  // This function marks an event transaction by a component. 
  //
  // An ~event_time~ of 0 indicates to use the current simulation time. 
  //
  // A handle to the transaction is returned. The ~keep_active~ bit determines
  // if the handle may be used for other vendor-specific purposes. 
  //
  // The strings for ~stream_name~, ~label~, and ~desc~ are vendor-specific
  // identifiers for the transaction.

  extern function integer record_event_tr (string stream_name="main",
                                           uvm_object info=null,
                                           string label="event_tr",
                                           string desc="",
                                           time   event_time=0,
                                           bit    keep_active=0);


  // Variable: print_enabled
  //
  // This bit determines if this component should automatically be printed as a
  // child of its parent object. 
  // 
  // By default, all children are printed. However, this bit allows a parent
  // component to disable the printing of specific children.

  bit print_enabled = 1;


  //----------------------------------------------------------------------------
  //                     PRIVATE or PSUEDO-PRIVATE members
  //                      *** Do not call directly ***
  //         Implementation and even existence are subject to change. 
  //----------------------------------------------------------------------------
  // Most local methods are prefixed with m_, indicating they are not
  // user-level methods. SystemVerilog does not support friend classes,
  // which forces some otherwise internal methods to be exposed (i.e. not
  // be protected via 'local' keyword). These methods are also prefixed
  // with m_ to indicate they are not intended for public use.
  //
  // Internal methods will not be documented, although their implementa-
  // tions are freely available via the open-source license.
  //----------------------------------------------------------------------------

  extern       function void set_int_local (string field_name, 
                               uvm_bitstream_t value,
                               bit recurse=1);

  /*protected*/ uvm_component m_parent;
  protected uvm_component m_children[string];
  protected uvm_component m_children_by_handle[uvm_component];
  extern local function bit m_add_child (uvm_component child);
  extern virtual local function void m_set_full_name ();

  extern          function void  do_resolve_bindings ();
  extern          function void  do_flush();

  extern virtual function void flush ();

  //AK uvm_phase m_curr_phase=null;

  extern local function void m_extract_name(string name ,
                                            output string leaf ,
                                            output string remainder );

  // overridden to disable
  extern virtual function uvm_object create (string name=""); 
  extern virtual function uvm_object clone  ();

  local integer m_stream_handle[string];
  local integer m_tr_h[uvm_transaction];
  extern protected function integer m_begin_tr (uvm_transaction tr,
              integer parent_handle=0, bit has_parent=0,
              string stream_name="main", string label="",
              string desc="", time begin_time=0);

  protected process m_phase_process;

  string m_name;

  protected uvm_event_pool event_pool;


  extern virtual task restart ();

  int unsigned recording_detail = UVM_NONE;
  extern         function void   do_print(uvm_printer printer);

  // Internal methods for setting up command line messaging stuff
  extern function void m_set_cl_msg_args;
  extern function void m_set_cl_verb;
  extern function void m_set_cl_action;
  extern function void m_set_cl_sev;

endclass : uvm_component



`include "base/uvm_root.svh"

//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// CLASS- uvm_component
//
//------------------------------------------------------------------------------


// new
// ---

function uvm_component::new (string name, uvm_component parent);
  string error_str;

  super.new(name);

  // If uvm_top, reset name to "" so it doesn't show in full paths then return
  if (parent==null && name == "__top__") begin
    set_name("");
    return;
  end

  // Check that we're not in or past end_of_elaboration
  begin
    uvm_phase_schedule common, end_of_elab;
    common = uvm_top.find_phase_schedule("uvm_pkg::common","common");
    if (common != null) begin
      // only check if we have got phasing set up yet
      end_of_elab = common.find_schedule("end_of_elaboration");
      if (end_of_elab.get_state == UVM_PHASE_EXECUTING ||
          end_of_elab.get_run_count > 0 ) begin
        uvm_phase_schedule curr_phase;
        curr_phase = uvm_top.get_current_phase();
        uvm_report_fatal("ILLCRT", {"It is illegal to create a component once",
                                    " phasing reaches end_of_elaboration. The current phase is ", 
                                    curr_phase.get_phase_name()}, UVM_NONE);
      end
    end
  end

  if (name == "") begin
    name.itoa(m_inst_count);
    name = {"COMP_", name};
  end

  if(parent == this) begin
    `uvm_fatal("THISPARENT", "cannot set the parent of a component to itself")
  end

  if (parent == null)
    parent = uvm_top;

  if(uvm_report_enabled(UVM_MEDIUM+1, UVM_INFO, "NEWCOMP"))
    `uvm_info("NEWCOMP",$psprintf("this=%0s, parent=%0s, name=%s",
                    this.get_full_name(),parent.get_full_name(),name),UVM_MEDIUM+1)

  if (parent.has_child(name) && this != parent.get_child(name)) begin
    if (parent == uvm_top) begin
      error_str = {"Name '",name,"' is not unique to other top-level ",
      "instances. If parent is a module, build a unique name by combining the ",
      "the module name and component name: $psprintf(\"\%m.\%s\",\"",name,"\")."};
      `uvm_fatal("CLDEXT",error_str)
    end
    else
      `uvm_fatal("CLDEXT",
        $psprintf("Cannot set '%s' as a child of '%s', %s",
                  name, parent.get_full_name(),
                  "which already has a child by that name."))
    return;
  end

  m_parent = parent;

  set_name(name);

  if (!m_parent.m_add_child(this))
    m_parent = null;

  event_pool = new("event_pool");

  foreach(parent.m_phase_domains[schedule])
    m_phase_domains[schedule] = parent.m_phase_domains[schedule];
  
  // Now that inst name is established, reseed (if use_uvm_seeding is set)
  reseed();

  // Do local configuration settings
  void'(get_config_int("recording_detail", recording_detail));

  set_report_verbosity_level(uvm_top.get_report_verbosity_level());

  set_report_id_action("CFGOVR", UVM_NO_ACTION);
  set_report_id_action("CFGSET", UVM_NO_ACTION);

  m_set_cl_msg_args();

  uvm_top.set_report_id_action("CFGOVR", UVM_NO_ACTION);
  uvm_top.set_report_id_action("CFGSET", UVM_NO_ACTION);
endfunction


// m_add_child
// -----------

function bit uvm_component::m_add_child(uvm_component child);

  if (m_children.exists(child.get_name()) &&
      m_children[child.get_name()] != child) begin
      `uvm_warning("BDCLD",
        $psprintf("A child with the name '%0s' (type=%0s) already exists.",
           child.get_name(), m_children[child.get_name()].get_type_name()))
      return 0;
  end

  if (m_children_by_handle.exists(child)) begin
      `uvm_warning("BDCHLD",
        $psprintf("A child with the name '%0s' %0s %0s'",
                  child.get_name(),
                  "already exists in parent under name '",
                  m_children_by_handle[child].get_name()))
      return 0;
    end

  m_children[child.get_name()] = child;
  m_children_by_handle[child] = child;
  return 1;
endfunction



//------------------------------------------------------------------------------
//
// Hierarchy Methods
// 
//------------------------------------------------------------------------------


// get_first_child
// ---------------

function int uvm_component::get_first_child(ref string name);
  return m_children.first(name);
endfunction


// get_next_child
// --------------

function int uvm_component::get_next_child(ref string name);
  return m_children.next(name);
endfunction


// get_child
// ---------

function uvm_component uvm_component::get_child(string name);
  if (m_children.exists(name))
    return m_children[name];
  `uvm_warning("NOCHILD",{"Component with name '",name,
       "' is not a child of component '",get_full_name(),"'"})
  return null;
endfunction


// has_child
// ---------

function int uvm_component::has_child(string name);
  return m_children.exists(name);
endfunction


// get_num_children
// ----------------

function int uvm_component::get_num_children();
  return m_children.num();
endfunction


// get_full_name
// -------------

function string uvm_component::get_full_name ();
  // Note- Implementation choice to construct full name once since the
  // full name may be used often for lookups.
  if(m_name == "")
    return get_name();
  else
    return m_name;
endfunction


// get_parent
// ----------

function uvm_component uvm_component::get_parent ();
  return  m_parent;
endfunction


// set_name
// --------

function void uvm_component::set_name (string name);
  
  super.set_name(name);
  m_set_full_name();

endfunction


// m_set_full_name
// ---------------

function void uvm_component::m_set_full_name();
  if (m_parent == uvm_top || m_parent==null)
    m_name = get_name();
  else 
    m_name = {m_parent.get_full_name(), ".", get_name()};

  foreach (m_children[c]) begin
    uvm_component tmp;
    tmp = m_children[c];
    tmp.m_set_full_name(); 
  end

endfunction


// lookup
// ------

function uvm_component uvm_component::lookup( string name );

  string leaf , remainder;
  uvm_component comp;

  comp = this;
  
  m_extract_name(name, leaf, remainder);

  if (leaf == "") begin
    comp = uvm_top; // absolute lookup
    m_extract_name(remainder, leaf, remainder);
  end
  
  if (!comp.has_child(leaf)) begin
    `uvm_warning("Lookup Error", 
       $psprintf("Cannot find child %0s",leaf))
    return null;
  end

  if( remainder != "" )
    return comp.m_children[leaf].lookup(remainder);

  return comp.m_children[leaf];

endfunction


// get_depth
// ---------

function int unsigned uvm_component::get_depth();
  if(m_name == "") return 0;
  get_depth = 1;
  foreach(m_name[i]) 
    if(m_name[i] == ".") ++get_depth;
endfunction


// m_extract_name
// --------------

function void uvm_component::m_extract_name(input string name ,
                                            output string leaf ,
                                            output string remainder );
  int i , len;
  string extract_str;
  len = name.len();
  
  for( i = 0; i < name.len(); i++ ) begin  
    if( name[i] == "." ) begin
      break;
    end
  end

  if( i == len ) begin
    leaf = name;
    remainder = "";
    return;
  end

  leaf = name.substr( 0 , i - 1 );
  remainder = name.substr( i + 1 , len - 1 );

  return;
endfunction
  

// flush
// -----

function void uvm_component::flush();
  return;
endfunction


// do_flush  (flush_hier?)
// --------

function void uvm_component::do_flush();
  foreach( m_children[s] )
    m_children[s].do_flush();
  flush();
endfunction
  


//------------------------------------------------------------------------------
//
// Factory Methods
// 
//------------------------------------------------------------------------------


// create
// ------

function uvm_object  uvm_component::create (string name =""); 
  `uvm_error("ILLCRT",
    "create cannot be called on a uvm_component. Use create_component instead.")
  return null;
endfunction


// clone
// ------

function uvm_object  uvm_component::clone ();
  `uvm_error("ILLCLN","clone cannot be called on a uvm_component. ")
  return null;
endfunction


// print_override_info
// -------------------

function void  uvm_component::print_override_info (string requested_type_name, 
                                                   string name="");
  factory.debug_create_by_name(requested_type_name, get_full_name(), name);
endfunction


// create_component
// ----------------

function uvm_component uvm_component::create_component (string requested_type_name,
                                                        string name);
  return factory.create_component_by_name(requested_type_name, get_full_name(),
                                          name, this);
endfunction


// create_object
// -------------

function uvm_object uvm_component::create_object (string requested_type_name,
                                                  string name="");
  return factory.create_object_by_name(requested_type_name,
                                       get_full_name(), name);
endfunction


// set_type_override (static)
// -----------------

function void uvm_component::set_type_override (string original_type_name,
                                                string override_type_name,
                                                bit    replace=1);
   factory.set_type_override_by_name(original_type_name,
                                     override_type_name, replace);
endfunction 


// set_type_override_by_type (static)
// -------------------------

function void uvm_component::set_type_override_by_type (uvm_object_wrapper original_type,
                                                        uvm_object_wrapper override_type,
                                                        bit    replace=1);
   factory.set_type_override_by_type(original_type, override_type, replace);
endfunction 


// set_inst_override
// -----------------

function void  uvm_component::set_inst_override (string relative_inst_path,  
                                                 string original_type_name,
                                                 string override_type_name);
  string full_inst_path;

  if (relative_inst_path == "")
    full_inst_path = get_full_name();
  else
    full_inst_path = {get_full_name(), ".", relative_inst_path};

  factory.set_inst_override_by_name(
                            original_type_name,
                            override_type_name,
                            full_inst_path);
endfunction 


// set_inst_override_by_type
// -------------------------

function void uvm_component::set_inst_override_by_type (string relative_inst_path,  
                                                        uvm_object_wrapper original_type,
                                                        uvm_object_wrapper override_type);
  string full_inst_path;

  if (relative_inst_path == "")
    full_inst_path = get_full_name();
  else
    full_inst_path = {get_full_name(), ".", relative_inst_path};

  factory.set_inst_override_by_type(original_type, override_type, full_inst_path);

endfunction



//------------------------------------------------------------------------------
//
// Hierarchical report configuration interface
//
//------------------------------------------------------------------------------

// set_report_id_verbosity_hier
// -------------------------

function void uvm_component::set_report_id_verbosity_hier( string id, int verbosity);
  set_report_id_verbosity(id, verbosity);
  foreach( m_children[c] )
    m_children[c].set_report_id_verbosity_hier(id, verbosity);
endfunction


// set_report_severity_id_verbosity_hier
// ----------------------------------

function void uvm_component::set_report_severity_id_verbosity_hier( uvm_severity severity,
                                                                 string id,
                                                                 int verbosity);
  set_report_severity_id_verbosity(severity, id, verbosity);
  foreach( m_children[c] )
    m_children[c].set_report_severity_id_verbosity_hier(severity, id, verbosity);
endfunction


// set_report_severity_action_hier
// -------------------------

function void uvm_component::set_report_severity_action_hier( uvm_severity severity, 
                                                           uvm_action action);
  set_report_severity_action(severity, action);
  foreach( m_children[c] )
    m_children[c].set_report_severity_action_hier(severity, action);
endfunction


// set_report_id_action_hier
// -------------------------

function void uvm_component::set_report_id_action_hier( string id, uvm_action action);
  set_report_id_action(id, action);
  foreach( m_children[c] )
    m_children[c].set_report_id_action_hier(id, action);
endfunction


// set_report_severity_id_action_hier
// ----------------------------------

function void uvm_component::set_report_severity_id_action_hier( uvm_severity severity,
                                                                 string id,
                                                                 uvm_action action);
  set_report_severity_id_action(severity, id, action);
  foreach( m_children[c] )
    m_children[c].set_report_severity_id_action_hier(severity, id, action);
endfunction


// set_report_severity_file_hier
// -----------------------------

function void uvm_component::set_report_severity_file_hier( uvm_severity severity,
                                                            UVM_FILE file);
  set_report_severity_file(severity, file);
  foreach( m_children[c] )
    m_children[c].set_report_severity_file_hier(severity, file);
endfunction


// set_report_default_file_hier
// ----------------------------

function void uvm_component::set_report_default_file_hier( UVM_FILE file);
  set_report_default_file(file);
  foreach( m_children[c] )
    m_children[c].set_report_default_file_hier(file);
endfunction


// set_report_id_file_hier
// -----------------------
  
function void uvm_component::set_report_id_file_hier( string id, UVM_FILE file);
  set_report_id_file(id, file);
  foreach( m_children[c] )
    m_children[c].set_report_id_file_hier(id, file);
endfunction


// set_report_severity_id_file_hier
// --------------------------------

function void uvm_component::set_report_severity_id_file_hier ( uvm_severity severity,
                                                                string id,
                                                                UVM_FILE file);
  set_report_severity_id_file(severity, id, file);
  foreach( m_children[c] )
    m_children[c].set_report_severity_id_file_hier(severity, id, file);
endfunction


// set_report_verbosity_level_hier
// -------------------------------

function void uvm_component::set_report_verbosity_level_hier(int verbosity);
  set_report_verbosity_level(verbosity);
  foreach( m_children[c] )
    m_children[c].set_report_verbosity_level_hier(verbosity);
endfunction  



//------------------------------------------------------------------------------
//
// Phase interface 
//
//------------------------------------------------------------------------------


// phase methods
//--------------
// these are prototypes for the methods to be implemented in user components
// build() has a default implementation, the others have an empty default

function void uvm_component::build();
  m_build_done = 1;
  apply_config_settings(print_config_matches);
endfunction

// these phase methods are common to all components in UVM

function void uvm_component::connect();             return; endfunction
function void uvm_component::start_of_simulation(); return; endfunction
function void uvm_component::end_of_elaboration();  return; endfunction
task          uvm_component::run();                 return; endtask
function void uvm_component::extract();             return; endfunction
function void uvm_component::check();               return; endfunction
function void uvm_component::report();              return; endfunction
function void uvm_component::finalize();            return; endfunction

// these runtime phase methods are only called if a set_domain() is done

task          uvm_component::pre_reset();           return; endtask
task          uvm_component::reset();               return; endtask
task          uvm_component::post_reset();          return; endtask
task          uvm_component::pre_configure();       return; endtask
task          uvm_component::configure();           return; endtask
task          uvm_component::post_configure();      return; endtask
task          uvm_component::pre_main();            return; endtask
task          uvm_component::main();                return; endtask
task          uvm_component::post_main();           return; endtask
task          uvm_component::pre_shutdown();        return; endtask
task          uvm_component::shutdown();            return; endtask
task          uvm_component::post_shutdown();       return; endtask


// The verbosity settings may have a specific phase to start at. 
// We will do this work in the phase_started callback. May need a
// seperate internal callback so the user doesn't have to remember to call
// the phase started callback.

typedef struct {
  string phase;
  time   offset;
  uvm_verbosity verbosity;
  string id;
} m_verbosity_setting;
m_verbosity_setting m_verbosity_settings[$];

// current phase convenience API
//------------------------------


// phase_started() and phase_ended() are extra callbacks called at the
// beginning and end of each phase, respectively.  Since they are
// called for all phases the phase is passed in as an argument so the
// extender can decide what to do, if anything, for each phase.

function void uvm_component::phase_started(uvm_phase_schedule phase);
  foreach(m_verbosity_settings[i]) begin
    if(phase.get_name() == m_verbosity_settings[i].phase) begin
      if( m_verbosity_settings[i].offset == 0 ) begin
          if(m_verbosity_settings[i].id == "_ALL_") 
            set_report_verbosity_level(m_verbosity_settings[i].verbosity);
          else 
            set_report_id_verbosity(m_verbosity_settings[i].id, m_verbosity_settings[i].verbosity);
      end
      else begin
        fork begin
          m_verbosity_setting setting = m_verbosity_settings[i];
          #setting.offset;
          if(setting.id == "_ALL_") 
            set_report_verbosity_level(setting.verbosity);
          else 
            set_report_id_verbosity(setting.id, setting.verbosity);
        end join_none;
      end
      // Remove after use
      m_verbosity_settings.delete(i);
    end
  end
endfunction


function void uvm_component::phase_ended(uvm_phase_schedule phase);
endfunction


function uvm_phase_schedule uvm_component::get_current_phase();
  foreach (m_phase_threads[phase])
    if (m_phase_threads[phase].is_current_process()) return phase;

  return m_current_phase;
endfunction


function string uvm_component::find_phase_domain(string schedule_name="uvm_pkg::uvm");
  foreach (m_phase_domains[schedule])
    if (schedule.get_schedule_name() == schedule_name)
      return m_phase_domains[schedule];
  uvm_report_fatal("BADDOMAIN", {"component has no '", schedule_name, "' schedule domain"});
endfunction


function uvm_phase_schedule uvm_component::find_phase_schedule(string name, string domain);
  foreach (m_phase_domains[schedule])
    if (((name == "*") || (schedule.get_schedule_name() == name)) &&
        ((domain == "*") || (m_phase_domains[schedule] == domain)))
      return schedule;
  return null;
endfunction


function void uvm_component::add_phase_schedule(uvm_phase_schedule schedule, string domain);
  m_phase_domains[schedule] = domain;
endfunction


function void uvm_component::delete_phase_schedule(uvm_phase_schedule schedule);
  m_phase_domains.delete(schedule);
endfunction


// phase / schedule / domain API
//------------------------------
// methods for VIP creators and integrators to use to set up schedule domains
// - a schedule is a named, organized group of phases for a component base type
// - a domain is a named instance of a schedule in the master phasing schedule


// here we define the "uvm_pkg::uvm" schedule containing the UVM runtime phases
// - and add a named instance of it to the root schedule [if not already there]
// - and add the schedule handle to this component's domain membership list
// [replacing any existing handles comp has to this schedule in other domains]

// components using these phases must subscribe by calling set_domain(name)

function void uvm_component::set_phase_schedule(string domain_name);
  const string schedule_name = "uvm_pkg::uvm";
  uvm_phase_schedule uvm;

  // find this schedule/domain in the master schedule if it exists
  uvm = uvm_top.find_phase_schedule(schedule_name, domain_name);

  // create it and add it to master schedule if it doesn't exist
  if (uvm == null) begin
    uvm = new(schedule_name);
    uvm_root::m_has_rt_phases=1;
    // schedule consists of a linear list of predefined phases
    uvm.add_phase(uvm_pre_reset_ph);
    uvm.add_phase(uvm_reset_ph);
    uvm.add_phase(uvm_post_reset_ph);
    uvm.add_phase(uvm_pre_configure_ph);
    uvm.add_phase(uvm_configure_ph);
    uvm.add_phase(uvm_post_configure_ph);
    uvm.add_phase(uvm_pre_main_ph);
    uvm.add_phase(uvm_main_ph);
    uvm.add_phase(uvm_post_main_ph);
    uvm.add_phase(uvm_pre_shutdown_ph);
    uvm.add_phase(uvm_shutdown_ph);
    uvm.add_phase(uvm_post_shutdown_ph);
    // schedule is integrated hierarchically in parallel with the "run" phase
    // of the "uvm_pkg::common" schedule, for the specified domain
    begin
      uvm_phase_schedule common;
      common = uvm_top.find_phase_schedule("uvm_pkg::common","common");
      common.add_schedule(uvm, .with_phase(common.find_schedule("run")));
    end
    // schedule/domain pair is added to the master list
    uvm_top.add_phase_schedule(uvm, domain_name);
  end

  // add schedule to this component's list, replacing any existing entry found
  if (find_phase_schedule(schedule_name,"*"))
    delete_phase_schedule(find_phase_schedule(schedule_name,"*"));
  add_phase_schedule(uvm, domain_name);
endfunction

function void uvm_component::set_phase_domain(string domain_name, int hier=1);
  set_phase_schedule(domain_name);
  if (hier) foreach (m_children[c]) m_children[c].set_phase_domain(domain_name,hier);
endfunction

function void uvm_component::set_phase_imp(uvm_phase_imp phase, uvm_phase_imp imp, int hier=1);
  m_phase_imps[phase] = imp;
  if (hier) foreach (m_children[c]) m_children[c].set_phase_imp(phase,imp,hier);
endfunction


// phase process / thread semantics API
//-------------------------------------

function void uvm_component::set_default_thread_mode(uvm_thread_mode_t thread_mode);
  m_phase_thread_mode = thread_mode;
endfunction

function void uvm_component::set_thread_mode(uvm_thread_mode_t thread_mode);
  foreach (m_phase_threads[phase]) begin
    if (m_phase_threads[phase].is_current_process()) begin
      m_phase_threads[phase].set_thread_mode(thread_mode);
      return;
    end
  end
  //TBD fatal
endfunction


// phase runtime control API
// -------------------------

function void uvm_component::jump(uvm_phase_imp phase);
  uvm_phase_schedule current_phase;
  current_phase = get_current_phase();
  current_phase.jump(phase);
endfunction

function void uvm_component::jump_all_domains(uvm_phase_imp phase);
  uvm_phase_schedule current_phase;
  current_phase = get_current_phase();
  current_phase.jump_all(phase);
endfunction

function void uvm_component::raise_objection(uvm_phase_schedule phase=null);
  if(phase == null)
    phase = get_current_phase();
  phase.phase_done.raise_objection(this);
endfunction

function void uvm_component::drop_objection(uvm_phase_schedule phase=null);
  if(phase == null)
    phase = get_current_phase();
  phase.phase_done.drop_objection(this);
endfunction

function void uvm_component::terminate_phase(uvm_phase_schedule phase=null);
  if(phase == null)
    phase = get_current_phase();
  phase.terminate_phase();
endfunction


// do_kill_all
// -----------

function void uvm_component::do_kill_all();
  foreach(m_children[c])
    m_children[c].do_kill_all();
  kill();
endfunction


// kill
// ----

function void uvm_component::kill();
    if (m_phase_process != null) begin
      m_phase_process.kill;
      m_phase_process = null;
    end
endfunction


// suspend
// -------

task uvm_component::suspend();
  `ifdef UVM_USE_SUSPEND_RESUME
    if(m_phase_process != null)
      m_phase_process.suspend;
  `else
    `uvm_error("UNIMP", "suspend not implemented")
  `endif
endtask


// resume
// ------

task uvm_component::resume();
  `ifdef UVM_USE_SUSPEND_RESUME
    if(m_phase_process!=null) 
      m_phase_process.resume;
  `else
     `uvm_error("UNIMP", "resume not implemented")
  `endif
endtask


// restart
// -------

task uvm_component::restart();
  `uvm_warning("UNIMP",
      $psprintf("%0s: restart not implemented",this.get_name()))
endtask


// status
//-------

function string uvm_component::status();

  `ifdef UVM_USE_PROCESS_STATE
    process::state ps;

    if(m_phase_process == null)
      return "<unknown>";

    ps = m_phase_process.status();

    return ps.name();
  `else
    if(m_phase_process == null)
      return "<unknown>";

    case(m_phase_process.status())
      0: return "FINISHED";
      1: return "RUNNING";
      2: return "WAITING";
      3: return "SUSPENDED";
      4: return "KILLED";
      default: return "<unknown>";
    endcase
  `endif 
   
endfunction


// stop
// ----

task uvm_component::stop(string ph_name);
  return;
endtask


// resolve_bindings
// ----------------

function void uvm_component::resolve_bindings();
  return;
endfunction


// do_resolve_bindings
// -------------------

function void uvm_component::do_resolve_bindings();
  foreach( m_children[s] )
    m_children[s].do_resolve_bindings();
  resolve_bindings();
endfunction



//------------------------------------------------------------------------------
//
// Recording interface
//
//------------------------------------------------------------------------------

// accept_tr
// ---------

function void uvm_component::accept_tr (uvm_transaction tr,
                                        time accept_time=0);
  uvm_event e;
  tr.accept_tr(accept_time);
  do_accept_tr(tr);
  e = event_pool.get("accept_tr");
  if(e!=null) 
    e.trigger();
endfunction

// begin_tr
// --------

function integer uvm_component::begin_tr (uvm_transaction tr,
                                          string stream_name ="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);
  return m_begin_tr(tr, 0, 0, stream_name, label, desc, begin_time);
endfunction

// begin_child_tr
// --------------

function integer uvm_component::begin_child_tr (uvm_transaction tr,
                                          integer parent_handle=0,
                                          string stream_name="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);
  return m_begin_tr(tr, parent_handle, 1, stream_name, label, desc, begin_time);
endfunction

// m_begin_tr
// ----------

function integer uvm_component::m_begin_tr (uvm_transaction tr,
                                          integer parent_handle=0,
                                          bit    has_parent=0,
                                          string stream_name="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);
  uvm_event e;
  integer stream_h;
  integer tr_h;
  integer link_tr_h;
  string name;

  tr_h = 0;
  if(has_parent)
    link_tr_h = tr.begin_child_tr(begin_time, parent_handle);
  else
    link_tr_h = tr.begin_tr(begin_time);

  if (tr.get_name() != "")
    name = tr.get_name();
  else
    name = tr.get_type_name();

  if(stream_name == "") stream_name="main";

  if (uvm_verbosity'(recording_detail) != UVM_NONE) begin

    if(m_stream_handle.exists(stream_name))
        stream_h = m_stream_handle[stream_name];

    if (uvm_check_handle_kind("Fiber", stream_h) != 1) 
      begin  
        stream_h = uvm_create_fiber(stream_name, "TVM", get_full_name());
        m_stream_handle[stream_name] = stream_h;
      end

    if(has_parent == 0) 
      tr_h = uvm_begin_transaction("Begin_No_Parent, Link", 
                             stream_h,
                             name,
                             label,
                             desc,
                             begin_time);
    else begin
      tr_h = uvm_begin_transaction("Begin_End, Link", 
                             stream_h,
                             name,
                             label,
                             desc,
                             begin_time);
      if(parent_handle!=0)
        uvm_link_transaction(parent_handle, tr_h, "child");
    end

    m_tr_h[tr] = tr_h;

    if (uvm_check_handle_kind("Transaction", link_tr_h) == 1)
      uvm_link_transaction(tr_h,link_tr_h);
        
    do_begin_tr(tr,stream_name,tr_h); 
        
  end
 
  e = event_pool.get("begin_tr");
  if (e!=null) 
    e.trigger(tr);
        
  return tr_h;

endfunction


// end_tr
// ------

function void uvm_component::end_tr (uvm_transaction tr,
                                     time end_time=0,
                                     bit free_handle=1);
  uvm_event e;
  integer tr_h;
  tr_h = 0;

  tr.end_tr(end_time,free_handle);

  if (uvm_verbosity'(recording_detail) != UVM_NONE) begin

    if (m_tr_h.exists(tr)) begin

      tr_h = m_tr_h[tr];

      do_end_tr(tr, tr_h); // callback

      m_tr_h.delete(tr);

      if (uvm_check_handle_kind("Transaction", tr_h) == 1) begin  

        uvm_default_recorder.tr_handle = tr_h;
        tr.record(uvm_default_recorder);

        uvm_end_transaction(tr_h,end_time);

        if (free_handle)
           uvm_free_transaction_handle(tr_h);

      end
    end
    else begin
      do_end_tr(tr, tr_h); // callback
    end

  end

  e = event_pool.get("end_tr");
  if(e!=null) 
    e.trigger();

endfunction

// record_error_tr
// ---------------

function integer uvm_component::record_error_tr (string stream_name="main",
                                              uvm_object info=null,
                                              string label="error_tr",
                                              string desc="",
                                              time   error_time=0,
                                              bit    keep_active=0);
  string etype;
  integer stream_h;

  if(keep_active) etype = "Error, Link";
  else etype = "Error";

  if(error_time == 0) error_time = $time;

  stream_h = m_stream_handle[stream_name];
  if (uvm_check_handle_kind("Fiber", stream_h) != 1) begin  
    stream_h = uvm_create_fiber(stream_name, "TVM", get_full_name());
    m_stream_handle[stream_name] = stream_h;
  end

  record_error_tr = uvm_begin_transaction(etype, stream_h, label,
                         label, desc, error_time);
  if(info!=null) begin
    uvm_default_recorder.tr_handle = record_error_tr;
    info.record(uvm_default_recorder);
  end

  uvm_end_transaction(record_error_tr,error_time);
endfunction


// record_event_tr
// ---------------

function integer uvm_component::record_event_tr (string stream_name="main",
                                              uvm_object info=null,
                                              string label="event_tr",
                                              string desc="",
                                              time   event_time=0,
                                              bit    keep_active=0);
  string etype;
  integer stream_h;

  if(keep_active) etype = "Event, Link";
  else etype = "Event";

  if(event_time == 0) event_time = $time;

  stream_h = m_stream_handle[stream_name];
  if (uvm_check_handle_kind("Fiber", stream_h) != 1) begin  
    stream_h = uvm_create_fiber(stream_name, "TVM", get_full_name());
    m_stream_handle[stream_name] = stream_h;
  end

  record_event_tr = uvm_begin_transaction(etype, stream_h, label,
                         label, desc, event_time);
  if(info!=null) begin
    uvm_default_recorder.tr_handle = record_event_tr;
    info.record(uvm_default_recorder);
  end

  uvm_end_transaction(record_event_tr,event_time);
endfunction

// do_accept_tr
// ------------

function void uvm_component::do_accept_tr (uvm_transaction tr);
  return;
endfunction


// do_begin_tr
// -----------

function void uvm_component::do_begin_tr (uvm_transaction tr,
                                          string stream_name,
                                          integer tr_handle);
  return;
endfunction


// do_end_tr
// ---------

function void uvm_component::do_end_tr (uvm_transaction tr,
                                        integer tr_handle);
  return;
endfunction


//------------------------------------------------------------------------------
//
// Configuration interface
//
//------------------------------------------------------------------------------


function string uvm_component::massage_scope(string scope);

  // uvm_top
  if(scope == "")
    return "^$";

  if(scope == "*")
    return {get_full_name(), ".*"};

  // absolute path to the top-level test
  if(scope == "uvm_test_top")
    return "uvm_test_top";

  // absolute path to uvm_root
  if(scope[0] == ".")
    return {get_full_name(), scope};

  return {get_full_name(), ".", scope};

endfunction

//
// set_config_int
//
typedef uvm_config_db#(uvm_bitstream_t) uvm_config_int;
typedef uvm_config_db#(string) uvm_config_string;
typedef uvm_config_db#(uvm_object) uvm_config_object;

function void uvm_component::set_config_int(string inst_name,
                                           string field_name,
                                           uvm_bitstream_t value);

  uvm_config_int::set(this, inst_name, field_name, value);
endfunction

//
// set_config_string
//
function void uvm_component::set_config_string(string inst_name,
                                               string field_name,
                                               string value);

  uvm_config_string::set(this, inst_name, field_name, value);
endfunction

//
// set_config_object
//
function void uvm_component::set_config_object(string inst_name,
                                               string field_name,
                                               uvm_object value,
                                               bit clone = 1);
  uvm_object tmp;

  if(clone && (value != null)) begin
    tmp = value.clone();
    if(tmp == null) begin
      uvm_component comp;
      if ($cast(comp,value)) begin
        `uvm_error("INVCLNC", {"Clone failed during set_config_object ",
          "with an object that is an uvm_component. Components cannot be cloned."})
        return;
      end
      else begin
        `uvm_warning("INVCLN", {"Clone failed during set_config_object, ",
          "the original reference will be used for configuration. Check that ",
          "the create method for the object type is defined properly."})
      end
    end
    else
      value = tmp;
  end

  uvm_config_object::set(this, inst_name, field_name, value);
endfunction

//
// get_config_int
//
function bit uvm_component::get_config_int (string field_name,
                                            inout uvm_bitstream_t value);

  return uvm_config_int::get(this, "", field_name, value);
endfunction

//
// get_config_string
//
function bit uvm_component::get_config_string(string field_name,
                                              inout string value);

  return uvm_config_string::get(this, "", field_name, value);
endfunction

//
// get_config_object
//
function bit uvm_component::get_config_object (string field_name,
                                               inout uvm_object value,
                                               input bit clone=1);
  if(!uvm_config_object::get(this, "", field_name, value)) begin
    return 0;
  end

  if(clone && value != null) begin
    value = value.clone();
  end

  return 1;
endfunction

// check_config_usage
// ------------------

function void uvm_component::check_config_usage ( bit recurse=1 );
  uvm_resource_pool rp = uvm_resource_pool::get();
  uvm_queue#(uvm_resource_base) rq;

  rq = rp.find_unused_resources();

  if(rq.size() == 0)
    return;

  $display("\n ::: The following resources have at least one write and no reads :::");
  rp.print_resources(rq, 1);
endfunction

// apply_config_settings
// ---------------------

function void uvm_component::apply_config_settings (bit verbose=0);

  uvm_resource_pool rp = uvm_resource_pool::get();
  uvm_queue#(uvm_resource_base) rq;
  uvm_resource_base r;
  string name;
  string search_name;
  int unsigned i;
  int unsigned j;

  m_field_automation (null, UVM_CHECK_FIELDS, "");

  if(verbose)
    $display("applying configuration settings for %s", get_full_name());

  rq = rp.lookup_scope(get_full_name());

  for(int i=0; i<rq.size(); ++i) begin

    r = rq.get(i);
    name = r.get_name();

    // does name have brackets [] in it?
    for(j = 0; j < name.len(); j++)
      if(name[j] == "[" || name[j] == ".")
        break;

    // If it does have brackets then we'll use the name
    // up to the brackets to search m_sc.field_array
    if(j < name.len())
      search_name = name.substr(0, j-1);
    else
      search_name = name;

    if(!m_sc.field_array.exists(search_name))
      continue;

    if(verbose)
      $display("applying %s [%s] in %s", name, m_sc.field_array[search_name],
                                         get_full_name());

    begin
    uvm_resource#(uvm_bitstream_t) rbs;
    if($cast(rbs, r))
      set_int_local(name, rbs.read(this));
    else begin
      uvm_resource#(int) ri;
      if($cast(ri, r))
        set_int_local(name, ri.read(this));
      else begin
        uvm_resource#(int unsigned) riu;
        if($cast(riu, r))
          set_int_local(name, riu.read(this));
        else begin
          uvm_resource#(string) rs;
          if($cast(rs, r))
            set_string_local(name, rs.read(this));
          else begin
            uvm_resource#(uvm_object) ro;
            if($cast(ro, r))
              set_object_local(name, ro.read(this), 0);
          end
        end
      end
    end
    end

  end

  m_sc.field_array.delete();
  
endfunction


// print_config_settings
// ---------------------

function void uvm_component::print_config_settings (string field="",
                                                    uvm_component comp=null,
                                                    bit recurse=0);
  static bit have_been_warned = 0;
  if(!have_been_warned) begin
    uvm_report_warning("deprecated", "uvm_component::print_config_settings has been deprecated.  Use print_config() instead");
    have_been_warned = 1;
  end

  print_config(1, recurse);
endfunction

function void uvm_component::print_config_with_audit(bit recurse = 0);
  print_config(recurse, 1);
endfunction

function void uvm_component::print_config(bit recurse = 0, audit = 0);

  uvm_resource_pool rp = uvm_resource_pool::get();

  $display();
  $display("resources that are visible in %s", get_full_name());
  rp.print_resources(rp.lookup_scope(get_full_name()), audit);

  if(recurse) begin
    uvm_component c;
    foreach(m_children[name]) begin
      c = m_children[name];
      c.print_config(recurse, audit);
    end
  end

endfunction


// do_print (override)
// --------

function void uvm_component::do_print(uvm_printer printer);
  string v;
  super.do_print(printer);

  // It is printed only if its value is other than the default (UVM_NONE)
  if(uvm_verbosity'(recording_detail) != UVM_NONE)
    case (recording_detail)
      UVM_LOW : printer.print_generic("recording_detail", "uvm_verbosity", 
        $bits(recording_detail), "UVM_LOW");
      UVM_MEDIUM : printer.print_generic("recording_detail", "uvm_verbosity", 
        $bits(recording_detail), "UVM_MEDIUM");
      UVM_HIGH : printer.print_generic("recording_detail", "uvm_verbosity", 
        $bits(recording_detail), "UVM_HIGH");
      UVM_FULL : printer.print_generic("recording_detail", "uvm_verbosity", 
        $bits(recording_detail), "UVM_FULL");
      default : printer.print_int("recording_detail", recording_detail, 
        $bits(recording_detail), UVM_DEC, , "integral");
    endcase

  if (enable_stop_interrupt != 0) begin
    printer.print_int("enable_stop_interrupt", enable_stop_interrupt,
                        $bits(enable_stop_interrupt), UVM_BIN, ".", "bit");
  end

endfunction


// set_int_local (override)
// -------------

function void uvm_component::set_int_local (string field_name,
                             uvm_bitstream_t value,
                             bit recurse=1);

  //call the super function to get child recursion and any registered fields
  super.set_int_local(field_name, value, recurse);

  //set the local properties
  if(uvm_is_match(field_name, "recording_detail"))
    recording_detail = value;

endfunction


// Internal methods for setting messagin parameters from command line switches

typedef class uvm_cmdline_processor;

function void uvm_component::m_set_cl_msg_args;
  m_set_cl_verb();
  m_set_cl_action();
  m_set_cl_sev();
endfunction

function void uvm_component::m_set_cl_verb;
  // _ALL_ can be used for ids
  // +uvm_set_verbosity=<comp>,<id>,<verbosity>,<phase|time>,<offset>
  // +uvm_set_verbosity=uvm_test_top.env0.agent1.*,_ALL_,UVM_FULL,time,800
 
  static string values[$];
  static bit first = 1;
  string args[$];
  uvm_verbosity verb;
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

  if(!values.size())
    void'(uvm_cmdline_proc.get_arg_values("+uvm_set_verbosity=",values));

  foreach(values[i]) begin
    string phase="";
    time   offset= 0;
    uvm_split_string(values[i], ",", args);
    // Warning is already issued in uvm_root, so just don't keep it
    if(first && ( ((args.size() != 4) && (args.size() != 5)) || 
                  (clp.m_convert_verb(args[2], verb) == 0))  )
    begin
      values.delete(i);
    end
    else if (uvm_is_match(args[0], get_full_name()) ) begin
      phase = args[3];
      if(args.size() == 5) begin
        offset = args[4].atoi();
      end
      if((phase == "" || phase == "build" || phase == "time") && (offset == 0) ) begin
        if(args[1] == "_ALL_") 
          set_report_verbosity_level(verb);
        else
          set_report_id_verbosity(args[1], verb);
      end
      else begin
        if(phase == "time") begin
          fork begin
            uvm_verbosity lverb = verb;
            string lid = args[1];
            time t = offset;
 
            #t;
            if(lid == "_ALL_") 
              set_report_verbosity_level(lverb);
            else 
              set_report_id_verbosity(lid, lverb);
          end join_none
        end
        else begin
          m_verbosity_setting setting;
          setting.phase = phase;
          setting.offset = offset;
          setting.verbosity = verb;
          setting.id = args[1];
          m_verbosity_settings.push_back(setting);
        end
      end
    end
  end
  first = 0;
endfunction


function void uvm_component::m_set_cl_action;
  // _ALL_ can be used for ids or severities
  // +uvm_set_action=<comp>,<id>,<severity>,<action[|action]>
  // +uvm_set_action=uvm_test_top.env0.*,_ALL_,UVM_ERROR,UVM_NO_ACTION

  static string values[$];
  static bit first = 1;
  string args[$];
  uvm_severity sev;
  uvm_action action;

  if(!values.size())
    void'(uvm_cmdline_proc.get_arg_values("+uvm_set_action=",values));

  foreach(values[i]) begin
    uvm_split_string(values[i], ",", args);
    if(args.size() != 4) begin
      `uvm_warning("INVLCMDARGS", $sformatf("+uvm_set_action requires 4 arguments, only %0d given for command +uvm_set_action=%s, Usage: +uvm_set_action=<comp>,<id>,<severity>,<action[|action]>", args.size(), values[i]))
      values.delete(i);
      break;
    end
    if (!uvm_is_match(args[0], get_full_name()) ) break; 
    if(!uvm_string_to_severity(args[2], sev)) begin
      `uvm_warning("INVLCMDARGS", $sformatf("Bad severity argument \"%s\" given to command +uvm_set_action=%s, Usage: +uvm_set_action=<comp>,<id>,<severity>,<action[|action]>", args[2], values[i]))
      values.delete(i);
      break;
    end
    if(!uvm_string_to_action(args[3], action)) begin
      `uvm_warning("INVLCMDARGS", $sformatf("Bad action argument \"%s\" given to command +uvm_set_action=%s, Usage: +uvm_set_action=<comp>,<id>,<severity>,<action[|action]>", args[3], values[i]))
      values.delete(i);
      break;
    end
    if(args[1] == "_ALL_") begin
      set_report_severity_action(sev, action);
    end
    else begin
      set_report_severity_id_action(sev, args[1], action);
    end
  end

  first = 0;
endfunction

function void uvm_component::m_set_cl_sev;
  // _ALL_ can be used for ids or severities
  //  +uvm_set_severity=<comp>,<id>,<orig_severity>,<new_severity>
  //  +uvm_set_severity=uvm_test_top.env0.*,BAD_CRC,UVM_ERROR,UVM_WARNING

  static string values[$];
  static bit first = 1;
  string args[$];
  uvm_severity orig_sev, sev;

  if(!values.size())
    void'(uvm_cmdline_proc.get_arg_values("+uvm_set_severity=",values));

  foreach(values[i]) begin
    uvm_split_string(values[i], ",", args);
    if(args.size() != 4) begin
      `uvm_warning("INVLCMDARGS", $sformatf("+uvm_set_severity requires 4 arguments, only %0d given for command +uvm_set_severity=%s, Usage: +uvm_set_severity=<comp>,<id>,<orig_severity>,<new_severity>", args.size(), values[i]))
      values.delete(i);
      break;
    end
    if (!uvm_is_match(args[0], get_full_name()) ) break; 
    if(args[2] != "_ALL_" && !uvm_string_to_severity(args[2], orig_sev)) begin
      `uvm_warning("INVLCMDARGS", $sformatf("Bad severity argument \"%s\" given to command +uvm_set_severity=%s, Usage: +uvm_set_severity=<comp>,<id>,<orig_severity>,<new_severity>", args[2], values[i]))
      values.delete(i);
      break;
    end
    if(!uvm_string_to_severity(args[3], sev)) begin
      `uvm_warning("INVLCMDARGS", $sformatf("Bad severity argument \"%s\" given to command +uvm_set_severity=%s, Usage: +uvm_set_severity=<comp>,<id>,<orig_severity>,<new_severity>", args[3], values[i]))
      values.delete(i);
      break;
    end
    if(args[1] == "_ALL_" && args[2] == "_ALL_") begin
      set_report_severity_override(UVM_INFO,sev);
      set_report_severity_override(UVM_WARNING,sev);
      set_report_severity_override(UVM_ERROR,sev);
      set_report_severity_override(UVM_FATAL,sev);
    end
    else if(args[1] == "_ALL_") begin
      set_report_severity_override(orig_sev,sev);
    end
    else if(args[2] == "_ALL_") begin
      set_report_severity_id_override(UVM_INFO,args[1],sev);
      set_report_severity_id_override(UVM_WARNING,args[1],sev);
      set_report_severity_id_override(UVM_ERROR,args[1],sev);
      set_report_severity_id_override(UVM_FATAL,args[1],sev);
    end
    else begin
      set_report_severity_id_override(orig_sev,args[1],sev);
    end
  end
endfunction

