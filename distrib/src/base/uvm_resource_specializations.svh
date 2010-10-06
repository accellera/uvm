//----------------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
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

//----------------------------------------------------------------------
// uvm_int_rsrc
//
// specialization of uvm_resource #() for int
//----------------------------------------------------------------------
class uvm_int_rsrc extends uvm_resource #(int);

  function new(string name, string s = "*");
    super.new(name, s);
  endfunction

  function string convert2string();
    string s;
    $sformat(s, "%0d", read());
    return s;
  endfunction

endclass

//----------------------------------------------------------------------
// uvm_string_rsrc
//
// specialization of uvm_resource #() for string
//----------------------------------------------------------------------
class uvm_string_rsrc extends uvm_resource #(string);

  function new(string name, string s = "*");
    super.new(name, s);
  endfunction

  function string convert2string();
    return read();
  endfunction

endclass

//----------------------------------------------------------------------
// uvm_obj_rsrc
//
// specialization of uvm_resource #() for uvm_object
//----------------------------------------------------------------------
class uvm_obj_rsrc extends uvm_resource #(uvm_object);

  function new(string name, string s = "*");
    super.new(name, s);
  endfunction

endclass

//----------------------------------------------------------------------
// uvm_bit_rsrc
//
// specialization of uvm_resource #() for vector of bits
//----------------------------------------------------------------------
class uvm_bit_rsrc #(int unsigned N=1) extends uvm_resource #(bit[N-1:0]);

  function new(string name, string s = "*");
    super.new(name, s);
  endfunction

  function string convert2string();
    string s;
    $sformat(s, "%0b", read());
    return s;
  endfunction

endclass

//----------------------------------------------------------------------
// uvm_byte_rsrc
//
// specialization of uvm_resource #() for vector of bytes
//----------------------------------------------------------------------
class uvm_byte_rsrc #(int unsigned N=1) extends uvm_resource #(bit[7:0][N-1:0]);

  function new(string name, string s = "*");
    super.new(name, s);
  endfunction

  function string convert2string();
    string s;
    $sformat(s, "%0x", read());
    return s;
  endfunction

endclass

