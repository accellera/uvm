//---------------------------------------------------------------------- 
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

`define N 7

import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// MODULE TOP
//------------------------------------------------------------------------------

module top;
   
//------------------------------------------------------------------------------
//
// CLASS: item
//
//------------------------------------------------------------------------------

class item extends uvm_sequence_item;

  `uvm_object_utils(item)

  function new(string name="");
    super.new(name);
  endfunction

  typedef enum bit [1:0] { NOP, READ, WRITE } enum_t;
   
  bit                    pad[$];

  rand enum_t            enum2;

  rand longint           int64;
  rand int               int32;
  rand shortint          int16;
  rand byte              int8;
  rand bit               int1;

  rand longint unsigned  uint64;
  rand int unsigned      uint32;
  rand shortint unsigned uint16;
  rand byte unsigned     uint8;
  rand bit unsigned      uint1;

`ifndef INCA
       shortreal         real32;
`endif

       real              real64;

  rand time              time64;

       string            str;

  rand int               sa[3];
  rand shortint          da[];
  rand byte              q[$];
       shortint          aa[shortint];

  rand bit [`N-1:0]       bits;
  rand logic [`N-1:0]     logics;

  constraint C_q_size  { q.size  inside {[1:11]}; }
  constraint C_da_size { da.size inside {[1:11]}; }


  // do_copy
  //--------

  virtual function void do_copy(uvm_object rhs);
    item rhs_;

    if(!$cast(rhs_, rhs)) begin
      uvm_report_error("do_copy", "cast failed, check type compatability");
      return;
    end
    super.do_copy(rhs);

    enum2 = rhs_.enum2;

    int64 = rhs_.int64;
    int32 = rhs_.int32;
    int16 = rhs_.int16;
    int8  = rhs_.int8;
    int1  = rhs_.int1;

    uint64 = rhs_.uint64;
    uint32 = rhs_.uint32;
    uint16 = rhs_.uint16;
    uint8  = rhs_.uint8;
    uint1  = rhs_.uint1;

    time64 = rhs_.time64;
    str    = rhs_.str;

    q      = rhs_.q;
    sa     = rhs_.sa;
    da     = rhs_.da;
    aa     = rhs_.aa;

    real64 = rhs_.real64;
`ifndef INCA    
    real32 = rhs_.real32;
`endif

    bits   = rhs_.bits;
    logics = rhs_.logics;
  endfunction


  // do_compare
  // ----------

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    item rhs_;
    return   $cast(rhs_,rhs) &&
             super.do_compare(rhs_, comparer) &&

             enum2 == rhs_.enum2 &&

             int64 == rhs_.int64 &&
             int32 == rhs_.int32 &&
             int16 == rhs_.int16 &&
             int8  == rhs_.int8 &&
             int1  == rhs_.int1 &&

             uint64 == rhs_.uint64 &&
             uint32 == rhs_.uint32 &&
             uint16 == rhs_.uint16 &&
             uint8  == rhs_.uint8 &&
             uint1  == rhs_.uint1 &&

             time64 === rhs_.time64 &&
             str    == rhs_.str &&

             q      == rhs_.q  &&
             sa     == rhs_.sa && 
             da     == rhs_.da &&

             $realtobits(real64) == $realtobits(rhs_.real64) &&
`ifndef INCA             
             $shortrealtobits(real32) == $shortrealtobits(rhs_.real32) &&
`endif             
             bits   == rhs_.bits &&
             logics === rhs_.logics
             ;
             //*/
             //aa     == rhs_.aa; // &&

  endfunction


  // convert2string
  //---------------

  virtual function string convert2string();

   `ifdef UVM_USE_P_FORMAT
     return $sformatf("%p",this);
   `else
     string s;
     s = {s, $sformatf("enum2:%s ",enum2.name())};

     s = {s, $sformatf("int64:%0h ",int64)};
     s = {s, $sformatf("int32:%0h ",int32)};
     s = {s, $sformatf("int16:%0h ",int16)};
     s = {s, $sformatf("int8:%0h ", int8)};
     s = {s, $sformatf("int1:%0h ", int1)};
      
     s = {s, $sformatf("uint64:%0h ",uint64)};
     s = {s, $sformatf("uint32:%0h ",uint32)};
     s = {s, $sformatf("uint16:%0h ",uint16)};
     s = {s, $sformatf("uint8:%0h ", uint8)};
     s = {s, $sformatf("uint1:%0h ", uint1)};
      
     s = {s, $sformatf("real64:%0f ", real64)};
