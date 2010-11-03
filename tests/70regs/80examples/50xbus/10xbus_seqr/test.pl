$cmd = "cd $uvm_home/examples/registers/xbus/direct_xbus_seqr && make -f Makefile.$tool";
$cmd .= " > /dev/null 2>&1" unless $opt_v;
return system($cmd);
