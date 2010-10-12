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


//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_mem_burst
//
//------------------------------------------------------------------------------

class uvm_ral_mem_burst;
   rand int unsigned    n_beats;
   rand uvm_ral_addr_t  start_offset;
   rand uvm_ral_addr_t  incr_offset;
   rand uvm_ral_addr_t  max_offset;
endclass



//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_mem_cbs
//
//------------------------------------------------------------------------------

class uvm_ral_mem_cbs extends uvm_callback;
   string fname = "";
   int lineno = 0;

   function new(string name = "uvm_ral_reg_cbs");
      super.new(name);
   endfunction
   
   virtual task pre_write(uvm_ral_mem         mem,
                          ref uvm_ral_addr_t  offset,
                          ref uvm_ral_data_t  wdat,
                          ref uvm_ral::path_e path,
                          ref uvm_ral_map  map);
   endtask: pre_write

   virtual task post_write(uvm_ral_mem            mem,
                           uvm_ral_addr_t         offset,
                           uvm_ral_data_t         wdat,
                           uvm_ral::path_e        path,
                           uvm_ral_map         map,
                           ref uvm_ral::status_e  status);
   endtask: post_write

   virtual task pre_read(uvm_ral_mem         mem,
                         ref uvm_ral_addr_t  offset,
                         ref uvm_ral::path_e path,
                         ref uvm_ral_map  map);
   endtask: pre_read

   virtual task post_read(input uvm_ral_mem        mem,
                          input uvm_ral_addr_t     offset,
                          ref   uvm_ral_data_t     rdat,
                          input uvm_ral::path_e    path,
                          input uvm_ral_map     map,
                          ref   uvm_ral::status_e  status);
   endtask: post_read

   virtual task pre_burst(uvm_ral_mem              mem,
                          uvm_tlm_gp::tlm_command  kind,
                          uvm_ral_mem_burst        burst,
                          ref uvm_ral_data_t       wdat[],
                          ref uvm_ral::path_e      path,
                          ref uvm_ral_map       map);
   endtask: pre_burst

   virtual task post_burst(input uvm_ral_mem             mem,
                           input uvm_tlm_gp::tlm_command kind,
                           input uvm_ral_mem_burst       burst,
                           ref   uvm_ral_data_t          data[],
                           input uvm_ral::path_e         path,
                           input uvm_ral_map          map,
                           ref   uvm_ral::status_e       status);
   endtask: post_burst
endclass: uvm_ral_mem_cbs



typedef uvm_callbacks#(uvm_ral_mem, uvm_ral_mem_cbs) uvm_ral_mem_cb;
typedef uvm_callback_iter#(uvm_ral_mem, uvm_ral_mem_cbs) uvm_ral_mem_cb_iter;


//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_mem_frontdoor
//
//------------------------------------------------------------------------------

virtual class uvm_ral_mem_frontdoor extends uvm_sequence #(uvm_sequence_item);

   uvm_ral_mem       mem;
   bit               is_write;
   uvm_ral_mem_burst burst;
   uvm_ral::status_e status = uvm_ral::IS_OK;
   uvm_ral_addr_t    offset;
   uvm_ral_data_t    data[];
   int               prior = -1;
   uvm_object        extension = null;
   string            fname = "";
   int               lineno = 0;

   uvm_sequencer_base sequencer;

   function new(string name="");
      super.new(name);
   endfunction

endclass: uvm_ral_mem_frontdoor



//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_mem
//
//------------------------------------------------------------------------------

