//
// -------------------------------------------------------------
//    Copyright 2004-2009 Synopsys, Inc.
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


`ifndef UVM_MAM__SV
`define UVM_MAM__SV


typedef class uvm_mam_cfg;
typedef class uvm_mam;

typedef class uvm_ral_mem;
typedef class uvm_ral_mem_burst;

class uvm_mam_region;
   /*local*/ bit [63:0] Xstart_offsetX;  // Can't be local since function
   /*local*/ bit [63:0] Xend_offsetX;    // calls not supported in constraints

   local int unsigned len;
   local int unsigned n_bytes;
   local uvm_mam      parent;
   local string       fname = "";
   local int          lineno = 0;

   /*local*/ uvm_ral_vreg XvregX;

   extern /*local*/ function new(bit [63:0]   start_offset,
                                 bit [63:0]   end_offset,
                                 int unsigned len,
                                 int unsigned n_bytes,
                                 uvm_mam      parent);

   extern function bit [63:0] get_start_offset();
   extern function bit [63:0] get_end_offset();

   extern function int unsigned get_len();
   extern function int unsigned get_n_bytes();

   extern function string psdisplay(string prefix = "");

   extern function void release_region();

   extern function uvm_ral_mem get_memory();
   extern function uvm_ral_vreg get_virtual_registers();

   extern task write(output uvm_ral::status_e  status,
                     input  uvm_ral_addr_t     offset,
                     input  uvm_ral_data_t     value,
                     input  uvm_ral::path_e    path   = uvm_ral::DEFAULT,
                     input  uvm_ral_map        map    = null,
                     input  uvm_sequence_base  parent = null,
                     input  int                prior = -1,
                     input  uvm_object         extension = null,
                     input  string             fname = "",
                     input  int                lineno = 0);

   extern task read(output uvm_ral::status_e  status,
                    input  uvm_ral_addr_t     offset,
                    output uvm_ral_data_t     value,
                    input  uvm_ral::path_e    path   = uvm_ral::DEFAULT,
                    input  uvm_ral_map        map    = null,
                    input  uvm_sequence_base  parent = null,
                    input  int                prior = -1,
                    input  uvm_object         extension = null,
                    input  string             fname = "",
                    input  int                lineno = 0);

   extern task burst_write(output uvm_ral::status_e  status,
                           input  uvm_ral_mem_burst  burst,
                           input  uvm_ral_data_t     value[],
                           input  uvm_ral::path_e    path   = uvm_ral::DEFAULT,
                           input  uvm_ral_map        map    = null,
                           input  uvm_sequence_base  parent = null,
                           input  int                prior = -1,
                           input  uvm_object         extension = null,
                           input  string             fname = "",
                           input  int                lineno = 0);

   extern task burst_read(output uvm_ral::status_e  status,
                          input  uvm_ral_mem_burst  burst,
                          output uvm_ral_data_t     value[],
                          input  uvm_ral::path_e    path   = uvm_ral::DEFAULT,
                          input  uvm_ral_map        map    = null,
                          input  uvm_sequence_base  parent = null,
                          input  int                prior = -1,
                          input  uvm_object         extension = null,
                          input  string             fname = "",
                          input  int                lineno = 0);

   extern task poke(output uvm_ral::status_e  status,
                    input  uvm_ral_addr_t     offset,
                    input  uvm_ral_data_t     value,
                    input  uvm_sequence_base  parent = null,
                    input  uvm_object         extension = null,
                    input  string             fname = "",
                    input  int                lineno = 0);

   extern task peek(output uvm_ral::status_e  status,
                    input  uvm_ral_addr_t     offset,
                    output uvm_ral_data_t     value,
                    input  uvm_sequence_base  parent = null,
                    input  uvm_object         extension = null,
                    input  string             fname = "",
                    input  int                lineno = 0);
endclass


class uvm_mam_allocator;
   int unsigned len;

   rand bit [63:0] start_offset;

   bit [63:0] min_offset;
   bit [63:0] max_offset;

   uvm_mam_region in_use[$];

   constraint vmam_mam_allocator_valid {
      start_offset >= min_offset;
      start_offset <= max_offset - len + 1;
   }

   constraint vmam_mam_allocator_no_overlap {
      foreach (in_use[i]) {
         !(start_offset <= in_use[i].Xend_offsetX &&
           start_offset + len - 1 >= in_use[i].Xstart_offsetX);
      }
   }

