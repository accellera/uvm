//
// -------------------------------------------------------------
//    Copyright 2004-2009 Synopsys, Inc.
//    Copyright 2010 Mentor Graphics Corp.
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

//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_reg_backdoor_callbacks
//
//------------------------------------------------------------------------------

virtual class uvm_ral_reg_backdoor_callbacks;

    string fname = "";
    int lineno = 0;

    virtual task pre_read(input uvm_ral_reg rg,
                          input uvm_sequence_base parent = null,
                          input uvm_object extension = null);
    endtask

    virtual task post_read(input uvm_ral_reg       rg,
                           inout uvm_ral::status_e status,
                           inout uvm_ral_data_t    data,
                           input uvm_sequence_base parent = null,
                           input uvm_object extension = null);
    endtask

    virtual task pre_write(input uvm_ral_reg       rg,
                           inout uvm_ral_data_t    data,
                           input uvm_sequence_base parent = null,
                           input uvm_object extension = null);
    endtask

    virtual task post_write(input uvm_ral_reg        rg,
                            inout uvm_ral::status_e status,
                            input uvm_ral_data_t    data,
                            input uvm_sequence_base parent = null,
                            input uvm_object extension = null);
    endtask

    virtual function uvm_ral_data_t  encode(uvm_ral_data_t data);
      return 0;
    endfunction

    virtual function uvm_ral_data_t  decode(uvm_ral_data_t data);
      return 0;
    endfunction


endclass


//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_mem_backdoor_callbacks
//
//------------------------------------------------------------------------------


virtual class uvm_ral_mem_backdoor_callbacks;

    string fname = "";
    int lineno = 0;
    
    virtual task pre_read(input uvm_ral_mem       mem,
                          inout uvm_ral_addr_t    offset,
                          input uvm_sequence_base parent = null,
                          input uvm_object extension = null);
    endtask

    virtual task post_read(input uvm_ral_mem       mem,
                           inout uvm_ral::status_e status,
                           inout uvm_ral_addr_t    offset,
                           inout uvm_ral_data_t    data,
                           input uvm_sequence_base parent = null,
                           input uvm_object extension = null);
    endtask

    virtual task pre_write(input uvm_ral_mem       mem,
                           inout uvm_ral_addr_t    offset,
                           inout uvm_ral_data_t    data,
                           input uvm_sequence_base parent = null,
                           input uvm_object extension = null);
    endtask

    virtual task post_write(input uvm_ral_mem       mem,
                            inout uvm_ral::status_e status,
                            inout uvm_ral_addr_t    offset,
                            input uvm_ral_data_t    data,
                            input uvm_sequence_base parent = null,
                            input uvm_object extension = null);
    endtask

    virtual function uvm_ral_data_t  encode(uvm_ral_data_t  data);
      return 0;
    endfunction

    virtual function uvm_ral_data_t  decode(uvm_ral_data_t  data);
      return 0;
    endfunction

endclass


//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_reg_backdoor
//
//------------------------------------------------------------------------------

virtual class uvm_ral_reg_backdoor;
   string fname = "";
   int lineno = 0;
   uvm_ral_reg rg;
   local uvm_ral_reg_backdoor_callbacks backdoor_callbacks[$];

   local process update_thread;

   extern function new(input uvm_ral_reg rg=null);

   extern virtual task write(output uvm_ral::status_e status,
                             input  uvm_ral_data_t    data,
                             input uvm_sequence_base  parent = null,
                             input uvm_object extension = null);

   extern virtual task read(output uvm_ral::status_e status,
                            output uvm_ral_data_t    data,
                            input uvm_sequence_base  parent = null,
                            input uvm_object extension = null);

   extern virtual function uvm_ral::status_e read_func(
                            output uvm_ral_data_t    data,
                            input uvm_sequence_base  parent,
                            input uvm_object         extension);

   extern virtual function bit is_auto_updated(string fieldname);

   extern virtual task wait_for_change();

   extern function void start_update_thread(uvm_ral_reg rg);

   extern function void kill_update_thread();

   extern virtual task pre_read(uvm_sequence_base parent = null,
   input uvm_object extension = null);

   extern virtual task post_read(inout uvm_ral::status_e status,
                                 inout uvm_ral_data_t    data,
                                 input uvm_sequence_base parent = null,
                                 input uvm_object extension = null);

   extern virtual task pre_write(inout uvm_ral_data_t    data,
                                 input uvm_sequence_base parent = null,
                                 input uvm_object extension = null);

   extern virtual task post_write(inout uvm_ral::status_e status,
                                  input uvm_ral_data_t    data,
                                  input uvm_sequence_base parent = null,
                                  input uvm_object extension = null);

   extern virtual function void append_callback(uvm_ral_reg_backdoor_callbacks cb,
                                                string fname = "",
                                                int lineno = 0);

   extern virtual function void prepend_callback(uvm_ral_reg_backdoor_callbacks cb,
                                                 string fname = "",
                                                 int lineno = 0);

   extern virtual function void unregister_callback(uvm_ral_reg_backdoor_callbacks cb,
                                                    string fname = "",
                                                    int lineno = 0);

