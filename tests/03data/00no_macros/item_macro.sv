//
//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc.
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
     s = {s, $psprintf("enum2:%s ",enum2.name())};

     s = {s, $psprintf("int64:%0h ",int64)};
     s = {s, $psprintf("int32:%0h ",int32)};
     s = {s, $psprintf("int16:%0h ",int16)};
     s = {s, $psprintf("int8:%0h ", int8)};
     s = {s, $psprintf("int1:%0h ", int1)};
      
     s = {s, $psprintf("uint64:%0h ",uint64)};
     s = {s, $psprintf("uint32:%0h ",uint32)};
     s = {s, $psprintf("uint16:%0h ",uint16)};
     s = {s, $psprintf("uint8:%0h ", uint8)};
     s = {s, $psprintf("uint1:%0h ", uint1)};
      
     s = {s, $psprintf("real64:%0f ", real64)};
`ifndef INCA     
     s = {s, $psprintf("real32:%0f ", real32)};
`endif      
     s = {s, $psprintf("time64:%0t ", time64)};
      
     s = {s, $psprintf("str:%0s ", str)};

     s = {s, "sa:'{"};
     foreach (sa[i])
       s = {s, $psprintf("%s%0h", i==0?"":" ",sa[i])};
     s = {s, "} "};

     s = {s, "da:'{"};
     foreach (da[i])
       s = {s, $psprintf("%s%0h", i==0?"":" ",da[i])};
     s = {s, "} "};

     s = {s, "q:'{"};
     foreach (q[i])
       s = {s, $psprintf("%s%0h", i==0?"":" ",q[i])};
     s = {s, "} "};

     begin bit first=0;
     s = {s, "aa:'{"};
     foreach (aa[key])
       s = {s, $psprintf("%s%0h:%0h", first?"":" ",key, aa[key])};
     s = {s, "} "};
     end

     s = {s, $psprintf("bits:%0h", bits)};
     s = {s, $psprintf("logics:%0b", logics)};

    `endif
  endfunction


endclass
