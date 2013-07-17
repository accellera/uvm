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

// this test by purpose does the following:
// 1. it sets up a graph (not a dag) of objects
// 2. the references are contained in a DA and two independent variables
// 3. while the network is randomly routed it does include "null" and refs to the top object
// 4. the objects in addition contain 2 layers of inheritance with fields of the same name (and eventually the same ref)
//
// then .copy/.clone is performed
// and the result is checked for value equality (via compare)
// and then for structural equivalence (by checking the refs in the tree)
//

module test;
	import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    parameter int TESTSET_SIZE=5;

	class blob0 extends uvm_object;
		rand blob0 b0,b1;
		`uvm_object_utils_begin(blob0)
		`uvm_field_object(b0,UVM_DEFAULT)
		`uvm_field_object(b1,UVM_DEFAULT)       
		`uvm_field_utils_end
		function new(string name="");
			super.new(name);
		endfunction
	endclass

	class blob extends blob0;
		typedef int int_a[$];
		typedef int int_aa[blob];

		rand blob b0,b1;
		rand blob arr[];
		`uvm_object_utils_begin(blob)
		`uvm_field_object(b0,UVM_DEFAULT)
		`uvm_field_object(b1,UVM_DEFAULT)       
		`uvm_field_array_object(arr,UVM_DEFAULT)
		`uvm_field_utils_end

		function new(string name="");
			super.new(name);
		endfunction

		// collect all refs
		function void idset(ref int_aa seen);
			blob q[$];
			q = arr;
			q.push_back(b0);
			q.push_back(b1);

			foreach(q[idx]) begin
				if(seen.exists(q[idx]))
					seen[q[idx]]++;
				else	
					seen[q[idx]]=1;	

				if(seen[q[idx]]==1)  
					if(q[idx]!=null)       
						q[idx].idset(seen);
			end
		endfunction

		// compare the refs statistics
		static function void compare_idset(int_aa left, int_aa right);
			int unsigned id0[$],id1[$];

			foreach(left[idx])
				id0.push_back(left[idx]);

			foreach(right[idx])
				id1.push_back(right[idx]);

			id0.sort();
			id1.sort();

			assert(id0.size() == id1.size()) else `uvm_error("TEST","structure different (number of unique refs differ)");   
			
			for(int i=0;i<id0.size();i++) begin
				assert(id0[i]==id1[i]) else `uvm_error("TEST",$sformatf("left %0d  right %0d",id0[i],id1[i]))
			end	

		endfunction 

		static function void compare_deep(blob orig, blob transformed);
			int_aa a0,a1;
			orig.idset(a0);
			transformed.idset(a1);
			`uvm_info("TEST-ORIG",orig.sprint(),UVM_NONE)
			`uvm_info("TEST-TRANS",transformed.sprint(),UVM_NONE)  
			compare_idset(a0,a1);
		endfunction 

		virtual function void setupb0(bit s[1:0],blob r);
			if(s[0])
				super.b0=r;
			if(s[1])
				b0=r;               
		endfunction
		virtual function void setupb1(bit s[1:0],blob r);
			if(s[0])
				super.b1=r;
			if(s[1])
				b1=r;               
		endfunction 
	endclass

	initial begin
		blob inst;
		blob clone;
		blob old_scratch;

		repeat(1) begin
			int unsigned y;
			bit rnd[1:0];

			blob x[];
			inst=new;
			
			x = new[TESTSET_SIZE+1];

			// create set of objects
			foreach(x[idx])
				x[idx]=new;
				
			x[0]=inst;
				

			begin   
				int idx0;
				// make some pointers 
				foreach(x[idx]) begin  
					blob b;
					b = x[idx];
					// make sub-set in object
					assert(std::randomize(y) with { y < x.size();}) else `uvm_error("TEST","rand fail")
						b.arr=new[y];
					foreach(b.arr[idx0]) begin                  
						assert(std::randomize(y) with { y <= x.size();}) else `uvm_error("TEST","rand fail")
							if(y==x.size())
								b.arr[idx0]=null;
							else    
								b.arr[idx0]=x[y];
					end 
					end

					foreach(x[idx]) begin   
						assert(std::randomize(rnd));
						assert(std::randomize(y) with { y < x.size();}) else `uvm_error("TEST","rand fail")
							x[idx].setupb0(rnd,x[y]);
						assert(std::randomize(y) with { y < x.size();}) else `uvm_error("TEST","rand fail")
							x[idx].setupb1(rnd,x[y]);
					end 
				end 
		
				$display($sformatf("%p",inst));
				$display(inst.sprint());

				// test clone() for value-equal and structure-equal
				assert($cast(clone,inst.clone()));
				assert(inst.compare(clone)) else `uvm_error("TEST","clone doesnt preserve value")
				blob::compare_deep(inst,clone);

				// test copy() for value-equal and structure-equal on new()d object
				clone=new;
				clone.copy(inst);
				assert(inst.compare(clone)) else `uvm_error("TEST","copy doesnt preserve value")
				blob::compare_deep(inst,clone);
				
				// test copy() for value-equal and structure-equal on existing object				
				old_scratch.copy(inst);
				assert(clone.compare(old_scratch)) else `uvm_error("TEST","copy doesnt preserve value (while copy() to existing obj)")
				blob::compare_deep(clone,old_scratch);
				
			end 
			begin
				uvm_report_server svr;
				svr=uvm_report_server::get_server();

				$display("UVM TEST PASSED");
				svr.summarize();
			end

		end
endmodule
