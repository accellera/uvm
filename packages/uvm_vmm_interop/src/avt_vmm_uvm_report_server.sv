//
//    Copyright 2009 Synopsys, Inc.
//    Copyright 2009 Mentor Graphics Corporation
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
//


//
// Redirect UVM messages to VMM with the following mapping
//
//   UVM FATAL   --> VMM FATAL
//   UVM ERROR   --> VMM ERROR
//   UVM WARNING --> VMM WARNING
//   UVM INFO    --> VMM NOTE  if verbosity level <= UVM_MEDIUM
//                   VMM DEBUG if verbosity level > UVM_MEDIUM
//

class avt_vmm_uvm_report_server extends uvm_report_server;

   `ifdef VMM_ON_TOP
   static local avt_vmm_uvm_report_server me = get();
   `endif

   `VMM_LOG log;

   local int vmm_sev;

   static function avt_vmm_uvm_report_server get();
     uvm_report_global_server gs = new;
     get = new;
     gs.set_server(get);
   endfunction

   `_protected function new();
      super.new();
      this.log = new("UVM", "reporter");
      // Make sure all UVM messages are issued by default
      this.log.set_verbosity(vmm_log::VERBOSE_SEV);
      // Let VMM abort if too many errors
      this.set_max_quit_count(0);
   endfunction
   

   virtual function void report(uvm_severity      severity,
                                string            name,
                                string            id,
                                string            message,
                                int               verbosity_level,
                                string            filename,
                                int               line,
                                uvm_report_object client);

           if (verbosity_level <= UVM_NONE)   this.vmm_sev = vmm_log::NORMAL_SEV;
      else if (verbosity_level <= UVM_LOW)    this.vmm_sev = vmm_log::NORMAL_SEV;
      else if (verbosity_level <= UVM_MEDIUM) this.vmm_sev = vmm_log::NORMAL_SEV;
      else if (verbosity_level <= UVM_HIGH)   this.vmm_sev = vmm_log::TRACE_SEV;
      else if (verbosity_level <= UVM_FULL)   this.vmm_sev = vmm_log::DEBUG_SEV;
      else                                    this.vmm_sev = vmm_log::VERBOSE_SEV;

      super.report(severity, name, id, message, verbosity_level,
                   filename, line, client);
   endfunction


   virtual function void process_report(uvm_severity      severity,
                                        string            name,
                                        string            id,
                                        string            message,
                                        uvm_action        action,
                                        UVM_FILE          file,
                                        string            filename,
                                        int               line,
                                        string            composed_message,
                                        int               verbosity_level,
                                        uvm_report_object client);
      int typ;
      case (severity)
        UVM_INFO:    typ = vmm_log::NOTE_TYP;
        UVM_WARNING: typ = vmm_log::FAILURE_TYP;
        UVM_ERROR:   typ = vmm_log::FAILURE_TYP;
        UVM_FATAL:   typ = vmm_log::FAILURE_TYP;
      endcase
      case (severity)
        UVM_WARNING: this.vmm_sev = vmm_log::WARNING_SEV;
        UVM_ERROR:   this.vmm_sev = vmm_log::ERROR_SEV;
        UVM_FATAL:   this.vmm_sev = vmm_log::FATAL_SEV;
      endcase

      if (this.log.start_msg(typ, this.vmm_sev `ifdef VMM_LOG_FORMAT_FILE_LINE , filename, line `endif )) begin
         void'(this.log.text(composed_message));
         this.log.end_msg();
      end
   endfunction


   virtual function string compose_message(uvm_severity severity,
                                           string       name,
                                           string       id,
                                           string       message,
                                           string       filename,
                                           int          line);
      // Severity, time, filename and line number
      // will be provided by vmm_log
      $sformat(compose_message, "%s(%s): %s",
               name, id, message);
   endfunction
endclass
