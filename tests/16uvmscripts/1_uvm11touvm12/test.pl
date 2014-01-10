$ENV{'UVM_HOME'} = "$uvm_home";
$fout = "> /dev/null 2>&1" unless $opt_v;
return system("./test.sh $fout ");
