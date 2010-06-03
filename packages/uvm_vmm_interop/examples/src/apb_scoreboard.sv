
//-----------------------------------------------------------------------------
//   Copyright 2009 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//-----------------------------------------------------------------------------
 
`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV
 
//-----------------------------------------------------------------------------
// CLASS: apb_scoreboard
//
// This UVM component accepts UVM transactions from its analysis export and VMM
// transactions from a vmm_channel passed in as a constructor argument. When a
// UVM/VMM transaction pair are received, the VMM transaction is converted and
// compared to the UVM transaction. The result is then displayed.
//-----------------------------------------------------------------------------
 
import uvm_pkg::*; 
`include "uvm_macros.svh"
 
class apb_scoreboard extends uvm_component;

  `uvm_component_utils(apb_scoreboard)
   
  uvm_tlm_analysis_fifo #(uvm_apb_rw) uvm_fifo;
  vmm_channel_typed #(vmm_apb_rw) vmm_fifo;
 
  uvm_analysis_export #(uvm_apb_rw) uvm_in;
 
  int m_matches     = 0;
  int m_mismatches  = 0;

  bit always_pull;
  
   // Function: new
   //
   // Creates a new instance of the ~apb_scoreboard~.  If the ~vmm_fifo~
   // argument is null, a default vmm_channel instance is created.

   function new(string name = "apb_scoreboard",
                uvm_component parent=null,
                vmm_channel_typed #(vmm_apb_rw) vmm_fifo = null,
                bit always_pull = 0);
     super.new(name,parent);
     uvm_fifo       = new("uvm_fifo",this);
     uvm_in         = new("uvm_in", this);
     if (vmm_fifo == null)
       vmm_fifo     = new("vmm_fifo",name);
     this.vmm_fifo  = vmm_fifo;
     vmm_fifo.tee_mode(1);
     this.always_pull  = always_pull;
   endfunction : new

  // Function- connect
  //
  // Connects the analysis export to the internal TLM fifo's analysis imp.

  virtual function void connect();
    uvm_in.connect(uvm_fifo.analysis_export);
  endfunction


  // Task: run
  //
  // Continually fetches UVM-VMM transaction pairs and compares them. The
  // UVM and VMM transaction streams come from independent sources.

  virtual task run();
    uvm_apb_rw o, v2o=new();
    vmm_apb_rw v;

    if(always_pull == 1)
      fork
        begin
          vmm_apb_rw v_tmp;
          forever begin
            vmm_fifo.get(v_tmp);
          end
        end
      join_none
          
    forever begin
      fork  //PH> Weihua's
	 begin
	    uvm_fifo.get(o);
	 end
	 begin
	    vmm_apb_rw v_t;
	    vmm_fifo.tee(v_t);
	    v = new v_t;
	 end	 
      join  //PH> ----------
      
      v2o = apb_rw_convert_vmm2uvm::convert(v);
      
      if(!o.compare(v2o)) begin
        uvm_report_error("mismatch",
                         {"UVM:\n", o.convert2string(),"\n",
                          "VMM:\n", v.psdisplay()});
        m_mismatches++;
      end
      else begin
        uvm_report_info("match",o.convert2string());
        m_matches++;
      end
    end
  endtask

  // Function: report
  //
  // Reports the number of matches and mismatches seen.
  
  virtual function void report();
    string match,mismatch;
    match.itoa(m_matches);
    mismatch.itoa(m_mismatches);
    uvm_report_info(get_full_name(),{"Scoreboard had ",match,
      " matches and ",mismatch," mismatches."});
  endfunction

  // Function: flush
  //
  // This method resets the match and mismatch counts and flushes
  // the internal transaction buffers.

  virtual function void flush();
    m_matches = 0;
    m_mismatches = 0;
    uvm_fifo.flush();
    vmm_fifo.flush();
  endfunction
   
endclass
 
`endif // SCOREBOARD_SV
