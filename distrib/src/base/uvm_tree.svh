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



//------------------------------------------------------------------------------
//
// CLASS: uvm_tree
//
// The uvm_tree class is a <uvm_scoped_object> with knowledge of the objects
// under the context it creates (aka branches).
// Its primary role is to provide objects with bi-directional hierarchical contexts.
//
// Networks of uvm_tree instances where a single member is referred to via a static
// variable (e.g. <uvm_root>) cannot be garbage-collected.
// This is not a problem for a network of <uvm_component> instances
// as they are designed to be static for the entire duration of the simulation.
// If (part of) a network of uvm_tree instances is dynamic in nature,
// make sure to set the context of its root instance to ~null~
// so it can be garbage-collected.
//
//------------------------------------------------------------------------------

virtual class uvm_tree extends uvm_report_object;


  // Function: new
  //
  // Creates a new uvm_tree with the given instance ~name~ and ~ctxt~.
  // If ~ctxt~ is not supplied, the tree does not have a context.
  // All classes extended from this base class must have a similar constructor.

  extern function new (string name, uvm_tree ctxt = null);

  // Function: set_name
  //
  // Set or rename this uvm_tree instance.

  extern function void set_name (string name);

  // Function: set_context
  //
  // Sets the context instance of this tree, overwriting any previously
  // given context.
  // If ~ctxt~ is specified as ~null~, the tree no longer has a context.
  // Returns TRUE if the setting was successful, FALSE otherwise.

  extern virtual function bit set_context (uvm_object ctxt);


  // Function: get_branches
  //
  // This function appends the list of this tree's branches to the ~branches~ array.
  //
  //|   uvm_tree branches[$];
  //|   my_tree.get_branches(branches);
  //|   foreach(branches[i]) 
  //|     do_something(branches[i]);

  extern function void get_branches(ref uvm_tree branches[$]);


  // Function: get_branch
  // Return the branch with the specified name, if it exists.
  // Returns ~null~ otherwise.

  extern function uvm_tree get_branch (string name);

  // Function: get_first_branch
  //
  // Find the name of the first branch and returns TRUE if one exists.
  // Returns FALSE otherwise.
  //
  // Together with <get_next_branch>, it is used to iterate through the branches of this tree.
  // For example, given a tree with an object handle, ~tree~, the
  // following code calls <uvm_object::print> for each branch:
  //
  //|    string name;
  //|    uvm_tree branch;
  //|    if (tree.get_first_branch(name))
  //|      do begin
  //|        branch = tree.get_branch(name);
  //|        branch.print();
  //|      end while (tree.get_next_branch(name));

  extern function int get_first_branch (ref string name);


  // Function: get_next_branch
  //
  // Find the name of the next branch and returns TRUE if one exists.
  // Returns FALSE otherwise.

  extern function int get_next_branch (ref string name);


  // Function: get_num_branches
  //
  // Returns the number of branches in this tree

  extern function int get_num_branches ();


  // Function: find_branch
  //
  // Looks for a branch with the given hierarchical ~name~ relative to this tree.
  // Returns the the branch found if any, or ~null~ otherwise.
  // The name is interpreted as-is, not as a pattern.

  extern function uvm_tree find_branch (string name);


  //---------------------------------------------------------------------------
  //                 **** Internal Methods and Properties ***
  //                           Do not use directly
  //---------------------------------------------------------------------------

  protected     uvm_tree m_branches_by_name[string];
  protected     uvm_tree m_branches_by_handle[uvm_tree];
  extern protected virtual function bit  m_add_branch(uvm_tree branch);
  extern protected virtual function void m_del_branch(uvm_tree branch);

  // overridden to disable
  extern virtual function uvm_object create (string name=""); 

endclass


//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

// new
// ---

function uvm_tree::new (string name, uvm_tree ctxt=null);
   super.new(name, ctxt);
endfunction


function void uvm_tree::set_name (string name);
   uvm_tree trunk;

   if (name == "") begin
      name.itoa(get_inst_id());
      name = {"TREE_", name};
   end

   void'($cast(trunk, get_context()));
   if (trunk != null) begin
      trunk.m_branches_by_name.delete(get_name());
      trunk.m_branches_by_name[name] = this;
   end
   
   super.set_name(name);
endfunction


// set_context
// --------

function bit uvm_tree::set_context (uvm_object ctxt);
   uvm_tree trunk;

   void'($cast(trunk, get_context()));
   if (trunk != null)
      trunk.m_del_branch(this);

   super.set_context(ctxt);

   if ($cast(trunk, ctxt) && trunk != null)
      return trunk.m_add_branch(this);

   return 1;
endfunction


function bit uvm_tree::m_add_branch(uvm_tree branch);
   if (m_branches_by_name.exists(branch.get_name())) begin
      `uvm_error("UVM/TREE/BR/DUP",
                 $sformatf("A branch with the name '%0s' of type '%0s' already exists.",
                           branch.get_name(), m_branches_by_name[branch.get_name()].get_type_name()))
      return 0;
   end

   m_branches_by_name[branch.get_name()] = branch;
   m_branches_by_handle[branch] = branch;

   return 1;
endfunction


function void uvm_tree::m_del_branch(uvm_tree branch);
   if (!m_branches_by_handle.exists(branch)) return;

   m_branches_by_name.delete(branch.get_name());
   m_branches_by_handle.delete(branch);
endfunction


function void uvm_tree::get_branches(ref uvm_tree branches[$]);
  foreach(m_branches_by_name[i]) 
     branches.push_back(m_branches_by_name[i]);
endfunction


function uvm_tree uvm_tree::get_branch (string name);
   if (m_branches_by_name.exists(name))
      return m_branches_by_name[name];

   return null;
endfunction


function int uvm_tree::get_first_branch (ref string name);
  return m_branches_by_name.first(name);
endfunction


function int uvm_tree::get_next_branch (ref string name);
  return m_branches_by_name.next(name);
endfunction


function int uvm_tree::get_num_branches ();
  return m_branches_by_name.num();
endfunction


function uvm_tree uvm_tree::find_branch (string name);
   int i,j;
   string br_name;
   uvm_tree br;

   // Ignore a starting '.'
   j = 0;
   if (name[j] == ".") j++;

   // Extract the first part of the name
   for(i = j; i < name.len(); i++) begin  
      if (name[i] == "." ) break;
   end
   br_name = name.substr(j, i-1);

   // Is this part of the hierarchical name found here?
   br = get_branch(name);
   if (br == null) return null;

   // Are we done?
   if (i == name.len()) return br;

   // Keep searching
   return br.find_branch(name.substr(i, name.len()-1));
endfunction
