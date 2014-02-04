module test294;
	import uvm_pkg::*;
    `include "uvm_macros.svh"

	class m extends uvm_component;
		`uvm_component_utils(m)
		function new(string name,uvm_component parent);
			super.new(name,parent);
		endfunction

	endclass
	class test extends uvm_component;
		`uvm_component_utils(test)
		function new(string name,uvm_component parent);
			super.new(name,parent);
		endfunction
		function void report_phase(uvm_phase phase);
			uvm_coreservice_t cs_;
			uvm_root top;
			uvm_report_server svr;
			cs_ = uvm_coreservice_t::get();
			top = cs_.get_root();
			svr = top.get_report_server();
			
			if (svr.get_id_count("UVM/COMP/NAME")!=6)
				$write("** UVM TEST FAILED **\n");
				
			if (svr.get_severity_count(UVM_FATAL) +
					svr.get_severity_count(UVM_ERROR) == 0)
				$write("** UVM TEST PASSED **\n");
			else
				$write("** UVM TEST FAILED **\n");
		endfunction
	endclass

	initial begin
		m m1,m2,m3,m4,m5;
		uvm_root r;

		m1 = new("a component instance with a space",null);
		m2 = new("{}....,,,,",null);
		m3 = new("..",null);
		m4 = new(".",m3);
		m5 = new("....",null);
		r = uvm_root::get();
		$display(m3.get_full_name());
		$display(m4.get_full_name());
		$display(m5.get_full_name());

		begin
			m n;
			string names[$];    
			names ='{"normal",
				"a-legal-name",
				" leading",
				"trailing ",
				"embedded whitespace",
				"special-:{ chars{}[0123456789] _"
			};
			foreach(names[idx])
				n=new(names[idx],m5);
		end

		r.print_topology();

		run_test();

	end

endmodule // test294
