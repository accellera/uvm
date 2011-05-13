//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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
//------------------------------------------------------------------------------

`include "uvm_macros.svh"

package my_uvc;

   import uvm_pkg::*;

   
typedef enum bit {GOOD_PARITY, BAD_PARITY} parity_e;
   
class packet extends uvm_sequence_item;
    rand bit[31:0] data;
    rand parity_e parity_type;     
    
    `uvm_object_utils_begin(packet)
      `uvm_field_int(data,UVM_ALL_ON|UVM_DEC)
      `uvm_field_enum(parity_e, parity_type, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name="unnamed-packet");
      super.new(name);
    endfunction : new
endclass : packet

   
class my_uvc_sequencer extends uvm_sequencer #(packet);
    `uvm_sequencer_utils(my_uvc_sequencer)

    function new (string name, uvm_component parent);
      super.new(name, parent);
      `uvm_update_sequence_lib_and_item(packet)
    endfunction : new
endclass : my_uvc_sequencer

      
class my_uvc_driver extends uvm_driver #(packet);
    packet packet_array[] = new [1000];
    int i;
    int j;
    int k;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
     
    `uvm_component_utils(my_uvc_driver)
      
    

    task run();
      i = 0;
      
      while(1) begin
        #10;
        seq_item_port.get_next_item(req);
	uvm_report_info("DRIVER_ITEM", 
                        $sformatf("my_uvc_driver recieved item: \n%s", req.sprint(uvm_default_tree_printer)),
                        UVM_HIGH, `uvm_file, `uvm_line);
	#0;
        packet_array[i] = req;
        
        if ( i == 124 )
           begin

              for (  j = 0 ; j <= 124;j++)
                 begin
                    
                    $display("packet_array[%0d",j,"].data is %0d ",packet_array[j].data);
                    
                 end  

              // assert short_seq sequences were executed until kill() was executed 

              for ( j = 1 ; j <= 99;j = j+2)
                 begin
                    
                    $display("packet_array[%0d",j,"].data is %0d ",packet_array[j].data);
                    //assert(packet_array[j].data == 99); 
                 end  
              
              
              

              

              // assert long_seq sequences were executed before kill() was executed 
              // alongside with short_seq sequences 

              for ( j = 0 ; j <= 99;j = j+2)
                 begin
                    
                    $display("packet_array[%0d",j,"].data is %0d ",packet_array[j].data);
                    //assert(packet_array[j].data == 999); 
                 end

              // assert long_seq sequences were executed before kill() was executed 
              // without short_seq sequences 


              for ( j = 100 ; j <= 124;j++)
                 begin
                    
                    $display("packet_array[%0d",j,"].data is %0d ",packet_array[j].data);
                    //assert(packet_array[j].data == 999);
                    //assert(packet_array[j].data != 99); 
                 end
              

              
                 

           end 
        i = i + 1;
        seq_item_port.item_done();
      end
      
      
    endtask: run
endclass : my_uvc_driver
      

class short_packet_seq extends uvm_sequence;
     rand bit [7:0] data_in;
     bit [7:0] data_out;
     int i;
     packet req;
     int pass=0;
     
     
     function new(string name="short_packet_seq");
	super.new(name);
     endfunction // new

    `uvm_sequence_utils_begin(short_packet_seq, my_uvc_sequencer)
        `uvm_field_int(data_in, UVM_ALL_ON)
	`uvm_field_int(data_out, UVM_ALL_ON)
    `uvm_sequence_utils_end
      
    virtual task body();
       #10;
       for ( i = 1 ; i <= 100;i++)
          begin 
	     $display("short_packet_seq i = %0d",i);
             if ( i == 51 )
                begin
$display("!!!!! KILLING SHORT PACKET SEQ !!!!!");
                   pass=1;
                   kill();
                end
             else 
                begin 
                   uvm_report_info("SIMPLESEQ", $sformatf("short_packet_seq body()... data_in = %0d", data_in),UVM_HIGH, `uvm_file, `uvm_line);
                   `uvm_do_with(req,{data == 99;})
                   if(i>51) `uvm_fatal("KILLFAIL", "Kill failed on short_packet_seq, i>51")
                end
          end
    endtask
endclass : short_packet_seq

class long_packet_seq extends uvm_sequence;
     rand bit [31:0] data_in;
     bit [31:0] data_out;
     int i;
     int pass=0;
     packet req;
     
     
     function new(string name="long_packet_seq");
	super.new(name);
        //super.enable_stop_interrupt = 1;
     endfunction // new

    `uvm_sequence_utils_begin(long_packet_seq, my_uvc_sequencer)
        `uvm_field_int(data_in, UVM_ALL_ON)
	`uvm_field_int(data_out, UVM_ALL_ON)
    `uvm_sequence_utils_end
      
    virtual task body();
       #10;
       for ( i = 1 ; i <= 100;i++)
	 
         begin
	    $display("long_packet_seq i = %0d",i);
	    
             if ( i == 76 )
	       
                begin
                   
$display("!!!!! KILLING LONG PACKET SEQ !!!!!");
                   pass=1;
                   kill();
                end
             else  
                begin   
                   uvm_report_info("SIMPLESEQ", $sformatf("long_packet_seq body()... data_in = %0d", data_in),UVM_HIGH, `uvm_file, `uvm_line);
                   `uvm_do_with(req,{data == 999;})
                   if(i>76) `uvm_fatal("KILLFAIL", "Kill failed on short_packet_seq, i>51")
                end
          end
    endtask
endclass : long_packet_seq

class root_seq extends uvm_sequence #(packet);

   long_packet_seq lps;
   short_packet_seq sps;
   

     function new(string name="root_seq");
	super.new(name);
     endfunction 
     
    `uvm_sequence_utils(root_seq, my_uvc_sequencer)
      
   virtual task body();
      fork
	 `uvm_do(sps);
	 `uvm_do(lps);
      join    
      if(sps.pass && lps.pass)
        $display("** UVM TEST PASSED **\n");
      else
        $display("** UVM TEST FAILED **\n");
    endtask
endclass : root_seq
   

endpackage // simple
