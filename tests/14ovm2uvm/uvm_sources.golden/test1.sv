`uvm_info("bla","text",UVM_MEDIUM);
`uvm_fatal("foo","text");

class bla extends uvm_sequence_item;


function new(a,b,c);

super.new( a ); // NOTE: [super.new( a , f ,h);]

endfunction


 function foo;
	#1 global_stop_request();
 endfunction
endclass

class bla2 extends uvm_sequence_item;


function new(a,b,c);

super.new( a ); // NOTE: [super.new( a , f2 ,h);]

endfunction

endclass

`include "uvm.svh"

`include "uvm_macros.svh"
`include "uvm_foo.svh" // XX-REVIEW-XX FIXME include of uvm file other than uvm_macros.svh detected, you should move to an import based methodology

factory.print()

uvm_pkg::uvm_top.set_report_verbosity_level_hier(UVM_DEBUG-1)

uvm_urm_report_server::set_global_debug_style(style); // XX-REVIEW-XX FIXME potential deprecated URM reference



	uvm_top.enable_print_topology = 1; // XX-REVIEW-XX NOTE mapped from something.uvm_enable_print_topology = 1; 

	uvm_top.enable_print_topology = 1;	 // XX-REVIEW-XX NOTE mapped from uvm_enable_print_topology = 1;	 


class bla extends uvm_report_object;
endclass

class phu extends configure_ph; // XX-REVIEW-XX FIXME potential usage of configure_ph, this should be mapped to end_of_elaboration_ph

endclass

// swap a and b for uvm
foo.raise_objection(devthis,b,a); 
 // should be devthis,,54
foo.raise_objection(devthis,,54);
// no change
foo.raise_objection(this); 
// this,,4
foo.raise_objection(this,,4);
 // this,,4 
foo.raise_objection(this,,4);

class bla extends uvm_sequence_item;
 
    function new(string name="yapp_packet");
     super.new(name);
     setPacketLength();
     `ifdef DATA_ITEM_DEBUG
       $display("DATA_ITEM_DEBUG: yapp_packet allocated @addr %0d : time=%0g",this,$time);
     `endif
   endfunction : new

   function void build();
   endfunction

   function void start_of_simulation();
   endfunction

   function void import_connections(); // XX-REVIEW-XX NOTE import _connections has been deprecated and should be mapped into connect()
   endfunction
 
   function void export_connections(); // XX-REVIEW-XX NOTE export _connections has been deprecated and should be mapped into connect()
   endfunction


endclass


// this should be now in global space
global_stop_request();


          `uvm_info("FIXME",$sformatf("%s to existing address...Updating address : %0h with data : %0h", 
            trans.read_write.name(), trans.addr + i, data),UVM_LOW);

          `uvm_error("DUT",
            ($sformatf("Read data mismatch.  Expected : %0h. Actual : %0h", exp, data)));

        `uvm_info("FIXME",$sformatf("%s to empty address...Updating address : %0h with data : %0h", 
          trans.read_write.name(), trans.addr + i, data),UVM_LOW);

      `uvm_info("FIXME",$sformatf("Reporting scoreboard information...\n%s", this.sprint(),UVM_LOW));


  task put (T p);
    lock.get();
    count++;
//    void'(accept_tr(p));
    accept_tr(p);
    #10;
    void'(begin_tr(p));
    #30; 
    end_tr(p); 
    `uvm_info("consumer", $sformatf("Received %0s local_count=%0d",p.get_name(),count), UVM_MEDIUM)
    if (uvm_report_enabled(UVM_HIGH))
      p.print();
    lock.put();
  endtask 


factory.set_type_override_by_name("some","other");
factory.set_type_override_by_name("some","other");
factory.set_type_override_by_type(some,other);
