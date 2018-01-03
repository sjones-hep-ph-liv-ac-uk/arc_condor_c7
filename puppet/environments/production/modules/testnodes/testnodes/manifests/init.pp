class testnodes(
  $ensure = $testnodes::params::ensure,
  $version = $testnodes::params::version,
) inherits testnodes::params {

  # PARAMETER INITIALISATION / CHECKING
  # set local variables as appropriate
  if $ensure == 'absent' {
    $testnodes_ensure = 'absent'
    $config_ensure = 'absent'
  } else {
    $testnodes_ensure = $version
    $config_ensure = 'file'
  }

  # INCLUDES / REQUIRES

  # RESOURCES

  # - REPOS

  # - PACKAGES

  # - FILES

  # 
  file { "/usr/libexec/condor/scripts":
    ensure => "directory",
    mode => "755",
    require => Package ["condor"],
  }

  file { "/usr/libexec/condor/scripts/testnode.sh":
    source => "puppet:///modules/testnodes/emi-testnode.sh",
    mode => "755",
    #before => Package["lcg-CA"],
    require => File["/usr/libexec/condor/scripts"],
  }

  file { "/usr/libexec/condor/scripts/testnodeWrapper.sh":
    source => "puppet:///modules/testnodes/testnodeWrapper.sh",
    require => [File["/usr/libexec/condor/scripts"],File ["/usr/libexec/condor/scripts/testnode.sh"]],
    mode => "755",
  }


  # CRONS

  # SERVICES

  # EXECS

}

