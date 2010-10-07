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


typedef class uvm_mam_region;
typedef class uvm_mam;



//------------------------------------------------------------------------------
// CLASS: uvm_ral_vreg_cbs
// Base class for virtual register descriptors. 
//------------------------------------------------------------------------------
class uvm_ral_vreg_cbs extends uvm_callback;
   string fname = "";
   int    lineno = 0;

   function new(string name = "uvm_ral_reg_cbs");
      super.new(name);
   endfunction
   

   //------------------------------------------------------------------------------
   // TASK: pre_write
   // This callback method is invoked before a value is written to a virtual register in the
   // DUT. The written value, if modified, changes the actual value that is written. The path
   // and domain used to write to the register can also be modified. This callback method is
   // only invoked when the "uvm_ral_vreg::write()" method is used to write to the register
   // inside the DUT. This callback method is not invoked when the memory location implementing
   // a virtual register, is written to using the "uvm_ral_mem::write()" method. Because
   // writing a register causes all of the fields it contains to be written, all registered
   // "uvm_ral_vfield_cbs::pre_write()" methods with the fields contained in the register
   // will also be invoked before all registered register callback methods. Because the
   // memory implementing the virtual field is accessed through its own abstraction class,
   // all of its registered "uvm_ral_mem_cbs::pre_write()" methods will also be invoked
   // as a side effect. 
   //------------------------------------------------------------------------------
   virtual task pre_write(uvm_ral_vreg         rg,
                          longint unsigned     idx,
                          ref uvm_ral_data_t   wdat,
                          ref uvm_ral::path_e  path,
                          ref uvm_ral_map   map);
   endtask: pre_write


   //------------------------------------------------------------------------------
   // TASK: post_write
   // This callback method is invoked after a value is successfully written to a register
   // in the DUT. If a physical write access did not return uvm_rw::IS_OK, this method is not
   // called. This callback method is only invoked when the "uvm_ral_vreg::write()" method
   // is used to write to the register inside the DUT. This callback method is not invoked when
   // the memory location implementing a virtual register, is written to using the "uvm_ral_mem::write()"
   // method. Because writing a register causes all of the fields it contains to be written,
   // all registered "uvm_ral_vfield_cbs::post_write()" methods with the fields contained
   // in the register will also be invoked before all registered register callback methods.
   // Because the memory implementing the virtual field is accessed through its own abstraction
   // class, all of its registered "uvm_ral_mem_cbs::post_write()" methods will also
   // be invoked as a side effect. 
   //------------------------------------------------------------------------------
   virtual task post_write(uvm_ral_vreg           rg,
                           longint unsigned       idx,
                           uvm_ral_data_t         wdat,
                           uvm_ral::path_e        path,
                           uvm_ral_map         map,
                           ref uvm_ral::status_e  status);
   endtask: post_write


   //------------------------------------------------------------------------------
   // TASK: pre_read
   // This callback method is invoked before a value is read from a register in the DUT. The
   // path and domain used to read the register can be modified. This callback method is only
   // invoked when the "uvm_ral_vreg::read()" method is used to read to the register inside
   // the DUT. This callback method is not invoked when the memory location implementing
   // a virtual register, is read to using the "uvm_ral_mem::read()" method. Because reading
   // a register causes all of the fields it contains to be written, all registered "uvm_ral_vfield_cbs::pre_read()"
   // methods with the fields contained in the register will also be invoked before all registered
   // register callback methods. Because the memory implementing the virtual field is accessed
   // through its own abstraction class, all of its registered "uvm_ral_mem_cbs::pre_read()"
   // methods will also be invoked as a side effect. 
   //------------------------------------------------------------------------------
   virtual task pre_read(uvm_ral_vreg         rg,
                         longint unsigned     idx,
                         ref uvm_ral::path_e  path,
                         ref uvm_ral_map   map);
   endtask: pre_read


   //------------------------------------------------------------------------------
   // TASK: post_read
   // This callback method is invoked after a value is successfully read from a register in
   // the DUT. The rdat and status values are the values that will be ultimately returned by
   // the "uvm_ral_vreg::read()" method and can be modified. If a physical read access did
   // not return uvm_rw::IS_OK, this method is not called. This callback method is only invoked
   // when the "uvm_ral_vreg::read()" method is used to read to the register inside the DUT.
   // This callback method is not invoked when the memory location implementing a virtual
   // register, is read to using the "uvm_ral_mem::read()" method. Because reading a register
   // causes all of the fields it contains to be written, all registered "uvm_ral_vfield_cbs::post_read()"
   // methods with the fields contained in the register will also be invoked before all registered
   // register callback methods. Because the memory 
   //------------------------------------------------------------------------------
   virtual task post_read(uvm_ral_vreg           rg,
                          longint unsigned       idx,
                          ref uvm_ral_data_t     rdat,
                          input uvm_ral::path_e  path,
                          input uvm_ral_map   map,
                          ref uvm_ral::status_e  status);
   endtask: post_read
endclass: uvm_ral_vreg_cbs
typedef uvm_callbacks#(uvm_ral_vreg, uvm_ral_vreg_cbs) uvm_ral_vreg_cb;
typedef uvm_callback_iter#(uvm_ral_vreg, uvm_ral_vreg_cbs) uvm_ral_vreg_cb_iter;



