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
   int seen;
   
   function new(string name);
      super.new(name);
   endfunction : new

   virtual function action_e catch();

      if ((get_severity() == UVM_ERROR) &&
          (get_id() == "UVM/GET_TO_LOCK_DAP/SAG")) begin
         set_severity(UVM_INFO);
         seen++;
      end

      return THROW;
   endfunction : catch
endclass // my_catcher
   
class my_sequence extends uvm_sequence();

   `uvm_object_utils(my_sequence)

   function new(string name="unnamed-my_sequence");
      super.new(name);
   endfunction : new

   task body();
      uvm_phase configure_phase = uvm_configure_phase::get();
      uvm_phase starting_phase = get_starting_phase();
      
      // Check to see if the phase is set...
      if (starting_phase == null)
        `uvm_error("ERR_A", "get_starting_phase() == null!!!")

      if (!starting_phase.is(configure_phase))
        `uvm_error("ERR_B", "get_starting_phase() != configure_phase!!!")

      // this will cause an error
      set_starting_phase(null);

   endtask : body

endclass // my_sequence
   
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
      
      uvm_config_db#(uvm_object_wrapper)::set(this,
                                              "seqr.configure_phase",
                                              "default_sequence",
                                              my_sequence::get_type());

   endfunction : build_phase

   virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);

      if (ctchr.seen != 1)
        `uvm_error("ERR_X",
                   "Didn't see the error we expected!")
      else
        $display("*** UVM TEST PASSED ***");
      
   endfunction : report_phase

endclass // test

   initial begin
      run_test();
   end

endmodule // test_mod
