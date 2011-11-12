//
//------------------------------------------------------------------------------
//   Copyright 2011 (Synopsys)
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

// Test: mantis : 3476
// Purpose: To test the Mantis Fix.

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class cb_base extends uvm_event_callback;
    static int count;
    function new(string name=""); 
      super.new(name); 
      count=0;
    endfunction
    virtual function bit pre_trigger (uvm_event e, uvm_object data=null);
       `uvm_info("pre_trigger", $sformatf("Callback Count::%0d",count), UVM_NONE)
	count++;
    endfunction
  endclass

  class ip_comp extends uvm_component;
    uvm_event ev;
    cb_base cb[10];
    `uvm_component_utils(ip_comp)
    function new(string name,uvm_component parent);
      super.new(name,parent);
      ev = new("ev");
      for(int i = 0; i < 10; i++) cb[i] = new("cb");
    endfunction
    task run;
        foreach(cb[i]) ev.add_callback(cb[i]);
    endtask
  endclass

  class test extends uvm_component;
    ip_comp comp;
    uvm_event new_ev;
    cb_base cbb[15];
    `uvm_component_utils(test)
    function new(string name,uvm_component parent);
      super.new(name,parent);
      comp = new("comp",this);
      new_ev = new("new_ev");
      foreach(cbb[i]) cbb[i] = new("cbb");
    endfunction

    task run;
        for(int i =0; i < 15; i++) new_ev.add_callback(cbb[i]);
    endtask

    function void report();
	comp.ev.print();
	new_ev.copy(comp.ev);
	new_ev.print();
	new_ev.trigger();
 	
	if(cb_base::count==10)
		$display("UVM TEST PASSED");
	else
		$display("UVM TEST FAILED");
    endfunction
  endclass

  initial begin
    run_test();
  end
  
endmodule
