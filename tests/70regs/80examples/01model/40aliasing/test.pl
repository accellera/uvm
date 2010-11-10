$cmd = "cd $uvm_home/examples/registers/models/aliasing && make -f Makefile.$tool";
$cmd .= " > /dev/null 2>&1" unless $opt_v;
$result = system($cmd);
if (!$opt_d) {
  $cmd = "cd $uvm_home/examples/registers/models/aliasing && make -f Makefile.$tool clean";
  $cmd .= " > /dev/null 2>&1" unless $opt_v;
  system($cmd);
}
return $result;
