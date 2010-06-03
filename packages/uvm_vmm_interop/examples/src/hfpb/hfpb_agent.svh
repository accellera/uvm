//----------------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
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
// hfpb_agent
//
// This is a highly configurable, reusable component that contains all
// the necessary elements to build testbench for a DUT with an hfpb
// interface.
//
// The interfaces to the agent are:
//
//  * transport_export: for sending hfpb transaction request and
//    retrieving responses.
//
//  * seq_item_port: for connenting to an external sequencer.
//
//  * slave_export[]: for connecting slaves.
//
//  * analysis_port: for obtaining the stream of transactions issued by
//    the monitor.
//
//  * vif: Virtual interface for connecting pins
//
//  * sequencer: The internal sequencer can be used to execute hfpb
//    sequences.  It's public (not local) so it can be accessed
//    externally.
//
// This device has a number of config parameters that can be set to
// configure it for various modes of operation.  These include
//
//    has_monitor: turns on/off the monitor
//    has_coverage: turns on/off coverage collector
//    has_talker: turn on/off talker
//    has_master: turns on/off the master
//    has_driver: turns on/off the driver
//    has_sequencer: turns on/off the sequencer
//    slaves: set to the number of slaves
//
// Note: has master and has driver are mutually exclusive.  An error
// will appear if both are turned on.  The device can be set to accept
// sequence items from a sequencer or transactions from a transaction
// generator, but not both simultaneously.
//
// Modes of operation
// ------------------
//
// Monitor:
//    has_monitor = 1
//    has_coverage = don't care
//    has_talker = don't care
//    has_master = 0
//    has_driver = 0
//    has_sequencer = 0
//    slaves = 0
//
//    Runs passively as a monitor.  The virtual interface must be
//    connected. A transaction stream will be available on the analysis
//    port.
//
// Master:
//    has_monitor = don't care
//    has_coverage = don't care 
//    has_talker = don't care
//    has_master = 1
//    has_driver = 0
//    has_sequencer = 0
//    slaves = 0
//
//    The transport_port and master will be instantiated and connected.
//    The master will convert hfpb request transaction to pin activity
//    and listen to the pins to form a response.  Requests and responses
//    are tightly synchronized which is why we are using the transport
//    interface.
//
// Driver:
//    has_monitor = don't care
//    has_coverage = don't care
//    has_talker = don't care
//    has_master = 0
//    has_driver = 1
//    has_sequencer = 0
//    slaves = 0
//  
//   The driver is instantiated and the internal sequencer is turned
//   OFF. The seq_item_port is instantiated and connected.  The driver
//   expects to receive sequence items from an external sequencer.
//
// Sequencer:
//    has_monitor = don't care
//    has_coverage = don't care
//    has_talker = don't care
//    has_master = 0
//    has_driver = 1
//    has_sequencer = 1
//    slaves = 0
//
//    If you turn on has_sequencer, has_driver will be turned on for
//    you. You needn't turn them both on manually.  That is,
//    has_sequencer implies that a driver must be present.  In this mode
//    the internal sequencer is turned on and you access it directly.
//
// In Monitor, Master, Driver, and Sequencer modes, you can set slaves
// to 0 or to a number greater than 0.  If you set it to zero then no
// slaves will be created and the device will drive transaction (or
// sequence items) to the bus.  If you set slaves to a number greater
// than zero then that number of slaves will be created.  Those slaves
// listen to the pin level bus and respond accordingly.
//
// In Master, Driver, and Sequencer modes if has_monitor is set then the
// monitor will be activated and a stream of transactions will appear on
// the analysis port (assuming that the virtual interface is also
// connected).
//
// The function dump_config_status() will dump out the current
// configuration of the agent.
//
// See the hfpb_master, hfpb_slave, hfpb_monitor, hfpb_responder for
// more information on these components.
//
//----------------------------------------------------------------------
// begin codeblock header
class hfpb_agent #(int DATA_SIZE=8, ADDR_SIZE=16)
  extends uvm_agent;
// end codeblock header

  // external connections
// begin codeblock interfaces
  virtual hfpb_if #(DATA_SIZE, ADDR_SIZE) m_bus_if;

  uvm_transport_export
    #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE),
      hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
        transport_export;

  uvm_seq_item_pull_port
    #(hfpb_seq_item#(DATA_SIZE, ADDR_SIZE),
      hfpb_seq_item#(DATA_SIZE, ADDR_SIZE))
        seq_item_port;

  uvm_slave_export
    #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE),
      hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
        slave_export [];

  uvm_analysis_port
    #(hfpb_transaction #(DATA_SIZE, ADDR_SIZE))
        analysis_port;
// end codeblock interfaces

  // internal components
// begin codeblock components
  local hfpb_master #(DATA_SIZE, ADDR_SIZE) master;
  local hfpb_driver #(DATA_SIZE, ADDR_SIZE) driver;
  local hfpb_slave #(DATA_SIZE, ADDR_SIZE) slave [];
  local hfpb_monitor #(DATA_SIZE, ADDR_SIZE) monitor;
  local hfpb_coverage #(DATA_SIZE, ADDR_SIZE) cov;
  local hfpb_talker #(DATA_SIZE, ADDR_SIZE) talker;
  hfpb_sequencer #(DATA_SIZE, ADDR_SIZE) sequencer;
// end codeblock components
  // sequencer is not local because its interface must
  // be externally visible

  // configuration information
