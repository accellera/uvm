##---------------------------------------------------------------------- 
##   Copyright 2011 Cadence
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
# goldfiles are all files in the local directory *.au and *.au.$tool
# each goldfile is compared to a produced file by chopping \.au(.$tool)$ from the goldfile
# 
# 1. each produced file is filtered and saved as .post
# 2. then a diff is performed between X.post and X.au(.$tools) and saved as X.df
# 3. the script returns showing the mismatches (or not)


# consider all *.au and *.au.$tool files
#my $tool="ius";
#my $log="tests/10resources/99Mantis_fixes/3416/bla";
my $dir=dirname($log);
my @sources = bsd_glob("$dir/*.{au,au.$tool}",GLOB_CSH);
my @diffs=();
my %lookup=();

if(!@sources) {
  push @diffs;"no gold files";
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

$$logfile =~ s/\@\d+/\@X/sg;
# strip header
$$logfile =~ s/^# //mg;
$$logfile =~ s/.*\nGOLD-FILE-START\n//sx;
$$logfile =~ s/\nGOLD-FILE-END.*/\n/sx;
$$logfile =~ s/^ncsim>.*$//mg;
$$logfile =~ s/^.*\.svh.*$//mg;
$$logfile =~ s/\n+\n/\n/sxg;
$$logfile =~ s/^UVM-\S+\s+\(\S+\)$/UVM-VERSION/mg;
$$logfile =~ s/^\(C\).*$/COPYRIGHT/mg;
$$logfile =~ s/COPYRIGHT(.COPYRIGHT)+/COPYRIGHT/sg;
$$logfile =~ s/^SVSEED.*\n//sg;
if ($tool eq "questa") {
  $$logfile =~ s/class p(::|\/)/class p::/sg;
}

}

sub diffLogs {
  my($gold,$post)=@_;

  if (system("diff -b $post.post $gold > $post.df")) {
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
  open(INFILE,$FILENAME) || push @diffs,"can't open file [$FILENAME][$!]";
  undef $/;
  $TEXT .= <INFILE>;
  $/ = "\n";
  close(INFILE);
  return ($TEXT);
}

#print "alive";
#print Dumper(@sources);
foreach my $goldfile (@sources) {
  my $current = $goldfile;
  $current =~ s/\.au(\.$tool)?$//g;
  my $c = ReadFileAsText($current);
  
  cleanFileAndWrite($c,"$current.post");
  push @diffs,diffLogs($goldfile,$current);

  if(! (-e $current && -r $current)) {
      push @diffs,"goldfile exists but log ($current) does not";
  }

  if(exists $lookup{$current}) {
    push @diffs,"fatal: generic goldfile and simulator specific exists";
  }
  $lookup{$current}=1;
}
#print Dumper(@diffs);

if(@diffs) {
  my $d=join(",",@diffs);
  $post_test="diffs in: $d";
  return 1;
} else {
  my $d=@sources;
  $post_test="$d goldfile(s) match";
  return 0;
}
