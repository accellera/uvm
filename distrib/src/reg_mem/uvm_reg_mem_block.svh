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



//------------------------------------------------------------------------
// CLASS: uvm_reg_mem_block
// Block abstraction base class
//
// A block represents a design hierarchy. It can contain registers,
// register files, memories and sub-blocks.
//
// A block has one or more address maps, each corresponding to a physical
// interface on the block.
//------------------------------------------------------------------------
virtual class uvm_reg_mem_block extends uvm_object;

   local uvm_reg_mem_block  parent;

   local static bit     m_roots[uvm_reg_mem_block];
   local int unsigned   blks[uvm_reg_mem_block];
   local int unsigned   regs[uvm_reg];
   local int unsigned   vregs[uvm_vreg];
   local int unsigned   mems[uvm_mem];
   local bit            maps[uvm_reg_mem_map];

   uvm_path_e      default_path = UVM_DEFAULT_PATH;
   local string         default_hdl_path = "RTL";
   local uvm_reg_backdoor backdoor;
   local uvm_object_string_pool #(uvm_queue #(string)) hdl_paths_pool;
   local string         root_hdl_paths[string];

   local bit            locked;

   local string         attributes[string];
   local string         constr[$];

   local int            has_cover;
   local int            cover_on;
   local string         fname = "";
   local int            lineno = 0;

   local static int id = 0;

   //----------------------
   // Group: Initialization
   //----------------------


   //------------------------------------------------------------------------
   // FUNCTION: new
   // Create a new instance and type-specific configuration
   //
   // Creates an instance of a block abstraction class with the specified
   // name.
   //
   // ~has_cover~ specifies which functional coverage models are present in
   // the extension of the block abstraction class.
   // Multiple functional coverage models may be specified by adding their
   // symbolic names, as defined by the <uvm_coverage_model_e> type.
   //------------------------------------------------------------------------
   extern function new(string name="", int has_cover=UVM_NO_COVERAGE);

   //
   // Function: configure
   // Instance-specific configuration
   //
   // Specify the parent block of this block.
   // A block without parent is a root block.
   //
   // If the block file corresponds to a hierarchical RTL structure,
   // it's contribution to the HDL path is specified as the ~hdl_path~.
   // Otherwise, the block does not correspond to a hierarchical RTL
   // structure (e.g. it is physically flattened) and does not contribute
   // to the hierarchical HDL path of any contained registers or memories.
   //
   extern virtual function void configure(uvm_reg_mem_block parent=null, string hdl_path="");

   //
   // Function: create_map
   // Create an address map in this block
   //
   // Create an address map with the specified ~name~.
   // The base address is usually 0.
   // ~n_bytes~ specifies the number of bytes in the datapath that accesses
   // this address map.
   // ~endian~ specifies the endianness, should a register or sub-map with
   // a greater number of bytes be accessed.
   //|
   //| APB = create_map("APB", 0, 1, UVM_LITTLE_ENDIAN);
   //|
   extern virtual function uvm_reg_mem_map create_map(string name,
                                                  uvm_reg_mem_addr_t base_addr,
                                                  int unsigned n_bytes,
                                                  uvm_endianness_e endian);

   //
   // Function: set_default_map
   // Defines the default address map
   //
   // Set the specified address map as the <default_map> for this
   // block. The address map must be a map of this address block.
   //
   extern function void                set_default_map (uvm_reg_mem_map map);

   //
   // Variable: default_map
   // Default address map
   //
   // Default address map for this block, to be used when no
   // address map is specified for a register operation and that
   // register is accessible from more than one address map.
   //
   // It is also the implciit address map for a block with a single,
   // unamed address map because it has only one physical interface.
   //
   uvm_reg_mem_map          default_map;
   extern function uvm_reg_mem_map         get_default_map ();


   extern virtual function void set_parent(uvm_reg_mem_block parent);

   /*local*/ extern function void add_block (uvm_reg_mem_block blk);
   /*local*/ extern function void add_map   (uvm_reg_mem_map map);
   /*local*/ extern function void add_reg   (uvm_reg  rg);
   /*local*/ extern function void add_vreg  (uvm_vreg vreg);
   /*local*/ extern function void add_mem   (uvm_mem  mem);

   /*local*/ extern virtual function void Xlock_modelX();
   /*local*/ extern function bit Xis_lockedX();


   //---------------------
   // Group: Introspection
   //---------------------


   //
   // Function: get_name
   // Get the simple name
   //
   // Return the simple object name of this block.
   //

   //
   // Function: get_full_name
   // Get the hierarchical name
   //
   // Return the hierarchal name of this block.
   // The base of the hierarchical name is the root block.
   //
   extern virtual function string        get_full_name();

   //
   // FUNCTION: get_parent
   // Get the parent block
   //
   // If this a top-level block, returns ~null~. 
   //
   extern virtual function uvm_reg_mem_block get_parent();

   //
   // FUNCTION: get_root_blocks
   // Get the all root blocks
   //
   // Returns an array of all root blocks in the simulation.
   //
   extern static  function void get_root_blocks(ref uvm_reg_mem_block blks[$]);
      
   //
   // Function: get_blocks
   // Get the sub-blocks
   //
   // Get the blocks instantiated in this blocks.
   // If ~hier~ is TRUE, recursively includes any sub-blocks.
   //
   extern virtual function void get_blocks           (ref uvm_reg_mem_block  blks[$],   input uvm_hier_e hier=UVM_HIER);

   //
   // Function: get_maps
   // Get the address maps
   //
   // Get the address maps instantiated in this block.
   //
   extern virtual function void get_maps             (ref uvm_reg_mem_map    maps[$]);

   //
   // Function: get_registers
   // Get the registers
   //
   // Get the registers instantiated in this block.
   // If ~hier~ is TRUE, recursively includes the registers
   // in the sub-blocks.
   //
   // Note that registers may be located in different and/or multiple
   // address maps. To get the registers in a specific address map,
   // use the <uvm_reg_mem_map::get_registers()> method.
   //
   extern virtual function void get_registers        (ref uvm_reg    regs[$],   input uvm_hier_e hier=UVM_HIER);

   //
   // Function: get_fields
   // Get the fields
   //
   // Get the fields in the registers instantiated in this block.
   // If ~hier~ is TRUE, recursively includes the fields of the registers
   // in the sub-blocks.
   //
   extern virtual function void get_fields           (ref uvm_reg_field  fields[$], input uvm_hier_e hier=UVM_HIER);

   //
   // Function get_memories
   // Get the memories
   //
   // Get the memories instantiated in this block.
   // If ~hier~ is TRUE, recursively includes the memories
   // in the sub-blocks.
   //
   // Note that memories may be located in different and/or multiple
   // address maps. To get the memories in a specific address map,
   // use the <uvm_reg_mem_map::get_memories()> method.
   //
   extern virtual function void get_memories         (ref uvm_mem    mems[$],   input uvm_hier_e hier=UVM_HIER);

   //
   // Function: get_virtual_registers
   // Get the virtual registers
   //
   // Get the virtual registers instantiated in this block.
   // If ~hier~ is TRUE, recursively includes the virtual registers
   // in the sub-blocks.
   //
   extern virtual function void get_virtual_registers(ref uvm_vreg   regs[$],   input uvm_hier_e hier=UVM_HIER);

   //
   // Function: get_virtual_fields
   // Get the virtual fields
   //
   // Get the virtual fields from the virtual registers instantiated
   // in this block.
   // If ~hier~ is TRUE, recursively includes the virtual fields
   // in the virtual registers in the sub-blocks.
   //
   extern virtual function void get_virtual_fields   (ref uvm_vreg_field fields[$], input uvm_hier_e hier=UVM_HIER);

   //
   // FUNCTION: get_block_by_name
   // Finds a sub-block with the specified simple name.
   //
   // The name is the simple name of the block, not a hierarchical name.
   // relative to this block.
   // If no block with that name is found in this block, the sub-blocks
   // are searched for a block of that name and the first one to be found
   // is returned.
   //
   // If no blocks are found, returns ~null~.
   //
   extern virtual function uvm_reg_mem_block  get_block_by_name  (string name);  

   //
   // FUNCTION: get_map_by_name
   // Finds an address map with the specified simple name.
   //
   // The name is the simple name of the address map, not a hierarchical name.
   // relative to this block.
   // If no map with that name is found in this block, the sub-blocks
   // are searched for a map of that name and the first one to be found
   // is returned.
   //
   // If no address maps are found, returns ~null~.
   //
   extern virtual function uvm_reg_mem_map    get_map_by_name    (string name);

   //
   // FUNCTION: get_reg_by_name
   // Finds a register with the specified simple name.
   //
   // The name is the simple name of the register, not a hierarchical name.
   // relative to this block.
   // If no register with that name is found in this block, the sub-blocks
   // are searched for a register of that name and the first one to be found
   // is returned.
   //
   // If no registers are found, returns ~null~.
   //
   extern virtual function uvm_reg    get_reg_by_name    (string name);

   //
   // FUNCTION: get_field_by_name
   // Finds a field with the specified simple name.
   //
   // The name is the simple name of the field, not a hierarchical name.
   // relative to this block.
   // If no field with that name is found in this block, the sub-blocks
   // are searched for a field of that name and the first one to be found
   // is returned.
   //
   // If no fields are found, returns ~null~.
   //
   extern virtual function uvm_reg_field  get_field_by_name  (string name);

   //
   // FUNCTION: get_mem_by_name
   // Finds a memory with the specified simple name.
   //
   // The name is the simple name of the memory, not a hierarchical name.
   // relative to this block.
   // If no memory with that name is found in this block, the sub-blocks
   // are searched for a memory of that name and the first one to be found
   // is returned.
   //
   // If no memories are found, returns ~null~.
   //
   extern virtual function uvm_mem    get_mem_by_name    (string name);

   //
   // FUNCTION: get_vreg_by_name
   // Finds a virtual register with the specified simple name.
   //
   // The name is the simple name of the virtual register,
   // not a hierarchical name.
   // relative to this block.
   // If no virtual register with that name is found in this block,
   // the sub-blocks are searched for a virtual register of that name
   // and the first one to be found is returned.
   //
   // If no virtual registers are found, returns ~null~.
   //
   extern virtual function uvm_vreg   get_vreg_by_name   (string name);

   //
   // FUNCTION: get_vfield_by_name
   // Finds a virtual field with the specified simple name.
   //
   // The name is the simple name of the virtual field,
   // not a hierarchical name.
   // relative to this block.
   // If no virtual field with that name is found in this block,
   // the sub-blocks are searched for a virtual field of that name
   // and the first one to be found is returned.
   //
   // If no virtual fields are found, returns ~null~.
   //
   extern virtual function uvm_vreg_field get_vfield_by_name (string name);


   //------------------
   // Group: Attributes
   //------------------


   //
   // FUNCTION: set_attribute
   // Set an attribute.
   //
   // Set the specified attribute to the specified value for this block.
   // If the value is specified as "", the specified attribute is deleted.
   // A warning is issued if an existing attribute is modified.
   // 
   // Attribute names are case sensitive. 
   //
   extern virtual function void set_attribute(string name,
                                              string value);

   //
   // FUNCTION: get_attribute
   // Get an attribute value.
   //
   // Get the value of the specified attribute for this block.
   // If the attribute does not exists, "" is returned.
   // If ~inherited~ is specifed as TRUE, the value of the attribute
   // is inherited from the nearest block ancestor
   // for which the attribute
   // is set if it is not specified for this block.
   // If ~inherited~ is specified as FALSE, the value "" is returned
   // if it does not exists in the this block.
   // 
   // Attribute names are case sensitive.
   // 
   extern virtual function string get_attribute(string name,
                                                bit inherited = 1);

   //
   // FUNCTION: get_attributes
   // Get all attribute values.
   //
   // Get the name of all attribute for this block.
   // If ~inherited~ is specifed as TRUE, the value for all attributes
   // inherited from all block ancestors are included.
   // 
   extern virtual function void get_attributes(ref string names[string],
                                                   input bit inherited = 1);

   
   extern virtual function void get_constraints(ref string names[$]);
   /*local*/ extern function void Xadd_constraintsX(string name);


   //----------------
   // Group: Coverage
   //----------------


   //
   // Function: can_cover
   // Check if block has coverage model(s)
   //
   // Returns TRUE if the block abstraction class contains a coverage model
   // for all of the models specified.
   // Models are specified by adding the symbolic value of individual
   // coverage model as defined in <uvm_coverage_model_e>.
   //
   extern virtual function bit can_cover(int models);

   //
   // FUNCTION: set_cover
   // Turns on coverage measurement.
   //
   // Turns the collection of functional coverage measurements on or off
   // for this block and all blocks, registers, fields and memories within it.
   // The functional coverage measurement is turned on for every
   // coverage model specified using <uvm_coverage_model_e> symbolic
   // identifers.
   // Multiple functional coverage models can be specified by adding
   // the functional coverage model identifiers.
   // All other functional coverage models are turned off.
   // Returns the sum of all functional
   // coverage models whose measurements were previously on.
   //
   // This method can only control the measurement of functional
   // coverage models that are present in the various abstraction classes,
   // then enabled during construction.
   // See the <uvm_reg_mem_block::can_cover()> method to identify
   // the available functional coverage models.
   //
   extern virtual function int set_cover(int is_on);

   //
   // FUNCTION: is_cover_on
   // Check if coverage measurement is on.
   //
   // Returns TRUE if measurement for all of the specified functional
   // coverage models are currently on.
   // Multiple functional coverage models can be specified by adding the
   // functional coverage model identifiers.
   //
   // See <uvm_reg_mem_block::set_cover()> for more details. 
   //
   extern virtual function bit is_cover_on(int is_on = UVM_ALL_COVERAGE);

   /*local*/ extern virtual function void XsampleX(uvm_reg_mem_addr_t  addr,
                                                   uvm_reg_mem_map  map);
   protected virtual function void     map_coverage    (uvm_reg_mem_map map);
   endfunction


   //--------------
   // Group: Access
   //--------------

   //
   // Function: get_default_path
   // Default access path
   //
   // Returns the default access path for this block.
   //
   extern virtual function uvm_path_e get_default_path();


   //
   // FUNCTION: reset
   // Reset the mirror for this block.
   //
   // Sets the mirror value of all registers in the block and sub-blocks
   // to the reset value corresponding to the specified reset event.
   // See <uvm_reg_field.reset()> for more details.
   // Does not actually set the value of the registers in the design,
   // only the values mirrored in their corresponding mirror.
   //
   extern virtual function void reset(string kind = "HARD");


   //
   // FUNCTION: needs_update
   // Check if DUT registers need to be written
   //
   // If a mirror value has been modified in the abstraction model
   // without actually updating the actual register
   // (either through randomization or via the <uvm_reg::set()> method,
   // the mirror and state of the registers are outdated.
   // The corresponding registers in the DUT need to be updated.
   //
   // This method returns TRUE if the state of at lest one register in
   // the block or sub-blocks needs to be updated to match the mirrored
   // values.
   // The mirror values, or actual content of registers, are not modified.
   // For additional information, see <uvm_reg_mem_block::update()> method.
   //
   extern virtual function bit needs_update();


   //
   // TASK: update
   // Batch update of register.
   //
   // Using the minimum number of write operations, updates the registers
   // in the design to match the mirrored values in this block and sub-blocks.
   // The update can be performed using the physical
   // interfaces (front-door access) or back-door accesses.
   // This method performs the reverse operation of <uvm_reg_mem_block::mirror()>. 
   //
   extern virtual task update(output uvm_status_e  status,
                              input  uvm_path_e    path = UVM_DEFAULT_PATH,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);


   //
   // TASK: mirror
   // Update the mirrored values
   //
   // Read all of the registers in this block and sub-blcoks and update their
   // mirror values to match their corresponding values in the design.
   // The mirroring can be performed using the physical interfaces
   // (front-door access) or back-door accesses.
   // If the ~check~ argument is specified as ~UVM_VERB~,
   // an error message is issued if the current mirrored value
   // does not match the actual value in the design.
   // This method performs the reverse operation of <uvm_reg_mem_block::update()>.
   // 
   extern virtual task mirror(output uvm_status_e  status,
                              input  uvm_check_e   check = UVM_NO_CHECK,
                              input  uvm_path_e    path  = UVM_DEFAULT_PATH,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);

   //
   // Task: write_reg_by_name
   // Write the named register
   //
   // Equivalent to <get_reg_by_name()> followed by <uvm_reg::write()>
   //
   extern virtual task write_reg_by_name(
                              output uvm_status_e   status,
                              input  string              name,
                              input  uvm_reg_mem_data_t      data,
                              input  uvm_path_e     path = UVM_DEFAULT_PATH,
                              input  uvm_reg_mem_map         map = null,
                              input  uvm_sequence_base   parent = null,
                              input  int                 prior = -1,
                              input  uvm_object          extension = null,
                              input  string              fname = "",
                              input  int                 lineno = 0);

   //
   // Task: read_reg_by_name
   // Read the named register
   //
   // Equivalent to <get_reg_by_name()> followed by <uvm_reg::read()>
   //
   extern virtual task read_reg_by_name(
                              output uvm_status_e  status,
                              input  string             name,
                              output uvm_reg_mem_data_t     data,
                              input  uvm_path_e    path = UVM_DEFAULT_PATH,
                              input  uvm_reg_mem_map        map = null,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);

   //
   // Task: write_mem_by_name
   // Write the named memory
   //
   // Equivalent to <get_mem_by_name()> followed by <uvm_mem::write()>
   //
   extern virtual task write_mem_by_name(
                              output uvm_status_e  status,
                              input  string             name,
                              input  uvm_reg_mem_addr_t     offset,
                              input  uvm_reg_mem_data_t     data,
                              input  uvm_path_e    path = UVM_DEFAULT_PATH,
                              input  uvm_reg_mem_map        map = null,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);

   //
   // Task: read_mem_by_name
   // Read the named memory
   //
   // Equivalent to <get_mem_by_name()> followed by <uvm_mem::read()>
   //
   extern virtual task read_mem_by_name(
                              output uvm_status_e  status,
                              input  string             name,
                              input  uvm_reg_mem_addr_t     offset,
                              output uvm_reg_mem_data_t     data,
                              input  uvm_path_e    path = UVM_DEFAULT_PATH,
                              input  uvm_reg_mem_map        map = null,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);


   extern virtual task readmemh(string filename);
   extern virtual task writememh(string filename);


   //----------------
   // Group: Backdoor
   //----------------

   //
   // Function: get_backdoor
   // Get the user-defined backdoor for all registers in this block
   //
   // Return the user-defined backdoor for all register in this
   // block and all sub-blocks -- unless overriden by a backdoor set
   // in a lower-level block or in the register itself.
   //
   // If ~inherit~ is TRUE, returns the backdoor of the parent block
   // if none have been specified for this block.
   //
   extern function uvm_reg_backdoor get_backdoor(bit inherit = 1);

   //
   // Function: set_backdoor
   // Set the user-defined backdoor for all registers in this block
   //
   // Defines the backdoor mechanism for all registers instantiated
   // in this block and sub-blocks, unless overriden by a definition
   // in a lower-level block or register.
   //
   extern function void set_backdoor        (uvm_reg_backdoor bkdr,
                                             string fname = "",
                                             int lineno = 0);

   //
   // Function:  clear_hdl_path
   // Delete HDL paths
   //
   // Remove any previously specified HDL path to the block instance
   // for the specified design abstraction.
   //
   extern function void clear_hdl_path    (string kind = "RTL");

   //
   // Function:  add_hdl_path
   // Add an HDL path
   //
   // Add the specified HDL path to the block instance for the specified
   // design abstraction. This method may be called more than once for the
   // same design abstraction if the block is physically duplicated
   // in the design abstraction
   //
   extern function void add_hdl_path      (string path, string kind = "RTL");

   //
   // Function:   has_hdl_path
   // Check if a HDL path is specified
   //
   // Returns TRUE if the block instance has a HDL path defined for the
   // specified design abstraction. If no design abstraction is specified,
   // uses the default design abstraction specified for this block or
   // the nearest block ancestor with a specified default design abstraction.
   //
   extern function bit  has_hdl_path      (string kind = "");

   //
   // Function:  get_hdl_path
   // Get the incremental HDL path(s)
   //
   // Returns the HDL path(s) defined for the specified design abstraction
   // in the block instance.
   // Returns only the component of the HDL paths that corresponds to
   // the block, not a full hierarchical path
   //
   // If no design asbtraction is specified, the default design abstraction
   // for this block is used.
   //
   extern function void get_hdl_path      (ref string paths[$], input string kind = "");

   //
   // Function:  get_full_hdl_path
   // Get the full hierarchical HDL path(s)
   //
   // Returns the full hierarchical HDL path(s) defined for the specified
   // design abstraction in the block instance.
   // There may be more than one path returned even
   // if only one path was defined for the block instance, if any of the
   // parent components have more than one path defined for the same design
   // abstraction
   //
   // If no design asbtraction is specified, the default design abstraction
   // for each ancestor block is used to get each incremental path.
   //
   extern function void get_full_hdl_path (ref string paths[$], input string kind = "");

   //
   // Function:    set_default_hdl_path
   // Set the default design abstraction
   //
   // Set the default design abstraction for this block instance.
   //
   extern function void   set_default_hdl_path (string kind);

   //
   // Function:  get_default_hdl_path
   // Get the default design abstraction
   //
   // Returns the default design abstraction for this block instance.
   // If a default design abstraction has not been explicitly set for this
   // block instance, returns the default design absraction for the
   // nearest block ancestor.
   // Returns "" if no default design abstraction has been specified.
   //
   extern function string get_default_hdl_path ();

   //
   // Function: set_hdl_path_root
   // Specify a root HDL path
   //
   // Set the specified path as the absolute HDL path to the block instance
   // for the specified design abstraction.
   // This absolute root path is preppended to all hierarchical paths
   // under this block. The HDL path of any ancestor block is ignored.
   // This method overrides any incremental path for the
   // same design abstraction specified using <add_hdl_path>.
   //
   extern function void   set_hdl_path_root    (string path, string kind = "RTL");

   //
   // Function: is_hdl_path_root
   // Check if this block has an absolute path
   //
   // Returns TRUE if an absolute HDL path to the block instance
   // for the specified design abstraction has been defined.
   // If no design asbtraction is specified, the default design abstraction
   // for this block is used.
   //
   extern function bit    is_hdl_path_root     (string kind = "");

   extern virtual function void   do_print      (uvm_printer printer);
   extern virtual function void   do_copy       (uvm_object rhs);
   extern virtual function bit    do_compare    (uvm_object  rhs,
                                                 uvm_comparer comparer);
   extern virtual function void   do_pack       (uvm_packer packer);
   extern virtual function void   do_unpack     (uvm_packer packer);
   extern virtual function string convert2string ();
   extern virtual function uvm_object clone();
   
   extern local function void Xinit_address_mapsX();

