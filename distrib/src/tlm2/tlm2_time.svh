//----------------------------------------------------------------------
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

// CLASS: uvm_tlm_time
// Canonical time type that can be used in different timescales
//
// This time type is used to represent time values in a canonical
// form that can bridge initiators and targets located in different
// timescales and time precisions.
//
class uvm_tlm_time;

   static local real m_resolution = 1.0e-12; // ps by default
   local real m_res;
   local time m_time;  // Number of 'm_res' time units,
   local string m_name;

   // Function: set_time_resolution
   // Set the default canonical time resolution.
   //
   // Must be a power of 10.
   // When co-simulating with SystemC, it is recommended
   // that default canonical time resolution be set to the
   // SystemC time resolution.
   //
   // By default, the default resolution is 1.0e-12 (ps)
   //
   static function void set_time_resolution(real res);
      // ToDo: Check that it is a power of 10
      m_resolution = res;
   endfunction

   // Function: new
   // Create a new canonical time value.
   //
   // The new value is initialized to 0.
   // If a resolution is not specified,
   // the default resolution,
   // as specified by <set_time_resolution()>,
   // is used.
   function new(string name = "uvm_tlm_time", real res = 0);
      m_name = name;
      m_res = (res == 0) ? m_resolution : res;
      reset();
   endfunction


   // Function: get_name
   // Return the name of this instance
   //
   function string get_name();
      return m_name;
   endfunction


   // Function: reset
   // Reset the value to 0
   function void reset();
      m_time = 0;
   endfunction
   

   // Scale a timescaled value to 'm_res' units
   local function real to_m_res(real t, time ns);
      // ToDo: Check resolution
      return t/real'(ns) * (1.0e-9/m_res);
   endfunction
   
   
   // Function: get_realtime
   // Return the current canonical time value,
   // scaled for the caller's timescale
   //
   // ~ns~ MUST be 1ns to specify the timescale of the
   // caller's scope.
   //
   //| #(delay.get_realtime(1ns));
   //
   function real get_realtime(time ns);
      return m_time*real'(ns) * m_res/1.0e-9;
   endfunction
   

   // Function: incr
   // Increment the time value by the specified number of scaled time unit
   //
   // ~t~ is a time value expressed in the scale
   // of the caller.
   // ~ns~ MUST be 1ns to specify the timescale of the
   // caller's scope.
   //
   //| delay.incr(1.5ns, 1ns);
   //
   function void incr(real t, time ns);
      if (t < 0.0) begin
         `uvm_error("UVM/TLM/TIMENEG", {"Cannot increment uvm_tlm_time variable ", m_name, " by a negative value"});
         return;
      end
      m_time += to_m_res(t, ns);
   endfunction


   // Function: decr
   // Decrement the time value by the specified number of scaled time unit
   //  
   // ~t~ is a time value expressed in the scale
   // of the caller.
   // ~ns~ MUST be 1ns to specify the timescale of the
   // caller's scope.
   //
   //| delay.decr(200ps, 1ns);
   //
   function void decr(real t, time ns);
      if (t < 0.0) begin
         `uvm_error("UVM/TLM/TIMENEG", {"Cannot decrement uvm_tlm_time variable ", m_name, " by a negative value"});
         return;
      end
      
      m_time -= to_m_res(t, ns);

      if (m_time < 0.0) begin
         `uvm_error("UVM/TLM/TOODECR", {"Cannot decrement uvm_tlm_time variable ", m_name, " to a negative value"});
         reset();
      end
   endfunction
endclass
