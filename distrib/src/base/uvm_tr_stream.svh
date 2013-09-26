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
// File: Transaction Recording Streams
//

// class- m_uvm_tr_stream_init
// Undocumented helper class for storing stream
// initialization values.
class m_uvm_tr_stream_init;
   uvm_tr_database db;
   uvm_component cntxt;
   string stream_type_name;
endclass : m_uvm_tr_stream_init

typedef class uvm_set_before_get_dap;
typedef class uvm_text_recorder;
   
//------------------------------------------------------------------------------
//
// CLASS: uvm_tr_stream
//
// The ~uvm_tr_stream~ base class is a representation of a stream of records
// within a <uvm_tr_database>.
//
// The record stream is intended to hide the underlying database implementation
// from the end user, as these details are often vendor or tool-specific.
//
// The ~uvm_tr_stream~ class is pure virtual, and must be extended with an
// implementation.  A default text-based implementation is provided via the
// <uvm_text_tr_stream> class.
//
virtual class uvm_tr_stream extends uvm_object;

   // Variable- m_init_dap
   // Data access protected reference to the DB
   local uvm_set_before_get_dap#(m_uvm_tr_stream_init) m_init_dap;

   // Variable- m_open_records
   // Used for tracking records between the open..closed state
   time m_open_records[uvm_tr_recorder];

   // Variable- m_closed_records
   // Used for tracking records between the closed..free state
   time m_closed_records[uvm_tr_recorder];

   // Function: new
   // Constructor
   //
   // Parameters:
   // name - Stream instance name
   function new(string name="unnamed-uvm_tr_stream");
      super.new(name);
      m_init_dap = new("init_dap");
   endfunction : new

   // Group: Stream API
   //
   // Transactions within a ~uvm_tr_stream~ follow a protocol similar to a folder,
   // in that the user can "Open" and "Close" a record.  
   //
   // Due to the fact that many database implementations will require crossing 
   // a language boundary, an additional step of "Freeing" the transaction is required.
   //
   // It is legal to add attributes to a record any time between "Open" and "Close",
   // however it is illegal to add attributes after "Close".
   //
   // A ~link~ can be established within the database any time between "Open" and
   // "Free", however it is illegal to establish a link after "Freeing" the record.
   //
   
   // Function: get_db
   // Returns a reference to the database which contains this
   // stream.
   //
   // An error will be asserted if get_db is called prior to
   // the stream being initialized via <initialize_stream>.
   function uvm_tr_database get_db();
      m_uvm_tr_stream_init m_init;
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
      m_uvm_tr_stream_init m_init;
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
      m_uvm_tr_stream_init m_init;
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
   function void initialize_stream(uvm_tr_database db,
                                   uvm_component cntxt=null,
                                   string stream_type_name="");
      
      m_uvm_tr_stream_init m_init;
      uvm_tr_database m_db;
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
   
   // Function: open_tr
   // Marks the opening of a new transaction in the stream.
   //
   // Parameters:
   // name - A name for the new transaction
   // open_time - Optional time to record as the opening of this transaction
   // type_name - Optional type name for the transaction
   //
   // If ~open_time~ is omitted (or set to '0'), then the stream will use
   // the current time.
   //
   // This method will trigger a <do_open_tr> call.
   function uvm_tr_recorder open_tr(string name,
                                      time   open_time = 0,
                                      string type_name="");
      time m_time = (open_time == 0) ? $time : open_time;
      open_tr = do_open_tr(name,
                                     m_time,
                                     type_name);
      m_open_records[open_tr] = m_time;
   endfunction : open_tr

   // Function: close_tr
   // Marks the closing of a transaction in the stream.
   //
   // Parameters:
   // tr - The transaction recorder which is closing
   // close_time - Optional time to record as the closing of this transaction.
   //
   // If ~close_time~ is omitted (or set to '0'), then the stream will use
   // the current time.
   //
   // An error will be asserted if:
   // - ~tr~ is ~null~
   // - ~tr~ has already ended
   // - ~tr~ was not generated by this stream
   // - the ~close_time~ is prior to the ~open_time~
   //
   // This method will trigger a <do_close_tr> call.
   function void close_tr(uvm_tr_recorder tr,
                            time close_time = 0);
      time m_time = (close_time == 0) ? $time : close_time;
      if (tr == null) begin
         `uvm_error("UVM/REC_STR/END_NULL",
                    $sformatf("illegal '<null>' recorder passed to close_tr on '%s'",
                              get_name()))
         return;
      end
      else if (m_closed_records.exists(tr)) begin
         `uvm_error("UVM/REC_STR/END_AGAIN",
                    $sformatf("illegal attempt to re-end tr '%s' on '%s'",
                              tr.get_name(),
                              get_name()))
         return;
      end
      else if (!m_open_records.exists(tr)) begin
         `uvm_error("UVM/REC_STR/END_INV",
                    $sformatf("illegal attempt to end invalid tr '%s' on '%s'",
                              tr.get_name(),
                              get_name()))
         return;
      end
      else if (m_time < m_open_records[tr]) begin
         `uvm_error("UVM/REC_STR/END_B4_BEGIN",
                    $sformatf("illegal attempt to end tr '%s' on '%s' at time %0t, which is before the begin time %0t",
                              tr.get_name(),
                              get_name(),
                              m_time,
                              m_open_records[tr]))
      end
      m_open_records.delete(tr);
      m_closed_records[tr] = m_time;
      do_close_tr(tr, m_time);
   endfunction : close_tr

   // Function: free_tr
   // Indicates the stream and database can free any references to the record.
   //
   // Parameters:
   // tr - The transaction recorder which is being freed
   // close_time - Optional time to record as the ending of this record
   //
   // If a record has not yet ended (via a call to <close_tr>), then the
   // record will be explicitly ended via the call to ~free_tr~.  If
   // this is the case, <close_tr> will be called automatically.
   //
   // If the record has already ended, then the second parameter to ~free_tr~
   // will be ignored.
   //
   // This method will trigger a call to <uvm_tr_recorder::free_tr>, followed by
   // a call to <do_free_tr>.
   //
   // An error will be asserted if:
   // - ~record~ is null
   // - ~record~ has already been freed
   // - ~record~ was not generated by this stream
   function void free_tr(uvm_tr_recorder record,
                             time close_time = 0);
      if (record == null) begin
         `uvm_error("UVM/REC_STR/END_NULL",
                    $sformatf("illegal '<null>' recorder passed to free_tr on '%s'",
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
         close_tr(record, close_time);
      end

      m_closed_records.delete(record);

      record.free_recorder();
      
      do_free_tr(record);

   endfunction : free_tr

   // Group: Implementation Agnostic API
   //

   // Function: do_initialize_stream
   // Initializes the state of the stream
   //
   // Backend implementation of <initialize_stream>
   protected pure virtual function void do_initialize_stream(uvm_tr_database db,
                                                             uvm_component cntxt,
                                                             string stream_type_name);

   // Function: do_open_tr
   // Marks the beginning of a new record in the stream.
   //
   // Backend implementation of <open_tr>
   protected pure virtual function uvm_tr_recorder do_open_tr(string name,
                                                                time   open_time,
                                                                string type_name);

   // Function: do_close_tr
   // Marks the end of a record in the stream
   //
   // Backend implementation of <close_tr>
   protected pure virtual function void do_close_tr(uvm_tr_recorder record,
                                                      time close_time);

   // Function: do_free_tr
   // Indicates the stream and database can free any references to the record.
   //
   // Backend implementation of <free_tr>.
   //
   // Note that unlike the <free_tr> method, ~do_free_tr~ does not
   // have the optional ~close_time~ argument.  The argument will be processed
   // by <free_tr> prior to the ~do_free_tr~ call.
   protected pure virtual function void do_free_tr(uvm_tr_recorder record);


   // THE FOLLOWING CODE IS PRESENT FOR BACKWARDS COMPATIBILITY PURPOSES
   // ONLY.  IT IS NOT DOCUMENTED, AND SHOULD NOT BE USED BY END USERS

   // Variable- m_ids_by_stream
   // An associative array of integers, indexed by uvm_tr_streams.  This
   // provides a unique 'id' or 'handle' for each stream, which can be
   // used to identify the stream.
   //
   // By default, neither ~m_ids_by_stream~ or ~m_streams_by_id~ are
   // used.  Streams are only placed in the arrays when the user
   // attempts to determine the id for a stream.
   local static integer m_ids_by_stream[uvm_tr_stream];

   // Variable- m_streams_by_id
   // A corollary to ~m_ids_by_stream~, this indexes the streams by their
   // unique ids.
   local static uvm_tr_stream m_streams_by_id[integer];

   // Variable- m_id
   // Static int marking the last assigned id.
   local static integer m_id;

   // Function- m_get_id_from_stream
   // Returns a "unique id" for the given stream.
   //
   // 0 indicates "null" stream
   static function integer m_get_id_from_stream(uvm_tr_stream stream);
      if (stream == null)
        return 0;

      if (!m_ids_by_stream.exists(stream)) begin
         m_streams_by_id[++m_id] = stream;
         m_ids_by_stream[stream] = m_id;
      end

      return m_id;
   endfunction : m_get_id_from_stream

   // Function- m_get_stream_from_id
   // Returns a stream reference for a given unique id.
   //
   // If no stream exists with a given id, then ~null~
   // is returned.
   static function uvm_tr_stream m_get_stream_from_id(integer id);
      if (id == 0)
        return null;

      if (!m_streams_by_id.exists(id))
        return null;

      return m_streams_by_id[id];
   endfunction : m_get_stream_from_id
        
   
endclass : uvm_tr_stream

//------------------------------------------------------------------------------
//
// CLASS: uvm_text_tr_stream
//
// The ~uvm_text_tr_stream~ is the default stream implementation for the
// <uvm_text_tr_database>.  
//
//                     

class uvm_text_tr_stream extends uvm_tr_stream;

   // Variable- m_text_db
   // Internal reference to the text-based backend
   local uvm_text_tr_database m_text_db;
   
   // Variable- m_free_trs
   // Used for memory savings
   static uvm_text_recorder m_free_trs[$];

   `uvm_object_utils_begin(uvm_text_tr_stream)
   `uvm_object_utils_end

   // Function: new
   // Constructor
   //
   // Parameters:
   // name - Instance name
   function new(string name="unnamed-uvm_text_tr_database");
      super.new(name);
   endfunction : new

   // Group: Implementation Agnostic API

   // Function: do_initialize_stream
   // Initiailizes the state of the stream
   //
   protected virtual function void do_initialize_stream(uvm_tr_database db,
                                                        uvm_component cntxt,
                                                        string stream_type_name);
      $cast(m_text_db, db);
   endfunction : do_initialize_stream

   // Function: do_open_tr
   // Marks the beginning of a new record in the stream
   //
   // Text-backend specific implementation.
   protected virtual function uvm_tr_recorder do_open_tr(string name,
                                                           time   open_time,
                                                           string type_name);
      if (m_text_db.open_db()) begin
         UVM_FILE file = m_text_db.m_file;
         uvm_text_recorder m_recorder;
         if (m_free_trs.size() > 0) begin
            m_recorder = m_free_trs.pop_front();
            m_recorder.set_name(name);
         end
         else
           m_recorder = new(name);
         
         m_recorder.initialize_recorder(this);
         $fdisplay(file, "BEGIN @%0t {TXH:%0d STREAM:%0d NAME:%s TIME:%0t TYPE=\"%0s\"}",
                   $time,
                   uvm_tr_recorder::m_get_id_from_recorder(m_recorder),
                   uvm_tr_stream::m_get_id_from_stream(this),
                   name,
                   open_time,
                   type_name);
         return m_recorder;
      end

      return null;
   endfunction : do_open_tr

   // Function: do_close_tr
   // Marks the end of a record in the stream
   //
   // Text-backend specific implementation.
   protected virtual function void do_close_tr(uvm_tr_recorder record,
                                                 time close_time);
      if (m_text_db.open_db()) begin
         UVM_FILE file = m_text_db.m_file;
         $fdisplay(file, "END @%0t {TXH:%0d TIME=%0t}",
                   $time,
                   uvm_tr_recorder::m_get_id_from_recorder(record),
                   close_time);
         
      end
   endfunction : do_close_tr

   // Function: do_free_tr
   // Indicates the stream and database can free any references to the record.
   //
   // Text-backend specific implementation.
   protected virtual function void do_free_tr(uvm_tr_recorder record);
      if (m_text_db.open_db()) begin
         UVM_FILE file = m_text_db.m_file;
         $fdisplay(file, "FREE @%0t {TXH:%0d}",
                   $time,
                   uvm_tr_recorder::m_get_id_from_recorder(record));
      end
      // Arbitrary size, useful for example purposes
      if (m_free_trs.size() < 8) begin
         uvm_text_recorder m_record;
         $cast(m_record, record);
         m_free_trs.push_back(m_record);
      end
   endfunction : do_free_tr

endclass : uvm_text_tr_stream
