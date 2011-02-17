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

  typedef uvm_sequence_library #(simple_item) simple_seq_lib;


  //  We define some derived types. We don't register statically, however.
  // We use the add_typewide_sequence method instead.

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
  `uvm_seq_lib_decl(simple_seq_lib_MAIN,simple_seq_lib)


  // SEQUENCE DECLARATIONS
  //
  // Quickly define a bunch of skeleton sequences for testing purposes.
  // (they do nothing in body() except print the fact they are executing).
  //
  // Each sequence will invoke one or more `uvm_add_to_seq_lib macros to
  // statically register it with one or more sequence library types previously
  // defined. We pass such invocations as a parameter to the macro so we
  //

  `define seq_decl(TYPE,BASE) \
    class TYPE extends BASE; \
      function new(string name=`"TYPE`"); \
        super.new(name); \
      endfunction \
      `uvm_object_utils(TYPE) \
      virtual task body(); \
        `uvm_info("SEQ_START", {"Executing sequence '", \
           get_full_name(),"' (",get_type_name(),")"},UVM_DEBUG) \
        #1; \
      endtask \
    endclass

   typedef uvm_sequence #(simple_item) simple_seq;

  `seq_decl(seqR1,simple_seq)
  `seq_decl(seqR2,simple_seq)
  `seq_decl(seqRT,simple_seq)

  `seq_decl(seqC1,simple_seq)
  `seq_decl(seqC2,simple_seq)

  `seq_decl(seqM1,simple_seq)
  `seq_decl(seqM2,simple_seq)
  `seq_decl(seqMT,seqM1)

  `seq_decl(seqGT1,simple_seq)
  `seq_decl(seqGT2,seqGT1)

  `seq_decl(seqS1,simple_seq)
  `seq_decl(seqS2,simple_seq)
  `seq_decl(seqS3,seqS2)



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

  // NOTE: SEQUENCE INSTANCES, NOT TYPES
  typedef uvm_config_db #(uvm_sequence_base) phase_rsrc;

  initial begin
    simple_seq_lib CFGlib,SHUTlib;
    simple_seq_lib_RST RSTlib;
    simple_seq_lib_MAIN MAINlib;

    simple_seq_lib::add_typewide_sequence(seqGT1::get_type());
    simple_seq_lib::add_typewide_sequence(seqGT2::get_type());
    simple_seq_lib_RST::add_typewide_sequence(seqRT::get_type());
    simple_seq_lib_MAIN::add_typewide_sequence(seqMT::get_type());

    begin
      RSTlib = new("RST");
      RSTlib.add_sequence(seqR1::get_type());
      RSTlib.add_sequence(seqR2::get_type());
      phase_rsrc::set(null, "uvm_test_top.sequencer.reset_phase", "default_sequence", RSTlib);
    end

    begin
      CFGlib = new("CFG");
      CFGlib.add_sequence(seqC1::get_type());
      CFGlib.add_sequence(seqC2::get_type());
      phase_rsrc::set(null, "uvm_test_top.sequencer.configure_phase", "default_sequence", CFGlib);
    end

    begin
      MAINlib = new("MAIN");
      MAINlib.add_sequence(seqC2::get_type());
      MAINlib.add_sequence(seqM1::get_type());
      MAINlib.add_sequence(seqM2::get_type());
      phase_rsrc::set(null, "uvm_test_top.sequencer.main_phase", "default_sequence", MAINlib);
    end

    begin
      SHUTlib = new("SHUT");
      SHUTlib.add_sequence(seqS1::get_type());
      SHUTlib.add_sequence(seqS2::get_type());
      SHUTlib.add_sequence(seqS3::get_type());
      phase_rsrc::set(null, "uvm_test_top.sequencer.shutdown_phase", "default_sequence", SHUTlib);
    end

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

    // Verify simple_seq_lib_RST
    begin
    uvm_object_wrapper seqs[$];
    bit seq_aa[string];
    RSTlib.get_sequences(seqs);
    if (seqs.size() != 5) begin
      `uvm_error("BAD_RST_SEQ_LIB",$sformatf("%s size is %0d, expected 5",RSTlib.get_name(),seqs.size()))
    end
    foreach (seqs[i])
      seq_aa[seqs[i].get_type_name()] = 1;
    if (!seq_aa.exists("seqR1")) `uvm_error("SEQ_NOT_FOUND",{"seqR1 not found in library  ",RSTlib.get_name()})
    if (!seq_aa.exists("seqR2")) `uvm_error("SEQ_NOT_FOUND",{"seqR2 not found in library  ",RSTlib.get_name()})
    if (!seq_aa.exists("seqRT")) `uvm_error("SEQ_NOT_FOUND",{"seqRT not found in library  ",RSTlib.get_name()})
    if (!seq_aa.exists("seqGT1")) `uvm_error("SEQ_NOT_FOUND",{"seqGT1 not found in library  ",RSTlib.get_name()})
    if (!seq_aa.exists("seqGT2")) `uvm_error("SEQ_NOT_FOUND",{"seqGT2 not found in library  ",RSTlib.get_name()})
    end

    // Verify simple_seq_lib_CFG
    begin
    uvm_object_wrapper seqs[$];
    bit seq_aa[string];
    CFGlib.get_sequences(seqs);
    if (seqs.size() != 4) begin
      `uvm_error("BAD_CFG_SEQ_LIB",$sformatf("%s size is %0d, expected 4",CFGlib.get_name(),seqs.size()))
    end
    foreach (seqs[i])
      seq_aa[seqs[i].get_type_name()] = 1;
    if (!seq_aa.exists("seqC1")) `uvm_error("SEQ_NOT_FOUND",{"seqC1 not found in library  ",CFGlib.get_name()})
    if (!seq_aa.exists("seqC2")) `uvm_error("SEQ_NOT_FOUND",{"seqC2 not found in library  ",CFGlib.get_name()})
    if (!seq_aa.exists("seqGT1")) `uvm_error("SEQ_NOT_FOUND",{"seqGT1 not found in library  ",CFGlib.get_name()})
    if (!seq_aa.exists("seqGT2")) `uvm_error("SEQ_NOT_FOUND",{"seqGT2 not found in library  ",CFGlib.get_name()})
    end

    // Verify simple_seq_lib_MAIN
    begin
    uvm_object_wrapper seqs[$];
    bit seq_aa[string];
    MAINlib.get_sequences(seqs);
    if (seqs.size() != 6) begin
      `uvm_error("BAD_MAIN_SEQ_LIB",$sformatf("%s size is %0d, expected 6",MAINlib.get_name(),seqs.size()))
    end
    foreach (seqs[i])
      seq_aa[seqs[i].get_type_name()] = 1;
    if (!seq_aa.exists("seqC2")) `uvm_error("SEQ_NOT_FOUND",{"seqC2 not found in library  ",MAINlib.get_name()})
    if (!seq_aa.exists("seqM1")) `uvm_error("SEQ_NOT_FOUND",{"seqM1 not found in library  ",MAINlib.get_name()})
    if (!seq_aa.exists("seqM2")) `uvm_error("SEQ_NOT_FOUND",{"seqM2 not found in library  ",MAINlib.get_name()})
    if (!seq_aa.exists("seqMT")) `uvm_error("SEQ_NOT_FOUND",{"seqMT not found in library  ",MAINlib.get_name()})
    if (!seq_aa.exists("seqGT1")) `uvm_error("SEQ_NOT_FOUND",{"seqGT1 not found in library  ",MAINlib.get_name()})
    if (!seq_aa.exists("seqGT2")) `uvm_error("SEQ_NOT_FOUND",{"seqGT2 not found in library  ",MAINlib.get_name()})
    end

    // Verify simple_seq_lib_SHUT
    begin
    uvm_object_wrapper seqs[$];
    bit seq_aa[string];
    SHUTlib.get_sequences(seqs);
    if (seqs.size() != 5) begin
      `uvm_error("BAD_SHUT_SEQ_LIB",$sformatf("%s size is %0d, expected 5",SHUTlib.get_name(),seqs.size()))
    end
    foreach (seqs[i])
      seq_aa[seqs[i].get_type_name()] = 1;
    if (!seq_aa.exists("seqS1")) `uvm_error("SEQ_NOT_FOUND",{"seqS1 not found in library  ",SHUTlib.get_name()})
    if (!seq_aa.exists("seqS2")) `uvm_error("SEQ_NOT_FOUND",{"seqS2 not found in library  ",SHUTlib.get_name()})
    if (!seq_aa.exists("seqS3")) `uvm_error("SEQ_NOT_FOUND",{"seqS3 not found in library  ",SHUTlib.get_name()})
    if (!seq_aa.exists("seqGT1")) `uvm_error("SEQ_NOT_FOUND",{"seqGT1 not found in library  ",SHUTlib.get_name()})
    if (!seq_aa.exists("seqGT2")) `uvm_error("SEQ_NOT_FOUND",{"seqGT2 not found in library  ",SHUTlib.get_name()})
    end

    run_test();

  end

endmodule