endclass: uvm_reg_mem_block

//------------------------------------------------------------------------


//---------------
// Initialization
//---------------

// new

function uvm_reg_mem_block::new(string name="", int has_cover=UVM_NO_COVERAGE);
   super.new(name);
   hdl_paths_pool = new("hdl_paths");
   this.has_cover = has_cover;
   // Root block until registered with a parent
   m_roots[this] = 1;
endfunction: new


// configure

function void uvm_reg_mem_block::configure(uvm_reg_mem_block parent=null, string hdl_path="");
  this.parent = parent; 
  if (parent != null)
    this.parent.add_block(this);
  add_hdl_path(hdl_path);
endfunction


// add_block

function void uvm_reg_mem_block::add_block (uvm_reg_mem_block blk);
   if (this.Xis_lockedX()) begin
      `uvm_error("RegMem", "Cannot add subblock to locked block model");
      return;
   end
   if (this.blks.exists(blk)) begin
      `uvm_error("RegMem", {"Subblock '",blk.get_name(),
         "' has already been registered with block '",get_name(),"'"})
       return;
   end
   blks[blk] = id++;
   if (m_roots.exists(blk)) m_roots.delete(blk);
endfunction


// add_reg

function void uvm_reg_mem_block::add_reg(uvm_reg rg);
   if (this.Xis_lockedX()) begin
      `uvm_error("RegMem", "Cannot add register to locked block model");
      return;
   end

   if (this.regs.exists(rg)) begin
      `uvm_error("RegMem", {"Register '",rg.get_name(),
         "' has already been registered with block '",get_name(),"'"})
       return;
   end

   regs[rg] = id++;