endclass: uvm_ral_reg_backdoor


//------------------------------------------------------------------------------
//
// CLASS: uvm_ral_mem_backdoor
//
//------------------------------------------------------------------------------

virtual class uvm_ral_mem_backdoor;
   string fname = "";
   int lineno = 0;
   uvm_ral_mem mem;
   local uvm_ral_mem_backdoor_callbacks backdoor_callbacks[$];

   extern function new(input uvm_ral_mem mem=null);

   extern virtual task write(output uvm_ral::status_e              status,
                             input  uvm_ral_addr_t  offset,
                             input  uvm_ral_data_t  data,
                             input  uvm_sequence_base parent = null,
                             input uvm_object extension = null);

   extern virtual task read(output uvm_ral::status_e              status,
                            input  uvm_ral_addr_t  offset,
                            output uvm_ral_data_t  data,
                            input  uvm_sequence_base parent = null,
                            input uvm_object extension = null);

   extern virtual function uvm_ral::status_e read_func(
                                       input uvm_ral_addr_t    offset,
                                       output uvm_ral_data_t   data,
                                       input uvm_sequence_base parent,
                                       input uvm_object        extension);

   extern virtual task pre_read(inout uvm_ral_addr_t  offset,
                                input uvm_sequence_base parent = null,
                                input uvm_object extension = null);

   extern virtual task post_read(inout uvm_ral::status_e status,
                                 inout uvm_ral_addr_t  offset,
                                 inout uvm_ral_data_t  data,
                                 input uvm_sequence_base parent = null,
                                 input uvm_object extension = null);

   extern virtual task pre_write(inout uvm_ral_addr_t  offset,
                                 inout uvm_ral_data_t  data,
                                 input uvm_sequence_base parent = null,
                                 input uvm_object extension = null);

   extern virtual task post_write(inout uvm_ral::status_e status,
                                  inout uvm_ral_addr_t  offset,
                                  input uvm_ral_data_t  data,
                                  input uvm_sequence_base parent = null,
                                  input uvm_object extension = null);

   extern virtual function void append_callback(uvm_ral_mem_backdoor_callbacks cb,
                                                string fname = "",
                                                int lineno = 0);

   extern virtual function void prepend_callback(uvm_ral_mem_backdoor_callbacks cb,
                                                 string fname = "",
                                                 int lineno = 0);

   extern virtual function void unregister_callback(uvm_ral_mem_backdoor_callbacks cb,
                                                    string fname = "",
                                                    int lineno = 0);

endclass: uvm_ral_mem_backdoor


//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

function bit uvm_ral_reg_backdoor::is_auto_updated(string fieldname);
   `uvm_fatal("RAL", "uvm_ral_reg_backdoor::is_auto_updated() method has not been overloaded");
  return 0;
endfunction

task uvm_ral_reg_backdoor::wait_for_change();
   `uvm_fatal("RAL", "uvm_ral_reg_backdoor::wait_for_change() method has not been overloaded");
endtask

function void uvm_ral_reg_backdoor::start_update_thread(uvm_ral_reg rg);
   if (this.update_thread != null) begin
      this.kill_update_thread();
   end

   fork
      begin
         uvm_ral_field fields[$];

         this.update_thread = process::self();
         rg.get_fields(fields);
         forever begin
            uvm_ral::status_e status;
            uvm_ral_data_t  val;
            this.read(status, val, null);
            if (status != uvm_ral::IS_OK) begin
               `uvm_error("RAL", $psprintf("Backdoor read of register '%s' failed.",
                          rg.get_name()));
            end
            foreach (fields[i]) begin
               if (this.is_auto_updated(fields[i].get_name())) begin
                  uvm_ral_data_t  fld_val
                     = val >> fields[i].get_lsb_pos_in_register();
                  fld_val = fld_val & ((1 << fields[i].get_n_bits())-1);
                  void'(fields[i].predict(fld_val));
               end
            end
            this.wait_for_change();
         end
      end
   join_none
endfunction

function void uvm_ral_reg_backdoor::kill_update_thread();
   if (this.update_thread != null) begin
      this.update_thread.kill();
      this.update_thread = null;
   end
endfunction

function uvm_ral_reg_backdoor::new(input uvm_ral_reg rg=null);

    this.rg = rg;

endfunction: new


task uvm_ral_reg_backdoor::write(output uvm_ral::status_e status,
                                 input  uvm_ral_data_t    data,
                                 input  uvm_sequence_base parent = null,
                                 input uvm_object extension = null);

   `uvm_fatal("RAL", "uvm_ral_reg_backdoor::write() method has not been overloaded");

