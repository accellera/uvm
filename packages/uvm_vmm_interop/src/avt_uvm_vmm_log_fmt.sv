//
// -------------------------------------------------------------
//    Copyright 2004-2009 Synopsys, Inc.
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


//
// Redirect VMM messages to UVM with the following mapping
//
//   VMM FATAL   --> UVM FATAL/NONE
//   VMM ERROR   --> UVM ERROR/LOW
//   VMM WARNING --> UVM WARNING/MEDIUM
//   default     --> UVM INFO/MEDIUM
//     TRACE_SEV             /HIGH
//     DEBUG_SEV             /FULL
//     VERBOSE_SEV           /DEBUG
//


class avt_uvm_vmm_log_fmt extends vmm_log_format;

`ifdef UVM_ON_TOP
   static local avt_uvm_vmm_log_fmt auto_register = new();
`endif

   local uvm_report_server svr;
   //OVM2UVM> local uvm_reporter client;
   local uvm_report_object client; //OVM2UVM>
   local vmm_log log;

   function new();
      uvm_report_global_server gs = new;
      this.svr    = gs.get_server();
      this.client = new("VMM->UVM Report Client");
      this.log    = new("VMM->UVM", "Redirector");
      void'(this.log.set_format(this));
      // Make sure all messages are issed on the UVM side
      this.client.set_report_verbosity_level(32'h7FFF_FFFF);
      // Let UVM abort after too many errors
      this.log.stop_after_n_errors(0);
   endfunction


   virtual function string format_msg(string name,
                                      string inst,
                                      string msg_typ,
                                      string severity,
`ifdef VMM_LOG_FORMAT_FILE_LINE
                                      string fname,
                                      int    line,
`endif
                                      ref string lines[$]);
`ifndef VMM_LOG_FORMAT_FILE_LINE
      string fname = "";
      int    line  = 0;
`endif
      uvm_severity uvm_sev;
      int uvm_verb;
      string msg;

      uvm_sev  = UVM_INFO;
      uvm_verb = UVM_MEDIUM;

      if (severity == this.log.sev_image(vmm_log::FATAL_SEV))
         uvm_verb = UVM_NONE;
      else if (severity == this.log.sev_image(vmm_log::ERROR_SEV))
         uvm_verb = UVM_LOW;
      else if (severity == this.log.sev_image(vmm_log::TRACE_SEV))
         uvm_verb = UVM_HIGH;
      else if (severity == this.log.sev_image(vmm_log::DEBUG_SEV))
         uvm_sev = UVM_FULL;
      else if (severity == this.log.sev_image(vmm_log::VERBOSE_SEV))
         uvm_sev = UVM_DEBUG;

      if (msg_typ == this.log.typ_image(vmm_log::FAILURE_TYP)) begin
         case (uvm_verb)
            UVM_NONE:   uvm_sev = UVM_FATAL;
            UVM_LOW:    uvm_sev = UVM_ERROR;
            UVM_MEDIUM: uvm_sev = UVM_WARNING;
         endcase
      end

      if (lines.size() > 0) begin
         int i = 1;
         msg = lines[0];
         while (i < lines.size()) begin
            msg = {msg, "\n", lines[i]};
         end
      end

      this.svr.report(uvm_sev, name, inst, msg, uvm_verb,
                      fname, line, this.client);

      return "";
   endfunction: format_msg
   

   virtual function string continue_msg(string name,
                                        string inst,
                                        string msg_typ,
                                        string severity,
`ifdef VMM_LOG_FORMAT_FILE_LINE
                                        string fname,
                                        int    line,
`endif
                                        ref string lines[$]);
      return this.format_msg(name, inst, msg_typ, severity,
`ifdef VMM_LOG_FORMAT_FILE_LINE
                             fname, line,
`endif
                             lines);
   endfunction: continue_msg
endclass
