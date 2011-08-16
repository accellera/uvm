//---------------------------------------------------------------------- 
//   Copyright 2011 Cadence Design
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


module top2;
	import uvm_pkg::*;

`include "uvm_macros.svh"

class mtest extends uvm_component;
   `uvm_component_utils(mtest)
   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction
endclass
	
class test extends uvm_test;

   `uvm_component_utils(test)

   mtest c = new ("some-cntxt-post",this);

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void report();
	string f;
	int r;
	r=c.get_config_string("some.field",f);
	$display(r,":",f);
	if(f=="config" && r==1)	
	        $display("** UVM TEST PASSED **\n");
	else
		$display("** UVM TEST FAILED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endmodule
