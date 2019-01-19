#!/usr/bin/perl
# abstract: traverse dirs in $HOME/dev and tell me what I accomplished today

use strict;
use warnings;

use Git::Sub;
use Cwd qw(getcwd);
use POSIX qw(strftime);
use File::Basename qw(dirname);
use Term::ExtendedColor qw(fg bg bold italic);
use File::LsColor qw(ls_color);

my $dev_dir = "$ENV{HOME}/dev";
my @additional_dirs = ("$ENV{HOME}/etc");

my $today = strftime "%Y-%m-%d", localtime;

$today = '2019-01-18';


for my $project(glob("$dev_dir/*"), @additional_dirs) {
  if(-d "$project/.git") {
    chdir  $project or warn $!;
    my($date, $commit) = split(/¶/, git::log qw(HEAD  --date=short --pretty=format:%cd¶%x00%s%x00));

    # highlight any filename with an extension
    if($commit =~ m/^(\S+):\s+(.+)$/) {
      $commit = sprintf("%s: %s", ls_color($1), $2);
    }
    # highlight any module name
    $commit =~ s/([A-Z_a-z][0-9A-Z_a-z]*::[0-9A-Z_a-z]+)/fg(196, $1)/e;
    

    if($date eq $today) {
      my ($basedir) = $project =~ m{.+/(.+)$};
      printf "· %s\n  %s\n", fg(51, bg(30, bold(italic($basedir)))), $commit;
    }
  }
}


#for dir in $DEVDIR/*; do
#  cd $dir
#  [[ -d '.git' ]] && git last | grep $DATE
#done
