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
package uvm_delegate_factory_pkg;
	import uvm_pkg::*;
	
	class uvm_delegate_factory extends uvm_factory;
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
		virtual function void print (int all_types=1);
			delegate.print(all_types);
		endfunction
	endclass 
endpackage
