// 
// -------------------------------------------------------------
//    Copyright 2010 Cadence.
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
//    permissions and limitations under the License.
// -------------------------------------------------------------
//

//
// TITLE: Register Backdoor Access Test Sequence
//

//
// class: uvm_reg_mem_access_backdoor_check_seq
//
// Verify the accessibility of a registers hdl backdoor path
// by obtaining a vpi handle to the specified hdl path. This sequence can be used   
// to check that the specified backdoor pathes are indeed accessible by the simulator.
//
// The check is performed for all defined abstraction kinds for a particular register.
// 
// If a path is not accessible by the simulator it cannot be used for 
// read/write backdoor accesses. In that case a warning is produced. 
// A simulator may have more fine granular access permissions such as separate 
// read or write permissions. These extra access permissions are NOT checked.
//
// The test is performed in zero time and does not require any reads/writes to/from the DUT
//
// TODO add filtering capabilities
//
class uvm_reg_mem_access_backdoor_check_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

    `uvm_object_utils(uvm_reg_mem_access_backdoor_check_seq)

    function new(string name="uvm_reg_mem_access_backdoor_check_seq");
        super.new(name);
    endfunction

    virtual task body();

        if (model == null) begin
            uvm_report_error("RegModel", "Register model handle is null");
            return;
        end

        uvm_report_info("RegModel", {"checking valid hdl backdoor pathes for all registers/memories with a hdl backdoor defined for within ",model.get_full_name()},UVM_LOW);

        do_block(model);
        
        uvm_report_info("RegModel", "hdl backdoor pathes validation completed ",UVM_LOW);
        
    endtask: body


    // Any additional steps required to reset the block
    // and make it accessible
    virtual task reset_blk(uvm_reg_block blk);
    endtask

    protected virtual function void do_block(uvm_reg_block blk);
        uvm_reg regs[$];
        uvm_mem mems[$];

        // Iterate over all registers, checking accesses
        blk.get_registers(regs, UVM_NO_HIER);
        foreach (regs[i]) 
            if (regs[i].get_backdoor() || regs[i].has_hdl_path())
            	check_reg(regs[i]);
        
        blk.get_memories(mems, UVM_NO_HIER);
        foreach (mems[i]) 
            if (mems[i].get_backdoor() || mems[i].has_hdl_path())
            	check_mem(mems[i]);

    endfunction: do_block
    
    protected virtual function void check_reg(uvm_reg r);
    	uvm_reg_backdoor b = r.get_backdoor();
    	uvm_hdl_path_concat paths[$];
    	string hdl_abstractions[$];
    	
    	r.get_hdl_path_kinds(hdl_abstractions);
    	foreach(hdl_abstractions[kind])
    	begin
    		r.get_full_hdl_path(paths, hdl_abstractions[kind]);
    		foreach(paths[p]) begin
                uvm_hdl_path_concat path=paths[p];
                foreach (path.slices[j]) 
                begin
                        string p_ = path.slices[j].path;
                        if(!uvm_hdl_check_path(p_))
                            uvm_report_warning("RegModel",$psprintf("hdl path %s for register %s does not seem to be accessible",
                            p_,r.get_full_name()));
                end
    	   end
        end
    endfunction
 
    protected virtual function void check_mem(uvm_mem r);
        uvm_reg_backdoor b = r.get_backdoor();
        uvm_hdl_path_concat paths[$];
        string hdl_abstractions[$];
        
        r.get_hdl_path_kinds(hdl_abstractions);
        foreach(hdl_abstractions[kind])
        begin
            r.get_full_hdl_path(paths, hdl_abstractions[kind]);
            foreach(paths[p]) begin
                uvm_hdl_path_concat path=paths[p];
                foreach (path.slices[j]) 
                begin
                        string p_ = path.slices[j].path;
                        if(!uvm_hdl_check_path(p_))
                            uvm_report_warning("RegModel",$psprintf("hdl path %s for memory %s does not seem to be accessible",
                            p_,r.get_full_name()));
                end
           end
        end
    endfunction   
endclass: uvm_reg_mem_access_backdoor_check_seq
