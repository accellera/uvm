//------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
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
//------------------------------------------------------------

// TITLE: UVM Register Backdoor SystemVerilog support routines.
// These routines provide an interface to the DPI/PLI
// implementation of backdoor access used by registers.
//
// Default is backward compatible -- NO DPI Backdoor.
// If you are not using backdoor access, there is nothing
// you need to do.
//
// If you want to use the DPI Backdoor API, then compile your
// SystemVerilog code with the vlog switch
//:   vlog ... +define+UVM_BACKDOOR_DPI ...
//
// If you DON'T want UVM_BACKDOOR_DPI, you don't have
//   to define anything.
//
// If you always want UVM_BACKDOOR_DPI, then in this file,
//  you can add a line like to avoid having to supply
//  the vlog compile-time switch. Uncomment the following
//  line to have UVM_BACKDOOR_DPI on by default.
//:    `define UVM_BACKDOOR_DPI
//

// The define UVM_BACKDOOR_DPI_OFF, allows you to turn OFF
//  the UVM_BACKDOOR_DPI define.
//  Use *+define+UVM_BACKDOOR_DPI_OFF* on the compile line
//  to make sure the C API is not called. This should
//  normally *not* be used.


`ifndef UVM_HDL_MAX_WIDTH
`define UVM_HDL_MAX_WIDTH 1024
`endif

/* 
 * VARIABLE: UVM_HDL_MAX_WIDTH
 * This parameter will be looked up by the 
 * DPI-C code using:
 *   vpi_handle_by_name(
 *     "uvm_pkg::UVM_HDL_MAX_WIDTH", 0);
 */
parameter int UVM_HDL_MAX_WIDTH = `UVM_HDL_MAX_WIDTH;

`ifndef UVM_NO_BACKDOOR_DPI
  // Defining UVM_BACKDOOR_DPI means that a C implmentation will
  // be called. You MUST have a compiled DPI-C callable routine.


  // Function: uvm_hdl_check_path
  //
  // Checks that the given HDL ~path~ exists. Returns 0 if found, 1 otherwise.
  //
  import "DPI-C" function int uvm_hdl_check_path(string path);


  // Function: uvm_hdl_deposit
  //
  // Sets the given HDL ~path~ to the specified ~value~.
  // Returns 1 if the call succeeded, 0 otherwise.
  //
  import "DPI-C" function int uvm_hdl_deposit(string path, logic[UVM_HDL_MAX_WIDTH-1:0] value);


  // Function: uvm_hdl_force
  //
  // Forces the ~value~ on the given ~path~. Returns 1 if the call succeeded, 0 otherwise.
  //
  import "DPI-C" function int uvm_hdl_force(string path, logic[UVM_HDL_MAX_WIDTH-1:0] value);


  // Function: uvm_hdl_force_time
  //
  // Forces the ~value~ on the given ~path~ for the specified amount of ~force_time~.
  // If ~force_time~ is 0, <uvm_hdl_deposit> is called.
  // Returns 1 if the call succeeded, 0 otherwise.
  //
  task uvm_hdl_force_time(string path, logic[UVM_HDL_MAX_WIDTH-1:0] value, time force_time=0);
    if (force_time == 0) begin
      void'(uvm_hdl_deposit(path, value));
      return;
    end
    if (!uvm_hdl_force(path, value))
      return;
    #force_time;
    void'(uvm_hdl_release(path,value));
  endtask


  // Function: uvm_hdl_release
  //
  // Releases a value previously set with <uvm_hdl_force>. The value at the given path ~after~
  // the release is provided in ~value~. Returns 1 if the call succeeded, 0 otherwise.
  //
  import "DPI-C" function int uvm_hdl_release(string path, output logic[UVM_HDL_MAX_WIDTH-1:0] value);


  // Function: uvm_hdl_read()
  //
  // Gets the value at the given ~path~.
  // Returns 1 if the call succeeded, 0 otherwise.
  //
  import "DPI-C" function int uvm_hdl_read(string path, output logic[UVM_HDL_MAX_WIDTH-1:0] value);

`else

  function int uvm_hdl_check_path(string path);
    uvm_report_fatal("UVM_HDL_CHECK_PATH", 
      $psprintf("%m: Backdoor routines are compiled off. Recompile without +define+UVM_NO_BACKDOOR_DPI"));
    return 0;
  endfunction

  function int uvm_hdl_deposit(string path, logic[UVM_HDL_MAX_WIDTH-1:0] value);
    uvm_report_fatal("UVM_HDL_DEPOSIT", 
      $psprintf("%m: Backdoor routines are compiled off. Recompile without +define+UVM_NO_BACKDOOR_DPI"));
    return 0;
  endfunction

  function int uvm_hdl_force(string path, logic[UVM_HDL_MAX_WIDTH-1:0] value);
    uvm_report_fatal("UVM_HDL_FORCE", 
      $psprintf("%m: Backdoor routines are compiled off. Recompile without +define+UVM_NO_BACKDOOR_DPI"));
    return 0;
  endfunction

  task uvm_hdl_force_time(string path, logic[UVM_HDL_MAX_WIDTH-1:0] value, time force_time=0);
    uvm_report_fatal("UVM_HDL_FORCE_TIME", 
      $psprintf("%m: Backdoor routines are compiled off. Recompile without +define+UVM_NO_BACKDOOR_DPI"));
  endtask

  function int uvm_hdl_release(string path, output logic[UVM_HDL_MAX_WIDTH-1:0] value);
    uvm_report_fatal("UVM_HDL_RELEASE", 
      $psprintf("%m: Backdoor routines are compiled off. Recompile without +define+UVM_NO_BACKDOOR_DPI"));
    return 0;
  endfunction

  function int uvm_hdl_read(string path, output logic[UVM_HDL_MAX_WIDTH-1:0] value);
    uvm_report_fatal("UVM_HDL_READ", 
      $psprintf("%m: Backdoor routines are compiled off. Recompile without +define+UVM_NO_BACKDOOR_DPI"));
    return 0;
  endfunction

`endif
