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

#
# IUS-Specific test running script
#

#
# Make sure the version of IUS can run these tests
#
$ius = `irun -version`;
if ($ius !~ /TOOL:[^\d]+(\d+\.\d+)/) {
  print STDERR "Unable to run IUS: $ius";
  exit(1);
}
$ius_version = $1;
if ($ius_version !~ m/(\d+)\.(\d+)$/) {
   print stderr "Unknown IUS version number \"$ius_version\".\n";
   exit(1);
}
if ($ius_version < 9.2) { &ius_too_old($ius_version); }

sub ius_too_old {
   local($v, $_) = @_;
   print STDERR "IUS $v cannot run the UVM library.\n";
   print STDERR "Version 9.20-p001 or later is required.\n";
   exit(1);
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
  
  # FIXME do we really need -timescale here
  $ius = "irun -uvm -uvmhome $uvm_home -uvmnoautocompile $uvm_home/src/dpi/uvm_dpi.c -incdir $uvm_home/src $uvm_home/src/uvm_pkg.sv test.sv -l irun.log $ius_comp_opts $ius_sim_opts +UVM_TESTNAME=test";
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
   return "irun.log";
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
  local($testdir, $_) = @_;

  local($log);
  $log = "$testdir/irun.log";
  if (!open(LOG, "<$log")) {
    return ();
  }

  local(@errs);

  while ($_ = <LOG>) {
    if (m/^(ncvlog|ncelab): \*E,\w+ \(([^,]),(\d+)\):/) {
	  $fname = $2; $line = $3;
    }
    if ($2) {
      push(@errs, "$fname#$line");
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
  local($testdir, $_) = @_;

  local($log);
  $log = "$testdir/irun.log";
  if (!open(LOG, "<$log")) {
    return ();
  }

  local(@errs);

  while ($_ = <LOG>) {
    if (m/^(ncsim): \*E,\w+ \(([^,]),(\d+)\):/) {
	  $fname = $2; $line = $3;
    }
    if ($2) {
      push(@errs, "$fname#$line");
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
