`include "uvm_macros.svh"

module test4160;
   import uvm_pkg::*;
   
class ac extends uvm_object;
   rand int a;
   string b;
   
   `uvm_object_utils_begin(ac)
     `uvm_field_int(a,UVM_DEFAULT)
     `uvm_field_string(b,UVM_DEFAULT)
   `uvm_object_utils_end
    function new(string name="");
	super.new(name);
    endfunction
endclass
   
class b extends uvm_comparer;
   function new();
      super.new();
      sev=UVM_FATAL;
      verbosity=UVM_NONE;
      show_max=-1;
   endfunction
endclass // b
   
 class catcher extends uvm_report_catcher;
    int   cnt=0;
     virtual function action_e catch();
        if(get_severity() == UVM_FATAL && get_id() == "MISCMP") begin 
	   cnt++;
	   set_severity(UVM_INFO);
	   return THROW;
	end
	if(get_severity() == UVM_INFO && get_id() == "MISCMP") begin 
	   cnt++;
	   return THROW;
	end
        return THROW;
     endfunction
  endclass

		   
initial begin
   static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

   ac mya,myb;
   b policy;
   catcher catch;

   catch = new;

   uvm_report_cb::add(null,catch);
		   
   mya=new();
   myb=new();
   policy=new();
   
   assert(mya.randomize());
   mya.b="bang";
   

   assert(mya.compare(myb,policy)==0);
   policy.verbosity=UVM_HIGH;
   policy.sev=UVM_INFO;
   assert(mya.compare(myb,policy)==0);   

   // 3 messages at FATAL->INFO (two diffs+status header)
   // 3(filtered) messages at UVM_INFO+UVM_HIGH (two diffs+status header)
   if(catch.cnt != 3)
     `uvm_fatal("TEST",$sformatf("test failed, caught %0d messages",catch.cnt))

  begin
      uvm_report_server svr;
      svr = cs_.get_report_server();

      svr.report_summarize();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   end
   
end   

endmodule // test4160
