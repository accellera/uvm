//
//------------------------------------------------------------------------------
//   Copyright 2014 NVIDIA Corporation
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

// This test checks the behavior of uvm_objection when the
// propagation mode is disabled.

// We're utilizing the run-time phases (and their post versions) to
// enable/disable and raise/drop the objections.

module top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  uvm_objection foo = new("foo");
  class lower_comp extends uvm_component;
     
    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction // new
        
  endclass
  class middle_comp extends uvm_component;
    lower_comp lc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      lc = new("lc", this);
    endfunction
  endclass
  class top_comp extends uvm_component;
    middle_comp mc;
    function new(string name, uvm_component parent);
      super.new(name,parent);
      mc = new("mc", this);
    endfunction
  endclass
  class test extends uvm_component;
    top_comp tc;
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      tc = new("tc", this);
    endfunction

     task run_phase(uvm_phase phase);
        uvm_objection test_objection = new("test_objection");
        phase.raise_objection(this, "test");
        
        // Prop mode on (default)
        test_objection.raise_objection(this.tc.mc.lc, "raise lc");
        test_objection.raise_objection(this.tc, "raise tc");
        test_objection.raise_objection(uvm_root::get(), "raise root");

        if (test_objection.get_objection_total(uvm_root::get()) != 3)
          `uvm_fatal("FAIL", "wrong total for root")
        if (test_objection.get_objection_count(uvm_root::get()) != 1)
          `uvm_fatal("FAIL", "wrong count for root")
        
        if (test_objection.get_objection_total(this) != 2)
          `uvm_fatal("FAIL", "wrong total for this")
        if (test_objection.get_objection_count(this) != 0)
          `uvm_fatal("FAIL", "wrong count for this")
        
        if (test_objection.get_objection_total(this.tc) != 2)
          `uvm_fatal("FAIL", "wrong total for tc")
        if (test_objection.get_objection_count(this.tc) != 1)
          `uvm_fatal("FAIL", "wrong count for tc")

        if (test_objection.get_objection_total(this.tc.mc) != 1)
          `uvm_fatal("FAIL", "wrong total for mc")
        if (test_objection.get_objection_count(this.tc.mc) != 0)
          `uvm_fatal("FAIL", "wrong count for mc")

        if (test_objection.get_objection_total(this.tc.mc.lc) != 1)
          `uvm_fatal("FAIL", "wrong total for lc")
        if (test_objection.get_objection_count(this.tc.mc.lc) != 1)
          `uvm_fatal("FAIL", "wrong count for lc")

        test_objection.drop_objection(this.tc.mc.lc, "drop lc");
        test_objection.drop_objection(this.tc, "drop tc");
        test_objection.drop_objection(uvm_root::get(), "drop root");

        #1; // Finish the drain

        // Turn off prop mode
        test_objection.set_propagate_mode(0);
        
        test_objection.raise_objection(this.tc.mc.lc, "raise lc");
        test_objection.raise_objection(this.tc, "raise tc");
        test_objection.raise_objection(uvm_root::get(), "raise root");

        if (test_objection.get_objection_total(uvm_root::get()) != 3)
          `uvm_fatal("FAIL", $sformatf("wrong non-prop total for root (%0d)",
                                       test_objection.get_objection_total(uvm_root::get()))
                     )
        if (test_objection.get_objection_count(uvm_root::get()) != 1)
          `uvm_fatal("FAIL", "wrong non-prop count for root")
        
        if (test_objection.get_objection_total(this) != 0)
          `uvm_fatal("FAIL", "wrong non-prop total for this")
        if (test_objection.get_objection_count(this) != 0)
          `uvm_fatal("FAIL", "wrong non-prop count for this")
        
        if (test_objection.get_objection_total(this.tc) != 1)
          `uvm_fatal("FAIL", "wrong non-prop total for tc")
        if (test_objection.get_objection_count(this.tc) != 1)
          `uvm_fatal("FAIL", "wrong non-prop count for tc")

        if (test_objection.get_objection_total(this.tc.mc) != 0)
          `uvm_fatal("FAIL", "wrong non-prop total for mc")
        if (test_objection.get_objection_count(this.tc.mc) != 0)
          `uvm_fatal("FAIL", "wrong non-prop count for mc")

        if (test_objection.get_objection_total(this.tc.mc.lc) != 1)
          `uvm_fatal("FAIL", "wrong non-prop total for lc")
        if (test_objection.get_objection_count(this.tc.mc.lc) != 1)
          `uvm_fatal("FAIL", "wrong non-prop count for lc")

        test_objection.drop_objection(this.tc.mc.lc, "drop lc");
        test_objection.drop_objection(this.tc, "drop tc");
        test_objection.drop_objection(uvm_root::get(), "drop root");

        `uvm_info("PASS", "** UVM TEST PASSED **", UVM_NONE)

        phase.drop_objection(this, "test");
        
     endtask // run_phase
     
  endclass

  initial run_test("test");

endmodule