endfunction: add_reg


// add_vreg

function void uvm_reg_mem_block::add_vreg(uvm_vreg vreg);
   if (this.Xis_lockedX()) begin
      `uvm_error("RegMem", "Cannot add virtual register to locked block model");
      return;
   end

   if (this.vregs.exists(vreg)) begin
      `uvm_error("RegMem", {"Virtual register '",vreg.get_name(),
         "' has already been registered with block '",get_name(),"'"})
       return;
   end
   vregs[vreg] = id++;
endfunction: add_vreg


// add_mem

function void uvm_reg_mem_block::add_mem(uvm_mem mem);
   if (this.Xis_lockedX()) begin
      `uvm_error("RegMem", "Cannot add memory to locked block model");
      return;
   end

   if (this.mems.exists(mem)) begin
      `uvm_error("RegMem", {"Memory '",mem.get_name(),
         "' has already been registered with block '",get_name(),"'"})
       return;
   end
   mems[mem] = id++;
endfunction: add_mem


// set_parent

function void uvm_reg_mem_block::set_parent(uvm_reg_mem_block parent);
  if (this != parent)
    this.parent = parent;
endfunction


// Xis_lockedX

function bit uvm_reg_mem_block::Xis_lockedX();
   Xis_lockedX = this.locked;
endfunction: Xis_lockedX