endclass


class uvm_mam;

   typedef enum {GREEDY, THRIFTY} alloc_mode_e;
   typedef enum {BROAD, NEARBY}   locality_e;

   local uvm_mam_cfg cfg;

   uvm_mam_allocator default_alloc;
   local uvm_ral_mem memory;

   local uvm_mam_region in_use[$];
   local int for_each_idx = -1;
   local string fname = "";
   local int lineno = 0;

   extern function new(string      name,
                       uvm_mam_cfg cfg,
                       uvm_ral_mem mem=null);

   extern function uvm_mam_cfg reconfigure(uvm_mam_cfg cfg = null);

   extern function uvm_mam_region reserve_region(bit [63:0]   start_offset,
                                                 int unsigned n_bytes,
                                                 string       fname = "",
                                                 int          lineno = 0);
   extern function uvm_mam_region request_region(int unsigned      n_bytes,
                                                 uvm_mam_allocator alloc = null,
                                                 string            fname = "",
                                                 int               lineno = 0);
   extern function void release_region(uvm_mam_region region);
   extern function void release_all_regions();


   extern function string psdisplay(string prefix = "");
   extern function uvm_mam_region for_each(bit reset = 0);
   extern function uvm_ral_mem get_memory();

endclass: uvm_mam


class uvm_mam_cfg;
   rand int unsigned n_bytes;

   rand bit [63:0] start_offset;
   rand bit [63:0] end_offset;

   rand uvm_mam::alloc_mode_e mode;
   rand uvm_mam::locality_e   locality;

   constraint uvm_mam_cfg_valid {
      end_offset > start_offset;
      n_bytes < 64;
   }
endclass



//------------------------------------------------------------------
//
//  Implementation
//

function uvm_mam_region::new(bit [63:0] start_offset,
                             bit [63:0] end_offset,
                             int unsigned len,
                             int unsigned n_bytes,
                             uvm_mam      parent);
   this.Xstart_offsetX = start_offset;
   this.Xend_offsetX   = end_offset;
   this.len            = len;
   this.n_bytes        = n_bytes;
   this.parent         = parent;
   this.XvregX         = null;
endfunction: new


function bit [63:0] uvm_mam_region::get_start_offset();
   return this.Xstart_offsetX;
endfunction: get_start_offset


function bit [63:0] uvm_mam_region::get_end_offset();
   return this.Xend_offsetX;
endfunction: get_end_offset


function int unsigned uvm_mam_region::get_len();
   return this.len;
endfunction: get_len


function int unsigned uvm_mam_region::get_n_bytes();
   return this.n_bytes;
endfunction: get_n_bytes


function string uvm_mam_region::psdisplay(string prefix = "");
   $sformat(psdisplay, "%s['h%h:'h%h]", prefix,
            this.Xstart_offsetX, this.Xend_offsetX);
endfunction: psdisplay


function void uvm_mam_region::release_region();
   this.parent.release_region(this);
endfunction


function uvm_ral_mem uvm_mam_region::get_memory();
   return this.parent.get_memory();
endfunction: get_memory


function uvm_ral_vreg uvm_mam_region::get_virtual_registers();
   return this.XvregX;
endfunction: get_virtual_registers


function uvm_mam::new(string      name,
                      uvm_mam_cfg cfg,
                      uvm_ral_mem mem = null);
   this.cfg           = cfg;
   this.memory        = mem;
   this.default_alloc = new;
endfunction: new


