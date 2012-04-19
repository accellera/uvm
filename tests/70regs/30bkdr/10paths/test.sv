//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Mentor Graphics Corporation
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


program top;

    import uvm_pkg::*;
`include "uvm_macros.svh"

    class r1_typ extends uvm_reg;

        function new(string name = "r1_typ");
            super.new(name,32,UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
        endfunction
   
        `uvm_object_utils(r1_typ)
   
    endclass


    class b1_typ extends uvm_reg_block;

        rand r1_typ r1; 

        function new(string name = "b1_typ");
            super.new(name,UVM_NO_COVERAGE);
        endfunction

        virtual function void build();

            r1 = r1_typ::type_id::create("r1");
            r1.build();
            r1.configure(this,null,"r1");
        endfunction
   
        `uvm_object_utils(b1_typ)
   
    endclass


    class top_blk extends uvm_reg_block;

        rand b1_typ b1; 

        function new(string name = "top_blk");
            super.new(name,UVM_NO_COVERAGE);
        endfunction

        virtual function void build();

            b1 = b1_typ::type_id::create("b1");
            b1.build();
            b1.configure(this,"b1");
        endfunction
   
        `uvm_object_utils(top_blk)
   
    endclass


    function void check_roots(string name,
                              string roots[$],
                              string exp[]);
        $write("Path(s) to %s:\n", name);
        foreach (roots[i]) begin
            $write("   %s\n", roots[i]);
            if (roots[i] != exp[i]) begin
                `uvm_error("ROOTS", $sformatf(" Root does not match \"%s\".", exp[i]));
            end
        end
   
    endfunction


    function void check_paths(string name,
                              uvm_hdl_path_concat paths[$],
                              uvm_hdl_path_concat exp[]);
        $write("Path(s) to %s:\n", name);
       if (paths.size() != exp.size()) begin
`uvm_error("Test", $sformatf("%0d paths found instead of the expected %0d.",
                             paths.size(), exp.size()))
          
          foreach (paths[i]) begin
             $write("   %s\n", uvm_hdl_concat2string(paths[i]));
          end
          $write("vs.\n");
          foreach (exp[i]) begin
             $write("   %s\n", uvm_hdl_concat2string(exp[i]));
          end
          return;
       end
        foreach (paths[i]) begin
            uvm_hdl_path_concat concat;
            uvm_hdl_path_concat exp_sl;

            concat = paths[i];
            exp_sl = exp[i];

            $write("   %s\n", uvm_hdl_concat2string(concat));
            foreach (concat.slices[j]) begin
                if (concat.slices[j].path != exp_sl.slices[j].path) begin
                    `uvm_error("PATHS", $sformatf(" Path does not match \"%s\".", exp_sl.slices[j].path));
                end
            end
        end
   
    endfunction


    initial
    begin
        uvm_hdl_path_concat paths[$];
        uvm_hdl_path_slice slice;
        string roots[$];
   
        top_blk model;
   
        model = new("model");
   
        model.build();
        model.set_hdl_path_root("$root.dut");

        model.b1.get_full_hdl_path(roots);
 
`ifdef INCA 
        begin
            string t_[1]; t_[0]="$root.dut.b1";
            check_roots("model.b1", roots, t_);
        end
`else
        check_roots("model.b1", roots, '{"$root.dut.b1"});
`endif 

        // Repeatthe test twice to make sure the paths
        // are not modified 
        repeat (2) begin
           paths.delete();
           model.b1.r1.get_full_hdl_path(paths);
   
           begin
              uvm_hdl_path_concat t_;
              uvm_hdl_path_concat ta_[1];
              t_ = new;
`ifdef INCA 
              
              t_.add_path("$root.dut.b1.r1", -1, -1);
              ta_[0]=t_;
              check_paths("model.b1.r1", paths,ta_);
`else
              t_.set('{ '{"$root.dut.b1.r1", -1, -1} });
              check_paths("model.b1.r1", paths,'{ t_ });
`endif     	
           end
        end

        model.b1.add_hdl_path("b1a");
       
        // Repeatthe test twice to make sure the paths
        // are not modified 
        repeat (2) begin
           paths.delete();
           model.b1.r1.get_full_hdl_path(paths);
   
           begin
              uvm_hdl_path_concat t_;
              uvm_hdl_path_concat exp[2];

              t_ = new;
              t_.add_path("$root.dut.b1.r1", -1, -1);
              exp[0]=t_;
              t_ = new;
              t_.add_path("$root.dut.b1a.r1");
              exp[1]=t_;
              check_paths("model.b1.r1", paths, exp);
           end
        end
       
        model.b1.r1.add_hdl_path_slice("r1a", 1, 1, .first(1));
        model.b1.r1.add_hdl_path_slice("r1a", 0, 1);
        model.b1.r1.add_hdl_path_slice("r1b", -1, -1, .first(1));
       
       paths.delete();
       model.b1.r1.get_full_hdl_path(paths);
   
       begin
          uvm_hdl_path_concat t_;
          uvm_hdl_path_concat exp[6];
          
          t_ = new;
          t_.add_path("$root.dut.b1.r1", -1, -1);
          exp[0]=t_;
          t_ = new;
          t_.add_path("$root.dut.b1.r1a", 1, 1);
          t_.add_path("$root.dut.b1.r1a", 0, 1);
          exp[2]=t_;
          t_ = new;
          t_.add_path("$root.dut.b1.r1b", -1, -1);
          exp[4]=t_;
          t_ = new;
          t_.add_path("$root.dut.b1a.r1", -1, -1);
          exp[1]=t_;
          t_ = new;
          t_.add_path("$root.dut.b1a.r1a", 1, 1);
          t_.add_path("$root.dut.b1a.r1a", 0, 1);
          exp[3]=t_;
          t_ = new;
          t_.add_path("$root.dut.b1a.r1b", -1, -1);
          exp[5]=t_;
          check_paths("model.b1.r1", paths, exp);
       end
       
       begin
          uvm_report_server svr;
          svr = _global_reporter.get_report_server();
          
          svr.summarize();
          
          if (svr.get_severity_count(UVM_FATAL) +
              svr.get_severity_count(UVM_ERROR) == 0)
             $write("** UVM TEST PASSED **\n");
          else
             $write("!! UVM TEST FAILED !!\n");
       end
    end

endprogram