endtask: write


task uvm_ral_reg_backdoor::read(output uvm_ral::status_e status,
                                output uvm_ral_data_t    data,
                                input  uvm_sequence_base parent = null,
                                input uvm_object extension = null);

  status = read_func(data,parent,extension);
endtask: read


function uvm_ral::status_e uvm_ral_reg_backdoor::read_func(
                            output uvm_ral_data_t    data,
                            input uvm_sequence_base  parent,
                            input uvm_object         extension);
   `uvm_fatal("RAL", "uvm_ral_reg_backdoor::read() method has not been overloaded");
   return uvm_ral::ERROR;
endfunction


task uvm_ral_reg_backdoor::pre_read(input uvm_sequence_base parent = null,
                                    input uvm_object extension = null);

    foreach (this.backdoor_callbacks[i])
        begin
            this.backdoor_callbacks[i].pre_read(this.rg, parent, extension);
        end

endtask: pre_read


task uvm_ral_reg_backdoor::post_read(inout uvm_ral::status_e status,
                                     inout uvm_ral_data_t    data,
                                     input uvm_sequence_base parent = null,
                                     input uvm_object extension = null);

    foreach (this.backdoor_callbacks[i])
        begin
            data = this.backdoor_callbacks[i].decode(data);
            this.backdoor_callbacks[i].post_read(this.rg, status, data, parent, extension);
        end

endtask: post_read


task uvm_ral_reg_backdoor::pre_write(inout uvm_ral_data_t    data,
                                     input uvm_sequence_base parent = null,
                                     input uvm_object extension = null);

    foreach (this.backdoor_callbacks[i])
        begin
            this.backdoor_callbacks[i].pre_write(this.rg, data, parent, extension);
            data = this.backdoor_callbacks[i].encode(data);
        end
        
endtask: pre_write


task uvm_ral_reg_backdoor::post_write(inout uvm_ral::status_e status,
                                      input uvm_ral_data_t    data,
                                      input uvm_sequence_base parent = null,
                                      input uvm_object extension = null);

    foreach (this.backdoor_callbacks[i])
        begin
            this.backdoor_callbacks[i].post_write(this.rg, status, data, parent, extension);
        end    

endtask: post_write


function void uvm_ral_reg_backdoor::append_callback(uvm_ral_reg_backdoor_callbacks cb,
                                                    string fname = "",
                                                    int lineno = 0);

    foreach (this.backdoor_callbacks[i])
        begin
            if (this.backdoor_callbacks[i] == cb)
            begin
            `uvm_warning("RAL", $psprintf("Callback has already been registered with register"));
             return;
            end
           end

        // Prepend new callback
        cb.fname = fname;
        cb.lineno = lineno;
        this.backdoor_callbacks.push_back(cb);    
        
endfunction: append_callback


function void uvm_ral_reg_backdoor::prepend_callback(uvm_ral_reg_backdoor_callbacks cb,
                                                     string fname = "",
                                                     int lineno = 0);

    foreach (this.backdoor_callbacks[i])
        begin
            if (this.backdoor_callbacks[i] == cb)
            begin
            `uvm_warning("RAL", $psprintf("Callback has already been registered with register"));
             return;
            end
           end
            
        // Prepend new callback
        cb.fname = fname;
        cb.lineno = lineno;
        this.backdoor_callbacks.push_front(cb);    
        
endfunction: prepend_callback



function void uvm_ral_reg_backdoor::unregister_callback(uvm_ral_reg_backdoor_callbacks cb,
                                                        string fname = "",
                                                        int lineno = 0);

    foreach (this.backdoor_callbacks[i])
        begin
            if (this.backdoor_callbacks[i] == cb)
            begin
                int j = i;
             // Unregister it
             this.backdoor_callbacks.delete(j);
             return;
            end
       end

   `uvm_warning("RAL", $psprintf("Callback was not registered with register "));

endfunction: unregister_callback


function uvm_ral_mem_backdoor::new(input uvm_ral_mem mem=null);
    this.mem = mem;
endfunction: new