function uvm_mam_cfg uvm_mam::reconfigure(uvm_mam_cfg cfg = null);
   if (cfg == null) return this.cfg;

   // Cannot reconfigure n_bytes
   if (cfg.n_bytes !== this.cfg.n_bytes) begin
      uvm_top.uvm_report_error("uvm_mam",
                 $psprintf("Cannot reconfigure Memory Allocation Manager with a different number of bytes (%0d !== %0d)",
                           cfg.n_bytes, this.cfg.n_bytes), UVM_LOW);
      return this.cfg;
   end

   // All currently allocated regions must fall within the new space
   foreach (this.in_use[i]) begin
      if (this.in_use[i].get_start_offset() < cfg.start_offset ||
          this.in_use[i].get_end_offset() > cfg.end_offset) begin
         uvm_top.uvm_report_error("uvm_mam",
                    $psprintf("Cannot reconfigure Memory Allocation Manager with a currently allocated region outside of the managed address range ([%0d:%0d] outside of [%0d:%0d])",
                              this.in_use[i].get_start_offset(),
                              this.in_use[i].get_end_offset(),
                              cfg.start_offset, cfg.end_offset), UVM_LOW);
         return this.cfg;
      end
   end

   reconfigure = this.cfg;
   this.cfg = cfg;
endfunction: reconfigure


function uvm_mam_region uvm_mam::reserve_region(bit [63:0]   start_offset,
                                                int unsigned n_bytes,
                                                string       fname = "",
                                                int          lineno = 0);
   bit [63:0] end_offset;
   this.fname = fname;
   this.lineno = lineno;
   if (n_bytes == 0) begin
      `uvm_error("RAL", "Cannot reserve 0 bytes");
      return null;
   end

   if (start_offset < this.cfg.start_offset) begin
      `uvm_error("RAL", $psprintf("Cannot reserve before start of memory space: 'h%h < 'h%h",
                                     start_offset, this.cfg.start_offset));
      return null;
   end

   end_offset = start_offset + ((n_bytes-1) / this.cfg.n_bytes);
   n_bytes = (end_offset - start_offset + 1) * this.cfg.n_bytes;

   if (end_offset > this.cfg.end_offset) begin
      `uvm_error("RAL", $psprintf("Cannot reserve past end of memory space: 'h%h > 'h%h",
                                     end_offset, this.cfg.end_offset));
      return null;
   end
    
    `uvm_info("RAL",$psprintf("Attempting to reserve ['h%h:'h%h]...",start_offset, end_offset),UVM_MEDIUM)




   foreach (this.in_use[i]) begin
      if (start_offset <= this.in_use[i].get_end_offset() &&
          end_offset >= this.in_use[i].get_start_offset()) begin
         // Overlap!
         `uvm_error("RAL", $psprintf("Cannot reserve ['h%h:'h%h] because it overlaps with %s",
                                        start_offset, end_offset,
                                        this.in_use[i].psdisplay()));
         return null;
      end

      // Regions are stored in increasing start offset
      if (start_offset > this.in_use[i].get_start_offset()) begin
         reserve_region = new(start_offset, end_offset,
                              end_offset - start_offset + 1, n_bytes, this);
         this.in_use.insert(i, reserve_region);
         return reserve_region;
      end
   end

   reserve_region = new(start_offset, end_offset,
                        end_offset - start_offset + 1, n_bytes, this);
   this.in_use.push_back(reserve_region);
endfunction: reserve_region


function uvm_mam_region uvm_mam::request_region(int unsigned      n_bytes,
                                                uvm_mam_allocator alloc = null,
                                                string            fname = "",
                                                int               lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   if (alloc == null) alloc = this.default_alloc;

   alloc.len        = (n_bytes-1) / this.cfg.n_bytes + 1;
   alloc.min_offset = this.cfg.start_offset;
   alloc.max_offset = this.cfg.end_offset;
   alloc.in_use     = this.in_use;

   if (!alloc.randomize()) begin
      `uvm_error("RAL", "Unable to randomize allocator");
      return null;
   end

   return reserve_region(alloc.start_offset, n_bytes);
endfunction: request_region


function void uvm_mam::release_region(uvm_mam_region region);

   if (region == null) return;

   foreach (this.in_use[i]) begin
      if (this.in_use[i] == region) begin
         this.in_use.delete(i);
         return;
      end
   end
   `uvm_error("RAL", region.psdisplay("Attempting to release unallocated region "));
endfunction: release_region


function void uvm_mam::release_all_regions();
`ifdef VCS2006_06
   // Work-around for NYI feature in VCS2006.06
   // but IEEE 1800-2009 compliant
   this.in_use.delete();
