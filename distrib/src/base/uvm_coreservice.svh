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
typedef class uvm_report_server;
typedef class uvm_default_report_server;
typedef class uvm_root;
typedef class uvm_visitor;
typedef class uvm_component_name_check_visitor;
typedef class uvm_component;

typedef class uvm_tr_database;
typedef class uvm_text_tr_database;

typedef class uvm_comparer;
typedef class uvm_packer;
typedef class uvm_printer;
typedef class uvm_line_printer;
typedef class uvm_tree_printer;
typedef class uvm_table_printer;

`ifndef UVM_CORESERVICE_TYPE
`define UVM_CORESERVICE_TYPE uvm_default_coreservice_t
`endif

typedef class `UVM_CORESERVICE_TYPE;

//----------------------------------------------------------------------
// Class: uvm_coreservice_t
//
// The singleton instance of uvm_coreservice_t provides a common point for all central
// uvm services such as uvm_factory, uvm_report_server, ...
// The service class provides a static <::get> which returns an instance adhering to uvm_coreservice_t
// the rest of the set_<facility> get_<facility> pairs provide access to the internal uvm services
//
// Custom implementations of uvm_coreservice_t can be included in uvm_pkg::*
// and can selected via the define UVM_CORESERVICE_TYPE. They cannot reside in another package.
//----------------------------------------------------------------------

