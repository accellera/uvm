//-----------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// CLASS: uvm_converter
//
// The uvm_converter class provides a policy object for doing convertion
// from values to strings.
//
//------------------------------------------------------------------------------

class uvm_converter #(type T=int);

   // Function: convert2string
   // Convert a value of type ~T~ to a string that can be displayed.
   //
   // By default, returns the name of the type
   //
   static function string convert2string(T val);
      return $typename(T);
   endfunction

   // Function: to_string
   // Virtual version of <convert2string()>.
   //
   // By default, calls <convert2string()>.
   //
   virtual function string to_string(T val);
      return convert2string(val);
   endfunction

endclass

