//------------------------------------------------------------------------------
//    Copyright 2008 Mentor Graphics Corporation
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the "License"); you may
//    not use this file except in compliance with the License.  You may obtain
//    a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//    License for the specific language governing permissions and limitations
//    under the License.
//------------------------------------------------------------------------------

`ifndef AVT_CONVERTER_SV
`define AVT_CONVERTER_SV

//------------------------------------------------------------------------------
//
// CLASS: avt_converter #(IN,OUT)
//
// This converter is a non-functional placeholder used as a default parameter
// value for any adapters' unused converters. 
//------------------------------------------------------------------------------

class avt_converter #(type IN=int, OUT=int);

  // Parameter: IN
  //
  // The input type to convert from.
  
  // Parameter: OUT
  //
  // The output type to convert to.

  // Function: convert
  //
  // Normally implemented to convert ~IN~ transactions to ~OUT~ transactions,
  // the ~convert~ function in this class does nothing. Thus, this class is
  // a dummy-converter used in adapter's default type parameter assignments.
  //
  // The ~to~ argument allows the conversion to copy into an existing
  // object and avoid the expense of allocation.
  // If ~to~ is null (default), the convert method should create a new
  // instance of OUT, copy the fields of ~in~ to it, and return it. If the
  // ~to~ argument is non-null, the convert method should copy the fields
  // of ~in~ to the corresponding fields of ~to~, then return ~to~.

  static function OUT convert(IN in, OUT to=null);  
    return to;
  endfunction

endclass

`endif // AVT_CONVERTER_SV
