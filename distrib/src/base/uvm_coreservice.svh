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
typedef class uvm_factory;
typedef class uvm_default_factory;


`ifndef UVM_CORESERVICE_TYPE
`define UVM_CORESERVICE_TYPE uvm_coreserviceT
`endif

//----------------------------------------------------------------------
// Class: uvm_coreserviceT
//
// The singleton instance of uvm_coreserviceT provides a common point for all central 
// uvm services such as factory, uvm_reporter, ...
// The service class provides a static ::get which return an instance adhering to uvm_coreserviceT
// the rest of the set<facility> get<facility> pairs provide access to the internal uvm services
//----------------------------------------------------------------------

class uvm_coreserviceT;
	//returns the global uvm factory
	local uvm_factory factory;

  // Function: getFactory
  //
  // returns the currently enabled uvm factory
	virtual function uvm_factory getFactory();
		if(factory==null) begin
			uvm_default_factory f;
			f=new;
			factory=f;
		end 

		return factory;
	endfunction

  // Function: setFactory
  //
  // sets the current uvm factory
  // please note: its upto the user to preserve the contents of the original factory or delegate calls to to the original factory
	virtual function void setFactory(uvm_factory f);
		factory = f;
	endfunction 
	
	
  // Function: get
  //
  // returns an instance providing the 	uvm_coreserviceT interface
  // the actual type of the instance is determined by the define `UVM_CORESERVICE_TYPE
  //
  //| `define UVM_CORESERVICE_TYPE uvm_blocking_coreservice
  //| class uvm_blocking_coreservice extends uvm_coreserviceT;
  //| 	virtual function void setFactory(uvm_factory f);
  //| 		`uvm_error("FACTORY","you are not allowed to override the factory")
  //|   endfunction
  //| endclass
  //|
	local static `UVM_CORESERVICE_TYPE inst;
	static function uvm_coreserviceT get();
		if(inst==null) begin
			inst=new;
		end 

		return inst;
	endfunction
endclass

//------------------------------------------------------------------------------
// Variable: uvm_coreservice
//
// this is the root uvm core service provider which can be queried for various uvm services 
// like factory, report etc.
//------------------------------------------------------------------------------

const  uvm_coreserviceT uvm_coreservice = uvm_coreserviceT::get();
