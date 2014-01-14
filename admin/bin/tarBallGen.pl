#!/usr/bin/perl -w
use strict;

#################################
# PLEASE READ
# The following is a quick hack to generate the tarball 
# Until it is made more "sophisticated", please uncomment the following lines
# to appropriate values, comment the die message below and go ahead.
#
#
# ./tarBallGen.pl <branch> <RC-label> <directory-prefix>
#
# ./tarBallGen.pl UVM_1_1_d RC7 uvm-1.1d

my $tag = undef;
my $rc = undef;
my $prefix = undef;
my $branch = undef;
my $localBranch = undef;


$branch       =        $ARGV[0]; #"UVM_1_1_d";
$rc        =           $ARGV[1]; #"RC7";
$prefix    =           $ARGV[2]; # "uvm-1.1d";
$tag       =           "$branch\_RELEASE";
$localBranch     =     "$branch._local";
#my $debug  =           1; # Do everything except push if TRUE
my $debug  =           0; # Do everything except push if TRUE
#die "Please set params above\n";

##################################

my $tar = "${prefix}_$rc.tar.gz";

die "uvm already exists" if (-e "uvm");
die "$tar already exists" if -e $tar;

my $cmd = "git clone git://git.code.sf.net/p/uvm/code uvm";
system ("echo $cmd"); system ("$cmd");

chdir "uvm" or die "Failed to cd uvm\n";

$cmd = "git checkout -b $localBranch origin/$branch";
system ("echo $cmd"); system ("$cmd");

my $commit_id = `git describe`; chomp $commit_id;

# Tag the release
$cmd = "git tag -f -a -m \"Release candidate with tag $tag\" $tag $commit_id;";
$cmd .= "git push --tags;";
system ("echo $cmd"); system ("$cmd") unless $debug;


# Now generate the docs in a separate branch

# Create the branch
$cmd = "git checkout -b $tag\_".$rc."_WITHHTMLDOC $tag";
system ("echo $cmd"); system ("$cmd");

$ENV{ND} = "$ENV{'PWD'}/uvm/natural_docs";
chdir  "uvm_ref/nd" or die "Failed to cd to uvm_ref/nd";

$cmd = "./gen_nd";
system ("echo $cmd"); system ("$cmd");

chdir "$ENV{'PWD'}/uvm/distrib/docs" or die "Failed to cd to ../../distrib/docs";

$cmd = "git add html;  git commit -m \"commited docs for $tag\"";
system ("echo $cmd"); system ("$cmd");

chdir ".." or die "Failed to cd to .. (distrib)";

$cmd = "git push origin $tag\_".$rc."_WITHHTMLDOC";
system ("echo $cmd"); system ("$cmd") unless $debug;

# Tag the release with doc
$commit_id = `git describe`; chomp $commit_id;
$cmd = "git tag -f -a -m \"Release candidate with tag $tag\" $tag\_".$rc."_WITHHTMLDOC $commit_id;";
$cmd .= "git push --tags;";
system ("echo \"$cmd\""); system ("$cmd") unless $debug;

# Generate the tarball
$cmd = "git archive --format tar.gz --prefix=$prefix/  $commit_id > ../../$tar";
system ("echo $cmd"); system ("$cmd");

print "Tarball ready: $tar\n";


