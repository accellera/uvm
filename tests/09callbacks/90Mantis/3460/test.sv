import uvm_pkg::*;
`include "uvm_macros.svh"

class phase_started_callback extends uvm_callback;

`uvm_object_utils(phase_started_callback)

   function new(string _name = "unnamed-phase_started_callback");
      super.new(_name);
   endfunction : new

   virtual function phase_started(uvm_phase phase);
`uvm_warning("UVM_PS_CB", $psprintf("phase_started not implemented in %s", get_type_name()))
   endfunction : phase_started

endclass : phase_started_callback

class phase_ended_callback extends uvm_callback;

`uvm_object_utils(phase_ended_callback)

   function new(string _name = "unnamed-phase_ended_callback");
      super.new(_name);
   endfunction : new

   virtual function phase_ended(uvm_phase phase);
`uvm_warning("UVM_PS_CB", $psprintf("phase_ended not implemented in %s", get_type_name()))
   endfunction : phase_ended

endclass : phase_ended_callback

class phase_ready_to_end_callback extends uvm_callback;

`uvm_object_utils(phase_ready_to_end_callback)

   function new(string _name = "unnamed-phase_ready_to_end_callback");
      super.new(_name);
   endfunction : new

   virtual function phase_ready_to_end(uvm_phase phase);
`uvm_warning("UVM_PS_CB", $psprintf("phase_ready_to_end not implemented in %s", get_type_name()))
   endfunction : phase_ready_to_end

endclass : phase_ready_to_end_callback

class phase_proxy_component extends uvm_component;
`uvm_register_cb(phase_proxy_component, phase_started_callback)
`uvm_register_cb(phase_proxy_component, phase_ended_callback)
`uvm_register_cb(phase_proxy_component, phase_ready_to_end_callback)

`uvm_component_utils(phase_proxy_component)

   function new(string _name, uvm_component _parent);
      super.new(_name, _parent);
   endfunction : new

   virtual function void phase_started(uvm_phase phase);
`uvm_do_callbacks(phase_proxy_component, phase_started_callback, phase_started(phase))
   endfunction : phase_started

   virtual function void phase_ended(uvm_phase phase);
`uvm_do_callbacks(phase_proxy_component, phase_ended_callback, phase_ended(phase))
   endfunction : phase_ended

   virtual function void phase_ready_to_end(uvm_phase phase);
`uvm_do_callbacks(phase_proxy_component, phase_ready_to_end_callback, phase_ready_to_end(phase))
   endfunction : phase_ready_to_end

endclass : phase_proxy_component

class phase_aware_object extends uvm_object;

`uvm_object_utils(phase_aware_object)

   function new(string _name = "unnamed-phase_aware_object");
      super.new(_name);
   endfunction : new

   virtual function void my_phase_started(uvm_phase phase);
      uvm_phase_state l_state = phase.get_state();
   endfunction : my_phase_started

   virtual function void my_phase_ended(uvm_phase phase);
      uvm_phase_state l_state = phase.get_state();
   endfunction : my_phase_ended

   virtual function void my_phase_ready_to_end(uvm_phase phase);
      uvm_phase_state l_state = phase.get_state();
   endfunction : my_phase_ready_to_end


endclass : phase_aware_object

class pao_started_callback extends phase_started_callback;

`uvm_object_utils(pao_started_callback)

   phase_aware_object m_ref;

   function new(string _name = "unnamed", phase_aware_object _pao_ref = null);
      super.new(_name);
      m_ref = _pao_ref;
   endfunction : new

   virtual   function phase_started(uvm_phase phase);
      m_ref.my_phase_started(phase);
   endfunction : phase_started

endclass : pao_started_callback

class pao_ended_callback extends phase_ended_callback;

`uvm_object_utils(pao_ended_callback)

   phase_aware_object m_ref;

   function new(string _name = "unnamed", phase_aware_object _pao_ref  = null);
      super.new(_name);
      m_ref = _pao_ref;
   endfunction : new

   virtual   function phase_ended(uvm_phase phase);
      m_ref.my_phase_ended(phase);
   endfunction : phase_ended

endclass : pao_ended_callback

class pao_ready_to_end_callback extends phase_ready_to_end_callback;

`uvm_object_utils(pao_ready_to_end_callback)

   phase_aware_object m_ref;

   function new(string _name = "unnamed", phase_aware_object _pao_ref = null);
      super.new(_name);
      m_ref = _pao_ref;
   endfunction : new

   virtual   function phase_ready_to_end(uvm_phase phase);
      m_ref.my_phase_ready_to_end(phase);
   endfunction : phase_ready_to_end

endclass : pao_ready_to_end_callback

class test extends uvm_component;

   phase_proxy_component ppc;

   pao_started_callback psc;
   pao_ended_callback pec;
   pao_ready_to_end_callback prtec;

   phase_aware_object pao;

   `uvm_component_utils(test)

   function new(string _name, uvm_component _parent);
      super.new(_name, _parent);
   endfunction : new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ppc = phase_proxy_component::type_id::create("ppc", this);

      pao = phase_aware_object::type_id::create("pao");

      psc = pao_started_callback::type_id::create("psc");
      psc.m_ref = pao;

      pec = pao_ended_callback::type_id::create("pec");
      pec.m_ref = pao;

      prtec = new("prtec", pao);
   endfunction : build_phase

   virtual function void start_of_simulation_phase(uvm_phase phase);
      uvm_report_server report_server = get_report_server();
      int  warning_count = report_server.get_severity_count(UVM_WARNING);
      super.start_of_simulation_phase(phase);

`uvm_info(get_type_name(), "registering psc with ppc::started in start_of_simulation", UVM_NONE)
      uvm_callbacks#(phase_proxy_component, phase_started_callback)::add(ppc, psc);

`uvm_info(get_type_name(), "registering pec with ppc::ended in start_of_simulation", UVM_NONE)
      uvm_callbacks#(phase_proxy_component, phase_ended_callback)::add(ppc, pec);

`uvm_info(get_type_name(), "registering prtec with ppc::ready_to_end in start_of_simulation", UVM_NONE)
      uvm_callbacks#(phase_proxy_component, phase_ready_to_end_callback)::add(ppc, prtec);

            if (report_server.get_severity_count(UVM_WARNING) != warning_count)
`uvm_error(get_type_name(), "Registration resulted in warnings!!!")

   endfunction : start_of_simulation_phase

   virtual task run();
      uvm_test_done.raise_objection(this);
      #10;

      uvm_test_done.drop_objection(this);
   endtask : run

   function void report_phase(uvm_phase phase);
      uvm_report_server svr;
      svr = _global_reporter.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction

endclass : test

module runner;
   initial
      uvm_pkg::run_test();
endmodule
