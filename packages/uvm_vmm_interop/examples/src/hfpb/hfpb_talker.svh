//----------------------------------------------------------------------
//   Copyright 2005-2007 Mentor Graphics Corporation
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
// hfpb_talker
//----------------------------------------------------------------------
class hfpb_talker #(int DATA_SIZE=8, int ADDR_SIZE=16)
  extends uvm_subscriber #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE));

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction

  function void write(hfpb_transaction #(DATA_SIZE, ADDR_SIZE) t);
    uvm_report_info("hfpb", t.convert2string());
  endfunction

endclass
