//----------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics Corporation
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

module top;

  `include "simple_item.sv"
  `include "simple_sequencer.sv"
  `include "simple_driver.sv"


  `define seq_decl(TYPE,BASE,REGISTRATIONS) \
  \
  class TYPE extends BASE; \
    function new(string name=`"TYPE`"); \
      super.new(name); \
    endfunction \
    `uvm_object_utils(TYPE)     \
    REGISTRATIONS \
    virtual task body(); \
      `uvm_info("SEQ_START", {"Executing sequence '", get_full_name(), "' (",get_type_name(),")"},UVM_HIGH) \
      #1; \
    endtask \
  endclass



  `define uvm_add_to_seq_lib(TYPE,LIBTYPE) \
     static bit add_``TYPE``_to_seq_lib_``LIBTYPE =\
        LIBTYPE::add_typewide_sequence(TYPE::get_type());


  typedef uvm_sequence_library #(simple_item) simple_seq_lib;

  `define uvm_seq_lib_decl(TYPE,BASE) \
    class TYPE extends BASE; \
      `uvm_object_utils(TYPE) \
      static protected uvm_object_wrapper m_typewide_sequences[$]; \
      local bit m_added_typewide_seqs; \
      protected uvm_object_wrapper sequences[$]; \
      function new(string name=""); \
        super.new(name); \
      endfunction \
      virtual function void m_add_typewide_sequences(ref uvm_object_wrapper seq_types[$]); \
        if (!m_added_typewide_seqs) begin \
          super.m_add_typewide_sequences(seq_types); \
          foreach (TYPE::m_typewide_sequences[i]) \
            seq_types.push_back(m_typewide_sequences[i]); \
          m_added_typewide_seqs = 1; \
        end \
      endfunction \
     static function bit add_typewide_sequence(uvm_object_wrapper seq_type); \
       if (m_type_check(seq_type)) \
         m_typewide_sequences.push_back(seq_type); \
       return 1; \
     endfunction \
    endclass

  `uvm_seq_lib_decl(simple_seq_lib_RST,simple_seq_lib)
  `uvm_seq_lib_decl(simple_seq_lib_CFG,simple_seq_lib)
  `uvm_seq_lib_decl(simple_seq_lib_MAIN,simple_seq_lib)
  `uvm_seq_lib_decl(simple_seq_lib_SHUT,simple_seq_lib)


  `define Aseqlibs `uvm_add_to_seq_lib(seqA, simple_seq_lib_RST)
  `define Bseqlibs `uvm_add_to_seq_lib(seqB, simple_seq_lib_RST)
  `define Cseqlibs `uvm_add_to_seq_lib(seqC, simple_seq_lib_CFG)

  `define Dseqlibs `uvm_add_to_seq_lib(seqD, simple_seq_lib_CFG) \
                   `uvm_add_to_seq_lib(seqD, simple_seq_lib_MAIN) 

  `define Eseqlibs `uvm_add_to_seq_lib(seqE, simple_seq_lib_MAIN)
  `define Fseqlibs `uvm_add_to_seq_lib(seqF, simple_seq_lib_MAIN)
  `define Gseqlibs `uvm_add_to_seq_lib(seqG, simple_seq_lib)


  `define U1seqlibs `uvm_add_to_seq_lib(seqU1, simple_seq_lib_SHUT)
  `define U2seqlibs `uvm_add_to_seq_lib(seqU2, simple_seq_lib_SHUT)
  `define U3seqlibs `uvm_add_to_seq_lib(seqU3, simple_seq_lib_SHUT)

   typedef uvm_sequence #(simple_item) simple_seq;

  `seq_decl(seqA,simple_seq,`Aseqlibs)
  `seq_decl(seqB,simple_seq,`Bseqlibs)
  `seq_decl(seqC,simple_seq,`Cseqlibs)
  `seq_decl(seqD,simple_seq,`Dseqlibs)
  `seq_decl(seqE,simple_seq,`Eseqlibs)
  `seq_decl(seqF,simple_seq,`Fseqlibs)
  `seq_decl(seqG,simple_seq,`Gseqlibs)

  `seq_decl(seqU1,simple_seq,`U1seqlibs)
  `seq_decl(seqU2,simple_seq,`U2seqlibs)
  `seq_decl(seqU3,simple_seq,`U3seqlibs)

  `seq_decl(seqAextend,seqA,`uvm_add_to_seq_lib(seqAextend,simple_seq_lib_RST))
  `seq_decl(seqEextend,seqE,`uvm_add_to_seq_lib(seqEextend,simple_seq_lib_MAIN))
  `seq_decl(seqGextend,seqG,`uvm_add_to_seq_lib(seqGextend,simple_seq_lib))


  class test extends uvm_component;
     `uvm_component_utils(test)
     function new(string name, uvm_component parent=null);
       super.new(name,parent);
     endfunction
     simple_sequencer sequencer;
     simple_driver driver;
     virtual function void build_phase();
       sequencer = new("sequencer", this);
       driver = new("driver", this);
     endfunction
     virtual function void connect_phase();
       driver.seq_item_port.connect(sequencer.seq_item_export);
       uvm_default_printer=uvm_default_line_printer;
     endfunction
     virtual function void report();
       uvm_root top = uvm_root::get();
       uvm_report_server svr = top.get_report_server();
       if (svr.get_severity_count(UVM_FATAL) +
           svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
       else
         $write("** UVM TEST PASSED **\n");
     endfunction
  endclass

  typedef uvm_config_db #(uvm_object_wrapper) phase_rsrc;


  initial begin

    phase_rsrc::set(null, "uvm_test_top.sequencer.reset_ph",     "default_sequence", simple_seq_lib_RST::get_type());
    phase_rsrc::set(null, "uvm_test_top.sequencer.configure_ph", "default_sequence", simple_seq_lib_CFG::get_type());
    phase_rsrc::set(null, "uvm_test_top.sequencer.main_ph",      "default_sequence", simple_seq_lib_MAIN::get_type());
    phase_rsrc::set(null, "uvm_test_top.sequencer.shutdown_ph",  "default_sequence", simple_seq_lib_SHUT::get_type());

    uvm_config_db #(uvm_sequence_lib_mode)::set(null,
                                          "uvm_test_top.sequencer.*",
                                          "selection_mode",
                                          UVM_SEQ_LIB_ITEM);

    uvm_config_db #(uvm_sequence_lib_mode)::set(null,
                                          "uvm_test_top.sequencer.reset_ph",
                                          "selection_mode",
                                          UVM_SEQ_LIB_RAND);

    uvm_config_db #(uvm_sequence_lib_mode)::set(null,
                                          "uvm_test_top.sequencer.configure_ph",
                                          "selection_mode",
                                          UVM_SEQ_LIB_RANDC);

    uvm_config_db #(uvm_sequence_lib_mode)::set(null,
                                          "uvm_test_top.sequencer.shutdown_ph",
                                          "selection_mode",
                                          UVM_SEQ_LIB_USER);

    uvm_config_db #(uvm_thread_mode)::set(null,
                                          "uvm_test_top.sequencer",
                                          "default_phase_thread_mode",
                                          UVM_PHASE_IMPLICIT_OBJECTION);

    run_test();

  end

endmodule
