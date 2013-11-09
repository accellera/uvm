// -------------------------------------------------------------
//    Copyright 2013 Synopsys, Inc.
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
//    permissions and limitations under t,he License.
// -------------------------------------------------------------
// //
// Template for UVM-compliant sequence library
//


`ifndef SQR_SNPS_SEQUENCE_LIBRARY__SV
`define SQR_SNPS_SEQUENCE_LIBRARY__SV

`include "trans_snps.sv"
`include "ral_DUT.sv"

typedef class trans_snps;

class sqr_snps_sequence_library extends uvm_sequence_library # (trans_snps);
  `uvm_sequence_library_utils(sqr_snps_sequence_library)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class base_sequence extends uvm_sequence #(trans_snps);
  `uvm_object_utils(base_sequence)

  function new(string name = "base_seq");
    super.new(name);
  endfunction:new
  virtual task pre_body();
      uvm_phase starting_phase = get_starting_phase();
    if (starting_phase != null)
      starting_phase.raise_objection(this);
  endtask:pre_body
  virtual task post_body();
      uvm_phase starting_phase = get_starting_phase();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask:post_body
endclass

class sequence_0 extends base_sequence;
  `uvm_object_utils(sequence_0)
  `uvm_add_to_seq_lib(sequence_0,sqr_snps_sequence_library)
  function new(string name = "seq_0");
    super.new(name);
  endfunction:new
  virtual task body();
    repeat(10) begin
      `uvm_do(req);
    end
  endtask
endclass

class sequence_1 extends base_sequence;
  byte sa;
  `uvm_object_utils(sequence_1)
  
  function new(string name = "seq_1");
    super.new(name);
  endfunction:new
  
  virtual task body();
      uvm_phase starting_phase = get_starting_phase();
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     if (starting_phase != null)
       starting_phase.raise_objection(this);
     `uvm_do_with(req, {addr == 'h00; kind == trans_snps::READ;});
     `uvm_info("CTRL_REG READ before write", {"\n", req.sprint()}, UVM_MEDIUM);
     `uvm_do_with(req, {addr == 'h00; data == '1; kind == trans_snps::WRITE;});
     `uvm_info("CTRL_REG WRITE", {"\n", req.sprint()}, UVM_MEDIUM);
     `uvm_do_with(req, {addr == 'h00; kind == trans_snps::READ;});
     `uvm_info("CTRL_REG READ after write", {"\n", req.sprint()}, UVM_MEDIUM);
     if (starting_phase != null)
       starting_phase.drop_objection(this);
   
   endtask
endclass


`endif // SQR_SNPS_SEQUENCE_LIBRARY__SV
