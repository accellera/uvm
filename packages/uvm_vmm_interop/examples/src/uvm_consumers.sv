//------------------------------------------------------------------------------
// Copyright 2008 Mentor Graphics Corporation
// All Rights Reserved Worldwide
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License.  You may obtain
// a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//------------------------------------------------------------------------------

`include "uvm_apb_rw.sv"

//------------------------------------------------------------------------------
// Title: UVM Consumers
//
// This file defines the following UVM consumer components.
//
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// Group: uvm_consumer
//
// A generic UVM driver/consumer component that can get transactions from
// a blocking get port or receive transactions via is blocking put export.
// If the <blocking_get_port> has been connected, this consumer will continually
// get and execute transactions from that port. Transactions coming in from the
// <blocking_get_export> will also be executed. A semaphore is used to arbitrate
// these two potential sources of transactions.
//
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_consumer #(type T=int) extends uvm_component;

  typedef uvm_consumer #(T) this_type;

  `uvm_component_param_utils(this_type)

  // Port: blocking_get_port
  //
  // When connected, a consumer process will continually get from
  // the port and call <put> with the received transaction. This
  // port may be left unconnected.

  uvm_blocking_get_port #(T) blocking_get_port;

  // Port: analysis_port
  //
  // The <put> method will also write the transaction to this port
  // for coverage, scoreboarding or other analysis. This port may
  // be left unconnected.

  uvm_analysis_port #(T) analysis_port;

  // Port: blockling_put_export
  //
  // Transactions put to this export will be forwarded to the <put>
  // method, where the received transaction is executed. (In this
  // case, we merely print the fact a transaction was received.)
  // A semaphore is used to govern access by both this port and the
  // active process that putting transaction that were gotten from
  // the blocking_get_port.

  uvm_blocking_put_imp #(T,this_type) blocking_put_export;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
    blocking_put_export   = new("blocking_put_export",this);
    blocking_get_port     = new("blocking_get_port",this,0);
    analysis_port         = new("analysis_port",this);
  endfunction

  const string type_name  = {"uvm_consumer #(",T::type_name,")"};

  virtual function string get_type_name();
    return type_name;
  endfunction

  int num_trans=0;

  local semaphore lock = new(1);


  // Task: run
  //
  // If the <blocking_get_port> is connected, a the run task will
  // continually get from the port and <put> the transaction for
  // immediate execution. If <put> is busy with a transaction
  // recevied from the blocking_put_export, this process will block
  // until the transaction is complete.

  task run();
    T tr;

    if (blocking_get_port.size()<=0)
      return;

    forever begin
      blocking_get_port.get(tr);
      put(tr);
    end

  endtask
  
  // Task: put
  //
  // Called via the <blocking_put_port> or <run> process, this
  // process "executes" the transaction by printing a message
  // and waiting a bit of time. It uses a semaphore to prevent
  // multiple callers from colliding.

  task put (T tr);
    lock.get();
    num_trans++;
    uvm_report_info("recevied", tr.convert2string());
    analysis_port.write(tr);
    #100;
    lock.put();
  endtask 
endclass
// (end inline source)


