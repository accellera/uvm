$cmd = "cd $uvm_home/examples/registers/xbus/direct_virt_seq && make -f Makefile.$tool";
$cmd .= " > /dev/null 2>&1" unless $opt_v;
$result = system($cmd);
if (!$opt_d) {
  $cmd = "cd $uvm_home/examples/registers/xbus/direct_virt_seq && make -f Makefile.$tool clean";
  $cmd .= " > /dev/null 2>&1" unless $opt_v;
  system($cmd);
}
return $result;
