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


typedef class uvm_ral_field;


//------------------------------------------------------------------------------
// CLASS: uvm_ral_field_cbs
// Field descriptors. 
//------------------------------------------------------------------------------
class uvm_ral_field_cbs extends uvm_callback;
   string fname;
   int    lineno;

   function new(string name = "uvm_ral_field_cbs");
      super.new(name);
   endfunction
   

   //------------------------------------------------------------------------------
   // TASK: pre_write
   // This callback method is invoked before a value is written to a field in the DUT. The written
   // value, if modified, modifies the actual value that will be written. The path and domain
   // used to write to the field can also be modified. This callback method is only invoked
   // when the "uvm_ral_field::write()" or the "uvm_ral_reg::write()" method is used
   // to write to the field inside the DUT. This callback method is not invoked when only the
   // mirrored value is written to using the "uvm_ral_field::set()" method. Because writing
   // a field causes the register to be written, and therefore all of the other fields it contains
   // to also be written, all registered "uvm_ral_field_cbs::pre_write()" 
   //------------------------------------------------------------------------------
   virtual task pre_write (uvm_ral_field       field,
                           ref uvm_ral_data_t  wdat,
                           ref uvm_ral::path_e path,
                           ref uvm_ral_map     map);
   endtask


   //------------------------------------------------------------------------------
   // TASK: post_write
   // This callback method is invoked after a value is written to a field in the DUT. The wdat
   // value is the final mirrored value in the register as reported by the "uvm_ral_field::get()"
   // method. This callback method is only invoked when the "uvm_ral_field::write()" or
   // the "uvm_ral_reg::write()" method is used to write to the field inside the DUT. This
   // callback method is not invoked when only the mirrored value is written to using the "uvm_ral_field::set()"
   // method. Because writing a field causes the register to be written and, therefore, all
   // of the other fields it contains to also be written, all registered "uvm_ral_field_cbs::post_write()"
   // 
   //------------------------------------------------------------------------------
   virtual task post_write(uvm_ral_field       field,
                           uvm_ral_data_t      wdat,
                           uvm_ral::path_e     path,
                           uvm_ral_map         map,
                           ref uvm_ral::status_e status);
   endtask


   //------------------------------------------------------------------------------
   // TASK: pre_read
   // This callback method is invoked before a value is read from a field in the DUT. The path
   // and domain used to read from the field can be modified. This callback method is only invoked
   // when the "uvm_ral_field::read()" or the "uvm_ral_reg::read()" method is used to
   // read from the field inside the DUT. This callback method is not invoked when only the
   // mirrored value is read using the "uvm_ral_field::get()" method. Because reading
   // a field causes the register to be read and, therefore, all of the other fields it contains
   // to also be read, all registered "uvm_ral_field_cbs::pre_read()" methods with the
   // fields contained in the register will also be invoked. At this point, all registered
   // "uvm_ral_reg_callbacks::pre_read()" methods with the register containing the
   // field will also be invoked. 
   //------------------------------------------------------------------------------
   virtual task pre_read  (uvm_ral_field       field,
                           ref uvm_ral::path_e path,
                           ref uvm_ral_map     map);
   endtask


   //------------------------------------------------------------------------------
   // TASK: post_read
   // This callback method is invoked after a value is read from a field in the DUT. The rdat
   // and status values are the values that are ultimately returned by the "uvm_ral_field::read()"
   // method and can be modified. This callback method is only invoked when the "uvm_ral_field::read()"
   // or the "uvm_ral_reg::read()" method is used to read from the field inside the DUT. This
   // callback method is not invoked when only the mirrored value is read from using the "uvm_ral_field::get()"
   // method. Because reading a field causes the register to be read and, therefore, all of
   // the other fields it contains to also be read, all registered "uvm_ral_field_cbs::post_read()"
   // 
   //------------------------------------------------------------------------------
   virtual task post_read (uvm_ral_field       field,
                           ref uvm_ral_data_t  rdat,
                           uvm_ral::path_e     path,
                           uvm_ral_map         map,
                           ref uvm_ral::status_e status);
   endtask

