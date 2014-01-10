##---------------------------------------------------------------------- 
##   Copyright 2011 Cadence
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
use File::Glob ':glob';
use Data::Dumper;
use File::Basename;

# the script compares a set of goldfiles
#
# goldfiles are all files in the local directory matching *.au.($tool)?
# each goldfile is compared to a produced file $file by chopping \.au(.$tool)$ from the goldfile name
# if the produced file $file doesnt exist its assumed that the goldfile shall be compared to the simulator default log
# 
# 1. each produced file is filtered and saved as $file.post
# 2. then a diff is performed between $file.post and $file.au(.$tool)? and saved as $file.df
# 3. the script returns showing the set mismatches, missing files (or not)
#
#
# the script filters a set of variying patterns such as
# filenames, message locations, seeds, handles


# consider all *.au and *.au.$tool files
#my $tool="ius";
#my $log="./bla";
my $dir=dirname($log);
my @sources = bsd_glob("$dir/*.{au,au.$tool}",GLOB_CSH);
my @diffs=();
my %lookup=();
my %known_logs= ("ius" => "$dir/irun.log", "vcs" => "$dir/simv.log", "questa" => "$dir/run.log");

if (! scalar(@sources)) {
  push @diffs,"no gold files present";
}

sub cleanFileAndWrite {
  my($text,$file) = @_;
  local(*O);

  scrub(\$text);
  open(O,">$file") || push @diffs,"cannot write post file $file - $!"; 
  print O $text;
  close O;
}

sub scrub {
  my($logfile)=@_;

  # This must be the first filter for Questa. Do not put anything before it, please.
  $$logfile =~ s/^# //mg;

  # Questa-specific?
  $$logfile =~ s/__\d+\@\d+/__X\@X/sg;
  if ($dir eq "00basic/25typename" && $tool eq "questa") {
    $$logfile =~ s/,88 /, 88/mg;
  }

  $$logfile =~ s/\@[\d_]+[^\S\r\n]*/\@X/sg;

  # strip header
  $$logfile =~ s/.*\nGOLD-FILE-START\n//sx;
  $$logfile =~ s/\nGOLD-FILE-END.*/\n/sx;

  $$logfile =~ s/^ncsim>.*$//mg;
  $$logfile =~ s/^(UVM_(INFO|WARNING|ERROR|FATAL))\s+\S+\(\d+\)/\1 FILE-LINE/mg;
  $$logfile =~ s/\S+\.svh//mg;
  $$logfile =~ s/\n+\n/\n/sxg;
  $$logfile =~ s/^UVM-\S+\s+\(\S+\)$/UVM-VERSION/mg;
  $$logfile =~ s/^\(C\).*$/COPYRIGHT/mg;
  $$logfile =~ s/COPYRIGHT(.COPYRIGHT)+/COPYRIGHT/sg;
  $$logfile =~ s/^SVSEED.*\n//sg;
  $$logfile =~ s/\$unit_0x[0-9a-f]+::/SCOPE::/mg;
  $$logfile =~ s/(\s+m_inst_(id|count)):\d+/\1:X/mg;

  # if this is a recorder dump then handle the TXH as handles
  if($$logfile =~ /\s+CREATE_STREAM/) {
      $$logfile =~ s/([\{ ]TXH\d*:)(\d+)/\1\@H/mg;
      $$logfile =~ s/STREAM:\d+/STREAM:\@H/mg;
  }
}

sub diffLogs {
  my($gold,$post)=@_;

  if (system("diff $post.post $gold > $post.df")) {
    return "$post.df";
  } else {
    return ();
  }
}

sub ReadFileAsText {
  my($FILENAME)=@_;
  my($TEXT);
  local(*INFILE);

  $TEXT="";
  open(INFILE,$FILENAME) || push @diffs,"can't open file [$FILE][$!]";
  undef $/;
  $TEXT .= <INFILE>;
  $/ = "\n";
  close(INFILE);
  return ($TEXT);
}

#print "alive";
#print Dumper(@sources);
my($vendorspecial)=();
LOOP: foreach my $goldfile (@sources) {
  my $current = $goldfile;
  $current =~ s/\.au(\.$tool)?$//g;

  # if its a vendor specific gold file then all vendors should have at least a goldfile
  if(defined $1) {
      foreach $v (keys %known_logs) {
	  my @sources = bsd_glob("$dir/*.au.$v",GLOB_CSH);
	  if(!scalar(@sources)) {
	      push @diffs,"no vendor specific log avail but vendor $v has one";
	  }
      }
  }

  if(!(-e $current)) {
    if(!(-e $known_logs{$tool})) {
      push @diffs,"neither vendor special log present nor default log present for vendor ($tool)";
      next LOOP;
    } else {
      $current=$known_logs{$tool};
    }
  } 

  if(! (-r $goldfile)) {
    push @diffs,"goldfile ($goldfile) not readable";
    next LOOP;
  }
  if(! (-r $current)) {
    push @diffs,"vendor log ($current) not readable";
    next LOOP;
  }

  my $c = ReadFileAsText($current);
  cleanFileAndWrite($c,"$current.post");
  push @diffs,diffLogs($goldfile,$current);
      
  if (exists $lookup{$current}) {
    push @diffs,"fatal: generic goldfile and simulator specific goldfile exists";
  }
  $lookup{$current}=1;
}
#print Dumper(@diffs);

if (@diffs) {
  my $d=join(",",@diffs);
  $post_test="diffs in: $d";
  return 1;
} else {
  my $d=@sources;
  $post_test="$d goldfile(s) match";
  return 0;
}
