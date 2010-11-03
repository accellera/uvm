$cmd = "cd $uvm_home/examples/registers/vertical_reuse && make -f Makefile.$tool";
$cmd .= " > /dev/null 2>&1" unless $opt_v;
return system($cmd);
