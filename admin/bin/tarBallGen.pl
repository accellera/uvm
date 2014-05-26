#!/usr/bin/perl -w
use strict;

#################################
# PLEASE READ
# The following is a quick hack to generate the tarball 
# Until it is made more "sophisticated", please uncomment the following lines
# to appropriate values, comment the die message below and go ahead.
#
#
# ./tarBallGen.pl <branch> <RC-label> <directory-prefix> <sf-user>
#
# ./tarBallGen.pl UVM_1_1_d RC7 uvm-1.1d

my $tag = undef;
my $rc = undef;
my $prefix = undef;
my $branch = undef;
my $user = undef;
my @fileset = undef;
my $baseurl = undef;

$branch       =        $ARGV[0]; #"UVM_1_1_d";
$rc        =           $ARGV[1]; #"RC7";
$prefix    =           $ARGV[2]; # "uvm-1.1d";
$tag       =           "$branch\_RELEASE";
$user = $ARGV[3];
@fileset = ("release-notes.txt", "README.txt", "src/macros/uvm_version_defines.svh");

#my $debug  =           1; # Do everything except push if TRUE
my $debug  =           1; # Do everything except push if TRUE
#die "Please set params above\n";

#
#
if($debug) {
    $baseurl = "~uwes/src/uvm";
} else {
    $baseurl = "ssh://${user}\@git.code.sf.net/p/uvm/code";
}

##################################

my $tar = "${prefix}_$rc.tar.gz";

die "uvm already exists" if (-e "uvm");
die "$tar already exists" if -e $tar;

msys("git clone $baseurl uvm",0);

chdir "uvm" or die "Failed to cd uvm\n";

msys("git checkout -b $branch origin/$branch",0);

my $rbranch = "$tag\_$rc\_WITHHTMLDOC";

# Tag the release
msys("git tag -f -a -m \"Release candidate with tag $tag\" $tag;",0);

# Now generate the docs in a separate branch
msys("git checkout -b $rbranch",0);

$ENV{ND} = "$ENV{'PWD'}/uvm/natural_docs";
chdir  "uvm_ref/nd" or die "Failed to cd to uvm_ref/nd";

msys("./gen_nd",0);

chdir "$ENV{'PWD'}/uvm/distrib/docs" or die "Failed to cd to ../../distrib/docs";

msys("git add html;  git commit -m \"commited docs for $tag\"",0);

chdir ".." or die "Failed to cd to .. (distrib)";

msys("pwd",0);
# fix variables
my $literal_version = "$branch\-$rc";
$literal_version=~ s/^UVM_//;
$literal_version=~ s/(\d+)_(\d+)/$1.$2/g;
$literal_version=~ s/(\d+)_(w+)/$1$2/;
print "version identifier used [$literal_version]\n";
my $literal_date=qx{date};
chomp $literal_date;

foreach my $file (@fileset) {
    msys("replace ~UVM:version~ \"$literal_version\" -- $file",0);
    msys("replace ~UVM:date~ \"$literal_date\" -- $file",0);
# TODO:
# the UVM_FIX_REV should be "git" when the native git branch is used
# or the postfix of the literal_version such as "a","b" or "a-RC1"
# the postfix should be derived from the branch name
#
#    msys("replace \$UVM:version\$ $literal_version -- $file",0);
}
print "automatic differences by keywords\n";
msys("git diff",0);

# remove because sf forbids non-forward pushs
msys("git push origin :refs/heads/$rbranch",$debug);
msys("git push --force origin refs/heads/$rbranch",$debug);

# Tag the release with doc
msys("git tag -f -a -m \"Release candidate with tag $tag\" $rbranch;git push  --tags --force origin;",$debug);

# Generate the tarball
msys("git archive --format tar.gz --prefix=$prefix/  refs/tags/$rbranch > ../../$tar",$debug); 

print "Tarball ready: $tar\n";

sub msys {
    my($cmd,$skip)=@_;
    if($skip) {
	print "skip: $cmd\n"; 
    } else {
	print "$cmd\n";
    }
    system ("$cmd") unless $skip;
}
