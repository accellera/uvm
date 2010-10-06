//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
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


class user_acp_reg_seq extends uvm_ral_sequence;
  
  `uvm_object_utils(user_acp_reg_seq)    

  ral_sys_xa0 ral;

  function new(string name="user_acp_reg_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_ral::status_e status;
    uvm_ral_data_t data;
    uvm_ral_reg acp;

    if (ral == null && !$cast(ral,super.ral))
        `uvm_fatal("user_acp_reg_seq",
            {"Must specify register model of type 'ral_sys_xa0'",
             "by assigning member 'ral' before starting sequence"})

    acp = ral.xbus_rf.user_acp_reg;

    /*
    begin
    xbus_user_acp_reg_cb cb = new;
    uvm_callbacks#(ral_reg_xa0_xbus_rf_user_acp_reg, uvm_ral_reg_cbs)::add(ral.xbus_rf.user_acp_reg, cb);
    end
    */


    `ifdef UVM_OBJECTIONS_SVH
      // Raising one uvm_test_done objection
      uvm_test_done.raise_objection(this);
    `endif

    // Write user_acp_reg register 5 times
    repeat (5) acp.write(status, 'hfa, .parent(this));

    // Check that user_acp_reg mirror is equal to 5
    acp.mirror(status, uvm_ral::CHECK, .parent(this));

    // Check that user_acp_reg is equal to 5
    acp.read(status, data, .parent(this));

    if(data=='h5)
      uvm_report_info(get_type_name(), 
        $psprintf("%s 'user_acp_reg' returned correct value", get_full_name()),
        UVM_MEDIUM);
    else
      uvm_report_error(get_type_name(), 
        $psprintf("%s 'user_acp_reg' returned incorrect value. Exp='h%0x, returned=%0x", 
                  get_sequence_path(), 5, data, UVM_NONE));

    `ifdef UVM_OBJECTIONS_SVH
      // Dropping the objection
      uvm_test_done.drop_objection(this);
    `endif
  endtask

endclass : user_acp_reg_seq