// begin codeblock hfpb_agent_config
  local bit has_monitor;
  local bit has_coverage;
  local bit has_talker;
  local bit has_master;
  local bit has_driver;
  local bit has_sequencer;
  local int unsigned slaves;
  local hfpb_vif #(DATA_SIZE, ADDR_SIZE) vif;
// end codeblock hfpb_agent_config

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //--------------------------------------------------------------------
  // build
  //--------------------------------------------------------------------
  function void build();

    uvm_object dummy;
    int unsigned i;
    string s;

    // First, collect up configuration information...

// begin codeblock get_config
    if(!get_config_int("has_monitor", has_monitor)) begin
      has_monitor = 0;
      monitor = null;
    end

    if(!get_config_int("has_coverage",
                       has_coverage)) begin
      has_coverage = 0;
      cov = null;
    end
// end codeblock get_config

    if(!get_config_int("has_talker", has_talker)) begin
      has_talker = 0;
      talker = null;
    end

    // The coverage collector and the talker rely on input from the
    // monitor.  So, if either of those is turned on we have to ensure
    // that the monitor is also turned on.
    if(has_coverage || has_talker)
      has_monitor = 1;

    if(!get_config_int("has_master", has_master)) begin
      has_master = 0;
      master = null;
    end

    if(!get_config_int("has_sequencer", has_sequencer)) begin
      has_sequencer = 0;
      sequencer = null;
    end

    if(!get_config_int("has_driver", has_driver)) begin
      has_driver = 0;
      driver = null;
    end

    if(!get_config_int("slaves", slaves)) begin
      uvm_report_warning("build",
                         "number of slaves not specified, defaulting to 0");
        slaves = 0;
    end

    vif = null;
    if(!get_config_object("hfpb_vif", dummy, 0)) begin
      // get config_object is specifed to NOT do a clone
      uvm_report_error("build", "no virtual interface available");
    end
    else begin
      if(!$cast(vif, dummy)) begin
        uvm_report_error("build", "virtual interface is incorrect type");
      end
    end

    // Now, use the configuration information to 
    // construct the internal components

    if(has_master && has_driver) begin
      uvm_report_error("build", "hfpb agent cannot have both a master and a driver");
    end

    if(has_monitor) begin
      monitor = new("monitor", this);
      analysis_port = new("analysis_port", this);
      if(has_coverage) begin
        cov = new("coverage", this);
      end
      if(has_talker) begin
        talker = new("talker", this);
      end
    end
    else begin
      // no monitor implies no coverage
      has_coverage = 0;
    end

// begin codeblock instantiate_master
    if(has_master) begin
      master = new("master", this);
      transport_export = new("transport_export", this);
    end
// end codeblock instantiate_master

    if(has_sequencer) begin
      sequencer = new("sequencer", this);
      has_driver = 1; // if we have a sequencer we must also have a driver
    end

    if(has_driver) begin
      driver = new("driver", this);
      // we only need an externally visible seq_item_port
      // if there is no sequencer
      if(!has_sequencer) begin
        seq_item_port = new("seq_item_port", this);
      end
    end

    // if no slaves then we're done
    if(slaves == 0)
      return;

    slave = new [slaves];
    slave_export = new [slaves];

    // construct slaves and slave_exports

    for(i = 0; i < slaves; i++) begin
      $sformat(s, "slave_%0d", i);
      $display("Creating agent.%s",s);
      slave[i] = new(s, this, i);
      $sformat(s, "slave_export_%0d", i);
      $display("Creating agent.%s",s);
      slave_export[i] = new(s, this);
    end
    
  endfunction

  //--------------------------------------------------------------------
  // connect
  //--------------------------------------------------------------------
  function void connect();

    int unsigned i;

    // connect the monitor, if necessary
    if(has_monitor) begin
      analysis_port.connect(monitor.analysis_port);
      if(has_coverage) begin
        monitor.analysis_port.connect(cov.analysis_export);
      end
      if(has_talker) begin
        monitor.analysis_port.connect(talker.analysis_export);
      end
    end

    // connect the master, if necessary
// begin codeblock connect_master
    if(has_master) begin
      transport_export.connect(master.transport_export);
    end
// end codeblock connect_master

    // connect the driver, if necessary
    if(has_driver) begin
      // connect the sequencer, if one exists.  Otherwise, make the
      // driver's seq_item_port externally visible
      if(has_sequencer)
        driver.seq_item_port.connect(sequencer.seq_item_export);
      else
        driver.seq_item_port.connect(seq_item_port);
    end

    if(slaves > 0) begin
      for(i = 0; i < slaves; i++) begin
        slave_export[i].connect(slave[i].slave_export);
      end
    end

  endfunction

  function void dump_config_status();
    $display("configuraiton status for: %s", get_full_name());
    $display("  has_driver   : %0d", has_driver);
    $display("  has_master   : %0d", has_master);
    $display("  has_sequencer: %0d", has_sequencer);
    $display("  slaves       : %0d", slaves);
    $display("  has_monitor  : %0d", has_monitor);
    $display("  has_talker   : %0d", has_talker);
    $display("  has_coverage : %0d", has_coverage);
    if(vif != null)
      $display("  virtual interface assigned");
    else
      $display("  virtual interface NOT assigned");
  endfunction

  function void end_of_elaboration();
    dump_config_status();
  endfunction

endclass
