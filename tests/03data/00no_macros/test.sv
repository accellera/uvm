//---------------------------------------------------------------------- 
//   Copyright 2011 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc.
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
//----------------------------------------------------------------------

`ifndef NUM_TRANS
`define NUM_TRANS 1
`endif


import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// MODULE TOP
//------------------------------------------------------------------------------

module top;

`include "item.sv"
`include "item_macro.sv"

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


  initial begin
    item       man1,man2;
    item_macro mac1,mac2;

    man1=new("man1");man2=new("man2");
    mac1=new("mac1");mac2=new("mac2");

    uvm_top.set_report_id_action("ILLEGALNAME",UVM_NO_ACTION);

    $display("\NUM_TRANS=%0d",`NUM_TRANS);

    assert(man2.randomize());
    //assert(mac2.randomize());

    /*
    man2.sa[0] = 1;
    man2.sa[1] = 2;
    man2.sa[2] = 3;
    man2.da = new[3];
    man2.da[0] = 4;
    man2.da[1] = 5;
    man2.da[2] = 6;
    man2.q.push_back(7);
    man2.q.push_back(8);
    man2.q.push_back(9);
    man2.aa[1] = 2;
    man2.aa[3] = 4;
    man2.aa[5] = 6;
    man2.time64 = 40;
    man2.str="HELLO";
    man2.bits = 'b1010111;
    man2.logics = 'bxz01zx1;
    */

    case (man2.enum2)
      item::NOP: mac2.enum2 = item_macro::NOP;
      item::READ: mac2.enum2 = item_macro::READ;
      item::WRITE: mac2.enum2 = item_macro::WRITE;
    endcase
    mac2.int64  = man2.int64;
    mac2.int32  = man2.int32;
    mac2.int16  = man2.int16;
    mac2.int8   = man2.int8;
    mac2.int1   = man2.int1;
    mac2.uint64 = man2.uint64;
    mac2.uint32 = man2.uint32;
    mac2.uint16 = man2.uint16;
    mac2.uint8  = man2.uint8;
    mac2.uint1  = man2.uint1;
