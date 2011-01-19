import uvm_pkg::*;

class transaction extends uvm_transaction;

`uvm_object_utils(transaction)

rand logic rw;
rand logic [7:0] data;
rand logic [1:0] addr;


function new (string name="");
  super.new(name);
endfunction

function string convert2string;
  string s;
  string s1, s2, s3;
  
  s2.itoa(data);
  s3.itoa(addr);
  
  if (rw)
    s = {"WRITE transaction: Address is ", s2, " Data is ", s3};
  else
    s = {"READ transaction: Address is ", s2, " Data is ", s3};
    
  return s;
endfunction

virtual function void do_copy( uvm_object rhs );
  transaction rhs_;
  assert($cast(rhs_,rhs));
  rw = rhs_.rw;
  data = rhs_.data;
  addr = rhs_.addr;
endfunction

virtual function bit do_compare( uvm_object rhs, uvm_comparer comparer );
  transaction rhs_;
  assert($cast(rhs_,rhs));
  if (rw != rhs_.rw)
    return 0;
  else if (data != rhs_.data)
    return 0;
  else if (addr != rhs_.addr)
    return 0;
  else return 1;
endfunction

endclass
