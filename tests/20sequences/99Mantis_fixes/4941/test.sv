`include "uvm_macros.svh"
package test289p;
	import uvm_pkg::*;
	// a quick and dirty UVC (parameterized)
	class UVC#(type T=uvm_object) extends uvm_component;
		`uvm_component_param_utils(UVC#(T))

		class transaction extends uvm_sequence_item;
			`uvm_object_param_utils(transaction)
			T key;

			function new(string name = "transaction");
				super.new(name);
			endfunction
		endclass
		
		class transaction_sub_sequence extends uvm_sequence#(transaction);
			`uvm_object_param_utils(transaction_sub_sequence)
			 uvm_sequencer#(transaction) sqr;
			
			function new(string name = "transaction_sub_sequence");
				super.new(name);
			endfunction

			virtual task body();
				repeat(10) begin
					`uvm_do_on(req,sqr)
				end
			endtask
		endclass

		class transaction_sequence extends uvm_sequence#(transaction);
			local transaction_sub_sequence sub;
			 uvm_sequencer#(transaction) sqr;
			`uvm_object_param_utils(transaction_sequence)

			function new(string name = "transaction_sequence");
				super.new(name);
			endfunction

			virtual task body();
				repeat(5) begin
					`uvm_info("FOO","new iteration",UVM_NONE)
					sub = new();
					sub.sqr=sqr;
					sub.start(null);
					#10
					sub.start(null);
				end
			endtask
		endclass

		class driver extends uvm_driver#(transaction);
			`uvm_component_param_utils(driver)

			function new (string name, uvm_component parent);
				super.new(name, parent);
			endfunction

			virtual task run_phase(uvm_phase phase);
				forever begin
					`uvm_info("DRV","sending item",UVM_NONE)
					seq_item_port.get_next_item(req);
					#10;
					$display("data:%p",req.key);
					seq_item_port.item_done();
					`uvm_info("DRV","sending item complete",UVM_NONE)
					#5;
				end
			endtask
		endclass

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
		
		task run_phase(uvm_phase phase);
				phase.raise_objection(this);
		
				super.run_phase(phase);
				fork begin
					transaction_sequence s=new();
					s.sqr=sqr;
					s.start(sqr);
				end join_none
				
				#851;
				`uvm_info("TAST","stopping now",UVM_NONE)
				sqr.stop_sequences();
				`uvm_info("TAST","stopping done",UVM_NONE)

				phase.drop_objection(this);

		endtask

		virtual function void report_phase(uvm_phase phase);
			`uvm_info("TEST","UVM TEST PASSED",UVM_NONE)
		endfunction
		
	endclass

	class test extends uvm_test;
		`uvm_component_utils(test)
		function new(string name,uvm_component parent);
			super.new(name,parent);
		endfunction
	endclass
endpackage

module test289;
	import uvm_pkg::*;
	import test289p::*;

	UVC#(int) hi_uvc0 = new("HI0",null);

	initial begin
		
//		uvm_config_wrapper::set(null,"HI.sqr.run_phase","default_sequence",UVC#(int)::transaction_sequence::get_type());

		run_test("");

	end 
endmodule
