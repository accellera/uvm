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
// hfpb_random_mem_master
//
// A highly randomized test of a memory though the HFPB protocol.  The
// test is self checking so that the the pass/fail criteria is isolsated
// from the specifics of the randomization.
//----------------------------------------------------------------------
// begin codeblock mem_master_header
class hfpb_random_mem_master
  #(int DATA_SIZE=8, int ADDR_SIZE=16)
    extends hfpb_master_base #(DATA_SIZE, ADDR_SIZE);
// end codeblock mem_master_header

  typedef hfpb_random_mem_master #(DATA_SIZE, ADDR_SIZE) this_type;
  typedef uvm_component_registry #(this_type) type_id;

  local int unsigned max_burst_size;
  local int unsigned max_bursts;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  static function uvm_object_wrapper get_type_id();
    return type_id::get();
  endfunction

  //--------------------------------------------------------------------
  // build
  //--------------------------------------------------------------------
  function void build();

    string s;

    super.build();

// begin codeblock config
    max_burst_size = 16;
    if(!get_config_int("max_burst_size", max_burst_size)) begin
      $sformat(s, "max burst size not specified, using default of %0d", max_burst_size);
      uvm_report_warning("build", s);
    end
    $sformat(s, "max burst size: %0d", max_burst_size);
    uvm_report_info("build", s);

    max_bursts = 100;
    if(!get_config_int("max_bursts", max_bursts)) begin
      $sformat(s, "max bursts not specified, using default of %0d", max_bursts);
      uvm_report_warning("build", s);
    end
    $sformat(s, "max bursts: %0d", max_bursts);
    uvm_report_info("build", s);
// end codeblock config
    
  endfunction

  //--------------------------------------------------------------------
  // run
  //--------------------------------------------------------------------
  task run();

    int unsigned bursts;
    int unsigned size;
    int unsigned i, j;
    data_t data;

    int unsigned addr_mask = (~(~0 << ADDR_SIZE));
    int unsigned data_mask = (~(~0 << DATA_SIZE));
    addr_t addr;
    addr_t start_addr;

    data_t refq[$];
    data_t ref_data;

    string s;

    uvm_report_info("random mem master", "start");

    // randomize the number of bursts.  1 <= bursts <= max_bursts
    bursts = ($random % max_bursts) + 1;

    // For each burst, generate a stream of randomized data in a
    // contiguous section of memory.  The starting address and burst
    // size is randomized.  Store each data value in a queue.  Then,
    // read all the data back from the memory -- same starting location
    // and same burst size.  Compare the values with those in the queue.
    // Complain if there is a mismatch.

    for(int i = 0; i < bursts; i++) begin

      start_addr = $random & addr_mask;
      size = ($random % max_burst_size) + 1;
      
      // generate a bunch of writes.  Store the randomly generated data
      // into a reference queue

      addr = start_addr;
      for(j = 0; j < size; j++) begin
        data = $random & data_mask;
        refq.push_back(data);
        write_word(data, addr);
        addr++;
        #0;
      end

      // generate reads over the same address range.  Compare the data
      // read from the memory with data in the reference queue.  Print
      // an error message if there is a mismatch

      addr = start_addr;
      for(j = 0; j < size; j++) begin
        read_word(data, addr);
        ref_data = refq.pop_front();
        if(ref_data != data) begin
          $sformat(s, "reference = %0x data = %0x", ref_data, data);
          uvm_report_error("mismatch", s);
        end
        addr++;
        #0;
      end
    end

    uvm_report_info("random mem master", "finish");

    // we're done
    uvm_top.stop_request();

  endtask

endclass
