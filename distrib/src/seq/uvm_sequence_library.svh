//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
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
//----------------------------------------------------------------------


typedef class uvm_sequence_library_cfg;

//------------------------------------------------------------------------------
//
// CLASS: uvm_sequence_library
//
// The ~uvm_sequence_library~ is a sequence that contains a list of registered
// sequence types. It can be configured to create and execute these sequences
// any number of times using one of several modes of operation, including a
// user-defined mode.
//
// When started (as any other sequence), the sequence library will randomly
// select and execute a sequence from its ~sequences~ queue. If in
// <UVM_SEQ_LIB_RAND> mode, its <select_rand> property is randomized and used
// as an index into ~sequences~.  When in <UVM_SEQ_LIB_RANC> mode, the
// <select_randc> property is used. When in <UVM_SEQ_LIB_ITEM> mode, only
// sequence items of the ~REQ~ type are generated and executed--no sequences
// are executed. Finally, when in <UVM_SEQ_LIB_USER> mode, the
// <select_sequence> method is called to obtain the index for selecting the
// next sequence to start. Users can override this method in subtypes to
// implement custom selection algorithms.
//
//------------------------------------------------------------------------------

class uvm_sequence_library #(type REQ=int,RSP=REQ) extends uvm_sequence #(REQ,RSP);

   // Function: new
   //
   // Create a new instance of this class
   //
   extern function new(string name="");


   // Function: get_type_name
   //
   // Get the type name of this class
   //
   extern virtual function string get_type_name();



   //--------------------------
   // Group: Sequence selection
   //--------------------------

   // Variable: selection_mode
   //
   // Specifies the mode used to select sequences for execution
   //
   // If you do not have access to an instance of the library,
   // use the configuration resource interface.
   //
   // The following example sets the ~config_seq_lib~ as the default
   // sequence for the 'main' phase on the sequencer to be
   // located at "env.agent.sequencer"
   // and set the selection mode to <UVM_SEQ_LIB_RANDC>. If the
   // settings are being done from within a component, the first
   // argument must be ~this~ and the second argument a path
   // relative to that component.
   // 
   //
   //| uvm_config_db #(uvm_object_wrapper)::set(null,
   //|                                    "env.agent.sequencer.main_ph",
   //|                                    "default_sequence",
   //|                                    main_seq_lib::get_type());
   //|
   //| // default sequences inherit sequencer's thread mode
   //| uvm_config_db #(uvm_thread_mode)::set(null,
   //|                                    "env.agent.sequencer.main_ph",
   //|                                    "default_sequence.thread_mode",
   //|                                    UVM_PHASE_IMPLICIT_OBJECTION);
   //|
   //| uvm_config_db #(uvm_sequence_lib_mode)::set(null,
   //|                                    "env.agent.sequencer.main_ph",
   //|                                    "default_sequence.selection_mode",
   //|                                    UVM_SEQ_LIB_RANDC);
   //
   // Alternatively, you may create an instance of the sequence library
   // apriori, initialize all its parameters, randomize it, then set it
   // to run as-is on the sequencer. 
   //
   //| main_seq_lib my_seq_lib;
   //| my_seq_lib = new("my_seq_lib");
   //|
   //| my_seq_lib.selection_mode = UVM_SEQ_LIB_RANDC;
   //| my_seq_lib.min_random_count = 500;
   //| my_seq_lib.max_random_count = 1000;
   //| void'(my_seq_lib.randomize());
   //|
   //| uvm_config_db #(uvm_sequence_base)::set(null,
   //|                                    "env.agent.sequencer.main_ph",
   //|                                    "default_sequence",
   //|                                    my_seq_lib);
   //|
   //| uvm_config_db #(uvm_thread_mode)::set(null,
   //|                                    "env.sequencer",
   //|                                    "default_sequence.thread_mode",
   //|                                    UVM_PHASE_IMPLICIT_OBJECTION);
   //|
   //
   protected uvm_sequence_lib_mode selection_mode;


   // Variable: min_random_count
   //
   // Sets the minimum number of items to execute. Use the configuration
   // mechanism to set. See <selection_mode> for an example.
   //
   protected int unsigned min_random_count=20;


   // Variable: max_random_count
   //
   // Sets the maximum number of items to execute. Use the configuration
   // mechanism to set. See <selection_mode> for an example.
   //
   //
   protected int unsigned max_random_count=20;



   // Variable: sequences_executed
   //
   // Indicates the number of sequences executed, not including the
   // currently executing sequence, if any.
   //
   protected int unsigned sequences_executed;


   // Variable: sequence_count
   //
   // Specifies the number of sequences to execute when this sequence
   // library is started. If in <UVM_SEQ_LIB_ITEM> mode, specifies the
   // number of sequence items that will be generated.
   //
   rand  int unsigned sequence_count;


   // Variable: select_rand
   //
   // The index variable that is randomized to select the next sequence
   // to execute when in UVM_SEQ_LIB_RAND mode
   //
   // Extensions may place additional constraints on this variable.
   //
   rand  int unsigned select_rand;


   // Variable: select_randc
   //
   // The index variable that is randomized to select the next sequence
   // to execute when in UVM_SEQ_LIB_RANDC mode
   //
   // Extensions may place additional constraints on this variable.
   //
   randc int unsigned select_randc;



   // Variable- seqs_distrib
   //
   //
   //
   protected int seqs_distrib[string]
   `ifndef INCA
   = '{default:0}
   `endif
   ;


   // Variable: sequences
   //
   // The container of all registered sequence types. For <sequence_count>
   // times, this sequence library will randomly select and execute a
   // sequence from this list of sequence types.
   //
   protected uvm_object_wrapper sequences[$];



   // Constraint: valid_rand_selection
   //
   // Constrains <select_rand> to be a valid index into the ~sequences~ array
   //
   constraint valid_rand_selection {
      select_rand < sequences.size();
   }



   // Constraint: valid_randc_selection
   //
   // Constrains <select_randc> to be a valid index into the ~sequences~ array
   //
   constraint valid_randc_selection {
      select_randc < sequences.size();
   }



   // Constraint: valid_sequence_count
   //
   // Constrains <sequence_count> to lie within the range defined by
   // <min_random_count> and <max_random_count>.
   //
   constraint valid_sequence_count {
      sequence_count inside {[min_random_count:max_random_count]};
   }



   // Function: select_sequence
   //
   // Generates an index used to select the next sequence to execute. 
   // Overrides must return a value between 0 and ~max~, inclusive.
   // Used only for <UVM_SEQ_LIB_USER> selection mode. The
   // default implementation returns 0, incrementing on successive calls,
   // wrapping back to 0 when reaching ~max~.
   //
   extern virtual function int unsigned select_sequence(int unsigned max);


   // Function: pre_randomize
   //
   // Loads all statically registered sequence types. Subtypes of this class
   // must call ~super.pre_randomize()~
   //
   extern function void pre_randomize();



   //-----------------------------
   // Group: Sequence registration
   //-----------------------------

   // Function: add_typewide_sequence
   //
   // Registers the provided sequence type with this sequence library
   // type. The sequence type will be available for selection by all instances
   // of this class. Sequence types already registered are silently ignored.
   //
   extern static function void add_typewide_sequence(uvm_object_wrapper seq_type);



   // Function: add_typewide_sequences
   //
   // Registers the provided sequence types with this sequence library
   // type. The sequence types will be available for selection by all instances
   // of this class. Sequence types already registered are silently ignored.
   //
   //
   extern static function void add_typewide_sequences(uvm_object_wrapper seq_types[$]);


   // Function: add_sequence
   //
   // Registers the provided sequence type with this sequence library
   // instance. Sequence types already registered are silently ignored.
   //
   //
   extern function void add_sequence(uvm_object_wrapper seq_type);


   // Function: add_sequences
   //
   // Registers the provided sequence types with this sequence library
   // instance. Sequence types already registered are silently ignored.
   //
   //
   extern virtual function void add_sequences(uvm_object_wrapper seq_types[$]);


   // Function: get_sequences
   //
   // 
   // Append to the provided ~seq_types~ array the list of registered <sequences>.
   //
   //
   extern virtual function void get_sequences(ref uvm_object_wrapper seq_types[$]);



   //------------------------------------------
   // PRIVATE - INTERNAL - NOT PART OF STANDARD
   //------------------------------------------

   `uvm_object_param_utils(uvm_sequence_library #(REQ,RSP))
   typedef uvm_sequence_library #(REQ,RSP) this_type;

   static const string type_name = "uvm_sequence_library #(REQ,RSP)";
   static protected uvm_object_wrapper m_typewide_sequences[$];

   extern static   function bit  m_static_check(uvm_object_wrapper seq_type);
   extern          function bit  m_check(uvm_object_wrapper seq_type);
   extern          function void m_get_config();
   extern static   function bit  m_add_typewide_sequence(uvm_object_wrapper seq_type);
   extern virtual  function void m_add_typewide_sequences
                                  (ref uvm_object_wrapper seq_types[$]);
   extern virtual  task          execute(uvm_object_wrapper wrap);

   extern virtual  task          body();
   extern virtual  function void do_print(uvm_printer printer);

endclass



//------------------------------------------------------------------------------
//
// CLASS: uvm_sequence_library_cfg
//
// A convenient container class for configuring all the sequence library
// parameters using a single ~set~ command.
//
//| uvm_sequence_library_cfg cfg;
//| cfg = new("seqlib_cfg", UVM_SEQ_LIB_RANDC, 1000, 2000);
//|
//| uvm_config_db #(uvm_sequence_base)::set(null,
//|                                    "env.agent.sequencer.main_ph",
//|                                    "default_sequence.config",
//|                                    cfg);
//|
//------------------------------------------------------------------------------

class uvm_sequence_library_cfg extends uvm_object;
  `uvm_object_utils(uvm_sequence_library_cfg)
  uvm_sequence_lib_mode selection_mode;
  int unsigned min_random_count;
  int unsigned max_random_count;
  function new(string name="",
               uvm_sequence_lib_mode mode=UVM_SEQ_LIB_RAND,
               int unsigned min=1,
               int unsigned max=10);
    super.new(name);
    selection_mode = mode;
    min_random_count = min;
    max_random_count = max;
  endfunction
