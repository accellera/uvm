eval 'exec perl -S $0 ${1+"$@"}' 
if 0;

##---------------------------------------------------------------------- 
##   Copyright 2013 Synopsys, Inc. 
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
# Identify the status of the Mantis corresponding to the various
# mantis branches found in the local git repository.
#

sub usage {

print STDERR <<USAGE;
Usage: $0 [options] csv

   csv      CSV file exported from Mantis system

Options:
   -h       Print this message
   -m       Only consider the branches that have not
            yet been merged into the current branch

USAGE
   exit(1);
}

require "getopts.pl";

&Getopts("hm");
&usage if $opt_h || $#ARGV < 0;

$csv = shift(@ARGV);

#
# Parse the CSV file, recording the status of each Mantis it contains
#
if (!open(CSV, "< $csv")) {
    print STDERR "ERROR: Cannot open CSV file \"$csv\" for reading: $!\n";
    exit(-1);
}

while ($_ = <CSV>) {
    # Only valid data lines
    next unless m/^0*(\d+),[^,]*,([^,]*),([^,]*),.*,([^,]+),[^,]*,[^,]*,\d+$/;

    $id     = $1;

    $author{$id} = $2;
    $owner {$id} = $3;
    $status{$id} = $4;
}
    
close(CSV);


#
# Now see which mantis branches we have
#
$cmd = "git branch -a";
$cmd .= " --no-merged" if $opt_m;

if (!open(GIT, "$cmd |")) {
    print STDERR "ERROR: Cannot check git repository: $!\n";
    exit(-1);
}

while ($_ = <GIT>) {
    next unless m/mantis_?\d+/i;
    chomp($_);
    push(@branches, $_);
}

close(GIT);

#
# Now display the branches and their corresponding Mantis status
#

foreach $_ (@branches) {
    m/mantis_?(\d+)/i;
    $id = $1;

    $status = $status{$id};
    $status = "UNKNOWN" unless $status;

    $owner = $owner{$id};
    $owner = "UNKNOWN" unless $owner;

    print "$_    Status: $status    Owner: $owner\n";
}

exit(0);
