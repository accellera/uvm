//----------------------------------------------------------------------
//   Copyright 2010 Synopsys, Inc.
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

class mem_init_from_file_seq extends uvm_reg_sequence;

   // Must set these two vars before starting sequence. This sequence
   // could be enhanced to use get_config_string/object.
   string fname = "mem.dat";
   reg_sys_xa0 model = null;

   `uvm_object_utils(mem_init_from_file_seq)

   function new(string name = "mem_init_from_file_seq");
      super.new(name);
   endfunction: new

   virtual task body();
      int fp, lineno = 0;
      string line;

      if (model == null && !$cast(model,super.model))
          `uvm_fatal("mem_init_from_file_seq",
              {"Must specify register model of type 'reg_sys_xa0'",
               "by assigning member 'model' before starting sequence"})

      if (!$value$plusargs("MEMFILE=%s",fname))
         `uvm_warning("mem_init_from_file_seq", {"Reading default file '",
              fname,"', as none was specified. You can specify the file ",
               "from the command line using +MEMFILE=<file>, or you ",
               " can assign member 'fname' before starting this sequence."})

      `uvm_info("mem_init_from_file_seq",
                {"Initializing ", model.xbus_rf.mem.get_full_name(),
                 " from file '", fname, "'"}, UVM_LOW);
      
      fp = $fopen(fname, "r");
      if (fp == 0) begin
         `uvm_error("mem_init_from_file_seq",
                    {"Unable to open file '", fname, "' for reading"});
         return;
      end

      while ($fgets(line, fp)) begin
         int idx, data;
         uvm_status_e status;
         
         lineno++;
         if (!$sscanf(line, " %h %h", idx, data)) begin
            `uvm_error("mem_init_from_file_seq",
               $psprintf("Syntax error in file %s, line %0d: \"%s\"",
                          fname, lineno, line));
            continue;
         end

         model.xbus_rf.mem.write(status, idx, data, .parent(this));
      end

      $fclose(fp);

   endtask
endclass


class mem_rand_init_seq extends uvm_reg_sequence;

   `uvm_object_utils(mem_rand_init_seq)

   reg_sys_xa0 model;

   function new(string name = "mem_rand_init_seq");
      super.new(name);
   endfunction: new

   virtual task body();
      uvm_status_e status;
      int idx;

      if (model == null && super.model != null)
        if(!$cast(model,super.model))
          `uvm_fatal("mem_init_from_file_seq",
              {"Must specify register model of type 'reg_sys_xa0'",
               "by assigning member 'model' before starting sequence"})

      `uvm_info("mem_rand_init_seq", {"Initializing ",
          model.xbus_rf.mem.get_full_name(), " with random data"}, UVM_LOW);
      
      idx = model.xbus_rf.mem.get_size();
      while (idx > 0) begin
         idx--;
         model.xbus_rf.mem.write(status, idx, $urandom(), .parent(this));
      end
   endtask
endclass
