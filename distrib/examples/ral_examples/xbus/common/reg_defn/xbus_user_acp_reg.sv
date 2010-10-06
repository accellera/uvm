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

//
// The user_acp_reg has a user-defined behavior
//
// It increments by 1 after every write
//
class xbus_user_acp_reg_cb extends uvm_ral_reg_cbs;

   local uvm_ral_data_t m_data;

   virtual task pre_write(uvm_ral_reg         rg,
                          ref uvm_ral_data_t  wdat,
                          ref uvm_ral::path_e path,
                          ref uvm_ral_map     map);
      uvm_ral_data_t data;

      // Predict the value that will be in the register
      this.m_data = rg.get() + 1;
      
      // If a backdoor write is used, replace the value written
      // with the incremented value to emulate the front-door
      if (path == uvm_ral::BACKDOOR) begin
         wdat = this.m_data;
      end
   endtask: pre_write

   virtual task post_write(uvm_ral_reg            rg,
                           uvm_ral_data_t         wdat,
                           uvm_ral::path_e        path,
                           uvm_ral_map            map,
                           ref uvm_ral::status_e  status);
      void'(rg.predict(this.m_data));
   endtask: post_write

endclass
