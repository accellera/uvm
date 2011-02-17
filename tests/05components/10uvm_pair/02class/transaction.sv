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

import uvm_pkg::*;

class transaction extends uvm_transaction;

`uvm_object_utils(transaction)

rand logic rw;
rand logic [7:0] data;
rand logic [1:0] addr;


function new (string name="");
  super.new(name);
endfunction

function string convert2string;
  string s;
  string s1, s2, s3;
  
  s2.itoa(data);
  s3.itoa(addr);
  
  if (rw)
    s = {"WRITE transaction: Address is ", s2, " Data is ", s3};
  else
    s = {"READ transaction: Address is ", s2, " Data is ", s3};
    
  return s;
endfunction

virtual function void do_copy( uvm_object rhs );
  transaction rhs_;
  assert($cast(rhs_,rhs));
  rw = rhs_.rw;
  data = rhs_.data;
  addr = rhs_.addr;
endfunction

virtual function bit do_compare( uvm_object rhs, uvm_comparer comparer );
  transaction rhs_;
  assert($cast(rhs_,rhs));
  if (rw != rhs_.rw)
    return 0;
  else if (data != rhs_.data)
    return 0;
  else if (addr != rhs_.addr)
    return 0;
  else return 1;
endfunction

endclass
