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

`ifdef UVM_USE_P_FORMAT
`define DO_CMP(STYLE,OP,OP1,OP2) \
    for (int i=0; i< `NUM_TRANS; i++) \
      if(!OP1.OP(OP2)) \
        `uvm_fatal("MISCOMPARE",$sformatf("op1=%p op2=%p",OP1,OP2)) \
        
`else
`define DO_CMP(STYLE,OP,OP1,OP2) \
    for (int i=0; i< `NUM_TRANS; i++) \
      if(!OP1.OP(OP2)) \
        `uvm_fatal("MISCOMPARE",$sformatf("MISCOMPARE! op1=%s op2=%s",OP1.convert2string(),OP2.convert2string())) \

`endif        
        

`define DO_IT(STYLE,OP,OP1,OP2) \
    for (int i=0; i< `NUM_TRANS; i++) \
      OP1.OP(OP2); \

`define DO_PRT(STYLE,OP,OP1,OP2) \
    for (int i=0; i< `NUM_TRANS; i++) \
      void'(OP1.sprint(OP2)); \

initial run_test();
   
class test extends uvm_test;
   bit pass = 1;
   `uvm_component_utils(test)
   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   task run_phase(uvm_phase phase);
      uvm_tlm_gp  obj1=new,obj2=new;

    phase.raise_objection(this);

    uvm_default_packer.use_metadata = 1;
    uvm_default_packer.big_endian = 0;

    uvm_top.set_report_id_action("ILLEGALNAME",UVM_NO_ACTION);

    //obj1.enable_recording("obj1");

    $display("\NUM_TRANS=%0d",`NUM_TRANS);

     assert( obj1.randomize() with { 
          m_address >= 0 && m_address < 256; 
          m_length == `NUM_TRANS; 
          m_data.size == m_length;
          m_byte_enable_length <= m_length;
          (m_byte_enable_length % 4) == 0;
          m_byte_enable.size == m_byte_enable_length;
          m_streaming_width == m_length; 
          m_response_status == UVM_TLM_INCOMPLETE_RESPONSE;
				     } );

    obj1.print();
   assert( obj2.randomize() with { 
          m_address != obj1.m_address; 
          m_length == obj1.m_length-1; //ensure different sizes
          m_data.size == m_length;
          m_byte_enable_length <= m_length;
          (m_byte_enable_length % 4) == 0;
          m_byte_enable.size == m_byte_enable_length;
          m_streaming_width == m_length; 
          m_response_status == UVM_TLM_INCOMPLETE_RESPONSE;
				     } );
        obj2.print();


    //---------------------------------
    // COPY
    //---------------------------------

    `DO_IT("COPY: ",copy,obj2,obj1);

    //---------------------------------
    // COMPARE
    //---------------------------------

    `DO_CMP("COMPARE: ",compare,obj1,obj2);

    $display("obj1:",obj1.convert2string());
    $display("obj2:",obj2.convert2string());

    //---------------------------------
    // PACK/UNPACK
    //---------------------------------

    begin : pack
    bit bits[];
    
    for (int i=0; i< `NUM_TRANS; i++) begin
      void'(obj1.pack(bits));
      void'(obj2.unpack(bits));
      if (!obj1.compare(obj2)) begin
                 `uvm_error("TEST", "MISCOMPARE");
        obj1.print();
        obj2.print();
      end
    end
    
    end : pack
     


    //---------------------------------
    // RECORD
    //---------------------------------

    begin :record
    for (int i=0; i< `NUM_TRANS; i++) begin
      void'(obj1.begin_tr());
      #10;
      obj1.m_data[i] = i;
      obj1.end_tr();
    end

    
    end : record

    //---------------------------------
    // PRINT/SPRINT
    //---------------------------------

    begin
    int NUM = `NUM_TRANS/5;
    if (NUM==0) NUM=1;

    `DO_PRT("obj1: ",compare,obj1,uvm_default_table_printer);

    `DO_PRT("obj1: ",compare,obj1,uvm_default_tree_printer);

    `DO_PRT("obj1: ",compare,obj1,uvm_default_line_printer);

    end

//    $display("*** UVM TEST PASSED ***");
    phase.drop_objection(this);

endtask // run_phase
   
   virtual function void report_phase(uvm_phase phase);
      uvm_report_server svr = uvm_report_server::get_server();
      if (svr.get_severity_count(UVM_ERROR) > 0) pass = 0;
       $write("** UVM TEST %sED **\n", (pass) ? "PASS" : "FAIL");
endfunction
endclass
endmodule
