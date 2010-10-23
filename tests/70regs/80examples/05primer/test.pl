$cmd = "cd $uvm_home/examples/registers/primer && make -f Makefile.$tool";
$cmd .= " > /dev/null 2>&1" unless $opt_v;
return system($cmd);
