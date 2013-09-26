//
//-----------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
//   Copyright 2013 NVIDIA Corporation
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
//-----------------------------------------------------------------------------

// File: UVM Recorders
//
// The uvm_tr_recorder class serves two purposes:
//  - Firstly, it is an abstract representation of a record within a
//    <uvm_tr_stream>.
//  - Secondly, it is a policy object for recording fields ~into~ that
//    record within the ~stream~.
//

//------------------------------------------------------------------------------
//
// CLASS: uvm_tr_recorder
//
// Abstract class which defines the ~recorder~ API.
//
//------------------------------------------------------------------------------

virtual class uvm_tr_recorder extends uvm_object;

  // Variable- m_stream_dap
  // Data access protected reference to the stream
  local uvm_set_before_get_dap#(uvm_tr_stream) m_stream_dap;

  // Variable- m_warn_null_stream
  // Used to limit the number of warnings 
  local bit m_warn_null_stream;
   
  // Variable- recording_depth
  int recording_depth;

  // Variable: default_radix
  //
  // This is the default radix setting if <record_field> is called without
  // a radix.

  uvm_radix_enum default_radix = UVM_HEX;

  // Variable: physical
  //
  // This bit provides a filtering mechanism for fields. 
  //
  // The <abstract> and physical settings allow an object to distinguish between
  // two different classes of fields. 
  //
  // It is up to you, in the <uvm_object::do_record> method, to test the
  // setting of this field if you want to use the physical trait as a filter.

  bit physical = 1;


  // Variable: abstract
  //
  // This bit provides a filtering mechanism for fields. 
  //
  // The abstract and physical settings allow an object to distinguish between
  // two different classes of fields. 
  //
  // It is up to you, in the <uvm_object::do_record> method, to test the
  // setting of this field if you want to use the abstract trait as a filter.

  bit abstract = 1;


  // Variable: identifier
  //
  // This bit is used to specify whether or not an object's reference should be
  // recorded when the object is recorded. 

  bit identifier = 1;


  // Variable: recursion_policy
  //
  // Sets the recursion policy for recording objects. 
  //
  // The default policy is deep (which means to recurse an object).

  uvm_recursion_policy_enum policy = UVM_DEFAULT_POLICY;


  function new(string name = "uvm_tr_recorder");
     super.new(name);
     m_stream_dap = new("stream_dap");
  endfunction

   // Function: get_stream
   // Returns a reference to the stream which created
   // this record.
   //
   // A warning will be asserted if get_stream is called prior
   // to the record being initialized via <initialize_recorder>.
   //
   function uvm_tr_stream get_stream();
      if (!m_stream_dap.try_get(get_stream)) begin
         if (m_warn_null_stream == 1) 
           `uvm_warning("UVM/REC/NO_INIT",
                        $sformatf("attempt to retrieve STREAM from '%s' before it was set!",
                                  get_name()))
         m_warn_null_stream = 0;
      end
   endfunction : get_stream

  // Group: Implementation Agnostic API

  // Function: initialize_recorder
  // Initializes the internal state of the recorder.
  //
  // Parameters:
  // stream - The stream which spawned this recorder
  //
  // This method will trigger a <do_initialize_recorder> call.
  //
  // An error will be asserted if:
  // - ~initialized_recorder~ is called more than once without the
  //  recorder being ~freed~ in between.
  // - ~stream~ is ~null~
  function void initialize_recorder(uvm_tr_stream stream);
     uvm_tr_stream m_stream;
     if (stream == null) begin
        `uvm_error("UVM/REC/NULL_STREAM",
                   $sformatf("Illegal attempt to set STREAM for '%s' to '<null>'",
                             this.get_name()))
        return;
     end

     if (m_stream_dap.try_get(m_stream)) begin
        `uvm_error("UVM/REC/RE_INIT",
                   $sformatf("Illegal attempt to re-initialize '%s'",
                             this.get_name()))
        return;
     end

     m_stream_dap.set(stream);

     do_initialize_recorder(stream);
  endfunction : initialize_recorder

  // Function: free_recorder
  // Releases the internal state of the recorder.
  //
  // This method will trigger a <do_free_recorder> call.
  function void free_recorder();
     m_stream_dap = new("stream_dap");
     m_warn_null_stream = 1;
     // Backwards compat
     if (m_ids_by_recorder.exists(this))
       m_free_id(m_ids_by_recorder[this]);
     do_free_recorder();
  endfunction : free_recorder
   
   // Function: record_field
   // Records an integral field (less than or equal to 4096 bits).
   //
   // Parameters:
   // name - Name of the field
   // value - Value of the field to record.
   // size - Number of bits of the field which apply (Usually obtained via $bits).
   // radix - The <uvm_radix_enum> to use.
   //
   // This method will trigger a <do_record_field> call.
   function void record_field(string name,
                              uvm_bitstream_t value,
                              int size,
                              uvm_radix_enum radix=UVM_NORADIX);
      if (get_stream() == null) begin
         return;
      end
      do_record_field(name, value, size, radix);
   endfunction : record_field

   // Function: record_field_int
   // Records an integral field (less than or equal to 64 bits).
   //
   // This optimized version of <record_field> is useful for sizes up
   // to 64 bits.
   //
   // Parameters:
   // name - Name of the field
   // value - Value of the field to record
   // size - Number of bits of the wfield which apply (Usually obtained via $bits).
   // radix - The <uvm_radix_enum> to use.
   //
   // This method will trigger a <do_record_field_int> call.
   function void record_field_int(string name,
                                  uvm_integral_t value,
                                  int size,
                                  uvm_radix_enum radix=UVM_NORADIX);
        if (get_stream() == null) begin
         return;
      end
      do_record_field_int(name, value, size, radix);
   endfunction : record_field_int

   // Function: record_field_real
   // Records a real field.
   //
   // Parameters:
   // name - Name of the field
   // value - Value of the field to record
   //
   // This method will trigger a <do_record_field_real> call.
   function void record_field_real(string name,
                                   real value);
      if (get_stream() == null) begin
         return;
      end
      do_record_field_real(name, value);
   endfunction : record_field_real

   // Function: record_object
   // Records an object field.
   //
   // Parameters:
   // name - Name of the field
   // value - Object to record
   //
   // The implementation must use the <recursion_policy> and <identifier> to
   // determine exactly what should be recorded.
   function void record_object(string name,
                               uvm_object value);
      if (get_stream() == null) begin
         return;
      end
      
      do_record_object(name, value);
   endfunction : record_object

   // Function: record_string
   // Records a string field.
   //
   // Parameters:
   // name - Name of the field
   // value - Value of the field
   //
   function void record_string(string name,
                               string value);
      if (get_stream() == null) begin
         return;
      end

      do_record_string(name, value);
   endfunction : record_string
   
   // Function: record_time
   // Records a time field.
   //
   // Parameters:
   // name - Name of the field
   // value - Value of the field
   //
   function void record_time(string name,
                             time value);
      if (get_stream() == null) begin
         return;
      end

      do_record_time(name, value);
   endfunction : record_time
   
   // Function: record_generic
   // Records a name/value pair, where ~value~ has been converted to a string.
   //
   // For example:
   //| recorder.record_generic("myvar","var_type", $sformatf("%0d",myvar), 32);
   //
   // Parameters:
   // name - Name of the field
   // value - Value of the field
   // type_name - ~optional~ Type name of the field
   function void record_generic(string name,
                                string value,
                                string type_name="");
      if (get_stream() == null) begin
         return;
      end

      do_record_generic(name, value, type_name);
   endfunction : record_generic

   // Group: Implementation Specific API

   // Function: do_intiialize_recorder
   // Initializes the state of the recorder
   //
   // ~Optional~ Backend implementation of <initialize_recorder>
   protected virtual function void do_initialize_recorder(uvm_tr_stream stream);
   endfunction : do_initialize_recorder

   // Function: do_free_recorder
   // Frees the internal state of the recorder
   //
   // ~Optional~ Backend implementation of <free_recorder>
   protected virtual function void do_free_recorder();
   endfunction : do_free_recorder
   
   // Function: do_record_field
   // Records an integral field (less than or equal to 4096 bits).
   //
   // ~Mandatory~ Backend implementation of <record_field>
   protected pure virtual function void do_record_field(string name,
                                                        uvm_bitstream_t value,
                                                        int size,
                                                        uvm_radix_enum radix);

   // Function: do_record_field_int
   // Records an integral field (less than or equal to 64 bits).
   //
   // ~Mandatory~ Backend implementation of <record_field_int>
   protected pure virtual function void do_record_field_int(string name,
                                                            uvm_integral_t value,
                                                            int          size,
                                                            uvm_radix_enum radix);
   
   // Function: do_record_field_real
   // Records a real field.
   //
   // ~Mandatory~ Backend implementation of <record_field_real>
   protected pure virtual function void do_record_field_real(string name,
                                                             real value);

   // Function: do_record_object
   // Records an object field.
   //
   // ~Mandatory~ Backend implementation of <record_object>
   protected pure virtual function void do_record_object(string name,
                                                         uvm_object value);

   // Function: do_record_string
   // Records a string field.
   //
   // ~Mandatory~ Backend implementation of <record_string>
   protected pure virtual function void do_record_string(string name,
                                                         string value);

   // Function: do_record_time
   // Records a time field.
   //
   // ~Mandatory~ Backend implementation of <record_time>
   protected pure virtual function void do_record_time(string name,
                                                       time value);

   // Function: do_record_generic
   // Records a name/value pair, where ~value~ has been converted to a string.
   //
   // ~Mandatory~ Backend implementation of <record_generic>
   protected pure virtual function void do_record_generic(string name,
                                                          string value,
                                                          string type_name);

   /// LEFT FOR BACKWARDS COMPAT ONLY!!!!!!
   
   // THE FOLLOWING CODE IS PRESENT FOR BACKWARDS COMPATIBILITY PURPOSES
   // ONLY.  IT IS NOT DOCUMENTED, AND SHOULD NOT BE USED BY END USERS

   // Variable- m_ids_by_recorder
   // An associative array of integers, indexed by uvm_tr_recorders.  This
   // provides a unique 'id' or 'handle' for each recorder, which can be
   // used to identify the recorder.
   //
   // By default, neither ~m_ids_by_recorder~ or ~m_recorders_by_id~ are
   // used.  Recorders are only placed in the arrays when the user
   // attempts to determine the id for a recorder.
   local static integer m_ids_by_recorder[uvm_tr_recorder];

   // Variable- m_recorders_by_id
   // A corollary to ~m_ids_by_recorder~, this indexes the recorders by their
   // unique ids.
   local static uvm_tr_recorder m_recorders_by_id[integer];

   // Variable- m_id
   // Static int marking the last assigned id.
   local static integer m_id;

   // Function- m_get_id_from_recorder
   // Returns a "unique id" for the given recorder.
   //
   // 0 indicates "null" recorder
   static function integer m_get_id_from_recorder(uvm_tr_recorder recorder);
      if (recorder == null)
        return 0;

      if (!m_ids_by_recorder.exists(recorder)) begin
         m_recorders_by_id[++m_id] = recorder;
         m_ids_by_recorder[recorder] = m_id;
      end

      return m_id;
   endfunction : m_get_id_from_recorder

   // Function- m_get_recorder_from_id
   // Returns a recorder reference for a given unique id.
   //
   // If no recorder exists with a given id, then ~null~
   // is returned.
   static function uvm_tr_recorder m_get_recorder_from_id(integer id);
      if (id == 0)
        return null;

      if (!m_recorders_by_id.exists(id))
        return null;

      return m_recorders_by_id[id];
   endfunction : m_get_recorder_from_id

   // Function- m_free_id
   // Frees the id/recorder link (memory cleanup)
   //
   static function void m_free_id(integer id);
      uvm_tr_recorder recorder;
      if (m_recorders_by_id.exists(id))
        recorder = m_recorders_by_id[id];

      if (recorder != null) begin
         m_recorders_by_id.delete(id);
         m_ids_by_recorder.delete(recorder);
      end
   endfunction : m_free_id
            
   
   //------------------------------
   // Group- Vendor-Independent API
   //------------------------------


  // UVM provides only a text-based default implementation.
  // Vendors provide subtype implementations and overwrite the
  // <uvm_default_recorder> handle.


  // Function- open_file
  //
  // Opens the file in the <filename> property and assigns to the
  // file descriptor <file>.
  //
  virtual function bit open_file();
     return 0;
  endfunction

  // Function- create_stream
  //
  //
  virtual function integer create_stream (string name,
                                          string t,
                                          uvm_component cntxt);
     return -1;
  endfunction

   
  // Function- m_set_attribute
  //
  //
  virtual function void m_set_attribute (integer txh,
                                 string nm,
                                 string value);
  endfunction
  
  
  // Function- set_attribute
  //
  //
  virtual function void set_attribute (integer txh,
                               string nm,
                               logic [1023:0] value,
                               uvm_radix_enum radix,
                               integer numbits=1024);
  endfunction
  
  
  // Function- check_handle_kind
  //
  //
  virtual function integer check_handle_kind (string htype, integer handle);
  endfunction
  
  
  // Function- begin_tr
  //
  //
  virtual function integer begin_tr(string txtype,
                                     integer stream,
                                     string nm,
                                     string label="",
                                     string desc="",
                                     time begin_time=0);
    return -1;
  endfunction
  
  
  // Function- end_tr
  //
  //
  virtual function void end_tr (integer handle, time end_time=0);
  endfunction
  
  
  // Function- link_tr
  //
  //
  virtual function void link_tr(integer h1,
                                 integer h2,
                                 string relation="");
  endfunction
  
  
  
  // Function- free_tr
  //
  //
  virtual function void free_tr(integer handle);
  endfunction
  
endclass // uvm_tr_recorder

// Provided for backwards compat
typedef uvm_tr_recorder uvm_recorder;
  
//------------------------------------------------------------------------------
//
// CLASS: uvm_text_recorder
//
// The ~uvm_text_recorder~ is the default recorder implementation for the
// <uvm_text_tr_database>.
//

class uvm_text_recorder extends uvm_tr_recorder;

   `uvm_object_utils(uvm_text_recorder)

   // Variable- tr_handle
   //
   // This is an integral handle to a transaction object. Its use is vendor
   // specific. 
   //
   // A handle of 0 indicates there is no active transaction object. 
   
   integer tr_handle = 0;

   // Variable- m_text_db
   //
   // Reference to the text database backend
   uvm_text_tr_database m_text_db;

   // Variable- scope
   // Imeplementation detail
   uvm_scope_stack scope = new;

   // Function: new
   // Constructor
   //
   // Parameters:
   // name - Instance name
   function new(string name="unnamed-uvm_text_recorder");
      super.new(name);
   endfunction : new

   // Group: Implementation Specific API

   // Function: do_initialize_recorder
   // Initializes the state of the recorder
   //
   // Text-backend specific implementation.
   protected virtual function void do_initialize_recorder(uvm_tr_stream stream);
      $cast(m_text_db, stream.get_db());
   endfunction : do_initialize_recorder

   // Function: do_free_recorder
   // Clears the state of the recorder
   //
   // Text-backend specific implementation.
   protected virtual function void do_free_recorder();
      m_text_db = null;
   endfunction : do_free_recorder
   
   // Function: do_record_field
   // Records an integral field (less than or equal to 4096 bits).
   //
   // Text-backend specific implementation.
   protected virtual function void do_record_field(string name,
                                                   uvm_bitstream_t value,
                                                   int size,
                                                   uvm_radix_enum radix);
      scope.set_arg(name);
      if (!radix)
        radix = default_radix;

      m_text_db.set_attribute(uvm_tr_recorder::m_get_id_from_recorder(this),
                              scope.get(),
                              value,
                              radix,
                              size);

   endfunction : do_record_field
  
   
   // Function: do_record_field_int
   // Records an integral field (less than or equal to 64 bits).
   //
   // Text-backend specific implementation.
   protected virtual function void do_record_field_int(string name,
                                                       uvm_integral_t value,
                                                       int          size,
                                                       uvm_radix_enum radix);
      scope.set_arg(name);
      if (!radix)
        radix = default_radix;

      m_text_db.set_attribute_int(uvm_tr_recorder::m_get_id_from_recorder(this),
                                  scope.get(),
                                  value,
                                  radix,
                                  size);

   endfunction : do_record_field_int


   // Function: do_record_field_real
   // Record a real field.
   //
   // Text-backened specific implementation.
   protected virtual function void do_record_field_real(string name,
                                                        real value);
      bit [63:0] ival = $realtobits(value);
      scope.set_arg(name);

      m_text_db.set_attribute(uvm_tr_recorder::m_get_id_from_recorder(this),
                              scope.get(),
                              ival,
                              UVM_REAL,
                              64);
   endfunction : do_record_field_real

   // Function: do_record_object
   // Record an object field.
   //
   // Text-backend specific implementation.
   //
   // The method uses <identifier> to determine whether or not to
   // record the object instance id, and <recursion_policy> to
   // determine whether or not to recurse into the object.
   protected virtual function void do_record_object(string name,
                                                    uvm_object value);
      int            v;
      string         str;
      
      if(identifier) begin 
         if(value != null) begin
            $swrite(str, "%0d", value.get_inst_id());
            v = str.atoi(); 
         end
         scope.set_arg(name);
         m_text_db.set_attribute(uvm_tr_recorder::m_get_id_from_recorder(this), 
                                 scope.get(), 
                                 v, 
                                 UVM_DEC, 
                                 32);
      end
 
      if(policy != UVM_REFERENCE) begin
         if(value!=null) begin
            if(value.__m_uvm_status_container.cycle_check.exists(value)) return;
            value.__m_uvm_status_container.cycle_check[value] = 1;
            scope.down(name);
            value.record(this);
            scope.up();
            value.__m_uvm_status_container.cycle_check.delete(value);
         end
      end
   endfunction : do_record_object

   // Function: do_record_string
   // Records a string field.
   //
   // Text-backend specific implementation.
   protected virtual function void do_record_string(string name,
                                                    string value);
      scope.set_arg(name);
      m_text_db.set_attribute(uvm_tr_recorder::m_get_id_from_recorder(this), 
                              scope.get(), 
                              uvm_string_to_bits(value),
                              UVM_STRING, 
                              8+value.len());
   endfunction : do_record_string

   // Function: do_record_time
   // Records a time field.
   //
   // Text-backend specific implementation.
   protected virtual function void do_record_time(string name,
                                                    time value);
      scope.set_arg(name);
      m_text_db.set_attribute(uvm_tr_recorder::m_get_id_from_recorder(this), 
                              scope.get(), 
                              value,
                              UVM_TIME, 
                              64);
   endfunction : do_record_time

   // Function: do_record_generic
   // Records a name/value pair, where ~value~ has been converted to a string.
   //
   // Text-backend specific implementation.
   protected virtual function void do_record_generic(string name,
                                                     string value,
                                                     string type_name);
      scope.set_arg(name);
      m_text_db.set_attribute(uvm_tr_recorder::m_get_id_from_recorder(this), 
                              scope.get(), 
                              uvm_string_to_bits(value), 
                              UVM_STRING, 
                              8+value.len());
   endfunction : do_record_generic

   /// LEFT FOR BACKWARDS COMPAT ONLY!!!!!!!!

   //------------------------------
   // Group- Vendor-Independent API
   //------------------------------


  // UVM provides only a text-based default implementation.
  // Vendors provide subtype implementations and overwrite the
  // <uvm_default_recorder> handle.

   string                                                   filename;
   bit                                                      filename_set;

  // Function- open_file
  //
  // Opens the file in the <filename> property and assigns to the
  // file descriptor <file>.
  //
  virtual function bit open_file();
     if (!filename_set) begin
        m_text_db.set_file_name(filename);
     end
     return m_text_db.open_db();
  endfunction


  // Function- create_stream
  //
  //
  virtual function integer create_stream (string name,
                                          string t,
                                          uvm_component cntxt);
     uvm_text_tr_stream stream;
     if (open_file()) begin
        $cast(stream,m_text_db.get_stream(name, cntxt, t));
        return uvm_tr_stream::m_get_id_from_stream(stream);
     end
     return 0;
  endfunction

   
  // Function- m_set_attribute
  //
  //
  virtual function void m_set_attribute (integer txh,
                                 string nm,
                                 string value);
     if (open_file()) begin
        UVM_FILE file = m_text_db.m_file;
        $fdisplay(file,"  SET_ATTR @%0t {TXH:%0d NAME:%s VALUE:%s}", $time,txh,nm,value);
     end
  endfunction
  
  
  // Function- set_attribute
  //
  //
  virtual function void set_attribute (integer txh,
                               string nm,
                               logic [1023:0] value,
                               uvm_radix_enum radix,
                               integer numbits=1024);
     if (open_file()) begin
        m_text_db.set_attribute(txh, nm, value, radix, numbits);
     end
  endfunction
  
  
  // Function- check_handle_kind
  //
  //
  virtual function integer check_handle_kind (string htype, integer handle);
     return ((uvm_tr_recorder::m_get_recorder_from_id(handle) != null) ||
             (uvm_tr_stream::m_get_stream_from_id(handle) != null));
  endfunction
  
  
  // Function- begin_tr
  //
  //
  virtual function integer begin_tr(string txtype,
                                     integer stream,
                                     string nm,
                                     string label="",
                                     string desc="",
                                     time begin_time=0);
     if (open_file()) begin
        uvm_tr_stream stream_obj = uvm_tr_stream::m_get_stream_from_id(stream);
        uvm_tr_recorder recorder;
        if (stream_obj == null)
          return -1;

        recorder = stream_obj.open_tr(nm, begin_time, txtype);

        return uvm_tr_recorder::m_get_id_from_recorder(recorder);
     end
     return -1;
  endfunction
  
  
  // Function- end_tr
  //
  //
  virtual function void end_tr (integer handle, time end_time=0);
     if (open_file()) begin
        uvm_tr_recorder record = uvm_tr_recorder::m_get_recorder_from_id(handle);
        if (record != null) begin
           uvm_tr_stream stream = record.get_stream();
           stream.close_tr(record, end_time);
        end
     end
  endfunction
  
  
  // Function- link_tr
  //
  //
  virtual function void link_tr(integer h1,
                                 integer h2,
                                 string relation="");
    if (open_file())
      $fdisplay(m_text_db.m_file,"  LINK @%0t {TXH1:%0d TXH2:%0d RELATION=%0s}", $time,h1,h2,relation);
  endfunction
  
  
  
  // Function- free_tr
  //
  //
  virtual function void free_tr(integer handle);
     if (open_file()) begin
        uvm_tr_recorder record = uvm_tr_recorder::m_get_recorder_from_id(handle);
        if (record != null) begin
           uvm_tr_stream stream = record.get_stream();
           stream.free_tr(record);
        end
     end
  endfunction // free_tr

endclass : uvm_text_recorder

  
   