// Xlock_modelX

function void uvm_reg_mem_block::Xlock_modelX();

   if (Xis_lockedX())
     return;

   locked = 1;

   foreach (regs[rg])
     rg.Xlock_modelX();

   foreach (mems[mem])
     mem.Xlock_modelX();

   foreach (blks[blk])
     blk.Xlock_modelX();

   //`ifndef UVM_REG_FAST_SRCH
   if (this.parent == null)
      Xinit_address_mapsX();
   //`endif

   //if (this.parent == null)
   //   foreach (maps[map])
   //     map.Xcheck_overlapX();

endfunction: Xlock_modelX



//--------------------------
// Get Hierarchical Elements
//--------------------------

function string uvm_reg_mem_block::get_full_name();
   uvm_reg_mem_block blk;

   get_full_name = this.get_name();

   // Do not include top-level name in full name
   blk = this.get_parent();

   if (blk == null)
     return get_full_name;

   if (blk.get_parent() == null)
     return get_full_name;

   get_full_name = {this.parent.get_full_name(), ".", get_full_name};

endfunction: get_full_name


// get_fields

function void uvm_reg_mem_block::get_fields(ref uvm_reg_field fields[$],
                                        input uvm_hier_e hier=UVM_HIER);

   foreach (this.regs[rg])
     rg.get_fields(fields);
   
   if (hier == UVM_HIER)
     foreach (this.blks[blk])
       blk.get_fields(fields);

endfunction: get_fields


// get_virtual_fields

