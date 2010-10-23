$cmd = "cd $uvm_home/examples/registers/xbus/reg_seqr_layer && make -f Makefile.$tool";
$cmd .= " > /dev/null 2>&1" unless $opt_v;
return system($cmd);
