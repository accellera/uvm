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
//    permissions and limitations under t,he License.
// -------------------------------------------------------------
// 

`include "uvm_pkg.sv"

program tb;

bit [7:0] R;

import uvm_pkg::*;


class my_cb extends uvm_reg_cbs;
   virtual task pre_write(uvm_reg_item rw);
      `uvm_info("Test", "uvm_reg_cbs::pre_write() called...", UVM_NONE)
      rw.value[0] |= 8'h10;
   endtask
endclass

class my_reg extends uvm_reg;
   uvm_reg_field F;

   function new(string name = "my_reg");
      super.new(name,8,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      F = uvm_reg_field::type_id::create("F");
      F.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      
      begin
         my_cb cb = new;
         uvm_reg_cb::add(this, cb);
      end
   endfunction: build

   virtual task pre_write(uvm_reg_item rw);
      `uvm_info("Test", "uvm_reg::pre_write() called...", UVM_NONE)
      rw.value[0] |= 8'h01;
   endtask

   `uvm_object_utils(my_reg)

endclass


class my_blk extends uvm_reg_block;
   rand my_reg R;

   function new(string name = "my_blk");
      super.new(name,UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      R = my_reg::type_id::create("R");
      R.build();
      R.configure(this, null, "R");

      default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN);
      default_map.add_reg(R, 'h0, "RW");
   endfunction : build

   `uvm_object_utils(my_blk)

endclass : my_blk


class my_env extends uvm_env;

   `uvm_component_utils(my_env)

   my_blk model;
 
   function new(string name = "my_env", uvm_component parent = null);
      super.new(name, parent);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if (model == null) begin
         model = my_blk::type_id::create("model");
         model.build();
         model.set_hdl_path_root("tb");
         model.lock_model();
      end
   endfunction: build_phase

endclass: my_env


class test extends uvm_test;

   `uvm_component_utils(test)

   my_env env;

   function new(string name = "test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = my_env::type_id::create("env", this);
   endfunction
   
   virtual task run_phase(uvm_phase phase);
      uvm_reg_data_t rdat;
      uvm_status_e status;
      
      phase.raise_objection(this);

      env.model.reset();
      env.model.R.write(status, 8'h00, UVM_BACKDOOR);
      if (status != UVM_IS_OK) begin
         `uvm_error("Test", $sformatf("Cannot backdoor-write to register R: status is %p",
                                      status))
      end
      if (R != 8'h11) begin
         `uvm_error("Test", $sformatf("One of the pre-wite callback method was not called. tb.R is 'h%h instead of 'h11",
                                      R))
      end
      phase.drop_objection(this);
   endtask

   virtual function void report();
      uvm_report_server svr =  _global_reporter.get_report_server();
      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) +
          svr.get_severity_count(UVM_WARNING) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
endclass

initial run_test("test");

endprogram