`else
   // Works in VCS2008.03 or later
   // IEEE 1800-2005 compliant
   this.in_use = '{};
`endif
endfunction: release_all_regions


function string uvm_mam::psdisplay(string prefix = "");
   $sformat(psdisplay, "%sAllocated memory regions:\n", prefix);
   foreach (this.in_use[i]) begin
      $sformat(psdisplay, "%s%s   %s\n", psdisplay, prefix,
               this.in_use[i].psdisplay());
   end
endfunction: psdisplay


function uvm_mam_region uvm_mam::for_each(bit reset = 0);
   if (reset) this.for_each_idx = -1;

   this.for_each_idx++;

   if (this.for_each_idx >= this.in_use.size()) begin
      return null;
   end

   return this.in_use[this.for_each_idx];
endfunction: for_each


function uvm_ral_mem uvm_mam::get_memory();
   return this.memory;
endfunction: get_memory


task uvm_mam_region::write(output uvm_ral::status_e  status,
                           input  uvm_ral_addr_t     offset,
                           input  uvm_ral_data_t     value,
                           input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                           input  uvm_ral_map        map    = null,
                           input  uvm_sequence_base  parent = null,
                           input  int                prior = -1,
                           input  uvm_object         extension = null,
                           input  string             fname = "",
                           input  int                lineno = 0);

   uvm_ral_mem mem = this.parent.get_memory();
   this.fname = fname;
   this.lineno = lineno;

   if (mem == null) begin
      `uvm_error("RAL", "Cannot use uvm_mam_region::write() on a region that was allocated by a Memory Allocation Manager that was not associated with a uvm_ral_mem instance");
      status = uvm_ral::ERROR;
      return;
   end

   if (offset > this.len) begin
      `uvm_error("RAL",
                 $psprintf("Attempting to write to an offset outside of the allocated region (%0d > %0d)",
                           offset, this.len));
      status = uvm_ral::ERROR;
      return;
   end

   mem.write(status, offset + this.get_start_offset(), value,
            path, map, parent, prior, extension);
endtask: write


task uvm_mam_region::read(output uvm_ral::status_e  status,
                          input  uvm_ral_addr_t     offset,
                          output uvm_ral_data_t     value,
                          input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                          input  uvm_ral_map        map    = null,
                          input  uvm_sequence_base  parent = null,
                          input  int                prior = -1,
                          input  uvm_object         extension = null,
                          input  string             fname = "",
                          input  int                lineno = 0);
   uvm_ral_mem mem = this.parent.get_memory();
   this.fname = fname;
   this.lineno = lineno;

   if (mem == null) begin
      `uvm_error("RAL", "Cannot use uvm_mam_region::read() on a region that was allocated by a Memory Allocation Manager that was not associated with a uvm_ral_mem instance");
      status = uvm_ral::ERROR;
      return;
   end

   if (offset > this.len) begin
      `uvm_error("RAL",
                 $psprintf("Attempting to read from an offset outside of the allocated region (%0d > %0d)",
                           offset, this.len));
      status = uvm_ral::ERROR;
      return;
   end

   mem.read(status, offset + this.get_start_offset(), value,
            path, map, parent, prior, extension);
endtask: read


task uvm_mam_region::burst_write(output uvm_ral::status_e  status,
                                 input  uvm_ral_mem_burst  burst,
                                 input  uvm_ral_data_t     value[],
                                 input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                                 input  uvm_ral_map        map    = null,
                                 input  uvm_sequence_base  parent = null,
                                 input  int                prior = -1,
                                 input  uvm_object         extension = null,
                                 input  string             fname = "",
                                 input  int                lineno = 0);
   uvm_ral_mem mem = this.parent.get_memory();
   this.fname = fname;
   this.lineno = lineno;

   if (mem == null) begin
      `uvm_error("RAL", "Cannot use uvm_mam_region::burst_write() on a region that was allocated by a Memory Allocation Manager that was not associated with a uvm_ral_mem instance");
      status = uvm_ral::ERROR;
      return;
   end

   if (burst.start_offset > this.len ||
       burst.max_offset   > this.len) begin
      `uvm_error("RAL",
                 $psprintf("Attempting to burst-write to an offset outside of the allocated region ([%0d:%0d] > %0d)",
                           burst.start_offset, burst.max_offset, this.len));
      status = uvm_ral::ERROR;
      return;
   end

   begin
      uvm_ral_mem_burst b = new burst;
      b.start_offset += this.get_start_offset();
      b.max_offset   += this.get_start_offset();

      mem.burst_write(status, b, value,
                      path, map,
                      parent, prior, extension);
   end
