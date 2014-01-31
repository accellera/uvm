// 
// -------------------------------------------------------------
//    Copyright 2012 Accellera Systems Initiative
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

bit [7:0] mem [0:255];
  
endmodule


program test;

import uvm_pkg::*;

class mem extends uvm_mem;
  `uvm_object_utils(mem)

  function new(string name = "mem");
    super.new(name, 256, 8);
  endfunction
endclass

class my_dut extends uvm_reg_block;
  `uvm_object_utils(my_dut)

  mem mem1;   
   
  function new(string name = "my_dut");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  function void build();
    default_map = create_map("", 'h0, 1, UVM_LITTLE_ENDIAN);
    
    mem1 = mem::type_id::create("mem1",,get_full_name());
    mem1.configure(this, "");
    
    default_map.add_mem(mem1, 0);
  endfunction
endclass


`include "reg_agent.sv"

class dut_rw;
  static task rw(reg_rw rw);
    if (rw.addr >= 'h8000) begin
    end else begin
      if (rw.read) begin
        rw.data = dut.mem[rw.addr];
      end else begin
        dut.mem[rw.addr] = rw.data; 
      end
    end
    #10;
    $write("DUT: %0s 'h%h @ 'h%h...\n", (rw.read) ? "read" : "wrote", rw.addr[7:0], rw.data[7:0]);
  endtask
endclass


class tb_env extends uvm_env;
  bit use_auto_predict;
  
  `uvm_component_utils(tb_env)

  my_dut                     regmodel;
  reg_agent#(dut_rw)         bus;
  uvm_reg_predictor#(reg_rw) bus2reg_predictor;

  function new(string name = "tb_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    regmodel = my_dut::type_id::create("regmodel");
    regmodel.build();
    regmodel.lock_model();
    
    bus = reg_agent#(dut_rw)::type_id::create("bus", this);
    if (!use_auto_predict) begin
      bus2reg_predictor = new("bus2reg_predictor", this);
    end
    
    regmodel.set_hdl_path_root("dut");
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    reg2rw_adapter reg2rw; 
    super.connect_phase(phase);
    reg2rw  = new("reg2rw");
    regmodel.default_map.set_sequencer(bus.sqr, reg2rw);
    if (use_auto_predict) begin
      regmodel.default_map.set_auto_predict(1);
    end else begin
      bus2reg_predictor.map = regmodel.default_map;
      bus2reg_predictor.adapter = reg2rw;
      regmodel.default_map.set_auto_predict(0);
      bus.mon.ap.connect(bus2reg_predictor.bus_in);
    end
  endfunction
endclass

class test extends uvm_test;
  tb_env env;
  
  `uvm_component_utils(test)
  
  function new(string name = "tb_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = new("env",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    int unsigned burst_size;
    bit [7:0] val;
    uvm_status_e status;
    phase.raise_objection(this, "Waiting for sequence to finish");

    // Base write/read for seeing a hole through the system
    env.regmodel.mem1.write(status, 5, 42);
    if (status != UVM_IS_OK) `uvm_error(get_type_name(), "Return status was not UVM_IS_OK");
    env.regmodel.mem1.read(status, 5, val);
    if (status != UVM_IS_OK) `uvm_error(get_type_name(), "Return status was not UVM_IS_OK");
    if (val !== 42) `uvm_error(get_type_name(), "Return status value was");
    
    check_burst_write_read(64, 5);
    check_burst_write_read(2, 7);
    check_burst_write_read(1, 11);
    check_burst_write_read(0, 17);

    phase.drop_objection(this);
  endtask

  task check_burst_write_read(int unsigned burst_size, int unsigned offset);
    uvm_reg_data_t write_block [];
    uvm_reg_data_t read_block [];
    uvm_status_e status;

    // Burst write/read
    burst_size = 64;
    write_block = new[burst_size];
    read_block = new[burst_size];
    foreach (write_block[i]) write_block[i] = $urandom_range(255, 0);
    
    env.regmodel.mem1.burst_write(status, offset, write_block);
    if (status != UVM_IS_OK) `uvm_error(get_type_name(), "Return status was not UVM_IS_OK");
    env.regmodel.mem1.burst_read(status, offset, read_block);
    if (status != UVM_IS_OK) `uvm_error(get_type_name(), "Return status was not UVM_IS_OK");
    if (read_block.size() !== burst_size) begin
      `uvm_error(get_type_name(), $sformatf("read_block size %0d is different from burst_size %0d",
                                            read_block.size(), burst_size));
    end else begin
      for (int i = 0; i < burst_size; i++) begin
        if (write_block[i] !== read_block[i]) 
          `uvm_error(get_type_name(), $sformatf("write_block[%0d] (%h) !== read_block [%0d] (%h)", 
                                                i, write_block[i], i, read_block[i]));
      end
    end
  endtask
  
  function void final_phase(uvm_phase phase);
    uvm_coreservice_t cs_;
    uvm_report_server svr;
    cs_ = uvm_coreservice_t::get();
    svr = cs_.get_report_server();

    if (svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) == 0)
      $write("** UVM TEST PASSED **\n");
    else
      $write("!! UVM TEST FAILED !!\n");
  endfunction
  
endclass

initial run_test();

endprogram
