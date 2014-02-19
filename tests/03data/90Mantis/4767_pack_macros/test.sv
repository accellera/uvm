module test3; 
import uvm_pkg::*; 
`include "uvm_macros.svh" 
typedef enum {BIG,LITTLE} size_t; 
class packet extends uvm_object; 
   rand int value; 
   rand size_t size; 
   string str; 
   `uvm_object_utils(packet) 
   function new(string name="packet"); 
     super.new(name); 
   endfunction 
   virtual function void do_pack(uvm_packer packer); 
     super.do_pack(packer); 
     `uvm_pack_int(value) 
     `uvm_pack_enum(size) 
     `uvm_pack_string(str) 
   endfunction 
   virtual function void do_unpack(uvm_packer packer);
      super.do_unpack(packer); 
     `uvm_unpack_int(value) 
     `uvm_unpack_enum(size, size_t) 
     `uvm_unpack_string(str) 
   endfunction 
   virtual function void do_print(uvm_printer printer);
         super.do_print(printer); 
        `uvm_print_int(value,UVM_HEX) 
        `uvm_print_enum(size_t,size,"size",printer) 
        `uvm_print_string(str) 
endfunction 
endclass :packet 

class test extends uvm_test;
    `uvm_component_utils(test)
    function new(string name="test", uvm_component parent=null);
      super.new(name, parent); 
   endfunction 
   task run_phase(uvm_phase phase); 
     var packet packet_inst = new; 
     var bit list_of_bit[]; 
     var string n;
     var bit   fail;
      
     uvm_default_packer.use_metadata = 1; 
// uvm_default_packer.big_endian = 0; 
     packet_inst.str = "packetenfkdsfjgvsdjfgsejfg"; 
     n = packet_inst.str; 
     packet_inst.randomize();
     if (n!=packet_inst.str) begin
        fail = 1;
        `uvm_error("TEST","RAND touched name")
     end
      
     packet_inst.pack(list_of_bit); 

     if (n!=packet_inst.str) begin
        fail = 1;
        `uvm_error("TEST","PACK touched name")
     end

     packet_inst.print(); 
     packet_inst.randomize(); 
     packet_inst.unpack(list_of_bit); 
     if (n!=packet_inst.str) begin
        fail = 1;
        `uvm_error("TEST","UNPACK touched name")
     end

      packet_inst.print();

     if (!fail)
       `uvm_info("PASS", "*** UVM TEST PASSED ***", UVM_NONE)
   endtask 
endclass : test 

initial begin
 run_test();
 end 

endmodule
