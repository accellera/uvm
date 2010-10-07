//
// -------------------------------------------------------------
//    Copyright 2010 Synopsys, Inc.
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


virtual class uvm_ral_regfile extends uvm_object;

   local uvm_ral_block     parent;
   local uvm_ral_regfile   m_rf;
   local string            default_hdl_path = "RTL";
   local uvm_object_string_pool #(uvm_queue #(string)) hdl_paths_pool;
   local string            attributes[string];
   local string            constr[$];


   //----------------------
   // Group: Initialization
   //----------------------

   extern function                  new        (string name="");

   extern virtual function void     configure  (uvm_ral_block blk_parent,
                                                uvm_ral_regfile rf_parent,
                                                string hdl_path = "");
 
   //--------------------------------
   // Group: Attributes & Constraints
   //--------------------------------

   extern virtual function void   set_attribute   (string name, string value);
   extern virtual function string get_attribute   (string name, bit inherited = 1);
   extern virtual function void   get_attributes  (ref string names[string],
                                                   input bit inherited = 1);
   extern virtual function void   get_constraints (ref string names[]);
   /*local*/ extern function void Xadd_constraintsX(string name);


   //-----------
   // Group: Get
   //-----------

   extern virtual function uvm_ral_block    get_block       ();
   extern virtual function uvm_ral_regfile  get_regfile     ();


   //----------------
   // Group: Backdoor
   //----------------

   extern function void clear_hdl_path    (string kind = "RTL");
   extern function void add_hdl_path      (string path, string kind = "RTL");
   extern function bit  has_hdl_path      (string kind = "");
   extern function void get_hdl_path      (ref string paths[$], input string kind = "");
   extern function void get_full_hdl_path (ref string paths[$], input string kind = "");

   extern function void   set_default_hdl_path (string kind);
   extern function string get_default_hdl_path ();


   //--------------------
   // Group: Standard Ops
   //--------------------

   extern virtual function string        get_full_name();
   extern virtual function uvm_ral_block get_parent ();
   extern virtual function void          do_print (uvm_printer printer);
   extern virtual function string        convert2string();
   extern virtual function uvm_object    clone      ();
   extern virtual function void          do_copy    (uvm_object rhs);
   extern virtual function bit           do_compare (uvm_object  rhs,
                                                     uvm_comparer comparer);
   extern virtual function void          do_pack    (uvm_packer packer);
   extern virtual function void          do_unpack  (uvm_packer packer);

endclass: uvm_ral_regfile


//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

// new

function uvm_ral_regfile::new(string name="");
   super.new(name);
   hdl_paths_pool = new("hdl_paths");
endfunction: new


// configure

function void uvm_ral_regfile::configure(uvm_ral_block blk_parent, uvm_ral_regfile rf_parent, string hdl_path = "");
   this.parent = parent;
   this.m_rf = rf_parent;
   if (hdl_path != "")
     this.add_hdl_path(hdl_path);
endfunction: configure


//-----------
// ATTRIBUTES
//-----------

// set_attribute

function void uvm_ral_regfile::set_attribute(string name,
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

function string uvm_ral_regfile::get_attribute(string name,
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

function void uvm_ral_regfile::get_attributes(ref string names[string],
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

function void uvm_ral_regfile::Xadd_constraintsX(string name);

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

function void uvm_ral_regfile::get_constraints(ref string names[]);
   names = new [this.constr.size()] (this.constr);
endfunction: get_constraints



// get_block

function uvm_ral_block uvm_ral_regfile::get_block();
   get_block = this.parent;
endfunction: get_block


// get_regfile

function uvm_ral_regfile uvm_ral_regfile::get_regfile();
   return m_rf;
endfunction


// clear_hdl_path

function void uvm_ral_regfile::clear_hdl_path(string kind = "RTL");
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

function void uvm_ral_regfile::add_hdl_path(string path, string kind = "RTL");

  uvm_queue #(string) paths;

  paths = hdl_paths_pool.get(kind);

  paths.push_back(path);

endfunction


// has_hdl_path

function bit  uvm_ral_regfile::has_hdl_path(string kind = "");
  if (kind == "") begin
     if (m_rf != null)
        kind = m_rf.get_default_hdl_path();
     else
        kind = parent.get_default_hdl_path();
  end
  
  return hdl_paths_pool.exists(kind);
endfunction


// get_hdl_path

function void uvm_ral_regfile::get_hdl_path(ref string paths[$], input string kind = "");

  uvm_queue #(string) hdl_paths;

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

  for (int i=0; i<hdl_paths.size();i++)
    paths.push_back(hdl_paths.get(i));

endfunction


// get_full_hdl_path

function void uvm_ral_regfile::get_full_hdl_path(ref string paths[$], input string kind = "");
   if (kind == "")
      kind = get_default_hdl_path();

   if (!has_hdl_path(kind)) begin
      `uvm_error("RAL",{"Register file does not have hdl path defined for abstraction '",kind,"'"})
      return;
   end
   
   paths.delete();

   begin
      uvm_queue #(string) hdl_paths = hdl_paths_pool.get(kind);
      string parent_paths[$];

      if (m_rf != null)
         m_rf.get_full_hdl_path(parent_paths,kind);
      else if (parent != null)
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

function string uvm_ral_regfile::get_default_hdl_path();
  if (default_hdl_path == "") begin
     if (m_rf != null)
        return m_rf.get_default_hdl_path();
     else
        return parent.get_default_hdl_path();
  end
  return default_hdl_path;
endfunction


// set_default_hdl_path

function void uvm_ral_regfile::set_default_hdl_path(string kind);

  if (kind == "") begin
    if (m_rf != null)
       kind = m_rf.get_default_hdl_path();
    else if (parent == null)
       kind = parent.get_default_hdl_path();
    else begin
      `uvm_error("RAL",{"Register file has no parent. ",
           "Must specify a valid HDL abstraction (kind)"})
      return;
    end
  end

  if (!has_hdl_path(kind)) begin
    `uvm_error("RAL",{"Register file does not have hdl path defined for abstraction '",kind,"'"})
    return;
  end

  default_hdl_path = kind;

endfunction


// get_parent

function uvm_ral_block uvm_ral_regfile::get_parent();
  return get_block();
endfunction


// get_full_name

function string uvm_ral_regfile::get_full_name();
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


//-------------
// STANDARD OPS
//-------------

// convert2string

function string uvm_ral_regfile::convert2string();
  `uvm_fatal("RAL","RAL register files cannot be converted to strings")
   return "";
endfunction: convert2string


// do_print

function void uvm_ral_regfile::do_print (uvm_printer printer);
  super.do_print(printer);
endfunction



// clone

function uvm_object uvm_ral_regfile::clone();
  `uvm_fatal("RAL","RAL register files cannot be cloned")
  return null;
endfunction

// do_copy

function void uvm_ral_regfile::do_copy(uvm_object rhs);
  `uvm_fatal("RAL","RAL register files cannot be copied")
endfunction


// do_compare

function bit uvm_ral_regfile::do_compare (uvm_object  rhs,
                                        uvm_comparer comparer);
  `uvm_warning("RAL","RAL register files cannot be compared")
  return 0;
endfunction


// do_pack

function void uvm_ral_regfile::do_pack (uvm_packer packer);
  `uvm_warning("RAL","RAL register files cannot be packed")
endfunction


// do_unpack

function void uvm_ral_regfile::do_unpack (uvm_packer packer);
  `uvm_warning("RAL","RAL register files cannot be unpacked")
endfunction


