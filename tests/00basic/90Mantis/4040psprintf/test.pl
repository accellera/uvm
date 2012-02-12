my $count = int(`find $uvm_home/src/ -name "*.svh" | xargs grep "psprintf(" | wc -l`);
$post_test = "Found psprintf $count times";
return $count;