endclass



//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

// new
// ---

function uvm_sequence_library::new(string name="");
   super.new(name);
   //m_add_typewide_sequences(sequences);
endfunction


// get_type_name
// -------------

function string uvm_sequence_library::get_type_name();
  return type_name;
endfunction


// m_add_typewide_sequence
// -----------------------

function bit uvm_sequence_library::m_add_typewide_sequence(uvm_object_wrapper seq_type);
  this_type::add_typewide_sequence(seq_type);
  return 1;
endfunction


// add_typewide_sequence
// ---------------------

function void uvm_sequence_library::add_typewide_sequence(uvm_object_wrapper seq_type);
  if (m_static_check(seq_type))
    m_typewide_sequences.push_back(seq_type);
endfunction


// add_typewide_sequences
// ----------------------

function void uvm_sequence_library::add_typewide_sequences(uvm_object_wrapper seq_types[$]);
  foreach (seq_types[i])
    add_typewide_sequence(seq_types[i]);
endfunction


// add_sequence
// ------------

function void uvm_sequence_library::add_sequence(uvm_object_wrapper seq_type);
  if (m_check(seq_type))
    sequences.push_back(seq_type);
endfunction


// add_sequences
// -------------

function void uvm_sequence_library::add_sequences(uvm_object_wrapper seq_types[$]);
  foreach (seq_types[i])
    add_sequence(seq_types[i]);
