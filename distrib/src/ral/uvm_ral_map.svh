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

class uvm_ral_map_info;
   uvm_ral_addr_t        offset;
   string                rights;
   uvm_ral_reg_frontdoor frontdoor;
   uvm_ral_mem_frontdoor mem_frontdoor;
   bit                   unmapped;
   uvm_ral_addr_t        addr[];
endclass



class uvm_ral_map extends uvm_object;

   `uvm_object_utils(uvm_ral_map)
   
   // info that is valid only if top-level map
   local int unsigned            m_n_bytes;
   local uvm_ral::endianness_e   m_endian;
   local uvm_ral_addr_t          m_base_addr;
   local uvm_object_wrapper      m_sequence_wrapper;
   local uvm_ral_adapter         m_adapter;
   local uvm_sequencer_base      m_sequencer;
   local bit                     m_auto_predict;

   local uvm_ral_block           m_parent;

   local int unsigned            m_system_n_bytes;

   local uvm_ral_map             m_parent_map;
   local uvm_ral_addr_t          m_parent_maps[uvm_ral_map];   // value=offset of this map at parent level
   local uvm_ral_addr_t          m_submaps[uvm_ral_map];       // value=offset of submap at this level
   local string                  m_submap_rights[uvm_ral_map]; // value=rights of submap at this level

   local uvm_ral_map_info        m_regs_info[uvm_ral_reg];
   local uvm_ral_map_info        m_mems_info[uvm_ral_mem];

   local string                  m_attributes[string];

   local uvm_ral_reg             m_regs_by_offset[uvm_ral_addr_t];
   local uvm_ral_mem             m_mems_by_offset[uvm_ral_addr_t];

   //extern local function void Xinit_reg_by_offset_mapX();
   //extern /*local*/ function uvm_ral_reg_by_offset_map Xget_reg_by_offset_mapX(string map); 

   extern /*local*/ function void Xinit_address_mapX();

   static local uvm_ral_map   m_backdoor;
   static function uvm_ral_map backdoor();
      if (m_backdoor == null)
        m_backdoor = new("Backdoor");
      return m_backdoor;
   endfunction


   // TODO: add 'reset' method, which resets only elements in that map

   //----------------------
   // Group: Initialization
   //----------------------

   extern function new(string name = "");

   extern function void configure(uvm_ral_block          parent,
                                  uvm_ral_addr_t         base_addr,
                                  int unsigned           n_bytes,
                                  uvm_ral::endianness_e  endian);


   extern virtual function void   add_reg       (uvm_ral_reg   rg,
                                                 uvm_ral_addr_t offset,
                                                 string rights = "RW",
                                                 bit unmapped=0,
                                                 uvm_ral_reg_frontdoor frontdoor=null);

   extern virtual function void   add_mem       (uvm_ral_mem   mem,
                                                 uvm_ral_addr_t offset,
                                                 string rights = "RW",
                                                 bit unmapped=0,
                                                 uvm_ral_mem_frontdoor frontdoor=null);

   extern virtual function void   add_parent_map(uvm_ral_map  parent_map,
                                                 uvm_ral_addr_t offset);

   extern virtual function void   add_submap    (uvm_ral_map    child_map,
                                                 uvm_ral_addr_t offset);

   extern virtual function void   set_sequencer (uvm_sequencer_base sequencer,
                                                 uvm_ral_adapter adapter);

   extern virtual function void           set_submap_offset (uvm_ral_map submap,
                                                             uvm_ral_addr_t offset);
   extern virtual function uvm_ral_addr_t get_submap_offset (uvm_ral_map submap);

   extern virtual function void   set_base_addr (uvm_ral_addr_t  offset);

   extern function bit Xcheck_child_overlapX(uvm_ral_map  child_map,
                                             int unsigned offset,
                                             int unsigned size);

   extern function bit Xcheck_rangeX        (int unsigned str_addr,
                                             int unsigned end_addr,
                                             string kind,
                                             int unsigned new_str_addr,
                                             int unsigned new_end_addr,
                                             string new_name);

   extern virtual function void   Xverify_map_configX();


   // Group: Get

   extern virtual function uvm_ral_map           get_root_map();
   extern virtual function uvm_ral_block         get_parent    ();
   extern virtual function uvm_ral_map           get_parent_map();

   extern virtual function uvm_ral_addr_t        get_base_addr (uvm_ral::hier_e hier=uvm_ral::HIER);
   extern virtual function int unsigned          get_n_bytes   (uvm_ral::hier_e hier=uvm_ral::HIER);
   extern virtual function uvm_ral::endianness_e get_endian    (uvm_ral::hier_e hier=uvm_ral::HIER);
   extern virtual function uvm_sequencer_base    get_sequencer (uvm_ral::hier_e hier=uvm_ral::HIER);
   extern virtual function uvm_ral_adapter       get_adapter   (uvm_ral::hier_e hier=uvm_ral::HIER);

   extern virtual function void  get_submaps           (ref uvm_ral_map maps[$],      input uvm_ral::hier_e hier=uvm_ral::HIER);
   extern virtual function void  get_registers         (ref uvm_ral_reg regs[$],      input uvm_ral::hier_e hier=uvm_ral::HIER);
   extern virtual function void  get_fields            (ref uvm_ral_field fields[$],  input uvm_ral::hier_e hier=uvm_ral::HIER);
   extern virtual function void  get_memories          (ref uvm_ral_mem mems[$],      input uvm_ral::hier_e hier=uvm_ral::HIER);
   extern virtual function void  get_virtual_registers (ref uvm_ral_vreg regs[$],     input uvm_ral::hier_e hier=uvm_ral::HIER);
   extern virtual function void  get_virtual_fields    (ref uvm_ral_vfield fields[$], input uvm_ral::hier_e hier=uvm_ral::HIER);

   extern virtual function uvm_ral_map_info get_reg_map_info(uvm_ral_reg rg,  bit error=1);
   extern virtual function uvm_ral_map_info get_mem_map_info(uvm_ral_mem mem, bit error=1);

   extern virtual function int unsigned          get_size      ();
   extern virtual function int get_physical_addresses(uvm_ral_addr_t        base_addr,
                                                      uvm_ral_addr_t        mem_offset,
                                                      int unsigned          n_bytes,
                                                      ref uvm_ral_addr_t    addr[]);
   
   function void set_auto_predict(bit on=1); m_auto_predict = on; endfunction
   function bit  get_auto_predict(); return m_auto_predict; endfunction
   
   //---------------------
   // Group: Get-by-Offset
   //---------------------

   extern virtual function uvm_ral_reg    get_reg_by_offset(uvm_ral_addr_t offset);
   extern virtual function uvm_ral_mem    get_mem_by_offset(uvm_ral_addr_t offset);

   //------------------
   // Group: Attributes
   //------------------

   extern virtual function void        set_attribute(string name, string value);
   extern virtual function string      get_attribute(string name, bit inherited = 1);
   extern virtual function void        get_attributes(ref string names[string],
                                                      input bit inherited=1);

   //--------------------
   // Group: Standard Ops
   //--------------------

   extern virtual function string      get_full_name();
   extern virtual function string      convert2string();
   extern virtual function uvm_object  clone();
   extern virtual function void        do_print (uvm_printer printer);
   extern virtual function void        do_copy   (uvm_object rhs);
   //extern virtual function bit       do_compare (uvm_object rhs, uvm_comparer comparer);
   //extern virtual function void      do_pack (uvm_packer packer);
   //extern virtual function void      do_unpack (uvm_packer packer);


endclass: uvm_ral_map
   


//---------------
// Initialization
//---------------

// new

function uvm_ral_map::new(string name = "");
   super.new((name == "") ? "default_map" : name);
   m_auto_predict = uvm_ral::PREDICT_DIRECT;
endfunction


// configure

function void uvm_ral_map::configure(uvm_ral_block          parent,
                                     uvm_ral_addr_t         base_addr,
                                     int unsigned           n_bytes,
                                     uvm_ral::endianness_e  endian);
   m_parent     = parent;
   m_n_bytes    = n_bytes;
   m_endian     = endian;
   m_base_addr  = base_addr;
endfunction: configure


// add_reg

function void uvm_ral_map::add_reg(uvm_ral_reg rg, 
                                   uvm_ral_addr_t offset,
                                   string rights = "RW",
                                   bit unmapped=0,
                                   uvm_ral_reg_frontdoor frontdoor=null);

   if (this.m_regs_info.exists(rg)) begin
      `uvm_error("RAL", {"Register '",rg.get_name(),
                 "' has already been added to map '",get_name(),"'"})
      return;
   end

   rg.add_map(this);

   begin
   uvm_ral_map_info info = new;
   info.offset   = offset;
   info.rights   = rights;
   info.unmapped = unmapped;
   info.frontdoor = frontdoor;
   m_regs_info[rg] = info;
   end