`ifndef INCA    
    mac2.real32 = man2.real32;
`endif    
    mac2.real64 = man2.real64;
    mac2.time64 = man2.time64;
    mac2.str    = man2.str;
    mac2.sa     = man2.sa;
    mac2.da     = man2.da;
    mac2.q      = man2.q;
    mac2.aa     = man2.aa;
    mac2.bits   = man2.bits;
    mac2.logics = man2.logics;

    $display("\nManual:");
    man2.print();
    $display("\nMacro:");
    mac2.print();

    //---------------------------------
    // COPY
    //---------------------------------

    `DO_IT("Manual: ",copy,man1,man2);
    `DO_IT("Macros: ",copy,mac1,mac2);

    //---------------------------------
    // COMPARE
    //---------------------------------

    `DO_CMP("Manual: ",compare,man1,man2);
    `DO_CMP("Macros: ",compare,mac1,mac2);

    $display("man1:",man1.convert2string());
    $display("man2:",mac1.convert2string());

    //---------------------------------
    // PACK/UNPACK
    //---------------------------------

    begin
    bit bits[];
    bit bits2[];
    byte unsigned bytes[];
    byte unsigned bytes2[];
    int unsigned ints[];
    int unsigned ints2[];

    uvm_default_packer.use_metadata = 1;

    uvm_default_packer.big_endian = 0;
    
      void'(man1.pack(bits));
      void'(man2.unpack(bits));
      if (!man1.compare(man2)) begin
        $display("MISCOMPARE!");
        man1.print();
        man2.print();
      end


      void'(mac1.pack(bits2));
      void'(mac2.unpack(bits2));
      if (!mac1.compare(mac2)) begin
        mac1.print();
        mac2.print();
        `uvm_fatal("MISCOMPARE","mismatch in pack/unpack")
        
      end

      if (bits != bits2) begin
        $display("\nSize bits=%0d\nSize bits2=%0d",bits.size(),bits2.size());
        foreach (bits[i]) begin
          if (bits[i] != bits2[i])
            $display("index %0d bits=%b bits2=%b",i,bits[i],bits2[i]);
        end
        `uvm_fatal("MACRO/NON-MACRO DIFF",$sformatf("packed bits via field macros not the same as packed bits via `uvm_pack_* macros big_endian=0"))

      end



    uvm_default_packer.big_endian = 1;
    
      void'(man1.pack(bits));
      void'(man2.unpack(bits));
      if (!man1.compare(man2)) begin
        $display("MISCOMPARE!");
        man1.print();
        man2.print();
      end


      void'(mac1.pack(bits2));
      void'(mac2.unpack(bits2));
      if (!mac1.compare(mac2)) begin
        mac1.print();
        mac2.print();
        `uvm_fatal("MISCOMPARE","mismatch in pack/unpack")
        
      end

      if (bits != bits2)
        `uvm_fatal("MACRO/NON-MACRO DIFF","packed bits via field macros not the same as packed bits via `uvm_pack_* macros big_endian=1")



    uvm_default_packer.big_endian = 0;
    
      void'(man1.pack_bytes(bytes));
      void'(man2.unpack_bytes(bytes));
      if (!man1.compare(man2)) begin
        $display("MISCOMPARE!");
        man1.print();
        man2.print();
      end


      void'(mac1.pack_bytes(bytes2));
      void'(mac2.unpack_bytes(bytes2));
      if (!mac1.compare(mac2)) begin
        mac1.print();
        mac2.print();
        `uvm_fatal("MISCOMPARE","mismatch in pack/unpack")
        
      end

      if (bytes != bytes2)
        `uvm_fatal("MACRO/NON-MACRO DIFF","packed bytes via field macros not the same as packed bytes via `uvm_pack_* macros big_endian=0")

    uvm_default_packer.big_endian = 1;
    
      void'(man1.pack_bytes(bytes));
      void'(man2.unpack_bytes(bytes));
      if (!man1.compare(man2)) begin
        $display("MISCOMPARE!");
        man1.print();
        man2.print();
      end


      void'(mac1.pack_bytes(bytes2));
      void'(mac2.unpack_bytes(bytes2));
      if (!mac1.compare(mac2)) begin
        mac1.print();
        mac2.print();
        `uvm_fatal("MISCOMPARE","mismatch in pack/unpack")
        
      end

      if (bytes != bytes2)
        `uvm_fatal("MACRO/NON-MACRO DIFF","packed bytes via field macros not the same as packed bytes via `uvm_pack_* macros big_endian=1")



    uvm_default_packer.big_endian = 0;
    
      void'(man1.pack_ints(ints));
      void'(man2.unpack_ints(ints));
      if (!man1.compare(man2)) begin
        $display("MISCOMPARE!");
        man1.print();
        man2.print();
      end


      void'(mac1.pack_ints(ints2));
      void'(mac2.unpack_ints(ints2));
      if (!mac1.compare(mac2)) begin
        mac1.print();
        mac2.print();
        `uvm_fatal("MISCOMPARE","mismatch in pack/unpack")
        
      end

      if (ints != ints2)
        `uvm_fatal("MACRO/NON-MACRO DIFF","packed ints via field macros not the same as packed ints via `uvm_pack_* macros big_endian=0")

    uvm_default_packer.big_endian = 1;
    
      void'(man1.pack_ints(ints));
      void'(man2.unpack_ints(ints));
      if (!man1.compare(man2)) begin
        $display("MISCOMPARE!");
        man1.print();
        man2.print();
      end


      void'(mac1.pack_ints(ints2));
      void'(mac2.unpack_ints(ints2));
      if (!mac1.compare(mac2)) begin
        mac1.print();
        mac2.print();
        `uvm_fatal("MISCOMPARE","mismatch in pack/unpack")
        
      end

      if (ints != ints2)
        `uvm_fatal("MACRO/NON-MACRO DIFF","packed ints via field macros not the same as packed ints via `uvm_pack_* macros big_endian=1")

    end



    //---------------------------------
    // RECORD
    //---------------------------------

    begin
    man1.enable_recording("man1");
    mac1.enable_recording("mac1");

    for (int i=0; i< `NUM_TRANS; i++) begin
      void'(man1.begin_tr());
      #10;
      man1.int32 = i;
      man1.end_tr();
    end

    for (int i=0; i< `NUM_TRANS; i++) begin
      void'(mac1.begin_tr());
      #10;
      mac1.int32 = i;
      mac1.end_tr();
    end
    end

    //---------------------------------
    // PRINT/SPRINT
    //---------------------------------

    begin
    int NUM;
    NUM = `NUM_TRANS/5;
    if (NUM==0) NUM=1;

    `DO_PRT("Manual: ",compare,man1,uvm_default_table_printer);
    `DO_PRT("Macros: ",compare,mac1,uvm_default_table_printer);

    `DO_PRT("Manual: ",compare,man1,uvm_default_tree_printer);
    `DO_PRT("Macros: ",compare,mac1,uvm_default_tree_printer);

    `DO_PRT("Manual: ",compare,man1,uvm_default_line_printer);
    `DO_PRT("Macros: ",compare,mac1,uvm_default_line_printer);

    end

    $display("*** UVM TEST PASSED ***");
    uvm_top.report_summarize();
  end

endmodule