virtual class uvm_coreservice_t;
	// Function: get_factory
	//
	// intended to return the currently enabled uvm factory,
	pure virtual function uvm_factory get_factory();

	// Function: set_factory
	//
	// intended to set the current uvm factory
	pure virtual function void set_factory(uvm_factory f);

	// Function: get_report_server
	// intended to return the current global report_server
	pure virtual function uvm_report_server get_report_server();

	// Function: set_report_server
	// intended to set the central report server to ~server~
	pure virtual function void set_report_server(uvm_report_server server);

	// Function: get_default_tr_database
	// intended to return the current default record database
	pure virtual function uvm_tr_database get_default_tr_database();

	// Function: set_default_tr_database
	// intended to set the current default record database to ~db~
	//
	pure virtual function void set_default_tr_database(uvm_tr_database db);

	// Function: set_component_visitor
	// intended to set the component visitor to ~v~
	// (this visitor is being used for the traversal at end_of_elaboration_phase
	// for instance for name checking)
	pure virtual function void set_component_visitor(uvm_visitor#(uvm_component) v);

	// Function: get_component_visitor
	// intended to retrieve the current component visitor
	// see <set_component_visitor>
	pure virtual function uvm_visitor#(uvm_component) get_component_visitor();

	// Function: get_root
	//
	// returns the uvm_root instance
	pure virtual function uvm_root get_root();

	local static `UVM_CORESERVICE_TYPE inst;
	// Function: get
	//
	// Returns an instance providing the uvm_coreservice_t interface.
	// The actual type of the instance is determined by the define `UVM_CORESERVICE_TYPE.
	//
	//| `define UVM_CORESERVICE_TYPE uvm_blocking_coreservice
	//| class uvm_blocking_coreservice extends uvm_default_coreservice_t;
	//|    virtual function void set_factory(uvm_factory f);
	//|       `uvm_error("FACTORY","you are not allowed to override the factory")
	//|    endfunction
	//| endclass
	//|
	static function uvm_coreservice_t get();
		if(inst==null)
			inst=new;

		return inst;
	endfunction // get

	// Function: get_default_printer
	// return the default printer for uvm (and creates it if necessary)
	pure virtual function uvm_printer get_default_printer();

	// Function: set_default_printer
	// sets the default printer to the new value ~p~
	pure virtual function void set_default_printer(uvm_printer p);

	// Function: get_default_table_printer
	// return the default table printer for uvm (and creates it if necessary)
	pure virtual function uvm_table_printer get_default_table_printer();

	// Function: set_default_table_printer
	// sets the default table printer to the new value ~p~
	pure virtual function void set_default_table_printer(uvm_table_printer p);

	// Function: get_default_line_printer
	// return the default line printer for uvm (and creates it if necessary)
	pure virtual function uvm_line_printer get_default_line_printer();

	// Function: set_default_line_printer
	// sets the default line printer to the new value ~p~
	pure virtual function void set_default_line_printer(uvm_line_printer p);
	
	// Function: get_default_tree_printer
	// return the default tree printer for uvm (and creates it if necessary)
	pure virtual function uvm_tree_printer get_default_tree_printer();

	// Function: set_default_tree_printer
	// sets the default tree printer to the new value ~p~
	pure virtual function void set_default_tree_printer(uvm_tree_printer p);

	// Function: get_default_comparer
	// return the default comparer for uvm (and creates it if necessary)
	pure virtual function uvm_comparer get_default_comparer();

	// Function: set_default_comparer
	// sets the default comparer to the new value ~p~
	pure virtual function void set_default_comparer(uvm_comparer p);

	// Function: get_default_packer
	// return the default packer for uvm (and creates it if necessary)
	pure virtual function uvm_packer get_default_packer();

	// Function: set_default_packer
	// sets the default packer to the new value ~p~
	pure virtual function void set_default_packer(uvm_packer p);

endclass

//----------------------------------------------------------------------
// Class: uvm_default_coreservice_t
//
// uvm_default_coreservice_t provides a default implementation of the
// uvm_coreservice_t API. It instantiates uvm_default_factory, uvm_default_report_server,
// uvm_root.
//----------------------------------------------------------------------
class uvm_default_coreservice_t extends uvm_coreservice_t;
	local uvm_factory factory;

	// Function: get_factory
	//
	// Returns the currently enabled uvm factory.
	// When no factory has been set before, instantiates a uvm_default_factory
	virtual function uvm_factory get_factory();
		if(factory==null) begin
			uvm_default_factory f;
			f=new;
			factory=f;
		end

		return factory;
	endfunction

	// Function: set_factory
	//
	// Sets the current uvm factory.
	// Please note: it is up to the user to preserve the contents of the original factory or delegate calls to the original factory
	virtual function void set_factory(uvm_factory f);
		factory = f;
	endfunction

	local uvm_tr_database tr_database;
	// Function: get_default_tr_database
	// returns the current default record database
	//
	// If no default record database has been set before this method
	// is called, returns an instance of <uvm_text_tr_database>
	virtual function uvm_tr_database get_default_tr_database();
		if (tr_database == null) begin
			process p = process::self();
			uvm_text_tr_database tx_db;
			string s;
			if(p != null)
				s = p.get_randstate();

			tx_db = new("default_tr_database");
			tr_database = tx_db;

			if(p != null)
				p.set_randstate(s);
		end
		return tr_database;
	endfunction : get_default_tr_database

	// Function: set_default_tr_database
	// Sets the current default record database to ~db~
	virtual function void set_default_tr_database(uvm_tr_database db);
		tr_database = db;
	endfunction : set_default_tr_database

	local uvm_report_server report_server;
	// Function: get_report_server
	// returns the current global report_server
	// if no report server has been set before, returns an instance of
	// uvm_default_report_server
	virtual function uvm_report_server get_report_server();
		if(report_server==null) begin
			uvm_default_report_server f;
			f=new;
			report_server=f;
		end

		return report_server;
	endfunction

	// Function: set_report_server
	// sets the central report server to ~server~
	virtual function void set_report_server(uvm_report_server server);
		report_server=server;
	endfunction

	virtual function uvm_root get_root();
		return uvm_root::m_uvm_get_root();
	endfunction

	local uvm_visitor#(uvm_component) _visitor;
	// Function: set_component_visitor
	// sets the component visitor to ~v~
	// (this visitor is being used for the traversal at end_of_elaboration_phase
	// for instance for name checking)
	virtual function void set_component_visitor(uvm_visitor#(uvm_component) v);
		_visitor=v;
	endfunction

	// Function: get_component_visitor
	// retrieves the current component visitor
	// if unset(or ~null~) returns a <uvm_component_name_check_visitor> instance
	virtual function uvm_visitor#(uvm_component) get_component_visitor();
		if(_visitor==null) begin
			uvm_component_name_check_visitor v = new("name-check-visitor");
			_visitor=v;
		end
		return _visitor;
	endfunction

	local uvm_printer printer_;
	// is unset this implementation provides the a table printer
	virtual function uvm_printer get_default_printer();
		if(printer_==null) begin
			printer_=get_default_table_printer();
		end
		return printer_;
	endfunction
	virtual function void set_default_printer(uvm_printer p);
		printer_=p;
	endfunction

	local uvm_table_printer table_printer_;
	virtual function uvm_table_printer get_default_table_printer();
		if(table_printer_==null) begin
			uvm_table_printer p_=new();
			table_printer_=p_;
		end
		return table_printer_;
	endfunction
	virtual function void set_default_table_printer(uvm_table_printer p);
		table_printer_=p;
	endfunction

	local uvm_line_printer line_printer_;
	virtual function uvm_line_printer get_default_line_printer();
		if(line_printer_==null) begin
			uvm_line_printer p_=new();
			line_printer_=p_;
		end
		return line_printer_;
	endfunction
	virtual function void set_default_line_printer(uvm_line_printer p);
		line_printer_=p;
	endfunction
	
	local uvm_tree_printer tree_printer_;
	virtual function uvm_tree_printer get_default_tree_printer();
		if(tree_printer_==null) begin
			uvm_tree_printer p_=new();
			tree_printer_=p_;
		end
		return tree_printer_;
	endfunction
	virtual function void set_default_tree_printer(uvm_tree_printer p);
		tree_printer_=p;
	endfunction

	local uvm_comparer comparer_;
	virtual function uvm_comparer get_default_comparer();
		if(comparer_==null) begin
			uvm_comparer p_=new(); // FIXME: to stick with the uvm naming the API should be in uvm_comparer and the default in uvm_default_comparer
			comparer_=p_;
		end
		return comparer_;
	endfunction	
	virtual function void set_default_comparer(uvm_comparer p);
		comparer_=p;
	endfunction

	local uvm_packer packer_;
	virtual function uvm_packer get_default_packer();
		if(packer_==null) begin
			uvm_packer p_=new(); // FIXME: to stick with the uvm naming the API should be in uvm_packer and the default in uvm_"default"_packer
			packer_=p_;
		end
		return packer_;
	endfunction
	virtual function void set_default_packer(uvm_packer p);
		packer_=p;
	endfunction
endclass