endfunction


// add_mem

function void uvm_ral_map::add_mem(uvm_ral_mem mem,
                                   uvm_ral_addr_t offset,
                                   string rights = "RW",
                                   bit unmapped=0,
                                   uvm_ral_mem_frontdoor frontdoor=null);
   if (this.m_mems_info.exists(mem)) begin
      `uvm_error("RAL", {"Memory '",mem.get_name(),
                 "' has already been added to map '",get_name(),"'"})
      return;
   end

   mem.add_map(this);

   begin
   uvm_ral_map_info info = new;
   info.offset   = offset;
   info.rights   = rights;
   info.unmapped = unmapped;
   info.mem_frontdoor = frontdoor;
   m_mems_info[mem] = info;
   end
endfunction: add_mem



// add_submap

function void uvm_ral_map::add_submap (uvm_ral_map child_map,
                                       uvm_ral_addr_t offset);
   // was uvm_ral_block::register_child
   uvm_ral_map parent_map = child_map.get_parent_map();

   if (child_map == null) begin
      `uvm_error("RAL", {"Attempting to add NULL map to map '",get_full_name(),"'"})
      return;
   end

   // Can not have more than one parent (currently)
   if (parent_map != null) begin
      `uvm_error("RAL", {"Map '", child_map.get_full_name(),
                 "' is already a child of map '",
                 parent_map.get_full_name(),
                 "'. Cannot also be a child of map '",
                 get_full_name(),
                 "'"})
      return;
   end

   begin : parent_block_check
     uvm_ral_block blk = child_map.get_parent();
     if (blk == null) begin
        `uvm_error("RAL", {"Cannot add submap '",child_map.get_full_name(),
                   "' because it does not have a parent block"})
        return;
     end
   end

   begin : n_bytes_match_check
      if (m_n_bytes > child_map.get_n_bytes(uvm_ral::NO_HIER)) begin
         `uvm_warning("RAL",
             $sformatf("Adding %0d-byte submap '%s' to %0d-byte parent map '%s'",
                       m_n_bytes, child_map.get_full_name(),
                       child_map.get_n_bytes(uvm_ral::NO_HIER), get_full_name()));
      end
   end

   child_map.add_parent_map(this,offset);

   set_submap_offset(child_map, offset);

endfunction: add_submap


// add_parent_map

function void uvm_ral_map::add_parent_map(uvm_ral_map parent_map, uvm_ral_addr_t offset);

   if (parent_map == null) begin
      `uvm_error("RAL",
          {"Attempting to add NULL parent map to map '",get_full_name(),"'"})
      return;
   end

   if (m_parent_map != null) begin
      `uvm_error("RAL",
          $psprintf("Map \"%s\" already a submap of map \"%s\" at offset 'h%h",
                    get_full_name(), m_parent_map.get_full_name(),
                    m_parent_map.get_submap_offset(this)));
      return;
   end

   this.m_parent_map = parent_map;
   this.m_parent_maps[parent_map] = offset; // prep for multiple parents
   parent_map.m_submaps[this] = offset;

endfunction: add_parent_map


// set_sequencer

function void uvm_ral_map::set_sequencer(uvm_sequencer_base sequencer,
                                         uvm_ral_adapter adapter);

   if (sequencer == null) begin
      `uvm_error("RAL_NULL_SQR", "Null reference specified for bus sequencer");
      return;
   end

   if (adapter == null) begin
      `uvm_error("RAL_NULL_CVT", "Null reference specified for adapter object");
      return;
   end

   m_sequencer = sequencer;
   m_adapter = adapter;
endfunction



//------------
// get methods
//------------

// get_parent

function uvm_ral_block uvm_ral_map::get_parent();
  return m_parent;
endfunction


// get_parent_map

function uvm_ral_map uvm_ral_map::get_parent_map();
  return m_parent_map;
endfunction


// get_root_map

function uvm_ral_map uvm_ral_map::get_root_map();
   return (m_parent_map == null) ? this : m_parent_map.get_root_map();
endfunction: get_root_map


// get_base_addr

function uvm_ral_addr_t  uvm_ral_map::get_base_addr(uvm_ral::hier_e hier=uvm_ral::HIER);
  uvm_ral_map child = this;
  if (hier == uvm_ral::NO_HIER || m_parent_map == null)
    return m_base_addr;
  get_base_addr = m_parent_map.get_submap_offset(this);
  get_base_addr += m_parent_map.get_base_addr(uvm_ral::HIER);
endfunction


// get_n_bytes

function int unsigned uvm_ral_map::get_n_bytes(uvm_ral::hier_e hier=uvm_ral::HIER);
  if (hier == uvm_ral::NO_HIER)
    return m_n_bytes;
  return m_system_n_bytes;
endfunction


// get_endian

function uvm_ral::endianness_e uvm_ral_map::get_endian(uvm_ral::hier_e hier=uvm_ral::HIER);
  if (hier == uvm_ral::NO_HIER || m_parent_map == null)
    return m_endian;
  return m_parent_map.get_endian(hier);
endfunction


// get_sequencer

function uvm_sequencer_base uvm_ral_map::get_sequencer(uvm_ral::hier_e hier=uvm_ral::HIER);
  if (hier == uvm_ral::NO_HIER || m_parent_map == null)
    return m_sequencer;
  return m_parent_map.get_sequencer(hier);
endfunction


// get_adapter

function uvm_ral_adapter uvm_ral_map::get_adapter(uvm_ral::hier_e hier=uvm_ral::HIER);
  if (hier == uvm_ral::NO_HIER || m_parent_map == null)
    return m_adapter;
  return m_parent_map.get_adapter(hier);
endfunction


// get_submaps

function void uvm_ral_map::get_submaps(ref uvm_ral_map maps[$], input uvm_ral::hier_e hier=uvm_ral::HIER);

   foreach (m_submaps[submap])
     maps.push_back(submap);

   if (hier == uvm_ral::HIER)
     foreach (this.m_submaps[submap])
       submap.get_submaps(maps);

endfunction


// get_registers

function void uvm_ral_map::get_registers(ref uvm_ral_reg regs[$], input uvm_ral::hier_e hier=uvm_ral::HIER);

  foreach (this.m_regs_info[rg])
    regs.push_back(rg);

  if (hier == uvm_ral::HIER)
    foreach (this.m_submaps[submap])
      submap.get_registers(regs);

endfunction


// get_fields

function void uvm_ral_map::get_fields(ref uvm_ral_field fields[$], input uvm_ral::hier_e hier=uvm_ral::HIER);

   foreach (this.m_regs_info[rg])
     rg.get_fields(fields);
   
   if (hier == uvm_ral::HIER)
     foreach (this.m_submaps[submap])
       submap.get_fields(fields);

endfunction


// get_memories

function void uvm_ral_map::get_memories(ref uvm_ral_mem mems[$], input uvm_ral::hier_e hier=uvm_ral::HIER);

   foreach (this.m_mems_info[mem])
     mems.push_back(mem);
    
   if (hier == uvm_ral::HIER)
     foreach (this.m_submaps[submap])
       submap.get_memories(mems);

endfunction


// get_virtual_registers

function void uvm_ral_map::get_virtual_registers(ref uvm_ral_vreg regs[$], input uvm_ral::hier_e hier=uvm_ral::HIER);

  uvm_ral_mem mems[$];
  get_memories(mems,hier);

  foreach (mems[i])
    mems[i].get_virtual_registers(regs);


endfunction


// get_virtual_fields

function void uvm_ral_map::get_virtual_fields(ref uvm_ral_vfield fields[$], input uvm_ral::hier_e hier=uvm_ral::HIER);

   uvm_ral_vreg regs[$];
   get_virtual_registers(regs,hier);

   foreach (regs[i])
       regs[i].get_fields(fields);

endfunction



// get_full_name

function string uvm_ral_map::get_full_name();

   get_full_name = this.get_name();

   if (m_parent == null)
     return get_full_name;

   return {m_parent.get_full_name(), ".", get_full_name};

endfunction: get_full_name


// get_mem_map_info

function uvm_ral_map_info uvm_ral_map::get_mem_map_info(uvm_ral_mem mem, bit error=1);
  if (!m_mems_info.exists(mem)) begin
    if (error)
      `uvm_error("RAL_NO_MAP",{"Memory '",mem.get_name(),"' not in map '",get_name(),"'"})
    return null;
  end
  return m_mems_info[mem];
