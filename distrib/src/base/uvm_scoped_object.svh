//
//-----------------------------------------------------------------------------
//   Copyright 2012 Synopsys, Inc.
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


typedef class uvm_report_object;


//------------------------------------------------------------------------------
//
// CLASS: uvm_scoped_object
//
// The uvm_scoped_object class is a <uvm_object> with an optional context object.
// Its primary role is to provide objects with hierarchical contexts and naming.
// A scoped object can only find its context object.
// If an object must be able to find the object within the context it creates,
// use <uvm_tree> instead.
//
//------------------------------------------------------------------------------

virtual class uvm_scoped_object extends uvm_object;


  // Function: new
  //
  // Creates a new uvm_scoped_object with the given instance ~name~ and ~ctxt~.
  // If ~ctxt~ is not supplied, the object does not have a context.
  // All classes extended from this base class must have a similar constructor.

  extern function new (string name, uvm_object ctxt = null);

  // Function: set_context
  //
  // Sets the context instance of this object, overwriting any previously
  // given context.
  // If ~ctxt~ is specified as ~null~, the object no longer has a context.
  // Returns TRUE if the settign was succesful, FALSE otherwise.

  extern virtual function bit set_context (uvm_object ctxt);


  // Function: get_context
  //
  // Returns the context of the object, as provided by the ~ctxt~ argument in the
  // <new> constructor or <set_context> method.

  extern virtual function uvm_object get_context ();


  // Function: get_full_name
  //
  // Returns the full hierarchical name of this object.
  // A hierarchical name is composed by prefixing the full hierarchical name
  // of the object's context with the name of this object, seperated with a '.' (dot).
  // A hierarchical name stops when no context is present or when the context
  // is <uvm_root>.

  extern virtual function string get_full_name ();


  // Function: is_context
  //
  // Returns TRUE if the specified object is a context for this object,
  // within the specified maximum number of levels
  // (e.g. 0 means an immediate context).

  extern function bit is_context(uvm_object obj, int max_lvl = -1);


  //----------------------------------------------------------------------------
  // Group- Reporting
  // Documented in uvm_report_object
  //----------------------------------------------------------------------------

  virtual function void uvm_report_info( string id,
                                         string message,
                                         int verbosity = UVM_MEDIUM,
                                         string filename = "",
                                         int line = 0);
     uvm_report_object rpt = m_get_report_object();
     rpt.uvm_report_info(id, message, verbosity, filename, line);
  endfunction

  virtual function void uvm_report_warning( string id,
                                            string message,
                                            int verbosity = UVM_NONE,
                                            string filename = "",
                                            int line = 0);
     uvm_report_object rpt = m_get_report_object();
     rpt.uvm_report_warning(id, message, verbosity, filename, line);
  endfunction

  virtual function void uvm_report_error( string id,
                                          string message,
                                          int verbosity = UVM_NONE,
                                          string filename = "",
                                          int line = 0);
     uvm_report_object rpt = m_get_report_object();
     rpt.uvm_report_error(id, message, verbosity, filename, line);
  endfunction

  virtual function void uvm_report_fatal( string id,
                                          string message,
                                          int verbosity = UVM_NONE,
                                          string filename = "",
                                          int line = 0);
     uvm_report_object rpt = m_get_report_object();
     rpt.uvm_report_fatal(id, message, verbosity, filename, line);
  endfunction


  // Function: create_scoped_object
  //
  // The create_scoped_object method allocates a new object of the same type as this object
  // and returns it via a base uvm_scoped_object handle. Every class deriving from
  // uvm_scoped_object, directly or indirectly, must implement the create_scoped method.
  // This method is automatically implemented when the <`uvm_scoped_object_utils> macro is used.
  //
  // A typical implementation is as follows:
  //
  //|  class mytype extends uvm_scoped_object;
  //|    ...
  //|    virtual function uvm_scoped_object create_scoped_object(string name="", uvm_object ctxt=null);
  //|      mytype t = new(name, ctxt);
  //|      return t;
  //|    endfunction 

  virtual function uvm_object create_scoped_object (string name="", uvm_object ctxt=null);
     return null;
  endfunction


  //---------------------------------------------------------------------------
  //                 **** Internal Methods and Properties ***
  //                           Do not use directly
  //---------------------------------------------------------------------------

  local uvm_object m_context;
  extern protected virtual function uvm_report_object m_get_report_object();

endclass


//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

// new
// ---

function uvm_scoped_object::new (string name, uvm_object ctxt=null);
   super.new(name);
   void'(set_context(ctxt));
endfunction


// set_context
// --------

function bit uvm_scoped_object::set_context (uvm_object ctxt);
   uvm_object c = ctxt;
   while (c != null) begin
      if (c == this) begin
         `uvm_error("UVM/CTXT/CYC", {"Cannot set context of ", get_full_name(), " to ",
                                     ctxt.get_full_name(), " because it creates a context cycle"})
         return 0;
      end

      c = c.get_context();
   end
          
   m_context = ctxt;
   return 1;
endfunction


// get_context
// --------

function uvm_object uvm_scoped_object::get_context ();
  return m_context;
endfunction


// get_full_name
// -------------

function string uvm_scoped_object::get_full_name ();
   if (m_context != null && m_context != uvm_root::get())
      return {m_context.get_full_name(), ".", get_name()};

  return get_name();
endfunction


// is_context
// ----------
function bit uvm_scoped_object::is_context(uvm_object obj, int max_lvl = -1);
   uvm_object o;
   
   if (obj == this) return 0;

   o = this;
   while (max_lvl-- >= 0) begin
      o = o.get_context();
      if (o == null) return 0;
      if (obj == o) return 1;
   end

   return 0;
endfunction


// m_get_report_object
// -------------------

function uvm_report_object uvm_scoped_object::m_get_report_object();
   if (m_context != null)
      return m_context.m_get_report_object();
   
   return super.m_get_report_object();
endfunction