task uvm_ral_mem_backdoor::write(output uvm_ral::status_e status,
                                 input  uvm_ral_addr_t    offset,
                                 input  uvm_ral_data_t    data,
                                 input  uvm_sequence_base parent = null,
                                 input  uvm_object        extension = null);

   `uvm_fatal("RAL", "uvm_ral_mem_backdoor::write() method has not been overloaded");

endtask: write


task uvm_ral_mem_backdoor::read(output uvm_ral::status_e status,
                                input  uvm_ral_addr_t    offset,
                                output uvm_ral_data_t    data,
                                input  uvm_sequence_base parent = null,
                                input  uvm_object        extension = null);

   status = read_func(offset,data,parent,extension);
endtask: read


function uvm_ral::status_e uvm_ral_mem_backdoor::read_func(
                                       input uvm_ral_addr_t    offset,
                                       output uvm_ral_data_t   data,
                                       input uvm_sequence_base parent,
                                       input uvm_object        extension);
   `uvm_fatal("RAL", "uvm_ral_mem_backdoor::read_func() method has not been overloaded");
   return uvm_ral::ERROR;
endfunction


task uvm_ral_mem_backdoor::pre_read(inout uvm_ral_addr_t    offset,
                                    input uvm_sequence_base parent = null,
                                    input uvm_object        extension = null);

    foreach (this.backdoor_callbacks[i])
        begin
            this.backdoor_callbacks[i].pre_read(this.mem, offset, parent, extension);
        end

endtask: pre_read


task uvm_ral_mem_backdoor::post_read(inout uvm_ral::status_e status,
                                     inout uvm_ral_addr_t    offset,
                                     inout uvm_ral_data_t    data,
                                     input uvm_sequence_base parent = null,
                                     input uvm_object        extension = null);

    foreach (this.backdoor_callbacks[i])
        begin
            data = this.backdoor_callbacks[i].decode(data);
            this.backdoor_callbacks[i].post_read(this.mem, status, offset, data, parent, extension);
        end

endtask: post_read


task uvm_ral_mem_backdoor::pre_write(inout uvm_ral_addr_t    offset,
                                     inout uvm_ral_data_t    data,
                                     input uvm_sequence_base parent = null,
                                     input uvm_object        extension = null);

    foreach (this.backdoor_callbacks[i])
        begin
            this.backdoor_callbacks[i].pre_write(this.mem, offset, data, parent, extension);
            data = this.backdoor_callbacks[i].encode(data);
        end
        
endtask: pre_write


task uvm_ral_mem_backdoor::post_write(inout uvm_ral::status_e status,
                                      inout uvm_ral_addr_t    offset,
                                      input uvm_ral_data_t    data,
                                      input uvm_sequence_base parent = null,
                                      input uvm_object        extension = null);

    foreach (this.backdoor_callbacks[i])
        begin
            this.backdoor_callbacks[i].post_write(this.mem, status, offset, data, parent, extension);
        end    

endtask: post_write


function void uvm_ral_mem_backdoor::append_callback(uvm_ral_mem_backdoor_callbacks cb,
                                                    string fname = "",
                                                    int lineno = 0);

    foreach (this.backdoor_callbacks[i])
        begin
            if (this.backdoor_callbacks[i] == cb)
            begin
            `uvm_warning("RAL", $psprintf("Callback has already been registered with register"));
             return;
            end
           end

        // Prepend new callback
        cb.fname = fname;
        cb.lineno = lineno;
        this.backdoor_callbacks.push_back(cb);    
        
endfunction: append_callback


function void uvm_ral_mem_backdoor::prepend_callback(uvm_ral_mem_backdoor_callbacks cb,
                                                     string fname = "",
                                                     int lineno = 0);

    foreach (this.backdoor_callbacks[i])
        begin
            if (this.backdoor_callbacks[i] == cb)
            begin
            `uvm_warning("RAL", $psprintf("Callback has already been registered with register"));
             return;
            end
           end
            
        // Prepend new callback
        cb.fname = fname;
        cb.lineno = lineno;
        this.backdoor_callbacks.push_front(cb);    
        
endfunction: prepend_callback



function void uvm_ral_mem_backdoor::unregister_callback(uvm_ral_mem_backdoor_callbacks cb,
                                                        string fname = "",
                                                        int lineno = 0);

    foreach (this.backdoor_callbacks[i])
        begin
            if (this.backdoor_callbacks[i] == cb)
            begin
                int j = i;
             // Unregister it
             this.backdoor_callbacks.delete(j);
             return;
            end
       end

   `uvm_warning("RAL", $psprintf("Callback was not registered with register "));

endfunction: unregister_callback