`ifndef INCA     
     s = {s, $sformatf("real32:%0f ", real32)};
`endif      
     s = {s, $sformatf("time64:%0t ", time64)};
      
     s = {s, $sformatf("str:%0s ", str)};

     s = {s, "sa:'{"};
     foreach (sa[i])
       s = {s, $sformatf("%s%0h", i==0?"":" ",sa[i])};
     s = {s, "} "};

     s = {s, "da:'{"};
     foreach (da[i])
       s = {s, $sformatf("%s%0h", i==0?"":" ",da[i])};
     s = {s, "} "};

     s = {s, "q:'{"};
     foreach (q[i])
       s = {s, $sformatf("%s%0h", i==0?"":" ",q[i])};
     s = {s, "} "};

     begin bit first=0;
     s = {s, "aa:'{"};
     foreach (aa[key])
       s = {s, $sformatf("%s%0h:%0h", first?"":" ",key, aa[key])};
     s = {s, "} "};
     end

     s = {s, $sformatf("bits:%0h", bits)};
     s = {s, $sformatf("logics:%0b", logics)};

    `endif
  endfunction


  // do_print
  // --------

  virtual function void do_print(uvm_printer printer);
    `ifndef UVM_USE_BKCOMPAT_NOMACRO_PRINT
    printer.print_generic("enum2", "enum2", 2, enum2.name());

    printer.print_int("int64", int64, 64);
    printer.print_int("int32", int32, 32);
    printer.print_int("int16", int16, 16);
    printer.print_int("int8",  int8,   8);
    printer.print_int("int1",  int1,   1);

    printer.print_int("uint64", uint64, 64);
    printer.print_int("uint32", uint32, 32);
    printer.print_int("uint16", uint16, 16);
    printer.print_int("uint8",  uint8,   8);
    printer.print_int("uint1",  uint1,   1);

    printer.print_time("time64", time64);
    printer.print_string("str", str);

    printer.print_array_header("sa",3,"sa(int)");
    foreach(sa[i])
      printer.print_int($sformatf("[%0d]", i), sa[i], 32);
    printer.print_array_footer();

    printer.print_array_header("da",da.size(),"da(int)");
    foreach(da[i])
      printer.print_int($sformatf("[%0d]", i), da[i], 16);
    printer.print_array_footer();

    printer.print_array_header("q",q.size(),"queue(int)");
    foreach(q[i])
      printer.print_int($sformatf("[%0d]", i), q[i], 8);
    printer.print_array_footer();

    printer.print_array_header("aa",aa.num(),"aa(int)");
    foreach(aa[i])
      printer.print_int($sformatf("[%0d]", i), aa[i], 16);
    printer.print_array_footer();

    printer.print_real("real64",real64);
`ifndef INCA
    printer.print_real("real32",real32);
`endif    
    printer.print_int("bits", bits, $bits(bits));
    printer.print_int("logics", logics, $bits(logics));
    `else
    if(printer.knobs.sprint)
      printer.m_string = convert2string();
    else
      $display(convert2string());
    `endif

  endfunction


  // do_record
  // ---------

  virtual function void do_record(uvm_recorder recorder);
    if (!is_recording_enabled())
      return;
    super.do_record(recorder);
    `uvm_record_field("int64", int64)
    `uvm_record_field("int32", int32)
    `uvm_record_field("int16", int16)
    `uvm_record_field("int8",  int8)
    `uvm_record_field("int1",  int1)

    `uvm_record_field("uint64", uint64)
    `uvm_record_field("uint32", uint32)
    `uvm_record_field("uint16", uint16)
    `uvm_record_field("uint8",  uint8)
    `uvm_record_field("uint1",  uint1)

    `uvm_record_field("time64", time64)
    `uvm_record_field("str", str)

`ifdef INCA      
    foreach(sa[i])
      `uvm_record_field($sformatf("\\sa[%0d] ", i), sa[i])
    // currently no support to store sa into db 
`else
    `uvm_record_field("sa",sa);
