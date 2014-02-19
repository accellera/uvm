module main;

`include "uvm_macros.svh"
import uvm_pkg::*;


`define uvm_compare_field_int(object1, object2, field_name) \
	temp_string = `"field_name`"; \
	if(object1.field_name != object2.field_name) \
		diff_string = {diff_string, $sformatf({temp_string," mismatch %h!=%h\n"},object1.field_name,object2.field_name)};

`define uvm_compare_field_array(object1, object2, field_name) \
	temp_string = `"field_name`"; \
	if(object1.field_name.size() != object2.field_name.size()) \
		diff_string = {diff_string, $sformatf({temp_string," size mismatch %d!=%d\n"},object1.field_name.size(),object2.field_name.size())}; \
	else \
		foreach(object1.field_name[i]) \
			if(object1.field_name[i] != object2.field_name[i]) \
				diff_string = {diff_string, $sformatf({temp_string,"[%d] mismatch %h!=%h\n"},i,object1.field_name[i],object2.field_name[i])};


class my_packet_class extends uvm_object;
		
	function new(string name="my_packet_class");
		super.new(name);
	endfunction
	
	rand byte unsigned data[];
	rand bit[88:0] large_one;
	
	`uvm_object_utils_begin(my_packet_class)
	`uvm_field_array_int(data, UVM_ALL_ON | UVM_NOPACK)
	`uvm_object_utils_end
	
	function void do_pack(uvm_packer packer);
		`uvm_pack_arrayN(data,8)
	endfunction
	
	function void do_unpack(uvm_packer packer);
		`uvm_unpack_arrayN(data,8)		
	endfunction
endclass


   function void report();
      uvm_coreservice_t cs_;
      uvm_report_server svr;
      cs_ = uvm_coreservice_t::get();
      svr = cs_.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
      
svr.report_summarize();
   endfunction

my_packet_class packet;
my_packet_class other_packet;
byte unsigned lob[];
string temp_string;
string diff_string;

initial begin
	// use meta data
	uvm_default_packer.use_metadata = 1;

	packet = my_packet_class::type_id::create("packet");
	other_packet = my_packet_class::type_id::create("other_packet");	
	assert(packet.randomize() with {packet.data.size() inside {[10:100]};});
	$display("packet is : \n %s",packet.sprint());
	void'(packet.pack_bytes(lob));

// preallocate QDA (use_metadata=0)
//	other_packet.data = new[packet.data.size()];
// or use meta_data

	void'(other_packet.unpack_bytes(lob));
//	$display("other_packet is : \n %s",other_packet.sprint());
	`uvm_compare_field_array(packet, other_packet, data)


	if(diff_string!="") begin
	      `uvm_error("UVM TEST FAILED", "We have mismatches1")
	end
	
	uvm_default_packer.use_metadata = 0;
	void'(packet.pack_bytes(lob));
	assert(other_packet.randomize() with {other_packet.data.size() inside {[10:100]};});
	other_packet.data = new[packet.data.size()];
	void'(other_packet.unpack_bytes(lob));
	`uvm_compare_field_array(packet, other_packet, data)

	if(diff_string!="") begin
	      `uvm_error("UVM TEST FAILED", "We have mismatches2")
	end

	report();
end

endmodule
