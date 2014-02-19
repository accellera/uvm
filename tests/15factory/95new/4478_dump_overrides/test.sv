//----------------------------------------------------------------------
//   Copyright 2013 Cadence Design Inc
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
`include "../4478_tracing_factory/uvm_delegate_factory_pkg.sv"

module test;
	import uvm_pkg::*;  
	import uvm_delegate_factory_pkg::*;
    `include "uvm_macros.svh"

	class a extends uvm_component;
		`uvm_component_utils(a)
		function new(string name,uvm_component parent );
			super.new(name,parent);
		endfunction
	endclass

	class b extends a;
		`uvm_component_utils(b)
		function new(string name,uvm_component parent );
			super.new(name,parent);
		endfunction
	endclass

	class c extends a;
		`uvm_component_utils(c)
		function new(string name,uvm_component parent );
			super.new(name,parent);
		endfunction
	endclass

	class d extends a;
		`uvm_component_utils(d)
		function new(string name,uvm_component parent );
			super.new(name,parent);
		endfunction
	endclass

	class uvm_override_logging_factory extends uvm_default_factory;
		uvm_factory delegate;

		virtual function void register (uvm_object_wrapper obj);
			delegate.register(obj);
		endfunction 

		virtual function void set_inst_override_by_type (uvm_object_wrapper original_type,
				uvm_object_wrapper override_type,
				string full_inst_path);
			delegate.set_inst_override_by_type(original_type,override_type,full_inst_path);
		endfunction 

		virtual function void set_inst_override_by_name (string original_type_name,
				string override_type_name,
				string full_inst_path);
			delegate.set_inst_override_by_name(original_type_name,override_type_name,full_inst_path);
		endfunction

		virtual function void set_type_override_by_type (uvm_object_wrapper original_type,
				uvm_object_wrapper override_type,
				bit replace=1);
			delegate.set_type_override_by_type(original_type, override_type, replace);
		endfunction


		virtual function void set_type_override_by_name (string original_type_name,
				string override_type_name,
				bit replace=1);
			delegate.set_type_override_by_name(original_type_name, override_type_name, replace);
		endfunction 

		virtual function uvm_object create_object_by_type    (uvm_object_wrapper requested_type,  
				string parent_inst_path="",
				string name=""); 
			return delegate.create_object_by_type(requested_type,parent_inst_path,name);
		endfunction 

		virtual function uvm_component create_component_by_type (uvm_object_wrapper requested_type,  
				string parent_inst_path="",
				string name, 
				uvm_component parent);
			return delegate.create_component_by_type(requested_type,parent_inst_path,name,parent);
		endfunction 

		virtual function uvm_object    create_object_by_name    (string requested_type_name,  
				string parent_inst_path="",
				string name=""); 
			return delegate.create_object_by_name(requested_type_name,parent_inst_path,name);
		endfunction 

		virtual function uvm_component create_component_by_name (string requested_type_name,  
				string parent_inst_path="",
				string name, 
				uvm_component parent);
			return delegate.create_component_by_name(requested_type_name,parent_inst_path,name,parent);
		endfunction 

		virtual function void debug_create_by_type (uvm_object_wrapper requested_type,
				string parent_inst_path="",
				string name="");
			delegate.debug_create_by_type(requested_type, parent_inst_path, name);
		endfunction 

		virtual function void debug_create_by_name (string requested_type_name,
				string parent_inst_path="",
				string name="");
			delegate.debug_create_by_name(requested_type_name, parent_inst_path, name);
		endfunction 

		virtual function uvm_object_wrapper find_override_by_type (uvm_object_wrapper requested_type, string full_inst_path);
			return delegate.find_override_by_type(requested_type, full_inst_path);
		endfunction 

		virtual function uvm_object_wrapper find_override_by_name (string requested_type_name, string full_inst_path);
			return delegate.find_override_by_name(requested_type_name, full_inst_path);
		endfunction

		virtual function uvm_object_wrapper find_wrapper_by_name            (string type_name);
			return delegate.find_wrapper_by_name(type_name);
		endfunction

		virtual function void prints(string s, uvm_factory_override q[$],int all_types);
			foreach(q[idx])
				if(all_types || q[idx].used>0)
					`uvm_info("FACTORY",$sformatf(s,
							q[idx].full_inst_path,
							q[idx].orig_type_name,
							q[idx].ovrd_type_name,
							q[idx].used),UVM_NONE)  
		endfunction 

		virtual function void print (int all_types=1);
			uvm_default_factory f;
			assert($cast(f,delegate)) else `uvm_error("FACTORY","only works with the uvm_default_factory")
			
			prints("type-override (inst matching %s) with override %s -> %s used %0d time(s)",f.m_type_overrides,all_types);

			foreach(f.m_inst_override_name_queues[inst]) begin
				uvm_factory_queue_class fq = f.m_inst_override_name_queues[inst];
				prints("inst-override for inst matching %s with override %s -> %s used %0d time(s)",fq.queue,all_types);
			end 
			
			foreach(f.m_inst_override_queues[idx]) begin
				uvm_factory_queue_class fq = f.m_inst_override_queues[idx];
				prints("inst-override for inst matching %s with override %s -> %s used %0d time(s)",fq.queue,all_types);
			end 			
			delegate.print(all_types);
		endfunction
	endclass    

	initial begin
		static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

		uvm_override_logging_factory f;
		uvm_coreservice_t cs;
		uvm_factory factory;
		cs = uvm_coreservice_t::get();                                                     
		factory = cs.get_factory();
  		
		// create new factory
		f = new();
		// set the delegate
		f.delegate=factory;
		// enable new factory
		cs_.set_factory(f);

		// do an override
		a::type_id::set_type_override(b::get_type());
		a::type_id::set_inst_override(c::get_type(),"some.path");
		f.set_inst_override_by_name("b", "d","in.some.path");
		b::type_id::set_type_override(c::get_type());

		// now dump the info
		f.print(0);
		f.print();
		
		// create an object...
		begin
			uvm_component ct;
			ct = a::type_id::create("comp", null);
			`uvm_info("TEST",{"produced an instance of type ",ct.get_type_name()},UVM_NONE) 
		end	
		
		// print again
		f.print(0);
		f.print();
		
		begin
			uvm_report_server svr;
			svr = uvm_report_server::get_server();

			if (svr.get_id_count("FACTORY")==10 && svr.get_severity_count(UVM_ERROR)==0)
				$write("** UVM TEST PASSED **\n");
			else
				$write("!! UVM TEST FAILED !!\n");

			svr.report_summarize();

		end 
	end 

endmodule
