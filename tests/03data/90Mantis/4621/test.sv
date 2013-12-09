//----------------------------------------------------------------------
//   Copyright 2013 Cadence Design Inc
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
module test;
	import uvm_pkg::*;

initial begin
		uvm_bitstream_t x;
		string y;
		x = 16'b10xz_10zx_10xz_10zx;
		y=uvm_bitstream_to_string(x,$bits(x),UVM_BIN);
		assert(y== "10xz10zx10xz10zx") else uvm_report_error("TEST",{"bits changed result is ",y});
		$display("str=[%s]val=[%0b]",y,x);
		
		y=uvm_integral_to_string(x,$bits(x),UVM_BIN);
		assert(y== "10xz10zx10xz10zx") else uvm_report_error("TEST",{"bits changed result is ",y});
		$display("str=[%s]val=[%0b]",y,x);
		
//		$display(uvm_vector_to_string('hdeadbeef,16,UVM_HEX));
		
		begin
			uvm_report_server svr;
			svr = uvm_report_server::get_server();

			if (svr.get_severity_count(UVM_ERROR)==0)
				$write("** UVM TEST PASSED **\n");
			else
				$write("!! UVM TEST FAILED !!\n");

			svr.report_summarize();

		end 
	end
endmodule