function void uvm_reg_mem_block::get_virtual_fields(ref uvm_vreg_field fields[$],
                                                input uvm_hier_e hier=UVM_HIER);

   foreach (this.vregs[vreg])
     vreg.get_fields(fields);
   
   if (hier == UVM_HIER)
     foreach (this.blks[blk])
       blk.get_virtual_fields(fields);

endfunction: get_virtual_fields


// get_registers

function void uvm_reg_mem_block::get_registers(ref uvm_reg regs[$],
                                           input uvm_hier_e hier=UVM_HIER);

   foreach (this.regs[rg])
     regs.push_back(rg);

   if (hier == UVM_HIER)
     foreach (this.blks[blk])
       blk.get_registers(regs);

endfunction: get_registers


// get_virtual_registers

function void uvm_reg_mem_block::get_virtual_registers(ref uvm_vreg regs[$],
                                                   input uvm_hier_e hier=UVM_HIER);

   foreach (this.vregs[rg])
     regs.push_back(rg);

   if (hier == UVM_HIER)
     foreach (this.blks[blk])
       blk.get_virtual_registers(regs);

endfunction: get_virtual_registers


// get_memories

function void uvm_reg_mem_block::get_memories(ref uvm_mem mems[$],
                                          input uvm_hier_e hier=UVM_HIER);

   foreach (this.mems[mem])
     mems.push_back(mem);

   if (hier == UVM_HIER)
     foreach (this.blks[blk])
       blk.get_memories(mems);

endfunction: get_memories


// get_blocks

function void uvm_reg_mem_block::get_blocks(ref uvm_reg_mem_block blks[$],
                                        input uvm_hier_e hier=UVM_HIER);

   foreach (this.blks[blk]) begin
     blks.push_back(blk);
     if (hier == UVM_HIER)
       blk.get_blocks(blks);
   end

endfunction: get_blocks


// get_root_blocks

function void uvm_reg_mem_block::get_root_blocks(ref uvm_reg_mem_block blks[$]);

   foreach (m_roots[blk]) begin
      blks.push_back(blk);
   end

endfunction: get_root_blocks


// get_maps

function void uvm_reg_mem_block::get_maps(ref uvm_reg_mem_map maps[$]);

   foreach (this.maps[map])
     maps.push_back(map);

endfunction


// get_parent

function uvm_reg_mem_block uvm_reg_mem_block::get_parent();
   get_parent = this.parent;
endfunction: get_parent


//------------
// Get-By-Name
//------------

// get_block_by_name

function uvm_reg_mem_block uvm_reg_mem_block::get_block_by_name(string name);

   if (get_name() == name)
     return this;

   foreach (blks[blk]) begin
     uvm_reg_mem_block tmp_blk;
     if (blk.get_name() == name)
       return blk;
     tmp_blk = blk.get_block_by_name(name);
     if (tmp_blk != null)
       return tmp_blk;
   end

   `uvm_warning("RegMem", {"Unable to locate block '",name,
                "' in block '",get_full_name(),"'"})
   return null;

endfunction: get_block_by_name


// get_reg_by_name

function uvm_reg uvm_reg_mem_block::get_reg_by_name(string name);

   foreach (regs[rg])
     if (rg.get_name() == name)
       return rg;

   foreach (blks[blk]) begin
     uvm_reg rg;
     rg = blk.get_reg_by_name(name);
     if (rg != null)
       return rg;
   end

   `uvm_warning("RegMem", {"Unable to locate register '",name,
                "' in block '",get_full_name(),"'"})
   return null;

endfunction: get_reg_by_name


// get_vreg_by_name

function uvm_vreg uvm_reg_mem_block::get_vreg_by_name(string name);

   foreach (vregs[rg])
     if (rg.get_name() == name)
       return rg;

   foreach (blks[blk]) begin
     uvm_vreg rg;
     rg = blk.get_vreg_by_name(name);
     if (rg != null)
       return rg;
   end

   `uvm_warning("RegMem", {"Unable to locate virtual register '",name,
                "' in block '",get_full_name(),"'"})
   return null;

endfunction: get_vreg_by_name


// get_mem_by_name

function uvm_mem uvm_reg_mem_block::get_mem_by_name(string name);

   foreach (mems[mem])
     if (mem.get_name() == name)
       return mem;

   foreach (blks[blk]) begin
     uvm_mem mem;
     mem = blk.get_mem_by_name(name);
     if (mem != null)
       return mem;
   end

   `uvm_warning("RegMem", {"Unable to locate memory '",name,
                "' in block '",get_full_name(),"'"})
   return null;

endfunction: get_mem_by_name


// get_field_by_name

function uvm_reg_field uvm_reg_mem_block::get_field_by_name(string name);

   foreach (regs[rg]) begin
      uvm_reg_field fields[$];
      rg.get_fields(fields);
      foreach (fields[i])
        if (fields[i].get_name() == name)
          return fields[i];
   end

   foreach (blks[blk]) begin
     uvm_reg_field field;
     field = blk.get_field_by_name(name);
     if (field != null)
       return field;
   end

   `uvm_warning("RegMem", {"Unable to locate field '",name,
                "' in block '",get_full_name(),"'"})

   return null;

endfunction: get_field_by_name


// get_vfield_by_name

function uvm_vreg_field uvm_reg_mem_block::get_vfield_by_name(string name);

   foreach (vregs[rg]) begin
      uvm_vreg_field fields[$];
      rg.get_fields(fields);
      foreach (fields[i])
        if (fields[i].get_name() == name)
          return fields[i];
   end

   foreach (blks[blk]) begin
     uvm_vreg_field field;
     field = blk.get_vfield_by_name(name);
     if (field != null)
       return field;
   end

   `uvm_warning("RegMem", {"Unable to locate virtual field '",name,
                "' in block '",get_full_name(),"'"})

   return null;

endfunction: get_vfield_by_name



//-------------
// Coverage API
//-------------

// set_cover

function int uvm_reg_mem_block::set_cover(int is_on);
   int can_cvr;

   if (is_on == UVM_NO_COVERAGE) begin
      this.cover_on = is_on;
      return this.cover_on;
   end

   if ((this.has_cover & is_on) == 0) begin
      `uvm_warning("RegMem", {this.get_full_name()," - Cannot turn ON any ",
          "coverage becasue the corresponding coverage model was not generated."})
      return this.cover_on;
   end

   if (is_on & UVM_REG_BITS) begin
      if (this.has_cover & UVM_REG_BITS) begin
          this.cover_on |= UVM_REG_BITS;
      end
      else begin
        `uvm_warning("RegMem", {this.get_full_name()," - Cannot turn ON Register Bit ",
            "coverage becasue the corresponding coverage model was not generated."})
      end
   end

   if (is_on & UVM_FIELD_VALS) begin
      if (this.has_cover & UVM_FIELD_VALS) begin
          this.cover_on |= UVM_FIELD_VALS;
      end
      else begin
        `uvm_warning("RegMem", {this.get_full_name()," - Cannot turn ON Field Value ",
            "coverage becasue the corresponding coverage model was not generated."})
      end
   end

   if (is_on & UVM_ADDR_MAP) begin
      if (this.has_cover & UVM_ADDR_MAP) begin
          this.cover_on |= UVM_ADDR_MAP;
      end 
      else begin
        `uvm_warning("RegMem", {this.get_full_name()," - Cannot turn ON Address Map ",
            "coverage becasue the corresponding coverage model was not generated."})
      end
   end

   set_cover = this.cover_on;

   can_cvr = is_on & set_cover; 

   if (can_cvr == 0)
     return set_cover;

   foreach (regs[rg])
     rg.set_cover(can_cvr);

   foreach (mems[mem])
     mem.set_cover(can_cvr);

   foreach (blks[blk])
     blk.set_cover(can_cvr);

