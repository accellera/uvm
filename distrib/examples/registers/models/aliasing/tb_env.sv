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


`include "any_agent.sv"

typedef any_agent #(uvm_reg_bus_item) bus_agent;
typedef any_driver #(uvm_reg_bus_item) bus_driver;
class my_bus_driver extends bus_driver;

   `uvm_component_utils(my_bus_driver)
   
   bit [7:0] F1 = 0;
   bit [7:0] F2 = 0;
   
   function new(string name = "my_bus_driver", uvm_component parent=null);
      super.new(name, parent);
   endfunction: new

   virtual task do_req(uvm_reg_bus_item req);
      this.pre_req(req);
      case (req.addr)
       'h000: // Ra
          if (req.kind == UVM_READ) req.data = {8'h00, F2, 8'h00, F1};
          else if (req.byte_en[0]) F1 = req.data[7:0];
       'h100: // Rb
          if (req.kind == UVM_READ) req.data = {8'h00, F2, 8'h00, F1};
          else begin
             if (req.byte_en[0]) F1 = req.data[7:0];
             if (req.byte_en[2]) F2 = req.data[23:16];
          end
      endcase
      post_req(req);
   endtask
endclass


class tb_env extends uvm_env;

   `uvm_component_utils(tb_env)

   block_B   regmodel;
   bus_agent bus;

   function new(string name = "tb_env", uvm_component parent=null);
      super.new(name, parent);
   endfunction: new

   virtual function void build();
      regmodel = block_B::type_id::create("regmodel");
      regmodel.build();
      regmodel.lock_model();

      bus = bus_agent::type_id::create("bus", this);
      set_inst_override_by_type("bus.drv",
                                bus_driver::get_type(),
                                my_bus_driver::get_type());
  endfunction: build

   virtual function void connect();
      uvm_reg_passthru_adapter reg2reg  = uvm_reg_passthru_adapter::type_id::create("reg2reg");
      reg2reg.supports_byte_enable = 1;
      regmodel.default_map.set_sequencer(bus.sqr, reg2reg);
   endfunction

endclass
