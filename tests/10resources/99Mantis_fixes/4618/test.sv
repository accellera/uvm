//----------------------------------------------------------------------
//   Copyright 2013 Cadence Design Systems, Inc.
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

`include "uvm_macros.svh"

module top();
	import uvm_pkg::*;

	class test extends uvm_test;
		int my_complex_int;

		`uvm_component_utils_begin(test)
		`uvm_field_int(my_complex_int,UVM_ALL_ON)
		`uvm_component_utils_end
		`uvm_new_func

		function void build_phase(uvm_phase phase);  
			int i;
			uvm_config_int::set(this, "","/z?mycomplexint/",4);
			uvm_config_int::set(this, "","/mycomplexint/",1);
			uvm_config_int::set(this, "","mycomplexint",10);			
			uvm_config_int::set(this, "","/my*int/",2);
			uvm_config_int::set(this, "","/my_complex.*/",3);

			super.build_phase(phase);

			// check the settings
			// fail plain
			assert(uvm_config_int::get(this, "","mycomplexint",i)) else `uvm_error("TEST","LOOKUPFAIL")
			assert(i==10) else `uvm_error("TEST","LOOKUPVALUEFAIL")

				// since field names are plain (=no regex) we lookup this field 
			assert(uvm_config_int::get(this, "","/z?mycomplexint/",i)) else `uvm_error("TEST","LOOKUPFAIL")
			assert(i==4) else `uvm_error("TEST","LOOKUPVALUEFAIL")

		endfunction

		function void end_of_elaboration_phase(uvm_phase phase);
			uvm_top.print_topology();
		endfunction

		function void check_phase(uvm_phase phase);
			super.check_phase(phase);

			begin
				uvm_report_server svr;
				svr = uvm_report_server::get_server();

				if(svr.get_id_count("UVM/RSRC/NOREGEX") != 4)
					$write("*** UVM TEST FAILED ***");

				if (svr.get_id_count("TEST")==0 && svr.get_severity_count(UVM_ERROR)==0)
					$write("** UVM TEST PASSED **\n");
				else
					$write("!! UVM TEST FAILED !!\n");

				svr.report_summarize();
			end
		endfunction
	endclass

	initial begin
		uvm_component::print_config_matches=1;
		run_test("test");
	end

endmodule
