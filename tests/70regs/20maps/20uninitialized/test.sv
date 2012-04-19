// 
// -------------------------------------------------------------
//    Copyright 2010-2011 Cadence Design Systems, Inc.
//    Copyright 2010-2011 Mentor Graphics Corporation
//    Copyright 2011 Synopsys, Inc.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under t,he License.
// -------------------------------------------------------------
// 
    
program two_sequencers_with_same_map;
    import uvm_pkg::*;
`include "uvm_macros.svh"

    class reg_slave_ID extends uvm_reg;

        uvm_reg_field REVISION_ID;
        uvm_reg_field CHIP_ID;
        uvm_reg_field PRODUCT_ID;

        function new(string name = "slave_ID");
            super.new(name,32,UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            this.REVISION_ID = uvm_reg_field::type_id::create("REVISION_ID");
            this.CHIP_ID = uvm_reg_field::type_id::create("CHIP_ID");
            this.PRODUCT_ID = uvm_reg_field::type_id::create("PRODUCT_ID");

            this.REVISION_ID.configure(this, 8, 0, "RO", 0, 8'h03, 1, 0, 1);
            this.CHIP_ID.configure(this, 8, 8, "RO", 0, 8'h5A, 1, 0, 1);
            this.PRODUCT_ID.configure(this, 10, 16,"RO", 0, 10'h176, 1, 0, 1);
        endfunction
   
        `uvm_object_utils(reg_slave_ID) 
    endclass


    class reg_block_slave extends uvm_reg_block;

        reg_slave_ID ID;
 
        uvm_reg_field REVISION_ID;
        uvm_reg_field CHIP_ID;
        uvm_reg_field PRODUCT_ID;

        function new(string name = "slave");
            super.new(name,UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            // create
            ID = reg_slave_ID::type_id::create("ID");
 
            // configure
            ID.configure(this,null,"ID");
            ID.build();

            // define default map
            default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);
            default_map.add_reg(ID, 'h0, "RW");
      
            // field handle aliases
            REVISION_ID = ID.REVISION_ID;
            CHIP_ID = ID.CHIP_ID;
            PRODUCT_ID = ID.PRODUCT_ID;
        endfunction
   
        `uvm_object_utils(reg_block_slave) 
    endclass : reg_block_slave
     
   
    class whatever_trans extends uvm_sequence_item;
        `uvm_object_utils(whatever_trans)
        function new(string name="");
            super.new(name);
        endfunction
    endclass
           
        class whatever_driver #(type T=uvm_object) extends uvm_driver#(T);
            `uvm_component_utils(whatever_driver)
            function new(string name, uvm_component parent=null);
                super.new(name,parent);
            endfunction
                    
            task run();
                while(1) begin
                    #10;
                    seq_item_port.get_next_item(req);
                    `uvm_info("Driver", "Printing received item :", UVM_MEDIUM)
                    seq_item_port.item_done();
                end 
            endtask 
        endclass
            
        class whatever_sequencer#(type T=uvm_object) extends uvm_sequencer#(T);
            `uvm_component_param_utils(whatever_sequencer#(T))
            function new(string name, uvm_component parent=null);
                super.new(name,parent);
            endfunction
        endclass

    class whatever_agent#(type T=uvm_object) extends uvm_agent;
        whatever_sequencer#(T) sequencer;
        whatever_driver#(T) driver;
    
        `uvm_component_param_utils(whatever_agent#(T))
        function new(string name, uvm_component parent=null);
            super.new(name,parent);
            sequencer = new("sqr",this);
            driver = new("driver",this);
        endfunction
        
        virtual function void build();
            driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction
    endclass
    
        class my_adapter extends uvm_reg_adapter;
            virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
                whatever_trans t = new;
                return t;
            endfunction
            virtual function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw); 
            endfunction 
        endclass

        class write_some extends uvm_reg_sequence;
            reg_block_slave model;
            function new(string name="write_some");
                super.new(name);
            endfunction : new
            `uvm_object_utils(write_some)
            
            virtual task pre_body();
                uvm_test_done.raise_objection(this);
            endtask
            virtual task post_body();
                uvm_test_done.drop_objection(this);
            endtask
                        
            virtual task body();
                uvm_status_e status; 
                uvm_reg_data_t data;
                uvm_reg_map m;
                
                void'(uvm_config_db#(uvm_reg_map)::get(get_sequencer(),"","target_map",m));

                repeat(10) begin
                    data = $urandom;
                    model.ID.write(status,data,.parent(this),.map(m));
                end 
            endtask 
        endclass

    class test extends uvm_test;
        `uvm_component_utils(test)
            

        reg_block_slave model; 

        whatever_agent#(whatever_trans) m0;
        whatever_agent#(whatever_trans) m1;

        function new(string name, uvm_component parent=null);
            super.new(name,parent);
            m0 = new("M0",this);
            m1 = new("M1",this);
        endfunction

        virtual function void build_phase(uvm_phase phase);
        
            if (model == null) begin
                model = reg_block_slave::type_id::create("model",this);
                model.build();
 
`ifdef ENABLE_M1 
                // scenario1: now i want to run 'write_some' on M1 as well (in parallel)
                // scenario2: M0+M1 are masters on the same bus and share the same addressing: HOW DO THEY share now the same addressing active driving?        
                begin
                    uvm_reg_map bla = model.create_map("bla_map", 'h0, 4, UVM_LITTLE_ENDIAN);
                    uvm_reg_map default_map=model.get_default_map();
                    bla.add_submap(default_map, 0);
                    bla.set_sequencer(m1.sequencer,default_map.get_adapter(UVM_NO_HIER));
                    bla.set_auto_predict(1); 
                
                    uvm_config_db#(uvm_reg_map)::set(this,"*.seq0","target_map",default_map);
                    uvm_config_db#(uvm_reg_map)::set(this,"*.seq1","target_map",bla);
               
                end 
`endif 
 
// not locking produces the WARNING                model.lock_model(); 
               
            end 
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            if (model.get_parent() == null) begin
                my_adapter m = new;
                model.default_map.set_sequencer(m1.sequencer,m);
                model.default_map.set_auto_predict(1);
            end 
        endfunction
    
        task run(); 
            begin
                write_some seq0=new("seq0");
                seq0.model=model;
                seq0.start(null); // NOTE can start on ANY sequencer    
            end
`ifdef ENABLE_M1 
            begin
                write_some seq1=new("seq1");
                seq1.model=model;
                seq1.start(null); // NOTE can start on ANY sequencer    
            end
`endif 
        endtask
 
        virtual function void report();
            uvm_report_server svr;
            svr = _global_reporter.get_report_server();

            if (svr.get_severity_count(UVM_FATAL) == 0 &&
                    svr.get_severity_count(UVM_ERROR) == 0 &&
                    svr.get_severity_count(UVM_WARNING) == 20 )
                $write("** UVM TEST PASSED **\n");
            else
                $write("!! UVM TEST FAILED !!\n");
        endfunction
    endclass
    
    initial
        run_test();
endprogram