`endif    
    foreach(da[i])
      `uvm_record_field($sformatf("\\da[%0d] ", i), da[i])

    foreach(q[i])
      `uvm_record_field($sformatf("\\q[%0d] ", i), q[i])

    foreach(aa[i])
      `uvm_record_field($sformatf("\\aa[%0d] ", i), aa[i])

    `uvm_record_field("real64",real64)
`ifndef INCA    
    `uvm_record_field("real32",real32)
`endif
    `uvm_record_field("bits",bits)
    `uvm_record_field("logics",logics)

  endfunction


  // do_pack 
  
  virtual function void do_pack (uvm_packer packer);
     if (1) `uvm_pack_enum(enum2)
     else $write();     
     if (1) `uvm_pack_int(int64)
     else $write();     
     if (1) `uvm_pack_int(int32)
     else $write();     
     if (1) `uvm_pack_int(int16)
     else $write();     
     if (1) `uvm_pack_int(int8)
     else $write();     
     if (1) `uvm_pack_int(int1)
     else $write();     
     if (1) `uvm_pack_int(uint64)
     else $write();     
     if (1) `uvm_pack_int(uint32)
     else $write();     
     if (1) `uvm_pack_int(uint16)
     else $write();     
     if (1) `uvm_pack_int(uint8)
     else $write();     
     if (1) `uvm_pack_int(uint1)
     else $write();     
     if (1) `uvm_pack_int(bits)
     else $write();     
     if (1) `uvm_pack_int(logics)
     else $write();     
`ifndef INCA    
    if (1) `uvm_pack_real(real32)
     else $write();     
`endif    
     if (1) `uvm_pack_real(real64)
     else $write();     
     if(1) `uvm_pack_int(time64)
     else $write();     
     if (1) `uvm_pack_string(str)
     else $write();     
     if (1) `uvm_pack_sarrayN(sa,32)
     else $write();     
     if (1) `uvm_pack_arrayN(da,16)
     else $write();     
     if (1) `uvm_pack_queueN(q,8)
     else $write();     
  endfunction


  // do_unpack

  virtual function void do_unpack (uvm_packer packer);
    if (1) `uvm_unpack_enum(enum2,enum_t)
     else $write();     
    if (1) `uvm_unpack_int(int64)
     else $write();     
    if (1) `uvm_unpack_int(int32)
     else $write();     
    if (1) `uvm_unpack_int(int16)
     else $write();     
    if (1) `uvm_unpack_int(int8)
     else $write();     
    if (1) `uvm_unpack_int(int1)
     else $write();     
    if (1) `uvm_unpack_int(uint64)
     else $write();     
    if (1) `uvm_unpack_int(uint32)
     else $write();     
    if (1) `uvm_unpack_int(uint16)
     else $write();     
    if (1) `uvm_unpack_int(uint8)
     else $write();     
    if (1) `uvm_unpack_int(uint1)
     else $write();     
    if (1) `uvm_unpack_int(bits)
     else $write();     
    if (1) `uvm_unpack_int(logics)
     else $write();     
`ifndef INCA
    if (1) `uvm_unpack_real(real32)
     else $write();     
`endif
    if (1) `uvm_unpack_real(real64)
     else $write();     
    if (1) `uvm_unpack_int(time64)
     else $write();     
    if (1) `uvm_unpack_string(str)
     else $write();     
    if (1) `uvm_unpack_sarrayN(sa,32)
     else $write();     
    if (1) `uvm_unpack_arrayN(da,16)
     else $write();     
    if (1) `uvm_unpack_queueN(q,8)
     else $write();     
  endfunction



  // pre_randomize
  // -------------

  function void pre_randomize();
    int aa_size;
    int str_size;

    // randomize assoc array
    void'(std::randomize(aa_size) with { aa_size inside {[4:11]}; });
    aa.delete();
    for (int i=0; i < aa_size; i++) begin
      byte b;
      int ele;
      b = $urandom; // seed for RNG? time of day?
      ele = $urandom;
      aa[b] = ele;
    end

    // randomize string
    void'(std::randomize(str_size) with { str_size inside {[4:11]}; });
    str = "";
    for (int i=0; i < str_size; i++) begin
      byte ele;
      void'(std::randomize(ele) with { ele inside {[32:126]}; });
      str = {str, $sformatf("%s",ele)};
    end
  endfunction

  function void post_randomize();
    // reals derive from quotient of two randomized ints
    real64 = real'(uint64) / real'(uint32);
`ifndef INCA    
    real32 = real'(uint32) / real'(uint16);
`endif    
  endfunction

endclass


//------------------------------------------------------------------------------
//
// CLASS: item
//
//------------------------------------------------------------------------------

class item_macro extends uvm_sequence_item;

  typedef enum bit [1:0] { NOP, READ, WRITE } enum_t;
   
  bit                    pad[$];

  rand enum_t            enum2;

  rand longint           int64;
  rand int               int32;
  rand shortint          int16;
  rand byte              int8;
  rand bit               int1;

  rand longint unsigned  uint64;
  rand int unsigned      uint32;
  rand shortint unsigned uint16;
  rand byte unsigned     uint8;
  rand bit unsigned      uint1;

