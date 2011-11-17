`include "uvm_macros.svh"

module test116;
    import uvm_pkg::*;

    class a extends uvm_object;
        int my_aa[int];
        int bla='h10;

        `uvm_object_utils_begin(a)
            `uvm_field_aa_int_int(my_aa,UVM_NOCOMPARE|UVM_DEC)
            `uvm_field_int(bla,UVM_DEC)
        `uvm_object_utils_end

        function new(string name="");
            super.new(name);
        endfunction 
    endclass

    class test extends uvm_test;
	int cnt=0;
	`uvm_component_utils(test)
        function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction	
    
    task run();
	int cnt;
        a mya,myb;
        myb=new();
	cnt=0;
        mya = a::type_id::create("foo");
                
        mya.bla=3;
        mya.my_aa[10]=5;
        

        mya.print();
        
        
        myb.copy(mya);
        
        // need to check if my_aa is in printout
        myb.print();
        
        // need to check if my_aa is set in target 
        assert(myb.my_aa.size()==1) else cnt++;
        assert(myb.my_aa[10]==5) else cnt++;

	if(cnt)
		uvm_report_error("TEST","AA  copy/print failed");
	else
		uvm_report_info("TEST","*** UVM TEST PASSED ***",UVM_NONE);
    endtask

    endclass    

	initial run_test();
endmodule
