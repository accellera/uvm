

class foo;
   int q[$] = '{1,2,3,4};
   function void get_q(ref int q[$]);
      q = this.q;
   endfunction
endclass

module top;

  initial begin
    foo f = new;
    int q[];
    f.get_q(q);
    $display("q=%p",q);
  end

endmodule