`ifndef INCA
       shortreal         real32;
`endif       
       real              real64;

  rand time              time64;

       string            str;

  rand int               sa[3];
  rand shortint          da[];
  rand byte              q[$];
       shortint          aa[shortint];

  rand bit [`N-1:0]       bits;
  rand logic [`N-1:0]     logics;

  constraint C_q_size  { q.size  inside {[1:11]}; }
  constraint C_da_size { da.size inside {[1:11]}; }


  function new(string name="");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(item_macro)

     `uvm_field_enum(enum_t,enum2,UVM_ALL_ON);

     `uvm_field_int(int64,UVM_ALL_ON)
     `uvm_field_int(int32,UVM_ALL_ON)
     `uvm_field_int(int16,UVM_ALL_ON)
     `uvm_field_int(int8,UVM_ALL_ON)
     `uvm_field_int(int1,UVM_ALL_ON)

     `uvm_field_int(uint64,UVM_ALL_ON)
     `uvm_field_int(uint32,UVM_ALL_ON)
     `uvm_field_int(uint16,UVM_ALL_ON)
     `uvm_field_int(uint8,UVM_ALL_ON)
     `uvm_field_int(uint1,UVM_ALL_ON)
`ifndef INCA
     `uvm_field_real(real32,UVM_ALL_ON)
`endif     
     `uvm_field_real(real64,UVM_ALL_ON)

     `uvm_field_int(time64,UVM_ALL_ON|UVM_TIME)

     `uvm_field_string(str,UVM_ALL_ON)

     `uvm_field_sarray_int(sa,UVM_ALL_ON)
     `uvm_field_array_int(da,UVM_ALL_ON)
     `uvm_field_queue_int(q,UVM_ALL_ON)
     `uvm_field_aa_int_shortint(aa,UVM_ALL_ON)

     `uvm_field_int(bits,UVM_ALL_ON)
     `uvm_field_int(logics,UVM_ALL_ON)

  `uvm_object_utils_end

 // convert2string
  //---------------

  virtual function string convert2string();

   `ifdef UVM_USE_P_FORMAT
     return $sformatf("%p",this);
   `else
     string s;
     s = {s, $sformatf("enum2:%s ",enum2.name())};

     s = {s, $sformatf("int64:%0h ",int64)};
     s = {s, $sformatf("int32:%0h ",int32)};
     s = {s, $sformatf("int16:%0h ",int16)};
     s = {s, $sformatf("int8:%0h ", int8)};
     s = {s, $sformatf("int1:%0h ", int1)};
      
     s = {s, $sformatf("uint64:%0h ",uint64)};
     s = {s, $sformatf("uint32:%0h ",uint32)};
     s = {s, $sformatf("uint16:%0h ",uint16)};
     s = {s, $sformatf("uint8:%0h ", uint8)};
     s = {s, $sformatf("uint1:%0h ", uint1)};
      
     s = {s, $sformatf("real64:%0f ", real64)};
`ifndef INCA     
     s = {s, $sformatf("real32:%0f ", real32)};
`endif      
     s = {s, $sformatf("time64:%0t ", time64)};
      
     s = {s, $sformatf("str:%0s ", str)};

     s = {s, "sa:'{"};
     foreach (sa[i])
       s = {s, $sformatf("%s%0h", i==0?"":" ",sa[i])};
     s = {s, "} "};

     s = {s, "da:'{"};
     foreach (da[i])
       s = {s, $sformatf("%s%0h", i==0?"":" ",da[i])};
     s = {s, "} "};

     s = {s, "q:'{"};
     foreach (q[i])
       s = {s, $sformatf("%s%0h", i==0?"":" ",q[i])};
     s = {s, "} "};

     begin bit first=0;
     s = {s, "aa:'{"};
     foreach (aa[key])
       s = {s, $sformatf("%s%0h:%0h", first?"":" ",key, aa[key])};
     s = {s, "} "};
     end

     s = {s, $sformatf("bits:%0h", bits)};
     s = {s, $sformatf("logics:%0b", logics)};

    `endif
  endfunction


endclass

`ifndef NUM_TRANS
`define NUM_TRANS 1
`endif

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
    static item       man1=new("man1"),man2=new("man2");
    static item_macro mac1=new("mac1"),mac2=new("mac2");

    uvm_default_packer.use_metadata = 1;
    uvm_default_packer.big_endian = 0;

    uvm_top.set_report_id_action("ILLEGALNAME",UVM_NO_ACTION);

    $display("\NUM_TRANS=%0d",`NUM_TRANS);

    assert(man2.randomize());

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
    
    for (int i=0; i< `NUM_TRANS; i++) begin
      void'(man1.pack(bits));
      void'(man2.unpack(bits));
      if (!man1.compare(man2)) begin
        $display("MISCOMPARE!");
        man1.print();
        man2.print();
      end
    end


    for (int i=0; i< `NUM_TRANS; i++) begin
      void'(mac1.pack(bits));
      void'(mac2.unpack(bits));
      if (!mac1.compare(mac2)) begin
        mac1.print();
        mac2.print();
        `uvm_fatal("MISCOMPARE","mismatch in pack/unpack")
        
      end
    end
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
    static int NUM = `NUM_TRANS/5;
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
