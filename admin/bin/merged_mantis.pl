#!/usr/bin/perl
##---------------------------------------------------------------------- 
##   Copyright 2013 Cadence Inc
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
# usage: merged_mantis.pl <after-this-git-ref> <target-git-ref> <repo-prefix> <mantis-username> <mantis-password>
#
# example: merged_mantis.pl UVM_1_1_d UVM_1_2 sf dummyuser dummypassword
#
# produces the fowllowing output
#
# mantis,score,reasons
# 4479,1,sf/mantis_4479:new
# 4542,3,sf/mantis_4542:relnotes:completed
# 4686,4,sf/mantis_4686:sf/mantis_4686-2:relnotes:completed
# 4135,1,sf/mantis_4135:approved
# 3250,1,sf/Mantis_3250
#
# the score is increased for every
# - mantis status "completed"
# - branch present in <repo> and merged to <target>
# - mantis present in relnotes
#
# note1: there might be multiple branches for a single item for instance with fixes,vendor specials therefore the score could be higher than the set of checks made
# note2: items with a reason "already-in-<after-this-git-ref>" can be ignored since the code has been merged into <after-this-git-ref>
# note3: the tool needs wget and access to eda.org to operate 
#
use Data::Dumper;

my $repo=$ARGV[2];

my $after="$repo/" . $ARGV[0];
my $target="$repo/" . $ARGV[1];
my $user=$ARGV[3];
my $password=$ARGV[4];

# find all branches of the repo
my $mantistxt = qx { git branch -r };

while($mantistxt =~ /(${repo}\/[Mm]antis_(\d+).*)/gmx) {
  $mantis{$1}=$2; # mantis-of(branch)-is
  $branch{$2}=$1;
}

# remove the items merged already into $after
foreach $thisBranch (keys %mantis) {
  my $t = qx{git branch -r --contains $thisBranch $after};
  if($t =~  /$after/) {
    push @{$reason{$mantis{$thisBranch}}},"already-in-$after";
  } else {
      my $t = qx{git branch -r --contains $thisBranch $target};
      if($t =~ /$target/) {
	  $score{$mantis{$thisBranch}}++;
	  push @{$reason{$mantis{$thisBranch}}},"merged($thisBranch)";
      } else {
          push @{$reason{$mantis{$thisBranch}}},"not-merged($thisBranch)";
      }
  }
}



# now extract the info from the relnotes
$releasenotes = qx{git show ${target}:distrib/release-notes.txt};
while($releasenotes =~ /Mantis\s+(\d+)\s*:/gx) {
    $score{$1}++;
    push @{$reason{$1}},"relnotes";
}

# get the csv
system("wget --save-cookies cookies --keep-session-cookies --post-data 'username=${user}&password=${password}&perm_login=false' http://www.eda.org/svdb/login.php");
system("wget --keep-session-cookies --load-cookies cookies http://www.eda.org/svdb/csv_export.php -O VIP.csv");
unlink("cookies");

my $csv = qx{cat VIP.csv};
while($csv =~ /(^Id\,.*)/mgx) {
  @cols=split(",",$1);
}
for $i (0..$#cols) {
  $cols{$cols[$i]} = $i;
}

while($csv =~ /(^\d+\,.*)/mgx) {
  @cols=split(",",$1);

  my $id=$cols[$cols{"Id"}]*1.0;
  if($cols[$cols{"Status"}] =~ /completed/) {
    $score{$id}++;
  }
  if($cols[$cols{"Status"}] =~ /closed/) {
    $score{$id}++;
  }
  push @{$reason{$id}},$cols[$cols{"Status"}];
  push @{$reason{$id}},$cols[$cols{"Assigned To"}];  
}

print "mantis,score,reasons\n";
my @known=(keys %reason,keys %score);
#print Dumper(@known);
@known=sort(uniq(@known));
#print Dumper(@known);
#exit(1);
foreach $mantis (@known) {
  print $mantis . "," . $score{$mantis} . "," . join(":",@{$reason{$mantis}}) . "\n";
}

#print Dumper(%reason);

sub uniq {
  my %seen;
  foreach $line (@_) {
    $seen{1.0*$line}=1;
  }

  return keys %seen;
}
