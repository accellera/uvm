
`ifndef NUM_TRANS
`define NUM_TRANS 10
`endif


import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// MODULE TOP
//------------------------------------------------------------------------------

module top;

`include "item.sv"
`include "item_macro.sv"


`define DO_CMP(STYLE,OP,OP1,OP2) \
    for (int i=0; i< `NUM_TRANS; i++) \
      if(!OP1.OP(OP2)) \
        $display("MISCOMPARE! op1=%p op2=%p",OP1,OP2); \

`define DO_IT(STYLE,OP,OP1,OP2) \
    for (int i=0; i< `NUM_TRANS; i++) \
      OP1.OP(OP2); \

`define DO_PRT(STYLE,OP,OP1,OP2) \
    for (int i=0; i< `NUM_TRANS; i++) \
      void'(OP1.sprint(OP2)); \


  initial begin



    item       man1=new,man2=new;
    item_macro mac1=new,mac2=new;

    uvm_default_packer.use_metadata = 1;
    uvm_default_packer.big_endian = 0;

    uvm_top.set_report_id_action("ILLEGALNAME",UVM_NO_ACTION);

    //man1.enable_recording("man1");
    //mac1.enable_recording("mac1");

    $display("\NUM_TRANS=%0d",`NUM_TRANS);

    assert(man1.randomize());
    assert(mac1.randomize());

    $display("\nManual:");
    man1.print();
    $display("\nMacro:");
    mac1.print();

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

    //mac2.enum2  = man2.enum2;
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
    mac2.real32 = man2.real32;
    mac2.real64 = man2.real64;
    mac2.time64 = man2.time64;
    mac2.str    = man2.str;
    mac2.sa     = man2.sa;
    mac2.da     = man2.da;
    mac2.q      = man2.q;
    mac2.aa     = man2.aa;
    mac2.bits   = man2.bits;
    mac2.logics = man2.logics;

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

    //$display("man1:",man1.convert2string());
    //$display("man2:",man2.convert2string());

    //---------------------------------
    // PACK/UNPACK
    //---------------------------------

    begin
    bit bits[];
    
    for (int i=0; i< `NUM_TRANS; i++) begin
      void'(man1.pack(bits));
      void'(man2.unpack(bits));
      if (!man1.do_compare(man2,null)) begin
        $display("MISCOMPARE!");
        man1.print();
        man2.print();
      end
    end


    for (int i=0; i< `NUM_TRANS; i++) begin
      void'(mac1.pack(bits));
      void'(mac2.unpack(bits));
      if (!mac1.do_compare(mac2,null)) begin
        $display("MISCOMPARE!");
        mac1.print();
        mac2.print();
      end
    end
    end


    //---------------------------------
    // RECORD
    //---------------------------------

    begin
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
    int NUM = `NUM_TRANS/5;
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
