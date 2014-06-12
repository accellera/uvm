// 
//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010-2011 Synopsys, Inc.
//   Copyright 2013      NVIDIA Corporation
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

module test_mod();

   import uvm_pkg::*;
   `include "uvm_macros.svh"
   
class my_catcher extends uvm_report_catcher;
   int err_seen;
   int warn_seen;
   
   function new(string name);
      super.new(name);
   endfunction : new

   virtual function action_e catch();

      if ((get_severity() == UVM_WARNING) &&
          (get_id() == "UVM_DEPRECATED")) begin
         warn_seen++;
      end
      if ((get_severity() == UVM_ERROR) &&
          (get_id() == "UVM/SEQ/LOCK_DEPR")) begin
         set_severity(UVM_WARNING);
         err_seen++;
      end

      return THROW;
   endfunction : catch
endclass // my_catcher

   // seq_a expects starting_phase to be set manually to 'run_phase'
class seq_a extends uvm_sequence#();
   `uvm_object_utils(seq_a)

   my_catcher catcher;

   function new(string name="unnamed-seq_a");
      super.new(name);
   endfunction : new
      
   task body();
      uvm_phase my_phase;
      
   `ifdef UVM_DEPRECATED_STARTING_PHASE
      if (!starting_phase.is(uvm_run_phase::get()))
        `uvm_error("ERR", "starting_phase != run_phase")

      // Should cause warning
      my_phase = get_starting_phase();
      if (catcher.warn_seen != 1)
        `uvm_error("ERR", "No warning on get_starting_phase")
      if (catcher.err_seen != 0)
        `uvm_error("ERR", "unexpected error seen")

      // Calling again should not get a warning
      my_phase = get_starting_phase();
      if (catcher.warn_seen != 1)
        `uvm_error("ERR", "unexpected warning seen 2")
      if (catcher.err_seen != 0)
        `uvm_error("ERR", "unexpected error seen 2")

      if (!my_phase.is(uvm_run_phase::get()))
        `uvm_error("ERR", "my_phase != run_phase")
   `endif
      
   endtask : body

endclass : seq_a

   // seq_b expects starting_phase to be set manually to 'configure_phase'
   // after set_starting_phase(run_phase) was called
class seq_b extends uvm_sequence#();
   `uvm_object_utils(seq_b)

   my_catcher catcher;

   function new(string name="unnamed-seq_b");
      super.new(name);
   endfunction : new

   task body();
      uvm_phase my_phase;

   `ifdef UVM_DEPRECATED_STARTING_PHASE
      if (!starting_phase.is(uvm_configure_phase::get()))
        `uvm_error("ERR", "starting_phase != configure_phase")

      // Should cause warning
      my_phase = get_starting_phase();
      if (catcher.warn_seen != 2)
        `uvm_error("ERR", "No warning on get_starting_phase")
      if (catcher.err_seen != 0)
        `uvm_error("ERR", "unexpected error seen")


      if (!my_phase.is(uvm_configure_phase::get()))
        `uvm_error("ERR", "my_phase != configure_phase")
   `endif
   endtask // body

endclass // seq_b

   // seq_c expects the starting_phase to be updated to 'configure_phase'
   // after it has been set and locked (via get) to 'run_phase'
class seq_c extends uvm_sequence#();
   `uvm_object_utils(seq_c)

   my_catcher catcher;

   function new(string name="unnamed-seq_c");
      super.new(name);
   endfunction : new
      
   task body();
      uvm_phase my_phase;

      my_phase = get_starting_phase();
   `ifdef UVM_DEPRECATED_STARTING_PHASE
      if (catcher.warn_seen != 3)
        `uvm_error("ERR", "No warning on get_starting_phase")
      if (catcher.err_seen != 1)
        `uvm_error("ERR", "No error on get_starting_phase")
   `endif
   endtask // body
   
endclass : seq_c

   // seq_d expects the starting_phase to be set to 'run_phase',
   // and will call set_starting_phase w/ 'configure_phase'.
class seq_d extends uvm_sequence#();
   `uvm_object_utils(seq_d)

   my_catcher catcher;

   function new(string name="unnamed-seq_d");
      super.new(name);
   endfunction : new

   task body();
      uvm_phase my_phase;

   `ifdef UVM_DEPRECATED_STARTING_PHASE
      // should produce a warning...
      set_starting_phase(uvm_configure_phase::get());
      if (catcher.warn_seen != 4)
        `uvm_error("ERR", "No warning on set_starting_phase")
      if (catcher.err_seen != 1)
        `uvm_error("ERR", "unexpected error seen")

      my_phase = get_starting_phase();
      
      if (my_phase != uvm_configure_phase::get())
        `uvm_error("ERR", $sformatf("expected get_starting_phase to return configure_phase (not %s)", my_phase.get_full_name()))
      if (starting_phase != uvm_configure_phase::get())
        `uvm_error("ERR", $sformatf("expected starting_phase to be configure_phase (not %s)", starting_phase.get_full_name()))

      if (catcher.warn_seen != 4)
        `uvm_error("ERR", "unexpected warning seen 2")
      if (catcher.err_seen != 1)
        `uvm_error("ERR", "unexpected error seen 2")
   `endif //  `ifdef UVM_DEPRECATED_STARTING_PHASE
   endtask // body
endclass // seq_d
   
      
class test extends uvm_component;

   `uvm_component_utils(test)

   uvm_sequencer seqr;
   my_catcher ctchr;
   

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      seqr = new("seqr", this);
      
      ctchr = new("ctchr");
      
      uvm_report_cb::add(null, ctchr);
      
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      seq_a my_a;
      seq_b my_b;
      seq_c my_c;
      seq_d my_d;

      my_a = seq_a::type_id::create("my_a");
      my_a.catcher = ctchr;
   `ifdef UVM_DEPRECATED_STARTING_PHASE
      my_a.starting_phase = phase;
   `endif
      my_a.start(seqr);

      my_b = seq_b::type_id::create("my_b");
      my_b.catcher = ctchr;
      my_b.set_starting_phase(phase);
   `ifdef UVM_DEPRECATED_STARTING_PHASE
      my_b.starting_phase = uvm_configure_phase::get();
   `endif
      my_b.start(seqr);

      my_c = seq_c::type_id::create("my_c");
      my_c.catcher = ctchr;
      my_c.set_starting_phase(phase);
      void'(my_c.get_starting_phase());
   `ifdef UVM_DEPRECATED_STARTING_PHASE
      my_c.starting_phase = uvm_configure_phase::get();
   `endif
      my_c.start(seqr);

      my_d = seq_d::type_id::create("my_d");
      my_d.catcher = ctchr;
   `ifdef UVM_DEPRECATED_STARTING_PHASE
      my_d.starting_phase = phase;
   `endif
      my_d.start(seqr);

   endtask // run_phase
   

   virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      
`ifdef UVM_DEPRECATED_STARTING_PHASE
      if (ctchr.warn_seen != 4)
        `uvm_error("ERR_W",
                   "Didn't see the warnings we expected!")
      else if (ctchr.err_seen != 1)
        `uvm_error("ERR_E",
                   "Didn't see the errors we expected!")
      else
        $display("*** UVM TEST PASSED ***");
`else
      if (ctchr.warn_seen != 0)
        `uvm_error("ERR_W",
                   "Saw unexpected warnings")
      else if (ctchr.err_seen != 0)
        `uvm_error("ERR_E",
                   "Saw unexpected errors")
      else
        $display("*** UVM TEST PASSED ***");
`endif
      
   endfunction : report_phase

endclass // test

   initial begin
      run_test();
   end

endmodule // test_mod