endfunction


// get_reg_map_info

function uvm_ral_map_info uvm_ral_map::get_reg_map_info(uvm_ral_reg rg, bit error=1);
  if (!m_regs_info.exists(rg)) begin
    if (error)
      `uvm_error("RAL_NO_MAP",{"Register '",rg.get_name(),"' not in map '",get_name(),"'"})
    return null;
  end
  return m_regs_info[rg];
endfunction


//----------
// Size and Overlap Detection
//---------

// set_base_addr

function void uvm_ral_map::set_base_addr(uvm_ral_addr_t offset);
   if (m_parent_map != null) begin
      uvm_ral_map top_map = get_root_map();
      m_parent_map.set_submap_offset(this, offset);
      top_map.Xinit_address_mapX();
      return;
   end
   m_base_addr = offset;
endfunction


// get_size

function int unsigned uvm_ral_map::get_size();

  int unsigned max_addr = 0;
  int unsigned addr;

  // get max offset from registers
  foreach (m_regs_info[rg]) begin
    addr = m_regs_info[rg].offset + ((rg.get_n_bytes()-1)/m_n_bytes);
    if (addr > max_addr);
      max_addr = addr;
  end

  // get max offset from memories
  foreach (m_mems_info[mem]) begin
    addr = m_mems_info[mem].offset + (mem.get_size() * (((mem.get_n_bytes()-1)/m_n_bytes)+1)) -1;
    if (addr > max_addr) 
      max_addr = addr;
  end

  // get max offset from submaps
  foreach (m_submaps[submap]) begin
    addr = m_submaps[submap] + submap.get_size();
    if (addr > max_addr)
      max_addr = addr;
  end

  return max_addr + 1;

endfunction


// Xcheck_rangeX

function bit uvm_ral_map::Xcheck_rangeX(int unsigned str_addr,
                                        int unsigned end_addr,
                                        string kind,
                                        int unsigned new_str_addr,
                                        int unsigned new_end_addr,
                                        string new_name);

    if (new_str_addr >= str_addr && new_end_addr <= end_addr ||
        new_str_addr <= str_addr && new_end_addr >= str_addr ||
        new_str_addr <= end_addr && new_end_addr >= end_addr) begin

      `uvm_warning("RAL",
      $sformatf("In parent map '%s', new submap '%s' with offset range 'h%0h:%0h overlaps with existing %s with offset range 'h%0h:%0h",
        get_full_name(), new_name, new_str_addr, new_end_addr, kind, str_addr, end_addr))
      return 0;
    end

    return 1;
