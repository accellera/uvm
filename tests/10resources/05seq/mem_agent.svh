//----------------------------------------------------------------------
//   Copyright 2010-2011 Mentor Graphics Corporation
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

//----------------------------------------------------------------------
// mem_agent_config
//
// object for configuring the mem agent.
//----------------------------------------------------------------------
class mem_agent_config;

  // initial sequnce is the sequnce to be started by the agent.  It's
  // much easier to supply a sequnce through the resources facility than
  // to try to use the default sequence mumbo jumbo on the sequencer.
  uvm_object_wrapper initial_sequence;

  // If has_talker is set then we instantiate and connect the talker.
  // Otherwise, not.
  bit has_talker;

  function new();

    // establish default values for all the items in the configuration
    // object.

    initial_sequence = null;
    has_talker = 0;

  endfunction


endclass  

//----------------------------------------------------------------------
// mem_driver
//----------------------------------------------------------------------
class mem_driver #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
  extends uvm_driver #(mem_seq_item #(ADDR_SIZE, DATA_SIZE));

  typedef mem_driver #(ADDR_SIZE, DATA_SIZE) this_type;
  typedef virtual mem_if #(ADDR_SIZE, DATA_SIZE) if_t;
  `uvm_component_param_utils(this_type)

  local if_t m_if;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    // retrieve virtual interface from the resources database
    if(!uvm_resource_db#(if_t)::read_by_type(get_full_name(), m_if, this))
      uvm_report_error("build", "no bus interface available");
  endfunction

  task run();

    mem_seq_item #(ADDR_SIZE, DATA_SIZE) req;
    mem_seq_item #(ADDR_SIZE, DATA_SIZE) rsp;

    forever begin
      @(posedge m_if.clk);

      seq_item_port.try_next_item(req);
      if(req == null)
        continue;

      uvm_report_info("req", req.convert2string());

      rsp = new();
      rsp.set_id_info(req);
      rsp.addr = req.addr;
      rsp.op = req.op;

      case(req.op)
        MEM_READ:
          begin
            m_if.addr <= req.addr;
            m_if.rw <= 0;
          end

        MEM_WRITE:
          begin
            m_if.addr <= req.addr;
            m_if.data <= req.data;
            m_if.rw <= 1;
          end

      endcase

      m_if.start <= 1;
      while(m_if.ready != 1)
        @(posedge m_if.clk);
      m_if.start <= 0;

      if(req.op == MEM_READ)
        rsp.data = m_if.data;

      uvm_report_info("rsp", rsp.convert2string());

      seq_item_port.item_done();
      seq_item_port.put_response(rsp);
    end

  endtask

endclass

//----------------------------------------------------------------------
// monitor
//----------------------------------------------------------------------
class mem_monitor #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
   extends uvm_component;

  typedef mem_monitor #(ADDR_SIZE, DATA_SIZE) this_type;
  typedef virtual mem_if #(ADDR_SIZE, DATA_SIZE) if_t;
  `uvm_component_param_utils(this_type)

  uvm_analysis_port #(mem_seq_item #(ADDR_SIZE, DATA_SIZE)) ap;

  local if_t m_if;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();
    ap = new("ap", this);
    // retrieve virtual interface from the resources database
    if(!uvm_resource_db#(if_t)::read_by_type(get_full_name(), m_if, this))
      uvm_report_error("build", "no bus interface available");
  endfunction

  task run();

    mem_seq_item #(ADDR_SIZE, DATA_SIZE) item;

    forever begin
      @(negedge m_if.clk);
      item = new();
      item.addr = m_if.addr;
      @(negedge m_if.clk);
      item.data = m_if.data;
      if(m_if.rw == 1)
        item.op = MEM_WRITE;
      else
        item.op = MEM_READ;
      ap.write(item);      
    end

  endtask

endclass

//----------------------------------------------------------------------
// mem_talker
//
// Print all the transactions as they pass by.  This is not something
// you would want to do all the time.  However, it is a handy tool for
// debugging.
//----------------------------------------------------------------------
class mem_talker #(int unsigned ADDR_SIZE=16, int unsigned DATA_SIZE=8)
  extends uvm_subscriber #(mem_seq_item #(ADDR_SIZE, DATA_SIZE));

  typedef mem_talker #(ADDR_SIZE, DATA_SIZE) this_type;
  `uvm_component_param_utils(this_type)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void write (mem_seq_item #(ADDR_SIZE, DATA_SIZE) t);
    `uvm_info("talker", t.convert2string(), UVM_MEDIUM);
  endfunction

endclass

//----------------------------------------------------------------------
// mem_agent
//----------------------------------------------------------------------
class mem_agent #(type CONFIG=int,
                  int unsigned ADDR_SIZE=16,
                  int unsigned DATA_SIZE=8)
  extends uvm_component;

  typedef mem_agent#(CONFIG) this_type;
  `uvm_component_param_utils(this_type)

  local mem_driver #(ADDR_SIZE, DATA_SIZE) drv;
  local mem_monitor #(ADDR_SIZE, DATA_SIZE) mon;
  local mem_talker #(ADDR_SIZE, DATA_SIZE) tlk;
  local uvm_sequencer #(mem_seq_item #(ADDR_SIZE, DATA_SIZE)) sqr;

  local uvm_sequence_base m_initial_sequence;

  CONFIG cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build();

    // retrieve the config object
    if(!uvm_resource_db#(CONFIG)::read_by_type(get_full_name(), cfg, this)) begin
      `uvm_warning("build", "no config object available, creating a default one");
      cfg = new(); // create default configuration object
    end

    if(cfg.initial_sequence != null) begin
      // Is the thing we pulled from the configuration database
      // really a sequence?
      if(!$cast(m_initial_sequence, cfg.initial_sequence.create_object("initial_seq")))
        `uvm_error("run",
                   "unable to find an initial sequence of the correct type");
    end

    drv = new("drv", this);
    mon = new("mon", this);
    sqr = new("sqr", this);

    if(cfg.has_talker)
      tlk = new("tlk", this);

  endfunction

  function void connect();
    drv.seq_item_port.connect(sqr.seq_item_export);

    if(cfg.has_talker)
      mon.ap.connect(tlk.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    if(m_initial_sequence != null)
      m_initial_sequence.start(sqr);
    phase.drop_objection(this);
  endtask

endclass
