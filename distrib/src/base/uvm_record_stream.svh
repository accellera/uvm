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
// File: Recording Streams
//

// class- m_uvm_record_stream_init
// Undocumented helper class for storing stream
// initialization values.
class m_uvm_record_stream_init;
   uvm_record_database db;
   uvm_component cntxt;
   string stream_type_name;
endclass : m_uvm_record_stream_init

typedef class uvm_set_before_get_dap;
typedef class uvm_text_recorder;
   
//------------------------------------------------------------------------------
//
// CLASS: uvm_record_stream
//
// The ~uvm_record_stream~ base class is a representation of a stream of records
// within a <uvm_record_database>.
//
// The record stream is intended to hide the underlying database implementation
// from the end user, as these details are often vendor or tool-specific.
//
// The ~uvm_record_stream~ class is pure virtual, and must be extended with an
// implementation.  A default text-based implementation is provided via the
// <uvm_text_record_stream> class.
//
virtual class uvm_record_stream extends uvm_object;

   // Variable- m_init_dap
   // Data access protected reference to the DB
   local uvm_set_before_get_dap#(m_uvm_record_stream_init) m_init_dap;

   // Variable- m_open_records
   // Used for tracking records between the begin..end state
   time m_open_records[uvm_recorder];

   // Variable- m_closed_records
   // Used for tracking records between the end..free state
   time m_closed_records[uvm_recorder];

   // Function: new
   // Constructor
   //
   // Parameters:
   // name - Stream instance name
   function new(string name="unnamed-uvm_record_stream");
      super.new(name);
      m_init_dap = new("init_dap");
   endfunction : new

   // Group: Stream API
   //
   // Records within a stream follow a protocol similar to <uvm_transaction>,
   // in that the user can "Begin" and "End" a record.  
   //
   // Due to the fact that many database implementations will require crossing 
   // a language boundary, an additional step of "Freeing" the record is required.
   //
   // It is legal to add attributes to a record any time between "Begin" and "End",
   // however it is illegal to add attributes after "End".
   //
   // A ~link~ can be established within the database any time between "Begin" and
   // "Free", however it is illegal to establish a link after "Freeing" the record.
   //
   
   // Function: get_db
   // Returns a reference to the database which contains this
   // stream.
   //
   // An error will be asserted if get_db is called prior to
   // the stream being initialized via <initialize_stream>.
   function uvm_record_database get_db();
      m_uvm_record_stream_init m_init;
      if (!m_init_dap.try_get(m_init)) begin
         `uvm_error("UVM/REC_STR/NO_INIT",
                    $sformatf("Illegal attempt to retrieve DB from '%s' before it was set!",
                              get_name()))
         return null;
      end
      return m_init.db;
   endfunction : get_db
      
   // Function: get_context
   // Returns a reference to the database which contains this
   // stream.
   //
   // An error will be asserted if get_context is called prior to
   // the stream being initialized via <initialize_stream>.
   function uvm_component get_context();
      m_uvm_record_stream_init m_init;
      if (!m_init_dap.try_get(m_init)) begin
         `uvm_error("UVM/REC_STR/NO_INIT",
                    $sformatf("Illegal attempt to retrieve CONTEXT from '%s' before it was set!",
                              get_name()))
         return null;
      end
      return m_init.cntxt;
   endfunction : get_context
      
   // Function: get_stream_type_name
   // Returns a reference to the database which contains this
   // stream.
   //
   // An error will be asserted if get_stream_type_name is called prior to
   // the stream being initialized via <initialize_stream>.
   function string get_stream_type_name();
      m_uvm_record_stream_init m_init;
      if (!m_init_dap.try_get(m_init)) begin
         `uvm_error("UVM/REC_STR/NO_INIT",
                    $sformatf("Illegal attempt to retrieve STREAM_TYPE_NAME from '%s' before it was set!",
                              get_name()))
         return "";
      end
      return m_init.stream_type_name;
   endfunction : get_stream_type_name

   // Function: initialize_stream
   // Initializes the state of the stream
   //
   // Parameters:
   // db - Database which the stream belongs to
   // context - Optional component context
   // stream_type_name - Optional type name for the stream
   //
   // This method will trigger a <do_initialize_stream> call.
   //
   // An error will be asserted if:
   // - initialize_stream is called more than once
   // - initialize_stream is passed a ~null~ db
   function void initialize_stream(uvm_record_database db,
                                   uvm_component cntxt=null,
                                   string stream_type_name="");
      
      m_uvm_record_stream_init m_init;
      uvm_record_database m_db;
      if (db == null) begin
         `uvm_error("UVM/REC_STR/NULL_DB",
                    $sformatf("Illegal attempt to set DB for '%s' to '<null>'",
                              this.get_full_name()))
         return;
      end

      if (m_init_dap.try_get(m_init)) begin
         `uvm_error("UVM/REC_STR/RE_INIT",
                    $sformatf("Illegal attempt to re-initialize '%s'",
                              this.get_full_name()))
      end
      else begin
         // Never set before
         m_init = new();
         m_init.db = db;
         m_init.cntxt = cntxt;
         m_init.stream_type_name = stream_type_name;
         m_init_dap.set(m_init);

         do_initialize_stream(db, cntxt, stream_type_name);
      end
      
   endfunction : initialize_stream
   
   // Function: begin_record
   // Marks the beginning of a new record in the stream.
   //
   // Parameters:
   // name - A name for the new record
   // begin_time - Optional time to record as the begining of this record
   // type_name - Optional type name for the record
   //
   // If ~begin_time~ is omitted (or set to '0'), then the stream will use
   // the current time.
   //
   // This method will trigger a <do_begin_record> call.
   function uvm_recorder begin_record(string name,
                                      time   begin_time = 0,
                                      string type_name="");
      time m_time = (begin_time == 0) ? $time : begin_time;
      begin_record = do_begin_record(name,
                                     m_time,
                                     type_name);
      m_open_records[begin_record] = m_time;
   endfunction : begin_record

   // Function: end_record
   // Marks the end of a record in the stream.
   //
   // Parameters:
   // record - The record which is ending
   // end_time - Optional time to record as the ending of this record.
   //
   // If ~end_time~ is omitted (or set to '0'), then the stream will use
   // the current time.
   //
   // An error will be asserted if:
   // - ~record~ is ~null~
   // - ~record~ has already ended
   // - ~record~ was not generated by this stream
   // - the ~end_time~ is prior to the ~begin_time~
   //
   // This method will trigger a <do_end_record> call.
   function void end_record(uvm_recorder record,
                            time end_time = 0);
      time m_time = (end_time == 0) ? $time : end_time;
      if (record == null) begin
         `uvm_error("UVM/REC_STR/END_NULL",
                    $sformatf("illegal '<null>' recorder passed to end_record on '%s'",
                              get_name()))
         return;
      end
      else if (m_closed_records.exists(record)) begin
         `uvm_error("UVM/REC_STR/END_AGAIN",
                    $sformatf("illegal attempt to re-end record '%s' on '%s'",
                              record.get_name(),
                              get_name()))
         return;
      end
      else if (!m_open_records.exists(record)) begin
         `uvm_error("UVM/REC_STR/END_INV",
                    $sformatf("illegal attempt to end invalid record '%s' on '%s'",
                              record.get_name(),
                              get_name()))
         return;
      end
      else if (m_time < m_open_records[record]) begin
         `uvm_error("UVM/REC_STR/END_B4_BEGIN",
                    $sformatf("illegal attempt to end record '%s' on '%s' at time %0t, which is before the begin time %0t",
                              record.get_name(),
                              get_name(),
                              m_time,
                              m_open_records[record]))
      end
      m_open_records.delete(record);
      m_closed_records[record] = m_time;
      do_end_record(record, m_time);
   endfunction : end_record

   // Function: free_record
   // Indicates the stream and database can free any references to the record.
   //
   // Parameters:
   // record - The record which is being freed
   // end_time - Optional time to record as the ending of this record
   //
   // If a record has not yet ended (via a call to <end_record>), then the
   // record will be explicitly ended via the call to ~free_record~.  If
   // this is the case, <end_record> will be called automatically.
   //
   // If the record has already ended, then the second parameter to ~free_record~
   // will be ignored.
   //
   // This method will trigger a call to <uvm_recorder::free_record>, followed by
   // a call to <do_free_record>.
   //
   // An error will be asserted if:
   // - ~record~ is null
   // - ~record~ has already been freed
   // - ~record~ was not generated by this stream
   function void free_record(uvm_recorder record,
                             time end_time = 0);
      if (record == null) begin
         `uvm_error("UVM/REC_STR/END_NULL",
                    $sformatf("illegal '<null>' recorder passed to free_record on '%s'",
                              get_name()))
         return;
      end
      else if ((!m_closed_records.exists(record)) && (!m_open_records.exists(record))) begin
         `uvm_error("UVM/REC_STR/END_INV",
                    $sformatf("illegal attempt to free invalid record '%s' on '%s'",
                              record.get_name(),
                              get_name()))
         return;
      end

      if (m_open_records.exists(record)) begin
         // Need to end the record
         end_record(record, end_time);
      end

      m_closed_records.delete(record);

      record.free_recorder();
      
      do_free_record(record);

      // Required for backwards compat...
      uvm_record_database::m_free_record_handle(record);
   endfunction : free_record

   // Group: Implementation Agnostic API
   //

   // Function: do_initialize_stream
   // Initializes the state of the stream
   //
   // Backend implementation of <initialize_stream>
   protected pure virtual function void do_initialize_stream(uvm_record_database db,
                                                             uvm_component cntxt,
                                                             string stream_type_name);

   // Function: do_begin_record
   // Marks the beginning of a new record in the stream.
   //
   // Backend implementation of <begin_record>
   protected pure virtual function uvm_recorder do_begin_record(string name,
                                                                time   begin_time,
                                                                string type_name);

   // Function: do_end_record
   // Marks the end of a record in the stream
   //
   // Backend implementation of <end_record>
   protected pure virtual function void do_end_record(uvm_recorder record,
                                                      time end_time);

   // Function: do_free_record
   // Indicates the stream and database can free any references to the record.
   //
   // Backend implementation of <free_record>.
   //
   // Note that unlike the <free_record> method, ~do_free_record~ does not
   // have the optional ~end_time~ argument.  The argument will be processed
   // by <free_record> prior to the ~do_free_record~ call.
   protected pure virtual function void do_free_record(uvm_recorder record);

endclass : uvm_record_stream

//------------------------------------------------------------------------------
//
// CLASS: uvm_text_record_stream
//
// The ~uvm_text_record_stream~ is the default stream implementation for the
// <uvm_text_record_database>.  
//
//                     

class uvm_text_record_stream extends uvm_record_stream;

   // Variable- m_text_db
   // Internal reference to the text-based backend
   local uvm_text_record_database m_text_db;
   
   // Variable- m_free_records
   // Used for memory savings
   static uvm_text_recorder m_free_records[$];

   `uvm_object_utils_begin(uvm_text_record_stream)
   `uvm_object_utils_end

   // Function: new
   // Constructor
   //
   // Parameters:
   // name - Instance name
   function new(string name="unnamed-uvm_text_record_database");
      super.new(name);
   endfunction : new

   // Group: Implementation Agnostic API

   // Function: do_initialize_stream
   // Initiailizes the state of the stream
   //
   protected virtual function void do_initialize_stream(uvm_record_database db,
                                                        uvm_component cntxt,
                                                        string stream_type_name);
      $cast(m_text_db, db);
   endfunction : do_initialize_stream

   // Function: do_begin_record
   // Marks the beginning of a new record in the stream
   //
   // Text-backend specific implementation.
   protected virtual function uvm_recorder do_begin_record(string name,
                                                           time   begin_time,
                                                           string type_name);
      if (m_text_db.open_db()) begin
         UVM_FILE file = m_text_db.m_file;
         uvm_text_recorder m_recorder;
         if (m_free_records.size() > 0) begin
            m_recorder = m_free_records.pop_front();
            m_recorder.set_name(name);
         end
         else
           m_recorder = new(name);
         
         m_recorder.initialize_recorder(this);
         $fdisplay(file, "BEGIN @%0t {TXH:%0d STREAM:%0d NAME:%s TIME:%0t TYPE=\"%0s\"}",
                   $time,
                   uvm_record_database::m_get_record_handle(m_recorder),
                   uvm_record_database::m_get_stream_handle(this),
                   name,
                   begin_time,
                   type_name);
         return m_recorder;
      end

      return null;
   endfunction : do_begin_record

   // Function: do_end_record
   // Marks the end of a record in the stream
   //
   // Text-backend specific implementation.
   protected virtual function void do_end_record(uvm_recorder record,
                                                 time end_time);
      if (m_text_db.open_db()) begin
         UVM_FILE file = m_text_db.m_file;
         $fdisplay(file, "END @%0t {TXH:%0d TIME=%0t}",
                   $time,
                   uvm_record_database::m_get_record_handle(record),
                   end_time);
         
      end
   endfunction : do_end_record

   // Function: do_free_record
   // Indicates the stream and database can free any references to the record.
   //
   // Text-backend specific implementation.
   protected virtual function void do_free_record(uvm_recorder record);
      if (m_text_db.open_db()) begin
         UVM_FILE file = m_text_db.m_file;
         $fdisplay(file, "FREE @%0t {TXH:%0d}",
                   $time,
                   uvm_record_database::m_get_record_handle(record));
      end
      // Arbitrary size, useful for example purposes
      if (m_free_records.size() < 8) begin
         uvm_text_recorder m_record;
         $cast(m_record, record);
         m_free_records.push_back(m_record);
      end
   endfunction : do_free_record

endclass : uvm_text_record_stream
