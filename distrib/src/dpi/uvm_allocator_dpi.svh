`ifndef UVM_ALLOC_NO_DPI

import "DPI-C" function void svdpi_get_taken_list(string name, int size, inout longint db[]);
import "DPI-C" function void svdpi_set_taken_list(string name, int size, longint db[]);
import "DPI-C" function int  svdpi_get_num_taken(string name);
import "DPI-C" task svdpi_lock_taken_list(string name);
import "DPI-C" function bit svdpi_try_lock_taken_list(string name);
import "DPI-C" function void svdpi_unlock_taken_list(string name);
  
`else
  
function void svdpi_get_taken_list(string name, int size, inout longint db[]);
  uvm_report_fatal("SVDPI", 
                   "uvm_item_allocator DPI routines are compiled off. Recompile without +define+UVM_ALLOC_NO_DPI");
endfunction
function void svdpi_set_taken_list(string name, int size, longint db[]);
  uvm_report_fatal("SVDPI", 
                   "uvm_item_allocator DPI routines are compiled off. Recompile without +define+UVM_ALLOC_NO_DPI");
endfunction
function int  svdpi_get_num_taken(string name);
  uvm_report_fatal("SVDPI", 
                   "uvm_item_allocator DPI routines are compiled off. Recompile without +define+UVM_ALLOC_NO_DPI");
  return 0;
endfunction
`endif

   