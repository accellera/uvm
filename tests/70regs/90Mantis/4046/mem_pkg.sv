`ifndef __MEM_PKG_SV__
`define __MEM_PKG_SV__


package mem_pkg;
   `include "uvm_macros.svh"
   import uvm_pkg::*;

   // List of includes for the package
   `include "mem_transfer.sv"
   `include "mem_adapter.sv"

   `include "mem_driver.sv"   
   `include "mem_sequencer.sv"
   `include "mem_agent.sv"

   `include "mem_registers.sv"
   
   `include "mem_env.sv"

   `include "mem_sequences.sv"
endpackage // mem_pkg
   
   
`endif // __MEM_PKG_SV__
