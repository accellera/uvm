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


//------------------------------------------------------------------------------
//
// Title: UVM Producers
//
// This file defines the following UVM producer components.
//
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//
// Group: uvm_producer
//
// Generic generator, inheriting from uvm_random_stimulus #(T), that produces
// transactions of the parameterized type, T, and puts them out the inherited
// blocking put port.
//
// This class extends ~uvm_random_stimulus~ by providing the ability for users
// to specify the number and type of transactions produced. It also implements
// the run task to start generating stimulus without need for an explicit call
// ~generate_stimulus~.
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_producer #(type T=int) extends uvm_random_stimulus #(T);

  typedef uvm_producer #(T) this_type;

  `uvm_component_param_utils(this_type)

  // Function: new
  //
  // Creates a new instance of ~uvm_producer~.

  function new (string name, uvm_component parent);
     super.new(name,parent);
  endfunction

  // The object to produce; can be any extension of T.
  T prototype;

  // The number of transactions to generate
  int num_trans=5;

  // Function: build
  // 
  // Grabs any config settings for the number of transactions
  // to generate and the particular extension of the transaction
  // type to generate.

  virtual function void build();
    uvm_object obj;
    void'(get_config_int("num_trans",num_trans));
    void'(get_config_object("prototype",obj));
    if (!$cast(prototype,obj))
      uvm_report_error("Bad Object",
          "configured prototype not compatible");
  endfunction

  // Task: run
  //
  // Calls ~generate_stimulus~ from the base class to
  // produce ~num_trans~ transactions of a type given
  // by ~prototype~.

  virtual task run();
    super.run();
    generate_stimulus(prototype,num_trans);
  endtask
  
  const string type_name = {"uvm_producer #(",T::type_name,")"};

  virtual function string get_type_name();
    return type_name;
  endfunction

endclass
// (end inline source)



//----------------------------------------------------------------------------------
//
// Group: uvm_publish
//
// Uses an ~uvm_analysis_port~ to broadcast transactions to all its subscribers.
//
//----------------------------------------------------------------------------------

// (begin inline source)
class uvm_publish #(type T=int) extends uvm_component;

   typedef uvm_publish #(T) this_type;
  `uvm_component_utils(this_type)

  // Port: out
  //
  // This component uses this analysis port to publish transactions.

  uvm_analysis_port #(T) out;


  // Function: new
  //
  // Creates a new instance of ~uvm_pubish~.

  function new(string name, uvm_component parent=null);
    super.new(name,parent);
    out = new("out",this);
  endfunction

  virtual task run();
    T t;
    t = new();
    assert(t.randomize());
//    #0;
    uvm_report_info("publishing", t.convert2string());
    out.write(t);
  endtask

endclass
// (end inline source)

//------------------------------------------------------------------------------
//
// Group: uvm_blocking_transport_producer
//
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_blocking_transport_producer extends uvm_component;

  typedef uvm_blocking_transport_producer this_type;

  `uvm_component_param_utils(this_type)

  uvm_blocking_transport_port #(uvm_apb_rw, 
                                uvm_apb_rw) blocking_transport_port;

  // Function: new
  //
  // Creates a new instance of ~uvm_producer~.

  function new (string name, uvm_component parent);
     super.new(name,parent);
     blocking_transport_port=new("blocking_transport_port", this);
  endfunction

  // The object to produce; can be any extension of uvm_apb_rw.
  uvm_apb_rw prototype;

  // The number of transactions to generate
  int num_trans=5;

  // Function: build
  // 
  // Grabs any config settings for the number of transactions
  // to generate and the particular extension of the transaction
  // type to generate.

  virtual function void build();
    uvm_object obj;
    void'(get_config_int("num_trans",num_trans));
    void'(get_config_object("prototype",obj));
    if (!$cast(prototype,obj))
      `uvm_error("Bad Object",
          "configured prototype not compatible");
  endfunction

  // Task: run
  //
  // Calls ~generate_stimulus~ from the base class to
  // produce ~num_trans~ transactions of a type given
  // by ~prototype~.

  virtual task run();
    int rsp_num;
    uvm_apb_rw req, rsp;
    super.run();
    rsp_num=0;
    for (int i=0; i<num_trans; i++) begin
      #10;
      req=new(); 
      assert(req.randomize() with {req.cmd==uvm_apb_rw::RD;});
      fork
      begin
        uvm_report_info("uvm_producer", $psprintf("Send #%0d req transaction\n%s", i, req.convert2string()));
        blocking_transport_port.transport(req, rsp);
        uvm_report_info("uvm_producer", $psprintf("Get #%0d rsp transaction\n%s", rsp_num, rsp.convert2string()));
        rsp_num++;
      end
      join_none
    end
  endtask
  
  const string type_name = {"uvm_blocking_transport_producer #(",uvm_apb_rw::type_name,")"};

  virtual function string get_type_name();
    return type_name;
  endfunction

endclass
// (end inline source)

//------------------------------------------------------------------------------
//
// Group: uvm_passive_producer
//
//------------------------------------------------------------------------------

// (begin inline source)
class uvm_passive_producer #(type T=int) extends uvm_component ;

  typedef uvm_passive_producer #(T) this_type;

  `uvm_component_param_utils(this_type)

  //uvm_blocking_get_peek_imp #(T, T) get_peek_export;
  uvm_blocking_get_peek_imp #(T, this_type) get_peek_export;
  uvm_analysis_imp #(T, this_type) analysis_export;
  event get_request_e;

  // Function: new
  //
  // Creates a new instance of ~uvm_producer~.

  function new (string name, uvm_component parent);
     super.new(name,parent);
     get_peek_export=new("get_peek_export", this);
     analysis_export=new("analysis_export", this);
  endfunction

  // The object to produce; can be any extension of T.
  T prototype;

  // The number of transactions to generate
  int num_trans=5;

  // Function: build
  // 
  // Grabs any config settings for the number of transactions
  // to generate and the particular extension of the transaction
  // type to generate.

  virtual function void build();
    uvm_object obj;
    void'(get_config_int("num_trans",num_trans));
    void'(get_config_object("prototype",obj));
    if (!$cast(prototype,obj))
      `uvm_error("Bad Object",
          "configured prototype not compatible");
  endfunction

  // Task: run
  //
  virtual task run();
    super.run();
  endtask

  virtual task get(output T obj);
    this.peek(obj);
    prototype = null;
  endtask

  virtual task peek(output T obj);
    bit s;
      wait(prototype != null)
      obj = prototype;
  endtask
      
  virtual function void write(T obj);
    bit s;
    if (obj.cmd == uvm_apb_rw::RD)
      obj.data = 32'hdeadbeef;   
    prototype=obj;
  endfunction
  const string type_name = {"uvm_passive_producer #(",T::type_name,")"};

  virtual function string get_type_name();
    return type_name;
  endfunction

endclass
// (end inline source)

