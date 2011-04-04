##---------------------------------------------------------------------- 
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
# Available variables:
#
# $log        Path and name of run-time log file
# $testdir    Path to test directory
#
# Return:
#
# $post_test  Reason for success (or failure)
# 1           If test passes
# 0           If test fails

# This is a gold file test. The test prints "START OF GOLD FILE"
# at the start of comparison output and "END OF GOLD FILE TEST"
# at the end. Leading hashes (#) on lines are ignored to accomodate
# the output style of the Questa transcript.
#
# The log file is parsed and the data between the START/END markers
# are saved in an output file called output. This output file
# is then diffed with the gold file, output.au. A value of 1 is
# returned if there is no diff and 0 is returned on a diff. If
# a diff exists it will be output in a file called output.df.

if (! -e $log) {
   $post_test = "No logfile";
   return 1;
}

$path = `dirname $log`; chomp $path;

$gold = "$path/output.au";
$newlog = "$path/output";

open NEWLOG,">  $newlog"  or return 0;
open LOG, "<  $log"  or return 0;

$log_line = "";
$is_started = 0;
while($log_line = <LOG>) {
  if(!$is_started) {
    if($log_line =~ /START OF GOLD FILE/) { $is_started = 1; }
  } else {
    if($log_line =~ /END OF GOLD FILE/) { $is_started = 0; }
    else {
      # remove '# ' from logs (Questa)
      $log_line =~ s/^# //;
      print NEWLOG "$log_line";
    }
  }
}

close NEWLOG;
close LOG;

system("diff $gold $newlog > $path/output.df");
if($? == 0) {
  $post_test = "gold file matched";
  system("rm -f $path/output.df");
  system("rm -f $newlog") unless $opt_d;
  return 0;
}

$post_test = "gold file mismatched";
system("rm -f $newlog") unless $opt_d;
return 1;

