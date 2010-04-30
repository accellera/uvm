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
## % perl OVM_UVM_Rename.pl [--top_dir 'TOP_DIRECTORY_NAME'] [--help]


## For e.g:
## % perl OVM_UVM_Rename.pl -top_dir /xyz/abc/src

## If no top directory is specified, then current directory is taken as top. 

## To see the usemodel:
## % perl OVM_UVM_Rename.pl -help
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
	my $path = $ENV{'PWD'};

	if ((! ($filename =~ /$path/)) && ( !($filename =~ /^[\~|\/]/)))
	{
		$filename = $path."/".$filename;
	}

	if (!(-d $filename) )
	{
		system ("sed -i 's/ovm/uvm/g' $filename");
		system ("sed -i 's/tlm/uvm_tlm/g' $filename");
		system ("sed -i 's/OVM/UVM/g' $filename");
		system ("sed -i 's/TLM_/UVM_TLM_/g' $filename");
	}

}

sub pattern 
{
	my $new;
	my $filename;
	
	$filename = "$File::Find::name";

	if (!(-d $filename) )
	{
		if (!($filename =~ m/(\.v|\.vh|\.sv|\.svh)$/))
		{
			return;
		}
	}

	replace_string($filename);
	
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

print "\nReplacing ovm/tlm to uvm/uvm_tlm in all files....\n\n";
replace_dir_file_name($top_dir);

print "\n...Replaced all class names from ovm_* and tlm_* to uvm_* and uvm_tlm_* respectively.\n";
print "\n...Replaced all macro names from OVM_* and TLM_* to OVM_* and UVM_TLM_ respectively.\n";
print "\n...Replaced all enumerals and constants from OVM_* to UVM_*.\n";
