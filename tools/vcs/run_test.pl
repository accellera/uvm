##---------------------------------------------------------------------- 
##   Copyright 2010 Synopsys, Inc. 
##   Copyright 2010 Verilab, Inc.
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
# VCS-Specific test running script
#

# If $vcs_bin has already been defined (say, to VCSi) then use the 
# specified binary name instead. Otherwise, default to "vcs".
$vcs_bin = "vcs" unless $vcs_bin;

#
# Make sure the version of VSC can run these tests
#

$vcs = `$vcs_bin -id`;
if ($vcs !~ m/Compiler version = VCS\S* (\S+)/) {
  print STDERR "Unable to run VCS: $vcs";
  exit(1);
}
$vcs_version = $1;
if ($vcs_version !~ m/(\d\d\d\d)\.(\d\d)(-(.+))?$/) {
   print stderr "Unknown VCS version number \"$vcs_version\".\n";
   exit(1);
}
$vcs_yr = $1;
$vcs_mo = $2;
$vcs_rl = $4;
if ($vcs_yr < 2010) { &vcs_too_old($vcs_version); }
if ($vcs_yr == 2010 && $vcs_mo == 6) { 
  if ($vcs_rl !~ "^SP1" && $vcs_rl < "3") { &vcs_too_old($vcs_version); }
}

sub vcs_too_old {
   local($v, $_) = @_;
   print STDERR "VCS $v cannot run the full UVM library.\n";
   print STDERR "Version 2010.06-3 or later is required.\n";
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
  local($testdir, $vcs_opts, $simv_opts, $_) = @_;

  $vcs = "$vcs_bin -sverilog +acc +vpi -timescale=1ns/1ns +incdir+$uvm_home/src $uvm_home/src/uvm.sv test.sv $uvm_home/src/dpi/uvm_dpi.cc -CFLAGS -DVCS -l vcs.log $vcs_opts";
  $vcs .= " > /dev/null 2>&1" unless $opt_v;

  system("cd $testdir; rm -f simv vcs.log simv.log; $vcs");

  if (-e "$testdir/simv") {
    $simv = "simv -l simv.log +UVM_TESTNAME=test $simv_opts";
    $simv .= " > /dev/null 2>&1" unless $opt_v;

    print "$simv\n" if $opt_v;
    system("cd $testdir; ./$simv");
  }

  return 0;
}


#
# Return the name of the compile-time logfile
#
sub comptime_log_fname {
   return "vcs.log";
}


#
# Return the name of the run-time logfile
#
sub runtime_log_fname {
   return "simv.log";
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
  $log = "$testdir/vcs.log";
  if (!open(LOG, "<$log")) {
    return ();
  }

  local(@errs);

  while ($_ = <LOG>) {
    if (m/^Error-\[/) {
      while ($lf = <LOG>) {
	if ($lf =~ m/^\s+"(\S+)", (\d+)\s/) {
	  $fname = $1; $line = $2;
	  last;
	}
	if ($lf =~ m/^(\S+), (\d+)$/) {
	  $fname = $1; $line = $2;
	  last;
	}
      }
      if ($lf) {
	push(@errs, "$fname#$line");
      } else {
	print STDERR "Invalid VCS compile-time error: \n$_$lf";
      }
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
  $log = "$testdir/simv.log";
  if (!open(LOG, "<$log")) {
    return ();
  }

  local(@errs);

  while ($_ = <LOG>) {
    if (m/^Error-\[/) {
      while ($lf = <LOG>) {
	if ($lf =~ m/^\s+"(\S+)", (\d+)\s/) {
	  $fname = $1; $line = $2;
	  last;
	}
	if ($lf =~ m/^(\S+), (\d+)$/) {
	  $fname = $1; $line = $2;
	  last;
	}
      }
      if ($lf) {
	push(@errs, "$fname#$line");
      } else {
	print STDERR "Invalid VCS run-time error: \n$_$lf";
      }
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

  system("cd $testdir; rm -rf simv simv.daidir simv.vdb csrc ucli.* vc_hdrs.h .vcs*");
}

1;
