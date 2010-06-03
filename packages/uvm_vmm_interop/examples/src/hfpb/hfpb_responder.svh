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
// hfpb_responder
//----------------------------------------------------------------------
class hfpb_responder #(int DATA_SIZE=8, int ADDR_SIZE=16)
  extends uvm_component;

  uvm_slave_port #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE),
                     hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
        slave_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    slave_port = new("slave_port", this);
  endfunction

  task run();

    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) m_req;
    hfpb_transaction #(DATA_SIZE, ADDR_SIZE) m_rsp;

    forever begin
      slave_port.get(m_req);
      uvm_report_info("RESPONDER req", m_req.convert2string());
      assert($cast(m_rsp, m_req.clone()));
      if(m_rsp.is_read()) begin
        m_rsp.set_rdata($random % 'h100);
      end
      uvm_report_info("RESPONDER rsp", m_rsp.convert2string());
      slave_port.put(m_rsp);
    end
  endtask

endclass
