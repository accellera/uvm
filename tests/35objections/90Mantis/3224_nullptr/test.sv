//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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

module top();

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  uvm_objection foo_objection = new();

  class test extends uvm_component;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
      foo_objection.raise_objection(this);
      #101;
      $display("Ending run");
      foo_objection.drop_objection(this);
    endtask
    `uvm_component_utils(test)
  endclass

  initial begin
    uvm_top.finish_on_completion = 0;
    run_test();
  end

  uvm_object objs[$];
  initial begin
    foo_objection.set_report_verbosity_level(UVM_FULL);
    #100;
    foo_objection.raise_objection();
    foo_objection.get_objectors(objs);
    if(objs.size() != 2) $display("*** UVM TEST FAILED ***");
    foreach(objs[i]) $display(": objector: %s", objs[i].get_full_name());
    foo_objection.drop_objection();
    $display("*** UVM TEST PASSED ***");
  end

endmodule

