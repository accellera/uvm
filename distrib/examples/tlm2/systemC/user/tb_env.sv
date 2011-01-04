// 
// -------------------------------------------------------------
//    Copyright 2010-2011 Synopsys, Inc.
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


`include "uvm_macros.svh"
`include "payload.sv"
`include "initiator.sv"
`include "target.sv"

`include "uvm_tlm2_sv_bind.svh"


class tb_env extends uvm_env;
   `uvm_component_utils(tb_env);

   initiator initiator0;
   target    target0;

   function new(string name, uvm_component parent = null);
     super.new(name, parent);
   endfunction: new

   function void build();
      super.build();
      initiator0 = initiator::type_id::create("initiator0", this);
      target0    = target::type_id::create("target0", this);
   endfunction : build
   
   function void connect();
      uvm_tlm2_sv_bind#(payload)::connect(initiator0.socket,
                                          UVM_TLM_B_INITIATOR,
                                          "port0");

      uvm_tlm2_sv_bind#(payload)::connect(target0.socket,
                                          UVM_TLM_B_TARGET,
                                          "port1");
   endfunction : connect

endclass: tb_env
