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

//------------------------------------------------------------------------------
// File: Transaction Recording Databases
//
// The UVM "Transaction Recording Database" classes are an abstract representation
// of the backend tool which is recording information for the user.  Usually this
// tool would be dumping information such that it can be viewed with the ~waves~ 
// of the DUT.
//

typedef class uvm_tr_stream;
typedef class uvm_link_base;
typedef class uvm_simple_lock_dap;
typedef class uvm_text_tr_stream;
   
   
//------------------------------------------------------------------------------
//
// CLASS: uvm_tr_database
//
// The ~uvm_tr_database~ class is intended to hide the underlying database implementation
// from the end user, as these details are often vendor or tool-specific.
//
// The ~uvm_tr_database~ class is pure virtual, and must be extended with an
// implementation.  A default text-based implementation is provided via the
// <uvm_text_tr_database> class.
//

virtual class uvm_tr_database extends uvm_object;

   // Function: new
   // Constructor
   //
   // Parameters:
   // name - Instance name
   function new(string name="unnamed-uvm_tr_database");
      super.new(name);
   endfunction : new

   // Group: Database API
   
   // Function: open_db
   // Open the backend connection to the database.
   //
   // The method returns '1' if the connection was
   // successfully established, '0' otherwise.
   //
   // This method will trigger a <do_open_db>
   // call.
   function bit open_db();
      return do_open_db();
   endfunction : open_db

   // Function: get_stream
   // Provides a reference to a ~stream~ within the
   // database.
   //
   // Parameters:
   //   name - A string name for the stream.  This is the name associated
   //          with the stream in the database.
   //   cntxt - A optional uvm_component context for the stream.
   //   stream_type_name - An optional name describing the type of records which
   //                      will be created in this stream.  
   //
   // The method returns a reference to a <uvm_tr_stream>
   // object if successful, ~null~ otherwise.
   //
   // This method will trigger a <do_get_stream> call.
   function uvm_tr_stream get_stream(string name,
                                         uvm_component cntxt=null,
                                         string type_name="");
      return do_get_stream(name, cntxt, type_name);
   endfunction : get_stream

   // Function: establish_link
   // Establishes a ~link~ between two elements in the database
   //
   // Links are only supported between ~streams~ and ~records~
   // wihin a single database.
   //
   // This method will trigger a <do_establish_link> call.
   function void establish_link(uvm_link_base link);
      uvm_tr_stream s_lhs, s_rhs;
      uvm_tr_recorder r_lhs, r_rhs;
      uvm_object lhs = link.get_lhs();
      uvm_object rhs = link.get_rhs();
      uvm_tr_database db;

      if (lhs == null) begin
         `uvm_warning("UVM/REC_DB/BAD_LINK",
                      "left hand side '<null>' is not supported in links for 'uvm_tr_database'")
         return;
      end
      if (rhs == null) begin
         `uvm_warning("UVM/REC_DB/BAD_LINK",
                      "right hand side '<null>' is not supported in links for 'uvm_tr_database'")
         return;
      end
      
      if (!$cast(s_lhs, lhs) && 
          !$cast(r_lhs, lhs)) begin
         `uvm_warning("UVM/REC_DB/BAD_LINK",
                      $sformatf("left hand side of type '%s' not supported in links for 'uvm_tr_database'",
                                lhs.get_type_name()))
         return;
      end
      if (!$cast(s_rhs, rhs) && 
          !$cast(r_rhs, rhs)) begin
         `uvm_warning("UVM/REC_DB/BAD_LINK",
                      $sformatf("right hand side of type '%s' not supported in links for 'uvm_record_datbasae'",
                                rhs.get_type_name()))
         return;
      end
      
      if (r_lhs != null) begin
         s_lhs = r_lhs.get_stream();
      end
      if (r_rhs != null) begin
         s_rhs = r_rhs.get_stream();
      end

      if ((s_lhs != null) && (s_lhs.get_db() != this)) begin
         db = s_lhs.get_db();
         `uvm_warning("UVM/REC_DB/BAD_LINK",
                      $sformatf("attempt to link stream from '%s' into '%s'",
                                db.get_name(), this.get_name()))
         return;
      end
      if ((s_rhs != null) && (s_rhs.get_db() != this)) begin
         db = s_rhs.get_db();
         `uvm_warning("UVM/REC_DB/BAD_LINK",
                      $sformatf("attempt to link stream from '%s' into '%s'",
                                db.get_name(), this.get_name()))
         return;
      end

      do_establish_link(link);
   endfunction : establish_link
      
   // Group: Implementation Agnostic API
   //

   // Function: do_open_db
   // Backend implementation of <open_db>
   protected pure virtual function bit do_open_db();

   // Function: do_get_stream
   // Backend implementation of <get_stream>
   protected pure virtual function uvm_tr_stream do_get_stream(string name,
                                                                   uvm_component cntxt,
                                                                   string type_name);

   // Function: do_establish_link
   // Backend implementation of <establish_link>
   protected pure virtual function void do_establish_link(uvm_link_base link);

endclass : uvm_tr_database

//------------------------------------------------------------------------------
//
// CLASS: uvm_text_tr_database
//
// The ~uvm_text_tr_database~ is the default implementation for the
// <uvm_tr_database>.  It provides the ability to store recording information
// into a textual log file.
//
//
   