endfunction: set_cover


// sample

function void uvm_reg_mem_block::XsampleX(uvm_reg_mem_addr_t addr,
                                    uvm_reg_mem_map map);
   // Nothing to do in this base class
endfunction


// can_cover

function bit uvm_reg_mem_block::can_cover(int models);
   return ((this.has_cover & models) == models);
endfunction: can_cover


// is_cover_on

function bit uvm_reg_mem_block::is_cover_on(int is_on = UVM_ALL_COVERAGE);
   if (this.can_cover(is_on) == 0) return 0;
   return ((this.cover_on & is_on) == is_on);
endfunction: is_cover_on


//-------------------------
// Attributes & Constraints
//-------------------------

// set_attribute

function void uvm_reg_mem_block::set_attribute(string name,
                                           string value);
   if (name == "") begin
      `uvm_error("RegMem", {"Cannot set anonymous attribute \"\" in block '",
                         get_full_name(),"'"})
      return;
   end

   if (this.attributes.exists(name)) begin
      if (value != "") begin
         `uvm_warning("RegMem", {"Redefining attribute '",name,"' in block '",
                         get_full_name(),"' to '",value,"'"})
         this.attributes[name] = value;
      end
      else begin
         this.attributes.delete(name);
      end
      return;
   end

   if (value == "") begin
      `uvm_warning("RegMem", {"Attempting to delete non-existent attribute '",
                          name, "' in block '", get_full_name(), "'"})
      return;
   end

   this.attributes[name] = value;

endfunction: set_attribute


// get_attribute

function string uvm_reg_mem_block::get_attribute(string name, bit inherited = 1);

   if (inherited && parent != null)
      get_attribute = parent.get_attribute(name);

   if (get_attribute == "" && this.attributes.exists(name))
      return this.attributes[name];

   return "";
endfunction


// get_attributes

function void uvm_reg_mem_block::get_attributes(ref string names[string],
                                            input bit inherited = 1);
   // attributes at higher levels supercede those at lower levels
   if (inherited && parent != null)
     parent.get_attributes(names,1);

   foreach (attributes[nm])
     if (!names.exists(nm))
       names[nm] = attributes[nm];

endfunction: get_attributes


// Xadd_constraintsX

function void uvm_reg_mem_block::Xadd_constraintsX(string name);

   if (this.locked) begin
      `uvm_error("RegMem", "Cannot add constraints to locked model");
      return;
   end

   // Check if the constraint block already exists
   foreach (this.constr[i]) begin
      if (this.constr[i] == name) begin
         `uvm_warning("RegMem", $psprintf("Constraint \"%s\" already added",
                                          name));
         return;
      end
   end

   constr.push_back(name);

endfunction: Xadd_constraintsX


// get_constraints

function void uvm_reg_mem_block::get_constraints(ref string names[$]);
  names = constr;
endfunction



//----------------
// Run-Time Access
//----------------


// reset

function void uvm_reg_mem_block::reset(string kind = "HARD");

   foreach (regs[rg])
     rg.reset(kind);

   foreach (blks[blk])
     blk.reset(kind);

endfunction


// needs_update

function bit uvm_reg_mem_block::needs_update();
   needs_update = 0;

   foreach (regs[rg])
     if (rg.needs_update())
       return 1;

   foreach (blks[blk])
     if (blk.needs_update())
       return 1;
endfunction: needs_update


// update

task uvm_reg_mem_block::update(output uvm_status_e  status,
                           input  uvm_path_e    path = UVM_DEFAULT_PATH,
                           input  uvm_sequence_base  parent = null,
                           input  int                prior = -1,
                           input  uvm_object         extension = null,
                           input  string             fname = "",
                           input  int                lineno = 0);
   status = UVM_IS_OK;

   if (!needs_update()) begin
     `uvm_info("RegMem", $sformatf("%s:%0d - RegMem block %s does not need updating",
                    fname, lineno, this.get_name()), UVM_HIGH);

   end
   
   `uvm_info("RegMem", $sformatf("%s:%0d - Updating regmem block %s with %s path",
                    fname, lineno, this.get_name(), path.name ), UVM_HIGH);

   foreach (this.regs[rg]) begin
      if (rg.needs_update()) begin
         rg.update(status, path, null, parent, prior, extension);
         if (status != UVM_IS_OK || status != UVM_HAS_X) begin;
           `uvm_error("RegMem", $sformatf("Register \"%s\" could not be updated",
                                        rg.get_full_name()));
           return;
         end
      end
   end

   foreach (blks[blk])
     blk.update(status,path,parent,prior,extension,fname,lineno);

endtask: update


// mirror

