//
//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
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
//----------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// Class - uvm_process
//
//------------------------------------------------------------------------------
// Workaround container for process construct.

class uvm_process;

  protected process m_process_id;  

  function new(process pid);
    m_process_id = pid;
  endfunction

  function process self();
    return m_process_id;
  endfunction

  virtual function void kill();
    m_process_id.kill();
  endfunction

`ifdef UVM_USE_FPC
  virtual function process::state status();
    return m_process_id.status();
  endfunction

  task await();
    m_process_id.await();
  endtask

  task suspend();
   m_process_id.suspend();
  endtask

  function void resume();
   m_process_id.resume();
  endfunction
`else
  virtual function int status();
    return m_process_id.status();
  endfunction
`endif

endclass