//------------------------------------------------------------------------------
//
// Group: uvm_driver_req
//
// This consumer's run task will continually retrieve and execute 
// transaction items from this port in one of two ways, chosen
// randomly ofr -- either using get_next_item/item_done or peek/get.
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_driver_req extends uvm_component;

  `uvm_component_utils(uvm_driver_req)

  // Port: seq_item_port
  //
  // Transactions are fetched from this port. Although this port is bidirectional,
  // this component will not return responses.

  uvm_seq_item_pull_port #(uvm_apb_rw) seq_item_port;

  // Port: ap
  //
  // Processed requests are published to this port. 

  uvm_analysis_port #(uvm_apb_rw) ap;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
    seq_item_port = new("seq_item_port",this);
    ap = new("ap",this);
  endfunction

  int max_trans = 100;
  int num_trans = 0;

  local integer unsigned m[int];

  function void mem_model(ref uvm_apb_rw tr);
    if(tr.cmd == uvm_apb_rw::WR)
      m[tr.addr] = tr.data;
    else begin
      if (m.exists(tr.addr))
        tr.data = m[tr.addr];
      else
        tr.data = 'hx;
    end
  endfunction
  
  task run();

    uvm_apb_rw req;
    uvm_apb_rw pop;
    
    while (num_trans < max_trans) begin 

      randcase

        // get_next_item/item_done
        1: begin
          seq_item_port.get_next_item(req);
          mem_model(req);
          #10;
          seq_item_port.item_done();
          uvm_report_info("UVM Consumer",
            {"via GET_NEXT_ITEM/ITEM_DONE - ", req.convert2string()});
        end

        // peek/get
        1: begin
          seq_item_port.peek(req);
          mem_model(req);
          #10;
          seq_item_port.get(pop);
          uvm_report_info("UVM Consumer", 
            {"via PEEK/GET                - ", req.convert2string()});
        end

      endcase

      ap.write(req);

      num_trans++;

    end
  endtask

endclass
// (end inline source)



//------------------------------------------------------------------------------
//
// Group: uvm_driver_rsp
//
// This consumer's run task will continually retrieve, execute, and send back
// a response in one of three ways, chosen randomly-- either using peek/get,
// get/delay/put, or get_next_item/item_done.
//
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_driver_rsp extends uvm_component;

  `uvm_component_param_utils(uvm_driver_rsp)

  // Port: seq_item_port
  //
  // When connected, a consumer process will continually get from
  // the port and call <put> with the response.

  uvm_seq_item_pull_port #(uvm_apb_rw) seq_item_port;

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
    seq_item_port = new("seq_item_port",this);
  endfunction

  int max_trans=100;
  int num_trans=0;
  
  local integer unsigned m[int];

  function uvm_apb_rw mem_model(ref uvm_apb_rw tr);
    uvm_apb_rw rsp;
    $cast(rsp,tr.clone());
    if(tr.cmd == uvm_apb_rw::WR) begin
      m[tr.addr]  = tr.data;
    end
    else begin
      if (m.exists(tr.addr))
        rsp.data = m[tr.addr];
      else
        rsp.data = 'hx;
    end
    rsp.set_id_info(tr);
    return rsp;
  endfunction // mem_model

  task run();

    uvm_apb_rw req;
    uvm_apb_rw rsp;
    
    while (num_trans < max_trans) begin 

      randcase

        // peek/get
        1: begin
          uvm_report_info("UVM Consumer","Using peek/get");
          seq_item_port.peek(req);
          rsp = mem_model(req);
          seq_item_port.get(req);
          #10;
          seq_item_port.put_response(rsp);
          uvm_report_info("UVM Consumer",
               { " via PEEK/GET                             - ",
               "req=",req.convert2string(), " rsp=", rsp.convert2string() });
        end

        // get-delay-put
        1: begin
          uvm_report_info("UVM Consumer","Using get-delay-put");
          seq_item_port.get(req);
          rsp = mem_model(req);
          #10 seq_item_port.put_response(rsp);
          uvm_report_info("UVM Consumer",
               { " via GET/DELAY/PUT                        - ",
               "req=",req.convert2string(), " rsp=", rsp.convert2string() });
        end

        // get_next_item/item_done
        1: begin
          uvm_report_info("UVM Consumer","Using get_next_item/item_done");
          seq_item_port.get_next_item(req);
          rsp = mem_model(req);
          seq_item_port.item_done();
          #10;
          seq_item_port.put_response(rsp);
          uvm_report_info("UVM Consumer",
               { " via GET_NEXT_ITEM/ITEM_DONE/PUT_RESPONSE - ",
               "req=",req.convert2string(), " rsp=", rsp.convert2string() });
        end

      endcase
    end
  endtask

endclass
// (end inline source)


//----------------------------------------------------------------------------------
//
// Group: uvm_subscribe
//
// This consumer receives transactions via the ~uvm_analysis_export~ inherited from
// its ~uvm_subscriber~ base class. 
//----------------------------------------------------------------------------------

// (begin inline source)
class uvm_subscribe #(type T=int) extends uvm_subscriber #(T);

  // Port: analysis_export
  //
  // Transactions are received via this inherited analysis export.

  uvm_analysis_port #(T) ap;

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
    ap = new("ap",this);
  endfunction

  virtual function void write(T t);
     uvm_transaction o_tr;
     vmm_data v_tr;
     if ($cast(o_tr,t)) begin
       uvm_report_info("received_uvm",o_tr.convert2string());
       ap.write(t);
     end
     else if ($cast(v_tr,t))
       uvm_report_info("received_vmm",v_tr.psdisplay());
  endfunction

endclass
// (end inline source)