endfunction


// Xcheck_child_overlapX

function bit uvm_ral_map::Xcheck_child_overlapX(uvm_ral_map  child_map,
                                                int unsigned offset,
                                                int unsigned size);

  int unsigned multiplier = ((child_map.get_n_bytes(uvm_ral::NO_HIER)-1)/m_n_bytes)+1;
  int unsigned new_submap_size     = size;
  int unsigned new_submap_str_addr = offset;
  int unsigned new_submap_end_addr = offset + (new_submap_size * multiplier) - 1;

  Xcheck_child_overlapX = 1;

  foreach(m_regs_info[rg]) begin
    Xcheck_child_overlapX &=
      Xcheck_rangeX(m_regs_info[rg].offset, m_regs_info[rg].offset,"register",
                    new_submap_str_addr, new_submap_end_addr, child_map.get_full_name());
  end

  foreach(m_mems_info[mem]) begin
    Xcheck_child_overlapX &=
      Xcheck_rangeX(m_mems_info[mem].offset,
                    m_mems_info[mem].offset + mem.get_size() - 1, "memory",
                    new_submap_str_addr, new_submap_end_addr, child_map.get_full_name());
  end

  foreach(m_submaps[submap]) begin
  
    if (submap != child_map) begin


      int unsigned submap_start_addr = m_submaps[submap];
      int unsigned submap_end_addr   = m_submaps[submap] + (submap.get_size() *
                                     (((submap.get_n_bytes(uvm_ral::NO_HIER)-1)/m_n_bytes)+1))-1;
      Xcheck_child_overlapX &=
        Xcheck_rangeX(submap_start_addr, submap_end_addr, "submap",
                      new_submap_str_addr, new_submap_end_addr, child_map.get_full_name());
    end
  end

  if (Xcheck_child_overlapX == 0)
    return 0;

  //if there is a parent map, then this map is a submap of that parent, 
  //and if the submap size has increased, we need to check that it has not overlapped
  //into any of its siblings in the parent.

  if (m_parent_map != null) begin

    int unsigned new_size = get_size();

    if (new_submap_str_addr >= new_size)
      new_size += (new_size - new_submap_str_addr) + size;

    Xcheck_child_overlapX &= m_parent_map.Xcheck_child_overlapX(this, 
                               m_parent_map.get_submap_offset(this), new_size);

  end

