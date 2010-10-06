// 
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 

class blk_AXW_test_seq extends uvm_ral_sequence;

   `uvm_object_utils(blk_AXW_test_seq)

   ral_block_B ral;

   function new(string name = "blk_AXW_test_seq");
      super.new(name);
   endfunction: new

   virtual task body();
      uvm_ral::status_e status;
      uvm_ral_data_t    data;
      int n;

      // Write all three registers at once. W will be written concurrently with
      // A or X because W will go across the WSH bus, whereas A and X both go
      // across the APB bus and must therefore execute sequentially. It the
      // responsibility of the DUT to handle concurrent accesses across
      // two different interfaces.
      fork
      ral.A.write(status, 'h33, .parent(this));
      ral.X.write(status, 'h44, .parent(this));
      ral.W.write(status, 'hcc, .parent(this));
      join

      // Write A to random value via default map (APB), then check against mirror
      data[7:0] = $urandom();
      ral.A.write(status, data, .parent(this));
      ral.A.mirror(status, uvm_ral::CHECK, .parent(this));

      // Write ~A to X via APB interface, then check via WSH interface
      ral.X.write(status, ~ral.A.get(), .map(ral.APB), .parent(this));
      ral.X.mirror(status, uvm_ral::CHECK, .map(ral.WSH), .parent(this));

      // Write ~X to W via default map (APB), then check
      ral.W.write(status, ~ral.X.get(), .parent(this));
      ral.W.mirror(status, uvm_ral::CHECK, .parent(this));

      // W should now be equal to A
      if (ral.W.get() !== data) begin
         `uvm_error("test", $psprintf("W == 'h%h != 'h%h", ral.X.get(), data));
      end
   endtask
   
endclass
