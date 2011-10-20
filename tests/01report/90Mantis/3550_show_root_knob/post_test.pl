##---------------------------------------------------------------------- 
##   Copyright 2010 Cadence
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


if (!open(LOG, "<$log")) {
  $post_test = "Cannot open \"$log\" for reading: $!";
  return 1;
}

$logfile=qx{cat "$log"};
close(LOG);

# strip Value from table
$logfile =~ s/\@\d+ *$/\@X/mg;
# strip any '# ' prefix on each line
$logfile =~ s/^# //mg;
# strip all text up to and including GOLD-FILE-START
$logfile =~ s/.*\nGOLD-FILE-START\n//sx;
# strip all text from GOLD-FILE-START after
$logfile =~ s/\nGOLD-FILE-ENDS.*//sx;


$logfile =~ s/^ncsim>.*$//mg;
$logfile =~ s/^.*\.svh.*$//mg;
$logfile =~ s/\n+\n/\n/sxg;
$logfile =~ s/^UVM-\S+\s+\(\S+\)$/UVM-VERSION/mg;
$logfile =~ s/^\(C\).*$/COPYRIGHT/mg;
$logfile =~ s/COPYRIGHT(.COPYRIGHT)+/COPYRIGHT/sg;



# write back

if (!open(L, ">$testdir/post.log")) {
  $post_test = "Cannot open \"$testdir/post.log\" for writing: $!";
  close(L);
  return 1;
}
print L $logfile;
close(L);

if (system("diff $testdir/log.au $testdir/post.log > $testdir/log.df")) {
  $post_test = "$log and log.au differ";
  return 1;
}

return 0;
