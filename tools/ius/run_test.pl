##---------------------------------------------------------------------- 
##   Copyright 2010 Synopsys, Inc. 
##   Copyright 2010 Cadence Design Systems, Inc. 
##   All Rights Reserved Worldwide 
## 
##   Licensed under the Apache License, Version 2.0 (the 
##   "License"); you may not use this file except in 
##   compliance with the License.  You may obtain a copy of 
##   the License at 
## 
##       http://www.apache.org/licenses/LICENSE-2.0 
## 
##   Unless required by applicable law or agreed to in 
##   writing, software distributed under the License is 
##   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
##   CONDITIONS OF ANY KIND, either express or implied.  See 
##   the License for the specific language governing 
##   permissions and limitations under the License. 
##----------------------------------------------------------------------
use Cwd 'realpath';
use Data::Dumper;

#
# IUS-Specific test running script
#

#
# Make sure the version of IUS can run these tests
#
@ius_min_version_required=(9,2,30);
$ius = `irun -version`;
chomp $ius;
if ($ius !~ /TOOL:\s+\S+\s+(\d+)\.(\d+)-([A-z])(\d+)/) {
  print STDERR "Unable to run IUS: $ius";
  exit(1);
} else {
	@ius_version = ($1,$2,$4);
	&ius_compare_version($3,\@ius_version, \@ius_min_version_required);
}

sub ius_too_old {
   local($v, @min) = @_;
   print STDERR "IUS $v cannot run the UVM library.\n";
   print STDERR "Version $min[0].$min[1]s$min[2] or later is required.\n";
   exit(1);
}

sub ius_compare_version {
	my($stream,$cv,$rv)=@_;
	my(@c,@r);
	@c=@{$cv};
	@r=@{$rv};
	if($c[0] < $r[0]) {
		&ius_too_old(@c,@r);
	} elsif ($c[1] < $r[1]) {
		&ius_too_old(@c,@r);
	} elsif (($c[2] < $r[2]) && ($stream eq "s") ) {
		&ius_too_old(@c,@r);
	} elsif ($stream ne "s") {
		print STDERR "running a nonstd build version [$ius] assuming its at least equiv. to IUS".ius_version_string(@r)."\n";
	}
}

sub ius_version_string {
	my(@v)=@_;
	return "$v[0].$v[1]s$v[2]";
}

#
# Run the test implemented by the file named "test.sv" located
# in the specified directory, using the specified compile-time
# and run-time command-line options
#
# The specified directory must also be used as the CWD for the
# simulation run.
#
# Run silently, unless $opt_v is specified.
#
sub run_the_test {
  local($testdir, $ius_comp_opts, $ius_sim_opts, $_) = @_;
  local($uvm_dpi_lib) = qx($uvm_home/bin/uvm_dpi_name);
  
  $ius = "irun -uvmhome $uvm_home -uvmnoautocompile $uvm_home/src/dpi/uvm_dpi.cc -incdir $uvm_home/src $uvm_home/src/uvm_pkg.sv $ius_comp_opts test.sv +UVM_TESTNAME=test $ius_sim_opts";
  $ius .= " -nostdout" unless $opt_v;

  print "$ius\n" if $opt_v;
  system("cd $testdir; rm -rf INCA_libs irun.log;");
  system("cd $testdir; $ius");

  return 0;
}


#
# Return the name of the compile-time logfile
#
sub comptime_log_fname {
   return runtime_log_fname();
}


#
# Return the name of the run-time logfile
#
sub runtime_log_fname {
   return "irun.log";
}


#
# Return a list of filename & line numbers with compile-time errors
# for the test in the specified directory as an array, where each element
# is of the format "fname#lineno"
#
# e.g. ("test.sv#25" "test.sv#30")
#
sub get_compiletime_errors {
  local($testdir) = @_;

  local($log)= "$testdir/" . comptime_log_fname();

  open(LOG,$log) or die("couldnt open log [$log] [$!]");

  local(@errs)=();
  
  while ($_ = <LOG>) {
    if (/^(ncvlog|ncelab): \*[EF],\w+ \(([^,]+),(\d+)\|(\d+)\):/,){ 
	  push(@errs, "$2#$3");
    }
  }

  close(LOG);

  return @errs;
}


#
# Return a list of filename & line numbers with run-time errors
# for the test in the specified directory as an array, where each element
# is of the format "fname#lineno"
#
# e.g. ("test.sv#25" "test.sv#30")
#
# Run-time errors here refers to errors identified and reported by the
# simulator, not UVM run-time reports.
#
sub get_runtime_errors {
    local($testdir) = @_;
    local($log) = &realpath("$testdir/" . runtime_log_fname());

  open(LOG, $log) or die("couldnt open [$log] [$!]");

  local(@errs)=();

  while ($_ = <LOG>) {
   if (/^(ncsim): \*[FE],\w+ \(([^,]+),(\d+)\|(\d+)\):/) {
	  push(@errs, "$2#$3");
    }

    if (/^ERROR:/) {
	  push(@errs, "fname#2");
    }
  }

  close(LOG);
  
  return @errs;
}


#
# Clean-up all files created by the simulation,
# except the log files
#
sub cleanup_test {
  local($testdir, $_) = @_;

  system("cd $testdir; rm -rf INCA_libs waves.shm");
}

1;
