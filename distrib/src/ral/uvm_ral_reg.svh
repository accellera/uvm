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
// CLASS: uvm_ral_reg_cbs
//
//------------------------------------------------------------------------------


virtual class uvm_ral_reg_cbs extends uvm_callback;

   string fname = "";
   int lineno = 0;

   function new(string name = "uvm_ral_reg_cbs");
      super.new(name);
   endfunction
   
   virtual task pre_write (uvm_ral_reg         rg,
                           ref uvm_ral_data_t  wdat,
                           ref uvm_ral::path_e path,
                           ref uvm_ral_map     map);
   endtask

   virtual task post_write(uvm_ral_reg        rg,
                           uvm_ral_data_t     wdat,
                           uvm_ral::path_e    path,
                           uvm_ral_map        map,
                           ref uvm_ral::status_e status);
   endtask

   virtual task pre_read  (uvm_ral_reg         rg,
                           ref uvm_ral::path_e path,
                           ref uvm_ral_map     map);
   endtask

   virtual task post_read (uvm_ral_reg           rg,
                           ref uvm_ral_data_t    rdat,
                           input uvm_ral::path_e path,
                           input uvm_ral_map     map,
                           ref uvm_ral::status_e status);
   endtask

endclass: uvm_ral_reg_cbs


typedef uvm_callbacks#(uvm_ral_reg, uvm_ral_reg_cbs) uvm_ral_reg_cb;
typedef uvm_callback_iter#(uvm_ral_reg, uvm_ral_reg_cbs) uvm_ral_reg_cb_iter;


//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_reg_frontdoor
//
//------------------------------------------------------------------------------

virtual class uvm_ral_reg_frontdoor extends uvm_sequence #(uvm_sequence_item);

   uvm_ral_reg       rg;
   bit               is_write;
   uvm_ral::status_e status = uvm_ral::IS_OK;
   uvm_ral_data_t    data;
   int               prior = -1;
   uvm_object        extension;
   string            fname = "";
   int               lineno = 0;

   uvm_sequencer_base sequencer;

   function new(string name="");
      super.new(name);
   endfunction

endclass: uvm_ral_reg_frontdoor


//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_reg
//
//------------------------------------------------------------------------------

