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


class user_acp_reg_seq extends uvm_reg_sequence;
  
  `uvm_object_utils(user_acp_reg_seq)    

  reg_sys_xa0 regmem;

  function new(string name="user_acp_reg_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e status;
    uvm_reg_mem_data_t data;
    uvm_reg acp;

    if (regmem == null && !$cast(regmem,super.regmem))
        `uvm_fatal("user_acp_reg_seq",
            {"Must specify register model of type 'reg_sys_xa0'",
             "by assigning member 'regmem' before starting sequence"})

    acp = regmem.xbus_rf.user_acp_reg;

    `ifdef UVM_OBJECTIONS_SVH
      // Raising one uvm_test_done objection
      uvm_test_done.raise_objection(this);
    `endif

    // Write user_acp_reg register 5 times
    repeat (5) acp.write(status, 'hfa, .parent(this));

    // Check that user_acp_reg mirror is equal to 5
    acp.mirror(status, UVM_CHECK, .parent(this));

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

  virtual task pre_do(bit is_item);
    `uvm_info("PRE_DO",$sformatf("%m called"),UVM_MEDIUM);
  endtask

  virtual function void mid_do(uvm_sequence_item this_item);
    `uvm_info("MID_DO",$sformatf("%m called with transaction type %s",this_item.get_type_name()),UVM_MEDIUM);
  endfunction

  virtual function void post_do(uvm_sequence_item this_item);
    `uvm_info("POST_DO",$sformatf("%m called with transaction type %s",this_item.get_type_name()),UVM_MEDIUM);
  endfunction


  bit toggle = 0;

  virtual function bit is_relevant();
    `uvm_info("IS_RELEVANT",$sformatf("%m called"),UVM_MEDIUM);
    is_relevant = toggle;
    if (toggle) toggle = 0;
  endfunction

  virtual task wait_for_relevant();
    toggle = 1;
    `uvm_info("WAIT_FOR_RELEVANT",$sformatf("%m called"),UVM_MEDIUM);
    #1;
  endtask


endclass : user_acp_reg_seq
