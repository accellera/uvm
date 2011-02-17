//----------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc.
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

import uvm_pkg::*;
`include "uvm_macros.svh"

module top;

  `include "simple_item.sv"
  `include "simple_sequencer.sv"
  `include "simple_driver.sv"

  // SEQUENCE LIBRARY SUBTYPE DECLARATIONS
  //
  // subtypes use the `uvm_sequence_library_utils macro;
  // we create subtypes here so that we can statically initialize
  // (register) sequences within the declarations of those sequence.
  // Other reasons to subtype include implementation of the
  // USER sequence selection mode, adding constraints, etc.

  typedef uvm_sequence_library #(simple_item) simple_seq_lib;

  `define uvm_seq_lib_decl(TYPE,BASE) \
    class TYPE extends BASE; \
      `uvm_object_utils(TYPE) \
      `uvm_sequence_library_utils(TYPE) \
      function new(string name=""); \
        super.new(name); \
        init_sequence_library(); \
      endfunction \
    endclass

  `uvm_seq_lib_decl(simple_seq_lib_RST,simple_seq_lib)
  `uvm_seq_lib_decl(simple_seq_lib_CFG,simple_seq_lib)
  `uvm_seq_lib_decl(simple_seq_lib_MAIN,simple_seq_lib)
  `uvm_seq_lib_decl(simple_seq_lib_SHUT,simple_seq_lib)


  // SEQUENCES DECLARATIONS
  //
  // Quickly define a bunch of skeleton sequences for testing purposes.
  // (they do nothing in body() except print the fact they are executing).
  //
  // Each sequence will invoke one or more `uvm_add_to_seq_lib macros to
  // statically register it with one or more sequence library types previously
  // defined. We pass such invocations as a parameter to the macro so we
  //

  `define seq_decl_1lib(TYPE,BASE,LIBTYPE) \
    class TYPE extends BASE; \
      function new(string name=`"TYPE`"); \
        super.new(name); \
      endfunction \
      `uvm_object_utils(TYPE)     \
      `uvm_add_to_seq_lib(TYPE, LIBTYPE) \
      virtual task body(); \
        `uvm_info("SEQ_START", {"Executing sequence '", \
           get_full_name(),"' (",get_type_name(),")"},UVM_DEBUG) \
        #1; \
      endtask \
    endclass

  `define seq_decl_2lib(TYPE,BASE,LIBTYPE1,LIBTYPE2) \
    class TYPE extends BASE; \
      function new(string name=`"TYPE`"); \
        super.new(name); \
      endfunction \
      `uvm_object_utils(TYPE)     \
      `uvm_add_to_seq_lib(TYPE, LIBTYPE1) \
      `uvm_add_to_seq_lib(TYPE, LIBTYPE2) \
      virtual task body(); \
        `uvm_info("SEQ_START", {"Executing sequence '", \
           get_full_name(),"' (",get_type_name(),")"},UVM_DEBUG) \
        #1; \
      endtask \
    endclass

   typedef uvm_sequence #(simple_item) simple_seq;

  `seq_decl_1lib(seqA,simple_seq,simple_seq_lib_RST)
  `seq_decl_1lib(seqB,simple_seq,simple_seq_lib_RST)
  `seq_decl_1lib(seqC,simple_seq,simple_seq_lib_CFG)
  `seq_decl_2lib(seqD,simple_seq,simple_seq_lib_CFG,simple_seq_lib_MAIN)
  `seq_decl_1lib(seqE,simple_seq,simple_seq_lib_MAIN)
  `seq_decl_1lib(seqF,simple_seq,simple_seq_lib_MAIN)
  `seq_decl_1lib(seqG,simple_seq,simple_seq_lib)

  `seq_decl_1lib(seqU1,simple_seq,simple_seq_lib_SHUT)
  `seq_decl_1lib(seqU2,simple_seq,simple_seq_lib_SHUT)
  `seq_decl_1lib(seqU3,simple_seq,simple_seq_lib_SHUT)

  `seq_decl_1lib(seqAextend,seqA,simple_seq_lib_RST)
  `seq_decl_1lib(seqEextend,seqE,simple_seq_lib_MAIN)
  `seq_decl_1lib(seqGextend,seqG,simple_seq_lib)


  // SIMPLE TEST COMPONENT
  //
  // Normal component in most respects. Test infrastructure
  // requires top-level component be called 'test'

  class test extends uvm_component;

     `uvm_component_utils(test)

     function new(string name, uvm_component parent=null);
       super.new(name,parent);
     endfunction

     simple_sequencer sequencer;
     simple_driver driver;

     virtual function void build_phase(uvm_phase phase);
       sequencer = new("sequencer", this);
       driver = new("driver", this);
       uvm_default_printer=uvm_default_line_printer;
     endfunction

     virtual function void connect_phase(uvm_phase phase);
       driver.seq_item_port.connect(sequencer.seq_item_export);
     endfunction

     virtual task post_shutdown_phase(uvm_phase phase);
        global_stop_request();
     endtask

     virtual function void report();
       uvm_root top = uvm_root::get();
       uvm_report_server svr = top.get_report_server();
       if (svr.get_severity_count(UVM_FATAL) +
           svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
       else
         $write("** UVM TEST FAILED **\n");
     endfunction

  endclass


  // TEST CONFIGURATION.
  //
  // This could be inside the test class.

  typedef uvm_config_db #(uvm_object_wrapper) phase_rsrc;

  initial begin

    // Set the default sequence to run for 4 of the run-time phases.
    // The instance path is the path to the sequencer concatenated with the phase name
    // The field name is "default_sequence"
    phase_rsrc::set(null, "uvm_test_top.sequencer.reset_phase",     "default_sequence", simple_seq_lib_RST::get_type());
    phase_rsrc::set(null, "uvm_test_top.sequencer.configure_phase", "default_sequence", simple_seq_lib_CFG::get_type());
    phase_rsrc::set(null, "uvm_test_top.sequencer.main_phase",      "default_sequence", simple_seq_lib_MAIN::get_type());
    phase_rsrc::set(null, "uvm_test_top.sequencer.shutdown_phase",  "default_sequence", simple_seq_lib_SHUT::get_type());

    // Set the sequence selection mode different for each sequence library.
    // Had we created instances of the seq lib first, we could configure the
    // mode and min/max settings, apply randomize...with constraints, etc.
    // then set those instances to be the default sequence.

    // set mode for all phases in sequencer to "ITEM"
    uvm_config_db #(uvm_sequence_lib_mode)::set(null,
                                          "uvm_test_top.sequencer.*",
                                          "default_sequence.selection_mode",
                                          UVM_SEQ_LIB_ITEM);

    // then override the mode for three of the four phases.
    // this tests the the config overrides work  
    uvm_config_db #(uvm_sequence_lib_mode)::set(null,
                                          "uvm_test_top.sequencer.reset_phase",
                                          "default_sequence.selection_mode",
                                          UVM_SEQ_LIB_RAND);

    uvm_config_db #(uvm_sequence_lib_mode)::set(null,
                                          "uvm_test_top.sequencer.configure_phase",
                                          "default_sequence.selection_mode",
                                          UVM_SEQ_LIB_RANDC);

    uvm_config_db #(uvm_sequence_lib_mode)::set(null,
                                          "uvm_test_top.sequencer.shutdown_phase",
                                          "default_sequence.selection_mode",
                                          UVM_SEQ_LIB_USER);

    repeat (10) #0;
    // Verify simple_seq_lib
    begin

    simple_seq_lib lib;  // MUST NOT INITIALIZE LIB HERE; CREATES RACE CONDITION
    uvm_object_wrapper seqs[$];
    bit seq_aa[string];
    lib = new("lib");
    lib.get_sequences(seqs);
    if (seqs.size() != 2) begin
      `uvm_error("BAD_BASE_SEQ_LIB",$sformatf("Base simple_seq_lib size is %0d, expected 2",seqs.size()))
    end
    foreach (seqs[i])
      seq_aa[seqs[i].get_type_name()] = 1;
    if (!seq_aa.exists("seqG"))       `uvm_error("SEQ_NOT_FOUND",{"seqG not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqGextend")) `uvm_error("SEQ_NOT_FOUND",{"seqGextend not found in library  ",lib.get_name()})
    end

    // Verify simple_seq_lib_RST
    begin
    simple_seq_lib_RST lib;
    uvm_object_wrapper seqs[$];
    bit seq_aa[string];
    lib = new("lib");
    lib.get_sequences(seqs);
    if (seqs.size() != 5) begin
      `uvm_error("BAD_RST_SEQ_LIB",$sformatf("%s size is %0d, expected 5",lib.get_name(),seqs.size()))
    end
    foreach (seqs[i])
      seq_aa[seqs[i].get_type_name()] = 1;
    if (!seq_aa.exists("seqA"))       `uvm_error("SEQ_NOT_FOUND",{"seqA not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqAextend")) `uvm_error("SEQ_NOT_FOUND",{"seqAextend not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqB"))       `uvm_error("SEQ_NOT_FOUND",{"seqB not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqG"))       `uvm_error("SEQ_NOT_FOUND",{"seqG not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqGextend")) `uvm_error("SEQ_NOT_FOUND",{"seqGextend not found in library  ",lib.get_name()})
    end

    // Verify simple_seq_lib_CFG
    begin
    simple_seq_lib_CFG lib;
    uvm_object_wrapper seqs[$];
    bit seq_aa[string];
    lib = new("lib");
    lib.get_sequences(seqs);
    if (seqs.size() != 4) begin
      `uvm_error("BAD_CFG_SEQ_LIB",$sformatf("%s size is %0d, expected 4",lib.get_name(),seqs.size()))
    end
    foreach (seqs[i])
      seq_aa[seqs[i].get_type_name()] = 1;
    if (!seq_aa.exists("seqC"))       `uvm_error("SEQ_NOT_FOUND",{"seqC not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqD"))       `uvm_error("SEQ_NOT_FOUND",{"seqD not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqG"))       `uvm_error("SEQ_NOT_FOUND",{"seqG not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqGextend")) `uvm_error("SEQ_NOT_FOUND",{"seqGextend not found in library  ",lib.get_name()})
    end

    // Verify simple_seq_lib_MAIN
    begin
    simple_seq_lib_MAIN lib;
    uvm_object_wrapper seqs[$];
    bit seq_aa[string];
    lib = new("lib");
    lib.get_sequences(seqs);
    if (seqs.size() != 6) begin
      `uvm_error("BAD_MAIN_SEQ_LIB",$sformatf("%s size is %0d, expected 6",lib.get_name(),seqs.size()))
    end
    foreach (seqs[i])
      seq_aa[seqs[i].get_type_name()] = 1;
    if (!seq_aa.exists("seqD"))       `uvm_error("SEQ_NOT_FOUND",{"seqD not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqE"))       `uvm_error("SEQ_NOT_FOUND",{"seqE not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqF"))       `uvm_error("SEQ_NOT_FOUND",{"seqF not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqG"))       `uvm_error("SEQ_NOT_FOUND",{"seqG not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqGextend")) `uvm_error("SEQ_NOT_FOUND",{"seqGextend not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqEextend")) `uvm_error("SEQ_NOT_FOUND",{"seqEextend not found in library  ",lib.get_name()})
    end

    // Verify simple_seq_lib_SHUT
    begin
    simple_seq_lib_SHUT lib;
    uvm_object_wrapper seqs[$];
    bit seq_aa[string];
    lib = new("lib");
    lib.get_sequences(seqs);
    if (seqs.size() != 5) begin
      `uvm_error("BAD_SHUT_SEQ_LIB",$sformatf("%s size is %0d, expected 5",lib.get_name(),seqs.size()))
    end
    foreach (seqs[i])
      seq_aa[seqs[i].get_type_name()] = 1;
    if (!seq_aa.exists("seqU1"))      `uvm_error("SEQ_NOT_FOUND",{"seqU1 not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqU2"))      `uvm_error("SEQ_NOT_FOUND",{"seqU2 not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqU3"))      `uvm_error("SEQ_NOT_FOUND",{"seqU3 not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqG"))       `uvm_error("SEQ_NOT_FOUND",{"seqG not found in library  ",lib.get_name()})
    if (!seq_aa.exists("seqGextend")) `uvm_error("SEQ_NOT_FOUND",{"seqGextend not found in library  ",lib.get_name()})
    end

    run_test();

  end

endmodule
