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

class hfpb_monitor #(int DATA_SIZE=8, int ADDR_SIZE=16)
  //OVM2UVM> extends uvm_threaded_component;
  extends uvm_component;
  
  uvm_analysis_port #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
        analysis_port;

  local virtual hfpb_if #(DATA_SIZE, ADDR_SIZE) m_bus_if;

  local hfpb_transaction #(DATA_SIZE, ADDR_SIZE) m_trans;
  local int unsigned id;

  function new( string name, uvm_component parent);
    super.new( name, parent );
  endfunction

  function void build();

    hfpb_vif #(DATA_SIZE, ADDR_SIZE) vif;
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

    analysis_port = new("analysis_port", this);

  endfunction

  task run();

    // Used to decode bus control signals
    localparam INACTIVE = 2'b00;
    localparam START    = 2'b10;
    localparam ACTIVE   = 2'b11;
    localparam ERROR    = 2'b01;

    forever begin
      @( posedge m_bus_if.monitor.clk );
      #0; // make sure monitor runs last

      if (m_bus_if.rst) continue;
    
      case( { (m_bus_if.monitor.sel != 0), m_bus_if.monitor.en} )

        INACTIVE : begin
        end
  
        START : begin

          id = 0;
          for(id = 0; id < 8; id++)
           if(m_bus_if.monitor.sel[id])
             break;
          if(id >= 8)
            id = 7;

          m_trans = new();

          m_trans.set_addr(m_bus_if.monitor.addr);
          m_trans.set_wdata(m_bus_if.monitor.wdata);
          m_trans.set_slave_id(id);

          if (!m_bus_if.monitor.write)
            continue;

          m_trans.set_write();
          analysis_port.write(m_trans);

        end

        ACTIVE : begin
          if (m_bus_if.monitor.write)
            continue;

          m_trans.set_read();
          m_trans.set_rdata(m_bus_if.monitor.rdata);
          analysis_port.write(m_trans);
        end

      endcase

    end 

  endtask

endclass