task uvm_reg_mem_block::mirror(output uvm_status_e  status,
                           input  uvm_check_e   check = UVM_NO_CHECK,
                           input  uvm_path_e    path = UVM_DEFAULT_PATH,
                           input  uvm_sequence_base  parent = null,
                           input  int                prior = -1,
                           input  uvm_object         extension = null,
                           input  string             fname = "",
                           input  int                lineno = 0);
   status = UVM_IS_OK;

   if (!needs_update()) begin
     `uvm_info("RegMem", $sformatf("%s:%0d - RegMem block %s does not need updating",
                    fname, lineno, this.get_name()), UVM_HIGH);

   end
   
   `uvm_info("RegMem", $sformatf("%s:%0d - Updating regmem block %s with %s path",
                    fname, lineno, this.get_name(), path.name ), UVM_HIGH);

   foreach (this.regs[rg]) begin
      if (rg.needs_update())  begin
         rg.update(status, path, null, parent, prior, extension);
         if (status != UVM_IS_OK || status != UVM_HAS_X) begin;
           `uvm_error("RegMem", $sformatf("Register \"%s\" could not be updated",
                                        rg.get_full_name()));
           return;
         end
      end
   end

   foreach (blks[blk])
     blk.update(status,path,parent,prior,extension,fname,lineno);

endtask: mirror


// write_reg_by_name

task uvm_reg_mem_block::write_reg_by_name(output uvm_status_e   status,
                                      input  string              name,
                                      input  uvm_reg_mem_data_t      data,
                                      input  uvm_path_e     path = UVM_DEFAULT_PATH,
                                      input  uvm_reg_mem_map      map = null,
                                      input  uvm_sequence_base   parent = null,
                                      input  int                 prior = -1,
                                      input  uvm_object          extension = null,
                                      input  string              fname = "",
                                      input  int                 lineno = 0);
   uvm_reg rg;
   this.fname = fname;
   this.lineno = lineno;

   status = UVM_NOT_OK;
   rg = this.get_reg_by_name(name);
   if (rg != null)
     rg.write(status, data, path, map, parent, prior, extension);

endtask: write_reg_by_name


// read_reg_by_name

task uvm_reg_mem_block::read_reg_by_name(output uvm_status_e  status,
                                     input  string             name,
                                     output uvm_reg_mem_data_t     data,
                                     input  uvm_path_e    path = UVM_DEFAULT_PATH,
                                     input  uvm_reg_mem_map     map = null,
                                     input  uvm_sequence_base  parent = null,
                                     input  int                prior = -1,
                                     input  uvm_object         extension = null,
                                     input  string             fname = "",
                                     input  int                lineno = 0);
   uvm_reg rg;
   this.fname = fname;
   this.lineno = lineno;

   status = UVM_NOT_OK;
   rg = this.get_reg_by_name(name);
   if (rg != null)
     rg.read(status, data, path, map, parent, prior, extension);
endtask: read_reg_by_name


// write_mem_by_name

task uvm_reg_mem_block::write_mem_by_name(output uvm_status_e  status,
                                          input  string             name,
                                          input  uvm_reg_mem_addr_t     offset,
                                          input  uvm_reg_mem_data_t     data,
                                          input  uvm_path_e    path = UVM_DEFAULT_PATH,
                                          input  uvm_reg_mem_map     map = null,
                                          input  uvm_sequence_base  parent = null,
                                          input  int                prior = -1,
                                          input  uvm_object         extension = null,
                                          input  string             fname = "",
                                          input  int                lineno = 0);
   uvm_mem mem;
   this.fname = fname;
   this.lineno = lineno;

   status = UVM_NOT_OK;
   mem = get_mem_by_name(name);
   if (mem != null)
     mem.write(status, offset, data, path, map, parent, prior, extension);
endtask: write_mem_by_name


// read_mem_by_name

task uvm_reg_mem_block::read_mem_by_name(output uvm_status_e  status,
                                         input  string             name,
                                         input  uvm_reg_mem_addr_t     offset,
                                         output uvm_reg_mem_data_t     data,
                                         input  uvm_path_e    path = UVM_DEFAULT_PATH,
                                         input  uvm_reg_mem_map     map = null,
                                         input  uvm_sequence_base  parent = null,
                                         input  int                prior = -1,
                                         input  uvm_object         extension = null,
                                         input  string             fname = "",
                                         input  int                lineno = 0);
   uvm_mem mem;
   this.fname = fname;
   this.lineno = lineno;

   status = UVM_NOT_OK;
   mem = get_mem_by_name(name);
   if (mem != null)
     mem.read(status, offset, data, path, map, parent, prior, extension);
endtask: read_mem_by_name


// readmemh

task uvm_reg_mem_block::readmemh(string filename);
   // TODO
endtask: readmemh


// writememh

task uvm_reg_mem_block::writememh(string filename);
   // TODO
endtask: writememh


//---------------
// Map Management
//---------------

// create_map

function uvm_reg_mem_map uvm_reg_mem_block::create_map(string name, uvm_reg_mem_addr_t base_addr, int unsigned n_bytes, uvm_endianness_e endian);

   uvm_reg_mem_map  map;

   if (this.locked) begin
      `uvm_error("RegMem", "Cannot add map to locked model");
      return null;
   end

   map = uvm_reg_mem_map::type_id::create(name,,this.get_full_name());
   map.configure(this,base_addr,n_bytes,endian);

   this.maps[map] = 1;
   if (maps.num() == 1)
     default_map = map;
   this.map_coverage(map);

   return map;
endfunction


// add_map

function void uvm_reg_mem_block::add_map(uvm_reg_mem_map map);

   if (this.locked) begin
      `uvm_error("RegMem", "Cannot add map to locked model");
      return;
   end

   if (this.maps.exists(map)) begin
      `uvm_error("RegMem", {"Map '",map.get_name(),
                 "' already exists in '",get_full_name(),"'"})
      return;
   end

   this.maps[map] = 1;
   if (maps.num() == 1)
     default_map = map;
   this.map_coverage(map);

endfunction: add_map


// get_map_by_name

function uvm_reg_mem_map uvm_reg_mem_block::get_map_by_name(string name);
   uvm_reg_mem_map maps[$];

   this.get_maps(maps);

   foreach (maps[i])
     if (maps[i].get_name() == name)
       return maps[i];

   foreach (maps[i]) begin
      uvm_reg_mem_map submaps[$];
      maps[i].get_submaps(submaps, UVM_HIER);

      foreach (submaps[j])
         if (submaps[j].get_name() == name)
            return submaps[j];
   end
      

   `uvm_warning("RegMem", {"Map with name '",name,"' does not exist in block"})
   return null;
endfunction


// set_default_map

function void uvm_reg_mem_block::set_default_map(uvm_reg_mem_map map);
  if (!maps.exists(map))
   `uvm_warning("RegMem", {"Map '",map.get_full_name(),"' does not exist in block"})
  default_map = map;
endfunction


// get_default_map

function uvm_reg_mem_map uvm_reg_mem_block::get_default_map();
  return default_map;
endfunction


// get_default_path

function uvm_path_e uvm_reg_mem_block::get_default_path();

   if (this.default_path != UVM_DEFAULT_PATH)
      return this.default_path;

   if (this.parent != null)
      return this.parent.get_default_path();

   return UVM_BFM;

endfunction


// Xinit_address_mapsX

function void uvm_reg_mem_block::Xinit_address_mapsX();
   foreach (this.maps[map]) begin
      map.Xinit_address_mapX();
   end
      //map.Xverify_map_configX();
endfunction


//----------------
// Group- Backdoor
//----------------

// set_backdoor

function void uvm_reg_mem_block::set_backdoor(uvm_reg_backdoor bkdr,
                                          string               fname = "",
                                          int                  lineno = 0);
   bkdr.fname = fname;
   bkdr.lineno = lineno;
   if (this.backdoor != null &&
       this.backdoor.has_update_threads()) begin
      `uvm_warning("RegMem", "Previous register backdoor still has update threads running. Backdoors with active mirroring should only be set before simulation starts.");
   end
   this.backdoor = bkdr;
endfunction: set_backdoor


// get_backdoor

function uvm_reg_backdoor uvm_reg_mem_block::get_backdoor(bit inherit = 1);
   if (backdoor == null && inherit) begin
     uvm_reg_mem_block blk = get_parent();
     while (blk != null) begin
       uvm_reg_backdoor bkdr = blk.get_backdoor();
       if (bkdr != null)
         return bkdr;
       blk = blk.get_parent();
     end
   end
   return this.backdoor;
endfunction: get_backdoor



// clear_hdl_path

function void uvm_reg_mem_block::clear_hdl_path(string kind = "RTL");

  if (kind == "ALL") begin
    hdl_paths_pool = new("hdl_paths");
    return;
  end

  if (kind == "")
    kind = get_default_hdl_path();

  if (!hdl_paths_pool.exists(kind)) begin
    `uvm_warning("RegMem",{"Unknown HDL Abstraction '",kind,"'"})
    return;
  end

  hdl_paths_pool.delete(kind);
