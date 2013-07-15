module test4671;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	class a extends uvm_object; 
		`uvm_object_utils(a)
		function new(string name="");
			super.new(name);
		endfunction
	endclass
	class b extends uvm_object; 
		a a1,a2;

		`uvm_object_utils_begin(b)
		`uvm_field_object(a1,UVM_DEFAULT)
		`uvm_field_object(a1,UVM_DEFAULT)
		`uvm_field_utils_end

		function new(string name="");
			super.new(name);
		endfunction

	endclass

	initial begin
				b myb1;
				
		b myb;
		a mya;

		myb=new;
		mya=new;
		
		myb.a1=mya; myb.a2=mya;

		$cast(myb1,myb.clone());

// question: is it the expectation that during a copy/clone identities are preserved? if so then the myb1.a2 should point to the copy of myb.a1 (also stored in myb1.a1)

		assert(myb.a1==myb.a2) else `uvm_error("TEST","SRC identity failed") // this should pass
		assert(myb1.a1==myb1.a2) else `uvm_error("TEST","TARGET identity failed") // this fails today
		
		begin
			uvm_report_server svr;
			svr=uvm_report_server::get_server();
			
			$display("UVM TEST PASSED");
			svr.summarize();
		end	
	end
endmodule

