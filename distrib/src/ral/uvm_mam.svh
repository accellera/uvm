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


//------------------------------------------------------------------------------
// CLASS: uvm_mam_region
// This class is used by the memory allocation manager to describe allocated memory regions.
// Instances of this class should not be created directly, therefore, this appendix does
// not document the constructor. Instances of this class should be created only from within
// the memory manager, in the "uvm_mam::reserve_region()" and "uvm_mam::request_region()"
// methods. 
//------------------------------------------------------------------------------
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


   //------------------------------------------------------------------------------
   // FUNCTION: get_len
   // Return the number of consecutive memory locations (not necessarily bytes) in the allocated
   // region. 
   //------------------------------------------------------------------------------
   extern function int unsigned get_len();

   //------------------------------------------------------------------------------
   // FUNCTION: get_n_bytes
   // Return the number of consecutive bytes in the allocated region. If the managed memory
   // contains more than one byte per address, the number of bytes in an allocated region may
   // be greater than the number of requested or reserved bytes. 
   //------------------------------------------------------------------------------
   extern function int unsigned get_n_bytes();


   //------------------------------------------------------------------------------
   // FUNCTION: psdisplay
   // Create a human-readable description of the allocated region. Each line of the description
   // is prefixed with the specified prefix. 
   //------------------------------------------------------------------------------
   extern function string psdisplay(string prefix = "");

   extern function void release_region();


   //------------------------------------------------------------------------------
   // FUNCTION: get_memory
   // Return the reference to the RAL memory abstraction class for the memory implementing
   // this allocated memory region. Returns null if no memory abstraction class was specified
   // for the allocation manager that allocated this region. 
   //------------------------------------------------------------------------------
   extern function uvm_ral_mem get_memory();

   //------------------------------------------------------------------------------
   // FUNCTION: get_virtual_registers
   // Return the reference to the RAL virtual register abstraction class for the set of virtual
   // registers implemented in the allocated region. Returns null if the memory region is
   // not known to implement virtual registers. 
   //------------------------------------------------------------------------------
   extern function uvm_ral_vreg get_virtual_registers();


   //------------------------------------------------------------------------------
   // TASK: write
   // Writes the specified value at the specified region location in the design using the
   // specified access path. If the memory is shared by more than one physical interface,
   // a domain must be specified if a physical access is used (front-door access). 
   //------------------------------------------------------------------------------
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


   //------------------------------------------------------------------------------
   // TASK: read
   // Reads the current value of the memory region location from the design using the specified
   // access path. If the memory is shared by more than one physical interface, a domain must
   // be specified if a physical access is used (front-door access). 
   //------------------------------------------------------------------------------
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


   //------------------------------------------------------------------------------
   // TASK: burst_write
   // Burst-write the specified values in the region locations specified by burst descriptor.
   // If the memory is shared by more than one physical interface, a domain must be specified
   // if a physical access is used (front-door access). 
   //------------------------------------------------------------------------------
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


   //------------------------------------------------------------------------------
   // TASK: burst_read
   // Burst-read the current values of the region locations specified by the burst descriptor.
   // If the memory is shared by more than one physical interface, a domain must be specified
   // if a physical access is used (front-door access). 
   //------------------------------------------------------------------------------
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


   //------------------------------------------------------------------------------
   // TASK: poke
   // Deposit the specified value at the specified region location in the design using a back-door
   // access. Depending on the design model implementation, it may be possible to modify
   // the content of a read-only memory. 
   //------------------------------------------------------------------------------
   extern task poke(output uvm_ral::status_e  status,
                    input  uvm_ral_addr_t     offset,
                    input  uvm_ral_data_t     value,
                    input  uvm_sequence_base  parent = null,
                    input  uvm_object         extension = null,
                    input  string             fname = "",
                    input  int                lineno = 0);


   //------------------------------------------------------------------------------
   // TASK: peek
   // Reads the current value of the region location from the design using a back-door access.
   // The optional value of the arguments: data_id scenario_id stream_id ...are passed
   // to the back-door access method. This allows the physical and back-door read access
   // to be traced back to the higher-level transaction that caused the access to occur. 
   //------------------------------------------------------------------------------
   extern task peek(output uvm_ral::status_e  status,
                    input  uvm_ral_addr_t     offset,
                    output uvm_ral_data_t     value,
                    input  uvm_sequence_base  parent = null,
                    input  uvm_object         extension = null,
                    input  string             fname = "",
                    input  int                lineno = 0);
endclass



//------------------------------------------------------------------------------
// CLASS: uvm_mam_allocator
// An instance of this class is randomized to determine the starting offset of a randomly
// allocated memory region. This class can be extended to provide additional constraints
// on the starting offset, such as word alignment or location of the region within a memory
// page. 
//------------------------------------------------------------------------------
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