endfunction


// Xverify_map_configX

function void uvm_ral_map::Xverify_map_configX();
   // Make sure there is a generic payload sequence for each map
   // in the model and vice-versa if this is a root sequencer
   bit error;
   uvm_ral_map root_map = get_root_map();

   if (this.get_parent_map() != null)
     return;

   if (root_map.get_adapter() == null) begin
      `uvm_error("RAL", {"Map '",root_map.get_full_name(),
                 "' does not have an adapter registered"})
      error++;
   end
   if (root_map.get_sequencer() == null) begin
      `uvm_error("RAL", {"Map '",root_map.get_full_name(),
                 "' does not have a sequencer registered"})
      error++;
   end
   if (error) begin
      `uvm_fatal("RAL", {"Must register an adapter and sequencer ",
                 "for each top-level map in RAL model"});
      return;
   end

endfunction



// get_physical_addresses

// Identify the sequence of addresses that must be accessed physically
// to access the specified number of bytes at the specified address
// within the specified block or system. Returns the number of bytes
// of valid data in each access.
//
// Returns a list of address in little endian order, with the granularity
// of the top-level system
//
// A register is specified as a base address with mem_indx == 0.
// A location within a memory is specified as an index from a base address.
//
function int uvm_ral_map::get_physical_addresses(uvm_ral_addr_t     base_addr,
                                                 uvm_ral_addr_t     mem_offset,
                                                 int unsigned       n_bytes,
                                                 ref uvm_ral_addr_t addr[]);
   int bus_width = get_n_bytes(uvm_ral::NO_HIER);
   uvm_ral_map  up_map;
   uvm_ral_addr_t  local_addr[];

   addr = new [0];
   
   if (n_bytes <= 0) begin
      `uvm_fatal("RAL", $psprintf("Cannot access %0d bytes. Must be greater than 0",
                                     n_bytes));
      return 0;
   end

   // First, identify the addresses within the block/system
   if (n_bytes <= bus_width) begin
      local_addr = new [1];
      local_addr[0] = base_addr + mem_offset;
   end else begin
      int n;

      n = ((n_bytes-1) / bus_width) + 1;
      local_addr = new [n];
      
      base_addr = base_addr + mem_offset * n;

      case (get_endian(uvm_ral::NO_HIER))
         uvm_ral::LITTLE_ENDIAN: begin
            foreach (local_addr[i]) begin
               local_addr[i] = base_addr + i;
            end
         end
         uvm_ral::BIG_ENDIAN: begin
            foreach (local_addr[i]) begin
               n--;
               local_addr[i] = base_addr + n;
            end
         end
         uvm_ral::LITTLE_FIFO: begin
            foreach (local_addr[i]) begin
               local_addr[i] = base_addr;
            end
         end
         uvm_ral::BIG_FIFO: begin
            foreach (local_addr[i]) begin
               local_addr[i] = base_addr;
            end
         end
         default: begin
            `uvm_error("RAL",
               {"Map has no specified endianness. ",
                $sformatf("Cannot access %0d bytes register via its %0d byte \"%s\" interface",
               n_bytes, bus_width, get_full_name())})
         end
      endcase
   end

  up_map = get_parent_map();

   // Then translate these addresses in the parent's space
   if (up_map == null) begin
      // This is the top-most system/block!
      addr = new [local_addr.size()] (local_addr);
   end else begin
      uvm_ral_addr_t  sys_addr[];
      uvm_ral_addr_t  base_addr;
      int w, k;

      // Scale the consecutive local address in the system's granularity
      if (bus_width < up_map.get_n_bytes(uvm_ral::NO_HIER))
        k = 1;
      else
        k = ((bus_width-1) / up_map.get_n_bytes(uvm_ral::NO_HIER)) + 1;

      base_addr = up_map.get_submap_offset(this);
      foreach (local_addr[i]) begin
         int n = addr.size();
         
         w = up_map.get_physical_addresses(base_addr + local_addr[i] * k,
                                           0,
                                           bus_width,
                                           sys_addr);

         addr = new [n + sys_addr.size()] (addr);
         foreach (sys_addr[j]) begin
            addr[n+j] = sys_addr[j];
         end
      end
      // The width of each access is the minimum of this block or the system's width
      if (w < bus_width)
         bus_width = w;
   end

   return bus_width;

endfunction: get_physical_addresses


//--------------
// Get-By-Offset
//--------------


// set_submap_offset

function void uvm_ral_map::set_submap_offset(uvm_ral_map submap, uvm_ral_addr_t offset);
  assert(submap != null);
  if (!Xcheck_child_overlapX(submap,offset,submap.get_size())) begin
    // msg?
  end
  m_submaps[submap] = offset;
endfunction


// get_submap_offset

function uvm_ral_addr_t uvm_ral_map::get_submap_offset(uvm_ral_map submap);
  assert(submap != null);
  if (!m_submaps.exists(submap)) begin
    `uvm_error("RAL",{"Map '",submap.get_full_name(),
                      "' is not a submap of '",get_full_name(),"'"})
    return -1;
  end
  return m_submaps[submap];
