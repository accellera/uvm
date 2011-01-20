`ifndef UVM_GRAPH_SVH
`define UVM_GRAPH_SVH
//------------------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc. 
//   Copyright 2010 Synopsys, Inc.
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
//------------------------------------------------------------------------------


//----------------------------------------------------------------------
// Class: uvm_graph
//----------------------------------------------------------------------
//
// This is a generic data structure class implementing a DAG (Directed Acyclic Graph).
// It has no dependencies on any other UVM class and can be used wherever required.
// Structure is node-oriented - each instance is a node connected to others to form the graph
//
// TBD insert DAG descriptive text from concept doc
//
// (see uvm_graph_example_dag.gif)

class uvm_graph extends uvm_object;

  // graph structure
  protected string m_name;
  /*protected*/ uvm_graph m_predecessors[$];
  protected uvm_graph m_successors[$];

  //----------------------------------------------------------------------
  // Group: graph creation
  //----------------------------------------------------------------------
  // These methods are called in order to construct or manipulate the graph
  // The hookup between nodes can be specified in new(), and/or done later using
  // the insert methods to adjust the graph, add links, or merge graphs together

  // Function: new
  // Create a new graph node and optionally link it up to others to make a graph
  //   name         - name of this graph node, user specified, free format, not interpreted
  //   predeceessor - optionally hookup the new node after this existing node
  //   successor    - optionally hookup the new node before this exiting node
  
  extern function new(string name="anon",
                      uvm_graph predecessor=null,
                      uvm_graph successor=null );

  // Function: set_name
  // set a string node name. name is not interpreted. Only for use by extending class

  protected function void set_name(string name); m_name = name; endfunction

  // Function: get_name
  // return string node name

  function string get_name(); return m_name; endfunction

  // Function: insert
  // Hookup this already-created node as part of a graph
  //   predeceessor - hook up after this existing node
  //   successor    - hook up before this existing node

  extern function void insert(uvm_graph predecessor,
                              uvm_graph successor = null);

  // Function: insert_predecessor
  // Link this node after an existing predeccessor node
  //   predeceessor - hook up after this existing node
  
  extern function void insert_predecessor(uvm_graph predecessor);

  // Function: insert_successor
  // Link this node before an existing successor node
  //   successor - hook up before this existing node

  extern function void insert_successor(uvm_graph successor);


  //----------------------------------------------------------------------
  // Group: graph search and traversal
  //----------------------------------------------------------------------
  // These user methods allow lookup, search of named nodes, and iteration

  // Function: find
  // Traverse all predecessor/successor nodes until matching named node is found.
  //   name - the exact string node name to locate
  //   return - handle of matching node, or null if no match was found

  extern function uvm_graph find(string name);

  // Function: find_predecessor
  // Traverse all predecessor nodes until matching named node is found.
  //   name - the exact string node name to locate
  //   return - handle of matching node, or null if no match was found

  extern function uvm_graph find_predecessor(string name);

  // Function: find_successor
  // Traverse all successor nodes until matching named node is found.
  //   name - the exact string node name to locate
  //   return - handle of matching node, or null if no match was found
  
  extern function uvm_graph find_successor(string name);

  // Function: compare
  // virtual comparison function for override by extenders to add functionality
  //   name - string name to match with node name
  
  extern virtual function int compare(string name);

  //----------------------------------------------------------------------
  // Group: graph debug
  //----------------------------------------------------------------------

  // Function: print
  // print the phase DAG using a depth-first traversal
  
  extern function void print();

  // Function: print_dot
  // print the phase DAG using a depth-first traversal into dot file format
  
  extern function void print_dot(string file_name = "dag.dot");

  //----------------------------------------------------------------------
  // Implementation
  //----------------------------------------------------------------------
  // No user-accessible methods or members after this point

  // scratch traversal state storage for print/debug methods
  local bit m_mark;
  local int m_level;

  // accessors for traversal state
  extern protected function void set_mark();
  extern protected function void clr_mark();
  extern protected function bit is_marked();
  extern protected function void clr_marks();

  // debug
  extern function void bfs();
  extern local function void bfs_imp(ref uvm_graph q[$]);
  extern local function void visit_level(ref uvm_graph q[$]);
  extern local function void print_imp();
  extern virtual function string convert2string(); // extender can override
  extern virtual function string q2string(uvm_graph q[$]); // extender can override
  extern local function void print_imp_dot(int fd);

endclass


//----------------------------------------------------------------------
// Implementation - public and friend methods
//----------------------------------------------------------------------

function uvm_graph::new(string name = "anon",
                        uvm_graph predecessor = null,
                        uvm_graph successor = null);
  m_name = name;
  clr_mark();
  m_level = -1;
  insert(predecessor, successor);
endfunction

function void uvm_graph::insert(uvm_graph predecessor,
                                uvm_graph successor = null);
  if (predecessor == null) return;
  insert_predecessor(predecessor);
  insert_successor(successor);
endfunction

function void uvm_graph::insert_predecessor(uvm_graph predecessor);
  if (predecessor == null) return;
  m_predecessors.push_back(predecessor);
  predecessor.m_successors.push_back(this);
endfunction

