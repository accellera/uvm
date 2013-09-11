//
//----------------------------------------------------------------------
//   Copyright 2013 Freescale Semiconductor, Inc.
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

`ifndef UVM_ALLOCATOR_DPI_SVH
`define UVM_ALLOCATOR_DPI_SVH

`ifndef UVM_ALLOC_NO_DPI

import "DPI-C" function void svdpi_get_taken_list(string name, int unsigned size, inout longint db[]);
import "DPI-C" function void svdpi_set_taken_list(string name, int unsigned size, longint db[]);
import "DPI-C" function int unsigned  svdpi_get_num_taken(string name);
import "DPI-C" task svdpi_lock_taken_list(string name);
import "DPI-C" function bit svdpi_try_lock_taken_list(string name);
import "DPI-C" function void svdpi_unlock_taken_list(string name);
  
`else
  
function void svdpi_get_taken_list(string name, int unsigned size, inout longint db[]);
  uvm_report_fatal("SVDPI", 
                   "uvm_item_allocator DPI routines are compiled off. Recompile without +define+UVM_ALLOC_NO_DPI");
endfunction

function void svdpi_set_taken_list(string name, int unsigned size, longint db[]);
  uvm_report_fatal("SVDPI", 
                   "uvm_item_allocator DPI routines are compiled off. Recompile without +define+UVM_ALLOC_NO_DPI");
endfunction

function int unsigned  svdpi_get_num_taken(string name);
  uvm_report_fatal("SVDPI", 
                   "uvm_item_allocator DPI routines are compiled off. Recompile without +define+UVM_ALLOC_NO_DPI");
  return 0;
endfunction 
  
task svdpi_lock_taken_list(string name);
  uvm_report_fatal("SVDPI", 
                   "uvm_item_allocator DPI routines are compiled off. Recompile without +define+UVM_ALLOC_NO_DPI");
endtask 
  
function bit svdpi_try_lock_taken_list(string name);
  uvm_report_fatal("SVDPI", 
                   "uvm_item_allocator DPI routines are compiled off. Recompile without +define+UVM_ALLOC_NO_DPI");
  return 0;
endfunction 
  
function void svdpi_unlock_taken_list(string name);
  uvm_report_fatal("SVDPI", 
                   "uvm_item_allocator DPI routines are compiled off. Recompile without +define+UVM_ALLOC_NO_DPI");
endfunction
`endif  // ifndef UVM_ALLOC_NO_DPI

`endif // ifndef UVM_ALLOCATOR_DPI_SVH
