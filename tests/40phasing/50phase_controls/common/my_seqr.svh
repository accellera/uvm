//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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
//------------------------------------------------------------------------------

class my_seqr extends uvm_sequencer;
  `uvm_component_utils(my_seqr)

  function new (string name="my_seqr0", uvm_component parent);
    super.new(name, parent);
    count = 0;
  endfunction : new

endclass : my_seqr

class my_seq extends uvm_sequence;
  `uvm_object_utils(my_seq)

  function new(string name="my_seq");
     super.new(name);
  endfunction

endclass : my_seq