function void uvm_graph::insert_successor(uvm_graph successor);
  if (successor == null) return;
  m_successors.push_back(successor);
  successor.m_predecessors.push_back(this);
endfunction

function uvm_graph uvm_graph::find_predecessor(string name);
  if (compare(name)) return this;
  foreach (m_predecessors[i]) begin
    uvm_graph found = m_predecessors[i].find_predecessor(name); // recurse
    if (found != null) return found;
  end
  return null; // not found
endfunction

function uvm_graph uvm_graph::find_successor(string name);
  if (compare(name)) return this;
  foreach (m_successors[i]) begin
    uvm_graph found = m_successors[i].find_successor(name); // recurse
    if (found != null) return found;
  end
  return null; // not found
endfunction

function uvm_graph uvm_graph::find(string name);
  if (compare(name)) return this;
  begin
    uvm_graph found = find_predecessor(name);
    if (found != null) return found;
  end
  begin
    uvm_graph found = find_successor(name);
    if (found != null) return found;
  end
  return null; // not found - TBD full search
endfunction

function int uvm_graph::compare(string name);
  return (m_name == name);
endfunction


//----------------------------------------------------------------------
// Implementation - debug/print methods
//----------------------------------------------------------------------

function void uvm_graph::print();
  clr_marks();
  $display("\n------------------------------------------------------------");
  $display("*** depth-first DAG traversal ***");
  print_imp();
  $display("------------------------------------------------------------\n");
endfunction

function void uvm_graph::print_dot(string file_name = "dag.dot");
  int unsigned fd = $fopen(file_name, "w");
  if (fd == 0)  begin
    $display({ "FATAL: uvm_graph::print_dot() : unable to open file: ", file_name });
    return;
  end
  clr_marks();
  // dot preamble
  $fdisplay(fd, "digraph hierarchy {");
  $fdisplay(fd, "  node [shape = ellipse, fontname = helvetica, penwidth = 2.0]");
  print_imp_dot(fd);
  // dot postamble
  $fdisplay(fd, "}");
  $fflush(fd);
  $fclose(fd);
endfunction


//----------------------------------------------------------------------
// Implementation - internal methods for debug/print
//----------------------------------------------------------------------

function void uvm_graph::set_mark(); m_mark = 1; endfunction
function void uvm_graph::clr_mark(); m_mark = 0; endfunction
function bit uvm_graph::is_marked(); return m_mark; endfunction

function void uvm_graph::clr_marks();
  clr_mark();
  foreach(m_successors[i]) begin
    uvm_graph n = m_successors[i];
    if(n.is_marked())
      n.clr_marks();
  end
endfunction

function void uvm_graph::bfs();
  uvm_graph q[$];
  this.m_level = 0;
  q.push_back(this);
  bfs_imp(q);
endfunction

function void uvm_graph::bfs_imp(ref uvm_graph q[$]);
  int level = 0;
  int prev_level = 0;
  uvm_graph level_q [$];
  clr_marks();
  while(q.size() > 0) begin
    uvm_graph n = q.pop_front();
    if(n.m_level != prev_level) begin
      prev_level = n.m_level;
      visit_level(level_q);
    end
    level_q.push_back(n);
    level = n.m_level + 1;
    foreach(n.m_successors[i]) begin
      uvm_graph m = n.m_successors[i];
      bit ok = 1;
      foreach (m.m_predecessors[i]) begin
        uvm_graph p = m.m_predecessors[i];
        ok &= (level > p.m_level)  && (p.m_level != -1);
      end
      if(!m.is_marked() && ok) begin
        m.m_level = level;
        m.set_mark();
        q.push_back(m);
      end
    end
  end
  if(level_q.size() > 0)
    visit_level(level_q);
endfunction

function void uvm_graph::visit_level(ref uvm_graph q[$]);
  $display("------");
  foreach(q[i]) begin
    uvm_graph n = q[i];
    $write("%s ", n.m_name);
  end
  $display();
  q = {};
endfunction

function void uvm_graph::print_imp();
  set_mark();
  $display(convert2string());
  foreach(m_successors[i]) begin
    uvm_graph n = m_successors[i];
    if(!n.is_marked())
      n.print_imp();
  end
endfunction

function string uvm_graph::convert2string();
  string s;
  s = $sformatf("node: %s [%0d]  pred %s  succ %s", m_name, m_level,
                q2string(m_predecessors),q2string(m_successors));
  return s;
endfunction

function string uvm_graph::q2string(uvm_graph q[$]);
  string s;
  s = "[ ";
  foreach (q[i]) begin
    uvm_graph n = q[i];
    s = $sformatf("%s%s ",s,(n == null) ? "null" : n.m_name);
   end
  s = $sformatf("%s]",s);
  return s;
endfunction

function void uvm_graph::print_imp_dot(int fd);
  set_mark();
  foreach (m_successors[i]) begin
    uvm_graph n = m_successors[i];
    $fdisplay(fd, "  \"%s\" -> \"%s\";", m_name, n.m_name );
  end
  foreach (m_successors[i]) begin
    uvm_graph n = m_successors[i];
    if (!n.is_marked())
      n.print_imp_dot(fd);
  end
endfunction


//----------------------------------------------------------------------
// End
//----------------------------------------------------------------------

`endif
