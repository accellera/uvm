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
if (!open(L, ">$testdir/post.log")) {
  $post_test = "Cannot open \"$testdir/post.log\" for writing: $!";
  close(L);
  return 1;
}
$logfile=qx{cat "$log"};
$logfile =~ s/\@\d+\s*\n/\@X\n/sg;
$logfile =~ s/\n# /\n/sg;
# strip header
$logfile =~ s/.*(UVM_INFO.*UVM\s+testbench\s+topology)/\1/sx;
# strip tail
$logfile =~ s/\n\n.*/\n/sx;
# write back

print L $logfile;

close(LOG);
close(L);

if (system("diff $testdir/post.log $testdir/log.au > $testdir/diff.log")) {
  $post_test = "$log and log.au differ";
  return 1;
}

return 0;
