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

//
// Title: uvm_ral_field
// Field abstraction base class
//
// A field is an atomic value in the DUT and
// are wholly contained in a register.
// All bits in a field have the same access policy.
//


typedef class uvm_ral_field_cbs;


//-----------------------------------------------------------------
// CLASS: uvm_ral_field
// Field abstraction base class
//
// A field represents a set of bots that behave consistently
// as a single entity.
//
// A field is contained within a single register, but may
// have different access policies depending on the adddress map
// use the access the register (thus the field).
//-----------------------------------------------------------------
class uvm_ral_field extends uvm_object;

   local string access;
   local uvm_ral_reg parent;
   local int unsigned lsb;
   local int unsigned size;
   local uvm_ral_data_t  mirrored; // What we think is in the HW
   local uvm_ral_data_t  desired;  // Mirrored after set()
   rand  uvm_ral_data_t  value;    // Mirrored after randomize()
   local uvm_ral_data_t  reset_value;
   local logic [`UVM_RAL_DATA_WIDTH-1:0] soft_reset_value;
   local bit written;
   local bit read_in_progress;
   local bit write_in_progress;
   local string fname = "";
   local int lineno = 0;
   local int cover_on;
   local bit individually_accessible = 0;
   local string attributes[string];


   constraint uvm_ral_field_valid {
      if (`UVM_RAL_DATA_WIDTH > size) {
         value < (`UVM_RAL_DATA_WIDTH'h1 << size);
      }
   }

   `uvm_object_utils(uvm_ral_field)

   //----------------------
   // Group: Initialization
   //----------------------

   //------------------------------------------------------------------------
   // FUNCTION: new
   // Create a field new instance
   //
   // This method should not be used directly.
   // The uvm_ral_field::type_id::create() method shoudl be used instead.
   //------------------------------------------------------------------------
   extern function new(string name = "uvm_ral_field");

   //
   // Function: configure
   // Instance-specific configuration
   //
   // Specify the ~parent~ register of this field, its
   // ~size~ in bits, the position of its least-significant bit
   // within the register relative to the least-significant bit
   // of the register, its ~access~ policy, ~reset~ value, ~soft reset~ value,
   // whether the field value may be randomized and
   // whether the field is the only one to occupy a byte lane in the register.
   //
   // The pre-defined access policies are:
   //
   // "RO"    - Read-only, never changes
   // "RU"    - Read-only, but may be changed by the DUT
   // "RW"    - Read-write, but not changed but the DUT
   // "RC"    - Clear-on-read, write has no effect
   // "W1C"   - Write-1-to-clear, writing zero has no effects
   // "A0"    - Write-1-to-set, writing zero has no effect
   // "A1"    - Write-0-to-clear, writing one has no effect
   // "WO"    - Write-only, reading has no effect
   // "W1"    - Write-once, subsequent writes have no effects
   // "DC"    - Don't care, RW but "check" never fails
   //
   // If the field has no soft reset value, a 'bx value must be specified.
   //
   extern function void configure(uvm_ral_reg                     parent,
                                  int unsigned                    size,
                                  int unsigned                    lsb_pos,
                                  string                          access,
                                  uvm_ral_data_t                  reset,
                                  logic [`UVM_RAL_DATA_WIDTH-1:0] soft_reset,
                                  bit                             is_rand = 0,
                                  bit                             individually_accessible = 0); 


   //---------------------
   // Group: Introspection
   //---------------------

   //
   // Function: get_name
   // Get the simple name
   //
   // Return the simple object name of this field
   //

   //
   // Function: get_full_name
   // Get the hierarchical name
   //
   // Return the hierarchal name of this field
   // The base of the hierarchical name is the root block.
   //
   extern virtual function string        get_full_name();

   //
   // FUNCTION: get_parent
   // Get the parent register
   //
   extern virtual function uvm_ral_reg get_parent ();
   extern virtual function uvm_ral_reg get_register  ();

   //
   // FUNCTION: get_lsb_pos_in_register
   // Return the position of the field
   ///
   // Returns the index of the least significant bit of the field
   // in the register that instantiates it.
   // An offset of 0 indicates a field that is aligned with the
   // least-significant bit of the register. 
   //
   extern virtual function int unsigned get_lsb_pos_in_register();

   //
   // FUNCTION: get_n_bits
   // Returns the width, in number of bits, of the field. 
   //
   extern virtual function int unsigned get_n_bits();


   //
   // FUNCTION: set_access
   // Modify the access policy of the field
   //
   // Set the access policy of the field to the specified one and
   // return the previous access policy.
   //
   extern virtual function string       set_access(string mode);

   //
   // FUNCTION: get_access
   // Get the access policy of the field
   //
   // Returns the current access policy of the field
   // when written and read through the specified address ~map~.
   // If the register containing the field is mapped in multiple
   // address map, an address map must be specified.
   // The access policy of a field from a specific
   // address map may be restricted by the register's access policy in that
   // address map.
   // For example, a RW field may only be writable through one of
   // the address maps and read-only through all of the other maps.
   //
   extern virtual function string       get_access(uvm_ral_map map = null);

   //
   // FUNCTION: get_access
   // Check if access policy is a built-in one.
   //
   // Returns TRUE if the current access policy of the field,
   // when written and read through the specified address ~map~,
   // is a built-in access policy.
   //
   extern virtual function bit          is_known_access(uvm_ral_map map = null);


   //--------------
   // Group: Access
   //--------------


   //
   // FUNCTION: set
   // Set the desired value for this field
   //
   // Sets the desired value of the field to the specified value.
   // Does not actually set the value of the field in the design,
   // only the desired value in the abstrcation class.
   // Use the <uvm_ral_reg::update()> method to update the actual register
   // with the desired value or the <uvm_ral_field::write()> method
   // to actually write the field and update its mirrored value.
   //
   // The final desired value in the mirror is a function of the field access
   // mode and the set value, just like a normal physical write operation
   // to the corresponding bits in the hardware.
   // As such, this method (when eventually followed by a call to
   // <uvm_ral_reg::update()>)
   // is a zero-time functional replacement for the <uvm_ral_field::write()>
   // method.
   // For example, the mirrored value of a read-only field is not modified
   // by this method and the mirrored value of a write-once field can only
   // be set if the field has not yet been
   // written to using a physical (for example, front-door) write operation.
   //
   // Use the <uvm_ral_field::predict()> to modify the mirrored value of
   // the field.
   //
   extern virtual function void set(uvm_ral_data_t  value,
                                    string          fname = "",
                                    int             lineno = 0);

   //
   // FUNCTION: get
   // Return the desired value of the field
   //
   // Does not actually read the value
   // of the field in the design, only the desired value
   // in the abstraction class. Unless set to a different value
   // using the <uvm_ral_field::set()>, the desired value
   // and the mirrored value are identical.
   //
   // Use the <uvm_ral_field::read()> or <uvm_ral_field::peek()>
   // method to get the actual field value. 
   //
   // If the field is write-only, the desired/mirrored
   // value is the value last written and assumed
   // to reside in the bits implementing it.
   // Although a physical read operation would something different,
   // the returned value is the actual content.
   //
   extern virtual function uvm_ral_data_t get(string fname = "",
                                              int    lineno = 0);


   //
   // FUNCTION: reset
   // Reset the desired/mirrored value for this field.
   //
   // Sets the desired and mirror value of the field
   // to the reset value specified by ~kind~ as a <uvm_ral::reset_e> value.
   // Does not actually reset the value of the field in the design,
   // only the value mirrored in the field abstraction class.
   //
   // Write-once fields can be modified after
   // a hard reset operation.
   //
   extern virtual function void reset(uvm_ral::reset_e kind = uvm_ral::HARD);

   //
   // FUNCTION: get_reset
   // Get a specified reset value for this field
   //
   // Return the reset value for this field
   // specified by ~kind~ as a <uvm_ral::reset_e> value.
   //
   extern virtual function uvm_ral_data_logic_t 
                       get_reset(uvm_ral::reset_e kind = uvm_ral::HARD);

   //
   // FUNCTION: get_reset
   // Modify the reset value for this field
   //
   // Modify the reset value for this field corresponding
   // to the cause specified by ~kind~ as a <uvm_ral::reset_e> value.
   //
   extern virtual function uvm_ral_data_logic_t
                       set_reset(uvm_ral_data_logic_t value,
                                 uvm_ral::reset_e     kind = uvm_ral::HARD);


   //
   // FUNCTION: needs_update
   // Check if the abstract model contains different desired and mirrored values.
   //
   // If a desired field value has been modified in the abstraction class
   // without actually updating the field in the DUT,
   // the state of the DUT (more specifically what the abstraction class
   // ~thinks~ the state of the DUT is) is outdated.
   // This method returns TRUE
   // if the state of the field in the DUT needs to be updated 
   // to match the desired value.
   // The mirror values or actual content of DUT field are not modified.
   // Use the <uvm_ral_reg::update()> to actually update the DUT field.
   //
   extern virtual function bit needs_update();


   //
   // TASK: write
   // Write the specified value in this field
   //
   // Write ~value~ in the DUT field that corresponds to this
   // abstraction class instance using the specified access
   // ~path~. 
   // If the register containing this field is mapped in more
   //  than one address map, 
   // an address ~map~ must be
   // specified if a physical access is used (front-door access).
   // If a back-door access path is used, the effect of writing
   // the field through a physical access is mimicked. For
   // example, read-only bits in the field will not be written.
   //
   // The mirrored value will be updated using the <uvm_ral_field:predict()>
   // method.
   //
   // If a front-door access is used, and
   // if the field is the only field in a byte lane and
   // if the physical interface corresponding to the address map used
   // to access the field support byte-enabling,
   // then only the field is written.
   // Otherwise, the entire register containing the field is written,
   // and the mirrored values of the other fields in the same register
   // are used in a best-effort not to modify their value.
   //
   // If a backdoor access is used, a peek-modify-poke process is used.
   // in a best-effort not to modify the value of the other fields in the
   // register.
   //
   extern virtual task write (output uvm_ral::status_e  status,
                              input  uvm_ral_data_t     value,
                              input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                              input  uvm_ral_map        map = null,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);


   //
   // TASK: read
   // Read the current value from this field
   //
   // Read and return ~value~ from the DUT field that corresponds to this
   // abstraction class instance using the specified access
   // ~path~. 
   // If the register containing this field is mapped in more
   // than one address map, an address ~map~ must be
   // specified if a physical access is used (front-door access).
   // If a back-door access path is used, the effect of reading
   // the field through a physical access is mimicked. For
   // example, clear-on-read bits in the filed will be set to zero.
   //
   // The mirrored value will be updated using the <uvm_ral_reg:predict()>
   // method.
   //
   // If a front-door access is used, and
   // if the field is the only field in a byte lane and
   // if the physical interface corresponding to the address map used
   // to access the field support byte-enabling,
   // then only the field is read.
   // Otherwise, the entire register containing the field is read,
   // and the mirrored values of the other fields in the same register
   // are updated.
   //
   // If a backdoor access is used, the entire containing register is peeked
   // and the mirrored value of the other fields in the register is updated.
   //
   extern virtual task read  (output uvm_ral::status_e  status,
                              output uvm_ral_data_t     value,
                              input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                              input  uvm_ral_map        map = null,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);
               

   //
   // TASK: poke
   // Deposit the specified value in this field
   //
   // Deposit the value in the DUT field corresponding to this
   // abstraction class instance, as-is, using a back-door access.
   // A peek-modify-poke process is used
   // in a best-effort not to modify the value of the other fields in the
   // register.
   //
   // The mirrored value will be updated using the <uvm_ral_reg:predict()>
   // method.
   //
   extern virtual task poke  (output uvm_ral::status_e  status,
                              input  uvm_ral_data_t     value,
                              input  string             kind = "",
                              input  uvm_sequence_base  parent = null,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);


   //
   // TASK: peek
   // Read the current value from this field
   //
   // Sample the value in the DUT field corresponding to this
   // absraction class instance using a back-door access.
   // The field value is sampled, not modified.
   //
   // Uses the HDL path for the design abstraction specified by ~kind~.
   //
   // The entire containing register is peeked
   // and the mirrored value of the other fields in the register
   // are updated using the <uvm_ral_reg:predict()> method.
   //
   //
   extern virtual task peek  (output uvm_ral::status_e  status,
                              output uvm_ral_data_t     value,
                              input  string             kind = "",
                              input  uvm_sequence_base  parent = null,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);
               

   //
   // TASK: mirror
   // Read the field and update/check its mirror value
   //
   // Read the field and optionally compared the readback value
   // with the current mirrored value if ~check~ is <uvm_ral::VERB>.
   // The mirrored value will be updated using the <uvm_ral_field:predict()>
   // method based on the readback value.
   //
   // The mirroring can be performed using the physical interfaces (frontdoor)
   // or <uvm_ral_field::peek()> (backdoor).
   //
   // If ~check~ is specified as uvm_ral::VERB,
   // an error message is issued if the current mirrored value
   // does not match the readback value, unless the field has the "DC"
   // (don't care) policy.
   //
   // If the containing register is mapped in multiple address maps and physical
   // access is used (front-door access), an address ~map~ must be specified.
   // For write-only fields, their content is mirrored and optionally
   // checked only if a uvm_ral::BACKDOOR
   // access path is used to read the field. 
   //
   extern virtual task mirror(output uvm_ral::status_e status,
                              input  uvm_ral::check_e  check = uvm_ral::NO_CHECK,
                              input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                              input  uvm_ral_map       map = null,
                              input  uvm_sequence_base parent = null,
                              input  int               prior = -1,
                              input  uvm_object        extension = null,
                              input  string            fname = "",
                              input  int               lineno = 0);


   //-----------------------------------------------------------------
   // FUNCTION: predict
   // Update the mirrored value for this field
   //
   // Predict the mirror value of the field
   // based on the specified observed ~value~ on a specified adress ~map~,
   // or based on a calculated value.
   //
   // If ~kind~ is specified as <uvm_ral::PREDICT_READ>, the value
   // was observed in a read transaction on the specified address ~map~ or
   // backdoor (if ~path~ is <uvm_ral::BACKDOOR>).
   // If ~kind~ is specified as <uvm_ral::PREDICT_WRITE>, the value
   // was observed in a write transaction on the specified address ~map~ or
   // backdoor (if ~path~ is <uvm_ral::BACKDOOR>).
   // If ~kind~ is specified as <uvm_ral::PREDICT_DIRECT>, the value
   // was computed and is updated as-is, without reguard to any access policy.
   // For example, the mirrored value of a read-only field is modified
   // by this method if ~kind~ is specified as <uvm_ral::PREDICT_DIRECT>.
   //
   // This method does not allow any explicit update of the mirror,
   // when the register containing this field is busy executing
   // a transaction because the results are unpredictable and
   // indicative of a race condition in the testbench.
   //
   // Returns TRUE if the prediction was succesful.
   extern virtual function bit predict (uvm_ral_data_t  value,
                                        uvm_ral::predict_e kind = uvm_ral::PREDICT_DIRECT,
                                        uvm_ral::path_e path = uvm_ral::BFM,
                                        uvm_ral_map     map = null,
                                        string          fname = "",
                                        int             lineno = 0);

   /*local*/ extern virtual function uvm_ral_data_t XpredictX (uvm_ral_data_t  cur_val,
        	                                               uvm_ral_data_t  wr_val,
                                                               uvm_ral_map  map);

   /*local*/ extern virtual function void Xpredict_readX (uvm_ral_data_t  value,
                                                          uvm_ral::path_e path,
                                                          uvm_ral_map  map);

   /*local*/ extern virtual function void Xpredict_writeX(uvm_ral_data_t  value,
                                                          uvm_ral::path_e path,
                                                          uvm_ral_map  map);

   /*local*/ extern virtual function uvm_ral_data_t XupdX();
  

   extern function void pre_randomize();
   extern function void post_randomize();


   //------------------
   // Group: Attributes
   //------------------

   //
   // FUNCTION: set_attribute
   // Set an attribute.
   //
   // Set the specified attribute to the specified value for this field.
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
   // Get the value of the specified attribute for this field.
   // If the attribute does not exists, "" is returned.
   // If ~inherited~ is specifed as TRUE, the value of the attribute
   // is inherited from its parent register
   // if it is not specified for this field.
   // If ~inherited~ is specified as FALSE, the value "" is returned
   // if it does not exists in the this field.
   // 
   // Attribute names are case sensitive.
   // 
   extern virtual function string get_attribute(string name,
                                                bit inherited = 1);

   //
   // FUNCTION: get_attributes
   // Get all attribute values.
   //
   // Get the name of all attribute for this field.
   // If ~inherited~ is specifed as TRUE, the value for all attributes
   // inherited from the parent register are included.
   // 
   extern virtual function void get_attributes(ref string names[string],
                                               input bit inherited = 1);

   //-----------------
   // Group: Callbacks
   //-----------------

   `uvm_register_cb(uvm_ral_field, uvm_ral_field_cbs)

   //--------------------------------------------------------------------------
   // TASK: pre_write
   // Called before field write.
   //
   // If the specified data value, access ~path~ or address ~map~ are modified,
   // the updated data value, access path or address map will be used
   // to perform the register operation.
   //
   // The field callback methods are invoked after the callback methods
   // on the containing register.
   // The registered callback methods are invoked after the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task pre_write  (ref uvm_ral_data_t  wdat,
                            ref uvm_ral::path_e path,
                            ref uvm_ral_map     map);
   endtask

   //--------------------------------------------------------------------------
   // TASK: post_write
   // Called after field write
   //
   // If the specified ~status~ is modified,
   // the updated status will be
   // returned by the register operation.
   //
   // The field callback methods are invoked after the callback methods
   // on the containing register.
   // The registered callback methods are invoked before the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task post_write (uvm_ral_data_t        wdat,
                            uvm_ral::path_e       path,
                            uvm_ral_map           map,
                            ref uvm_ral::status_e status);
   endtask

   //--------------------------------------------------------------------------
   // TASK: pre_read
   // Called before field read.
   //
   // If the specified access ~path~ or address ~map~ are modified,
   // the updated access path or address map will be used to perform
   // the register operation.
   //
   // The field callback methods are invoked after the callback methods
   // on the containing register.
   // The registered callback methods are invoked after the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task pre_read   (ref uvm_ral::path_e path,
                            ref uvm_ral_map     map);
   endtask

   //--------------------------------------------------------------------------
   // TASK: post_read
   // Called after field read.
   //
   // If the specified readback data or~status~ is modified,
   // the updated readback data or status will be
   // returned by the register operation.
   //
   // The field callback methods are invoked after the callback methods
   // on the containing register.
   // The registered callback methods are invoked before the invocation
   // of this method.
   //--------------------------------------------------------------------------
   virtual task post_read  (ref uvm_ral_data_t    rdat,
                            uvm_ral::path_e       path,
                            uvm_ral_map           map,
                            ref uvm_ral::status_e status);
   endtask


   extern virtual function void do_print (uvm_printer printer);
   extern virtual function string convert2string;
   extern virtual function uvm_object clone();
   extern virtual function void do_copy   (uvm_object rhs);
   extern virtual function bit  do_compare (uvm_object  rhs,
                                            uvm_comparer comparer);
   extern virtual function void do_pack (uvm_packer packer);
   extern virtual function void do_unpack (uvm_packer packer);

endclass: uvm_ral_field


//
// CLASS: uvm_ral_field_cbs
// Pre/post read/write callback facade class
//
class uvm_ral_field_cbs extends uvm_callback;
   string fname;
   int    lineno;

   function new(string name = "uvm_ral_field_cbs");
      super.new(name);
   endfunction
   

   //
   // Task: pre_write
   // Callback called before a write operation.
   //
   // The registered callback methods are invoked after the invocation
   // of the register pre-write callbacks and
   // of the <uvm_ral_field::pre_write()> method.
   //
   // The written value ~wdat, access ~path~ and address ~map~,
   // if modified, modifies the actual value, access path or address map
   // used in the register operation.
   //
   virtual task pre_write (uvm_ral_field       field,
                           ref uvm_ral_data_t  wdat,
                           ref uvm_ral::path_e path,
                           ref uvm_ral_map     map);
   endtask


   //
   // TASK: post_write
   // Called after a write operation
   //
   // The registered callback methods are invoked after the invocation
   // of the register post-write callbacks and
   // before the invocation of the <uvm_ral_field::post_write()> method.
   //
   // The ~status~ of the operation,
   // if modified, modifies the actual returned status.
   //
   virtual task post_write(uvm_ral_field       field,
                           uvm_ral_data_t      wdat,
                           uvm_ral::path_e     path,
                           uvm_ral_map         map,
                           ref uvm_ral::status_e status);
   endtask


   //
   // TASK: pre_read
   // Called before a field read.
   //
   // The registered callback methods are invoked after the invocation
   // of the register pre-read callbacks and
   // after the invocation of the <uvm_ral_field::pre_read()> method.
   //
   // The access ~path~ and address ~map~,
   // if modified, modifies the actual access path or address map
   // used in the register operation.
   //
   virtual task pre_read  (uvm_ral_field       field,
                           ref uvm_ral::path_e path,
                           ref uvm_ral_map     map);
   endtask


   //
   // TASK: post_read
   // Called after a field read.
   //
   // The registered callback methods are invoked after the invocation
   // of the register post-read callbacks and
   // before the invocation of the <uvm_ral_field::post_read()> method.
   //
   // The readback value ~rdat and the ~status~ of the operation,
   // if modified, modifies the actual returned readback value and status.
   //
   virtual task post_read (uvm_ral_field       field,
                           ref uvm_ral_data_t  rdat,
                           uvm_ral::path_e     path,
                           uvm_ral_map         map,
                           ref uvm_ral::status_e status);
   endtask

endclass: uvm_ral_field_cbs


//
// Type: uvm_ral_field_cb
// Convenience callback type declaration
//
// Use this declaration to register field callbacks rather than
// the more verbose parameterized class
//
typedef uvm_callbacks#(uvm_ral_field, uvm_ral_field_cbs) uvm_ral_field_cb;

//
// Type: uvm_ral_reg_cb_iter
// Convenience callback iterator type declaration
//
// Use this declaration to iterate over registered field callbacks
// rather than the more verbose parameterized class
//
typedef uvm_callback_iter#(uvm_ral_field, uvm_ral_field_cbs) uvm_ral_field_cb_iter;



//
// IMPLEMENTATION
//

// new

function uvm_ral_field::new(string name = "uvm_ral_field");
   super.new(name);
endfunction: new


// configure

function void uvm_ral_field::configure(uvm_ral_reg                     parent,
                                       int unsigned                    size,
                                       int unsigned                    lsb_pos,
                                       string                          access,
                                       uvm_ral_data_t                  reset,
                                       logic [`UVM_RAL_DATA_WIDTH-1:0] soft_reset,
                                       bit                             is_rand = 0,
                                       bit                             individually_accessible = 0); 
   this.parent = parent;
   if (size == 0) begin
      `uvm_error("RAL", $psprintf("Field \"%s\" cannot have 0 bits", this.get_full_name()));
      size = 1;
   end
   if (size > `UVM_RAL_DATA_WIDTH) begin
      `uvm_error("RAL", $psprintf("Field \"%s\" cannot have more than %0d bits",
                                  this.get_full_name(), `UVM_RAL_DATA_WIDTH))
      size = `UVM_RAL_DATA_WIDTH;
   end

   this.size                    = size;
   this.access                  = access.toupper();
   this.reset_value             = reset;
   this.soft_reset_value        = soft_reset;
   this.lsb                     = lsb_pos;
   this.individually_accessible = individually_accessible;
   this.cover_on                = uvm_ral::NO_COVERAGE;
   if (!is_rand) this.value.rand_mode(0);
   this.parent.add_field(this);

   this.written = 0;
endfunction: configure


// get_parent

function uvm_ral_reg uvm_ral_field::get_parent();
   return this.parent;
endfunction: get_parent


// get_full_name

function string uvm_ral_field::get_full_name();
   return {this.parent.get_full_name(), ".", this.get_name()};
endfunction: get_full_name


// get_register

function uvm_ral_reg uvm_ral_field::get_register();
   return this.parent;
endfunction: get_register


// get_lsb_pos_in_register

function int unsigned uvm_ral_field::get_lsb_pos_in_register();
   return this.lsb;
endfunction: get_lsb_pos_in_register


// get_n_bits

function int unsigned uvm_ral_field::get_n_bits();
   return this.size;
endfunction: get_n_bits


// is_known_access

function bit uvm_ral_field::is_known_access(uvm_ral_map map = null);
   string acc = this.get_access(map);
   case (acc)
     "RO", "RW", "RU", "RC", "W1C", "A0", "A1", "WO", "W1", "DC": return 1;
   endcase
   return 0;
endfunction


// get_access

function string uvm_ral_field::get_access(uvm_ral_map map = null);
   get_access = this.access;

   if (parent.get_n_maps() == 1 || map == uvm_ral_map::backdoor)
     return get_access;

   // Is the register restricted in this map?
   case (this.parent.get_rights(map))
     "RW":
       // No restrictions
       return get_access;

     "RO":
       case (get_access)
         "RW",
         "RO",
         "W1",
         "W1C": get_access = "RO";

         "RU",
         "A0",
         "A1": get_access = "RU";

         "WO": begin
            `uvm_error("RAL",
                       $psprintf("WO field \"%s\" restricted to RO in map \"%s\"",
                                 this.get_name(), map.get_full_name()));
         end

         // No change for the other modes (OTHER, USERx)
       endcase

     "WO":
       case (get_access)
         "RW",
         "WO": get_access = "WO";

         "RO",
         "RU",
         "W1C",
         "A0",
         "A1": begin
            `uvm_error("RAL",
                       $psprintf("%s field \"%s\" restricted to WO in map \"%s\"",
                                 get_access, this.get_name(), map.get_full_name()));
         end

         // No change for the other modes
       endcase

     default:
       `uvm_error("RAL",
                  $psprintf("Shared register \"%s\" containing field \"%s\" is not shared in map \"%s\"",
                            this.parent.get_name(), this.get_name(), map.get_full_name()))
   endcase
endfunction: get_access


// set_access

function string uvm_ral_field::set_access(string mode);
   set_access = this.access;
   this.access = mode.toupper();
endfunction: set_access


//-----------
// ATTRIBUTES
//-----------

// set_attribute

function void uvm_ral_field::set_attribute(string name,
                                         string value);
   if (name == "") begin
      `uvm_error("RAL", {"Cannot set anonymous attribute \"\" in field '",
                         get_full_name(),"'"})
      return;
   end

   if (this.attributes.exists(name)) begin
      if (value != "") begin
         `uvm_warning("RAL", {"Redefining attribute '",name,"' in field '",
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
                          name, "' in field '", get_full_name(), "'"})
      return;
   end

   this.attributes[name] = value;
endfunction: set_attribute


// get_attribute

function string uvm_ral_field::get_attribute(string name,
                                             bit inherited = 1);
   if (inherited && parent != null)
      get_attribute = parent.get_attribute(name);

   if (get_attribute == "" && this.attributes.exists(name))
      return this.attributes[name];

   return "";
endfunction: get_attribute


// get_attributes

function void uvm_ral_field::get_attributes(ref string names[string],
                                          input bit inherited = 1);
   // attributes at higher levels supercede those at lower levels
   if (inherited && parent != null)
     this.parent.get_attributes(names,1);

   foreach (attributes[nm])
     if (!names.exists(nm))
       names[nm] = attributes[nm];

endfunction


// XpredictX

function uvm_ral_data_t uvm_ral_field::XpredictX (uvm_ral_data_t cur_val,
                                                  uvm_ral_data_t wr_val,
                                                  uvm_ral_map    map);
   case (this.get_access(map))
     "RW":    return wr_val;
     "RO":    return cur_val;
     "WO":    return wr_val;
     "W1":    return (this.written) ? cur_val : wr_val;
     "RU":    return cur_val;
     "RC":    return cur_val;
     "W1C":   return cur_val & (~wr_val);
     "A0":    return cur_val | wr_val;
     "A1":    return cur_val & wr_val;
     "DC":    return wr_val;
     default: return wr_val;
   endcase

   `uvm_fatal("RAL", "uvm_ral_field::XpredictX(): Internal error");
   return 0;
endfunction: XpredictX


// Xpredict_readX

function void uvm_ral_field::Xpredict_readX (uvm_ral_data_t  value,
                                             uvm_ral::path_e path,
                                             uvm_ral_map     map);
   value &= ('b1 << this.size)-1;

   if (path == uvm_ral::BFM) begin

      string acc = this.get_access(map);

      // If the value was obtained via a front-door access
      // then a RC field will have been cleared
      if (acc == "RC")
        value = 0;

      // If the value of a WO field was obtained via a front-door access
      // it will always read back as 0 and the value of the field
      // cannot be inferred from it
      else if (acc == "WO")
        return;
   end

   this.mirrored = value;
   this.desired = value;
   this.value   = value;
endfunction: Xpredict_readX


// Xpredict_writeX 

function void uvm_ral_field::Xpredict_writeX (uvm_ral_data_t  value,
                                              uvm_ral::path_e path,
                                              uvm_ral_map     map);
   if (value >> this.size) begin
      `uvm_warning("RAL", $psprintf("Specified value (0x%h) greater than field \"%s\" size (%0d bits)",
                                       value, this.get_name(), this.size));
      value &= ('b1 << this.size)-1;
   end

   if (path == uvm_ral::BFM) begin
      this.mirrored = this.XpredictX(this.mirrored, value, map);
   end
   else this.mirrored = value;

   this.desired = this.mirrored;
   this.value   = this.mirrored;

   this.written = 1;
endfunction: Xpredict_writeX


// XupdX

function uvm_ral_data_t  uvm_ral_field::XupdX();
   // Figure out which value must be written to get the desired value
   // given what we think is the current value in the hardware
   XupdX = 0;

   case (this.access)
      "RW":    XupdX = this.desired;
      "RO":    XupdX = this.desired;
      "WO":    XupdX = this.desired;
      "W1":    XupdX = this.desired;
      "RU":    XupdX = this.desired;
      "RC":    XupdX = this.desired;
      "W1C":   XupdX = ~this.desired;
      "A0":    XupdX = this.desired;
      "A1":    XupdX = this.desired;
      default: XupdX = this.desired;
   endcase
endfunction: XupdX


// predict

function bit uvm_ral_field::predict(uvm_ral_data_t  value,
                                    uvm_ral::predict_e kind = uvm_ral::PREDICT_DIRECT,
                                    uvm_ral::path_e path = uvm_ral::BFM,
                                    uvm_ral_map     map = null,
                                    string          fname = "",
                                    int             lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   if (this.parent.Xis_busyX && kind == uvm_ral::PREDICT_DIRECT) begin
      `uvm_warning("RAL", $psprintf("Trying to predict value of field \"%s\" while register \"%s\" is being accessed",
                                       this.get_name(),
                                       this.parent.get_full_name()));
      return 0;
   end

   if (kind == uvm_ral::PREDICT_READ) begin
     Xpredict_readX(value,path,map);
     return 1;
   end

   if (kind == uvm_ral::PREDICT_WRITE) begin
     Xpredict_writeX(value,path,map);
     return 1;
   end

   // update the mirror with value as-is
   value &= ('b1 << this.size)-1;
   this.mirrored = value;
   this.desired = value;
   this.value   = value;

   return 1;
endfunction: predict


// set

function void uvm_ral_field::set(uvm_ral_data_t  value,
                                 string          fname = "",
                                 int             lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   if (value >> this.size) begin
      `uvm_warning("RAL", $psprintf("Specified value (0x%h) greater than field \"%s\" size (%0d bits)",
                                       value, this.get_name(), this.size));
      value &= ('b1 << this.size)-1;
   end

   case (this.access)
      "RW":    this.desired = value;
      "RO":    this.desired = this.desired;
      "WO":    this.desired = value;
      "W1":    this.desired = (this.written) ? this.desired : value;
      "RU":    this.desired = this.desired;
      "RC":    this.desired = this.desired;
      "W1C":   this.desired &= (~value);
      "A0":    this.desired |= value;
      "A1":    this.desired &= value;
      default: this.desired = value;
   endcase
   this.value = this.desired;
endfunction: set

 
// get

function uvm_ral_data_t  uvm_ral_field::get(string  fname = "",
                                            int     lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   get = this.desired;
endfunction: get


// reset

function void uvm_ral_field::reset(uvm_ral::reset_e kind = uvm_ral::HARD);
   case (kind)
     uvm_ral::HARD: begin
        this.mirrored = reset_value;
        this.desired  = reset_value;
        this.written  = 0;
     end
     uvm_ral::SOFT: begin
        if (soft_reset_value !== 'x) begin
           this.mirrored = soft_reset_value;
           this.desired  = soft_reset_value;
        end
     end
   endcase
   this.value = this.desired;
endfunction: reset


// get_reset

function logic [`UVM_RAL_DATA_WIDTH-1:0]
   uvm_ral_field::get_reset(uvm_ral::reset_e kind = uvm_ral::HARD);

   if (kind == uvm_ral::SOFT) return this.soft_reset_value;

   return this.reset_value;
endfunction: get_reset


// set_reset

function logic [`UVM_RAL_DATA_WIDTH-1:0]
   uvm_ral_field::set_reset(logic [`UVM_RAL_DATA_WIDTH-1:0] value,
                            uvm_ral::reset_e kind = uvm_ral::HARD);
   case (kind)
     uvm_ral::HARD: begin
        set_reset = this.reset_value;
        this.reset_value = value;
     end
     uvm_ral::SOFT: begin
        set_reset = this.soft_reset_value;
        this.soft_reset_value = value;
     end
   endcase
endfunction: set_reset


// needs_update

function bit uvm_ral_field::needs_update();
   needs_update = (this.mirrored != this.desired);
endfunction: needs_update


typedef class uvm_ral_map_info;

// write

task uvm_ral_field::write(output uvm_ral::status_e  status,
                          input  uvm_ral_data_t     value,
                          input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                          input  uvm_ral_map        map = null,
                          input  uvm_sequence_base  parent = null,
                          input  int                prior = -1,
                          input  uvm_object         extension = null,
                          input  string             fname = "",
                          input  int                lineno = 0);
   uvm_ral_data_t  tmp,msk,temp_data;
   uvm_ral_map local_map, system_map;
   uvm_ral_map_info map_info;

   bit [`UVM_RAL_BYTENABLE_WIDTH-1:0] byte_en = '0;
   bit b_en[$];
   uvm_ral_field fields[$];
   int fld_pos = 0;
   bit indv_acc = 0;
   //uvm_ral_addr_t  addr[];
   int w = 0, j = 0,bus_width, n_bits,n_access,n_access_extra,n_bytes_acc,temp_be;
   
   uvm_ral_block  blk = this.parent.get_block();
			
   if (path == uvm_ral::DEFAULT)
     path = blk.get_default_path();

   local_map = this.parent.get_local_map(map,"read()");

   if (local_map != null)
      map_info = local_map.get_reg_map_info(this.parent);

   if (path != uvm_ral::BACKDOOR && !this.parent.maps.exists(local_map) ) begin
     `uvm_error(get_type_name(), $psprintf("No transactor available to physically access map \"%s\".",
        map.get_full_name()));
     return;
   end
                        
   this.fname = fname;
   this.lineno = lineno;
   this.write_in_progress = 1'b1;

   this.parent.XatomicX(1);

   if (value >> this.size) begin
      `uvm_warning("RAL", {"uvm_ral_field::write(): Value greater than field '",
                          get_full_name(),"'"})
      value &= value & ((1<<this.size)-1);
   end
			temp_data = value;
   tmp = 0;
   // What values are written for the other fields???
   this.parent.get_fields(fields);
   foreach (fields[i]) begin
      if (fields[i] == this) begin
         tmp |= value << this.lsb;
	 fld_pos = i;
         continue;
      end

      // It depends on what kind of bits they are made of...
      case (fields[i].get_access(local_map))
        // These...
        "RC",
        "W1C",
        "A0":
          // Use all 0's
          tmp |= 0;

        // These...
        "A1":
          // Use all 1's
          tmp |= ((1<<fields[i].get_n_bits())-1) << fields[i].get_lsb_pos_in_register();

        default:
          // Use their mirrored value
          tmp |= fields[i].get() << fields[i].get_lsb_pos_in_register();

      endcase
   end

`ifdef UVM_RAL_NO_INDIVIDUAL_FIELD_ACCESS

   this.parent.XwriteX(status, tmp, path, map, parent, prior);

`else	

   system_map = local_map.get_root_map();
   bus_width = system_map.get_n_bytes();  //// get the width of the physical interface data bus in bytes
			
   //
   // Check if this field is the sole occupant of the
   // complete bus_data(width)
   //
   if (fields.size() == 1) begin
      indv_acc = 1;
   end
   else begin
      if (fld_pos == 0) begin
         if (fields[fld_pos+1].lsb%(bus_width*8) == 0)  indv_acc = 1;
         else if ((fields[fld_pos+1].lsb - fields[fld_pos].size) >= (fields[fld_pos+1].lsb%(bus_width*8))) indv_acc = 1;
         else indv_acc = 0;
      end 
      else if(fld_pos == (fields.size()-1)) begin
         if (fields[fld_pos].lsb%(bus_width*8) == 0)  indv_acc = 1;
         else if ((fields[fld_pos].lsb - (fields[fld_pos-1].lsb+fields[fld_pos-1].size)) >= (fields[fld_pos].lsb%(bus_width*8))) indv_acc = 1;
         else indv_acc = 0;
      end 
      else begin
         if (fields[fld_pos].lsb%(bus_width*8) == 0) begin
            if (fields[fld_pos+1].lsb%(bus_width*8) == 0) indv_acc = 1;
            else if ((fields[fld_pos+1].lsb - (fields[fld_pos].lsb+fields[fld_pos].size)) >= (fields[fld_pos+1].lsb%(bus_width*8))) indv_acc = 1;
            else indv_acc = 0;
         end 
         else begin
            if(((fields[fld_pos+1].lsb - (fields[fld_pos].lsb+fields[fld_pos].size))>= (fields[fld_pos+1].lsb%(bus_width*8)))  &&
               ((fields[fld_pos].lsb - (fields[fld_pos-1].lsb+fields[fld_pos-1].size))>=(fields[fld_pos].lsb%(bus_width*8))) ) indv_acc = 1;
            else indv_acc = 0;				
         end
      end
   end
			
   // BUILT-IN FRONTDOOR
   if (path == uvm_ral::BFM) begin
      if(this.individually_accessible) begin
         uvm_ral_adapter    adapter;
         uvm_sequencer_base sequencer;

         if (local_map == null)
           return;

         system_map = local_map.get_root_map();

         adapter = system_map.get_adapter();
         sequencer = system_map.get_sequencer();

   	 if(adapter.supports_byte_enable || (indv_acc)) begin

	    uvm_ral_field_cb_iter cbs = new(this);
	    value = temp_data;

            // PRE-WRITE CBS
            this.pre_write(value, path, map);
            for (uvm_ral_field_cbs cb = cbs.first(); cb != null;
                 cb = cbs.next()) begin
               cb.fname = this.fname;
               cb.lineno = this.lineno;
               cb.pre_write(this, value, path, map);
            end
	    this.parent.Xis_busyX = 1;
            
	    n_access_extra = this.lsb%(bus_width*8);		
	    n_access = n_access_extra + this.size;
	    value = (value) << (n_access_extra);
	    /* calculate byte_enables */
	    temp_be = n_access_extra;
            while(temp_be >= 8) begin
	       b_en.push_back(0);
               temp_be = temp_be - 8;
	    end			
	    temp_be = temp_be + this.size;
     	    while(temp_be > 0) begin
	       b_en.push_back(1);
               temp_be = temp_be - 8;
	    end
	    /* calculate byte_enables */
            
	    if(n_access%8 != 0) n_access = n_access + (8 - (n_access%8)); 
            n_bytes_acc = n_access/8;
            
            w = system_map.get_n_bytes();
	    //w = local_map.get_physical_addresses(map_info.offset + (this.lsb/(bus_width*8)),
            //                                     0,
            //                                     n_bytes_acc,
            //                                     addr);
            j = 0;
	    n_bits = this.size;
            foreach(map_info.addr[i]) begin
               uvm_sequence_item bus_req = new("bus_wr");
               uvm_rw_access rw_access;
	       uvm_ral_data_t  data;
	       bit tt;
	       data = value >> (j*8);
	       
	       for(int z=0;z<bus_width;z++) begin
		  tt = b_en.pop_front();	
		  byte_en[z] = tt;
	       end	
               

               data = value >> (j*8);

               status = uvm_ral::ERROR;
                           
               `uvm_info(get_type_name(), $psprintf("Writing 'h%0h at 'h%0h via map \"%s\"...",
                                                    data, map_info.addr[i], map.get_full_name()), UVM_HIGH);
                        
               rw_access = uvm_rw_access::type_id::create("rw_access",,{sequencer.get_full_name(),".",parent.get_full_name()});
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
                                                    data, map_info.addr[i], map.get_full_name(), status.name()), UVM_HIGH);

               if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) return;
               j += w;
               n_bits -= w * 8;
            end
            /*if (this.cover_on) begin
             this.sample(value, 0, di);
             this.parent.XsampleX(this.offset_in_block[di], di);
         end*/
            
            this.parent.Xis_busyX = 0;
	    value = (value >> (n_access_extra)) & ((1<<this.size))-1;

            if (system_map.get_auto_predict() == uvm_ral::PREDICT_DIRECT)
	      this.Xpredict_writeX(value, path, map);
            
            // POST-WRITE CBS
            this.post_write(value, path, map, status);
            for (uvm_ral_field_cbs cb = cbs.first(); cb != null;
                 cb = cbs.next()) begin
               cb.fname = this.fname;
               cb.lineno = this.lineno;
               cb.post_write(this, value, path, map, status);
            end
   	 end else begin
   	    if(!adapter.supports_byte_enable) begin
               `uvm_warning("RAL", $psprintf("Protocol does not support byte enabling to write field \"%s\". Writing complete register instead.", this.get_name()));
   	    end		
   	    if(!indv_acc) begin
               `uvm_warning("RAL", $psprintf("Field \"%s\" is not individually accessible. Writing complete register instead.", this.get_name()));
   	    end		
            this.parent.XwriteX(status, tmp, path, map, parent, prior);
   	 end	
      end else begin
         `uvm_warning("RAL", $psprintf("Individual field access not available for field \"%s\". Writing complete register instead.", this.get_name()));
         this.parent.XwriteX(status, tmp, path, map, parent, prior);
      end	
   end

   // Individual field access not available for BACKDOOR access		
   if(path == uvm_ral::BACKDOOR) begin
      `uvm_warning("RAL", $psprintf("Individual field access not available with BACKDOOR access for field \"%s\". Writing complete register instead.", this.get_name()));
      this.parent.XwriteX(status, tmp, path, map, parent, prior);
   end
`endif
   this.parent.XatomicX(0);
   this.write_in_progress = 1'b0;
endtask: write


// read

task uvm_ral_field::read(output uvm_ral::status_e  status,
                         output uvm_ral_data_t     value,
                         input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                         input  uvm_ral_map        map = null,
                         input  uvm_sequence_base  parent = null,
                         input  int                prior = -1,
                         input  uvm_object         extension = null,
                         input  string             fname = "",
                         input  int                lineno = 0);
   uvm_ral_data_t  reg_value;
   uvm_ral_map local_map, system_map;
   uvm_ral_map_info map_info;
   bit [`UVM_RAL_BYTENABLE_WIDTH-1:0] byte_en = '0;
   bit b_en[$];
   //uvm_ral_addr_t  addr[];
   int w = 0, j = 0,bus_width, n_bits,n_access,n_access_extra,n_bytes_acc,temp_be;
   uvm_ral_field fields[$];
   int fld_pos = 0;
   int rh_shift = 0;
   bit indv_acc = 0;
   
   uvm_ral_block  blk = this.parent.get_block();
			
   this.fname = fname;
   this.lineno = lineno;
   this.read_in_progress = 1'b1;

   if (path == uvm_ral::DEFAULT) path = blk.get_default_path();

   local_map = this.parent.get_local_map(map,"read()");

   if (local_map != null)
      map_info = local_map.get_reg_map_info(this.parent);

   if (path != uvm_ral::BACKDOOR && !this.parent.maps.exists(local_map)) begin
     `uvm_error(get_type_name(), $psprintf("No transactor available to physically access map \"%s\".",
        map.get_full_name()));
     return;
   end
                        

`ifdef UVM_RAL_NO_INDIVIDUAL_FIELD_ACCESS
   this.parent.read(status, reg_value, path, map, parent, prior, extension, fname, lineno);
			value = (reg_value >> this.lsb) & ((1<<this.size))-1;
`else
   system_map = local_map.get_root_map();
   bus_width = system_map.get_n_bytes();  //// get the width of the physical interface data bus in bytes
   
   /* START to check if this field is the sole occupant of the complete bus_data(width) */
   this.parent.get_fields(fields);
   foreach (fields[i]) begin
      if (fields[i] == this) begin
	 fld_pos = i;
      end
			end			
   if(fields.size() == 1)	begin
      indv_acc = 1;
   end else begin
      if(fld_pos == 0) begin
         if (fields[fld_pos+1].lsb%(bus_width*8) == 0)  indv_acc = 1;
         else if ((fields[fld_pos+1].lsb - fields[fld_pos].size) >= (fields[fld_pos+1].lsb%(bus_width*8))) indv_acc = 1;
         else indv_acc = 0;
      end 
      else if(fld_pos == (fields.size()-1)) begin
         if (fields[fld_pos].lsb%(bus_width*8) == 0)  indv_acc = 1;
         else if ((fields[fld_pos].lsb - (fields[fld_pos-1].lsb+fields[fld_pos-1].size)) >= (fields[fld_pos].lsb%(bus_width*8))) indv_acc = 1;
         else indv_acc = 0;
      end 
      else begin
         if (fields[fld_pos].lsb%(bus_width*8) == 0) begin
            if (fields[fld_pos+1].lsb%(bus_width*8) == 0) indv_acc = 1;
            else if ((fields[fld_pos+1].lsb - (fields[fld_pos].lsb+fields[fld_pos].size)) >= (fields[fld_pos+1].lsb%(bus_width*8))) indv_acc = 1;
            else indv_acc = 0;
         end 
         else begin
            if(((fields[fld_pos+1].lsb - (fields[fld_pos].lsb+fields[fld_pos].size))>= (fields[fld_pos+1].lsb%(bus_width*8)))  &&
               ((fields[fld_pos].lsb - (fields[fld_pos-1].lsb+fields[fld_pos-1].size))>=(fields[fld_pos].lsb%(bus_width*8))) ) indv_acc = 1;
            else indv_acc = 0;				
         end
      end
   end
   /* END to check if this field is the sole occupant of the complete bus_data(width) */

   if (path == uvm_ral::BFM) begin

      if (this.individually_accessible) begin

         uvm_ral_adapter    adapter;
         uvm_sequencer_base sequencer;

         if (local_map == null)
           return;

         system_map = local_map.get_root_map();

         adapter = system_map.get_adapter();
         sequencer = system_map.get_sequencer();

   	 if(adapter.supports_byte_enable || (indv_acc)) begin
            uvm_ral_field_cb_iter cbs = new(this);
            this.parent.XatomicX(1);
            this.parent.Xis_busyX = 1;
            this.pre_read(path, map);
            for (uvm_ral_field_cbs cb = cbs.first(); cb != null;
                 cb = cbs.next()) begin
               cb.fname = this.fname;
               cb.lineno = this.lineno;
               cb.pre_read(this, path, map);
            end
	    
	    n_access_extra = this.lsb%(bus_width*8);		
	    n_access = n_access_extra + this.size;
	    
	    /* calculate byte_enables */
	    temp_be = n_access_extra;
            while(temp_be >= 8) begin
	       b_en.push_back(0);
               temp_be = temp_be - 8;
	    end			
	    temp_be = temp_be + this.size;
     	    while(temp_be > 0) begin
	       b_en.push_back(1);
               temp_be = temp_be - 8;
	    end
	    /* calculate byte_enables */
	    
            if(n_access%8 != 0) n_access = n_access + (8 - (n_access%8)); 
            n_bytes_acc = n_access/8;

            w = system_map.get_n_bytes();
   	    //w = local_map.get_physical_addresses(map_info.offset + (this.lsb/(bus_width*8)),
            //                                     0,
            //                                     n_bytes_acc,
            //                                     addr);
            n_bits = this.size;

            foreach(map_info.addr[i]) begin
               uvm_sequence_item bus_req = new("bus_rd");
               uvm_rw_access rw_access;
	       uvm_ral_data_t  data;	
	       bit tt;
	       
 	       for(int z=0;z<bus_width;z++) begin
	  	  tt = b_en.pop_front();	
		  byte_en[z] = tt;
	       end	

               `uvm_info(get_type_name(), $psprintf("Reading 'h%0h at 'h%0h via map \"%s\"...",
                                                    data, map_info.addr[i], map.get_full_name()), UVM_HIGH);
                        
                rw_access = uvm_rw_access::type_id::create("rw_access",,{sequencer.get_full_name(),".",parent.get_full_name()});
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

                `uvm_info(get_type_name(), $psprintf("Read 'h%0h at 'h%0h via map \"%s\": %s...",
                                                    data, map_info.addr[i], map.get_full_name(), status.name()), UVM_HIGH);


               if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) return;
   	       reg_value |= (data & ((1 << (w*8)) - 1)) << (j*8);
               j += w;
               n_bits -= w * 8;
            end
            this.parent.Xis_busyX = 0;
	    /*if (this.cover_on) begin
             parent.sample(value, 1, map);
             parent.parent.XsampleX(parent.offset_in_block[map], map);
         end*/
	    value = (reg_value >> (n_access_extra)) & ((1<<this.size))-1;

            if (system_map.get_auto_predict() == uvm_ral::PREDICT_DIRECT)
	      this.Xpredict_readX(value, path, map);

            this.post_read(value, path, map, status);
            for (uvm_ral_field_cbs cb = cbs.first(); cb != null;
                 cb = cbs.next()) begin
               cb.fname = this.fname;
               cb.lineno = this.lineno;
               cb.post_read(this, value, path, map, status);
            end

            this.parent.XatomicX(0);
	    this.fname = "";
	    this.lineno = 0;
	    
   	 end else begin
   	    if(!adapter.supports_byte_enable) begin
               `uvm_warning("RAL", $psprintf("Protocol doesnot support byte enabling ....\n Reading complete register instead."));
   	    end		
   	    if((this.size%8)!=0) begin
               `uvm_warning("RAL", $psprintf("Field \"%s\" is not byte aligned. Individual field access will not be available ...\nReading complete register instead.", this.get_name()));
   	    end		
            this.parent.read(status, reg_value, path, map, parent, prior, extension, fname, lineno);
            value = (reg_value >> this.lsb) & ((1<<this.size))-1;
   	 end	
      end else begin
         `uvm_warning("RAL", $psprintf("Individual field access not available for field \"%s\". Reading complete register instead.", this.get_name()));
         this.parent.read(status, reg_value, path, map, parent, prior, extension, fname, lineno);
         value = (reg_value >> this.lsb) & ((1<<this.size))-1;
      end	
   end
   /// Individual field access not available for BACKDOOR access		
   if(path == uvm_ral::BACKDOOR) begin
      `uvm_warning("RAL", $psprintf("Individual field access not available with BACKDOOR access for field \"%s\". Reading complete register instead.", this.get_name()));
      this.parent.read(status, reg_value, path, map, parent, prior, extension, fname, lineno);
      value = (reg_value >> this.lsb) & ((1<<this.size))-1;
   end
`endif
   this.read_in_progress = 1'b0;

endtask: read
               

// poke

task uvm_ral_field::poke(output uvm_ral::status_e status,
                         input  uvm_ral_data_t    value,
                         input  string            kind = "",
                         input  uvm_sequence_base parent = null,
                         input  uvm_object        extension = null,
                         input  string            fname = "",
                         input  int               lineno = 0);
   uvm_ral_data_t  tmp;

   this.fname = fname;
   this.lineno = lineno;

   if (value >> this.size) begin
      `uvm_warning("RAL", $psprintf("uvm_ral_field::poke(): Value greater than field \"%s\" size", this.get_name()));
      value &= value & ((1<<this.size)-1);
   end


   this.parent.XatomicX(1);
   this.parent.Xis_locked_by_fieldX = 1'b1;

   tmp = 0;
   // What is the current values of the other fields???
   this.parent.peek(status, tmp, kind, parent, extension, fname, lineno);
   if (status != uvm_ral::IS_OK && status != uvm_ral::HAS_X) begin
      `uvm_error("RAL", $psprintf("uvm_ral_field::poke(): Peeking register \"%s\" returned status %s", this.parent.get_full_name(), status.name()));
      this.parent.XatomicX(0);
      this.parent.Xis_locked_by_fieldX = 1'b0;
      return;
   end

   // Force the value for this field then poke the resulting value
   tmp &= ~(((1<<this.size)-1) << this.lsb);
   tmp |= value << this.lsb;
   this.parent.poke(status, tmp, kind, parent, extension, fname, lineno);

   this.parent.XatomicX(0);
   this.parent.Xis_locked_by_fieldX = 1'b0;
endtask: poke


// peek

task uvm_ral_field::peek(output uvm_ral::status_e status,
                         output uvm_ral_data_t    value,
                         input  string            kind = "",
                         input  uvm_sequence_base parent = null,
                         input  uvm_object        extension = null,
                         input  string            fname = "",
                         input  int               lineno = 0);
   uvm_ral_data_t  reg_value;

   this.fname = fname;
   this.lineno = lineno;

   this.parent.peek(status, reg_value, kind, parent, extension, fname, lineno);
   value = (reg_value >> lsb) & ((1<<size))-1;

endtask: peek
               

// mirror

task uvm_ral_field::mirror(output uvm_ral::status_e status,
                           input  uvm_ral::check_e  check = uvm_ral::NO_CHECK,
                           input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                           input  uvm_ral_map       map = null,
                           input  uvm_sequence_base parent = null,
                           input  int               prior = -1,
                           input  uvm_object        extension = null,
                           input  string            fname = "",
                           input  int               lineno = 0);
   this.fname = fname;
   this.lineno = lineno;
   this.parent.mirror(status, check, path, map, parent, prior, extension,
                      fname, lineno);
endtask: mirror


// pre_randomize

function void uvm_ral_field::pre_randomize();
   // Update the only publicly known property with the current
   // desired value so it can be used as a state variable should
   // the rand_mode of the field be turned off.
   this.value = this.desired;
endfunction: pre_randomize


// post_randomize

function void uvm_ral_field::post_randomize();
   this.desired = this.value;
endfunction: post_randomize


// do_print

function void uvm_ral_field::do_print (uvm_printer printer);
  super.do_print(printer);
  printer.print_generic("initiator", parent.get_type_name(), -1, convert2string());
endfunction


// convert2string

function string uvm_ral_field::convert2string();
   string fmt;
   string res_str = "";
   string t_str = "";
   bit with_debug_info = 0;
   string prefix = "";

   $sformat(fmt, "%0d'h%%%0dh", this.get_n_bits(),
            (this.get_n_bits()-1)/4 + 1);
   $sformat(convert2string, {"%s%s[%0d-%0d] = ",fmt,"%s"}, prefix,
            this.get_name(),
            this.get_lsb_pos_in_register() + this.get_n_bits() - 1,
            this.get_lsb_pos_in_register(), this.desired,
            (this.desired != this.mirrored) ? $psprintf({" (Mirror: ",fmt,")"}, this.mirrored) : "");

   if (read_in_progress == 1'b1) begin
      if (fname != "" && lineno != 0)
         $sformat(res_str, " from %s:%0d",fname, lineno);
      convert2string = {convert2string, "\n", "currently being read", res_str}; 
   end
   if (write_in_progress == 1'b1) begin
      if (fname != "" && lineno != 0)
         $sformat(res_str, " from %s:%0d",fname, lineno);
      convert2string = {convert2string, "\n", res_str, "currently being written"}; 
   end
   if (this.attributes.num() > 0) begin
      string name;
      void'(this.attributes.first(name));
      convert2string = {convert2string, "\n", prefix, "Attributes:"};
      do begin
         $sformat(convert2string, " %s=\"%s\"", name, this.attributes[name]);
      end while (this.attributes.next(name));
   end
endfunction: convert2string


// clone

function uvm_object uvm_ral_field::clone();
  `uvm_fatal("RAL","RAL field cannot be cloned")
  return null;
endfunction

// do_copy

function void uvm_ral_field::do_copy(uvm_object rhs);
  `uvm_warning("RAL","RAL field copy not yet implemented")
  // just a this.set(rhs.get()) ?
endfunction


// do_compare

function bit uvm_ral_field::do_compare (uvm_object  rhs,
                                        uvm_comparer comparer);
  `uvm_warning("RAL","RAL field compare not yet implemented")
  // just a return (this.get() == rhs.get()) ?
  return 0;
endfunction


// do_pack

function void uvm_ral_field::do_pack (uvm_packer packer);
  `uvm_warning("RAL","RAL field cannot be packed")
endfunction


// do_unpack

function void uvm_ral_field::do_unpack (uvm_packer packer);
  `uvm_warning("RAL","RAL field cannot be unpacked")
endfunction

