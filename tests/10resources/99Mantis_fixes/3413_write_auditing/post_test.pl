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

# strip possible '# ' at beginning of every line
$logfile =~ s/\n# /\n/sg;

# strip irrelevant text
$logfile =~ s/.*(=== resource pool ===.*?=== end of resource pool ===\n).*/$1/sg;

# Replace implementation-dependent output with generic text
$logfile =~ s/: \(class .*\) /: \(class \$typename\) /g;

# write back
print L $logfile;

close(LOG);
close(L);

system("diff $testdir/log.au.$tool $testdir/post.log > $testdir/output.df");
if($? == 0) {
  $post_test = "gold file matched";
  system("rm -f $testdir/output.df");
  system("rm -f $testdir/post.log") unless $opt_d;
  return 0;
}

$post_test = "gold file mismatched";
system("rm -f $testdir/post.log") unless $opt_d;
return 1;
