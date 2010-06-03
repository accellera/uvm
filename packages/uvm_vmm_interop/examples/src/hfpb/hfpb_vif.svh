// $Id: //dvt/vtech/dev/main/uvm/cookbook/09_modules/tb_tr_sv/tb_transaction.svh#1 $
//----------------------------------------------------------------------
//   Copyright 2005-2007 Mentor Graphics Corporation
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


//----------------------------------------------------------------------
// hfpb_vif
//
// Container for a virtual interface.  Set_config_object and
// get_config_object can be used to supply a virtual interface to
// components deep in the component hierarchy.
//----------------------------------------------------------------------
class hfpb_vif #(int DATA_SIZE=8, ADDR_SIZE=16) extends uvm_object;

  virtual hfpb_if #(DATA_SIZE, ADDR_SIZE) m_bus_if;

  function new( virtual hfpb_if #(DATA_SIZE, ADDR_SIZE) vif = null);
    m_bus_if = vif;
  endfunction
  
  
endclass
