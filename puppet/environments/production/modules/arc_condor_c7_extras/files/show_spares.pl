#!/usr/bin/perl
#---------------------------------------------
# A tool to split up the slots of a machine
#---------------------------------------------

use strict;
use Getopt::Long;

# Global options
my %parameter;

#-------------------------------------

# Read the options
initParams();

# Get the guff on the machine and split it out.

my @machines;
open(GUFF,"condor_status -long $parameter{MACHINE}|") or die("Could not get the guff on $parameter{'MACHINE'}, $!");
my $count=0;
my $currentMachine = 0 ;
while(<GUFF>) {
  $count++;
  my $line = $_;
  #next unless($line !~ /^child/);
  if ($line =~ /^$/) {
    $currentMachine++;
  }
  else {
    if (!(defined($machines[$currentMachine]))) {
      $machines[$currentMachine] = {};
    }
    $line =~  /^([a-zA-Z0-9\-\_]+) = (.*)/;
    my $key = $1;
    my $payload = $2;
    $machines[$currentMachine]{$key} = $payload;
  }
}
close(GUFF);
die ("Could not get any guff on  $parameter{'MACHINE'}, $!") unless $count > 0;

my %metaSlotHash = %{$machines[0]};
if ($metaSlotHash{Activity} =~ /Retiring/) {
  print("Machine $parameter{'MACHINE'} is draining\n");
}
else {
  my $spares = $metaSlotHash{Cpus};
  if ($spares == 0) {
    print("Machine $parameter{'MACHINE'} is full\n");
  }
  else {
    print("Machine $parameter{'MACHINE'} has $spares spares\n");
  }
}

exit;

my $m = -1;
foreach my $mHash (@machines) {
  $m++;
  #print $m;
  my %h = %{$mHash};
  foreach my $k (keys(%h)) {
    my $payload = $h{$k};
    print($k, ' = ',$payload . "\n");
  }
}



#---------------------------------------------
# Read the command line options
#---------------------------------------------
sub initParams() {


  # Read the options
  GetOptions ('h|help'        =>   \$parameter{'HELP'},
              'm|machine:s'   =>   \$parameter{'MACHINE'} ,
              );

  if (defined($parameter{'HELP'})) {
    print <<TEXT;

Abstract: A tool to remove accounts from a VO

  -h  --help                  Prints this help page
  -m  --machine      r21-n01  Machine to deal with

Example:
  ./slot_splitter.pl -m r21-n01

TEXT
    exit(0);
  }
  if (!(defined($parameter{'MACHINE'}))) {
    die ("You must give the script a machine to work with\n");
  }
}


