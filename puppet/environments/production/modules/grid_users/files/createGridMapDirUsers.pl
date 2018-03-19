#!/usr/bin/perl
use strict;

die ("Pleace give the users.conf file") unless ($#ARGV == 0);
my $newUsersConf = $ARGV[0];

#20098:alice099:2001:alice:alice::
#20300:prdalc01:2002,2001:aliceprd,alice:alice:prd:

open (USERSCONF,$newUsersConf) or die("No open $newUsersConf");

if (!( -d "/etc/grid-security/")) {
  mkdir ('/etc/grid-security/',0770);
}
if (!( -d "/etc/grid-security/gridmapdir/")) {
  mkdir ('/etc/grid-security/gridmapdir/',0770);
}

while (<USERSCONF>) {
  my $line = $_; chomp($line);
  my @fields = split(/:/,$line);
  
  my $login = $fields[1];
  open(FILE, ">>/etc/grid-security/gridmapdir/$login")||die("Cannot open file:".$!);
  close(FILE);
}
close(USERSCONF);

