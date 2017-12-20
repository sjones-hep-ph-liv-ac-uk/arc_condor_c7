#!/usr/bin/perl

use strict;
my @mcs;
my @scs;

my $rc;
my $id;

my $singleCoreJobs;
my $multiCoreJobs;

open(CQ,"condor_q -long -attributes clusterid,requestcpus|") or die("Can't run condor_q");
while(<CQ>) {
  if (/requestcpus = (.*)/) {
    $rc = $1;
  }
  if (/clusterid = (.*)/) {
    $id = $1;
    if ($rc == 1) {
      push(@scs,$id);
      $singleCoreJobs = $singleCoreJobs . " " . $id;
    }
    else {
      push(@mcs,$id);
      $multiCoreJobs = $multiCoreJobs . " " . $id;
    }
  }
}
if ($#scs != -1) {
  open (QC,"condor_q $singleCoreJobs | grep -v '^\\s*\$' | sed '1,2d'  |") or die("No run condor_q");
  while(<QC>) {
    print "SC: ", $_;
  }
  close(QC);
}

if ($#mcs != -1) {
  open (QC,"condor_q $multiCoreJobs | grep -v '^\\s*\$' | sed '1,2d'  |") or die("No run condor_q");
  while(<QC>) {
    print "MC: ", $_;
  }
  close(QC);
  exit;
}

my @lines ;
foreach my $j (@scs) {
  open (QC,"condor_q $j|") or die("No run condor_q");
  while(<QC>) {
    my $line = $_;
    chomp($line);  
    if ($line =~ /^\d\d*\.0.*/) {
      push(@lines,"SC: " . $line);
    }
  }
  close(QC);
}
foreach my $j (@mcs) {
  open (QC,"condor_q $j|") or die("No run condor_q");
  while(<QC>) {
    my $line = $_;
    chomp($line);  
    if ($line =~ /^\d\d*\.0.*/) {
      push(@lines,"MC: " . $line);
    }
  }
  close(QC);
}

foreach my $l (@lines) {
  print $l,"\n";
}