endfunction


// get_sequences
// -------------

function void uvm_sequence_library::get_sequences(ref uvm_object_wrapper seq_types[$]);
  foreach (sequences[i])
    seq_types.push_back(sequences[i]);
endfunction


// select_sequence
// ---------------

function int unsigned uvm_sequence_library::select_sequence(int unsigned max);
  static int unsigned counter;
  select_sequence = counter;
  counter++;
  if (counter > max)
    counter = 0;
endfunction


// pre_randomize
// -------------

function void uvm_sequence_library::pre_randomize();
   m_add_typewide_sequences(sequences);
endfunction


//----------//
// INTERNAL //
//----------//

// m_add_typewide_sequences
// ------------------------

function void uvm_sequence_library::m_add_typewide_sequences(ref uvm_object_wrapper seq_types[$]);
  foreach (this_type::m_typewide_sequences[i])
    seq_types.push_back(this_type::m_typewide_sequences[i]);
endfunction


// m_static_check
// --------------


function bit uvm_sequence_library::m_static_check(uvm_object_wrapper seq_type);
  uvm_object obj;
  uvm_sequence #(REQ,RSP) seq; 
  obj = seq_type.create_object();
  if (!$cast(seq,obj)) begin
     uvm_root top = uvm_root::get();
    `uvm_error_context("BAD_SEQ_TYPE",
       {"Registered object '",obj.get_type_name(),
       "' is not a sequence of type ",REQ::type_name},top)
    return 0;
  end
  foreach (m_typewide_sequences[i])
    if (m_typewide_sequences[i] == seq_type)
      return 0;
  return 1;
endfunction


// m_check
// -------

function bit uvm_sequence_library::m_check(uvm_object_wrapper seq_type);
  foreach (sequences[i])
    if (sequences[i] == seq_type) begin
      return 0;
    end
endfunction


// m_get_config
// ------------

function void uvm_sequence_library::m_get_config();

  uvm_sequence_library_cfg cfg;

  if (uvm_config_db #(uvm_sequence_library_cfg)::get(m_sequencer, 
                                        {starting_phase.get_name(),"_ph"},
                                        "default_sequence.config",
                                        cfg) ) begin
    selection_mode = cfg.selection_mode; 
    min_random_count = cfg.min_random_count; 
    max_random_count = cfg.max_random_count; 
  end
  else begin
    void'(uvm_config_db #(int unsigned)::get(m_sequencer, 
                                        {starting_phase.get_name(),"_ph"},
                                        "default_sequence.min_random_count",
                                        min_random_count) );

    void'(uvm_config_db #(int unsigned)::get(m_sequencer, 
                                        {starting_phase.get_name(),"_ph"},
                                        "default_sequence.max_random_count",
                                        max_random_count) );

    void'(uvm_config_db #(uvm_sequence_lib_mode)::get(m_sequencer, 
                                        {starting_phase.get_name(),"_ph"},
                                        "default_sequence.selection_mode",
                                        selection_mode) );
  end

  if (min_random_count > max_random_count) begin
    `uvm_error("BAD_MIN_MAX",
       $sformatf("min_random_count (%0d) greater than max_random_count (%0d)",
       min_random_count,max_random_count))
    min_random_count = max_random_count;
  end

  if (min_random_count < 1) begin
    `uvm_error("BAD_MIN_MAX",
       $sformatf("min_random_count (%0d) less then one. Nothing will be done.",
       min_random_count))
  end

endfunction


// body
// ----

task uvm_sequence_library::body();

  uvm_object_wrapper wrap;

  m_get_config();

  `uvm_info("SEQ_LIB_START",{"Starting sequence library in phase ",starting_phase.get_name()},UVM_LOW)

  //print(uvm_default_table_printer);

  `uvm_info("SEQ_LIB_MODE", {"Mode is ",selection_mode.name()},UVM_MEDIUM)

    case (selection_mode)

      UVM_SEQ_LIB_RAND: begin
        for (int i=1; i<=sequence_count; i++) begin
          if (!randomize(select_rand)) begin
            `uvm_error("SEQ_LIB_RAND_FAIL", "Random sequence selection failed")
            wrap = REQ::get_type();
          end
          else begin
            wrap = sequences[select_rand];
          end
          execute(wrap);
        end
      end

      UVM_SEQ_LIB_RANDC: begin
        uvm_object_wrapper q[$];
        for (int i=1; i<=sequence_count; i++) begin
          if (!randomize(select_randc)) begin
            `uvm_error("SEQ_LIB_RANDC_FAIL", "Random sequence selection failed")
            wrap = REQ::get_type();
          end
          else begin
            wrap = sequences[select_randc];
          end
          q.push_back(wrap);
        end
        foreach(q[i])
          execute(q[i]);
      end

      UVM_SEQ_LIB_ITEM: begin
        for (int i=1; i<=sequence_count; i++) begin
          wrap = REQ::get_type();
          execute(wrap);
        end
      end

      UVM_SEQ_LIB_USER: begin
        for (int i=1; i<=sequence_count; i++) begin
          int user_selection;
          user_selection = select_sequence(sequences.size()-1);
          if (user_selection >= sequences.size()) begin
            `uvm_error("SEQ_LIB_USER_FAIL", "User sequence selection out of range")
            wrap = REQ::get_type();
          end
          else begin
            wrap = sequences[user_selection];
          end
          execute(wrap);
        end
      end

      default: begin
        `uvm_fatal("SEQ_LIB_RAND_MODE", 
           $sformatf("Unknown random sequence selection mode: %0d",selection_mode))
      end
     endcase

  `uvm_info("SEQ_LIB_ENDED",{"Ending sequence library in phase ",starting_phase.get_name()},UVM_LOW)
  `uvm_info("SEQ_LIB_DSTRB",$sformatf("%p",seqs_distrib),UVM_HIGH)

endtask


// execute
// -------

task uvm_sequence_library::execute(uvm_object_wrapper wrap);

  uvm_object obj;
  uvm_factory factory;
  uvm_sequence_item seq_or_item;

  factory = uvm_factory::get();

  obj = factory.create_object_by_type(wrap,get_full_name(),
           $sformatf("seq_%0d",sequences_executed+1));
  void'($cast(seq_or_item,obj)); // already qualified, 

  seq_or_item.print_sequence_info = 1;
  start_item(seq_or_item);
  if (!seq_or_item.randomize())
     `uvm_error("SEQ_LIB_RAND_FAIL", "Failed to randomize sequence")
  finish_item(seq_or_item);
  seqs_distrib[seq_or_item.get_type_name()]++;

  sequences_executed++;

