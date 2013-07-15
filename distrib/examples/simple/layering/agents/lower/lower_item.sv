//----------------------------------------------------------------------
//   Copyright 2013 Synopsys, Inc.
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

class lower_item extends uvm_sequence_item; 
  local uvm_sequence_item m_contains;

  `uvm_object_utils(lower_item)

  virtual function string get_full_name();
    return {get_type_name, "[", get_name(), "](",
            (m_contains == null) ? "" : m_contains.get_full_name(), ")"};
  endfunction

  function new(string name = "lower_item");
    super.new(name);
  endfunction

  function void encapsulate(uvm_sequence_item what);
    m_contains = what;
  endfunction

  function uvm_sequence_item decapsulate();
    return m_contains;
  endfunction

endclass
