//---------------------------------------------------------------------- 
//   Copyright 2013 Cadence, Inc.
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
module test284;
	import uvm_pkg::*;
    `include "uvm_macros.svh"

	class sub extends uvm_object;
		rand int i;
		`uvm_object_utils_begin(sub)
		`uvm_field_int(i,UVM_DEFAULT)
		`uvm_object_utils_end

		function new(string name="");
			super.new(name);
		endfunction
	endclass

	class bla extends uvm_object;
		rand sub arr[];
		`uvm_object_utils_begin(bla)
		`uvm_field_array_object(arr,UVM_DEFAULT)
		`uvm_field_utils_end

		function new(string name="");
			super.new(name);
		endfunction
	endclass


	initial begin
		bla inst;
		bla clone;

		inst = new();
		inst.arr =new[4];
		foreach(inst.arr[idx])
			inst.arr[idx] = new();

		assert(inst.randomize());

		$display("testing clone with unique refs");  
		// clone and compare    
		assert($cast(clone,inst.clone()));
		assert(clone.compare(inst));
		$display($sformatf("%p %p",clone,inst));


		// now some inst.arrs[] point to the same object
		inst.arr[1]=inst.arr[2];    

		$display("testing clone with duplicated refs");  

		// clone and compare    
		assert($cast(clone,inst.clone())) else `uvm_error("TEST","cant clone")
		assert(clone.compare(inst)) else `uvm_error("TEST","cloned object fails (value) comparison")
		assert(clone.arr[1]==clone.arr[2]) else `uvm_error("TEST","clone() doesnt preserve object-object relations")

			$display($sformatf("clone=%p\nsrc=%p",clone,inst));

		$display(clone.arr[2].i," =?= ",inst.arr[2].i);
		$display("DONE");

		begin
			uvm_report_server svr;
			svr=uvm_report_server::get_server();

			$display("UVM TEST PASSED");
			svr.summarize();
		end

	end
endmodule
