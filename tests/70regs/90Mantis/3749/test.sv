module top;

    `include "uvm_macros.svh"
    import uvm_pkg::*;

    class my_reg_c extends uvm_reg;

        uvm_reg_field field1;
        uvm_reg_field field2;

        `uvm_object_utils(my_reg_c)

        function new(string name="my_reg_c", int unsigned n_bits=32, int has_coverage = 0);
            super.new(name, n_bits, has_coverage);
        endfunction : new

        virtual function void build();
            field1  = uvm_reg_field::type_id::create("field1");
            field2  = uvm_reg_field::type_id::create("field2");

            field1.configure(
                .parent(this),
                .size(1),
                .lsb_pos(0),
                .access("W1C"),
                .volatile(0),
                .reset(0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(1)
                );

            field2.configure(
                .parent(this),
                .size(31),
                .lsb_pos(1),
                .access("RW"),
                .volatile(0),
                .reset(0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(1)
                );

        endfunction : build

    endclass : my_reg_c


    class my_reg_block_c extends uvm_reg_block;

        my_reg_c    my_reg;

        `uvm_object_utils(my_reg_block_c)

        function new(string name="my_reg_block_c", int has_coverage=UVM_NO_COVERAGE);
            super.new(name, has_coverage);
        endfunction : new

        virtual function void build();
            default_map = create_map(.name("reg_map"), .base_addr('h0), .n_bytes(4), .endian(UVM_LITTLE_ENDIAN));

            my_reg      = my_reg_c::type_id::create("my_reg");
            my_reg.configure(.blk_parent(this), .regfile_parent(null), .hdl_path(""));
            my_reg.add_hdl_path_slice("field1", 0, 1);
            my_reg.add_hdl_path_slice("field2", 1, 31);

            default_map.add_reg(my_reg, .offset(0), .rights("RW"));

            my_reg.build();

            lock_model();
        endfunction : build

    endclass : my_reg_block_c


    class reg_seq_item_c extends uvm_sequence_item;

        rand bit        rnw;
        rand bit [15:0] addr;
        rand bit [31:0] data;

        `uvm_object_utils_begin(reg_seq_item_c)
            `uvm_field_int(rnw, UVM_DEFAULT)
            `uvm_field_int(addr, UVM_DEFAULT)
            `uvm_field_int(data, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name="reg_seq_item_c");
            super.new(name);
        endfunction : new

    endclass : reg_seq_item_c


    class reg_seq_c extends uvm_sequence #(reg_seq_item_c);
        `uvm_object_utils(reg_seq_c)

        function new(string name="reg_seq_c");
            super.new(name);
        endfunction : new

        virtual task body();
            `uvm_do(req)
        endtask : body

    endclass : reg_seq_c


    class reg_update_seq_c extends uvm_reg_sequence;

        `uvm_object_utils(reg_update_seq_c)

        function new(string name="reg_update_seq_c");
            super.new(name);
        endfunction : new

        virtual task body();
            uvm_status_e    status;
            model.update(status, .parent(this));
        endtask : body

    endclass : reg_update_seq_c


    class my_reg_adapter_c extends uvm_reg_adapter;

        `uvm_object_utils(my_reg_adapter_c)

        function new(string name="my_reg_adapter_c");
            super.new(name);
            supports_byte_enable    = 0;
            provides_responses      = 0;
        endfunction : new

        virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
            reg_seq_item_c  reg_item    = reg_seq_item_c::type_id::create("reg_item");
            reg_item.rnw    = (rw.kind == UVM_READ);
            reg_item.addr   = rw.addr;
            reg_item.data   = rw.data;
            return reg_item;
        endfunction : reg2bus

        virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
            reg_seq_item_c  reg_item;

            $cast(reg_item, bus_item);
            rw.kind     = reg_item.rnw ? UVM_READ : UVM_WRITE;
            rw.addr     = reg_item.addr;
            rw.data     = reg_item.data;
            rw.status   = UVM_IS_OK;
        endfunction : bus2reg

    endclass : my_reg_adapter_c


    class my_driver_c extends uvm_driver #(reg_seq_item_c);

        `uvm_component_utils(my_driver_c)

        function new(string name="reg_seq_item_c", uvm_component parent);
            super.new(name, parent);
        endfunction : new

        virtual task run_phase(uvm_phase phase);
            forever begin
                seq_item_port.get(req);
                `uvm_info("DRVR", "Driving register transaction", UVM_NONE)
                req.print();
            end
        endtask : run_phase

    endclass : my_driver_c


    class my_agent_c extends uvm_agent;

        uvm_sequencer #(reg_seq_item_c) sequencer;
        my_driver_c                     driver;

        `uvm_component_utils_begin(my_agent_c)
            `uvm_field_object(sequencer, UVM_DEFAULT)
            `uvm_field_object(driver, UVM_DEFAULT)
        `uvm_component_utils_end

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction : new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer   = uvm_sequencer #(reg_seq_item_c)::type_id::create("sequencer", this);
            driver      = my_driver_c::type_id::create("driver", this);
        endfunction : build_phase

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction : connect_phase

    endclass : my_agent_c


    class my_env_c extends uvm_env;

        my_agent_c      agent;
        my_reg_block_c  reg_model;

        `uvm_component_utils_begin(my_env_c)
            `uvm_field_object(agent, UVM_DEFAULT)
            `uvm_field_object(reg_model, UVM_DEFAULT)
        `uvm_component_utils_end

        function new(string name="my_env_c", uvm_component parent=null);
            super.new(name, parent);
        endfunction : new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agent       = my_agent_c::type_id::create("agent", this);
            reg_model   = my_reg_block_c::type_id::create("reg_model", this);
            reg_model.build();
        endfunction : build_phase

        virtual function void connect_phase(uvm_phase phase);
            my_reg_adapter_c    adapter;

            super.connect_phase(phase);

            adapter = my_reg_adapter_c::type_id::create("adapter", this);
            reg_model.default_map.set_sequencer(agent.sequencer, adapter);
            reg_model.default_map.set_auto_predict(1);
        endfunction : connect_phase

    endclass : my_env_c


    class test extends uvm_test;

        my_env_c    env;

        `uvm_component_utils_begin(test)
            `uvm_field_object(env, UVM_DEFAULT)
        `uvm_component_utils_end

        function new(string name="test", uvm_component parent=null);
            super.new(name, parent);
        endfunction : new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = my_env_c::type_id::create("env", this);
        endfunction : build_phase

        virtual task run_phase(uvm_phase phase);
            reg_seq_c           reg_seq;
            reg_update_seq_c    reg_update_seq;

            phase.raise_objection(this);

            reg_seq                 = reg_seq_c::type_id::create("reg_seq", this);
            assert(reg_seq.randomize());
            $display("Sending sequence");
            reg_seq.print();
            reg_seq.start(env.agent.sequencer);

            env.reg_model.my_reg.field1.set(1);
            env.reg_model.my_reg.field2.set('h5EADBEEF);

            `uvm_info("TEST", "Model before update:", UVM_NONE)
            env.reg_model.print();

            `uvm_info("TEST","now updating",UVM_NONE)
            begin
                uvm_status_e status;
                env.reg_model.update(status);
            end

            #10ns;
            
            `uvm_info("TEST", "Model after update:", UVM_NONE)
            env.reg_model.print();
            
            assert (env.reg_model.my_reg.field2.value == 'h5eadbeef) else `uvm_error("TEST","field corrupted")
                       
            phase.drop_objection(this);
            
            $display("UVM TEST PASSED");
        endtask : run_phase

    endclass 


    initial begin
        run_test();
    end

endmodule : top
