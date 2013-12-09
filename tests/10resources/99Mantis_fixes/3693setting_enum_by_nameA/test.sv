module testmod;
		import uvm_pkg::*;

    typedef enum {ALPHA, BETA, GAMMA, DELTA} e_t;
    typedef uvm_pkg::uvm_enum_wrapper#(e_t) w_t;

    initial begin
        e_t val_map[string];
        e_t val;
        bit fail;

        void'(val.first());
        do begin
            val_map[val.name()] = val;
            val = val.next();
        end while (val != val.first());

        // Test for a failure
        if (w_t::from_name("FOO", val)) begin
            $display("The name 'FOO' shouldn't have worked!");
            fail = 1;
        end
        else begin
            $display("The name 'FOO' didn't work (THAT'S GOOD)");
        end

        // Test for all successes
        foreach (val_map[i]) begin
            if (!w_t::from_name(i, val)) begin
                $display("'%s' should have worked!", i);
                fail = 1;
            end
            else if (val != val_map[i]) begin
                $display("'%s' != '%s'", val.name, i);
                fail = 1;
            end
            else begin
                $display("The name '%s' worked (THAT'S GOOD)", i);
            end
        end

        if (!fail)
          $display("*** UVM TEST PASSED ***");
        else
          $display("*** UVM TEST FAILED ***");

          begin
	          uvm_report_server svr;
	          svr=uvm_report_server::get_server();
	          svr.report_summarize();
          end	
    end

endmodule


