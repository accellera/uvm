//----------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics Corporation
//   Copyright 2011 Synopsys, Inc.
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


// This test exercises all error conditions checked for in
// the sequence library.


`include "uvm_macros.svh"
import uvm_pkg::*;

module top;

  `include "simple_item.sv"
  `include "simple_sequencer.sv"
  `include "simple_driver.sv"

  typedef uvm_sequence_library #(simple_item) simple_seq_lib;

 
  class my_simple_item extends simple_item;
    `uvm_object_utils(my_simple_item)
    function new(string name="");
      super.new(name);
    endfunction
  endclass


  // SEQUENCE LIBRARY DECLARATIONS

  //  We define some derived types. We don't register statically, however.
  // We use the add_typewide_sequence method instead.

  `define seq_lib_decl(TYPE,BASE) \
    class TYPE extends BASE; \
      `uvm_object_utils(TYPE) \
      `uvm_sequence_library_utils(TYPE) \
      function new(string name=""); \
        super.new(name); \
        init_sequence_library(); \
      endfunction \
    endclass

  `seq_lib_decl(simple_seq_lib_RST,simple_seq_lib)
  `seq_lib_decl(simple_seq_lib_MAIN,simple_seq_lib)

  class seq_lib_rand_fail extends simple_seq_lib;
    `uvm_object_utils(seq_lib_rand_fail)
    `uvm_sequence_library_utils(seq_lib_rand_fail)
    function new(string name="");
      super.new(name);
      init_sequence_library();
    endfunction
    constraint rand_fail { select_rand >= 30; }
    constraint randc_fail { select_randc >= 30; }
    function int unsigned select_sequence(int unsigned max);
      return max+1;
    endfunction
    virtual task body();
        `uvm_info("SEQ_START", {"Executing sequence library '", 
           get_full_name(),"' (",get_type_name(),")"},UVM_DEBUG) 
      super.body();
    endtask
  endclass


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
   typedef uvm_sequence #(my_simple_item) my_simple_seq;

  `seq_decl(seqR1,simple_seq)
  `seq_decl(seqC1,simple_seq)
  `seq_decl(seqM1,simple_seq)
  `seq_decl(seqS1,simple_seq)
  `seq_decl(seqXX,my_simple_seq)



  // ITEMS and SEQUENCES to cause ERRORS
  class item extends uvm_sequence_item;
    `uvm_object_utils(item)
    function new(string name="");
      super.new(name);
    endfunction
  endclass

  class item_seq extends uvm_sequence #(item);
    `uvm_object_utils(item_seq)
    function new(string name="item_seq_inst");
      super.new(name);
    endfunction
  endclass

  class rsp_item_seq extends uvm_sequence #(simple_item,item);
    `uvm_object_utils(rsp_item_seq)
    function new(string name="rsp_item_seq_inst");
      super.new(name);
    endfunction
  endclass




  //----------------------------------------------------------------------------

  class test extends uvm_component;

     `uvm_component_utils(test)

     static bit failed;
     static int reports[string];

     function new(string name, uvm_component parent=null);
       super.new(name,parent);
     endfunction

     simple_sequencer sequencer;
     simple_driver driver;

      uvm_sequencer #(uvm_sequence_item) base_seqr;

     virtual function void build_phase(uvm_phase phase);
       driver    = new("driver", this);
       sequencer = new("sequencer", this);
       base_seqr = new("base_seqr");
       uvm_default_printer=uvm_default_line_printer;
     endfunction

     virtual function void connect_phase(uvm_phase phase);
       driver.seq_item_port.connect(sequencer.seq_item_export);
     endfunction

     virtual task main_phase(uvm_phase phase);
       uvm_sequence_library #(uvm_sequence_item) base_seq_lib;

       phase.raise_objection(this);

       // ERROR: SEQLIB/NOSEQS
       begin
         base_seq_lib = new("base_seq_lib");
         base_seq_lib.starting_phase = phase;
         base_seq_lib.selection_mode = UVM_SEQ_LIB_ITEM;
         base_seq_lib.starting_phase = phase;
         base_seq_lib.start(base_seqr);
       end

       begin
         seq_lib_rand_fail seq_fail;
         seq_fail = new("seq_FAIL");

         // ERROR: SEQLIB/BAD_SEQ_TYPE, BAD_REQ_TYPE, BAD_RSP_TYPE
         seq_fail.add_sequence(item::get_type());
         seq_fail.add_sequence(item_seq::get_type());
         seq_fail.add_sequence(rsp_item_seq::get_type());

         // ERROR: SEQLIB/BAD_SEQ_TYPE, BAD_REQ_TYPE, BAD_RSP_TYPE
         seq_fail.add_typewide_sequence(item::get_type());
         seq_fail.add_typewide_sequence(item_seq::get_type());
         seq_fail.add_typewide_sequence(rsp_item_seq::get_type());

         seq_fail.add_sequence(seqM1::get_type());
         seq_fail.add_sequence(seqC1::get_type());

         // ERROR: SEQLIB/RAND_FAIL
         seq_fail.selection_mode = UVM_SEQ_LIB_RAND;
         void'(seq_fail.randomize());
         seq_fail.start(sequencer);

         // ERROR: SEQLIB/RANDC_FAIL
         seq_fail.selection_mode = UVM_SEQ_LIB_RANDC;
         void'(seq_fail.randomize());
         seq_fail.start(sequencer);
       end
       
       // WARNING: SEQLIB/MIN_GT_MAX
       begin
         simple_seq_lib lib;
         lib = new("MIN_GT_MAX");
         lib.add_sequence(seqR1::get_type());
         lib.add_sequence(seqXX::get_type());
         lib.min_random_count = 5;
         lib.max_random_count = 4;
         lib.starting_phase = phase;
         void'(lib.randomize());
         lib.set_sequencer(sequencer);
         lib.start(sequencer);
       end

       // WARNING: SEQLIB/MAX_ZERO
       begin
         simple_seq_lib lib;
         lib = new("MAX_ZERO");
         lib.selection_mode = UVM_SEQ_LIB_ITEM;
         lib.add_sequence(seqC1::get_type());
         lib.min_random_count = 0;
         lib.max_random_count = 0;
         lib.starting_phase = phase;
         void'(lib.randomize());
         lib.start(sequencer);
       end

       // ERROR: SEQLIB/VIRT_SEQ
       begin
         simple_seq_lib lib;
         lib = new("VIRT_SEQ");
         lib.add_sequence(seqS1::get_type());
         lib.selection_mode = UVM_SEQ_LIB_ITEM;
         lib.starting_phase = phase;
         void'(lib.randomize());
         lib.start(null);
       end

       phase.drop_objection(this);


     endtask

     virtual function void report();
       uvm_root top = uvm_root::get();
       uvm_report_server svr = top.get_report_server();
       $display("Checking report counts");
       if (!reports.exists("SEQLIB/NOSEQS")       || reports["SEQLIB/NOSEQS"]       != 1) failed = 1;
       if (!reports.exists("SEQLIB/BAD_SEQ_TYPE") || reports["SEQLIB/BAD_SEQ_TYPE"] != 2) failed = 1;
       if (!reports.exists("SEQLIB/BAD_REQ_TYPE") || reports["SEQLIB/BAD_REQ_TYPE"] != 2) failed = 1;
       if (!reports.exists("SEQLIB/BAD_RSP_TYPE") || reports["SEQLIB/BAD_RSP_TYPE"] != 2) failed = 1;
       if (!reports.exists("SEQLIB/VIRT_SEQ")     || reports["SEQLIB/VIRT_SEQ"]     != 2) failed = 1;
       if (failed)
         $write("** UVM TEST FAILED **\n");
       else
         $write("** UVM TEST PASSED **\n");
     endfunction

  endclass

  class catcher extends uvm_report_catcher;
     virtual function action_e catch();
     	string id;
        bit ok = 0;
	id=get_id();
        if(get_severity() == UVM_INFO) ok = 1;
        if(get_severity() == UVM_ERROR   && id == "SEQLIB/NOSEQS") ok = 1; 
        if(get_severity() == UVM_ERROR   && id == "SEQLIB/MIN_GT_MAX") ok = 1; 
        if(get_severity() == UVM_ERROR   && id == "SEQLIB/BASE_ITEM") ok = 1; 
        if(get_severity() == UVM_ERROR   && id == "SEQLIB/VIRT_SEQ") ok = 1; 
        if(get_severity() == UVM_WARNING && id == "SEQLIB/MAX_ZERO") ok = 1; 
        if(get_severity() == UVM_FATAL   && id == "SEQLIB/VIRT_SEQ") ok = 1; 
        if(get_severity() == UVM_ERROR   && id == "SEQLIB/BAD_SEQ_TYPE") ok = 1; 
        if(get_severity() == UVM_ERROR   && id == "SEQLIB/BAD_REQ_TYPE") ok = 1; 
        if(get_severity() == UVM_ERROR   && id == "SEQLIB/BAD_RSP_TYPE") ok = 1; 
        if(get_severity() == UVM_ERROR   && id == "SEQLIB/RANDC_FAIL") ok = 1; 
        if(get_severity() == UVM_ERROR   && id == "SEQLIB/RAND_FAIL") ok = 1; 

	
        if (test::reports.exists(id))
          test::reports[id]++;
        else
          test::reports[id]=1;

        if (ok) begin
          set_severity(UVM_INFO);
          set_action(UVM_DISPLAY);
          return THROW;
        end
        else begin
          test::failed = 1;
          return THROW;
        end
     endfunction
  endclass




  initial begin
    catcher ctch;
    ctch = new;
    uvm_report_cb::add(null,ctch);
    run_test();
  end

endmodule
