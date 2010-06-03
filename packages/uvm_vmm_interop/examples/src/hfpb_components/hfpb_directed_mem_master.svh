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

//----------------------------------------------------------------------
// hfpb_directed_mem_master
//
// exercises a memory through the HFPB protocol in a directed manner.
//----------------------------------------------------------------------
class hfpb_directed_mem_master #(int DATA_SIZE=8, int ADDR_SIZE=16)
  extends hfpb_master_base #(DATA_SIZE, ADDR_SIZE);

  typedef hfpb_directed_mem_master #(DATA_SIZE, ADDR_SIZE) this_type;
  typedef uvm_component_registry #(this_type) type_id;

  local int unsigned max_burst_size  = 16;
  local int unsigned max_bursts      = 100;

  local bit done                     = 0;
  
  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //--------------------------------------------------------------------
  // get_type_id
  //
  // This function is necessary when you use the type-based factory to
  // construct new instances of this class.  It returns the static
  // handle representing the specialization of this type.
  //--------------------------------------------------------------------
  static function uvm_object_wrapper get_type_id();
    return type_id::get();
  endfunction

  function void build();
    super.build();
    enable_stop_interrupt  = 1;
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  task run();

    int unsigned  addr;
    int unsigned max_addr =  1 << ADDR_SIZE;
    int unsigned i;
    data_t data;
    string s;
    
    $sformat(s,"max addr = %0x", max_addr);
    uvm_report_info("Master",s);

    uvm_report_info("Master", "start");

    // Fill up the memory with each memory location having its address
    // as its value.

    data  = 0;
    addr  = 0;
    for(i = 0; i < max_addr; i++) begin
      write_word(data, addr);
      data++;
      addr++;
      #0;
    end

    addr = 0;
    for(i = 0; i < max_addr; i++) begin
      read_word(data, addr);
      data++;
      addr++;
      #0;
    end

    done  = 1;
    
    uvm_report_info("Master", "finish");

  endtask

  task stop(string ph_name);
    if(ph_name == "run") begin
      uvm_report_info("Master", "initating stop");
      wait(done == 1);
      uvm_report_info("Master", "shutting down...");
    end
  endtask

endclass