endtask
  


// do_print
// --------

function void uvm_sequence_library::do_print(uvm_printer printer);
   printer.print_int("min_random_count",min_random_count,32,UVM_DEC,,"int unsigned");
   printer.print_int("max_random_count",max_random_count,32,UVM_DEC,,"int unsigned");
   printer.print_generic("selection_mode","uvm_sequence_lib_mode",32,selection_mode.name());
   printer.print_int("sequence_count",sequence_count,32,UVM_DEC,,"int unsigned");

   printer.print_array_header("typewide_sequences",m_typewide_sequences.size(),"queue_object_types");
   foreach (m_typewide_sequences[i])
     printer.print_generic($sformatf("[%0d]",i),"uvm_object_wrapper","-",m_typewide_sequences[i].get_type_name());
   printer.print_array_footer();

   printer.print_array_header("sequences",sequences.size(),"queue_object_types");
   foreach (sequences[i])
     printer.print_generic($sformatf("[%0d]",i),"uvm_object_wrapper","-",sequences[i].get_type_name());
   printer.print_array_footer();

   printer.print_array_header("seqs_distrib",seqs_distrib.num(),"as_int_string");
   foreach (seqs_distrib[typ])
     printer.print_int({"[",typ,"]"},seqs_distrib[typ],UVM_DEC,,"int unsigned");
   printer.print_array_footer();
endfunction


