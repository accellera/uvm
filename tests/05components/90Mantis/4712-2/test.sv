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
package test289p;
	import uvm_pkg::*;
	// a quick and dirty UVC (parameterized)
		class transaction extends uvm_sequence_item;
			`uvm_object_param_utils(transaction)
			//T key;

			function new(string name = "transaction");
				super.new(name);
			endfunction
		endclass

		class transaction_sequence extends uvm_sequence#(transaction);
			`uvm_object_param_utils(transaction_sequence)

			function new(string name = "transaction_sequence");
				super.new(name);
			endfunction

			virtual task body();
				uvm_phase phase;
				phase = get_starting_phase();
				phase.raise_objection(this);
				repeat(10) `uvm_do(req)
				phase.drop_objection(this);
			endtask
		endclass

		class driver extends uvm_driver#(transaction);
			`uvm_component_param_utils(driver)

			function new (string name, uvm_component parent);
				super.new(name, parent);
			endfunction

			virtual task run_phase(uvm_phase phase);
				forever begin
					seq_item_port.get_next_item(req);
					#10 `uvm_info("DRV","sending item",UVM_NONE)
					seq_item_port.item_done();
				end
			endtask
		endclass

	class UVC#(type T=uvm_object) extends uvm_component;
		`uvm_component_param_utils(UVC#(T))

		function new (string name, uvm_component parent);
			super.new(name, parent);
		endfunction

		uvm_sequencer#(transaction) sqr;
		driver drv;

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sqr = uvm_sequencer#(transaction)::type_id::create("sqr",this);
			drv = driver::type_id::create("drv",this);
		endfunction

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			drv.seq_item_port.connect(sqr.seq_item_export);
		endfunction 

		function void end_of_elaboration_phase(uvm_phase phase);
			super.end_of_elaboration_phase(phase);
		endfunction 

		function void report_phase(uvm_phase phase);
			super.report_phase(phase);
		endfunction 
	endclass
endpackage

module test289;
	import uvm_pkg::*;
	import test289p::*;

	class my_visitor extends uvm_visitor#(uvm_component);
		string q[$];
		virtual function void visit(NODE node);
			q.push_back(node.get_name());
		endfunction 
		function new (string name = "");
			super.new(name);
		endfunction 

		virtual function void begin_v(); 
			q.push_back("begin_v");
		endfunction
		virtual function void end_v(); 
			q.push_back("end_v");      
		endfunction
	endclass

	class test extends uvm_test;
		`uvm_component_utils(test)
		function new (string name, uvm_component parent);
			super.new(name, parent);
		endfunction     

		function void report_phase(uvm_phase phase);
			uvm_coreservice_t cs_;
			cs_ = uvm_coreservice_t::get();

			super.report_phase(phase);
			begin
				uvm_component_proxy p = new("p");
				my_visitor v = new("v");
				uvm_bottom_up_visitor_adapter#(uvm_component,my_visitor) a1 = new("a1");
				uvm_top_down_visitor_adapter#(uvm_component,my_visitor) a2 = new("a2");
				uvm_by_level_visitor_adapter#(uvm_component,my_visitor) a3 = new("a3");
				a1.accept(uvm_root::get(),v,p);
				a2.accept(uvm_root::get(),v,p);
				a3.accept(uvm_root::get(),v,p);

				$display("GOLD-FILE-START");
				foreach(v.q[idx])
					$display(v.q[idx]);
				$display("GOLD-FILE-END");
			end

			begin
				uvm_root top = cs_.get_root();
				uvm_report_server svr = top.get_report_server();

				if (svr.get_severity_count(UVM_FATAL) +
						svr.get_severity_count(UVM_ERROR) == 0)
					$write("** UVM TEST PASSED **\n");
				else
					$write("** UVM TEST FAILED **\n");
			end 
		endfunction 
	endclass

	initial begin
		UVC#(int) hi_uvc;

		hi_uvc  = new("HI",null);

		uvm_config_wrapper::set(null,"HI.sqr.run_phase","default_sequence",test289p::transaction_sequence::get_type());

		run_test();

	end 
endmodule