class uvm_ral_mem extends uvm_object;

   `uvm_register_cb(uvm_ral_mem, uvm_ral_mem_cbs)

   uvm_mam mam;

   typedef enum {UNKNOWNS, ZEROES, ONES, ADDRESS, VALUE, INCR, DECR} init_e;

   local bit locked;

   local bit read_in_progress;
   local bit write_in_progress;

   /*local*/ string access;
   /*local*/ longint unsigned size;

   local uvm_ral_block   parent;
   /*local*/ bit maps[uvm_ral_map];

   /*local*/ int unsigned  n_bits;
   local string        constraint_block_names[];

   local string attributes[string];

   local bit is_powered_down;

   /*local*/ int has_cover;
   local int cover_on;

   local string fname = "";
   local int    lineno = 0;

   /*local*/ uvm_ral_vreg XvregsX[$]; //Virtual registers implemented here

   //-----------
   // Group: Get
   //-----------

   extern function new (string           name,
                        longint unsigned size,
                        int unsigned     n_bits,
                        string           access = "RW",
                        int              has_cover = uvm_ral::NO_COVERAGE);

   extern virtual function void configure (uvm_ral_block parent,
                                           string        hdl_path = "");

   extern function void add_map(uvm_ral_map map);

   /*local*/ extern function void Xlock_modelX();

   extern virtual task init(output bit             is_ok,
                            input  init_e          pattern,
                            input  uvm_ral_data_t  data);


   extern virtual function string get_full_name();

   extern virtual function void set_parent(uvm_ral_block parent);
   
   //-----------
   // Group: Get
   //-----------

   extern virtual function string          get_access(uvm_ral_map map = null);

   extern virtual function void            get_virtual_registers(ref uvm_ral_vreg regs[$]);
   extern virtual function void            get_virtual_fields(ref uvm_ral_vfield fields[$]);

   extern virtual function uvm_ral_vreg    get_vreg_by_name(string name);
   extern virtual function uvm_ral_vfield  get_vfield_by_name(string name);

   extern virtual function uvm_ral_vreg    get_vreg_by_offset(bit [63:0]     offset,
                                                           uvm_ral_map map = null);

   extern virtual function uvm_ral_block   get_parent ();
   extern virtual function uvm_ral_block   get_block  ();
   extern virtual function string          get_rights (uvm_ral_map map = null);
   extern virtual function longint unsigned get_size();

   extern         function int unsigned    get_n_bytes();
   extern virtual function int unsigned    get_n_bits();

   //------------
   // Group: Maps
   //------------

   extern virtual function int         get_n_maps();
   extern virtual function bit         is_in_map(uvm_ral_map map);
   extern virtual function void        get_maps(ref uvm_ral_map maps[$]);
   extern virtual function uvm_ral_map get_default_map(string caller = "");
   extern virtual function uvm_ral_map get_local_map(uvm_ral_map map, string caller = "");


   extern virtual function uvm_ral_addr_t  get_offset (uvm_ral_addr_t mem_addr = 0,
                                                       uvm_ral_map map = null);
   extern virtual function uvm_ral_addr_t  get_address(uvm_ral_addr_t  offset = 0,
                                                       uvm_ral_map   map = null);

   extern virtual function int get_addresses(uvm_ral_addr_t     offset = 0,
                                             uvm_ral_map        map=null,
                                             ref uvm_ral_addr_t addr[]);

   //--------------------------------
   // Group: Attributes & Constraints
   //--------------------------------

   extern virtual function void set_attribute(string name,
                                              string value);
   extern virtual function string get_attribute(string name,
                                                bit inherited = 1);
   extern virtual function void get_attributes(ref string names[string],
                                               input bit inherited = 1);

   //----------------
   // Group: Coverage
   //----------------

   extern virtual function bit can_cover(int models);
   extern virtual function int set_cover(int is_on);
   extern virtual function bit is_cover_on(int is_on = uvm_ral::ALL_COVERAGE);

   //------------------
   // Group: HDL Access
   //------------------
 
   extern virtual task write(output uvm_ral::status_e  status,
                             input  uvm_ral_addr_t     mem_addr,
                             input  uvm_ral_data_t     value,
                             input  uvm_ral::path_e    path   = uvm_ral::DEFAULT,
                             input  uvm_ral_map        map = null,
                             input  uvm_sequence_base  parent = null,
                             input  int                prior = -1,
                             input  uvm_object         extension = null,
                             input  string             fname = "",
                             input  int                lineno = 0);

   extern virtual task read(output uvm_ral::status_e   status,
                            input  uvm_ral_addr_t      mem_addr,
                            output uvm_ral_data_t      value,
                            input  uvm_ral::path_e     path   = uvm_ral::DEFAULT,
                            input  uvm_ral_map         map = null,
                            input  uvm_sequence_base   parent = null,
                            input  int                 prior = -1,
                            input  uvm_object          extension = null,
                            input  string              fname = "",
                            input  int                 lineno = 0);

   extern virtual task burst_write(output uvm_ral::status_e  status,
                                   input  uvm_ral_mem_burst  burst,
                                   input  uvm_ral_data_t     value[],
                                   input  uvm_ral::path_e    path   = uvm_ral::DEFAULT,
                                   input  uvm_ral_map        map = null,
                                   input  uvm_sequence_base  parent = null,
                                   input  int                prior = -1,
                                   input  uvm_object         extension = null,
                                   input  string             fname = "",
                                   input  int                lineno = 0);

   extern virtual task burst_read(output uvm_ral::status_e   status,
                                  input  uvm_ral_mem_burst   burst,
                                  output uvm_ral_data_t      value[],
                                  input  uvm_ral::path_e     path   = uvm_ral::DEFAULT,
                                  input  uvm_ral_map         map = null,
                                  input  uvm_sequence_base   parent = null,
                                  input  int                 prior = -1,
                                  input  uvm_object          extension = null,
                                  input  string              fname = "",
                                  input  int                 lineno = 0);

   extern virtual task poke(output uvm_ral::status_e  status,
                            input  uvm_ral_addr_t     mem_addr,
                            input  uvm_ral_data_t     value,
                            input  string             kind = "",
                            input  uvm_sequence_base  parent = null,
                            input  uvm_object         extension = null,
                            input  string             fname = "",
                            input  int                lineno = 0);

   extern virtual task peek(output uvm_ral::status_e  status,
                            input  uvm_ral_addr_t     mem_addr,
                            output uvm_ral_data_t     value,
                            input  string             kind = "",
                            input  uvm_sequence_base  parent = null,
                            input  uvm_object         extension = null,
                            input  string             fname = "",
                            input  int                lineno = 0);

   extern virtual task readmemh(string filename);
   extern virtual task writememh(string filename);


   //-----------------
   // Group: Frontdoor
   //-----------------

   extern function void set_frontdoor(uvm_ral_mem_frontdoor ftdr,
                                      uvm_ral_map        map = null,
                                      string                fname = "",
                                      int                   lineno = 0);
   
   extern function uvm_ral_mem_frontdoor get_frontdoor(uvm_ral_map map = null);


   //----------------
   // Group: Backdoor
   //----------------

   local uvm_ral_mem_backdoor backdoor;
   local uvm_object_string_pool #(uvm_queue #(uvm_ral_hdl_path_concat)) hdl_paths_pool;

   extern function void set_backdoor (uvm_ral_mem_backdoor bkdr,
                                      string               fname = "",
                                      int                  lineno = 0);

   extern function uvm_ral_mem_backdoor get_backdoor();

   extern function void clear_hdl_path    (string kind = "RTL");
   extern function void add_hdl_path      (uvm_ral_hdl_path_concat path,
                                           string kind = "RTL");
   extern function bit  has_hdl_path      (string kind = "");
   extern function void get_hdl_path      (ref uvm_ral_hdl_path_concat paths[$],
                                           input string kind = "");
   extern function void get_full_hdl_path (ref uvm_ral_hdl_path_concat paths[$],
                                           input string kind = "");


   extern virtual function uvm_ral::status_e        backdoor_read_func(
                            input uvm_ral_addr_t    offset,
                            output uvm_ral_data_t   data,
                            input string            kind,
                            input uvm_sequence_base parent,
                            input uvm_object        extension,
                            input string            fname = "",
                            input int               lineno = 0);

   extern virtual protected task backdoor_read(
                            output uvm_ral::status_e status,
                            input uvm_ral_addr_t     offset,
                            output uvm_ral_data_t    data,
                            input string             kind,
                            input uvm_sequence_base  parent,
                            input uvm_object         extension,
                            input string             fname = "",
                            input int                lineno = 0);

   extern virtual task backdoor_write(
                            output uvm_ral::status_e status,
                            input uvm_ral_addr_t     offset,
                            input uvm_ral_data_t     data,
                            input string             kind,
                            input uvm_sequence_base  parent,
                            input uvm_object         extension,
                            input string             fname = "",
                            input int                lineno = 0);

   extern local function bit validate_burst(uvm_ral_mem_burst burst);


   //--------------------
   // Group: Standard Ops
   //--------------------

   extern virtual function void do_print (uvm_printer printer);
   extern virtual function string convert2string;
   extern virtual function uvm_object clone();
   extern virtual function void do_copy   (uvm_object rhs);
   extern virtual function bit do_compare (uvm_object  rhs,
                                          uvm_comparer comparer);
   extern virtual function void do_pack (uvm_packer packer);
   extern virtual function void do_unpack (uvm_packer packer);


   //-----------------
   // Group: Callbacks
   //-----------------

   virtual task pre_write(ref uvm_ral_addr_t   offset,
                          ref uvm_ral_data_t   wdat,
                          ref uvm_ral::path_e  path,
                          ref uvm_ral_map   map);
   endtask

   virtual task post_write(uvm_ral_addr_t        offset,
                           uvm_ral_data_t        wdat,
                           uvm_ral::path_e       path,
                           uvm_ral_map        map,
                           ref uvm_ral::status_e status);
   endtask

   virtual task pre_read(ref uvm_ral_addr_t  offset,
                         ref uvm_ral::path_e path,
                         ref uvm_ral_map  map);
   endtask

   virtual task post_read(input uvm_ral_addr_t    offset,
                          ref   uvm_ral_data_t    rdat,
                          input uvm_ral::path_e   path,
                          input uvm_ral_map    map,
                          ref   uvm_ral::status_e status);
   endtask

   virtual task pre_burst(uvm_tlm_gp::tlm_command kind,
                          uvm_ral_mem_burst       burst,
                          ref uvm_ral_data_t      wdat[],
                          ref uvm_ral::path_e     path,
                          ref uvm_ral_map      map);
   endtask

   virtual task post_burst(input uvm_tlm_gp::tlm_command kind,
                           input uvm_ral_mem_burst       burst,
                           ref   uvm_ral_data_t          data[],
                           input uvm_ral::path_e         path,
                           input uvm_ral_map          map,
                           ref   uvm_ral::status_e       status);
   endtask

endclass: uvm_ral_mem


//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

// new

function uvm_ral_mem::new (string           name,
                           longint unsigned size,
                           int unsigned     n_bits,
                           string           access = "RW",
                           int              has_cover = uvm_ral::NO_COVERAGE);

   super.new(name);
   this.locked = 0;
   if (n_bits == 0) begin
      `uvm_error("RAL", {"Memory '",get_full_name(),"' cannot have 0 bits"})
      n_bits = 1;
   end
   if (n_bits > `UVM_RAL_DATA_WIDTH) begin
      `uvm_error("RAL",
          $psprintf("Memory \"%s\" cannot have more than %0d bits (%0d)",
                   this.get_full_name(), `UVM_RAL_DATA_WIDTH, n_bits))
      n_bits = `UVM_RAL_DATA_WIDTH;
   end
   this.size      = size;
   this.n_bits    = n_bits;
   this.backdoor  = null;
   this.access    = access.toupper();
   this.has_cover = has_cover;

   hdl_paths_pool = new("hdl_paths");

endfunction: new


// configure

function void uvm_ral_mem::configure(uvm_ral_block  parent,
                                     string         hdl_path="");

   assert(parent!=null);

   this.parent   = parent;

   if (this.access != "RW" && this.access != "RO") begin
      `uvm_error("RAL", {"Memory '",get_full_name(),"' can only be RW or RO"})
      this.access = "RW";
   end

   this.n_bits   = n_bits;
   this.backdoor = null;

   begin
      uvm_mam_cfg cfg = new;

      cfg.n_bytes      = ((n_bits-1) / 8) + 1;
      cfg.start_offset = 0;
      cfg.end_offset   = size-1;

      cfg.mode     = uvm_mam::GREEDY;
      cfg.locality = uvm_mam::BROAD;

      this.mam = new(this.get_full_name(), cfg, this);
   end

   this.parent.add_mem(this);

   if (hdl_path != "")
     add_hdl_path('{'{hdl_path, -1, -1}});

endfunction: configure


// add_map

function void uvm_ral_mem::add_map(uvm_ral_map map);
  if (!maps.exists(map))
    maps[map] = 1;
endfunction


// Xlock_modelX

function void uvm_ral_mem::Xlock_modelX();
   this.locked = 1;
endfunction: Xlock_modelX


// get_full_name

function string uvm_ral_mem::get_full_name();
   uvm_ral_block blk;

   get_full_name = this.get_name();

   // Do not include top-level name in full name
   blk = this.get_block();

   if (blk == null)
     return get_full_name;

   if (blk.get_parent() == null)
     return get_full_name;

   get_full_name = {this.parent.get_full_name(), ".", get_full_name};

endfunction: get_full_name


// get_block

function uvm_ral_block uvm_ral_mem::get_block();
   get_block = this.parent;
endfunction: get_block


// get_n_maps

function int uvm_ral_mem::get_n_maps();
   return maps.num();
endfunction: get_n_maps


// get_maps

function void uvm_ral_mem::get_maps(ref uvm_ral_map maps[$]);
   foreach (this.maps[map])
     maps.push_back(map);
endfunction


// is_in_map

function bit uvm_ral_mem::is_in_map(uvm_ral_map map);
   if (maps.exists(map))
     return 1;
   foreach (maps[local_map]) begin
     uvm_ral_map parent_map = local_map.get_parent_map();
     while (parent_map != null) begin
       if (parent_map == map)
         return 1;
       parent_map = parent_map.get_parent_map();
     end
   end
   return 0;
endfunction


// get_local_map

function uvm_ral_map uvm_ral_mem::get_local_map(uvm_ral_map map, string caller="");
   if (map == null)
     return get_default_map();
   if (maps.exists(map))
     return map; 
   foreach (maps[local_map]) begin
     uvm_ral_map parent_map = local_map.get_parent_map();
     while (parent_map != null) begin
       if (parent_map == map)
         return local_map;
       parent_map = parent_map.get_parent_map();
     end
   end
   `uvm_warning("RAL", 
       {"Memory '",get_full_name(),"' is not contained within map '",map.get_full_name(),"'",
        (caller == "" ? "": {" (called from ",caller,")"})})
   return null;
endfunction


// get_default_map

function uvm_ral_map uvm_ral_mem::get_default_map(string caller="");

   // if mem is not associated with any may, return null
   if (maps.num() == 0) begin
      `uvm_warning("RAL", 
        {"Memory '",get_full_name(),"' is not registered with any map",
         (caller == "" ? "": {" (called from ",caller,")"})})
      return null;
   end

   // if only one map, choose that
   if (maps.num() == 1) begin
     void'(maps.first(get_default_map));
   end

   // try to choose one based on default_map in parent blocks.
   foreach (maps[map]) begin
     uvm_ral_block blk = map.get_parent();
     uvm_ral_map default_map = blk.get_default_map();
     if (default_map != null) begin
       uvm_ral_map local_map = get_local_map(default_map);
       if (local_map != null)
         return local_map;
     end
   end

   // if that fails, choose the first in this mem's maps

   void'(maps.first(get_default_map));

endfunction


// get_access

function string uvm_ral_mem::get_access(uvm_ral_map map = null);
   get_access = this.access;
   if (this.get_n_maps() == 1) return get_access;

   map = get_local_map(map, "get_access()");
   if (map == null) return get_access;

   // Is the memory restricted in this map?
   case (this.get_rights(map))
     "RW":
       // No restrictions
       return get_access;

     "RO":
       case (get_access)
         "RW",
         "RO": get_access = "RO";

         "WO": begin
            `uvm_error("RAL",
                       $psprintf("WO memory %s restricted to RO in map \"%s\"",
                                 this.get_full_name(), map.get_full_name()))
         end

         default:
           `uvm_error("RAL",
                      $psprintf("Invalid memory %s access mode \"%s\"",
                                this.get_full_name(), get_access))
       endcase

     "WO":
       case (get_access)
         "RW",
         "WO": get_access = "WO";

         "RO": begin
            `uvm_error("RAL",
                       $psprintf("RO memory %s restricted to WO in map \"%s\"",
                                 this.get_full_name(), get_access, map.get_full_name()))
         end

         default:
           `uvm_error("RAL",
                      $psprintf("Invalid memory %s access mode \"%s\"",
                                this.get_full_name(), get_access))
       endcase

     default:
       `uvm_error("RAL",
                  $psprintf("Shared memory \"%s\" is not shared in map \"%s\"",
                            this.get_full_name(), map.get_full_name()))
   endcase
endfunction: get_access


// get_rights

function string uvm_ral_mem::get_rights(uvm_ral_map map = null);

   uvm_ral_map_info info;

   // No right restrictions if not shared
   if (maps.num() <= 1) begin
      return "RW";
   end

   map = get_local_map(map,"get_rights()");

   if (map == null)
     return "RW";

   info = map.get_mem_map_info(this);
   return info.rights;

endfunction: get_rights


// get_offset

function uvm_ral_addr_t uvm_ral_mem::get_offset(uvm_ral_addr_t mem_addr = 0, uvm_ral_map map = null);

   uvm_ral_map_info map_info;
   uvm_ral_map orig_map = map;

   map = get_local_map(map,"get_offset()");

   if (map == null)
     return -1;
   
   map_info = map.get_mem_map_info(this);
   
   if (map_info.unmapped) begin
      `uvm_warning("RAL", {"Memory '",get_name(),
                   "' is unmapped in map '",
                   ((orig_map == null) ? map.get_full_name() : orig_map.get_full_name()),"'"})
      return -1;
   end
         
   return map_info.offset;

endfunction: get_offset



// get_virtual_registers

function void uvm_ral_mem::get_virtual_registers(ref uvm_ral_vreg regs[$]);
  foreach (this.XvregsX[i])
     regs.push_back(XvregsX[i]);
endfunction


// get_virtual_fields

function void uvm_ral_mem::get_virtual_fields(ref uvm_ral_vfield fields[$]);

  foreach (this.XvregsX[i])
    this.XvregsX[i].get_fields(fields);

endfunction: get_virtual_fields


// get_vfield_by_name

function uvm_ral_vfield uvm_ral_mem::get_vfield_by_name(string name);
  // Return first occurrence of vfield matching name
  uvm_ral_vfield vfields[$];

  this.get_virtual_fields(vfields);

  foreach (vfields[i])
    if (vfields[i].get_name() == name)
      return vfields[i];

  `uvm_warning("RAL", {"Unable to find virtual field '",name,
                       "' in memory '",get_full_name(),"'"})
   return null;
endfunction: get_vfield_by_name


// get_vreg_by_name

function uvm_ral_vreg uvm_ral_mem::get_vreg_by_name(string name);

  foreach (this.XvregsX[i])
    if (this.XvregsX[i].get_name() == name)
      return this.XvregsX[i];

  `uvm_warning("RAL", {"Unable to find virtual register '",name,
                       "' in memory '",get_full_name(),"'"})
  return null;

endfunction: get_vreg_by_name


// get_vreg_by_offset

function uvm_ral_vreg uvm_ral_mem::get_vreg_by_offset(bit [63:0] offset,
                                                      uvm_ral_map map = null);
   `uvm_error("RAL", "uvm_ral_mem::get_vreg_by_offset() not yet implemented")
   return null;
endfunction: get_vreg_by_offset



// get_addresses

function int uvm_ral_mem::get_addresses(uvm_ral_addr_t offset = 0, uvm_ral_map map=null, ref uvm_ral_addr_t addr[]);

   uvm_ral_map_info map_info;
   uvm_ral_map system_map;
   uvm_ral_map orig_map = map;

   map = get_local_map(map,"get_addresses()");

   if (map == null)
     return 0;

   map_info = map.get_mem_map_info(this);

   if (map_info.unmapped) begin
      `uvm_warning("RAL", {"Memory '",get_name(),
                   "' is unmapped in map '",
                   ((orig_map == null) ? map.get_full_name() : orig_map.get_full_name()),"'"})
      return 0;
   end

   //addr = map_info.addr;
   //system_map = map.get_root_map();
   //return system_map.get_n_bytes();

   return map.get_physical_addresses(map_info.offset,
                                     0,
                                     this.get_n_bytes(),
                                     addr);
endfunction


// get_address

function uvm_ral_addr_t uvm_ral_mem::get_address(uvm_ral_addr_t offset = 0, uvm_ral_map map = null);
   uvm_ral_addr_t  addr[];
   void'(get_addresses(offset, map, addr));
   return addr[0];
endfunction


// get_size

function longint unsigned uvm_ral_mem::get_size();
   get_size = this.size;
endfunction: get_size


// get_n_bits

function int unsigned uvm_ral_mem::get_n_bits();
   get_n_bits = this.n_bits;
endfunction: get_n_bits


// get_n_bytes

function int unsigned uvm_ral_mem::get_n_bytes();
   get_n_bytes = (this.n_bits - 1) / 8 + 1;
endfunction: get_n_bytes




//-----------
// ATTRIBUTES
//-----------

// set_attribute

function void uvm_ral_mem::set_attribute(string name,
                                         string value);
   if (name == "") begin
      `uvm_error("RAL", {"Cannot set anonymous attribute \"\" in memory '",
                         get_full_name(),"'"})
      return;
   end

   if (this.attributes.exists(name)) begin
      if (value != "") begin
         `uvm_warning("RAL", {"Redefining attribute '",name,"' in memory '",
                         get_full_name(),"' to '",value,"'"})
         this.attributes[name] = value;
      end
      else begin
         this.attributes.delete(name);
      end
      return;
   end

   if (value == "") begin
      `uvm_warning("RAL", {"Attempting to delete non-existent attribute '",
                          name, "' in memory '", get_full_name(), "'"})
      return;
   end

   this.attributes[name] = value;
endfunction: set_attribute


// get_attribute

function string uvm_ral_mem::get_attribute(string name,
                                           bit inherited = 1);
   if (inherited && parent != null)
      get_attribute = parent.get_attribute(name,1);

   if (get_attribute == "" && this.attributes.exists(name))
      return this.attributes[name];

   return "";
endfunction: get_attribute


// get_attributes

function void uvm_ral_mem::get_attributes(ref string names[string],
                                          input bit inherited = 1);
   // attributes at higher levels supercede those at lower levels
   if (inherited && parent != null)
     this.parent.get_attributes(names,1);

   foreach (attributes[nm])
     if (!names.exists(nm))
       names[nm] = attributes[nm];

endfunction: get_attributes



//---------
// COVERAGE
//---------


// can_cover

function bit uvm_ral_mem::can_cover(int models);
   return ((this.has_cover & models) == models);
endfunction: can_cover


// set_cover

function int uvm_ral_mem::set_cover(int is_on);
   if (is_on == uvm_ral::NO_COVERAGE) begin
      this.cover_on = is_on;
      return this.cover_on;
   end

   if (is_on & uvm_ral::ADDR_MAP) begin
      if (this.has_cover & uvm_ral::ADDR_MAP) begin
          this.cover_on |= uvm_ral::ADDR_MAP;
      end else begin
          `uvm_warning("RAL", $psprintf("\"%s\" - Cannot turn ON Address Map coverage becasue the corresponding coverage model was not generated.", this.get_full_name()));
      end
   end else begin
      return this.cover_on;
   end

   set_cover = this.cover_on;
endfunction: set_cover


// is_cover_on

function bit uvm_ral_mem::is_cover_on(int is_on = uvm_ral::ALL_COVERAGE);
   if (this.can_cover(is_on) == 0) return 0;
   return ((this.cover_on & is_on) == is_on);
endfunction: is_cover_on



// init

task uvm_ral_mem::init(output bit is_ok,
                       input  init_e pattern,
                       input  uvm_ral_data_t  data);
   int incr;
   is_ok = 0;

   if (this.backdoor == null) begin
      `uvm_error("RAL", $psprintf("No backdoor available to initialize memory %s", this.get_full_name()));
      return;
   end

   case (pattern)
   UNKNOWNS:
     begin
        data = 'x;
        incr = 0;
     end

   ZEROES:
     begin
        data = '0;
        incr = 0;
     end

   ONES:
     begin
        data = '1;
        incr = 0;
     end

   VALUE:
     begin
        incr = 0;
     end

   INCR:
     begin
        incr = 1;
     end

   DECR:
     begin
        incr = -1;
     end
   endcase

   // ToDo...
endtask:init


//-----------
// HDL ACCESS
//-----------

// write

task uvm_ral_mem::write(output uvm_ral::status_e status,
                        input  uvm_ral_addr_t    mem_addr,
                        input  uvm_ral_data_t    value,
                        input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                        input  uvm_ral_map       map = null,
                        input  uvm_sequence_base parent = null,
                        input  int               prior = -1,
                        input  uvm_object        extension = null,
                        input  string            fname = "",
                        input  int               lineno = 0);
   uvm_ral_mem_cb_iter cbs = new(this);

   uvm_ral_map local_map, system_map;
   uvm_ral_map_info map_info;

   this.fname = fname;
   this.lineno = lineno;
   this.write_in_progress = 1'b1;
   status = uvm_ral::ERROR;
   
   if (path == uvm_ral::DEFAULT)
     path = this.parent.get_default_path();

   if (path == uvm_ral::BACKDOOR) begin
      if (this.backdoor == null && !has_hdl_path()) begin
         `uvm_warning("RAL",
            {"No backdoor access available for memory '",get_full_name(),
            "' . Using frontdoor instead."})
         path = uvm_ral::BFM;
      end
      else
        map = uvm_ral_map::backdoor;
   end

   if (path != uvm_ral::BACKDOOR) begin

     local_map = get_local_map(map,"write()");

     if (local_map == null || !maps.exists(local_map)) begin
        `uvm_error(get_type_name(), 
           {"No transactor available to physically access memory from map '",
            map.get_full_name(),"'"})
        return;
     end

     map_info = local_map.get_mem_map_info(this);

     if (map == null)
       map = local_map;
   end


   // PRE-WRITE CBS
   this.pre_write(mem_addr, value, path, map);
   for (uvm_ral_mem_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.pre_write(this, mem_addr, value, path, map);
   end

   // EXECUTE WRITE...
   case (path)
      
      uvm_ral::BFM: begin

         if (local_map == null)
           return;

         system_map = local_map.get_root_map();

         // ...VIA USER FRONTDOOR
         if (map_info.mem_frontdoor != null) begin
            uvm_ral_mem_frontdoor fd = map_info.mem_frontdoor;
            fd.mem       = this;
            fd.is_write  = 1;
            fd.burst     = null;
            fd.offset    = mem_addr;
            fd.data      = '{value};
            fd.extension = extension;
            fd.fname     = fname;
            fd.lineno    = lineno;
            if (fd.sequencer == null)
              fd.start(system_map.get_sequencer(), parent);
            else
              fd.start(fd.get_sequencer(), parent);
            status = fd.status;
         end

         // ...VIA BUILT-IN FRONTDOOR
         else begin
            uvm_ral_adapter    adapter = map.get_adapter();
            uvm_sequencer_base sequencer = map.get_sequencer();

            uvm_ral_addr_t  addr[];
            int w, j;
            int n_bits;
         
            if (map_info.unmapped) begin
               `uvm_error("RAL", {"Memory '",get_full_name(),"' unmapped in map '",
                          map.get_full_name(),"' and does not have a user-defined frontdoor"})
               return;
            end
         
            w = local_map.get_physical_addresses(map_info.offset,
                                                 mem_addr,
                                                 this.get_n_bytes(),
                                                 addr);
            j = 0;
            n_bits = this.get_n_bits;
            foreach (addr[i]) begin
               uvm_ral_data_t  data;
               uvm_rw_access rw_access;
               uvm_sequence_item bus_req = new("bus_mem_wr");

               data = (value >> (j*8)) & ((1'b1 << (w * 8))-1);
               
               status = uvm_ral::ERROR;
                           
               `uvm_info(get_type_name(), $psprintf("Writing 'h%0h at 'h%0h via map \"%s\"...",
                                                    data, addr[i], map.get_full_name()), UVM_HIGH);
                        
               rw_access = uvm_rw_access::type_id::create("rw_access",,{sequencer.get_full_name(),".",parent.get_full_name()});
               rw_access.element = this;
               rw_access.element_kind = uvm_ral::REG;
               rw_access.kind = uvm_ral::WRITE;
               rw_access.addr = addr[i];
               rw_access.value = value;
               rw_access.data = data;
               rw_access.n_bits = (n_bits > w*8) ? w*8 : n_bits;
               rw_access.byte_en = '1;
               rw_access.extension = extension;

               bus_req.m_start_item(sequencer,parent,prior);
               parent.mid_do(rw_access);
               bus_req = adapter.ral2bus(rw_access);
               bus_req.m_finish_item(sequencer,parent);
               bus_req.end_event.wait_on();
               if (adapter.provides_responses) begin
                 uvm_sequence_item bus_rsp;
                 uvm_ral::access_e op;
                 parent.get_base_response(bus_rsp);
                 adapter.bus2ral(bus_rsp,rw_access);
               end
               else begin
                 adapter.bus2ral(bus_req,rw_access);
               end
               status = rw_access.status;
               parent.post_do(rw_access);

               `uvm_info(get_type_name(), $psprintf("Wrote 'h%0h at 'h%0h via map \"%s\": %s...",
                                                    data, addr[i], map.get_full_name(), status.name()), UVM_HIGH);

               if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) break;
               j += w;
               n_bits -= w * 8;
            end
         end

         if (this.cover_on) 
            this.parent.XsampleX(map_info.offset + 
               mem_addr * (((this.get_n_bytes()-1)/local_map.get_n_bytes())+1), system_map);
      end
      
      uvm_ral::BACKDOOR: begin
         // Mimick front door access: Do not write read-only memories
         if (this.get_access(map) == "RW") begin
            this.poke(status, mem_addr, value, "", parent, extension);
         end else status = uvm_ral::IS_OK;
      end
   endcase

   this.post_write(mem_addr, value, path, map, status);
   for (uvm_ral_mem_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_write(this, mem_addr, value, path, map, status);
   end

   `uvm_info("RAL", $psprintf("Wrote memory \"%s\"[%0d] via %s: with 'h%h",
                              this.get_full_name(), mem_addr,
                              (path == uvm_ral::BFM) ? "frontdoor" : "backdoor",
                              value),UVM_MEDIUM )
   
   this.fname = "";
   this.lineno = 0;
   this.write_in_progress = 1'b0;
endtask: write


// read

task uvm_ral_mem::read(output uvm_ral::status_e  status,
                       input  uvm_ral_addr_t     mem_addr,
                       output uvm_ral_data_t     value,
                       input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                       input  uvm_ral_map        map = null,
                       input  uvm_sequence_base  parent = null,
                       input  int                prior = -1,
                       input  uvm_object         extension = null,
                       input  string             fname = "",
                       input  int                lineno = 0);
   uvm_ral_mem_cb_iter cbs = new(this);
   uvm_ral_map local_map, system_map;
   uvm_ral_map_info map_info;
   
   this.fname = fname;
   this.lineno = lineno;
   status = uvm_ral::ERROR;
   read_in_progress = 1'b1;
   
   if (path == uvm_ral::DEFAULT)
     path = this.parent.get_default_path();


   if (path == uvm_ral::BACKDOOR) begin
      if (this.backdoor == null && !has_hdl_path()) begin
         `uvm_warning("RAL",
            {"No backdoor access available for memory '",get_full_name(),
            "' . Using frontdoor instead."})
         path = uvm_ral::BFM;
      end
      else
        map = uvm_ral_map::backdoor;
   end

   if (path != uvm_ral::BACKDOOR) begin

     local_map = get_local_map(map,"write()");

     if (local_map == null || !maps.exists(local_map)) begin
        `uvm_error(get_type_name(), 
           {"No transactor available to physically access memory from map '",
            map.get_full_name(),"'"})
        return;
     end

     map_info = local_map.get_mem_map_info(this);

     if (map == null)
       map = local_map;
   end


   // PRE-READ CBS
   this.pre_write(mem_addr, value, path, map);
   this.pre_read(mem_addr, path, map);
   for (uvm_ral_mem_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.pre_read(this, mem_addr, path, map);
   end


   // EXECUTE READ
   case (path)
      
      uvm_ral::BFM: begin
         
         if (local_map == null)
            return;

         system_map = local_map.get_root_map();
         
         // ...VIA USER FRONTDOOR
         if (map_info.mem_frontdoor != null) begin
            uvm_ral_mem_frontdoor fd = map_info.mem_frontdoor;
            fd.mem       = this;
            fd.is_write  = 0;
            fd.burst     = null;
            fd.offset    = mem_addr;
            fd.extension = extension;
            fd.fname     = fname;
            fd.lineno    = lineno;
            if (fd.sequencer == null)
              fd.start(system_map.get_sequencer(), parent);
            else
              fd.start(fd.get_sequencer(), parent);
            value  = fd.data[0];
            status = fd.status;
         end

         // ...VIA BUILT-IN FRONTDOOR
         else begin
            uvm_ral_adapter    adapter = map.get_adapter();
            uvm_sequencer_base sequencer = map.get_sequencer();

            uvm_ral_addr_t  addr[];
            int w, j;
            int n_bits;
         
            if (map_info.unmapped) begin
               `uvm_error("RAL", {"Memory '",get_full_name(),"' unmapped in map '",
                          map.get_full_name(),"' and does not have a user-defined frontdoor"})
               return;
            end
         
            w = local_map.get_physical_addresses(map_info.offset,
                                                 mem_addr,
                                                 this.get_n_bytes(),
                                                 addr);
            j = 0;
            n_bits = this.get_n_bits();
            value = 0;
            foreach (addr[i]) begin
               uvm_ral_data_logic_t  data;

               uvm_sequence_item bus_req = new("bus_mem_rd");
               uvm_rw_access rw_access;
               
               `uvm_info(get_type_name(), $psprintf("Reading address 'h%0h via map \"%s\"...",
                                                    addr[i], map.get_full_name()), UVM_HIGH);
                        
                rw_access = uvm_rw_access::type_id::create("rw_access",,{sequencer.get_full_name(),".",parent.get_full_name()});
                rw_access.element = this;
                rw_access.element_kind = uvm_ral::REG;
                rw_access.kind = uvm_ral::READ;
                rw_access.addr = addr[i];
                rw_access.data = 'h0;
                rw_access.n_bits = (n_bits > w*8) ? w*8 : n_bits;
                rw_access.byte_en = '1;
                rw_access.extension = extension;
                            
                bus_req.m_start_item(sequencer,parent,prior);
                parent.mid_do(rw_access);
                bus_req = adapter.ral2bus(rw_access);
                bus_req.m_finish_item(sequencer,parent);
                bus_req.end_event.wait_on();
                if (adapter.provides_responses) begin
                   uvm_sequence_item bus_rsp;
                   uvm_ral::access_e op;
                   parent.get_base_response(bus_rsp);
                   adapter.bus2ral(bus_rsp,rw_access);
                end
                else begin
                  adapter.bus2ral(bus_req,rw_access);
                end
                data = rw_access.data & ((1<<w*8)-1);
                if (rw_access.status == uvm_ral::IS_OK && ^data === 1'bx)
                  rw_access.status = uvm_ral::HAS_X;
                status = rw_access.status;

                `uvm_info(get_type_name(), $psprintf("Read 'h%0h at 'h%0h via map \"%s\": %s...",
                                                    data, addr[i], map.get_full_name(), status.name()), UVM_HIGH);

                if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) break;

                value |= data << j*8;
                rw_access.value = value;
                parent.post_do(rw_access);
                j += w;
                n_bits -= w * 8;
            end
         end

         if (this.cover_on) 
            this.parent.XsampleX(map_info.offset +
               mem_addr * (((this.get_n_bytes()-1)/local_map.get_n_bytes())+1), system_map);
      end
      
      // ...VIA USER BACKDOOR
      uvm_ral::BACKDOOR: begin
         this.peek(status, mem_addr, value, "", parent, extension);
      end
   endcase

   // POST-READ CBS
   this.post_read(mem_addr, value, path, map, status);
   for (uvm_ral_mem_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_read(this, mem_addr, value, path, map, status);
   end

   `uvm_info("RAL", $psprintf("Read memory \"%s\"[%0d] via %s: 'h%h",
                              this.get_full_name(), mem_addr,
                              (path == uvm_ral::BFM) ? {"map ",map.get_full_name()} : "backdoor",
                              value),UVM_MEDIUM);
   read_in_progress = 1'b0;
   this.fname = "";
   this.lineno = 0;
endtask: read


// validate_burst

function bit uvm_ral_mem::validate_burst(uvm_ral_mem_burst burst);
   if (burst.start_offset >= this.get_size()) begin
      `uvm_error("RAL", $psprintf("Starting burst offset 'h%0h is greater than number of memory locations ('h%0h)",
                                     burst.start_offset, this.get_size()));
      return 0;
   end

   if (burst.max_offset >= this.get_size()) begin
      `uvm_error("RAL", $psprintf("Maximum burst offset 'h%0h is greater than number of memory locations ('h%0h)",
                                     burst.max_offset, this.get_size()));
      return 0;
   end

   if (burst.n_beats == 0) begin
      `uvm_error("RAL", "Zero-length burst");
      return 0;
   end

   if (burst.start_offset > burst.max_offset) begin
      `uvm_error("RAL", $psprintf("Starting burst offset ('h%0h) greater than maximum burst offset ('h%0h)",
                                     burst.start_offset, burst.max_offset));
      return 0;
   end

   if (burst.n_beats > 1 &&
       burst.start_offset + burst.incr_offset >= burst.max_offset) begin
      `uvm_error("RAL", $psprintf("First burst offset increment 'h%0h+%0h is greater than maximum burst offset ('h%0h)",
                                     burst.start_offset, burst.incr_offset,
                                     burst.max_offset));
      return 0;
   end

   return 1;
endfunction: validate_burst


// burst_write

task uvm_ral_mem::burst_write(output uvm_ral::status_e  status,
                              input  uvm_ral_mem_burst  burst,
                              input  uvm_ral_data_t     value[],
                              input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                              input  uvm_ral_map        map = null,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);
   uvm_ral_mem_cb_iter cbs = new(this);
   uvm_ral_map local_map, system_map;
   uvm_ral_map_info map_info;
   
   this.fname = fname;
   this.lineno = lineno;
   status = uvm_ral::ERROR;
   write_in_progress = 1'b1;
   
   if (path == uvm_ral::DEFAULT)
     path = this.parent.get_default_path();

   local_map = get_local_map(map,"read()");

   if (local_map != null)
     map_info = local_map.get_mem_map_info(this);

   this.pre_burst(uvm_tlm_gp::TLM_WRITE_COMMAND, burst, value, path, map);

   // PRE-WRITE CBS
   for (uvm_ral_mem_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.pre_burst(this, uvm_tlm_gp::TLM_WRITE_COMMAND, burst, value, path, map);
   end

   if (!this.validate_burst(burst))
     return;

   // EXECUTE WRITE BURST...
   case (path)
      
      uvm_ral::BFM: begin
         if (local_map == null)
            return;

         system_map = local_map.get_root_map();
         
         // ...VIA USER FRONTDOOR
         if (map_info.mem_frontdoor != null) begin
            uvm_ral_mem_frontdoor fd = map_info.mem_frontdoor;
            fd.mem       = this;
            fd.is_write  = 0;
            fd.burst     = burst;
            fd.data      = value;
            fd.extension = extension;
            fd.fname     = fname;
            fd.lineno    = lineno;
            if (fd.sequencer == null)
              fd.start(system_map.get_sequencer(), parent);
            else
              fd.start(fd.get_sequencer(), parent);
            status = fd.status;
         end

         // ...VIA BUILT-IN FRONTDOOR
         else begin
            uvm_ral_addr_t  addr[];
            int w;
            int n_bits;
         
            if (map_info.unmapped) begin
               `uvm_error("RAL", {"Memory '",get_full_name(),"' unmapped in map '",
                          map.get_full_name(),"' and does not have a user-defined frontdoor"})
               return;
            end
         
            w = local_map.get_physical_addresses(map_info.offset,
                                                 burst.start_offset,
                                                 this.get_n_bytes(),
                                                 addr);
            n_bits = this.get_n_bits;
            // Cannot burst memory through a narrower datapath
            if (n_bits > w*8) begin
               `uvm_error("RAL", $psprintf("Cannot burst-write a %0d-bit memory through a narrower data path (%0d bytes)",
                                              n_bits, w));
               return;
            end
            // Translate offsets into addresses
            begin
               uvm_ral_addr_t  start, incr, max;

               start = addr[0];

               w = local_map.get_physical_addresses(map_info.offset,
                                                    burst.start_offset + burst.incr_offset,
                                                    this.get_n_bytes(),
                                                    addr);
               incr = addr[0] - start;

               w = local_map.get_physical_addresses(map_info.offset,
                                                    burst.max_offset,
                                                    this.get_n_bytes(),
                                                    addr);

               max = addr[addr.size()-1];

               /*sqr.burst_write(status, start, incr, max, value,
                               map.get_external_map(sqr),
                               parent, extension, n_bits,
                               fname, lineno);*/
            end
         end

         if (this.cover_on) begin
            uvm_ral_addr_t  addr;
            for (addr = burst.start_offset;
                 addr <= burst.max_offset;
                 addr += burst.incr_offset) begin
               this.parent.XsampleX(map_info.offset + addr, map);
            end
         end
      end
      
      // ...VIA USER BACKDOOR
      uvm_ral::BACKDOOR: begin
         // Mimick front door access: Do not write read-only memories
         if (this.get_access(map) == "RW") begin
            uvm_ral_addr_t  addr;
            addr = burst.start_offset;
            foreach (value[i]) begin
               this.poke(status, addr, value[i], "", parent, extension);
               if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) return;
               addr += burst.incr_offset;
               if (addr > burst.max_offset) begin
                  addr -= (burst.max_offset - burst.start_offset - 1);
               end
            end
         end
         else status = uvm_ral::IS_OK;
      end
   endcase

   // POST-WRITE CBS
   this.post_burst(uvm_tlm_gp::TLM_WRITE_COMMAND, burst, value, path, map, status);
   for (uvm_ral_mem_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_burst(this, uvm_tlm_gp::TLM_WRITE_COMMAND, burst, value, path, map, status);
   end

   this.fname = "";
   this.lineno = 0;
   this.write_in_progress = 1'b0;
endtask: burst_write


// burst_read

task uvm_ral_mem::burst_read(output uvm_ral::status_e  status,
                             input  uvm_ral_mem_burst  burst,
                             output uvm_ral_data_t     value[],
                             input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                             input  uvm_ral_map     map = null,
                             input  uvm_sequence_base  parent = null,
                             input  int                prior = -1,
                             input  uvm_object         extension = null,
                             input  string             fname = "",
                             input  int                lineno = 0);
   uvm_ral_mem_cb_iter cbs = new(this);
   uvm_ral_map local_map, system_map;
   uvm_ral_map_info map_info;
   
   this.fname = fname;
   this.lineno = lineno;
   status = uvm_ral::ERROR;
   read_in_progress = 1'b1;
   
   if (path == uvm_ral::DEFAULT)
     path = this.parent.get_default_path();

   local_map = get_local_map(map,"read()");

   if (local_map != null)
     map_info = local_map.get_mem_map_info(this);

   begin
      uvm_ral_data_t  junk[];

      this.pre_burst(uvm_tlm_gp::TLM_READ_COMMAND, burst, junk, path, map);

      // PRE-READ CBS
      for (uvm_ral_mem_cbs cb = cbs.first(); cb != null;
           cb = cbs.next()) begin
         cb.fname = this.fname;
         cb.lineno = this.lineno;
         cb.pre_burst(this, uvm_tlm_gp::TLM_READ_COMMAND, burst, junk, path, map);
      end
   end

   if (!this.validate_burst(burst))
      return;

   // EXECUTE READ BURST...
   case (path)
      
      uvm_ral::BFM: begin
         if (local_map == null)
            return;

         system_map = local_map.get_root_map();
         
         // ...VIA USER FRONTDOOR
         if (map_info.mem_frontdoor != null) begin
            uvm_ral_mem_frontdoor fd = map_info.mem_frontdoor;
            fd.mem       = this;
            fd.is_write  = 0;
            fd.burst     = burst;
            fd.extension = extension;
            fd.fname     = fname;
            fd.lineno    = lineno;
            if (fd.sequencer == null)
              fd.start(system_map.get_sequencer(), parent);
            else
              fd.start(fd.get_sequencer(), parent);
            value  = fd.data;
            status = fd.status;
         end
         else begin
            uvm_ral_addr_t  addr[];
            int n_bits, w;
         
            if (map_info.unmapped) begin
               `uvm_error("RAL", {"Memory '",get_full_name(),"' unmapped in map '",
                          map.get_full_name(),"' and does not have a user-defined frontdoor"})
               return;
            end
         
            w = local_map.get_physical_addresses(map_info.offset,
                                                 burst.start_offset,
                                                 this.get_n_bytes(),
                                                 addr);
            n_bits = this.get_n_bits();
            // Cannot burst memory through a narrower datapath
            if (n_bits > w*8) begin
               `uvm_error("RAL", $psprintf("Cannot burst-write a %0d-bit memory through a narrower data path (%0d bytes)",
                                              n_bits, w));
               return;
            end
            // Translate the offset-based burst into address-based burst
            begin
               uvm_ral_addr_t  start, incr, max;

               start = addr[0];

               w = local_map.get_physical_addresses(map_info.offset,
                                                    burst.start_offset + burst.incr_offset,
                                                    this.get_n_bytes(),
                                                    addr);
               incr = addr[0] - start;

               w = local_map.get_physical_addresses(map_info.offset,
                                                    burst.max_offset,
                                                    this.get_n_bytes(),
                                                    addr);

               max = addr[addr.size()-1];

               /*sqr.burst_read(status, start, incr, max,
                              burst.n_beats, value,
                              map.get_external_map(sqr),
                              parent, extension, n_bits,
                              fname, lineno);*/
            end
         end

         if (this.cover_on) begin
            uvm_ral_addr_t  addr;
            for (addr = burst.start_offset;
                 addr <= burst.max_offset;
                 addr += burst.incr_offset) begin
               this.parent.XsampleX(map_info.offset + addr, map);
            end
         end
      end
      
   // ...VIA USER BACKDOOR
      uvm_ral::BACKDOOR: begin
         uvm_ral_addr_t  addr;
         value = new [burst.n_beats];
         addr = burst.start_offset;
         foreach (value[i]) begin
            this.peek(status, addr, value[i], "", parent);
            if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) return;
            addr += burst.incr_offset;
            if (addr > burst.max_offset) begin
               addr -= (burst.max_offset - burst.start_offset - 1);
            end
         end
      end
   endcase

   // POST-READ CBS
   this.post_burst(uvm_tlm_gp::TLM_READ_COMMAND, burst, value, path, map, status);
   for (uvm_ral_mem_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_burst(this, uvm_tlm_gp::TLM_READ_COMMAND, burst, value, path, map, status);
   end

   this.fname = "";
   this.lineno = 0;
   read_in_progress = 1'b0;
endtask: burst_read


//-------
// ACCESS
//-------

// poke

task uvm_ral_mem::poke(output uvm_ral::status_e status,
                       input  uvm_ral_addr_t    mem_addr,
                       input  uvm_ral_data_t    value,
                       input  string            kind = "",
                       input  uvm_sequence_base parent = null,
                       input  uvm_object        extension = null,
                       input  string            fname = "",
                       input  int               lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   if (this.backdoor == null && !has_hdl_path(kind)) begin
      `uvm_error("RAL", $psprintf("No backdoor access available in memory %s", this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   if (backdoor != null)
     this.backdoor.write(status, mem_addr, value, parent, extension);
   else
     this.backdoor_write(status, mem_addr, value, kind, parent, extension, fname, lineno);

   `uvm_info("RAL", $psprintf("Poked memory \"%s\"[%0d] with: 'h%h",
                              this.get_full_name(), mem_addr, value),UVM_MEDIUM);
   this.fname = "";
   this.lineno = 0;
endtask: poke


// peek

task uvm_ral_mem::peek(output uvm_ral::status_e status,
                       input  uvm_ral_addr_t    mem_addr,
                       output uvm_ral_data_t    value,
                       input  string            kind = "",
                       input  uvm_sequence_base parent = null,
                       input  uvm_object        extension = null,
                       input  string            fname = "",
                       input  int               lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   if (this.backdoor == null && !has_hdl_path(kind)) begin
      `uvm_error("RAL", $psprintf("No backdoor access available in memory %s", this.get_full_name()));
      status = uvm_ral::ERROR;
      return;
   end

   if (backdoor != null)
     this.backdoor.read(status, mem_addr, value, parent, extension);
   else
     this.backdoor_read(status, mem_addr, value, kind, parent, extension, fname, lineno);

   `uvm_info("RAL", $psprintf("Peeked memory \"%s\"[%0d]: 'h%h",
                              this.get_full_name(), mem_addr, value),UVM_MEDIUM);
   this.fname = "";
   this.lineno = 0;
endtask: peek


// readmemh

task uvm_ral_mem::readmemh(string filename);
endtask: readmemh


// writememh

task uvm_ral_mem::writememh(string filename);
endtask: writememh


//-----------------
// Group- Frontdoor
//-----------------

// set_frontdoor

function void uvm_ral_mem::set_frontdoor(uvm_ral_mem_frontdoor ftdr,
                                         uvm_ral_map           map = null,
                                         string                fname = "",
                                         int                   lineno = 0);
   uvm_ral_map_info map_info;
   this.fname = fname;
   this.lineno = lineno;

   map = get_local_map(map, "set_frontdoor()");

   if (map == null) begin
      `uvm_error("RAL", {"Memory '",get_full_name(),
                 "' not found in map '", map.get_full_name(),"'"})
      return;
   end

   map_info = map.get_mem_map_info(this);
   map_info.mem_frontdoor = ftdr;

endfunction: set_frontdoor


// get_frontdoor

function uvm_ral_mem_frontdoor uvm_ral_mem::get_frontdoor(uvm_ral_map map = null);
   uvm_ral_map_info map_info;

   map = get_local_map(map, "set_frontdoor()");

   if (map == null) begin
      `uvm_error("RAL", {"Memory '",get_full_name(),
                 "' not found in map '", map.get_full_name(),"'"})
      return null;
   end

   map_info = map.get_mem_map_info(this);
   return map_info.mem_frontdoor;

endfunction: get_frontdoor


//----------------
// Group- Backdoor
//----------------

// set_backdoor

function void uvm_ral_mem::set_backdoor(uvm_ral_mem_backdoor bkdr,
                                        string               fname = "",
                                        int                  lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   this.backdoor = bkdr;
endfunction: set_backdoor


// get_backdoor

function uvm_ral_mem_backdoor uvm_ral_mem::get_backdoor();
   get_backdoor = this.backdoor;
endfunction: get_backdoor


// backdoor_read_func

function uvm_ral::status_e  uvm_ral_mem::backdoor_read_func(
                    input uvm_ral_addr_t    offset,
                    output uvm_ral_data_t   data,
                    input string             kind,
                    input uvm_sequence_base parent,
                    input uvm_object        extension,
                    input string            fname="",
                    input int               lineno=0);
  uvm_ral_hdl_path_concat paths[$];
  uvm_ral_data_t val;
  string idx;
  bit ok=1;

  idx.itoa(offset);

  get_full_hdl_path(paths,kind);

  foreach (paths[i]) begin
     uvm_ral_hdl_path_concat hdl_slices = paths[i];
     val = 0;
     foreach (hdl_slices[j]) begin
        if (hdl_slices[j].offset < 0) begin
           ok &= uvm_hdl_read({hdl_slices[j].path, "[", idx, "]"},val);
           continue;
        end
        begin
           uvm_ral_data_t slice;
           int k = hdl_slices[j].offset;
           ok &= uvm_hdl_read({hdl_slices[j].path,"[", idx, "]"}, slice);
           repeat (hdl_slices[j].size) begin
              val[k++] = slice[0];
              slice >>= 1;
           end
        end
     end

     if (i == 0) data = val;

     if (val != data) begin
        `uvm_error("RAL", $psprintf("Backdoor read of register with multiple HDL copies: values are not the same: %0h at path '%s', and %0h at path '%s'. Returning first value.",
                                    this.get_full_name(),
                                    data, uvm_ral_concat2string(paths[0]),
                                    val, uvm_ral_concat2string(paths[i]))); 
        return uvm_ral::ERROR;
      end
  end

  return (ok) ? uvm_ral::IS_OK : uvm_ral::ERROR;
endfunction


// backdoor_read

task uvm_ral_mem::backdoor_read( output uvm_ral::status_e status,
                                 input uvm_ral_addr_t     offset,
                                 output uvm_ral_data_t    data,
                                 input string             kind,
                                 input uvm_sequence_base  parent,
                                 input uvm_object         extension,
                                 input string             fname="",
                                 input int                lineno=0);
  status = backdoor_read_func(offset,data,kind,parent,extension,fname,lineno);
endtask


// backdoor_write

task uvm_ral_mem::backdoor_write(output uvm_ral::status_e status,
                                 input uvm_ral_addr_t     offset,
                                 input uvm_ral_data_t     data,
                                 input string             kind,
                                 input uvm_sequence_base  parent,
                                 input uvm_object         extension,
                                 input string             fname="",
                                 input int                lineno=0);
  uvm_ral_hdl_path_concat paths[$];
  string idx;
  bit ok=1;

  idx.itoa(offset);
   
  get_full_hdl_path(paths,kind);
   
  foreach (paths[i]) begin
     uvm_ral_hdl_path_concat hdl_slices = paths[i];
     foreach (hdl_slices[j]) begin
        if (hdl_slices[j].offset < 0) begin
           ok &= uvm_hdl_deposit({hdl_slices[j].path,"[", idx, "]"},data);
           continue;
        end
        begin
           uvm_ral_data_t slice;
           slice = data >> hdl_slices[j].offset;
           slice &= (1 << hdl_slices[j].size)-1;
           ok &= uvm_hdl_deposit({hdl_slices[j].path, "[", idx, "]"}, slice);
        end
     end
  end
  status = (ok ? uvm_ral::IS_OK : uvm_ral::ERROR);
endtask




// clear_hdl_path

function void uvm_ral_mem::clear_hdl_path(string kind = "RTL");
  if (kind == "ALL") begin
    hdl_paths_pool = new("hdl_paths");
    return;
  end

  if (kind == "")
    kind = parent.get_default_hdl_path();

  if (!hdl_paths_pool.exists(kind)) begin
    `uvm_warning("RAL",{"Unknown HDL Abstraction '",kind,"'"})
    return;
  end

  hdl_paths_pool.delete(kind);
endfunction


// add_hdl_path

function void uvm_ral_mem::add_hdl_path(uvm_ral_hdl_path_concat path,
                                        string kind = "RTL");

  uvm_queue #(uvm_ral_hdl_path_concat) paths;

  //paths = hdl_paths_pool.get(kind);

  //paths.push_back(path);

endfunction


// has_hdl_path

function bit  uvm_ral_mem::has_hdl_path(string kind = "");
  if (kind == "")
    kind = parent.get_default_hdl_path();
  
  // TODO: fix
  return 0;
  //return this.hdl_paths_pool.exists(kind);
endfunction


// get_hdl_path

function void uvm_ral_mem::get_hdl_path(ref uvm_ral_hdl_path_concat paths[$],
                                        input string kind = "");

  uvm_queue #(uvm_ral_hdl_path_concat) hdl_paths;

  if (kind == "")
     kind = parent.get_default_hdl_path();

  if (!has_hdl_path(kind)) begin
    `uvm_error("RAL",{"Memory does not have hdl path defined for abstraction '",kind,"'"})
    return;
  end

  hdl_paths = hdl_paths_pool.get(kind);

  for (int i=0; i<hdl_paths.size();i++) begin
     paths.push_back(hdl_paths.get(i));
  end

endfunction


// get_full_hdl_path

function void uvm_ral_mem::get_full_hdl_path(ref uvm_ral_hdl_path_concat paths[$],
                                             input string kind = "");

   if (kind == "")
      kind = parent.get_default_hdl_path();
   
   if (!has_hdl_path(kind)) begin
      `uvm_error("RAL",{"Memory does not have hdl path defined for abstraction '",kind,"'"})
      return;
   end

   begin
      uvm_queue #(uvm_ral_hdl_path_concat) hdl_paths = hdl_paths_pool.get(kind);
      string parent_paths[$];

      parent.get_full_hdl_path(parent_paths,kind);

      for (int i=0; i<hdl_paths.size();i++) begin
         uvm_ral_hdl_path_concat hdl_slices = hdl_paths.get(i);

         foreach (parent_paths[j])  begin
            foreach (hdl_slices[k]) begin
               if (hdl_slices[k].path == "")
                  hdl_slices[k].path = parent_paths[j];
               else
                  hdl_slices[k].path = { parent_paths[j], ".", hdl_slices[k].path };
            end
         end
         paths.push_back(hdl_slices);
      end
   end
endfunction


// set_parent

function void uvm_ral_mem::set_parent(uvm_ral_block parent);
  this.parent = parent;
endfunction


// get_parent

function uvm_ral_block uvm_ral_mem::get_parent();
   return get_block();
endfunction


// convert2string

function string uvm_ral_mem::convert2string();

   string res_str = "";
   string prefix = "";

   $sformat(convert2string, "%sMemory %s -- %0dx%0d bits", prefix,
            this.get_full_name(), this.get_size(), this.get_n_bits());

   if (this.maps.num()==0)
     convert2string = {convert2string, "  (unmapped)\n"};
   else
     convert2string = {convert2string, "\n"};
   foreach (this.maps[map]) begin
     uvm_ral_map parent_map = map;
     int unsigned offset;
     while (parent_map != null) begin
       uvm_ral_map this_map = parent_map;
       parent_map = this_map.get_parent_map();
       offset = parent_map == null ? this_map.get_base_addr(uvm_ral::NO_HIER) : parent_map.get_submap_offset(this_map);
       prefix = {prefix, "  "};
       $sformat(convert2string, "%sMapped in '%s' -- %0d bytes, %s, offset 'h%0h\n", prefix,
            this_map.get_full_name(), this_map.get_n_bytes(), this_map.get_endian(), offset);
     end
   end
   prefix = "  ";
   if (read_in_progress == 1'b1) begin
      if (fname != "" && lineno != 0)
         $sformat(res_str, "%s:%0d ",fname, lineno);
      convert2string = {convert2string, "  ", res_str, "currently executing read method"}; 
   end
   if ( write_in_progress == 1'b1) begin
      if (fname != "" && lineno != 0)
         $sformat(res_str, "%s:%0d ",fname, lineno);
      convert2string = {convert2string, "  ", res_str, "currently executing write method"}; 
   end
endfunction: convert2string


// do_print

function void uvm_ral_mem::do_print (uvm_printer printer);
  super.do_print(printer);
  printer.print_generic("initiator", parent.get_type_name(), -1, convert2string());
endfunction


// clone

function uvm_object uvm_ral_mem::clone();
  `uvm_fatal("RAL","RAL memories cannot be cloned")
  return null;
endfunction

// do_copy

function void uvm_ral_mem::do_copy(uvm_object rhs);
  `uvm_fatal("RAL","RAL memories cannot be copied")
endfunction


// do_compare

function bit uvm_ral_mem::do_compare (uvm_object  rhs,
                                        uvm_comparer comparer);
  `uvm_warning("RAL","RAL memories cannot be compared")
  return 0;
endfunction


// do_pack

function void uvm_ral_mem::do_pack (uvm_packer packer);
  `uvm_warning("RAL","RAL memories cannot be packed")
endfunction


// do_unpack

function void uvm_ral_mem::do_unpack (uvm_packer packer);
  `uvm_warning("RAL","RAL memories cannot be unpacked")
endfunction


