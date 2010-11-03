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

typedef class reg_sys_xa0;


// The reg_indirect_reg[0..7] registers are accessed indirectly
// by putting their index value in 'addr_reg' then accessing
// them through 'data_reg'.

class xbus_indirect_reg_ftdr_seq extends uvm_reg_frontdoor;
   local reg_sys_xa0 m_am;
   local int         m_idx;
   
   function new(reg_sys_xa0 am, int idx);
      super.new("xbus_indirect_reg_ftdr_seq");
      m_am  = am;
      m_idx = idx;
   endfunction: new

   virtual task body();

      uvm_reg_item rw;
      
      $cast(rw,rw_info.clone());
      rw.element = m_am.xbus_rf.addr_reg;
      rw.kind    = UVM_WRITE;
      rw.value[0]= m_idx;

      m_am.xbus_rf.addr_reg.do_write(rw);

      if (rw.status == UVM_NOT_OK)
        return;

      $cast(rw,rw_info.clone());
      rw.element = m_am.xbus_rf.data_reg;

      if (rw_info.kind == UVM_WRITE)
        m_am.xbus_rf.data_reg.do_write(rw);
      else begin
        m_am.xbus_rf.data_reg.do_read(rw);
        rw_info.value[0] = rw.value[0];
      end

      rw_info.status = rw.status;
      /*
      m_am.xbus_rf.addr_reg.write(rw.status, m_idx, UVM_DEFAULT_PATH, null,
                                  rw_info.parent, rw_info.prior, rw_info.extension,
                                  rw_info.fname, rw_info.lineno);

      if (status != UVM_IS_OK)
         return;

      if (is_write)
         m_am.xbus_rf.data_reg.write(rw_info.status, rw_info.value, UVM_DEFAULT_PATH, null,
                                     rw_info.parent, rw_info.prior, rw_info.extension,
                                     rw_info.fname, rw_info.lineno);
      else
         m_am.xbus_rf.data_reg.read (rw_info.status, rw_info.value, UVM_DEFAULT_PATH, null,
                                     rw_info.parent, rw_info.prior, rw_info.extension,
                                     rw_info.fname, rw_info.lineno);
         */

   endtask

endclass
