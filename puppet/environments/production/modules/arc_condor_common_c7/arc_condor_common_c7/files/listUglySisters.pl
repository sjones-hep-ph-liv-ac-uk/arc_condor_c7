#!/usr/bin/perl

use strict;

opendir (my $dir_h, '/var/log/arc/') or die ("Cannot open directory: $!");
my @files = grep { /jura.log/ } readdir $dir_h;
closedir $dir_h;
my %removed;
foreach my $f (@files) {
  open(F,"/var/log/arc/$f") or die("Cannot open file: $!");
  while(<F>) {
    if (/INFO: Removing sent file .*\/([a-zA-Z0-9]{54})\./) {
      my $stem = $1;
      $removed{$stem} = 1;
    }
  }
  close(F);
}

opendir (my $dir_h, '/var/spool/arc/jobstatus/logs') or die ("Cannot open directory: $!");
my @files = grep { /[a-zA-Z0-9]{54}\.[A-Z0-9]{6}/ } readdir $dir_h;
closedir $dir_h;

my %logFiles;
foreach my $f (@files) {
  $f =~ /([a-zA-Z0-9]{54})\.[A-Z0-9]{6}/;
  my $stem = $1;
  if (! (defined($logFiles{$stem}))) {
    $logFiles{$stem} = [];
  }
  push(@{$logFiles{$stem}},$f);
}
my @uglySisters;
foreach my $s (keys(%logFiles)) {
  if (defined($removed{$s})) {
    my @logFiles = @{$logFiles{$s}};
    foreach my $f (@logFiles) {
      push(@uglySisters,$f)
    }
  }
}
foreach my $us (@uglySisters) {
  print ("Ugly sister - $us\n");
}