endfunction


// add_hdl_path

function void uvm_reg_mem_block::add_hdl_path(string path, string kind = "RTL");

  uvm_queue #(string) paths;

  paths = hdl_paths_pool.get(kind);

  paths.push_back(path);

endfunction


// has_hdl_path

function bit  uvm_reg_mem_block::has_hdl_path(string kind = "");
  if (kind == "") begin
    kind = get_default_hdl_path();
  end
  return hdl_paths_pool.exists(kind);
endfunction


// get_hdl_path

function void uvm_reg_mem_block::get_hdl_path(ref string paths[$], input string kind = "");

  uvm_queue #(string) hdl_paths;

  if (kind == "")
    kind = get_default_hdl_path();

  if (!has_hdl_path(kind)) begin
    `uvm_error("RegMem",{"Block does not have hdl path defined for abstraction '",kind,"'"})
    return;
  end

  hdl_paths = hdl_paths_pool.get(kind);

  for (int i=0; i<hdl_paths.size();i++)
    paths.push_back(hdl_paths.get(i));

endfunction


// get_full_hdl_path

function void uvm_reg_mem_block::get_full_hdl_path(ref string paths[$], input string kind = "");

   if (kind == "")
      kind = get_default_hdl_path();

   paths.delete();
   if (is_hdl_path_root(kind)) begin
      if (root_hdl_paths[kind] != "")
         paths.push_back(root_hdl_paths[kind]);
      return;
   end

   if (!has_hdl_path(kind)) begin
      `uvm_error("RegMem",{"Block does not have hdl path defined for abstraction '",kind,"'"})
      return;
   end
   
   begin
      uvm_queue #(string) hdl_paths = hdl_paths_pool.get(kind);
      string parent_paths[$];

      if (parent != null)
         parent.get_full_hdl_path(parent_paths,kind);

      for (int i=0; i<hdl_paths.size();i++) begin
         string hdl_path = hdl_paths.get(i);

         if (parent_paths.size() == 0) begin
            if (hdl_path != "")
               paths.push_back(hdl_path);

            continue;
         end
         
         foreach (parent_paths[j])  begin
            if (hdl_path == "")
               paths.push_back(parent_paths[j]);
            else
               paths.push_back({ parent_paths[j], ".", hdl_path });
         end
      end
   end
  
endfunction


// get_default_hdl_path

function string uvm_reg_mem_block::get_default_hdl_path();
  if (default_hdl_path == "" && parent != null)
    return parent.get_default_hdl_path();
  return default_hdl_path;
endfunction


// set_default_hdl_path

function void uvm_reg_mem_block::set_default_hdl_path(string kind);

  if (kind == "") begin
    if (parent == null) begin
      `uvm_error("RegMem",{"Block has no parent. ",
           "Must specify a valid HDL abstraction (kind)"})
    end
    kind = parent.get_default_hdl_path();
  end

  default_hdl_path = kind;
endfunction


// set_hdl_path_root

function void uvm_reg_mem_block::set_hdl_path_root (string path, string kind = "RTL");
  if (kind == "")
    kind = get_default_hdl_path();

  root_hdl_paths[kind] = path;
endfunction


// is_hdl_path_root

function bit  uvm_reg_mem_block::is_hdl_path_root (string kind = "");
  if (kind == "")
    kind = get_default_hdl_path();

  return root_hdl_paths.exists(kind);
endfunction


//----------------------------------
// Group- Basic Object Operations
//----------------------------------

// do_print

function void uvm_reg_mem_block::do_print (uvm_printer printer);
  uvm_reg_mem_block prnt = get_parent();
  super.do_print(printer);
  printer.print_generic("initiator", prnt.get_type_name(), -1, convert2string());
endfunction


// clone

function uvm_object uvm_reg_mem_block::clone();
  `uvm_fatal("RegMem","RegMem blocks cannot be cloned")
  return null;
endfunction

// do_copy

function void uvm_reg_mem_block::do_copy(uvm_object rhs);
  `uvm_fatal("RegMem","RegMem blocks cannot be copied")
endfunction


// do_compare

function bit uvm_reg_mem_block::do_compare (uvm_object  rhs,
                                        uvm_comparer comparer);
  `uvm_warning("RegMem","RegMem blocks cannot be compared")
  return 0;
endfunction


// do_pack

function void uvm_reg_mem_block::do_pack (uvm_packer packer);
  `uvm_warning("RegMem","RegMem blocks cannot be packed")
endfunction


// do_unpack

function void uvm_reg_mem_block::do_unpack (uvm_packer packer);
  `uvm_warning("RegMem","RegMem blocks cannot be unpacked")
endfunction


// convert2string

function string uvm_reg_mem_block::convert2string();
   string image;
   string maps[];
   string blk_maps[];
   bit         single_map;
   uvm_endianness_e endian;
   string prefix = "  ";

`ifdef TODO
   single_map = 1;
   if (map == "") begin
      this.get_maps(maps);
      if (maps.size() > 1) single_map = 0;
   end

   if (single_map) begin
      $sformat(image, "%sBlock %s", prefix, this.get_full_name());

      if (map != "")
        $sformat(image, "%s.%s", image, map);

      endian = this.get_endian(map);

      $sformat(image, "%s -- %0d bytes (%s)", image,
               this.get_n_bytes(map), endian.name());

      foreach (blks[i]) begin
         string img;
         img = blks[i].convert2string({prefix, "   "}, blk_maps[i]);
         image = {image, "\n", img};
      end

   end
   else begin
      $sformat(image, "%Block %s", prefix, this.get_full_name());
      foreach (maps[i]) begin
         string img;
         endian = this.get_endian(maps[i]);
         $sformat(img, "%s   Map \"%s\" -- %0d bytes (%s)",
                  prefix, maps[i],
                  this.get_n_bytes(maps[i]), endian.name());
         image = {image, "\n", img};

         this.get_blocks(blks, blk_maps, maps[i]);
         foreach (blks[j]) begin
            img = blks[j].convert2string({prefix, "      "},
                                    blk_maps[j]);
            image = {image, "\n", img};
         end

         this.get_subsys(sys, blk_maps, maps[i]);
         foreach (sys[j]) begin
            img = sys[j].convert2string({prefix, "      "},
                                   blk_maps[j]);
            image = {image, "\n", img};
         end
      end
   end
`endif
   return image;
endfunction: convert2string



