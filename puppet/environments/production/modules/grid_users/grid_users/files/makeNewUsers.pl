#!/usr/bin/perl
use strict;

die ("Pleace give the users.conf file") unless ($#ARGV == 0);
my $newUsersConf = $ARGV[0];

# Two types of record
# uid   login   gri1  grn1  vo    flag (none)
#20098:alice099:2001:alice:alice::
# uid   login   gri1 gri2  grn1     grn2   vo   flag
#20300:prdalc01:2002,2001:aliceprd,alice:alice:prd:
my %primaryGroupNames; my %primaryGroupIds;
my %secondaryGroupNames; my %secondaryGroupIds;

open (USERSCONF,$newUsersConf) or die("No open $newUsersConf");
open(PRIMARYGROUPCMDS,">prigrcmds_runFirst.sh") or die("No write prigrcmds_runFirst.sh");
open(NEWUSERSCMDS,">newusers_runSecond.sh") or die("No write newusers_runSecond.sh");
open(SECONDARYGROUPCMDS,">secgrcmds_runThird.sh") or die("No write secgrcmds_runThird.sh");

print NEWUSERSCMDS "newusers << ALLNEWSUSERS\n";
my %logins;

while (<USERSCONF>) {
  my $line = $_; chomp($line);
  my @fields = split(/:/,$line);
  my $uid = $fields[0];
  my $login = $fields[1];
  $logins{$login} = 1;
  my @groupsIds  = split(/,/,$fields[2]);
  my @groupNames  = split(/,/,$fields[3]);
  my $vo    = $fields[4];
  my $flag  = $fields[5];
  #pw_name:pw_passwd:pw_uid:pw_gid:pw_gecos:pw_dir:pw_shell
  my $primaryGroupId; my $secondaryGroupId;
  my $primaryGroupName; my $secondaryGroupName;
  $primaryGroupId  = $groupsIds[0];
  $primaryGroupName  = $groupNames[0];
  $secondaryGroupId = undef;
  $secondaryGroupName = undef;
  if ($#groupsIds == 1) {
    $secondaryGroupId = $groupsIds[1];
    $secondaryGroupName = $groupNames[1];
  }
  if (defined($primaryGroupId) && !defined($primaryGroupIds{$primaryGroupId})) {
    $primaryGroupIds{$primaryGroupId} = 1;
    print (PRIMARYGROUPCMDS "groupadd -g $primaryGroupId $primaryGroupName\n");
  }
  if (defined($secondaryGroupId) ) {
    $secondaryGroupIds{$secondaryGroupId} = 1;
    print (SECONDARYGROUPCMDS "usermod -a -G $secondaryGroupName $login \n");
  }
  print (NEWUSERSCMDS "$login\:*NP*\:$uid:$groupsIds[0]\:\:/home/$login\:/bin/bash\n");
}
close(USERSCONF);
close(PRIMARYGROUPCMDS);
close(SECONDARYGROUPCMDS);
print NEWUSERSCMDS "ALLNEWSUSERS\n";
close(NEWUSERSCMDS);

# Make the users and groups
system("chmod 700 secgrcmds_runThird.sh prigrcmds_runFirst.sh newusers_runSecond.sh");
system("./prigrcmds_runFirst.sh; ./newusers_runSecond.sh; ./secgrcmds_runThird.sh");

open(SHADOW,"/etc/shadow") or die("No open /etc/shadow");
open(SHADOWNEW,">/etc/shadow.new") or die("No open /etc/shadow.new");
while(<SHADOW>) {
  my $line = $_;
  my @parts = split(/:/,$line);
  my $login = $parts[0];
  if (defined($logins{$login})) {
    # It's one of ours; no password
    $line =~ s/:.*?:/:*NP*:/;
  }
  print SHADOWNEW $line;
}
close(SHADOW);
close(SHADOWNEW);

system("mv /etc/shadow.new /etc/shadow; chmod 000 /etc/shadow");


