// $Id: //dvt/vtech/dev/main/uvm/cookbook/09_modules/tb_sv/tb_responder.svh#2 $
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

class hfpb_slave #(int DATA_SIZE=8, int ADDR_SIZE=16)
  //OVM2UVM> extends uvm_threaded_component;
  extends uvm_component;
  

  uvm_slave_export #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE),
                     hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
        slave_export;

  local uvm_tlm_transport_channel #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE),
                                hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
        m_transport_channel;

  local hfpb_vif #(DATA_SIZE, ADDR_SIZE) vif;
  local virtual hfpb_if #(DATA_SIZE, ADDR_SIZE) m_bus_if;

  local hfpb_transaction #(DATA_SIZE, ADDR_SIZE) m_req;
  local hfpb_transaction #(DATA_SIZE, ADDR_SIZE) m_rsp;
  local int unsigned id;

  function new( string name, uvm_component parent, int unsigned _id = 0 );
    super.new( name, parent );
    id = _id;
  endfunction

  function void build();

    uvm_object dummy;

    vif = null;
    if(!get_config_object("hfpb_vif", dummy, 0)) begin
      // get config_object is specifed to NOT do a clone
      uvm_report_error("build", "no virtual interface available");
    end
    else begin
      if(!$cast(vif, dummy)) begin
        uvm_report_error("build", "virtual interface is incorrect type");
      end
      else begin
        m_bus_if = vif.m_bus_if;
      end
    end
    m_transport_channel = new("transport_channel", this);
    slave_export = new("slave_export", this);
  endfunction

  function void connect();
    slave_export.connect(m_transport_channel.slave_export);
  endfunction

  task run();

    // Used to decode bus control signals
    localparam INACTIVE = 2'b00;
    localparam START    = 2'b10;
    localparam ACTIVE   = 2'b11;
    localparam ERROR    = 2'b01;

    string s_trans_str;
  
    // Evaluate cycle accurate bus controls for protocol

    forever begin
      @( posedge m_bus_if.slave.clk );

      if (m_bus_if.rst) continue;
    
      case( {m_bus_if.slave.sel[id], m_bus_if.slave.en} )

        INACTIVE : begin
        end // INACTIVE
  
        START : begin

          m_req = new();

          if (m_bus_if.slave.write)
            m_req.set_write();
          else
            m_req.set_read();
          m_req.set_wdata(m_bus_if.slave.wdata);
          m_req.set_addr(m_bus_if.slave.addr);
          m_req.set_slave_id(id);

          m_transport_channel.transport(m_req, m_rsp);

          if(!m_bus_if.slave.write)
            m_bus_if.slave.rdata = m_rsp.get_rdata();

        end // START

        ACTIVE : begin
        end // ACTIVE

      endcase

    end 

  endtask

endclass
