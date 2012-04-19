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

   function void filter(ref string s1, ref string s2);
     int i;
     string tmp;
     tmp = s1.substr(i,i+6);
     while (tmp != "address") begin
       i++;
       tmp = s1.substr(i,i+6);
     end
     s1 = s1.substr(i,s1.len()-1);
     s2 = s2.substr(i,s2.len()-1);
   endfunction

   task run_phase(uvm_phase phase);
     uvm_tlm_gp  obj1=new("obj1"),obj2=new("obj2");
     bit bits[];
    
     phase.raise_objection(this);

     uvm_default_packer.use_metadata = 1;
     uvm_default_packer.big_endian = 0;

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

     void'(obj1.pack(bits));
     void'(obj2.unpack(bits));
     if (!obj1.compare(obj2)) begin
                  `uvm_error("TEST", "MISCOMPARE");
       obj1.print();
       obj2.print();
     end
    
     //---------------------------------
     // RECORD
     //---------------------------------

     void'(obj1.begin_tr());
     #10;
     obj1.m_data[i] = i;
     obj1.end_tr();


   end // for (..NUM_TRANS..)

   phase.drop_objection(this);

endtask // run_phase
   
virtual function void report_phase(uvm_phase phase);
   uvm_report_server svr = uvm_report_server::get_server();
   if (svr.get_severity_count(UVM_ERROR) > 0) pass = 0;
     $write("** UVM TEST %sED **\n", (pass) ? "PASS" : "FAIL");
endfunction

endclass

endmodule