//------------------------------------------------------------------------------
// CLASS: uvm_mam
// This class is a memory allocation management utility class similar to C's malloc()
// and free(). A single instance of this class is used to manage a single, contiguous address
// space. This memory allocation management class is used by any application-level process
// that requires reserved space in the memory. The section of memory (called a region)
// will remain reserved until it is explicitly released. 
//------------------------------------------------------------------------------
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


   //------------------------------------------------------------------------------
   // FUNCTION: new
   // Create an instance of a memory allocation manager with the specified name. This instance
   // manages all memory region allocation within the address range specified in the configuration
   // descriptor. If a reference to a RAL memory abstraction class is provided, the memory
   // locations within the regions can be accessed through the region descriptor, using
   // the Xref and Xref methods. The specified name is used as the instance name of the message
   // interface found in the "uvm_mam::log" class property. 
   //------------------------------------------------------------------------------
   extern function new(string      name,
                       uvm_mam_cfg cfg,
                       uvm_ral_mem mem=null);


   //------------------------------------------------------------------------------
   // FUNCTION: reconfigure
   // Optionally modify the maximum and minimum addresses of the address space managed by
   // the allocation manager, allocation mode, or locality. The number of bytes per memory
   // location cannot be modified once an allocation manager has been constructed. Returns
   // the previous configuration. All currently allocated regions must fall within the
   // new address space. 
   //------------------------------------------------------------------------------
   extern function uvm_mam_cfg reconfigure(uvm_mam_cfg cfg = null);


   //------------------------------------------------------------------------------
   // FUNCTION: reserve_region
   // Reserve a memory buffer of the specified number of bytes starting at the specified offset
   // in the memory. A descriptor of the reserved region is returned. If the specified region
   // cannot be reserved, null is returned. It may not be possible to reserve a region because
   // it overlaps with an already-allocated region or it lies outside the address range managed
   // by the memory manager. 
   //------------------------------------------------------------------------------
   extern function uvm_mam_region reserve_region(bit [63:0]   start_offset,
                                                 int unsigned n_bytes,
                                                 string       fname = "",
                                                 int          lineno = 0);

   //------------------------------------------------------------------------------
   // FUNCTION: request_region
   // Request and reserve a memory buffer of the specified number of bytes starting at a random
   // location in the memory. If an allocator is specified, it is randomized to determine
   // the start offset of the region. If no allocator is specified, the allocator found in
   // the "uvm_mam::default_alloc" class property is randomized. A descriptor of the allocated
   // region is returned. If no region can be allocated, null is returned. It may not be possible
   // to allocate a region because there is no area in the memory with enough consecutive locations
   // to meet the size requirements or because there is another contradiction when randomizing
   // the allocator. If the memory allocation is configured to uvm_mam::THRIFTY or uvm_mam::NEARBY
   // (see the "uvm_mam_cfg::mode" and "uvm_mam_cfg::locality" class properties, respectively),
   // a suitable region is first sought procedurally. If no suitable region is 
   //------------------------------------------------------------------------------
   extern function uvm_mam_region request_region(int unsigned      n_bytes,
                                                 uvm_mam_allocator alloc = null,
                                                 string            fname = "",
                                                 int               lineno = 0);

   //------------------------------------------------------------------------------
   // FUNCTION: release_region
   // Release the specified previously allocated memory region. An error is issued if the
   // specified region has not been previously allocated or is no longer allocated. 
   //------------------------------------------------------------------------------
   extern function void release_region(uvm_mam_region region);

   //------------------------------------------------------------------------------
   // FUNCTION: release_all_regions
   // Release all allocated memory regions. 
   //------------------------------------------------------------------------------
   extern function void release_all_regions();



   //------------------------------------------------------------------------------
   // FUNCTION: psdisplay
   // Create a human-readable description of the state of the memory manager and the currently
   // allocated regions. Each line of the description is prefixed with the specified prefix.
   // 
   //------------------------------------------------------------------------------
   extern function string psdisplay(string prefix = "");

   //------------------------------------------------------------------------------
   // FUNCTION: for_each
   // Iterate over all currently allocated regions. If reset is non-zero, reset the iterator
   // and return the first allocated region. Returns null when there are no additional allocated
   // regions to iterate on. 
   //------------------------------------------------------------------------------
   extern function uvm_mam_region for_each(bit reset = 0);

   //------------------------------------------------------------------------------
   // FUNCTION: get_memory
   // Return the reference to the RAL memory abstraction class for the memory implementing
   // the locations managed by this instance of the allocation manager. Returns null if no
   // memory abstraction class was specified at construction time. 
   //------------------------------------------------------------------------------
   extern function uvm_ral_mem get_memory();

endclass: uvm_mam



//------------------------------------------------------------------------------
// CLASS: uvm_mam_cfg
// This class is used to specify the memory managed by an instance of a "uvm_mam" memory
// allocation manager class. 
//------------------------------------------------------------------------------
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
