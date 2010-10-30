##---------------------------------------------------------------------- 
##   Copyright 2010 Synopsys, Inc. 
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
# Simulator-Specific test running script
#
# Dummy "ECHO" simulator that forces a "pass"
#

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
  local($testdir, $comptime, $runtime, $_) = @_;

  $echo = "echo \'** UVM TEST PASSED **\'";

  print $echo,"\n" if $opt_v;
  system("cd $testdir; $echo > echo.log");
  system("cd $testdir; echo \'Cargs: \"$comptime\"\' >> echo.log");
  system("cd $testdir; echo \'Rargs: \"$runtime\"\' >> echo.log");
  system("cd $testdir; echo '--- UVM Report Summary ---' >> echo.log");
  system("cd $testdir; echo 'UVM_ERROR : 0' >> echo.log");
  system("cd $testdir; echo 'UVM_FATAL : 0' >> echo.log");
}


#
# Return the name of the compile-time logfile
#
sub comptime_log_fname {
   return "echo.log";
}


#
# Return the name of the run-time logfile
#
sub runtime_log_fname {
   return "echo.log";
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
  return ();
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
  return ();
}


#
# Clean-up all files created by the simulation,
# except the log files
#
sub cleanup_test {
  local($testdir, $_) = @_;

  system("cd $testdir;");
}

1;