class uvm_text_tr_database extends uvm_tr_database;

   // Variable- m_filename_dap
   // Data Access Protected Filename
   local uvm_simple_lock_dap#(string) m_filename_dap;

   // Variable- m_file
   UVM_FILE m_file;

   `uvm_object_utils_begin(uvm_text_tr_database)
   `uvm_object_utils_end

   // Function: new
   // Constructor
   //
   // Parameters:
   // name - Instance name
   function new(string name="unnamed-uvm_text_tr_database");
      super.new(name);

      m_filename_dap = new("filename_dap");
      m_filename_dap.set("tr_db.log");
   endfunction : new

   // Group: Implementation Agnostic API
   
   // Function: do_open_db
   // Open the backend connection to the database.
   //
   // Text-Backend implementation of <uvm_tr_database::open_db>.
   //
   // The text-backend will open a text file to dump all records in to.  The name
   // of this text file is controlled via <set_file_name>.
   protected virtual function bit do_open_db();
      if (m_file == 0) begin
         m_file = $fopen(m_filename_dap.get());
         if (m_file > 0)
           m_filename_dap.lock();
      end
      return (m_file > 0);
   endfunction : do_open_db
   
   // Function: do_get_stream
   // Provides a reference to a ~stream~ within the
   // database.
   //
   // Text-Backend implementation of <uvm_tr_database::get_stream>
   protected virtual function uvm_tr_stream do_get_stream(string name,
                                                              uvm_component cntxt=null,
                                                              string type_name="");
      if (open_db()) begin
         uvm_text_tr_stream m_stream = uvm_text_tr_stream::type_id::create(name, cntxt);
         m_stream.initialize_stream(this, cntxt, type_name);
         $fdisplay(m_file, "  CREATE_STREAM @%0t {NAME:%s T:%s SCOPE:%s STREAM:%0d}",
                   $time,
                   name,
                   type_name,
                   (cntxt == null) ? "" : cntxt.get_full_name(),
                   uvm_tr_stream::m_get_id_from_stream(m_stream));
         return m_stream;
      end // if (open_db())
      return null;
   endfunction : do_get_stream

   // Function: do_establish_link
   // Establishes a ~link~ between two elements in the database
   //
   // Text-Backend implementation of <uvm_tr_database::establish_link>.
   protected virtual function void do_establish_link(uvm_link_base link);
      if (open_db()) begin
         uvm_tr_recorder r_lhs, r_rhs;
         uvm_object lhs = link.get_lhs();
         uvm_object rhs = link.get_rhs();

         void'($cast(r_lhs, lhs));
         void'($cast(r_rhs, rhs));
         
         if ((r_lhs == null) ||
             (r_rhs == null))
           return;
         else begin
            uvm_parent_child_link pc_link;
            uvm_related_link re_link;
            if ($cast(pc_link, link)) begin
               $fdisplay(m_file,"  LINK @%0t {TXH1:%0d TXH2:%0d RELATION=%0s}",
                         $time,
                         uvm_tr_recorder::m_get_id_from_recorder(r_lhs),
                         uvm_tr_recorder::m_get_id_from_recorder(r_rhs),
                         "child");
                         
            end
            else if ($cast(re_link, link)) begin
               $fdisplay(m_file,"  LINK @%0t {TXH1:%0d TXH2:%0d RELATION=%0s}",
                         $time,
                         uvm_tr_recorder::m_get_id_from_recorder(r_lhs),
                         uvm_tr_recorder::m_get_id_from_recorder(r_rhs),
                         "");
               
            end
         end
         
      end
   endfunction : do_establish_link

   // Group: Implementation Specific API
   
   // Function: set_file_name
   // Sets the file name which will be used for output.
   //
   // The ~set_file_name~ method can only be called prior to ~open_db~.
   //
   // By default, the database will use a file named "tr_db.log".
   function void set_file_name(string filename);
      if (filename == "") begin
        `uvm_warning("UVM/TXT_DB/EMPTY_NAME",
                     "Ignoring attempt to set file name to ''!")
         return;
      end

      if (!m_filename_dap.try_set(filename)) begin
         `uvm_warning("UVM/TXT_DB/SET_AFTER_OPEN",
                      "Ignoring attempt to change file name after opening the db!")
         return;
      end
   endfunction : set_file_name

   // Function: set_attribute
   // Outputs an integral attribute to the textual log
   //
   // Parameters:
   // record - Record containing this attribute
   // nm - Name of the attribute
   // value - Value
   // radix - Radix of the output
   // numbits - number of valid bits
   function void set_attribute(int tx_h,
                               string nm,
                               uvm_bitstream_t value,
                               uvm_radix_enum radix,
                               integer numbits=$bits(uvm_bitstream_t));
      if (open_db()) begin
         $fdisplay(m_file, "  SET_ATTR @%0t {TXH:%0d NAME:%s VALUE:%s   RADIX:%s BITS=%0d}",
                   $time,
                   tx_h,
                   nm,
                   uvm_bitstream_to_string(value, numbits, radix),
                    radix.name(),
                   numbits);
      end
   endfunction : set_attribute

   // Function: set_attribute_int
   // Outputs an integral attribute to the textual log
   //
   // Parameters:
   // record - Record containing this attribute
   // nm - Name of the attribute
   // value - Value
   // radix - Radix of the output
   // numbits - number of valid bits
   function void set_attribute_int(int tx_h,
                                   string  nm,
                                   uvm_integral_t value,
                                   uvm_radix_enum radix,
                                   integer numbits=$bits(uvm_bitstream_t));
      if (open_db()) begin
         $fdisplay(m_file, "  SET_ATTR @%0t {TXH:%0d NAME:%s VALUE:%0d   RADIX:%s BITS=%0d}",
                   $time,
                   tx_h,
                   nm,
                   uvm_integral_to_string(value, numbits, radix),
                    radix.name(),
                   numbits);
      end
   endfunction : set_attribute_int

   
endclass : uvm_text_tr_database
