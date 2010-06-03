//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

import float_pkg::*;

//----------------------------------------------------------------------
// hfpb_float_mem_master
//----------------------------------------------------------------------
class hfpb_float_mem_master #(int DATA_SIZE=8, int ADDR_SIZE=16)
  extends hfpb_master_base #(DATA_SIZE, ADDR_SIZE);

  local int slave_id;
  local addr_t addr_base;
  local addr_t addr_limit;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    addr_map = null;
    slave_id = 0;
  endfunction

  //--------------------------------------------------------------------
  // build
  //--------------------------------------------------------------------
  function void build();

    string s;

    super.build();

    // increment threshold, thus raising an objection
    objection.set_threshold(objection.get_threshold() + 1);

    // get the slave id for the memory slave
    if(!get_config_int(mem_slave_name, slave_id)) begin
      $sformat(s, "no slave id specified for %s, using default of %0d",
               mem_slave_name, slave_id);
      uvm_report_warning("build", s);
    end

    // from the address map, determine the address range for the memory slave
    if(!addr_map.query(slave_id, addr_base, addr_limit)) begin
      addr_base = 0;
      addr_limit = ~0;
    end

    $display("slave: %s [%0d] base=%04x limit=%4x",
             mem_slave_name, slave_id, addr_base, addr_limit);

  endfunction

  //--------------------------------------------------------------------
  // incr_addr
  //
  // Utility function for incrementing and address and then ensuring
  // that the new address is within the defined address space for the
  // slave.
  //--------------------------------------------------------------------
  function addr_t incr_addr(addr_t addr, int unsigned increment = 1);
    addr += increment;
    if(addr >= addr_limit)
      addr = addr_base + (addr - addr_limit);
    if(addr < addr_base)
      addr += addr_base; 
    return addr;
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  task run();

    hfpb_tr_t req;
    hfpb_tr_t rsp;

    int unsigned bursts = ($random % 99) + 1;
    int unsigned size;
    int unsigned i, j;
    operand_t operand;

    int unsigned addr_mask = ((~(~0 << ADDR_SIZE)) >> 2) << 2;
    addr_t addr;
    addr_t start_addr;

    ieeeFloat f = new();

    uvm_report_info("mem master", "start");

    for(int i = 0; i < bursts; i++) begin

      // generate a random start address.  If we've wrapped around then
      // adjust the address so that it fits into the proper address
      // range
      start_addr = ($random & addr_mask) + addr_base;
      size = $random & 'hf;

      // generate a bunch of writes
      addr = start_addr;
      for(j = 0; j < size; j++) begin
        void'(f.gen_float());
        operand = operand_t'(f.fpack());
        write_operand(operand, addr, $bitsof(operand));
        addr = incr_addr(addr, words($bitsof(operand)));
        #0;
      end

      // generate reads over the same address range
      addr = start_addr;
      for(j = 0; j < size; j++) begin
        read_operand(operand, addr, $bitsof(operand));
        f.stuff(operand);
        addr = incr_addr(addr, words($bitsof(operand)));
        #0;
      end
    end

    // decrement threshold, thus releasing the objection
    objection.set_threshold(objection.get_threshold() - 1);

    uvm_report_info("mem master", "finish");

  endtask

endclass
