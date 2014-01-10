module test184;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class test extends uvm_component;
        `uvm_new_func
        `uvm_component_utils(test)

        task run; uvm_coreservice_t cs_ = uvm_coreservice_t::get();

            uvm_resource_pool rp = uvm_resource_pool::get();  
            uvm_pool#(string,uvm_resource#(int)) m;
            int f;
    
            uvm_config_db#(int)::set(null,"env.driver", "value", 3);
            uvm_config_db#(int)::set(null,"env.driver", "value1", 7);
            uvm_config_db#(int)::set(null,"env.driver", "value", 4);
            uvm_config_db#(int)::set(null,"env.driver", "value1", 8);

            assert(uvm_config_db#(int)::m_rsc.size() == 1); //same context used
            m = uvm_config_db#(int)::m_rsc[cs_.get_root()];
            
            assert(uvm_config_db#(int)::get(null,"env.driver", "value", f));
            assert(f==4);
            assert(uvm_config_db#(int)::get(null,"env.driver", "value1", f));
            assert(f==8);

            // prio should be uvm_resource_types::PRI_HIGH as this has been overridden
            begin
                uvm_resource_pool rp = uvm_resource_pool::get();
                uvm_resource_types::rsrc_q_t rq;
                rq = rp.lookup_regex_names("env.driver", "value", uvm_resource#(int)::get_type());    
                if(rq.size()!=1)
                    $display("*** UVM TEST FAILED ***");    // should be reused
            end
            
            if(m.num() == 2) // two (overwriting) settings from that context
                $display("*** UVM TEST PASSED ***");
            else
                $display("*** UVM TEST FAILED ***");   
        endtask
    endclass

    initial begin
        run_test();
    end
endmodule

