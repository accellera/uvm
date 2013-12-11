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

program volatile;
   import uvm_pkg::*;
`include "uvm_macros.svh"

   bit [1:0] wrt_cnt = 2'b00;

   class vol_reg extends uvm_reg;

      uvm_reg_field vol_field;

      function new(string name = "vol_reg");
         super.new(name, 32, UVM_NO_COVERAGE);
      endfunction

      virtual function void build();
         this.vol_field = uvm_reg_field::type_id::create("vol_field");
         this.vol_field.configure(this, 8, 0, "RW", 1, 8'h03, 1, 0, 0);
      endfunction

      `uvm_object_utils(vol_reg)
   endclass : vol_reg

   class nonvol_reg extends uvm_reg;

      uvm_reg_field nonvol_field;

      function new(string name = "nonvol_reg");
         super.new(name, 32, UVM_NO_COVERAGE);
      endfunction

      virtual function void build();
         this.nonvol_field = uvm_reg_field::type_id::create("nonvol_field");
         this.nonvol_field.configure(this, 8, 0, "RW", 0, 8'h03, 1, 0, 0);
      endfunction

      `uvm_object_utils(nonvol_reg)
   endclass : nonvol_reg

   class my_block extends uvm_reg_block;

      vol_reg    vol_reg_inst;
      nonvol_reg nonvol_reg_inst;

      function new(string name = "my_block");
         super.new(name, UVM_NO_COVERAGE);
      endfunction

      virtual function void build();
         vol_reg_inst = vol_reg::type_id::create("vol_reg_inst");
         vol_reg_inst.configure(this, null);
         vol_reg_inst.build();

         nonvol_reg_inst = nonvol_reg::type_id::create("nonvol_reg_inst");
         nonvol_reg_inst.configure(this, null);
         nonvol_reg_inst.build();

         default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);
         default_map.add_reg(vol_reg_inst, 'h0, "RW");
         default_map.add_reg(nonvol_reg_inst, 'h4, "RW");
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
               if (req.kind == trans_item::WRITE) begin
                  `uvm_info("Driver", "Received item", UVM_MEDIUM);
                  wrt_cnt++;
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

   class vol_agent#(type T=trans_item) extends uvm_agent;
      trans_sequencer#(T) sqr;
      trans_driver#(T)    drvr;

      `uvm_component_param_utils(vol_agent#(T))
      function new(string name, uvm_component parent=null);
         super.new(name, parent);
         sqr = new("sqr", this);
         drvr = new("driver", this);
      endfunction

      virtual function void build();
         drvr.seq_item_port.connect(sqr.seq_item_export);
      endfunction
   endclass : vol_agent

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
      my_block model;
      function new(string name="my_seq");
         super.new(name);
      endfunction
      `uvm_object_utils(my_seq);

      virtual task body();
         uvm_status_e   status;
         uvm_reg_data_t data;
         model.vol_reg_inst.update(status);
         if (wrt_cnt == 1'b0) begin
            $write("** UVM TEST FAILED **\n");
         end
         else begin
            model.nonvol_reg_inst.update(status);
            if (wrt_cnt != 1'b1) begin
               $write("** UVM TEST FAILED **\n");
            end
            else begin
              $write("** UVM TEST PASSED **\n");
            end
         end
      endtask
   endclass : my_seq

   class test extends uvm_test;
      `uvm_component_utils(test)

      my_block model;
      my_seq    seq0;
      vol_agent#(trans_item) my_agent;
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

         my_agent = vol_agent#(trans_item)::type_id::create("my_agent", this);
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
