//
//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
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
    `uvm_pack_enum(enum2)
    `uvm_pack_int(int64)
    `uvm_pack_int(int32)
    `uvm_pack_int(int16)
    `uvm_pack_int(int8)
    `uvm_pack_int(int1)
    `uvm_pack_int(uint64)
    `uvm_pack_int(uint32)
    `uvm_pack_int(uint16)
    `uvm_pack_int(uint8)
    `uvm_pack_int(uint1)
    `uvm_pack_int(bits)
    `uvm_pack_int(logics)
`ifndef INCA    
    `uvm_pack_real(real32)
`endif    
    `uvm_pack_real(real64)
    `uvm_pack_int(time64)
    `uvm_pack_string(str)
    `uvm_pack_sarrayN(sa,32)
    `uvm_pack_arrayN(da,16)
    `uvm_pack_queueN(q,8)
  endfunction


  // do_unpack

  virtual function void do_unpack (uvm_packer packer);
    `uvm_unpack_enum(enum2,enum_t)
    `uvm_unpack_int(int64)
    `uvm_unpack_int(int32)
    `uvm_unpack_int(int16)
    `uvm_unpack_int(int8)
    `uvm_unpack_int(int1)
    `uvm_unpack_int(uint64)
    `uvm_unpack_int(uint32)
    `uvm_unpack_int(uint16)
    `uvm_unpack_int(uint8)
    `uvm_unpack_int(uint1)
    `uvm_unpack_int(bits)
    `uvm_unpack_int(logics)
`ifndef INCA
    `uvm_unpack_real(real32)
`endif
    `uvm_unpack_real(real64)
    `uvm_unpack_int(time64)
    `uvm_unpack_string(str)
    `uvm_unpack_sarrayN(sa,32)
    `uvm_unpack_arrayN(da,16)
    `uvm_unpack_queueN(q,8)
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
