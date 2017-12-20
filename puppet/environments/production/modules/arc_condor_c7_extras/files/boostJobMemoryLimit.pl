#!/usr/bin/perl
use strict;

if ($#ARGV != 0) {
  die("Give a boost factor , e.g. 2.0\n");
}

if (! -f "/root/scripts/boosted.log") {
  system("touch /root/scripts/boosted.log");
}

my %boosted;
open(BOOSTED,"/root/scripts/boosted.log") or die("Cannot open boosted file\n");
while(<BOOSTED>) {
  my $j = $_;
  chomp($j);
  $boosted{$j} = 1;
}
close(BOOSTED);

my $boostFactor = shift;
my @jobs;
open(JOBS,"condor_q |") or die("Cannot get job list\n");
while(<JOBS>) {
  my $line = $_;
  if ($line =~ /^(\d+\.\d+)/) {
    my $j = $1;
    if (! defined($boosted{$j})) {
      push (@jobs,$j);
    }
  }
}
close(JOBS);
open(BOOSTED,">>/root/scripts/boosted.log") or die("Cannot append to the boosted.log file\n");
foreach my $j (@jobs) {
  open(ATTRIBS,"condor_q -long $j|") or die("Could not get details for job $j\n");
  while (<ATTRIBS>) {
    my $attrib = $_;
    if ($attrib =~ /(.*) = (.*)/) {
      my $aName = $1;
      my $aVal = $2;
      if ($aName eq 'JobMemoryLimit') {
        my $newJobMemoryLimit = int($aVal * $boostFactor);
        print("Boosting JobMemoryLimit for job  $j from $aVal to $newJobMemoryLimit\n");
        open(QEDIT,"condor_qedit $j JobMemoryLimit $newJobMemoryLimit|") or die("Could not boost $j\n");
        my $response = <QEDIT>;
        if ($response !~ /Set attribute.*JobMemoryLimit/) {
          die ("Failed when boosting  $j, message was $response\n");
        }
        close(QEDIT);
        print BOOSTED "$j\n";
      }
    }
  }
  close(ATTRIBS);
}
close(BOOSTED);

