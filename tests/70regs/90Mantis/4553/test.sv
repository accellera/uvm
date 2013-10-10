// 
// -------------------------------------------------------------
//    Copyright 2010-2011 Cadence Design Systems, Inc.
//    Copyright 2010-2011 Mentor Graphics Corporation
//    Copyright 2011 Synopsys, Inc.
//    Copyright 2013 Semifore, Inc.
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
// 

program access_test;
   import uvm_pkg::*;
`include "uvm_macros.svh"

   class reg1 extends uvm_reg;

      uvm_reg_field rw_field;

      function new(string name = "reg1");
         super.new(name, 32, UVM_NO_COVERAGE);
      endfunction

      virtual function void build();
         this.rw_field = uvm_reg_field::type_id::create("rw_field");
         this.rw_field.configure(this, 8, 0, "RW", 0, 8'h03, 1, 0, 0);
      endfunction

      `uvm_object_utils(reg1)
   endclass : reg1

   class reg2 extends uvm_reg;

      uvm_reg_field wo_field;

      function new(string name = "reg2");
         super.new(name, 32, UVM_NO_COVERAGE);
      endfunction

      virtual function void build();
         this.wo_field = uvm_reg_field::type_id::create("wo");
         this.wo_field.configure(this, 8, 0, "WO", 0, 8'h03, 1, 0, 0);
      endfunction

      `uvm_object_utils(reg2)
   endclass : reg2

   class reg3 extends uvm_reg;

      uvm_reg_field rw_field;

      function new(string name = "reg3");
         super.new(name, 32, UVM_NO_COVERAGE);
      endfunction

      virtual function void build();
         this.rw_field = uvm_reg_field::type_id::create("rw_field");
         this.rw_field.configure(this, 8, 0, "RW", 0, 8'h03, 1, 0, 0);
      endfunction

      `uvm_object_utils(reg3)
   endclass : reg3

   class my_block extends uvm_reg_block;

      reg1    reg1_inst;
      reg2    reg2_inst;
      reg3    reg3_inst;

      function new(string name = "my_block");
         super.new(name, UVM_NO_COVERAGE);
      endfunction

      virtual function void build();
         reg1_inst = reg1::type_id::create("reg1_inst");
         reg1_inst.configure(this, null);
         reg1_inst.build();

         reg2_inst = reg2::type_id::create("reg2_inst");
         reg2_inst.configure(this, null);
         reg2_inst.build();

         reg3_inst = reg3::type_id::create("reg3_inst");
         reg3_inst.configure(this, null);
         reg3_inst.build();

         default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);
         default_map.add_reg(reg1_inst, 'h0, "RW");
         default_map.add_reg(reg2_inst, 'h4, "RO");
         default_map.add_reg(reg3_inst, 'h8, "RS");
      endfunction

      `uvm_object_utils(my_block)
   endclass : my_block

   class trans_item extends uvm_sequence_item;
      typedef enum {READ, WRITE} op_e;
      rand op_e                  kind;

      `uvm_object_utils_begin(trans_item)
          `uvm_field_enum(op_e, kind, UVM_ALL_ON);
      `uvm_object_utils_end 
 
      function new(string name="");
         super.new(name);
      endfunction
   endclass : trans_item

   class trans_driver #(type T=trans_item) extends uvm_driver#(T);
      `uvm_component_utils(trans_driver)
      function new(string name, uvm_component parent=null);
         super.new(name, parent);
      endfunction

      task run();
         while(1) begin
            #10;
            seq_item_port.get_next_item(req);
            if (req != null) begin
               if (req.kind == trans_item::READ) begin
                  `uvm_info("Driver", "Received READ", UVM_MEDIUM);
               end
               else if (req.kind == trans_item::WRITE) begin
                  `uvm_info("Driver", "Received WRITE", UVM_MEDIUM);
               end
            end
            seq_item_port.item_done();
         end
      endtask
   endclass : trans_driver

   class trans_sequencer#(type T=trans_item) extends uvm_sequencer#(T);
      `uvm_component_param_utils(trans_sequencer#(T))
      function new(string name, uvm_component parent=null);
         super.new(name, parent);
      endfunction
   endclass : trans_sequencer

   class acc_agent#(type T=trans_item) extends uvm_agent;
      trans_sequencer#(T) sqr;
      trans_driver#(T)    drvr;

      `uvm_component_param_utils(acc_agent#(T))
      function new(string name, uvm_component parent=null);
         super.new(name, parent);
         sqr = new("sqr", this);
         drvr = new("driver", this);
      endfunction

      virtual function void build();
         drvr.seq_item_port.connect(sqr.seq_item_export);
      endfunction
   endclass : acc_agent

   class my_adapter extends uvm_reg_adapter;
      virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
         trans_item t_item = trans_item::type_id::create("trans_item");
         t_item.kind = (rw.kind == UVM_READ) ? trans_item::READ : trans_item::WRITE;
         return t_item;
      endfunction
      virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      endfunction
   endclass : my_adapter

   class my_seq extends uvm_reg_sequence;
      my_block     model;
      function new(string name="my_seq");
         super.new(name);
      endfunction
      `uvm_object_utils(my_seq);

      virtual task body();
         uvm_status_e   status;
         uvm_reg_data_t data;
         string         access_val = "";
         uvm_reg_map    maps[$];
 
         model.get_maps(maps);
         access_val = model.reg1_inst.rw_field.get_access(maps[0]);
         if (access_val != "RW")
            $write("** UVM TEST FAILED **\n");
         else begin
            access_val = model.reg2_inst.wo_field.get_access(maps[0]);
            if (access_val != "NOACCESS")
               $write("** UVM TEST FAILED **\n");
            else begin
               access_val = model.reg3_inst.rw_field.get_access(maps[0]);
               if (access_val != "NOACCESS")
                  $write("** UVM TEST FAILED **\n");
               else $write("** UVM TEST PASSED **\n");
            end
         end
      endtask
   endclass : my_seq

   class test extends uvm_test;
      `uvm_component_utils(test)

      my_block model;
      my_seq    seq0;
      acc_agent#(trans_item) my_agent;
      my_adapter adapter;

      function new(string name, uvm_component parent=null);
         super.new(name, parent);
      endfunction

      virtual function void build_phase(uvm_phase phase);
         if (model == null) begin
            model = my_block::type_id::create("model", this);
            model.build();
            model.lock_model();
         end

         my_agent = acc_agent#(trans_item)::type_id::create("my_agent", this);
      endfunction

      virtual function void connect_phase(uvm_phase phase);
         if (model.get_parent() == null) begin
            adapter = new;
            model.default_map.set_sequencer(my_agent.sqr, adapter);
            model.default_map.set_auto_predict(1);
         end
      endfunction

      task run_phase(uvm_phase phase);
         phase.raise_objection(this);
         begin
           seq0 = my_seq::type_id::create("seq0", this);
           seq0.model = model;
           seq0.start(null);
         end
         phase.drop_objection(this);
      endtask
   endclass : test

   initial begin
      run_test();
   end
endprogram