//------------------------------------------------------------------------------
// CLASS: uvm_ral_vreg
// Base class for virtual register descriptors. 
//------------------------------------------------------------------------------
class uvm_ral_vreg extends uvm_object;

   `uvm_register_cb(uvm_ral_vreg, uvm_ral_vreg_cbs)

   virtual task pre_write(longint unsigned     idx,
                          ref uvm_ral_data_t   wdat,
                          ref uvm_ral::path_e  path,
                          ref uvm_ral_map   map);
   endtask: pre_write

   virtual task post_write(longint unsigned       idx,
                           uvm_ral_data_t         wdat,
                           uvm_ral::path_e        path,
                           uvm_ral_map         map,
                           ref uvm_ral::status_e  status);
   endtask: post_write

   virtual task pre_read(longint unsigned     idx,
                         ref uvm_ral::path_e  path,
                         ref uvm_ral_map   map);
   endtask: pre_read

   virtual task post_read(longint unsigned       idx,
                          ref uvm_ral_data_t     rdat,
                          input uvm_ral::path_e  path,
                          input uvm_ral_map   map,
                          ref uvm_ral::status_e  status);
   endtask: post_read

   local bit locked;
   local uvm_ral_block parent;
   local int unsigned  n_bits;
   local int unsigned  n_used_bits;

   local uvm_ral_vfield fields[$];   // Fields in LSB to MSB order

   local uvm_ral_mem                   mem;     // Where is it implemented?
   local uvm_ral_addr_t                offset;  // Start of vreg[0]
   local int unsigned                  incr;    // From start to start of next
   local longint unsigned              size;    //number of vregs
   local bit                           is_static;

   local uvm_mam_region   region;    // Not NULL if implemented via MAM
  
   local semaphore atomic;   // Field RMW operations must be atomic
   local string fname = "";
   local int lineno = 0;
   local bit read_in_progress;
   local bit write_in_progress;

   extern /*local*/ function new(string name);

   extern /*local*/ function void configure(uvm_ral_block     parent,
                                            int unsigned      n_bits,
                                            uvm_ral_addr_t    offset = 0,
                                            uvm_ral_mem       mem    = null,
                                            longint unsigned  size   = 0,
                                            int unsigned      incr   = 0);


   /*local*/ extern function void Xlock_modelX();
   
   /*local*/ extern function void add_field(uvm_ral_vfield field);
   /*local*/ extern task XatomicX(bit on);
   
   extern function void reset(uvm_ral::reset_e kind = uvm_ral::HARD);

   extern virtual function string get_full_name();
   extern virtual function uvm_ral_block get_parent();
   extern virtual function void set_parent(uvm_ral_block parent);

   //------------------------------------------------------------------------------
   // FUNCTION: get_block
   // Returns a reference to the descriptor of the block that includes the register corresponding
   // to the descriptor instance. 
   //------------------------------------------------------------------------------
   extern virtual function uvm_ral_block get_block();


   //------------------------------------------------------------------------------
   // FUNCTION: implement
   // Dynamically implement, resize or relocate a set of virtual registers of the specified
   // size, in the specified memory and offset. If an offset increment is specified, each
   // virtual register is implemented at the specified offset from the previous one. If an
   // offset increment of 0 is specified, virtual registers are packed as closely as possible
   // in the memory. If no memory is specified, the virtual register set is in the same memory,
   // at the same offset using the same offset increment as originally implemented. The initial
   // value of the newly-implemented or relocated set of virtual registers is whatever values
   // are currently stored in the memory now implementing them. Returns TRUE if the memory
   // can implement the number of virtual registers at the specified offset and increment.
   // Returns FALSE if the memory cannot implement the specified virtual register set. The
   // memory region used to implement a set of virtual registers is reserved to prevent it
   // from being allocated for another purpose by the memory's default memory allocation
   // manager. 
   //------------------------------------------------------------------------------
   extern virtual function bit implement(longint unsigned              n,
                                         uvm_ral_mem                   mem    = null,
                                         uvm_ral_addr_t  offset = 0,
                                         int unsigned                  incr   = 0);

   //------------------------------------------------------------------------------
   // FUNCTION: allocate
   // Dynamically implement, resize or relocate a set of virtual registers of the specified
   // size to a randomly allocated region of the appropriate size in the address space managed
   // by the specified memory allocation manager. The initial value of the newly-implemented
   // or relocated set of virtual registers is whatever values are currently stored in the
   // memory region now implementing them. Returns a reference to a memory region descriptor
   // if the memory allocation manager was able to allocate a region that can implement the
   // number of virtual registers. Returns null if the memory allocation manager cannot
   // allocate a suitable region. Statically-implemented virtual registers cannot be
   // implemented, resized nor relocated. 
   //------------------------------------------------------------------------------
   extern virtual function uvm_mam_region allocate(longint unsigned n,
                                                   uvm_mam          mam);

   //------------------------------------------------------------------------------
   // FUNCTION: get_region
   // Returns a reference to a memory region descriptor that implements the set of virtual
   // registers. Returns null if the virtual registers are not currently implemented. A
   // region implementing a set of virtual registers must not be released using the uvm_mam::release_region()
   // method. It must be released using the "uvm_ral_vreg::release_region()" method.
   // 
   //------------------------------------------------------------------------------
   extern virtual function uvm_mam_region get_region();

   //------------------------------------------------------------------------------
   // FUNCTION: release_region
   // Release the memory region used to implement the set of virtual registers and return
   // it to the pool of available memory that can be allocated by the memory's default allocation
   // manager. The virtual registers are subsequently considered as unimplemented and
   // can no longer be accessed. Statically-implemented virtual registers cannot be released.
   // 
   //------------------------------------------------------------------------------
   extern virtual function void release_region();


   //------------------------------------------------------------------------------
   // FUNCTION: get_memory
   // Returns a reference to the memory abstraction class for the memory that implements
   // the set of virtual registers corresponding to the descriptor instance. 
   //------------------------------------------------------------------------------
   extern virtual function uvm_ral_mem get_memory();
   extern virtual function int get_n_maps();
   extern virtual function void get_maps(ref uvm_ral_map maps[$]);
   extern virtual function bit is_in_map(uvm_ral_map map);

   //------------------------------------------------------------------------------
   // FUNCTION: get_access
   // Returns the specification of the behavior of the memory used to implement the set of
   // virtual register when written and read. If the memory is shared across more than one
   // domain, a domain name must be specified. If access restrictions are present when accessing
   // a memory through the specified domain, the access mode returned takes the access restrictions
   // into account. For example, a read-write memory accessed through a domain with read-only
   // restrictions would return uvm_ral::RO. 
   //------------------------------------------------------------------------------
   extern virtual function string get_access(uvm_ral_map map = null);

   //------------------------------------------------------------------------------
   // FUNCTION: get_rights
   // Returns the access rights of the memory implementing this set of virtual registers.
   // Returns uvm_ral::RW, uvm_ral::RO or uvm_ral::WO. See "uvm_ral_mem::get_rights()"
   // for more details. If the memory implementing this set of virtual registers is shared
   // in more than one domain, a domain name must be specified. If the memory is not shared in
   // the specified domain, an error message is issued and uvm_ral::RW is returned. 
   //------------------------------------------------------------------------------
   extern virtual function string get_rights(uvm_ral_map map = null);

   //------------------------------------------------------------------------------
   // FUNCTION: get_offset_in_memory
   // Returns the offset of the virtual register in the overall address space of the memory
   // that implements it. If the virtual register occupies more than one memory location,
   // the lowest offset value is returned. 
   //------------------------------------------------------------------------------
   extern virtual function uvm_ral_addr_t  get_offset_in_memory(longint unsigned idx);

   extern virtual function uvm_ral_addr_t  get_external_address(longint unsigned idx,
                                                                uvm_ral_map map = null);


   //------------------------------------------------------------------------------
   // FUNCTION: get_size
   // Returns the number of virtual registers in the virtual register array. 
   //------------------------------------------------------------------------------
   extern virtual function int unsigned get_size();

   //------------------------------------------------------------------------------
   // FUNCTION: get_n_bytes
   // Returns the width, in number of bytes, of the virtual register. The width of a virtual
   // register is always a multiple of the width of the memory locations used to implement
   // it. For example, a virtual register containing two 1-byte fields implemented in a memory
   // with 4-bytes memory locations is 4-byte wide. 
   //------------------------------------------------------------------------------
   extern virtual function int unsigned get_n_bytes();

   //------------------------------------------------------------------------------
   // FUNCTION: get_n_memlocs
   // Returns the number of memory locations used by a single virtual register. 
   //------------------------------------------------------------------------------
   extern virtual function int unsigned get_n_memlocs();

   //------------------------------------------------------------------------------
   // FUNCTION: get_incr
   // Returns the number of memory locations between two individual virtual registers in
   // the same array. 
   //------------------------------------------------------------------------------
   extern virtual function int unsigned get_incr();


   //------------------------------------------------------------------------------
   // FUNCTION: get_fields
   // Fills the specified dynamic array with the descriptor for all of the virtual fields
   // contained in the virtual register. Fields are ordered from least-significant position
   // to most-significant position within the register. 
   //------------------------------------------------------------------------------
   extern virtual function void get_fields(ref uvm_ral_vfield fields[$]);

   //------------------------------------------------------------------------------
   // FUNCTION: get_field_by_name
   // Finds a virtual field with the specified name in the register and returns its descriptor.
   // If no fields are found, returns null. 
   //------------------------------------------------------------------------------
   extern virtual function uvm_ral_vfield get_field_by_name(string name);


   //------------------------------------------------------------------------------
   // TASK: write
   // Writes the specified value in the specified virtual register in the design using the
   // specified access path. If the memory implementing the virtual register is shared by
   // more than one physical interface, a domain must be specified if a physical access is
   // used (front-door access). The optional value of the arguments: data_id scenario_id
   // stream_id ...are passed to the back-door access method or used to set the corresponding
   // uvm_data class properties in the "uvm_rw_access" transaction descriptors that are
   // necessary to execute this write operation. This allows the physical and back-door
   // write accesses to be traced back to the higher-level transaction that caused the access
   // to occur. 
   //------------------------------------------------------------------------------
   extern virtual task write(input  longint unsigned   idx,
                             output uvm_ral::status_e  status,
                             input  uvm_ral_data_t     value,
                             input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                             input  uvm_ral_map     map = null,
                             input  uvm_sequence_base  parent = null,
                             input  uvm_object         extension = null,
                             input  string             fname = "",
                             input  int                lineno = 0);

   //------------------------------------------------------------------------------
   // TASK: read
   // Reads the current value of the specified virtual register from the design using the
   // specified access path. If the memory implementing the virtual register is shared by
   // more than one physical interface, a domain must be specified if a physical access is
   // used (front-door access). The optional value of the arguments: data_id scenario_id
   // stream_id ...are passed to the back-door access method or used to set the corresponding
   // uvm_data class properties in the "uvm_rw_access" transaction descriptors that are
   // necessary to execute this read operation. This allows the physical and back-door read
   // accesses to be traced back to the higher-level transaction that caused the access to
   // occur. 
   //------------------------------------------------------------------------------
   extern virtual task read(input  longint unsigned    idx,
                            output uvm_ral::status_e   status,
                            output uvm_ral_data_t      value,
                            input  uvm_ral::path_e     path = uvm_ral::DEFAULT,
                            input  uvm_ral_map      map = null,
                            input  uvm_sequence_base   parent = null,
                            input  uvm_object          extension = null,
                            input  string              fname = "",
                            input  int                 lineno = 0);

   //------------------------------------------------------------------------------
   // TASK: poke
   // Deposit the specified value in the specified virtual register in the design, as-is,
   // using a back-door access. The memory implementing the virtual register must provide
   // a back-door access. The optional value of the arguments: data_id scenario_id stream_id
   // ...are passed to the back-door access method. This allows the physical and back-door
   // write accesses to be traced back to the higher-level transaction that caused the access
   // to occur. 
   //------------------------------------------------------------------------------
   extern virtual task poke(input  longint unsigned    idx,
                            output uvm_ral::status_e   status,
                            input  uvm_ral_data_t      value,
                            input  uvm_sequence_base   parent = null,
                            input  uvm_object          extension = null,
                            input  string              fname = "",
                            input  int                 lineno = 0);

   //------------------------------------------------------------------------------
   // TASK: peek
   // Reads the current value of the specified virtual register from the design using a back-door
   // access. The memory implementing the virtual register must provide a back-door access.
   // The optional value of the arguments: data_id scenario_id stream_id ...are passed
   // to the back-door access method. This allows the physical and back-door read accesses
   // to be traced back to the higher-level transaction that caused the access to occur. 
   //------------------------------------------------------------------------------
   extern virtual task peek(input  longint unsigned    idx,
                            output uvm_ral::status_e   status,
                            output uvm_ral_data_t      value,
                            input  uvm_sequence_base   parent = null,
                            input  uvm_object          extension = null,
                            input  string              fname = "",
                            input  int                 lineno = 0);
  
   extern virtual function void do_print (uvm_printer printer);
   extern virtual function string convert2string;
   extern virtual function uvm_object clone();
   extern virtual function void do_copy   (uvm_object rhs);
   extern virtual function bit do_compare (uvm_object  rhs,
                                          uvm_comparer comparer);
   extern virtual function void do_pack (uvm_packer packer);
   extern virtual function void do_unpack (uvm_packer packer);

endclass: uvm_ral_vreg


function uvm_ral_vreg::new(string name);
   super.new(name);
   this.locked    = 0;
endfunction: new

function void uvm_ral_vreg::configure(uvm_ral_block      parent,
                                      int unsigned       n_bits,
                                      uvm_ral_addr_t     offset = 0,
                                      uvm_ral_mem        mem = null,
                                      longint unsigned   size = 0,
                                      int unsigned       incr = 0);
   this.parent = parent;

   if (n_bits == 0) begin
      `uvm_error("RAL", $psprintf("Virtual register \"%s\" cannot have 0 bits", this.get_full_name()));
      n_bits = 1;
   end
   if (n_bits > `UVM_RAL_DATA_WIDTH) begin
      `uvm_error("RAL", $psprintf("Virtual register \"%s\" cannot have more than %0d bits (%0d)", this.get_full_name(), `UVM_RAL_DATA_WIDTH, n_bits));
      n_bits = `UVM_RAL_DATA_WIDTH;
   end
   this.n_bits = n_bits;
   this.n_used_bits = 0;

   if (mem != null) begin
      void'(this.implement(size, mem, offset, incr));
      this.is_static = 1;
   end
   else begin
      this.mem = null;
      this.is_static = 0;
   end
   this.parent.add_vreg(this);

   this.atomic = new(1);
endfunction: configure



function void uvm_ral_vreg::Xlock_modelX();
   if (this.locked) return;

   this.locked = 1;
endfunction: Xlock_modelX


function void uvm_ral_vreg::add_field(uvm_ral_vfield field);
   int offset;
   int idx;
   
   if (this.locked) begin
      `uvm_error("RAL", "Cannot add virtual field to locked virtual register model");
      return;
   end

   if (field == null) `uvm_fatal("RAL", "Attempting to register NULL virtual field");

   // Store fields in LSB to MSB order
   offset = field.get_lsb_pos_in_register();

   idx = -1;
   foreach (this.fields[i]) begin
      if (offset < this.fields[i].get_lsb_pos_in_register()) begin
         int j = i;
         this.fields.insert(j, field);
         idx = i;
         break;
      end
   end
   if (idx < 0) begin
      this.fields.push_back(field);
      idx = this.fields.size()-1;
   end

   this.n_used_bits += field.get_n_bits();
   
   // Check if there are too many fields in the register
   if (this.n_used_bits > this.n_bits) begin
      `uvm_error("RAL", $psprintf("Virtual fields use more bits (%0d) than available in virtual register \"%s\" (%0d)",
                                     this.n_used_bits, this.get_full_name(), this.n_bits));
   end

   // Check if there are overlapping fields
   if (idx > 0) begin
      if (this.fields[idx-1].get_lsb_pos_in_register() +
          this.fields[idx-1].get_n_bits() > offset) begin
         `uvm_error("RAL", $psprintf("Field %s overlaps field %s in virtual register \"%s\"",
                                        this.fields[idx-1].get_name(),
                                        field.get_name(),
                                        this.get_full_name()));
      end
   end
   if (idx < this.fields.size()-1) begin
      if (offset + field.get_n_bits() >
          this.fields[idx+1].get_lsb_pos_in_register()) begin
         `uvm_error("RAL", $psprintf("Field %s overlaps field %s in virtual register \"%s\"",
                                        field.get_name(),
                                        this.fields[idx+1].get_name(),

                                        this.get_full_name()));
      end
   end
endfunction: add_field


task uvm_ral_vreg::XatomicX(bit on);
   if (on) this.atomic.get(1);
   else begin
      // Maybe a key was put back in by a spurious call to reset()
      void'(this.atomic.try_get(1));
      this.atomic.put(1);
   end
endtask: XatomicX


function void uvm_ral_vreg::reset(uvm_ral::reset_e kind = uvm_ral::HARD);
   // Put back a key in the semaphore if it is checked out
   // in case a thread was killed during an operation
   void'(this.atomic.try_get(1));
   this.atomic.put(1);
endfunction: reset


function string uvm_ral_vreg::get_full_name();
   uvm_ral_block blk;

   get_full_name = this.get_name();

   // Do not include top-level name in full name
   blk = this.get_block();
   if (blk == null) return get_full_name;
   if (blk.get_parent() == null) return get_full_name;

   get_full_name = {this.parent.get_full_name(), ".", get_full_name};
endfunction: get_full_name

function void uvm_ral_vreg::set_parent(uvm_ral_block parent);
   this.parent = parent;
endfunction: set_parent

function uvm_ral_block uvm_ral_vreg::get_parent();
   get_parent = this.parent;
endfunction: get_parent

function uvm_ral_block uvm_ral_vreg::get_block();
   get_block = this.parent;
endfunction: get_block


function bit uvm_ral_vreg::implement(longint unsigned n,
                                     uvm_ral_mem      mem = null,
                                     uvm_ral_addr_t   offset = 0,
                                     int unsigned     incr = 0);

   uvm_mam_region mam_region;

   if(n < 1)
   begin
     `uvm_error("RAL", $psprintf("Attempting to implement virtual register \"%s\" with a subscript less than one doesn't make sense",this.get_full_name()));
      return 0;
   end

   if (mem == null) begin
      `uvm_error("RAL", $psprintf("Attempting to implement virtual register \"%s\" using a NULL uvm_ral_mem reference", this.get_full_name()));
      return 0;
   end

   if (this.is_static) begin
      `uvm_error("RAL", $psprintf("Virtual register \"%s\" is static and cannot be dynamically implemented", this.get_full_name()));
      return 0;
   end

   if (mem.get_block() != this.parent) begin
      `uvm_error("RAL", $psprintf("Attempting to implement virtual register \"%s\" on memory \"%s\" in a different block",
                                     this.get_full_name(),
                                     mem.get_full_name()));
      return 0;
   end

   begin
      int min_incr = (this.get_n_bytes()-1) / mem.get_n_bytes() + 1;
      if (incr == 0) incr = min_incr;
      if (min_incr > incr) begin
         `uvm_error("RAL", $psprintf("Virtual register \"%s\" increment is too small (%0d): Each virtual register requires at least %0d locations in memory \"%s\".",
                                        this.get_full_name(), incr,
                                        min_incr, mem.get_full_name()));
         return 0;
      end
   end

   // Is the memory big enough for ya?
   if (offset + (n * incr) > mem.get_size()) begin
      `uvm_error("RAL", $psprintf("Given Offset for Virtual register \"%s[%0d]\" is too big for memory %s@'h%0h", this.get_full_name(), n, mem.get_full_name(), offset));
      return 0;
   end

   mam_region = mem.mam.reserve_region(offset,n*incr*mem.get_n_bytes());

   if (mam_region == null) begin
      `uvm_error("RAL", $psprintf("Could not allocate a memory region for virtual register \"%s\"", this.get_full_name()));
      return 0;
   end

   if (this.mem != null) begin
      `uvm_info("RAL", $psprintf("Virtual register \"%s\" is being moved re-implemented from %s@'h%0h to %s@'h%0h",
                                 this.get_full_name(),
                                 this.mem.get_full_name(),
                                 this.offset,
                                 mem.get_full_name(), offset),UVM_MEDIUM);
      this.release_region();
   end

   this.region = mam_region;
   this.mem    = mem;
   this.size   = n;
   this.offset = offset;
   this.incr   = incr;
   this.mem.XvregsX.push_back(this);

   return 1;
endfunction: implement


function uvm_mam_region uvm_ral_vreg::allocate(longint unsigned n,
                                               uvm_mam          mam);

   uvm_ral_mem mem;

   if(n < 1)
   begin
     `uvm_error("RAL", $psprintf("Attempting to implement virtual register \"%s\" with a subscript less than one doesn't make sense",this.get_full_name()));
      return null;
   end

   if (mam == null) begin
      `uvm_error("RAL", $psprintf("Attempting to implement virtual register \"%s\" using a NULL uvm_mam reference", this.get_full_name()));
      return null;
   end

   if (this.is_static) begin
      `uvm_error("RAL", $psprintf("Virtual register \"%s\" is static and cannot be dynamically allocated", this.get_full_name()));
      return null;
   end

   mem = mam.get_memory();
   if (mem.get_block() != this.parent) begin
      `uvm_error("RAL", $psprintf("Attempting to allocate virtual register \"%s\" on memory \"%s\" in a different block",
                                     this.get_full_name(),
                                     mem.get_full_name()));
      return null;
   end

   begin
      int min_incr = (this.get_n_bytes()-1) / mem.get_n_bytes() + 1;
      if (incr == 0) incr = min_incr;
      if (min_incr < incr) begin
         `uvm_error("RAL", $psprintf("Virtual register \"%s\" increment is too small (%0d): Each virtual register requires at least %0d locations in memory \"%s\".",
                                        this.get_full_name(), incr,
                                        min_incr, mem.get_full_name()));
         return null;
      end
   end

   // Need memory at least of size num_vregs*sizeof(vreg) in bytes.
   allocate = mam.request_region(n*incr*mem.get_n_bytes());
   if (allocate == null) begin
      `uvm_error("RAL", $psprintf("Could not allocate a memory region for virtual register \"%s\"", this.get_full_name()));
      return null;
   end

   if (this.mem != null) begin
     `uvm_info("RAL", $psprintf("Virtual register \"%s\" is being moved re-allocated from %s@'h%0h to %s@'h%0h",
                                this.get_full_name(),
                                this.mem.get_full_name(),
                                this.offset,
                                mem.get_full_name(),
                                allocate.get_start_offset()),UVM_MEDIUM);

      this.release_region();
   end

   this.region = allocate;

   this.mem    = mam.get_memory();
   this.offset = allocate.get_start_offset();
   this.size   = n;
   this.incr   = incr;

   this.mem.XvregsX.push_back(this);
endfunction: allocate


function uvm_mam_region uvm_ral_vreg::get_region();
   return this.region;
endfunction: get_region


function void uvm_ral_vreg::release_region();
   if (this.is_static) begin
      `uvm_error("RAL", $psprintf("Virtual register \"%s\" is static and cannot be dynamically released", this.get_full_name()));
      return;
   end

   if (this.mem != null) begin
      foreach (this.mem.XvregsX[i]) begin
         if (this.mem.XvregsX[i] == this) begin
            this.mem.XvregsX.delete(i);
            break;
         end
      end
   end 
   if (this.region != null) begin
      this.region.release_region();
   end

   this.region = null;
   this.mem    = null;
   this.size   = 0;
   this.offset = 0;

   this.reset();
endfunction: release_region


function uvm_ral_mem uvm_ral_vreg::get_memory();
   return this.mem;
endfunction: get_memory


function uvm_ral_addr_t  uvm_ral_vreg::get_offset_in_memory(longint unsigned idx);
   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vreg::get_offset_in_memory() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      return 0;
   end

   return this.offset + idx * this.incr;
endfunction


function uvm_ral_addr_t  uvm_ral_vreg::get_external_address(longint unsigned idx,
                                                            uvm_ral_map map = null);
   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot get address of of unimplemented virtual register \"%s\".", this.get_full_name()));
      return 0;
   end

   return this.mem.get_address(this.get_offset_in_memory(idx), map);
endfunction: get_external_address


function int unsigned uvm_ral_vreg::get_size();
   if (this.size == 0) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vreg::get_size() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      return 0;
   end

   return this.size;
endfunction: get_size


function int unsigned uvm_ral_vreg::get_n_bytes();
   return ((this.n_bits-1) / 8) + 1;
endfunction: get_n_bytes


function int unsigned uvm_ral_vreg::get_n_memlocs();
   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vreg::get_n_memlocs() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      return 0;
   end

   return (this.get_n_bytes()-1) / this.mem.get_n_bytes() + 1;
endfunction: get_n_memlocs


function int unsigned uvm_ral_vreg::get_incr();
   if (this.incr == 0) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vreg::get_incr() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      return 0;
   end

   return this.incr;
endfunction: get_incr


function int uvm_ral_vreg::get_n_maps();
   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vreg::get_n_maps() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      return 0;
   end

   return this.mem.get_n_maps();
endfunction: get_n_maps


function void uvm_ral_vreg::get_maps(ref uvm_ral_map maps[$]);
   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vreg::get_maps() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      return;
   end

   this.mem.get_maps(maps);
endfunction: get_maps


function bit uvm_ral_vreg::is_in_map(uvm_ral_map map);
   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vreg::is_in_map() on unimplemented virtual register \"%s\"",
                                  this.get_full_name()));
      return 0;
   end

   return this.mem.is_in_map(map);
endfunction


function string uvm_ral_vreg::get_access(uvm_ral_map map = null);
   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vreg::get_rights() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      return "RW";
   end

   return this.mem.get_access(map);
endfunction: get_access


function string uvm_ral_vreg::get_rights(uvm_ral_map map = null);
   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot call uvm_ral_vreg::get_rights() on unimplemented virtual register \"%s\"",
                                     this.get_full_name()));
      return "RW";
   end

   return this.mem.get_rights(map);
endfunction: get_rights


function void uvm_ral_vreg::get_fields(ref uvm_ral_vfield fields[$]);
   foreach(this.fields[i])
      fields.push_back(this.fields[i]);
endfunction: get_fields


function uvm_ral_vfield uvm_ral_vreg::get_field_by_name(string name);
   foreach (this.fields[i]) begin
      if (this.fields[i].get_name() == name) begin
         return this.fields[i];
      end
   end
   `uvm_warning("RAL", $psprintf("Unable to locate field \"%s\" in virtual register \"%s\".",
                                    name, this.get_full_name()));
   get_field_by_name = null;
endfunction: get_field_by_name


task uvm_ral_vreg::write(input  longint unsigned   idx,
                         output uvm_ral::status_e  status,
                         input  uvm_ral_data_t     value,
                         input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                         input  uvm_ral_map     map = null,
                         input  uvm_sequence_base  parent = null,
                         input  uvm_object         extension = null,
                         input  string             fname = "",
                         input  int                lineno = 0);
   uvm_ral_vreg_cb_iter cbs = new(this);

   uvm_ral_addr_t  addr;
   uvm_ral_data_t  tmp;
   uvm_ral_data_t  msk;
   int lsb;

   this.write_in_progress = 1'b1;
   this.fname = fname;
   this.lineno = lineno;
   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot write to unimplemented virtual register \"%s\".", this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   if (path == uvm_ral::DEFAULT)
     path = this.parent.get_default_path();

   foreach (fields[i]) begin
      uvm_ral_vfield_cb_iter cbs = new(fields[i]);
      uvm_ral_vfield f = fields[i];
      
      lsb = f.get_lsb_pos_in_register();
      msk = ((1<<f.get_n_bits())-1) << lsb;
      tmp = (value & msk) >> lsb;

      f.pre_write(idx, tmp, path, map);
      for (uvm_ral_vfield_cbs cb = cbs.first(); cb != null;
           cb = cbs.next()) begin
         cb.fname = this.fname;
         cb.lineno = this.lineno;
         cb.pre_write(f, idx, tmp, path, map);
      end

      value = (value & ~msk) | (tmp << lsb);
   end
   this.pre_write(idx, value, path, map);
   for (uvm_ral_vreg_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.pre_write(this, idx, value, path, map);
   end

   addr = this.offset + (idx * this.incr);

   lsb = 0;
   status = uvm_ral::IS_OK;
   for (int i = 0; i < this.get_n_memlocs(); i++) begin
      uvm_ral::status_e s;

      msk = ((1<<(this.mem.get_n_bytes()*8))-1) << lsb;
      tmp = (value & msk) >> lsb;
      this.mem.write(s, addr + i, tmp, path, map , parent, , extension, fname, lineno);
      if (s != uvm_ral::IS_OK && s != uvm_ral::HAS_X) status = s;
      lsb += this.mem.get_n_bytes() * 8;
   end

   this.post_write(idx, value, path, map, status);
   for (uvm_ral_vreg_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_write(this, idx, value, path, map, status);
   end
   foreach (fields[i]) begin
      uvm_ral_vfield_cb_iter cbs = new(fields[i]);
      uvm_ral_vfield f = fields[i];
      
      lsb = f.get_lsb_pos_in_register();
      msk = ((1<<f.get_n_bits())-1) << lsb;
      tmp = (value & msk) >> lsb;

      f.post_write(idx, tmp, path, map, status);
      for (uvm_ral_vfield_cbs cb = cbs.first(); cb != null;
           cb = cbs.next()) begin
         cb.fname = this.fname;
         cb.lineno = this.lineno;
         cb.post_write(f, idx, tmp, path, map, status);
      end

      value = (value & ~msk) | (tmp << lsb);
   end

   `uvm_info("RAL", $psprintf("Wrote virtual register \"%s\"[%0d] via %s with: 'h%h",
                              this.get_full_name(), idx,
                              (path == uvm_ral::BFM) ? "frontdoor" : "backdoor",
                              value),UVM_MEDIUM);
   
   this.write_in_progress = 1'b0;
   this.fname = "";
   this.lineno = 0;

endtask: write


task uvm_ral_vreg::read(input  longint unsigned   idx,
                        output uvm_ral::status_e  status,
                        output uvm_ral_data_t     value,
                        input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                        input  uvm_ral_map     map = null,
                        input  uvm_sequence_base  parent = null,
                        input  uvm_object         extension = null,
                        input  string             fname = "",
                        input  int                lineno = 0);
   uvm_ral_vreg_cb_iter cbs = new(this);

   uvm_ral_addr_t  addr;
   uvm_ral_data_t  tmp;
   uvm_ral_data_t  msk;
   int lsb;
   this.read_in_progress = 1'b1;
   this.fname = fname;
   this.lineno = lineno;

   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot read from unimplemented virtual register \"%s\".", this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   if (path == uvm_ral::DEFAULT)
     path = this.parent.get_default_path();

   foreach (fields[i]) begin
      uvm_ral_vfield_cb_iter cbs = new(fields[i]);
      uvm_ral_vfield f = fields[i];

      f.pre_read(idx, path, map);
      for (uvm_ral_vfield_cbs cb = cbs.first(); cb != null;
           cb = cbs.next()) begin
         cb.fname = this.fname;
         cb.lineno = this.lineno;
         cb.pre_read(f, idx, path, map);
      end
   end
   this.pre_read(idx, path, map);
   for (uvm_ral_vreg_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.pre_read(this, idx, path, map);
   end

   addr = this.offset + (idx * this.incr);

   lsb = 0;
   value = 0;
   status = uvm_ral::IS_OK;
   for (int i = 0; i < this.get_n_memlocs(); i++) begin
      uvm_ral::status_e s;

      this.mem.read(s, addr + i, tmp, path, map, parent, , extension, fname, lineno);
      if (s != uvm_ral::IS_OK && s != uvm_ral::HAS_X) status = s;

      value |= tmp << lsb;
      lsb += this.mem.get_n_bytes() * 8;
   end

   this.post_read(idx, value, path, map, status);
   for (uvm_ral_vreg_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_read(this, idx, value, path, map, status);
   end
   foreach (fields[i]) begin
      uvm_ral_vfield_cb_iter cbs = new(fields[i]);
      uvm_ral_vfield f = fields[i];

      lsb = f.get_lsb_pos_in_register();

      msk = ((1<<f.get_n_bits())-1) << lsb;
      tmp = (value & msk) >> lsb;

      f.post_read(idx, tmp, path, map, status);
      for (uvm_ral_vfield_cbs cb = cbs.first(); cb != null;
           cb = cbs.next()) begin
         cb.fname = this.fname;
         cb.lineno = this.lineno;
         cb.post_read(f, idx, tmp, path, map, status);
      end

      value = (value & ~msk) | (tmp << lsb);
   end

   `uvm_info("RAL", $psprintf("Read virtual register \"%s\"[%0d] via %s: 'h%h",
                              this.get_full_name(), idx,
                              (path == uvm_ral::BFM) ? "frontdoor" : "backdoor",
                              value),UVM_MEDIUM);
   
   this.read_in_progress = 1'b0;
   this.fname = "";
   this.lineno = 0;
endtask: read


task uvm_ral_vreg::poke(input longint unsigned   idx,
                        output uvm_ral::status_e status,
                        input  uvm_ral_data_t    value,
                        input  uvm_sequence_base parent = null,
                        input  uvm_object        extension = null,
                        input  string            fname = "",
                        input  int               lineno = 0);
   uvm_ral_addr_t  addr;
   uvm_ral_data_t  tmp;
   uvm_ral_data_t  msk;
   int lsb;
   this.fname = fname;
   this.lineno = lineno;

   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot poke in unimplemented virtual register \"%s\".", this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   addr = this.offset + (idx * this.incr);

   lsb = 0;
   status = uvm_ral::IS_OK;
   for (int i = 0; i < this.get_n_memlocs(); i++) begin
      uvm_ral::status_e s;

      msk = ((1<<(this.mem.get_n_bytes() * 8))-1) << lsb;
      tmp = (value & msk) >> lsb;

      this.mem.poke(status, addr + i, tmp, "", parent, extension, fname, lineno);
      if (s != uvm_ral::IS_OK && s != uvm_ral::HAS_X) status = s;

      lsb += this.mem.get_n_bytes() * 8;
   end

   `uvm_info("RAL", $psprintf("Poked virtual register \"%s\"[%0d] with: 'h%h",
                              this.get_full_name(), idx, value),UVM_MEDIUM);
   this.fname = "";
   this.lineno = 0;

endtask: poke


task uvm_ral_vreg::peek(input longint unsigned   idx,
                        output uvm_ral::status_e status,
                        output uvm_ral_data_t    value,
                        input  uvm_sequence_base parent = null,
                        input  uvm_object        extension = null,
                        input  string            fname = "",
                        input  int               lineno = 0);
   uvm_ral_addr_t  addr;
   uvm_ral_data_t  tmp;
   uvm_ral_data_t  msk;
   int lsb;
   this.fname = fname;
   this.lineno = lineno;

   if (this.mem == null) begin
      `uvm_error("RAL", $psprintf("Cannot peek in from unimplemented virtual register \"%s\".", this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   addr = this.offset + (idx * this.incr);

   lsb = 0;
   value = 0;
   status = uvm_ral::IS_OK;
   for (int i = 0; i < this.get_n_memlocs(); i++) begin
      uvm_ral::status_e s;

      this.mem.peek(status, addr + i, tmp, "", parent, extension, fname, lineno);
      if (s != uvm_ral::IS_OK && s != uvm_ral::HAS_X) status = s;

      value |= tmp << lsb;
      lsb += this.mem.get_n_bytes() * 8;
   end

   `uvm_info("RAL", $psprintf("Peeked virtual register \"%s\"[%0d]: 'h%h",
                              this.get_full_name(), idx, value),UVM_MEDIUM);
   
   this.fname = "";
   this.lineno = 0;

endtask: peek


function void uvm_ral_vreg::do_print (uvm_printer printer);
  super.do_print(printer);
  printer.print_generic("initiator", parent.get_type_name(), -1, convert2string());
endfunction

function string uvm_ral_vreg::convert2string();
   string res_str = "";
   string t_str = "";
   bit with_debug_info = 1'b0;
   $sformat(convert2string, "Virtual register %s -- ", 
            this.get_full_name());

   if (this.size == 0)
     $sformat(convert2string, "%sunimplemented", convert2string);
   else begin
      uvm_ral_map maps[$];
      mem.get_maps(maps);

      $sformat(convert2string, "%s[%0d] in %0s['h%0h+'h%0h]\n", convert2string,
             this.size, this.mem.get_full_name(), this.offset, this.incr); 
      foreach (maps[i]) begin
        uvm_ral_addr_t  addr0 = this.get_external_address(0, maps[i]);

        $sformat(convert2string, "  Address in map '%s' -- @'h%0h+%0h",
        maps[i].get_full_name(), addr0, this.get_external_address(1, maps[i]) - addr0);
      end
   end
   foreach(this.fields[i]) begin
      $sformat(convert2string, "%s\n%s", convert2string,
               this.fields[i].convert2string());
   end

endfunction: convert2string



//TODO - add fatal messages
function uvm_object uvm_ral_vreg::clone();
  return null;
endfunction

function void uvm_ral_vreg::do_copy   (uvm_object rhs);
endfunction

function bit uvm_ral_vreg::do_compare (uvm_object  rhs,
                                        uvm_comparer comparer);
  return 0;
endfunction

function void uvm_ral_vreg::do_pack (uvm_packer packer);
endfunction

function void uvm_ral_vreg::do_unpack (uvm_packer packer);
endfunction


