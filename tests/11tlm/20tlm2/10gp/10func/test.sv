//----------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics Corporation
//   Copyright 2011 Synopsys, Inc.
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
//

`ifndef NUM_TRANS
`define NUM_TRANS 10
`endif


import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// MODULE TOP
//------------------------------------------------------------------------------

module top;


initial run_test();
   
class test extends uvm_test;
   bit pass = 1;
   `uvm_component_utils(test)
   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

 function void strip_id(ref string s);
        bit in_id=0;
        int i=0;
        bit p;
        while(i<s.len()) begin
            if(in_id && s[i] inside {["0":"9"]," "})
                if(p==0)
                    begin s[i]="X"; p=1; end
                else begin
                    s={s.substr(0,i-1),s.substr(i+1,s.len()-1)}; 
                    i--;
                end
            else
                in_id=0;
                    
            if(s[i]=="@") begin in_id=1; p=0; end
           
           i++;   
        end
    endfunction

   function void filter(ref string s1, ref string s2);
        strip_id(s1);
        strip_id(s2);
   endfunction

   task run_phase(uvm_phase phase);
     uvm_tlm_gp  obj1=new("obj1"),obj2=new("obj2");
     bit bits[];
     byte unsigned bytes[];
     int np, nu;
    
     phase.raise_objection(this);

     uvm_top.set_report_id_action("ILLEGALNAME",UVM_NO_ACTION);

     //obj1.enable_recording("obj1");

     $display("\NUM_TRANS=%0d",`NUM_TRANS);

     for (int i=0; i<`NUM_TRANS; i++) begin

       $display("*** TRANS %0d ***",i);

        assert( obj1.randomize() with { 
         m_address >= 0 && m_address < 256; 
         m_length == `NUM_TRANS; 
         m_data.size == m_length;
         m_byte_enable_length <= m_length;
         (m_byte_enable_length % 4) == 0;
         m_byte_enable.size == m_byte_enable_length;
         foreach (m_byte_enable[i])
           m_byte_enable[i] inside { 0, 255 };
         m_streaming_width == m_length; 
				     } );
       assert( obj2.randomize() with { 
         m_address != obj1.m_address; 
         m_length == obj1.m_length-1; //ensure different sizes
         m_data.size == m_length;
         m_byte_enable_length <= m_length;
         (m_byte_enable_length % 4) == 0;
         m_byte_enable.size == m_byte_enable_length;
         foreach (m_byte_enable[i])
           m_byte_enable[i] inside { 0, 255 };
         m_streaming_width == m_length; 
			     } );

     //---------------------------------
     // COPY
     //---------------------------------

     obj2.copy(obj1);

     //---------------------------------
     // COMPARE
     //---------------------------------

     if(!obj1.compare(obj2))
       `uvm_fatal("MISCOMPARE",$sformatf("MISCOMPARE detected on generic payload!"));
        
     //---------------------------------
     // CONVERT2STRING
     //---------------------------------

     begin
     string s1,s2;

     s1 = obj1.convert2string();
     s2 = obj2.convert2string();
     if (s1 != s2)
       `uvm_fatal("MISCOMPARE",$sformatf("convert2string different!\nobj1=%s\nobj2=%s",s1,s2))
     end

     //---------------------------------
     // PRINT/SPRINT
     //---------------------------------

     begin
     string s1,s2;

     obj2.set_name(obj1.get_name());

     s1 = obj1.sprint(uvm_default_table_printer);
     s2 = obj2.sprint(uvm_default_table_printer);
     filter(s1,s2); 
     if (s1 != s2)
       `uvm_fatal("MISCOMPARE",{"Sprint table:\nobj1=\n",s1,"\nobj2=\n",s2})

     s1 = obj1.sprint(uvm_default_tree_printer);
     s2 = obj2.sprint(uvm_default_tree_printer);
     filter(s1,s2); 
     if (s1 != s2)
       `uvm_fatal("MISCOMPARE",{"Sprint tree:\nobj1=\n",s1,"\nobj2=\n",s2})

     s1 = obj1.sprint(uvm_default_line_printer);
     s2 = obj2.sprint(uvm_default_line_printer);
     filter(s1,s2); 
     if (s1 != s2)
       `uvm_fatal("MISCOMPARE",{"Sprint line:\nobj1=\n",s1,"\nobj2=\n",s2})

     end

     //---------------------------------
     // PACK/UNPACK
     //---------------------------------

     uvm_default_packer.use_metadata = 1;
     uvm_default_packer.big_endian   = i % 2;

     `uvm_info("TEST", $sformatf("Testing pack/unpack using %0s endian...",
                                 (uvm_default_packer.big_endian) ? "big" : "little"), UVM_NONE)

     obj2 = new("obj2");
     np = obj1.pack(bits);
     nu = obj2.unpack(bits);
     if (!obj1.compare(obj2)) begin
                  `uvm_error("TEST", "pack/unpack MISCOMPARE");
       obj1.print();
       obj2.print();
     end
     if (np != nu) begin
        `uvm_error("TEST", $sformatf("Packed %0d bits but unpacked %0d bits", np, nu))
     end
    
     obj2 = new("obj2");
     nu = obj1.pack_bytes(bytes);
     np = obj2.unpack_bytes(bytes);
     if (!obj1.compare(obj2)) begin
                  `uvm_error("TEST", "pack_bytes/unpack_bytes MISCOMPARE");
       obj1.print();
       obj2.print();
     end
     if (np != nu) begin
        `uvm_error("TEST", $sformatf("pack_bytes() packed %0d bits but unpacked %0d bits", np, nu))
     end
    
     //---------------------------------
     // RECORD
     //---------------------------------

     void'(obj1.begin_tr());
     #10;
     obj1.m_data[i] = i;
     obj1.end_tr();


   end // for (..NUM_TRANS..)


   // Check the actual byte stream of the packing operation
   `uvm_info("TEST", "Checking content of packed byte stream...", UVM_LOW)
      
   begin
      uvm_tlm_gp gp = new();
   
      bytes = '{'h00, 'h11, 'h22, 'h33, 'h44, 'h55, 'h66, 'h77,
                'h88, 'h99, 'hAA, 'hBB, 'hCC, 'hDD, 'hEE, 'hFF,
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae,
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae,
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae,
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 
                'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae, 'hae
               };
      
      gp.set_address(64'h0011_2233_4455_7788);
      gp.set_write();
      gp.set_data(bytes);
      gp.set_data_length(16);
      gp.set_streaming_width(1);
      gp.set_byte_enable(bytes); // TECHNICALLY, byte_enables elements should be 00 or FF, nothing else
      gp.set_byte_enable_length(16);
      gp.set_dmi_allowed(1);
      gp.set_response_status(UVM_TLM_BYTE_ENABLE_ERROR_RESPONSE);
      
      //$display("gp=%p",gp); // prints everything in gp
      //gp.print();   // does not print m_data buffer, only m_length entries
     

      uvm_default_packer.big_endian   = 0;
      gp.pack_bytes(bytes);

      $write("Little Endian...\n");
      foreach (bytes[i])
         $write(",%s'h%h", (i%8) ? " ": "\n", bytes[i]);
      $write("};\n");
      
      begin
         byte unsigned exp[60]
            = {'h88, 'h77, 'h55, 'h44, 'h33, 'h22, 'h11, 'h00,
               'h01, 'h00, 'h00, 'h00, 'h10, 'h00, 'h00, 'h00,
               'h00, 'h11, 'h22, 'h33, 'h44, 'h55, 'h66, 'h77,
               'h88, 'h99, 'haa, 'hbb, 'hcc, 'hdd, 'hee, 'hff,
                                       'hfb, 'hff, 'hff, 'hff,
               'h10, 'h00, 'h00, 'h00, 'h00, 'h11, 'h22, 'h33,
               'h44, 'h55, 'h66, 'h77, 'h88, 'h99, 'haa, 'hbb,
               'hcc, 'hdd, 'hee, 'hff, 
               'h01, 'h00, 'h00, 'h00};

         np = gp.pack_bytes(bytes);
         np = (np-1) / 8 + 1;
         if (np != $size(exp)) begin
            `uvm_error("TEST", $sformatf("GP packed into %0d bytes instead of %0d", np, $size(exp)))
         end
         if (np != bytes.size()) begin
            `uvm_error("TEST", $sformatf("GP said it packed %0d bytes instead of %0d", np, bytes.size()))
         end
         foreach (bytes[i]) begin
            if (i >= $size(exp)) break;
            if (bytes[i] != exp[i]) begin
               `uvm_error("TEST", $sformatf("GP byte #%0d is 'h%h instead of 'h%h", i,
                                            bytes[i], exp[i]))
            end
         end
      end

      uvm_default_packer.big_endian   = 1;
      gp.pack_bytes(bytes);

      $write("Big Endian...\n");
      foreach (bytes[i])
         $write(",%s'h%h", (i%8) ? " ": "\n", bytes[i]);
      $write("};\n");
      
      begin
         byte unsigned exp[60]
         = {'h00, 'h11, 'h22, 'h33, 'h44, 'h55, 'h77, 'h88,
            'h00, 'h00, 'h00, 'h01, 'h00, 'h00, 'h00, 'h10,
            'h00, 'h11, 'h22, 'h33, 'h44, 'h55, 'h66, 'h77,
            'h88, 'h99, 'haa, 'hbb, 'hcc, 'hdd, 'hee, 'hff,
                                    'hff, 'hff, 'hff, 'hfb,
            'h00, 'h00, 'h00, 'h10, 'h00, 'h11, 'h22, 'h33,
            'h44, 'h55, 'h66, 'h77, 'h88, 'h99, 'haa, 'hbb,
            'hcc, 'hdd, 'hee, 'hff, 
            'h00, 'h00, 'h00, 'h01};

         np = gp.pack_bytes(bytes);
         np = (np-1) / 8 + 1;
         if (np != $size(exp)) begin
            `uvm_error("TEST", $sformatf("GP packed into %0d bytes instead of %0d", np, $size(exp)))
         end
         if (np != bytes.size()) begin
            `uvm_error("TEST", $sformatf("GP said it packed %0d bytes instead of %0d", np, bytes.size()))
         end
         foreach (bytes[i]) begin
            if (i >= $size(exp)) break;
            if (bytes[i] != exp[i]) begin
               `uvm_error("TEST", $sformatf("GP byte #%0d is 'h%h instead of 'h%h", i,
                                            bytes[i], exp[i]))
            end
         end
      end
   end

   phase.drop_objection(this);

endtask // run_phase
   
virtual function void report_phase(uvm_phase phase);
   uvm_report_server svr = uvm_report_server::get_server();
   if (svr.get_severity_count(UVM_ERROR) > 0) pass = 0;
     $write("** UVM TEST %sED **\n", (pass) ? "PASS" : "FAIL");
endfunction

endclass

endmodule