virtual class uvm_ral_reg extends uvm_object;

   local bit               locked;
   local uvm_ral_block     parent;
   local uvm_ral_regfile   m_rf;
   /*local*/ int unsigned  n_bits;
   local int unsigned      n_used_bits;

   /*local*/ bit           maps[uvm_ral_map];

   local uvm_ral_field     fields[$];   // Fields in LSB to MSB order
   local string            constr[$];
   local event             value_change;

   local string            attributes[string];

   /*local*/ int           has_cover;
   local int               cover_on;

   local semaphore         atomic;
   local string            fname = "";
   local int               lineno = 0;
   local bit               read_in_progress = 0;
   local bit               write_in_progress = 0;

   /*local*/ bit           Xis_busyX;
   /*local*/ bit           Xis_locked_by_fieldX;


   //----------------------
   // Group: Initialization
   //----------------------

   extern function                  new        (string name="",
                                                int unsigned n_bits,
                                                int has_cover);
   extern virtual function void     configure  (uvm_ral_block blk_parent,
                                                uvm_ral_regfile rf_parent,
                                                string hdl_path = "");
 
   extern virtual function void     set_parent (uvm_ral_block blk_parent,
                                                uvm_ral_regfile rf_parent);
   extern virtual function void     add_field  (uvm_ral_field field);
   extern virtual function void     add_map    (uvm_ral_map map);

   /*local*/ extern function void   Xlock_modelX();


   //-----------
   // Group: Get
   //-----------

   extern virtual function int             get_n_maps      ();
   extern function         bit             is_in_map       (uvm_ral_map map);
   extern virtual function void            get_maps        (ref uvm_ral_map maps[$]);
   extern function uvm_ral_map             get_local_map   (uvm_ral_map map,
                                                            string caller = "");
   extern function uvm_ral_map             get_default_map (string caller = "");

   extern virtual function uvm_ral_block   get_block       ();
   extern virtual function string          get_rights      (uvm_ral_map map = null);
   extern virtual function uvm_ral_addr_t  get_offset      (uvm_ral_map map = null);
   extern virtual function uvm_ral_addr_t  get_address     (uvm_ral_map map = null);
   extern virtual function int             get_addresses   (uvm_ral_map map = null,
                                                            ref uvm_ral_addr_t addr[]);

   extern virtual function int unsigned    get_n_bytes     ();
   extern virtual function void            get_fields      (ref uvm_ral_field fields[$]);
   extern virtual function uvm_ral_field   get_field_by_name(string name);


   //--------------------------------
   // Group: Attributes & Constraints
   //--------------------------------

   extern virtual function void   set_attribute   (string name, string value);
   extern virtual function string get_attribute   (string name, bit inherited = 1);
   extern virtual function void   get_attributes  (ref string names[string],
                                                   input bit inherited = 1);
   extern virtual function void   get_constraints (ref string names[]);

   /*local*/ extern function void Xadd_constraintsX(string name);


   //----------------
   // Group: Coverage
   //----------------

   extern virtual function bit can_cover(int models);
   extern virtual function int set_cover(int is_on);
   extern virtual function bit is_cover_on(int is_on);

   extern virtual local function void sample(uvm_ral_data_t  data,
                                             bit             is_read,
                                             uvm_ral_map     map);

   local virtual function void map_coverage(uvm_ral_map map,
                                            bit         rights);
   endfunction
   

   //-----------------
   // Group: Callbacks
   //-----------------
   `uvm_register_cb(uvm_ral_reg, uvm_ral_reg_cbs)
   
   virtual task pre_write(ref uvm_ral_data_t  wdat,
                          ref uvm_ral::path_e path,
                          ref uvm_ral_map     map);
   endtask

   virtual task post_write(uvm_ral_data_t        wdat,
                           uvm_ral::path_e       path,
                           uvm_ral_map           map,
                           ref uvm_ral::status_e status);
   endtask

   virtual task pre_read(ref uvm_ral::path_e path,
                         ref uvm_ral_map     map);
   endtask

   virtual task post_read(ref uvm_ral_data_t    rdat,
                          input uvm_ral::path_e path,
                          input uvm_ral_map     map,
                          ref uvm_ral::status_e status);
   endtask


   //--------------
   // Group: Access
   //--------------

   extern virtual function bit predict (uvm_ral_data_t  value,
                                        uvm_ral::predict_e kind = uvm_ral::PREDICT_DIRECT,
                                        uvm_ral::path_e path = uvm_ral::BFM,
                                        uvm_ral_map     map = null,
                                        string          fname = "",
                                        int             lineno = 0);

   extern local virtual function void Xpredict_readX (uvm_ral_data_t  value,
                                                      uvm_ral::path_e path,
                                                      uvm_ral_map     map);

   extern local virtual function void Xpredict_writeX(uvm_ral_data_t  value,
                                                      uvm_ral::path_e path,
                                                      uvm_ral_map     map);

   extern virtual function void set (uvm_ral_data_t  value,
                                     string          fname = "",
                                     int             lineno = 0);

   extern virtual function uvm_ral_data_t  get(string  fname = "",
                                               int     lineno = 0);
   extern virtual function void reset(uvm_ral::reset_e kind = uvm_ral::HARD);

   extern virtual function uvm_ral_data_logic_t
                             get_reset(uvm_ral::reset_e kind = uvm_ral::HARD);
   extern virtual function bit needs_update(); 


   //------------------
   // Group: HDL Access
   //------------------
 
   extern virtual task update(output uvm_ral::status_e status,
                              input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                              input  uvm_ral_map    map = null,
                              input  uvm_sequence_base parent = null,
                              input  int               prior = -1,
                              input  uvm_object        extension = null,
                              input  string            fname = "",
                              input  int               lineno = 0);

   extern virtual task write(output uvm_ral::status_e status,
                             input  uvm_ral_data_t    value,
                             input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                             input  uvm_ral_map    map = null,
                             input  uvm_sequence_base parent = null,
                             input  int               prior = -1,
                             input  uvm_object        extension = null,
                             input  string            fname = "",
                             input  int               lineno = 0);

   extern virtual task read(output uvm_ral::status_e status,
                            output uvm_ral_data_t    value,
                            input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                            input  uvm_ral_map    map = null,
                            input  uvm_sequence_base parent = null,
                            input  int               prior = -1,
                            input  uvm_object        extension = null,
                            input  string            fname = "",
                            input  int               lineno = 0);

   extern virtual task poke(output uvm_ral::status_e status,
                            input  uvm_ral_data_t    value,
                            input  string            kind = "",
                            input  uvm_sequence_base parent = null,
                            input  uvm_object        extension = null,
                            input  string            fname = "",
                            input  int               lineno = 0);

   extern virtual task peek(output uvm_ral::status_e status,
                            output uvm_ral_data_t    value,
                            input  string            kind = "",
                            input  uvm_sequence_base parent = null,
                            input  uvm_object        extension = null,
                            input  string            fname = "",
                            input  int               lineno = 0);

   extern virtual task mirror(output uvm_ral::status_e status,
                              input uvm_ral::check_e   check  = uvm_ral::NO_CHECK,
                              input uvm_ral::path_e    path = uvm_ral::DEFAULT,
                              input uvm_ral_map     map = null,
                              input uvm_sequence_base  parent = null,
                              input int                prior = -1,
                              input  uvm_object        extension = null,
                              input string             fname = "",
                              input int                lineno = 0);
  
   /*local*/ extern task XwriteX(output uvm_ral::status_e status,
                                 input  uvm_ral_data_t    value,
                                 input  uvm_ral::path_e   path,
                                 input  uvm_ral_map       map,
                                 input  uvm_sequence_base parent = null,
                                 input  int               prior = -1,
                                 input  uvm_object        extension = null,
                                 input  string            fname = "",
                                 input  int               lineno = 0);

   /*local*/ extern task XreadX(output uvm_ral::status_e status,
                                output uvm_ral_data_t    value,
                                input  uvm_ral::path_e   path,
                                input  uvm_ral_map       map,
                                input  uvm_sequence_base parent = null,
                                input  int               prior = -1,
                                input  uvm_object        extension = null,
                                input  string            fname = "",
                                input  int               lineno = 0);
   
   /*local*/ extern task XatomicX(bit on);


   //-----------------
   // Group: Frontdoor
   //-----------------

   extern function void set_frontdoor(uvm_ral_reg_frontdoor ftdr,
                                      uvm_ral_map        map = null,
                                      string                fname = "",
                                      int                   lineno = 0);
   extern function uvm_ral_reg_frontdoor get_frontdoor(uvm_ral_map map = null);


   //----------------
   // Group: Backdoor
   //----------------

   local uvm_object_string_pool #(uvm_queue #(uvm_ral_hdl_path_concat)) hdl_paths_pool;
   local uvm_ral_reg_backdoor  backdoor;

   extern function void set_backdoor(uvm_ral_reg_backdoor bkdr,
                                     string               fname = "",
                                     int                  lineno = 0);

   extern function uvm_ral_reg_backdoor get_backdoor(bit inherit = 1);

   extern function void clear_hdl_path    (string kind = "RTL");
   extern function void add_hdl_path      (uvm_ral_hdl_path_concat path,
                                           string kind = "RTL");
   extern function bit  has_hdl_path      (string kind = "");
   extern function void get_hdl_path      (ref uvm_ral_hdl_path_concat paths[$],
                                           input string kind = "");
   extern function void get_full_hdl_path (ref uvm_ral_hdl_path_concat paths[$],
                                           input string kind = "");

   extern virtual task backdoor_read(output uvm_ral::status_e status,
                              output uvm_ral_data_t    data,
                              input string             kind,
                              input uvm_sequence_base  parent,
                              input uvm_object         extension,
                              input string             fname = "",
                              input int                lineno = 0);

   extern virtual task backdoor_write(output uvm_ral::status_e status,
                               input uvm_ral_data_t     data,
                               input string             kind,
                               input uvm_sequence_base  parent,
                               input uvm_object         extension,
                               input string             fname = "",
                               input int                lineno = 0);

   extern virtual function uvm_ral::status_e backdoor_read_func(
                               output uvm_ral_data_t    data,
                               input string             kind,
                               input uvm_sequence_base  parent,
                               input uvm_object         extension,
                               input string             fname = "",
                               input int                lineno = 0);

   virtual task  backdoor_watch(); endtask


   //--------------------
   // Group: Standard Ops
   //--------------------

   extern virtual function string          get_full_name();
   extern virtual function uvm_ral_block   get_parent ();
   extern virtual function uvm_ral_regfile get_regfile ();
   extern virtual function void            do_print (uvm_printer printer);
   extern virtual function string          convert2string();
   extern virtual function uvm_object      clone      ();
   extern virtual function void            do_copy    (uvm_object rhs);
   extern virtual function bit             do_compare (uvm_object  rhs,
                                                       uvm_comparer comparer);
   extern virtual function void            do_pack    (uvm_packer packer);
   extern virtual function void            do_unpack  (uvm_packer packer);

endclass: uvm_ral_reg


//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

// new

function uvm_ral_reg::new(string name="", int unsigned n_bits, int has_cover);
   super.new(name);
   if (n_bits == 0) begin
      `uvm_error("RAL", $psprintf("Register \"%s\" cannot have 0 bits", this.get_name()));
      n_bits = 1;
   end
   if (n_bits > `UVM_RAL_DATA_WIDTH) begin
      `uvm_error("RAL", $psprintf("Register \"%s\" cannot have more than %0d bits (%0d)", this.get_name(), `UVM_RAL_DATA_WIDTH, n_bits));
      n_bits = `UVM_RAL_DATA_WIDTH;
   end
   this.n_bits = n_bits;
   this.n_used_bits = 0;
   this.has_cover = has_cover;
   this.locked = 0;
   this.atomic = new(1);
   this.Xis_busyX = 0;
   this.Xis_locked_by_fieldX = 1'b0;
   hdl_paths_pool = new("hdl_paths");
endfunction: new


// configure

function void uvm_ral_reg::configure(uvm_ral_block blk_parent, uvm_ral_regfile rf_parent, string hdl_path = "");
   this.parent = blk_parent;
   this.parent.add_reg(this);
   this.m_rf = rf_parent;
   if (hdl_path != "")
     this.add_hdl_path('{'{hdl_path, -1, -1}});
endfunction: configure


// add_field

function void uvm_ral_reg::add_field(uvm_ral_field field);
   int offset;
   int idx;
   
   if (this.locked) begin
      `uvm_error("RAL", "Cannot add field to locked register model");
      return;
   end

   if (field == null) `uvm_fatal("RAL", "Attempting to register NULL field");

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
      `uvm_error("RAL", $psprintf("Fields use more bits (%0d) than available in register \"%s\" (%0d)",
                                     this.n_used_bits, this.get_name(), this.n_bits));
   end

   // Check if there are overlapping fields
   if (idx > 0) begin
      if (this.fields[idx-1].get_lsb_pos_in_register() +
          this.fields[idx-1].get_n_bits() > offset) begin
         `uvm_error("RAL", $psprintf("Field %s overlaps field %s in register \"%s\"",
                                        this.fields[idx-1].get_name(),
                                        field.get_name(), this.get_name()));
      end
   end
   if (idx < this.fields.size()-1) begin
      if (offset + field.get_n_bits() >
          this.fields[idx+1].get_lsb_pos_in_register()) begin
         `uvm_error("RAL", $psprintf("Field %s overlaps field %s in register \"%s\"",
                                        field.get_name(),
                                        this.fields[idx+1].get_name(),

                                      this.get_name()));
      end
   end
endfunction: add_field


// Xlock_modelX

function void uvm_ral_reg::Xlock_modelX();
   if (this.locked)
     return;
   this.locked = 1;
endfunction


//----------------------
// Group- User Frontdoor
//----------------------

// set_frontdoor

function void uvm_ral_reg::set_frontdoor(uvm_ral_reg_frontdoor ftdr,
                                         uvm_ral_map           map = null,
                                         string                fname = "",
                                         int                   lineno = 0);
   uvm_ral_map_info map_info;
   ftdr.fname = fname;
   ftdr.lineno = lineno;
   map = get_local_map(map, "set_frontdoor()");
   if (map == null)
     return;
   map_info = map.get_reg_map_info(this);
   map_info.frontdoor = ftdr;
endfunction: set_frontdoor


// get_frontdoor

function uvm_ral_reg_frontdoor uvm_ral_reg::get_frontdoor(uvm_ral_map map = null);
   uvm_ral_map_info map_info;
   map = get_local_map(map, "get_frontdoor()");
   if (map == null)
     return null;
   map_info = map.get_reg_map_info(this);
   return map_info.frontdoor;
endfunction: get_frontdoor


//----------------
// Group: Backdoor
//----------------


// set_backdoor

function void uvm_ral_reg::set_backdoor(uvm_ral_reg_backdoor bkdr,
                                        string               fname = "",
                                        int                  lineno = 0);
   bkdr.fname = fname;
   bkdr.lineno = lineno;
   if (this.backdoor != null) this.backdoor.kill_update_thread();
   this.backdoor = bkdr;
endfunction: set_backdoor


// get_backdoor

function uvm_ral_reg_backdoor uvm_ral_reg::get_backdoor(bit inherit = 1);
   if (backdoor == null && inherit) begin
     uvm_ral_block blk = get_parent();
     while (blk != null) begin
       uvm_ral_reg_backdoor bkdr = blk.get_backdoor();
       if (bkdr != null)
         return bkdr;
       blk = blk.get_parent();
     end
   end
   return this.backdoor;
endfunction: get_backdoor



// clear_hdl_path

function void uvm_ral_reg::clear_hdl_path(string kind = "RTL");
  if (kind == "ALL") begin
    hdl_paths_pool = new("hdl_paths");
    return;
  end

  if (kind == "") begin
     if (m_rf != null)
        kind = m_rf.get_default_hdl_path();
     else
        kind = parent.get_default_hdl_path();
  end

  if (!hdl_paths_pool.exists(kind)) begin
    `uvm_warning("RAL",{"Unknown HDL Abstraction '",kind,"'"})
    return;
  end

  hdl_paths_pool.delete(kind);
endfunction


// add_hdl_path

function void uvm_ral_reg::add_hdl_path(uvm_ral_hdl_path_concat path, string kind = "RTL");

  uvm_queue #(uvm_ral_hdl_path_concat) paths;

  paths = hdl_paths_pool.get(kind);

  paths.push_back(path);

endfunction


// has_hdl_path

function bit  uvm_ral_reg::has_hdl_path(string kind = "");
  if (kind == "") begin
     if (m_rf != null)
        kind = m_rf.get_default_hdl_path();
     else
        kind = parent.get_default_hdl_path();
  end

  return hdl_paths_pool.exists(kind);
endfunction


// get_hdl_path

function void uvm_ral_reg::get_hdl_path(ref uvm_ral_hdl_path_concat paths[$],
                                        input string kind = "");

  uvm_queue #(uvm_ral_hdl_path_concat) hdl_paths;

  if (kind == "") begin
     if (m_rf != null)
        kind = m_rf.get_default_hdl_path();
     else
        kind = parent.get_default_hdl_path();
  end

  if (!has_hdl_path(kind)) begin
    `uvm_error("RAL",{"Register does not have hdl path defined for abstraction '",kind,"'"})
    return;
  end

  hdl_paths = hdl_paths_pool.get(kind);

  for (int i=0; i<hdl_paths.size();i++) begin
     paths.push_back(hdl_paths.get(i));
  end

endfunction


// get_full_hdl_path

function void uvm_ral_reg::get_full_hdl_path(ref uvm_ral_hdl_path_concat paths[$],
                                             input string kind = "");

   if (kind == "") begin
      if (m_rf != null)
         kind = m_rf.get_default_hdl_path();
      else
         kind = parent.get_default_hdl_path();
   end
   
   if (!has_hdl_path(kind)) begin
      `uvm_error("RAL",{"Register does not have hdl path defined for abstraction '",kind,"'"})
      return;
   end

   begin
      uvm_queue #(uvm_ral_hdl_path_concat) hdl_paths = hdl_paths_pool.get(kind);
      string parent_paths[$];

      if (m_rf != null)
         m_rf.get_full_hdl_path(parent_paths,kind);
      else
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

function void uvm_ral_reg::set_parent(uvm_ral_block blk_parent,
                                      uvm_ral_regfile rf_parent);
  if (this.parent != null) begin
     // ToDo: remove register from previous parent
  end
  this.parent = blk_parent;
  this.m_rf = rf_parent;
endfunction


// get_parent

function uvm_ral_block uvm_ral_reg::get_parent();
  return get_block();
endfunction


// get_regfile

function uvm_ral_regfile uvm_ral_reg::get_regfile();
   return m_rf;
endfunction


// get_full_name

function string uvm_ral_reg::get_full_name();
   uvm_ral_block blk;

   get_full_name = this.get_name();

   // Do not include top-level name in full name
   if (m_rf != null)
      return {m_rf.get_full_name(), ".", get_full_name};

   // Do not include top-level name in full name
   blk = this.get_block();
   if (blk == null)
      return get_full_name;
   if (blk.get_parent() == null)
      return get_full_name;
   get_full_name = {this.parent.get_full_name(), ".", get_full_name};
endfunction: get_full_name


// add_map

function void uvm_ral_reg::add_map(uvm_ral_map map);
  if (!maps.exists(map))
    maps[map] = 1;
endfunction


// get_maps

function void uvm_ral_reg::get_maps(ref uvm_ral_map maps[$]);
   foreach (this.maps[map])
     maps.push_back(map);
endfunction


// get_n_maps

function int uvm_ral_reg::get_n_maps();
   return maps.num();
endfunction


// is_in_map

function bit uvm_ral_reg::is_in_map(uvm_ral_map map);
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

function uvm_ral_map uvm_ral_reg::get_local_map(uvm_ral_map map, string caller="");
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
       {"Register '",get_full_name(),"' is not contained within map '",map.get_full_name(),"'",
        (caller == "" ? "": {" (called from ",caller,")"}) })
   return null;
endfunction



// get_default_map

function uvm_ral_map uvm_ral_reg::get_default_map(string caller="");

   // if reg is not associated with any may, return null
   if (maps.num() == 0) begin
      `uvm_warning("RAL", 
        {"Register '",get_full_name(),"' is not registered with any map",
         (caller == "" ? "": {" (called from ",caller,")"})})
      return null;
   end

   // if only one map, choose that
   if (maps.num() == 1) begin
     uvm_ral_map map;
     void'(maps.first(map));
     return map;
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

   // if that fails, choose the first in this reg's maps

   begin
     uvm_ral_map map;
     void'(maps.first(map));
     return map;
   end

endfunction


// get_rights

function string uvm_ral_reg::get_rights(uvm_ral_map map = null);

   uvm_ral_map_info info;

   // No right restrictions if not shared
   if (maps.num() <= 1) begin
      return "RW";
   end

   map = get_local_map(map,"get_rights()");

   if (map == null)
     return "RW";

   info = map.get_reg_map_info(this);
   return info.rights;

endfunction: get_rights



// get_block

function uvm_ral_block uvm_ral_reg::get_block();
   get_block = this.parent;
endfunction: get_block


// get_offset

function uvm_ral_addr_t uvm_ral_reg::get_offset(uvm_ral_map map = null);

   uvm_ral_map_info map_info;
   uvm_ral_map orig_map = map;

   map = get_local_map(map,"get_offset()");

   if (map == null)
     return -1;
   
   map_info = map.get_reg_map_info(this);
   
   if (map_info.unmapped) begin
      `uvm_warning("RAL", {"Register '",get_name(),
                   "' is unmapped in map '",
                   ((orig_map == null) ? map.get_full_name() : orig_map.get_full_name()),"'"})
      return -1;
   end
         
   return map_info.offset;

endfunction: get_offset


// get_addresses

function int uvm_ral_reg::get_addresses(uvm_ral_map map=null, ref uvm_ral_addr_t addr[]);

   uvm_ral_map_info map_info;
   uvm_ral_map system_map;
   uvm_ral_map orig_map = map;

   map = get_local_map(map,"get_addresses()");

   if (map == null)
     return -1;

   map_info = map.get_reg_map_info(this);

   if (map_info.unmapped) begin
      `uvm_warning("RAL", {"Register '",get_name(),
                   "' is unmapped in map '",
                   ((orig_map == null) ? map.get_full_name() : orig_map.get_full_name()),"'"})
      return -1;
   end
 
   addr = map_info.addr;
   system_map = map.get_root_map();
   return system_map.get_n_bytes();

   //return map.get_physical_addresses(map_info.offset,
   //                                  0,
   //                                  this.get_n_bytes(),
   //                                  addr);
endfunction


// get_address

function uvm_ral_addr_t uvm_ral_reg::get_address(uvm_ral_map map = null);
   uvm_ral_addr_t  addr[];
   void'(get_addresses(map,addr));
   return addr[0];
endfunction


// get_n_bytes

function int unsigned uvm_ral_reg::get_n_bytes();
   get_n_bytes = ((this.n_bits-1) / 8) + 1;
endfunction: get_n_bytes


// get_fields

function void uvm_ral_reg::get_fields(ref uvm_ral_field fields[$]);
   foreach(this.fields[i])
      fields.push_back(this.fields[i]);
endfunction


// get_field_by_name

function uvm_ral_field uvm_ral_reg::get_field_by_name(string name);
   foreach (this.fields[i]) begin
      if (this.fields[i].get_name() == name) begin
         return this.fields[i];
      end
   end
   `uvm_warning("RAL", $psprintf("Unable to locate field \"%s\" in register \"%s\".",
                                    name, this.get_name()));
   get_field_by_name = null;
endfunction: get_field_by_name


//-----------
// ATTRIBUTES
//-----------

// set_attribute

function void uvm_ral_reg::set_attribute(string name,
                                         string value);
   if (name == "") begin
      `uvm_error("RAL", {"Cannot set anonymous attribute \"\" in register '",
                         get_full_name(),"'"})
      return;
   end

   if (this.attributes.exists(name)) begin
      if (value != "") begin
         `uvm_warning("RAL", {"Redefining attribute '",name,"' in register '",
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
                          name, "' in register '", get_full_name(), "'"})
      return;
   end

   this.attributes[name] = value;
endfunction: set_attribute


// get_attribute

function string uvm_ral_reg::get_attribute(string name,
                                           bit inherited = 1);
   if (inherited) begin
      if (m_rf != null)
         get_attribute = parent.get_attribute(name);
      else if (parent != null)
         get_attribute = parent.get_attribute(name);
   end

   if (get_attribute == "" && this.attributes.exists(name))
      return this.attributes[name];

   return "";
endfunction: get_attribute


// get_attributes

function void uvm_ral_reg::get_attributes(ref string names[string],
                                          input bit inherited = 1);
   // attributes at higher levels supercede those at lower levels
   if (inherited) begin
      if (m_rf != null)
         this.parent.get_attributes(names,1);
      else if (parent != null)
         this.parent.get_attributes(names,1);
   end

   foreach (attributes[nm])
     if (!names.exists(nm))
       names[nm] = attributes[nm];

endfunction: get_attributes


// Xadd_constraintsX

function void uvm_ral_reg::Xadd_constraintsX(string name);

   if (this.locked) begin
      `uvm_error("RAL", "Cannot add constraints to locked register model");
      return;
   end

   // Check if the constraint block already exists
   foreach (this.constr[i]) begin
      if (this.constr[i] == name) begin
         `uvm_warning("RAL", $psprintf("Constraint \"%s\" already added",
                                          name));
         return;
      end
   end

   constr.push_back(name);

endfunction: Xadd_constraintsX


// get_constraints

function void uvm_ral_reg::get_constraints(ref string names[]);
   names = new [this.constr.size()] (this.constr);
endfunction: get_constraints



//---------
// COVERAGE
//---------

// can_cover

function bit uvm_ral_reg::can_cover(int models);
   return ((this.has_cover & models) == models);
endfunction: can_cover


// set_cover

function int uvm_ral_reg::set_cover(int is_on);
   if (is_on == uvm_ral::NO_COVERAGE) begin
      this.cover_on = is_on;
      return this.cover_on;
   end

   if ((this.has_cover & is_on) == 0) begin
      `uvm_warning("RAL", $psprintf("Register \"%s\" - Cannot turn ON any coverage becasue the corresponding coverage model was not generated.", this.get_full_name()));
      return this.cover_on;
   end

   if (is_on & uvm_ral::REG_BITS) begin
      if (this.has_cover & uvm_ral::REG_BITS) begin
          this.cover_on |= uvm_ral::REG_BITS;
      end else begin
          `uvm_warning("RAL", $psprintf("Register \"%s\" - Cannot turn ON Register Bit coverage becasue the corresponding coverage model was not generated.", this.get_full_name()));
      end
   end

   if (is_on & uvm_ral::FIELD_VALS) begin
      if (this.has_cover & uvm_ral::FIELD_VALS) begin
          this.cover_on |= uvm_ral::FIELD_VALS;
      end else begin
          `uvm_warning("RAL", $psprintf("Register \"%s\" - Cannot turn ON Field Value coverage becasue the corresponding coverage model was not generated.", this.get_full_name()));
      end
   end

   if (is_on & uvm_ral::ADDR_MAP) begin
      if (this.has_cover & uvm_ral::ADDR_MAP) begin
          this.cover_on |= uvm_ral::ADDR_MAP;
      end else begin
          `uvm_warning("RAL", $psprintf("Register \"%s\" - Cannot turn ON Address Map coverage becasue the corresponding coverage model was not generated.", this.get_full_name()));
      end
   end

   set_cover = this.cover_on;
endfunction: set_cover


// is_cover_on

function bit uvm_ral_reg::is_cover_on(int is_on);
   if (this.can_cover(is_on) == 0) return 0;
   return ((this.cover_on & is_on) == is_on);
endfunction: is_cover_on


// sample

function void uvm_ral_reg::sample(uvm_ral_data_t  data,
                                  bit             is_read,
                                  uvm_ral_map  map);
   // Nothing to do in this base class
endfunction




//---------
// ACCESS
//---------

function void uvm_ral_reg::set(uvm_ral_data_t  value,
                               string          fname = "",
                               int             lineno = 0);
   // Split the value into the individual fields
   int j, w;
   this.fname = fname;
   this.lineno = lineno;

   // Fields are stored in LSB to MSB order
   foreach (this.fields[i]) begin
      j = this.fields[i].get_lsb_pos_in_register();
      w = this.fields[i].get_n_bits();
      this.fields[i].set((value >> j) & ((1 << w) - 1));
   end
endfunction: set


function bit uvm_ral_reg::predict(uvm_ral_data_t  value,
                                  uvm_ral::predict_e kind = uvm_ral::PREDICT_DIRECT,
                                  uvm_ral::path_e path = uvm_ral::BFM,
                                  uvm_ral_map     map = null,
                                  string          fname = "",
                                  int             lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   if (this.Xis_busyX && kind == uvm_ral::PREDICT_DIRECT) begin
      `uvm_warning("RAL", $psprintf("Trying to predict value of register \"%s\" while it is being accessed",
                                    this.get_full_name()));
      return 0;
   end
   
   predict = 1;
   
   // Fields are stored in LSB to MSB order
   foreach (this.fields[i]) begin
      predict &= this.fields[i].predict(value >> this.fields[i].get_lsb_pos_in_register(),
                                        kind,path,map,fname,lineno);
   end
endfunction: predict


function uvm_ral_data_t  uvm_ral_reg::get(string  fname = "",
                                          int     lineno = 0);
   // Concatenate the value of the individual fields
   // to form the register value
   int j, w;
   this.fname = fname;
   this.lineno = lineno;

   get = 0;
   
   // Fields are stored in LSB or MSB order
   foreach (this.fields[i]) begin
      j = this.fields[i].get_lsb_pos_in_register();
      get |= this.fields[i].get() << j;
   end
endfunction: get


function void uvm_ral_reg::reset(uvm_ral::reset_e kind = uvm_ral::HARD);
   foreach (this.fields[i]) begin
      this.fields[i].reset(kind);
   end
   // Put back a key in the semaphore if it is checked out
   // in case a thread was killed during an operation
   void'(this.atomic.try_get(1));
   this.atomic.put(1);
endfunction: reset


function uvm_ral_data_logic_t uvm_ral_reg::get_reset(uvm_ral::reset_e kind = uvm_ral::HARD);
   // Concatenate the value of the individual fields
   // to form the register value
   int j, w;

   get_reset = 0;
   
   // Fields are stored in LSB to MSB order
   foreach (this.fields[i]) begin
      j = this.fields[i].get_lsb_pos_in_register();
      get_reset |= this.fields[i].get_reset(kind) << j;
   end
endfunction: get_reset


function void uvm_ral_reg::Xpredict_readX(uvm_ral_data_t  value,
                                   uvm_ral::path_e path,
                                   uvm_ral_map  map);
   // Fields are stored in LSB to MSB order
   foreach (this.fields[i]) begin
      this.fields[i].Xpredict_readX(value >> this.fields[i].get_lsb_pos_in_register(),
                             path, map);
   end
endfunction: Xpredict_readX


function void uvm_ral_reg::Xpredict_writeX(uvm_ral_data_t  value,
                                   uvm_ral::path_e path,
                                   uvm_ral_map  map);
   int j, w;

   // Fields are stored in LSB to MSB order
   foreach (this.fields[i]) begin
      j = this.fields[i].get_lsb_pos_in_register();
      w = this.fields[i].get_n_bits();
      this.fields[i].Xpredict_writeX((value >> j) & ((1 << w) - 1), path, map);
   end
endfunction: Xpredict_writeX


//-----------
// BUS ACCESS
//-----------

function bit uvm_ral_reg::needs_update();
   needs_update = 0;
   foreach (this.fields[i]) begin
      if (this.fields[i].needs_update()) begin
         return 1;
      end
   end
endfunction: needs_update



task uvm_ral_reg::update(output uvm_ral::status_e status,
                         input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                         input  uvm_ral_map    map = null,
                         input  uvm_sequence_base parent = null,
                         input  int               prior = -1,
                         input  uvm_object        extension = null,
                         input  string            fname = "",
                         input  int               lineno = 0);
   uvm_ral_data_t  upd, k;
   int j;

   status = uvm_ral::IS_OK;
   if (!this.needs_update()) return;

   this.XatomicX(1);

   // Concatenate the write-to-update values from each field
   // Fields are stored in LSB or MSB order
   upd = 0;
   foreach (this.fields[i]) begin
      j = this.fields[i].get_lsb_pos_in_register();
      k = (1 << this.fields[i].get_n_bits()) - 1;
      upd |= (this.fields[i].XupdX() & k) << j;
   end

   this.XwriteX(status, upd, path, map, parent, prior, extension, fname, lineno);

   this.XatomicX(0);
endtask: update


task uvm_ral_reg::write(output uvm_ral::status_e status,
                        input  uvm_ral_data_t    value,
                        input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                        input  uvm_ral_map    map = null,
                        input  uvm_sequence_base parent = null,
                        input  int               prior = -1,
                        input  uvm_object        extension = null,
                        input  string            fname = "",
                        input  int               lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   this.write_in_progress = 1'b1;

   this.XatomicX(1);
   this.XwriteX(status, value, path, map, parent, prior, extension, fname, lineno);
   this.XatomicX(0);
   this.fname = "";
   this.lineno = 0;
   this.write_in_progress = 1'b0;
endtask: write


// XwriteX

task uvm_ral_reg::XwriteX(output uvm_ral::status_e status,
                          input  uvm_ral_data_t    value,
                          input  uvm_ral::path_e   path,
                          input  uvm_ral_map       map,
                          input  uvm_sequence_base parent = null,
                          input  int               prior = -1,
                          input  uvm_object        extension = null,
                          input  string            fname = "",
                          input  int               lineno = 0);
   uvm_ral_reg_cb_iter cbs = new(this);
   uvm_ral_map local_map, system_map;
   uvm_ral_map_info map_info;

   status = uvm_ral::ERROR;
   value &= value << (`UVM_RAL_DATA_WIDTH - n_bits) >> (`UVM_RAL_DATA_WIDTH - n_bits);
   value &= ((1 << n_bits)-1);
   
   if (path == uvm_ral::DEFAULT)
     path = this.parent.get_default_path();

   if (path == uvm_ral::BACKDOOR) begin
      if (this.backdoor == null && !has_hdl_path()) begin
         `uvm_warning("RAL",
            {"No backdoor access available for register '",get_full_name(),
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
           {"No transactor available to physically access register on map '",
            map.get_full_name(),"'"})
        return;
     end

     map_info = local_map.get_reg_map_info(this);

     if (map == null)
       map = local_map;
   end


   // PRE-WRITE CBS - FIELDS
   begin : pre_write_callbacks
      uvm_ral_data_t  tmp;
      uvm_ral_data_t  msk;
      int lsb;

      foreach (fields[i]) begin
         uvm_ral_field_cb_iter cbs = new(fields[i]);
         uvm_ral_field f = fields[i];

         lsb = f.get_lsb_pos_in_register();

         msk = ((1<<f.get_n_bits())-1) << lsb;
         tmp = (value & msk) >> lsb;

         f.pre_write(tmp, path, map);
         for (uvm_ral_field_cbs cb = cbs.first(); cb != null;
              cb = cbs.next()) begin
            cb.fname = this.fname;
            cb.lineno = this.lineno;
            cb.pre_write(f, tmp, path, map);
         end

         value = (value & ~msk) | (tmp << lsb);
      end
   end

   // PRE-WRITE CBS - REG
   this.pre_write(value, path, map);
   for (uvm_ral_reg_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.pre_write(this, value, path, map);
   end

   // EXECUTE WRITE...
   case (path)
      
      // ...VIA USER BACKDOOR
      uvm_ral::BACKDOOR: begin
         uvm_ral_data_t  reg_val;
         uvm_ral_data_t  final_val;

         begin
            int j, w;

            // Fields are stored in LSB to MSB order
            final_val = '0;
            foreach (this.fields[i]) begin
               uvm_ral_data_t  field_val;
               j = this.fields[i].get_lsb_pos_in_register();
               w = this.fields[i].get_n_bits();
               field_val = this.fields[i].XpredictX((reg_val >> j) & ((1 << w) - 1),
                                                    (value >> j) & ((1 << w) - 1),
                                                    map);
               final_val |= field_val << j;
            end
         end
         if (backdoor != null)
           this.backdoor.write(status, final_val, parent, extension);
         else
           backdoor_write(status, final_val, "", parent, extension, fname, lineno);
         this.Xpredict_writeX(final_val, path, null);
      end

      uvm_ral::BFM: begin

         system_map = local_map.get_root_map();

         this.Xis_busyX = 1;

         // ...VIA USER FRONTDOOR
         if (map_info.frontdoor != null) begin
            uvm_ral_reg_frontdoor fd = map_info.frontdoor;
            fd.rg        = this;
            fd.is_write  = 1;
            fd.data      = value;
            fd.prior     = prior;
            fd.extension = extension;
            fd.fname     = fname;
            fd.lineno    = lineno;
            if (fd.sequencer == null)
              fd.start(system_map.get_sequencer(), parent);
            else
              fd.start(fd.sequencer, parent);
            status = fd.status;
         end

         // ...VIA BUILT-IN FRONTDOOR
         else begin : built_in_frontdoor
            uvm_ral_adapter    adapter = system_map.get_adapter();
            uvm_sequencer_base sequencer = system_map.get_sequencer();

            //uvm_ral_addr_t  addr[];
            int w, j;
            int n_bits;

            if (parent == null)
              `uvm_fatal("RAL","Built-in frontdoor write requires non-null parent argument")

            if (map_info.unmapped) begin
               `uvm_error("RAL", {"Register '",get_full_name(),"' unmapped in map '",
                          map.get_full_name(),"' and does not have a user-defined frontdoor"})
               this.Xis_busyX = 0;
               return;
            end

            
            w = system_map.get_n_bytes();
            //w = local_map.get_physical_addresses(map_info.offset,
            //                                     0,
            //                                     this.get_n_bytes(),
            //                                     addr);

            j = 0;
            n_bits = this.get_n_bytes() * 8;

            
            foreach (map_info.addr[i]) begin
               uvm_ral_data_t  data;
               uvm_sequence_item bus_req = new("bus_wr");
               uvm_rw_access rw_access;

               data = value >> (j*8);

               status = uvm_ral::ERROR;
                           
               `uvm_info(get_type_name(),
                  $psprintf("Writing 'h%0h at 'h%0h via map \"%s\"...",
                            data, map_info.addr[i], map.get_full_name()), UVM_HIGH);
                        
               rw_access = uvm_rw_access::type_id::create("rw_access",,
                           {sequencer.get_full_name(),
                           (parent==null? "":{".",parent.get_full_name()})});
               rw_access.element = this;
               rw_access.element_kind = uvm_ral::REG;
               rw_access.kind = uvm_ral::WRITE;
               rw_access.addr = map_info.addr[i];
               rw_access.data = data;
               rw_access.n_bits = (n_bits > w*8) ? w*8 : n_bits;
               rw_access.byte_en = '1;
               rw_access.extension = extension;

               bus_req.m_start_item(sequencer,parent,prior);

               parent.mid_do(rw_access);
               bus_req = adapter.ral2bus(rw_access);

               bus_req.set_sequencer(sequencer);
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

               `uvm_info(get_type_name(),
                  $psprintf("Wrote 'h%0h at 'h%0h via map \"%s\": %s...",
                            data, map_info.addr[i], map.get_full_name(), status.name()), UVM_HIGH);

               if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) begin
                  this.Xis_busyX = 0;
                  return;
               end
               j += w;
               n_bits -= w * 8;
            end

         end

         if (this.cover_on) begin
            this.sample(value, 0, map);
            this.parent.XsampleX(map_info.offset, map);
         end

         this.Xis_busyX = 0;

         if (system_map.get_auto_predict() == uvm_ral::PREDICT_DIRECT)
           this.Xpredict_writeX(value, path, map);
      end
      
   endcase

   // POST-WRITE CBS - REG
   this.post_write(value, path, map, status);
   for (uvm_ral_reg_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_write(this, value, path, map, status);
   end

   // POST-WRITE CBS - FIELDS
   begin
      uvm_ral_data_t  tmp;
      uvm_ral_data_t  msk;
      int lsb;
      uvm_ral_data_t predicted_value;

      predicted_value = this.get();

      foreach (fields[i]) begin
         uvm_ral_field_cb_iter cbs = new(fields[i]);
         uvm_ral_field f = fields[i];

         lsb = f.get_lsb_pos_in_register();

         msk = ((1<<f.get_n_bits())-1) << lsb;
         tmp = (predicted_value & msk) >> lsb;

         f.post_write(tmp, path, map, status);
         for (uvm_ral_field_cbs cb = cbs.first(); cb != null;
              cb = cbs.next()) begin
            cb.fname = this.fname;
            cb.lineno = this.lineno;
            cb.post_write(f, tmp, path, map, status);
         end
      end
   end

   `uvm_info("RAL", $psprintf("Wrote register \"%s\" via %s: 'h%0h",
              this.get_full_name(),
              (path == uvm_ral::BFM) ? {"map ",map.get_full_name()} : 
              (backdoor != null ? "user backdoor" : "DPI backdoor"),
              value),UVM_MEDIUM );
   
endtask: XwriteX


// read

task uvm_ral_reg::read(output uvm_ral::status_e status,
                       output uvm_ral_data_t    value,
                       input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                       input  uvm_ral_map       map = null,
                       input  uvm_sequence_base parent = null,
                       input  int               prior = -1,
                       input  uvm_object        extension = null,
                       input  string            fname = "",
                       input  int               lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   this.read_in_progress = 1'b1;

   this.XatomicX(1);
   this.XreadX(status, value, path, map, parent, prior, extension, fname, lineno);
   this.XatomicX(0);
   this.fname = "";
   this.lineno = 0;
   this.read_in_progress = 1'b0;
endtask: read


// XreadX

task uvm_ral_reg::XreadX(output uvm_ral::status_e status,
                         output uvm_ral_data_t    value,
                         input  uvm_ral::path_e   path,
                         input  uvm_ral_map       map,
                         input  uvm_sequence_base parent = null,
                         input  int               prior = -1,
                         input  uvm_object        extension = null,
                         input  string            fname = "",
                         input  int               lineno = 0);
   uvm_ral_reg_cb_iter cbs = new(this);
   uvm_ral_map local_map, system_map;
   uvm_ral_map_info map_info;
   
   status = uvm_ral::ERROR;
   
   if (path == uvm_ral::DEFAULT)
     path = this.parent.get_default_path();

   if (path == uvm_ral::BACKDOOR) begin
      if (this.backdoor == null && !has_hdl_path()) begin
         `uvm_warning("RAL",
            {"No backdoor access available for register '",get_full_name(),
            "' . Using frontdoor instead."})
         path = uvm_ral::BFM;
      end
      else
        map = uvm_ral_map::backdoor;
   end

   if (path != uvm_ral::BACKDOOR) begin

     local_map = get_local_map(map,"read()");

     if (local_map == null || !maps.exists(local_map)) begin
        `uvm_error(get_type_name(), 
           {"No transactor available to physically access register on map '",
            map.get_full_name(),"'"})
        return;
     end

     map_info = local_map.get_reg_map_info(this);

     if (map == null)
       map = local_map;
   end

                        
   // PRE-READ CBS - FIELDS
   foreach (fields[i]) begin
      uvm_ral_field_cb_iter cbs = new(fields[i]);
      uvm_ral_field f = fields[i];

      f.pre_read(path, map);
      for (uvm_ral_field_cbs cb = cbs.first(); cb != null;
           cb = cbs.next()) begin
         cb.fname = this.fname;
         cb.lineno = this.lineno;
         cb.pre_read(f, path, map);
      end
   end

   // PRE-READ CBS - REG
   this.pre_read(path, map);
   for (uvm_ral_reg_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.pre_read(this, path, map);
   end

   if (path == uvm_ral::DEFAULT) path = this.parent.get_default_path();

   // EXECUTE READ...
   case (path)
      
      // ...VIA USER BACKDOOR
      uvm_ral::BACKDOOR: begin
         uvm_ral_data_t  final_val;

         if (this.backdoor != null)
           this.backdoor.read(status, value, parent);
         else
           backdoor_read(status, value, "", parent, extension, fname, lineno);

         final_val = value;

         // Need to clear RC fields and mask WO fields
         if (status == uvm_ral::IS_OK || status == uvm_ral::HAS_X) begin
            uvm_ral_data_t  wo_mask = 0;

            foreach (this.fields[i]) begin
               string acc = this.fields[i].get_access(uvm_ral_map::backdoor);
               if (acc == "RC") begin
                  final_val &= ~(((1<<this.fields[i].get_n_bits())-1) << this.fields[i].get_lsb_pos_in_register());
               end
               else if (acc == "WO") begin
                  wo_mask |= ((1<<this.fields[i].get_n_bits())-1) << this.fields[i].get_lsb_pos_in_register();
               end
            end

            if (final_val != value) begin
              if (this.backdoor != null)
                 this.backdoor.read(status, final_val, parent, extension);
              else
                 backdoor_read(status, final_val, "", parent, extension, fname, lineno);
            end

            value &= ~wo_mask;
            this.Xpredict_readX(final_val, path, null);
         end
      end


      uvm_ral::BFM: begin

         system_map = local_map.get_root_map();

         this.Xis_busyX = 1;

         // ...VIA USER FRONTDOOR
         if (map_info.frontdoor != null) begin
            uvm_ral_reg_frontdoor fd = map_info.frontdoor;
            fd.rg        = this;
            fd.is_write  = 0;
            fd.prior     = prior;
            fd.extension = extension;
            fd.fname     = fname;
            fd.lineno    = lineno;
            if (fd.sequencer == null)
              fd.start(system_map.get_sequencer(), parent);
            else
              fd.start(fd.sequencer, parent);
            value  = fd.data;
            status = fd.status;
         end

         // ...VIA BUILT-IN FRONTDOOR
         else begin : built_in_frontdoor
            uvm_ral_adapter    adapter = system_map.get_adapter();
            uvm_sequencer_base sequencer = system_map.get_sequencer();

            //uvm_ral_addr_t  addr[];
            int w, j;
            int n_bits;
         
            if (parent == null)
              `uvm_fatal("RAL","Built-in frontdoor read requires non-null parent argument")

            if (maps.num() == 0 || map_info.unmapped) begin
               `uvm_error("RAL", {"Register '",get_full_name(),"' unmapped in map '",
                          map.get_full_name(),"' and does not have a user-defined frontdoor"})
               this.Xis_busyX = 0;
               return;
            end

            w = system_map.get_n_bytes();
            //w = local_map.get_physical_addresses(map_info.offset,
            //                                     0,
            //                                     this.get_n_bytes(),
            //                                     addr);

            j = 0;
            n_bits = this.get_n_bytes() * 8;
            value = 0;


            foreach (map_info.addr[i]) begin
               uvm_ral_data_t  data;
               uvm_sequence_item bus_req = new("bus_rd");
               uvm_rw_access rw_access;
               
               `uvm_info(get_type_name(),
                  $psprintf("Reading 'h%0h at 'h%0h via map \"%s\"...",
                            data, map_info.addr[i], map.get_full_name()), UVM_HIGH);
                        
                rw_access = uvm_rw_access::type_id::create("rw_access",,
                             {sequencer.get_full_name(),".",parent.get_full_name()});
                rw_access.element = this;
                rw_access.element_kind = uvm_ral::REG;
                rw_access.kind = uvm_ral::READ;
                rw_access.addr = map_info.addr[i];
                rw_access.data = data;
                rw_access.n_bits = (n_bits > w*8) ? w*8 : n_bits;
                rw_access.byte_en = '1;
                rw_access.extension = extension;
                            
                bus_req.m_start_item(sequencer,parent,prior);
                parent.mid_do(rw_access);
                bus_req = adapter.ral2bus(rw_access);
                bus_req.set_sequencer(sequencer);
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
                data = rw_access.data;
                parent.post_do(rw_access);

                `uvm_info(get_type_name(),
                   $psprintf("Read 'h%0h at 'h%0h via map \"%s\": %s...", data,
                             map_info.addr[i], map.get_full_name(), status.name()), UVM_HIGH);

                if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) begin
                   this.Xis_busyX = 0;
                   return;
                end
                value |= (data & ((1 << (w*8)) - 1)) << (j*8);
                j += w;
                n_bits -= w * 8;
             end
         end

         if (this.cover_on) begin
            this.sample(value, 1, map);
            this.parent.XsampleX(map_info.offset, map);
         end

         this.Xis_busyX = 0;

         if (system_map.get_auto_predict() == uvm_ral::PREDICT_DIRECT)
           this.Xpredict_readX(value, path, map);
      end
      
   endcase


   // POST-READ CBS - REG
   this.post_read(value, path, map, status);
   for (uvm_ral_reg_cbs cb = cbs.first(); cb != null;
        cb = cbs.next()) begin
      cb.fname = this.fname;
      cb.lineno = this.lineno;
      cb.post_read(this, value, path, map, status);
   end

   // POST-READ CBS - FIELDS
   begin
      uvm_ral_data_t  tmp;
      uvm_ral_data_t  msk;
      int lsb;

      foreach (fields[i]) begin
         uvm_ral_field_cb_iter cbs = new(fields[i]);
         uvm_ral_field f = fields[i];

         lsb = f.get_lsb_pos_in_register();

         msk = ((1<<f.get_n_bits())-1) << lsb;
         tmp = (value & msk) >> lsb;


         f.post_read(tmp, path, map, status);
         for (uvm_ral_field_cbs cb = cbs.first(); cb != null;
              cb = cbs.next()) begin
            cb.fname = this.fname;
            cb.lineno = this.lineno;
            cb.post_read(f, tmp, path, map, status);
         end

         value = (value & ~msk) | (tmp << lsb);
      end
   end

   `uvm_info("RAL",
      $psprintf("Read register \"%s\" via %s: 'h%0h",
                this.get_full_name(),
                (path == uvm_ral::BFM) ? {"map ",map.get_full_name()} : 
                  (backdoor != null ? "user backdoor" : "DPI backdoor"),
                value),UVM_MEDIUM);

endtask: XreadX


// backdoor_write

task  uvm_ral_reg::backdoor_write(output uvm_ral::status_e status,
                                  input uvm_ral_data_t     data,
                                  input string             kind,
                                  input uvm_sequence_base  parent,
                                  input uvm_object         extension,
                                  input string             fname = "",
                                  input int                lineno = 0);
  uvm_ral_hdl_path_concat paths[$];
  bit ok=1;
  get_full_hdl_path(paths,kind);
  foreach (paths[i]) begin
     uvm_ral_hdl_path_concat hdl_slices = paths[i];
     foreach (hdl_slices[j]) begin
        if (hdl_slices[j].offset < 0) begin
           ok &= uvm_hdl_deposit(hdl_slices[j].path,data);
           continue;
        end
        begin
           uvm_ral_data_t slice;
           slice = data >> hdl_slices[j].offset;
           slice &= (1 << hdl_slices[j].size)-1;
           ok &= uvm_hdl_deposit(hdl_slices[j].path, slice);
        end
     end
  end
  status = (ok ? uvm_ral::IS_OK : uvm_ral::ERROR);
endtask


// backdoor_read

task  uvm_ral_reg::backdoor_read (output uvm_ral::status_e status,
                                  output uvm_ral_data_t    data,
                                  input string             kind,
                                  input uvm_sequence_base  parent,
                                  input  uvm_object        extension,
                                  input string             fname = "",
                                  input int                lineno = 0);
  status = backdoor_read_func(data,kind,parent,extension,fname,lineno);
endtask


// backdoor_read_func

function uvm_ral::status_e uvm_ral_reg::backdoor_read_func(
                               output uvm_ral_data_t   data,
                               input string            kind,
                               input uvm_sequence_base parent,
                               input uvm_object        extension,
                               input string            fname = "",
                               input int               lineno = 0);
  uvm_ral_hdl_path_concat paths[$];
  uvm_ral_data_t val;
  bit ok=1;
  get_full_hdl_path(paths,kind);
  foreach (paths[i]) begin
     uvm_ral_hdl_path_concat hdl_slices = paths[i];
     val = 0;
     foreach (hdl_slices[j]) begin
        if (hdl_slices[j].offset < 0) begin
           ok &= uvm_hdl_read(hdl_slices[j].path,val);
           continue;
        end
        begin
           uvm_ral_data_t slice;
           int k = hdl_slices[j].offset;
           ok &= uvm_hdl_read(hdl_slices[j].path, slice);
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

// poke

task uvm_ral_reg::poke(output uvm_ral::status_e status,
                       input  uvm_ral_data_t    value,
                       input  string            kind = "",
                       input  uvm_sequence_base parent = null,
                       input  uvm_object        extension = null,
                       input  string            fname = "",
                       input  int               lineno = 0);
   this.fname = fname;
   this.lineno = lineno;

   if (!this.Xis_locked_by_fieldX) this.XatomicX(1);

   if (this.backdoor == null && !has_hdl_path(kind)) begin
      `uvm_error("RAL", $psprintf("No backdoor access available to poke register \"%s\"", this.get_name()));
      status = uvm_ral::ERROR;
      if(!this.Xis_locked_by_fieldX)
        this.XatomicX(0);
      return;
   end

   if (backdoor == null)
     this.backdoor.write(status, value, parent, extension);
   else
     this.backdoor_write(status, value, kind, parent, extension, fname, lineno);

   `uvm_info("RAL", $psprintf("Poked register \"%s\": 'h%h",
                              this.get_full_name(), value),UVM_MEDIUM);

   this.Xpredict_writeX(value, uvm_ral::BACKDOOR, null);
   if (!this.Xis_locked_by_fieldX) this.XatomicX(0);
   this.fname = "";
   this.lineno = 0;
endtask: poke


// peek

task uvm_ral_reg::peek(output uvm_ral::status_e status,
                       output uvm_ral_data_t    value,
                       input  string            kind = "",
                       input  uvm_sequence_base parent = null,
                       input  uvm_object        extension = null,
                       input  string            fname = "",
                       input  int               lineno = 0);
   this.fname = fname;
   this.lineno = lineno;

   if (!this.Xis_locked_by_fieldX) this.XatomicX(1);
   if (this.backdoor == null && !has_hdl_path(kind)) begin
      `uvm_error("RAL", $psprintf("No backdoor access available to peek register \"%s\"", this.get_name()));
      status = uvm_ral::ERROR;
      if(!this.Xis_locked_by_fieldX)
        this.XatomicX(0);
      return;
   end

   if (backdoor == null)
     this.backdoor.read(status, value, parent, extension);
   else
     this.backdoor_read(status, value, kind, parent, extension, fname, lineno);

   `uvm_info("RAL", $psprintf("Peeked register \"%s\": 'h%h",
                              this.get_full_name(), value),UVM_MEDIUM);

   this.Xpredict_readX(value, uvm_ral::BACKDOOR, null);

   if (!this.Xis_locked_by_fieldX) this.XatomicX(0);
   this.fname = "";
   this.lineno = 0;
endtask: peek


// mirror

task uvm_ral_reg::mirror(output uvm_ral::status_e  status,
                         input  uvm_ral::check_e   check = uvm_ral::NO_CHECK,
                         input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                         input  uvm_ral_map        map = null,
                         input  uvm_sequence_base  parent = null,
                         input  int                prior = -1,
                         input  uvm_object         extension = null,
                         input  string             fname = "",
                         input  int                lineno = 0);
   uvm_ral_data_t  v;
   uvm_ral_data_t  exp;
   this.fname = fname;
   this.lineno = lineno;


   if (path == uvm_ral::DEFAULT)
     path = this.parent.get_default_path();

   this.XatomicX(1);

   if (path == uvm_ral::BACKDOOR && (this.backdoor != null || has_hdl_path()))
      map = uvm_ral_map::backdoor;
   else
     map = get_local_map(map, "read()");

   if (map == null)
     return;
   
   // Remember what we think the value is before it gets updated
   if (check == uvm_ral::CHECK) begin
      exp = this.get();
      // Any WO field will readback as 0's
      foreach(this.fields[i]) begin
         if (this.fields[i].get_access(map) == "WO") begin
            exp &= ~(((1 << this.fields[i].get_n_bits())-1)
                     << this.fields[i].get_lsb_pos_in_register());
         end
      end
   end

   this.XreadX(status, v, path, map, parent, prior, extension, fname, lineno);

   if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) begin
      this.XatomicX(0);
      return;
   end

   if (check == uvm_ral::CHECK) begin
      // Check that our idea of the register value matches
      // what we just read from the DUT, minus the don't care fields
      uvm_ral_data_t  dc = 0;

      foreach(this.fields[i]) begin
         string acc = this.fields[i].get_access(map);
         if (acc == "DC") begin
            dc |= ((1 << this.fields[i].get_n_bits())-1)
                  << this.fields[i].get_lsb_pos_in_register();
         end
         else if (acc == "WO") begin
            // WO fields will always read-back as 0
            exp &= ~(((1 << this.fields[i].get_n_bits())-1)
                     << this.fields[i].get_lsb_pos_in_register());
         end
      end

      if ((v|dc) !== (exp|dc)) begin
         `uvm_error("RAL", $psprintf("Register \"%s\" value read from DUT (0x%h) does not match mirrored value (0x%h)",
                                     this.get_name(), v, (exp ^ ('x & dc))));
      end
   end

   this.XatomicX(0);
   this.fname = "";
   this.lineno = 0;
endtask: mirror


// XatomicX

task uvm_ral_reg::XatomicX(bit on);
   if (on)
     this.atomic.get(1);
   else begin
      // Maybe a key was put back in by a spurious call to reset()
      void'(this.atomic.try_get(1));
      this.atomic.put(1);
   end
endtask: XatomicX


//-------------
// STANDARD OPS
//-------------

// convert2string

function string uvm_ral_reg::convert2string();
   string res_str = "";
   string t_str = "";
   bit with_debug_info = 1'b0;

   string prefix = "";

   $sformat(convert2string, "Register %s -- %0d bytes, mirror value:'h%h",
            this.get_full_name(), this.get_n_bytes(),this.get());

   if (this.maps.num()==0)
     convert2string = {convert2string, "  (unmapped)\n"};
   else
     convert2string = {convert2string, "\n"};
   foreach (this.maps[map]) begin
     uvm_ral_map parent_map = map;
     int unsigned offset;
     while (parent_map != null) begin
       uvm_ral_map this_map = parent_map;
       parent_map = this_map.get_parent_map(0);
       offset = parent_map == null ? this_map.get_base_addr(0) : parent_map.get_submap_offset(this_map);
       prefix = {prefix, "  "};
       $sformat(convert2string, "%sMapped in '%s' -- %s bytes, %s, offset 'h%0h\n", prefix,
            this_map.get_full_name(), this_map.get_n_bytes(), this_map.get_endian(), offset);
     end
   end
   prefix = "  ";
   if (this.attributes.num() > 0) begin
      string name;
      void'(this.attributes.first(name));
      convert2string = {convert2string, "\n", prefix, "Attributes:"};
      do begin
         $sformat(convert2string, " %s=\"%s\"", name, this.attributes[name]);
      end while (this.attributes.next(name));
   end
   foreach(this.fields[i]) begin
      $sformat(convert2string, "%s\n%s", convert2string,
               this.fields[i].convert2string());
   end

   if (read_in_progress == 1'b1) begin
      if (fname != "" && lineno != 0)
         $sformat(res_str, "%s:%0d ",fname, lineno);
      convert2string = {convert2string, "\n", res_str, "currently executing read method"}; 
   end
   if ( write_in_progress == 1'b1) begin
      if (fname != "" && lineno != 0)
         $sformat(res_str, "%s:%0d ",fname, lineno);
      convert2string = {convert2string, "\n", res_str, "currently executing write method"}; 
   end

endfunction: convert2string


// do_print

function void uvm_ral_reg::do_print (uvm_printer printer);
  super.do_print(printer);
endfunction



// clone

function uvm_object uvm_ral_reg::clone();
  `uvm_fatal("RAL","RAL registers cannot be cloned")
  return null;
endfunction

// do_copy

function void uvm_ral_reg::do_copy(uvm_object rhs);
  `uvm_fatal("RAL","RAL registers cannot be copied")
endfunction


// do_compare

function bit uvm_ral_reg::do_compare (uvm_object  rhs,
                                        uvm_comparer comparer);
  `uvm_warning("RAL","RAL registers cannot be compared")
  return 0;
endfunction


// do_pack

function void uvm_ral_reg::do_pack (uvm_packer packer);
  `uvm_warning("RAL","RAL registers cannot be packed")
endfunction


// do_unpack

function void uvm_ral_reg::do_unpack (uvm_packer packer);
  `uvm_warning("RAL","RAL registers cannot be unpacked")
endfunction


