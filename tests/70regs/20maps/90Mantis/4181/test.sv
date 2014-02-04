//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2010 Mentor Graphics Corporation
//   Copyright 2011 Cadence Design Systems, Inc.
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

`include "uvm_macros.svh"
program top;

    import uvm_pkg::*;

    class reg32 extends uvm_reg;

        uvm_reg_field f32;

        function new(string name = "reg32");
            super.new(name,32,UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            this.f32 = new("f32");
            this.f32.configure(this, 32,  0, "RW", 0, 'h0, 1, 0, 1);
        endfunction
    endclass


    class dut extends uvm_reg_block;
        `uvm_object_utils(dut)
        rand reg32 r0;

        uvm_reg_map bus8;

        function new(string name = "dut");
            super.new(name,UVM_NO_COVERAGE);
        endfunction

        virtual function void build();

            // create
            r0 = new("r0");

            // configure
            r0.build();   r0.configure(this, null);

            // define default map
            bus8 = create_map("bus8", 'h0, 1, UVM_BIG_ENDIAN);

            bus8.add_reg(r0,    'h0,  "RW");
        endfunction
    endclass

    class bus_item extends uvm_sequence_item;
        int unsigned addr;
        `uvm_object_utils_begin(bus_item)
        `uvm_field_int(addr,UVM_DEFAULT)
        `uvm_object_utils_end
        function new(string name="");
            super.new(name);
        endfunction
    endclass

    static int unsigned queue[$];

    class d_reg_adapter extends uvm_reg_adapter;
        virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
            bus_item r=new("busitem");
            r=new("busitem");
            r.addr = rw.addr;
            queue.push_back(rw.addr);
            return r;
        endfunction
        virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
            // TODO Auto-generated function stub
            // super.bus2reg(bus_item, rw);        
        endfunction
    endclass


    class high_first extends uvm_reg_transaction_order_policy;
        virtual function void order(ref uvm_reg_bus_op q[$]);  
            q.sort with (item.addr);
        endfunction   
        function new(string name = "dut");
            super.new(name);
        endfunction
    endclass

    class low_first extends uvm_reg_transaction_order_policy;
        virtual function void order(ref uvm_reg_bus_op q[$]);  
            uvm_reg_bus_op o[] = q;  
            q.rsort with (item.addr);
        endfunction   
        function new(string name = "dut");
            super.new(name);
        endfunction
    endclass


    class dummy_driver#(type T=int) extends uvm_driver#(T);
        `uvm_component_param_utils(dummy_driver#(T))

        function new(string name,uvm_component parent = null);
            super.new(name,parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            T tr;
            super.run_phase(phase);
            forever begin
                seq_item_port.get_next_item(tr);
                $display(tr.sprint());
                seq_item_port.item_done();
            end
        endtask
    endclass


    class test extends uvm_test;
        `uvm_component_utils(test)

        function new(string name,uvm_component parent = null);
            super.new(name,parent);
        endfunction

        uvm_sequencer#(bus_item) rseqr;
        dummy_driver#(bus_item) driver;

        dut blk=new("blk");

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);               
            blk.build();

            rseqr=new("bus-sqr",this); 
            driver=new("dummy-driver",this);
            driver.seq_item_port.connect(rseqr.seq_item_export);

            blk.lock_model();
        endfunction
        virtual task run_phase(uvm_phase phase); uvm_coreservice_t cs_ = uvm_coreservice_t::get();

            uvm_status_e status;
            d_reg_adapter ad;
            uvm_reg_data_t val;
            high_first up=new("high-first");
            low_first down=new("low-first");

            phase.raise_objection(this);
            super.run_phase(phase);

            ad=new();
            blk.bus8.set_sequencer(rseqr, ad);

            blk.bus8.set_transaction_order_policy(up);
            blk.r0.write(status, 'hdeadbeef);
            blk.bus8.set_transaction_order_policy(down);
            blk.r0.read(status,val);
            `uvm_info("TEST",$sformatf("%p",queue),UVM_NONE)
            begin
                int unsigned exp_q[$] = '{0,1,2,3,3,2,1,0};
                assert(queue == exp_q) else `uvm_error("TEST","test failed");
            end
            
            begin
                uvm_report_server svr;
                svr = cs_.get_report_server();

                if (svr.get_severity_count(UVM_FATAL) +
                    svr.get_severity_count(UVM_ERROR) == 0)
                    $write("** UVM TEST PASSED **\n");
                else
                    $write("!! UVM TEST FAILED !!\n");
            end

            phase.drop_objection(this);
        endtask
    endclass

    initial run_test();

endprogram
