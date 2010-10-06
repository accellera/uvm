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

typedef class ral_sys_xa0;


// The reg_indirect_reg[0..7] registers are accessed indirectly
// by putting their index value in 'addr_reg' then accessing
// them through 'data_reg'.

class xbus_indirect_reg_ftdr_seq extends uvm_ral_reg_frontdoor;
   local ral_sys_xa0 m_am;
   local int         m_idx;
   
   function new(ral_sys_xa0 am, int idx);
      super.new("xbus_indirect_reg_ftdr_seq");
      m_am  = am;
      m_idx = idx;
   endfunction: new

   virtual task body();

      m_am.xbus_rf.addr_reg.write(status, m_idx, uvm_ral::DEFAULT, null, this, prior, extension, fname, lineno);

      if (status != uvm_ral::IS_OK)
         return;

      if (is_write)
         m_am.xbus_rf.data_reg.write(status, data, uvm_ral::DEFAULT, null, this, prior, extension, fname, lineno);
      else
         m_am.xbus_rf.data_reg.read(status, data, uvm_ral::DEFAULT, null, this, prior, extension, fname, lineno);

   endtask

endclass