endfunction


// get_reg_by_offset

function uvm_ral_reg uvm_ral_map::get_reg_by_offset(uvm_ral_addr_t offset);
   if (m_regs_by_offset.exists(offset))
     return m_regs_by_offset[offset];
   return null;
endfunction


// get_mem_by_offset

function uvm_ral_mem uvm_ral_map::get_mem_by_offset(uvm_ral_addr_t offset);
   if (m_mems_by_offset.exists(offset))
     return m_mems_by_offset[offset];
   return null;
endfunction


// Xinit_address_mapX

function void uvm_ral_map::Xinit_address_mapX();

   int unsigned bus_width;

   uvm_ral_map top_map = get_root_map();

   foreach (m_submaps[map])
     map.Xinit_address_mapX();

   foreach (m_regs_info[rg]) begin
     if (!m_regs_info[rg].unmapped) begin
       uvm_ral_addr_t addrs[];
       bus_width = get_physical_addresses(m_regs_info[rg].offset,0,rg.get_n_bytes(),addrs);
       foreach (addrs[i]) begin
         uvm_ral_addr_t addr = addrs[i];
         if (top_map.m_regs_by_offset.exists(addr)) begin
           string a;
           a = $sformatf("%0h",addr);
           `uvm_warning("RAL", {"In map '",get_full_name(),"' register '",
               rg.get_full_name(), "' maps to same address as register '",
               top_map.m_regs_by_offset[addr].get_full_name(),"': 'h",a})
         end
         if (top_map.m_mems_by_offset.exists(addr)) begin
           string a;
           a = $sformatf("%0h",addr);
           `uvm_warning("RAL", {"In map '",get_full_name(),"' register '",
               rg.get_full_name(), "' maps to same address as memory '",
               top_map.m_mems_by_offset[addr].get_full_name(),"': 'h",a})
         end
         top_map.m_regs_by_offset[ addr ] = rg;
         m_regs_info[rg].addr = addrs;
       end
     end
   end

   foreach (m_mems_info[mem]) begin
     if (!m_mems_info[mem].unmapped) begin
       uvm_ral_addr_t addrs[];
       bus_width = get_physical_addresses(m_mems_info[mem].offset,0,mem.get_n_bytes(),addrs);
       foreach (addrs[i]) begin
         uvm_ral_addr_t addr = addrs[i];
         if (top_map.m_regs_by_offset.exists(addr)) begin
           string a;
           a = $sformatf("%0h",addr);
           `uvm_warning("RAL", {"In map '",get_full_name(),"' memory '",
               mem.get_full_name(), "' maps to same address as register '",
               top_map.m_regs_by_offset[addr].get_full_name(),"': 'h",a})
         end
         if (top_map.m_mems_by_offset.exists(addr)) begin
           string a;
           a = $sformatf("%0h",addr);
           `uvm_warning("RAL", {"In map '",get_full_name(),"' memory '",
               mem.get_full_name(), "' maps to same address as memory '",
               top_map.m_mems_by_offset[addr].get_full_name(),"': 'h",a})
         end
         top_map.m_mems_by_offset[ addr ] = mem;
         m_mems_info[mem].addr = addrs;
         // TODO: cache any address scaling
         //m_mem_offset_multiplier address_range[ addr ] = mem.get_size();
       end
     end
   end
   m_system_n_bytes = bus_width;