endclass: uvm_ral_field_cbs


typedef uvm_callbacks#(uvm_ral_field, uvm_ral_field_cbs) uvm_ral_field_cb;
typedef uvm_callback_iter#(uvm_ral_field, uvm_ral_field_cbs) uvm_ral_field_cb_iter;



//------------------------------------------------------------------------------
// CLASS: uvm_ral_field
// Field descriptors. 
//------------------------------------------------------------------------------
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

   extern function new(string name = "uvm_ral_field");

   extern function void configure(uvm_ral_reg                     parent,
                                  int unsigned                    size,
                                  int unsigned                    lsb_pos,
                                  string                          access,
                                  uvm_ral_data_t                  reset,
                                  logic [`UVM_RAL_DATA_WIDTH-1:0] soft_reset,
                                  bit                             is_rand = 0,
                                  bit                             individually_accessible = 0); 


   //-----------
   // Group: Get
   //-----------

   extern virtual function uvm_ral_reg  get_parent();

   //------------------------------------------------------------------------------
   // FUNCTION: get_register
   // Returns a reference to the descriptor of the register that includes the field corresponding
   // to the descriptor instance. 
   //------------------------------------------------------------------------------
   extern virtual function uvm_ral_reg  get_register();
   extern virtual function string       get_full_name();

   //------------------------------------------------------------------------------
   // FUNCTION: get_lsb_pos_in_register
   // Returns the index of the least significant bit of the field in the register that instantiates
   // it. An offset of 0 indicates a field that is aligned with the least-significant bit of
   // the register. 
   //------------------------------------------------------------------------------
   extern virtual function int unsigned get_lsb_pos_in_register();

   //------------------------------------------------------------------------------
   // FUNCTION: get_n_bits
   // Returns the width, in number of bits, of the field. 
   //------------------------------------------------------------------------------
   extern virtual function int unsigned get_n_bits();


   //------------------------------------------------------------------------------
   // FUNCTION: set_access
   // Set the access mode of the field to the specified mode and return the previous access
   // mode. WARNING! Using this method will modify the behavior of the RAL model from the behavior
   // specified in the original specification. 
   //------------------------------------------------------------------------------
   extern virtual function string       set_access(string mode);

   //------------------------------------------------------------------------------
   // FUNCTION: get_access
   // Returns the specification of the behavior of the field when written and read through
   // the optionally specified domain. If the register containing the field is shared across
   // multiple domains, a domain must be specified. The access mode of a field in a specific
   // domain may be restricted. For example, a RW field may only be writable through one of
   // the domains and read-only through all of the other domains. 
   //------------------------------------------------------------------------------
   extern virtual function string       get_access(uvm_ral_map map = null);
   extern virtual function bit          is_known_access(uvm_ral_map map = null);


   //--------------
   // Group: Access
   //--------------


   //------------------------------------------------------------------------------
   // FUNCTION: set
   // Sets the mirror value of the field to the specified value. Does not actually set the value
   // of the field in the design, only the value mirrored in its corresponding descriptor
   // in the RAL model. Use the "uvm_ral_reg::update()" method to update the actual register
   // with the mirrored value or the "uvm_ral_field::write()" method to set the actual field
   // and its mirrored value. The final value in the mirror is a function of the field access
   // mode and the set value, just like a normal physical write operation to the corresponding
   // bits in the hardware. As such, this method (when eventually followed by a call to "uvm_ral_reg::update()")
   // is a zero-time functional replacement for the "uvm_ral_field::write()" method.
   // For example, the mirrored value of a read-only field is not modified by this method,
   // and the mirrored value of a write-once field can only be set if the field has not yet been
   // written to using a physical (for example, front-door) write operation. 
   //------------------------------------------------------------------------------
   extern virtual function void set(uvm_ral_data_t  value,
                                    string          fname = "",
                                    int             lineno = 0);

   //------------------------------------------------------------------------------
   // FUNCTION: get
   // Returns the mirror value of the field. Does not actually read the value of the field in
   // the design, only the value mirrored in its corresponding descriptor in the RAL model.
   // The mirrored value of a write-only field is the value that was set or written and assumed
   // to be stored in the bits implementing the field. Even though a physical read operation
   // of a write-only field returns zeroes, this method returns the assumed content of the
   // field. Use the "uvm_ral_field::read()" method to read the actual field and update
   // its mirrored value. 
   //------------------------------------------------------------------------------
   extern virtual function uvm_ral_data_t get(string fname = "",
                                              int    lineno = 0);


   //------------------------------------------------------------------------------
   // FUNCTION: reset
   // Sets the mirror value of the field to the specified reset value. Does not actually reset
   // the value of the field in the design, only the value mirrored in the descriptor in the
   // RAL model. The value of a write-once (uvm_ral::W1) field can be subsequently modified
   // each time a hard reset is applied. 
   //------------------------------------------------------------------------------
   extern virtual function void reset(uvm_ral::reset_e kind = uvm_ral::HARD);

   extern virtual function uvm_ral_data_logic_t 
                       get_reset(uvm_ral::reset_e kind = uvm_ral::HARD);

   extern virtual function uvm_ral_data_logic_t
                       set_reset(uvm_ral_data_logic_t value,
                                 uvm_ral::reset_e     kind = uvm_ral::HARD);


   //------------------------------------------------------------------------------
   // FUNCTION: needs_update
   // If the mirror value has been modified in the RAL model without actually updating the
   // actual register, the mirror and state of the registers are outdated. This method returns
   // TRUE if the state of the field needs to be updated to match the mirrored values (or vice-versa).
   // The mirror value or actual content of the field are not modified. See "uvm_ral_reg::update()"
   // or "uvm_ral_reg::mirror()". 
   //------------------------------------------------------------------------------
   extern virtual function bit needs_update();


   //------------------------------------------------------------------------------
   // TASK: write
   // Writes the specified field value in the design using the specified access path. If a
   // back-door access path is used, the effect of writing the field through a physical access
   // is mimicked. For example, a read-only field will not be written. If the field is located
   // in a register shared by more than one physical interface, a domain must be specified
   // if a physical access is used (front-door access). 
   //------------------------------------------------------------------------------
   extern virtual task write (output uvm_ral::status_e  status,
                              input  uvm_ral_data_t     value,
                              input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                              input  uvm_ral_map        map = null,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);


   //------------------------------------------------------------------------------
   // TASK: read
   // Reads the current value of the field from the design using the specified access path.
   // If a back-door access path is used, the effect of reading the field through a physical
   // access is mimicked. For example, a write-only field will return zeroes. If the field
   // is located in a register shared by more than one physical interface, a domain must be
   // specified if a physical access is used (front-door access). 
   //------------------------------------------------------------------------------
   extern virtual task read  (output uvm_ral::status_e  status,
                              output uvm_ral_data_t     value,
                              input  uvm_ral::path_e    path = uvm_ral::DEFAULT,
                              input  uvm_ral_map        map = null,
                              input  uvm_sequence_base  parent = null,
                              input  int                prior = -1,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);
               

   //------------------------------------------------------------------------------
   // TASK: poke
   // Deposit the specified field value in the design using a back-door access. The value
   // of the field is updated, regardless of the access mode. The optional value of the arguments:
   // data_id scenario_id stream_id ...are passed to the back-door access method. This
   // allows the physical and back-door write accesses to be traced back to the higher-level
   // transaction that caused the access to occur. 
   //------------------------------------------------------------------------------
   extern virtual task poke  (output uvm_ral::status_e  status,
                              input  uvm_ral_data_t     value,
                              input  string             kind = "",
                              input  uvm_sequence_base  parent = null,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);


   //------------------------------------------------------------------------------
   // TASK: peek
   // Peek the current value of the field from the design using a back-door access. The value
   // of the field in the design is not modified, regardless of the access mode. The optional
   // value of the data_id, scenario_id and stream_id arguments are passed to the back-door
   // access method. This allows the physical and back-door read accesses to be traced back
   // to the higher-level transaction which caused the access to occur. The mirrored value
   // of the field, and all other fields located in the same register, is updated with the value
   // peeked from the design. 
   //------------------------------------------------------------------------------
   extern virtual task peek  (output uvm_ral::status_e  status,
                              output uvm_ral_data_t     value,
                              input  string             kind = "",
                              input  uvm_sequence_base  parent = null,
                              input  uvm_object         extension = null,
                              input  string             fname = "",
                              input  int                lineno = 0);
               

   //------------------------------------------------------------------------------
   // TASK: mirror
   // Updates the content of the field mirror value for all the fields in the same register
   // to match the current values in the design. The mirroring can be performed using the physical
   // interfaces (frontdoor) or "uvm_ral_field::peek()" (backdoor). If the check argument
   // is specified as uvm_ral::VERB, an error message is issued if the current mirrored value
   // of the entire register does not match the actual value in the design. The content of a
   // write-only field is mirrored and optionally checked only if a uvm_ral::BACKDOOR access
   // path is used to read the register containing the field. If the field is located in a register
   // shared by more than one physical interface, a domain must be specified if a physical
   // access is used (front-door access). 
   //------------------------------------------------------------------------------
   extern virtual task mirror(output uvm_ral::status_e status,
                              input  uvm_ral::check_e  check = uvm_ral::NO_CHECK,
                              input  uvm_ral::path_e   path = uvm_ral::DEFAULT,
                              input  uvm_ral_map       map = null,
                              input  uvm_sequence_base parent = null,
                              input  int               prior = -1,
                              input  uvm_object        extension = null,
                              input  string            fname = "",
                              input  int               lineno = 0);


   //------------------------------------------------------------------------------
   // FUNCTION: predict
   // Force the mirror value of the field to the specified value. Does not actually force the
   // value of the field in the design, only the value mirrored in its corresponding descriptor
   // in the RAL model. Use the "uvm_ral_reg::update()" method to update the actual register
   // with the mirrored value or the "uvm_ral_field::write()" method to set the actual field
   // and its mirrored value. The final value in the mirror is the specified value, regardless
   // of the access mode. For example, the mirrored value of a read-only field is modified
   // by this method, and the mirrored value of a read-update field can be updated to any value
   // predicted to correspond to the value in the corresponding physical bits in the design.
   // By default, predict does not allow any update of the mirror, when RAL is busy executing
   // a transaction on this field. However, if need be, that can be overridden, by setting
   // the force_predict argument to 1. 
   //------------------------------------------------------------------------------
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

   extern virtual function void         set_attribute(string name,
                                                      string value);
   extern virtual function string       get_attribute(string name,
                                                      bit inherited = 1);
   extern virtual function void         get_attributes(ref string names[string],
                                                       input bit inherited = 1);

   //--------------------
   // Group: Standard Ops
   //--------------------

   extern virtual function void do_print (uvm_printer printer);
   extern virtual function string convert2string;
   extern virtual function uvm_object clone();
   extern virtual function void do_copy   (uvm_object rhs);
   extern virtual function bit  do_compare (uvm_object  rhs,
                                            uvm_comparer comparer);
   extern virtual function void do_pack (uvm_packer packer);
   extern virtual function void do_unpack (uvm_packer packer);


   //-----------------
   // Group: Callbacks
   //-----------------

   `uvm_register_cb(uvm_ral_field, uvm_ral_field_cbs)

   virtual task pre_write  (ref uvm_ral_data_t  wdat,
                            ref uvm_ral::path_e path,
                            ref uvm_ral_map     map);
   endtask

   virtual task post_write (uvm_ral_data_t        wdat,
                            uvm_ral::path_e       path,
                            uvm_ral_map           map,
                            ref uvm_ral::status_e status);
   endtask

   virtual task pre_read   (ref uvm_ral::path_e path,
                            ref uvm_ral_map     map);
   endtask

   virtual task post_read  (ref uvm_ral_data_t    rdat,
                            uvm_ral::path_e       path,
                            uvm_ral_map           map,
                            ref uvm_ral::status_e status);
   endtask

endclass: uvm_ral_field


//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

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

