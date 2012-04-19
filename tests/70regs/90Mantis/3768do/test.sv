// 
// -------------------------------------------------------------
//    Copyright 2011 Synopsys, Inc.
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


module dut();

bit [31:0] r1;

function void reset();
   r1 = 0;
endfunction

initial reset();

endmodule


program test;

import uvm_pkg::*;


class reg1 extends uvm_reg;
   `uvm_object_utils(reg1)

   uvm_reg_field data;

   function new(string name = "reg1");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      data = uvm_reg_field::type_id::create("data",,get_full_name());
      data.configure(this, 32,  0, "RW", 0,   'h0, 1, 0, 1);
   endfunction
endclass


class my_dut extends uvm_reg_block;
   `uvm_object_utils(my_dut)

   reg1 r1;
   
   function new(string name = "my_dut");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      default_map = create_map("", 'h0, 1, UVM_LITTLE_ENDIAN);
      
      r1 = reg1::type_id::create("r1",,get_full_name());
      r1.configure(this, null, "");
      r1.build();

      default_map.add_reg(r1, 0);
   endfunction
endclass


`include "reg_agent.sv"

class dut_rw;
   static task rw(reg_rw rw);
      casez (rw.addr)
       'h0000:
          if (rw.read) rw.data = dut.r1[7:0];
          else dut.r1[7:0] = rw.data;
       'h0001:
          if (rw.read) rw.data = dut.r1[15:8];
          else dut.r1[15:8] = rw.data;
       'h0002:
          if (rw.read) rw.data = dut.r1[23:16];
          else dut.r1[23:16] = rw.data;
       'h0003:
          if (rw.read) rw.data = dut.r1[31:24];
          else dut.r1[31:24] = rw.data;
      endcase
      #10;
      $write("DUT: %0s 'h%h @ 'h%h...\n", (rw.read) ? "read" : "wrote", rw.addr[7:0], rw.data[7:0]);
   endtask
endclass


class tb_env extends uvm_env;

   `uvm_component_utils(tb_env)

   my_dut             regmodel;
   reg_agent#(dut_rw) bus;

   function new(string name = "tb_env", uvm_component parent=null);
      super.new(name, parent);
   endfunction: new

   virtual function void build();
      regmodel = my_dut::type_id::create("regmodel");
      regmodel.build();
      regmodel.lock_model();

      bus = reg_agent#(dut_rw)::type_id::create("bus", this);

      regmodel.set_hdl_path_root("dut");
  endfunction: build

   virtual function void connect();
      reg2rw_adapter reg2rw  = new("reg2rw");
      regmodel.default_map.set_sequencer(bus.sqr, reg2rw);
   endfunction

endclass


class my_seq extends uvm_sequence;
   `uvm_object_utils(my_seq)

   my_dut regmodel;

   int n_pre, n_mid, n_post;

   function new(string name = "my_seq");
      super.new(name);
   endfunction


   virtual task pre_do(bit is_item);
      $write("Pre-do of %0s!\n", (is_item) ? "item" : "sequence");
      n_pre++;
   endtask

   virtual function void mid_do(uvm_sequence_item this_item);
      $write("Mid-do of %s!\n", this_item.get_type_name());
      if (this_item.get_type_name() == "uvm_reg_item" && n_mid != 0) begin
         `uvm_error("Test", $sformatf("mid-do for uvm_reg_item executed after %0d mid-do for reg_rw instead of 0", n_mid))
      end
      n_mid++;
   endfunction

   virtual function void post_do(uvm_sequence_item this_item);
      $write("Post-do of %s!\n", this_item.get_type_name());
      if (this_item.get_type_name() == "uvm_reg_item" && n_post != 4) begin
         `uvm_error("Test", $sformatf("post-do for uvm_reg_item executed after %0d post-do for reg_rw instead of 4", n_post))
      end
      n_post++;
   endfunction


   virtual task body();
      uvm_status_e   status;
      uvm_reg_data_t rdat;

      n_pre = 0;
      n_mid = 0;
      n_post = 0;
      regmodel.r1.write(status, 32'hDEADBEEF, .parent(this));
      if (n_pre != 4) begin
         `uvm_error("Test", $sformatf("Observed %0d calls to pre_do() instead of 5 on write()", n_pre))
      end
      if (n_mid != 5) begin
         `uvm_error("Test", $sformatf("Observed %0d calls to post_do() instead of 5 on write()", n_pre))
      end
      if (n_post != 5) begin
         `uvm_error("Test", $sformatf("Observed %0d calls to post_do() instead of 5 on write()", n_pre))
      end
      
      n_pre = 0;
      n_mid = 0;
      n_post = 0;
      regmodel.r1.read(status, rdat, .parent(this));
      if (n_pre != 4) begin
         `uvm_error("Test", $sformatf("Observed %0d calls to pre_do() instead of 5 on read()", n_pre))
      end
      if (n_mid != 5) begin
         `uvm_error("Test", $sformatf("Observed %0d calls to post_do() instead of 5 on read()", n_pre))
      end
      if (n_post != 5) begin
         `uvm_error("Test", $sformatf("Observed %0d calls to post_do() instead of 5 on read()", n_pre))
      end
   endtask
endclass


class test extends uvm_test;

   tb_env env;

   `uvm_component_utils(test)

   function new(string name = "tb_test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build();
     env = new("env",this);
   endfunction

   virtual task run_phase(uvm_phase phase);

      phase.raise_objection(this);

      env.regmodel.reset();
      begin
         my_seq seq = new("seq");
         seq.regmodel = env.regmodel;
         seq.start(null);
      end

      phase.drop_objection(this);
   endtask


   function void final_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
   
endclass

initial run_test();

endprogram