endfunction


//-----------
// Attributes
//-----------

// set_attribute

function void uvm_ral_map::set_attribute(string name, string value);

   if (name == "") begin
      `uvm_error("RAL", {"Cannot set attribute with empty name for map ",
         get_full_name(),"'."})
      return;
   end

   if (m_attributes.exists(name)) begin
      if (value != "") begin
         `uvm_warning("RAL", {"Redefining attribute '",
            name,"' in map '",get_full_name(),"' to '",value,"'"})
         m_attributes[name] = value;
      end
      else begin
         m_attributes.delete(name);
      end
      return;
   end

   if (value == "") begin
      `uvm_warning("RAL", {"Attempting to delete non-existent attribute '",
          name,"' in map '",get_full_name(),"'"})
      return;
   end

   m_attributes[name] = value;

endfunction: set_attribute


// get_attribute

function string uvm_ral_map::get_attribute(string name, bit inherited = 1);

   if (inherited && m_parent_map != null)
      get_attribute = m_parent_map.get_attribute(name);

   if (get_attribute == "" && this.m_attributes.exists(name))
      return this.m_attributes[name];

   return "";
endfunction: get_attribute


// get_attributes

function void uvm_ral_map::get_attributes(ref string names[string],
                                          input bit inherited = 1);
   if (inherited && m_parent_map != null)
     m_parent_map.get_attributes(names,1);

   foreach (m_attributes[nm])
     if (!names.exists(nm))
       names[nm] = m_attributes[nm];
endfunction



//-------------
// Standard Ops
//-------------

// do_print

function void uvm_ral_map::do_print (uvm_printer printer);
  super.do_print(printer);
  // Use printer object to print contents of map
endfunction

// convert2string

function string uvm_ral_map::convert2string();
   uvm_ral_reg  regs[$];
   uvm_ral_vreg vregs[$];
   uvm_ral_mem  mems[$];
   uvm_ral::endianness_e endian;
   string prefix = "";

   $sformat(convert2string, "%sMap %s", prefix, this.get_full_name());
   endian = this.get_endian(uvm_ral::NO_HIER);
   $sformat(convert2string, "%s -- %0d bytes (%s)", convert2string,
            this.get_n_bytes(uvm_ral::NO_HIER), endian.name());
   this.get_registers(regs);
   foreach (regs[j]) begin
      $sformat(convert2string, "%s\n%s", convert2string,
               regs[j].convert2string());//{prefix, "   "}, this));
   end
   this.get_memories(mems);
   foreach (mems[j]) begin
      $sformat(convert2string, "%s\n%s", convert2string,
               mems[j].convert2string());//{prefix, "   "}, this));
   end
   this.get_virtual_registers(vregs);
   foreach (vregs[j]) begin
      $sformat(convert2string, "%s\n%s", convert2string,
               vregs[j].convert2string());//{prefix, "   "}, this));
   end
endfunction


// clone

function uvm_object uvm_ral_map::clone();
  //uvm_rap_map me;
  //me = new this;
  //return me;
  return null;
endfunction


// do_copy

function void uvm_ral_map::do_copy (uvm_object rhs);
  //uvm_ral_map rhs_;
  //assert($cast(rhs_,rhs));

  //rhs_.regs = regs;
  //rhs_.mems = mems;
  //rhs_.vregs = vregs;
  //rhs_.blks = blks;
  //... and so on
endfunction

