eval 'exec perl -S $0 ${1+"$@"}' 
if 0;

##---------------------------------------------------------------------- 
##   Copyright 2010 Synopsys, Inc. 
##   Copyright 2010 Mentor Graphics Corp.
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
# Run all tests found in the example directory
#

sub usage {

print STDERR <<USAGE;
Usage: $0 {cmd}

   args     The command to execute in each example directory

Examples:

   $0 make -f Makefile.vcs
   $0 make -f Makefile.questa

USAGE
   exit(1);
}

&usage() if $#ARGV < 0;


@dirs = ("trivial",
	 "hello_world/uvm",
	 "basic_examples/module",
	 "basic_examples/pkg",
	 "callbacks",
	 "configuration/automated",
	 "configuration/manual",
	 "factory",
	 "objections",
	 "phases/basic",
	 "phases/run_test",
	 "phases/stop_request",
	 "sequence/basic_read_write_sequence",
	 "sequence/simple",
	 "interfaces",
	 "tlm1/hierarchy",
	 "tlm1/producer_consumer",
	 "tlm1/bidir",
	 "tlm1/fifo",
	 "xbus/examples");

$cmd = join(" ", @ARGV);

$rc = 0;
foreach $dir (@dirs) {
   print STDERR "Running example in $dir...\n";
   print "cd $dir; $cmd\n";
   $rc |= system("cd $dir; $cmd");
}
