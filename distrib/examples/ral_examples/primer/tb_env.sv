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

class tb_env extends uvm_component;

   `uvm_component_utils(tb_env)

   ral_block_slave ral; 
   apb_agent apb;

   function new(string name, uvm_component parent=null);
      super.new(name,parent);
   endfunction

   virtual function void build();
      ral = ral_block_slave::type_id::create("ral",this);
      apb = apb_agent::type_id::create("apb", this);
      ral.build();
  endfunction

   virtual function void connect();
      ral2apb_adapter ral2apb = new;
      ral.default_map.set_sequencer(apb.sqr,ral2apb);
   endfunction

endclass

