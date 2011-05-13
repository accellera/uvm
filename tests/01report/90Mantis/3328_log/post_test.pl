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
   &remove_tmp_files();
   return 1;
}

$path = `dirname $log`; chomp $path;

$newlog = "$path/output";

open NEWLOG,">  $newlog";
if(tell NEWLOG == -1) { 
  $post_test="can't open $newlog"; 
  &remove_tmp_files();
  return 1;
}
open LOG, "<  $log";
if (tell LOG == -1) {
  $post_test="can't open $log"; 
  &remove_tmp_files();
  return 1;
}

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
      # remove file name paths
      $log_line =~ s#[^\w]+/test.sv#test.sv#;
      print NEWLOG "$log_line";
    }
  }
}

close NEWLOG;
close LOG;

$rval = &do_diff("$newlog");
if($rval) {
  &remove_tmp_files();
  return 1;
}

&strip_path("$path/mcd2") or return 1;
$rval = &do_diff("$path/mcd2");
if($rval) {
  &remove_tmp_files();
  return 1;
}

&strip_path("$path/mcd1") or return 1;
$rval = &do_diff("$path/mcd1");
if($rval) {
  &remove_tmp_files();
  return 1;
}

&strip_path("$path/fp1") or return 1;
$rval = &do_diff("$path/fp1");
if($rval) {
  &remove_tmp_files();
  return 1;
}

&remove_tmp_files();
$post_test = "gold files matched";
return 0;

sub strip_path {
  $fname = shift;
  open FIN,"<  $fname";
  if (tell FIN == -1) {
    $post_test = "unable to open $fname";
    &remove_tmp_files();
    return 0;
  }
  open FOUT, ">  $fname.mod"  or return 0;
  while(<FIN>) {
      s#[^\w]+/test.sv#test.sv#;
      print FOUT "$_";
  }
  close FIN;
  close FOUT;
  system("mv $fname.mod $fname");
  return 1;
}

sub do_diff {
  $fname = shift;
  
  system("diff $fname.au $fname > $fname.df");
  if($? != 0) {
    $post_test = "$fname file mismatched";
    return 1;
  }
  system("rm -f $fname.df");
  return 0;
}

sub remove_tmp_files {
  @tmp_files = ( 'mcd1', 'mcd2', 'fp1', 'output' );
  foreach (@tmp_files) {
    system("rm -f $path/$_") unless $opt_d;
  }
}