endtask: burst_write


task uvm_mam_region::burst_read(output uvm_ral::status_e  status,
                                input  uvm_ral_mem_burst  burst,
                                output uvm_ral_data_t     value[],
                                input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                                input  uvm_ral_map        map    = null,
                                input  uvm_sequence_base  parent = null,
                                input  int                prior = -1,
                                input  uvm_object         extension = null,
                                input  string             fname = "",
                                input  int                lineno = 0);
   uvm_ral_mem mem = this.parent.get_memory();
   this.fname = fname;
   this.lineno = lineno;

   if (mem == null) begin
      `uvm_error("RAL", "Cannot use uvm_mam_region::burst_read() on a region that was allocated by a Memory Allocation Manager that was not associated with a uvm_ral_mem instance");
      status = uvm_ral::ERROR;
      return;
   end

   if (burst.start_offset > this.len ||
       burst.max_offset   > this.len) begin
      `uvm_error("RAL",
                 $psprintf("Attempting to burst-read from an offset outside of the allocated region ([%0d:%0d] > %0d)",
                           burst.start_offset, burst.max_offset, this.len));
      status = uvm_ral::ERROR;
      return;
   end

   begin
      uvm_ral_mem_burst b = new burst;
      b.start_offset += this.get_start_offset();
      b.max_offset   += this.get_start_offset();

      mem.burst_read(status, b, value,
                     path, map,
                     parent, prior, extension);
   end
endtask: burst_read


task uvm_mam_region::poke(output uvm_ral::status_e  status,
                          input  uvm_ral_addr_t     offset,
                          input  uvm_ral_data_t     value,
                          input  uvm_sequence_base  parent = null,
                          input  uvm_object         extension = null,
                          input  string             fname = "",
                          input  int                lineno = 0);
   uvm_ral_mem mem = this.parent.get_memory();
   this.fname = fname;
   this.lineno = lineno;

   if (mem == null) begin
      `uvm_error("RAL", "Cannot use uvm_mam_region::poke() on a region that was allocated by a Memory Allocation Manager that was not associated with a uvm_ral_mem instance");
      status = uvm_ral::ERROR;
      return;
   end

   if (offset > this.len) begin
      `uvm_error("RAL",
                 $psprintf("Attempting to poke to an offset outside of the allocated region (%0d > %0d)",
                           offset, this.len));
      status = uvm_ral::ERROR;
      return;
   end

   mem.poke(status, offset + this.get_start_offset(), value, "", parent, extension);
endtask: poke


task uvm_mam_region::peek(output uvm_ral::status_e  status,
                          input  uvm_ral_addr_t     offset,
                          output uvm_ral_data_t     value,
                          input  uvm_sequence_base  parent = null,
                          input  uvm_object         extension = null,
                          input  string             fname = "",
                          input  int                lineno = 0);
   uvm_ral_mem mem = this.parent.get_memory();
   this.fname = fname;
   this.lineno = lineno;

   if (mem == null) begin
      `uvm_error("RAL", "Cannot use uvm_mam_region::peek() on a region that was allocated by a Memory Allocation Manager that was not associated with a uvm_ral_mem instance");
      status = uvm_ral::ERROR;
      return;
   end

   if (offset > this.len) begin
      `uvm_error("RAL",
                 $psprintf("Attempting to peek from an offset outside of the allocated region (%0d > %0d)",
                           offset, this.len));
      status = uvm_ral::ERROR;
      return;
   end

   mem.peek(status, offset + this.get_start_offset(), value, "", parent, extension);
endtask: peek


`endif  // UVM_MAM__SV
