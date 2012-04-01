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

  uvm_object objs[$];
  uvm_objection foo_objection = new();

  class myseq extends uvm_sequence;
    function new(string name="myseq");
      super.new(name);
    endfunction
    task body;
      uvm_domain _common_domain = uvm_domain::get_common_domain();
      uvm_phase run_phase = _common_domain.find_by_name("run");
      run_phase.raise_objection(this);
      #10 run_phase.drop_objection(this);
    endtask
  endclass

  class test extends uvm_component;
    myseq ms;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task run;
      for(int i=0; i<100; ++i) begin
        ms=new($sformatf("ms_%0d",i));
        ms.body(); 
      end
    endtask
    `uvm_component_utils(test)

    function void report_phase(uvm_phase phase);
      uvm_domain _common_domain = uvm_domain::get_common_domain();
      uvm_phase run_phase = _common_domain.find_by_name("run");
      uvm_objection run_phase_objection = run_phase.get_objection();
      run_phase_objection.get_objectors(objs);
      foreach(objs[i]) $display(": objector: %s", objs[i].get_full_name());
      if(objs.size() == 0 && $time == 1000) $display("*** UVM TEST PASSED ***");
      else $display("*** UVM TEST FAILED ***");
    endfunction
  endclass

  initial begin
    run_test();
  end

endmodule

