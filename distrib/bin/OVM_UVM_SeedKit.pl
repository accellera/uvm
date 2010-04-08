eval 'exec perl -S $0 ${1+"$@"}' 
if 0;

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


##----------------------------------------------------------------------
## Script usage is as follows:
## % perl OVM_UVM_SeedKit.pl [--top_dir 'TOP_DIRECTORY_NAME'] [--help]

## For e.g:
## % perl OVM_UVM_SeedKit.pl -top_dir /xyz/abc/src

## If no top directory is specified, then current directory is taken as top. 

## To see the usemodel:
## % perl OVM_UVM_SeedKit.pl -help
##----------------------------------------------------------------------


use strict;
use warnings;
use Getopt::Long;
use File::Find;

sub replace_dir_file_name 
{
	my ($dir) = shift; 
	finddepth(\&pattern, $dir);
}

sub replace_string 
{
	my $filename = shift;

	if (!(-d $filename) )
	{
		system ("sed -i 's/ovm/uvm/g' $filename");
		system ("sed -i 's/tlm/uvm_tlm/g' $filename");
		system ("sed -i 's/OVM/UVM/g' $filename");
		system ("sed -i 's/TLM_/UVM_TLM_/g' $filename");
		system ("sed -i 's/-uvmhome/-ovmhome/g' $filename");
	}

}

sub pattern 
{
	my $new;
	my $filename;
	
	$filename = "$File::Find::name";

	if (!(-d $filename) )
	{
	if (!($filename =~ m/(\.v|\.vh|\.sv|\.svh|\.f|\.txt)$/))
	{
		return;
	}
	}

	replace_string($filename);
	
	if(/^ovm(.*)$/)
	{
		$new = "uvm$1"; 
		
		if (!(-d $filename) )
		{
			system ("sed -i 's/Copyright 2007\\-2009 Cadence Design Systems, Inc./Copyright 2007\\-2009 Cadence Design Systems, Inc. \\n\\/\\/   Copyright 2010 Synopsys, Inc./g' $filename" );
		}

	    rename($_, $new) or warn "Rename of '$_' to '$new' failed: $!\n";
	 }
	 elsif(/^tlm(.*)$/)
	 {
		$new = "uvm_tlm$1";
		if (!(-d $filename) )
		{
			system ("sed -n 's/Copyright 2007\\-2009 Cadence Design Systems, Inc./Copyright 2007\\-2009 Cadence Design Systems, Inc. \\n\\/\\/   Copyright 2010 Synopsys, Inc./g' $File::Find::name" );
		}
 
	    rename($_, $new) or warn "Rename of '$_' to '$new' failed: $!\n";
	 }
	 else 
	 {
		 return;
	 }


	$filename = $new;

	#
	# Add SNPS copyright notice to banner
	#
	if($filename =~ m/uvm_version.svh$/) {
	  system ("sed -i 's/parameter string uvm_cdn_copyright = \"(C) 2007\\-2009 Cadence Design Systems, Inc.\"\;/parameter string uvm_cdn_copyright \\= \"\\(C\\) 2007\\-2009 Cadence Design Systems, Inc.\"\\;\\nparameter string uvm_snps_copyright = \"\\(C\\) 2010 Synopsys, Inc.\"\;/g' $filename" );

	  print "File $filename modified for uvm_snps_copyright information\n";
	}

	if($filename =~ m/uvm_report_handler.svh$/) {
	  system ("sed -i 's/srvr.f_display\(file, uvm_cdn_copyright\);/srvr.f_display\(file, uvm_cdn_copyright\);\\n    srvr.f_display\(file, uvm_snps_copyright\);/g' $filename" );

	  print "File $filename modified for uvm_snps_copyright information\n";
	}

	#
	# Modify version macro definitions
	#
	if($filename =~ m/uvm_version_defines.svh$/) {
          open(F, "<$filename");
	  open(N, ">$filename.new");
          while ($_ = <F>) {
	    s/UVM_MAJOR_REV \d+/UVM_MAJOR_REV 1/;
	    s/UVM_MINOR_REV \d+/UVM_MINOR_REV 0/;
	    s/UVM_FIX_REV \d+/UVM_FIX_REV EA/;
	    s/UVM_VERSION_\d+_\d+/UVM_VERSION_1_0/;
	    s/UVM_MAJOR_VERSION_\d+_\d+/UVM_MAJOR_VERSION_1_0/;
	    s/UVM_MAJOR_REV_\d+/UVM_MAJOR_REV_1/;
	    s/UVM_MINOR_REV_\d+/UVM_MINOR_REV_0/;
	    s/UVM_FIX_REV_\d+/UVM_FIX_REV_EA/;
	    print N $_;
	  }
	  close(F);
	  close(N);
	  rename("$filename.new", $filename);
	  print "Updated version number definitions in $filename...\n";
	}
}

my $top_dir = '';
my $help = 0;


GetOptions ('top_dir=s' => \$top_dir, 'help+' => \$help) or die "\nIncorrect usage of script. The following is the correct usage: \n\n$0 [--top_dir '<TOP DIR PATH>'] [--help]\n\n" ;


if ($help != 0)
{
	print "\n\nScript usage is as follows:\n";
	print "\n$0 [--top_dir 'TOP_DIRECTORY_NAME'] [--help]\n\n";
exit;
}

if ($top_dir eq '')
{
	print "\nNo TOP directory name specified. Using current directory as top.\nUse '$0 --help' to see the options.\n\n";
	$top_dir = `pwd`; 
	chomp($top_dir);
}

if (! -e "$top_dir/LICENSE.txt" || !-e "$top_dir/OVM_Reference.pdf") {
  print STDERR "Directory \"$top_dir\" does not appear to be a valid OVM distribution. Aborting.\n";
  exit(1);
}

system("cd $top_dir; rm -rf deprecated.txt docs OVM_* README*.txt release-notes.txt");

open(F, ">README.txt");
print F <<README;
Accellera Universal Verification Methodology
version 1.0-EA

(C) Copyright 2007-2009 Mentor Graphics Corporation
(C) Copyright 2007-2009 Cadence Design Systems, Incorporated
(C) Copyright 2010 Synopsys Inc.
All Rights Reserved Worldwide

The UVM kit is licensed under the Apache-2.0 license.  The full text of
the licese is provided in this kit in the file LICENSE.txt

Installing the kit
------------------

Installation of UVM requires only unpacking the kit in a convenient
location.  No additional installation procedures or scripts are
necessary.

Using the UVM
-------------

You can make the UVM library accessible by your SystemVerilog program by
using either the package technique or the include technique.  To use
packages import uvm_pkg. If you are using the field automation macros
you will also need to include the macro defintions. E.g.

import uvm_pkg::*;
`include "uvm_macros.svh"

To use the include technique you include a single file:

`include "uvm.svh"

You will need to put the location of the UVM source as a include
directory in your compilation command line.

------------------------------------------------------------------------
README
close(F);

print "\nReplacing ovm/tlm to uvm/uvm_tlm in all *.sv/svh/v/vh files....\n\n";
replace_dir_file_name($top_dir);
print "\n...Replaced all files/directories starting with ovm/tlm to uvm/uvm_tlm in $top_dir.\n";

print "\n...Replaced all class names from ovm_* and tlm_* to uvm_* and uvm_tlm_* respectively.\n";
print "\n...Replaced all macro names from OVM_* and TLM_* to OVM_* and UVM_TLM_ respectively.\n";
print "\n...Replaced all enumerals and constants from OVM_* to UVM_*.\n";
