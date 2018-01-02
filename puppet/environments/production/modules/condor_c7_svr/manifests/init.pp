class condor_c7_svr() inherits condor_c7_svr::params 
{

  # PARAMETER INITIALISATION / CHECKING

  # INCLUDES / REQUIRES

  ## USERS

  # RESOURCES

  # - REPOS
  yumrepo { "condor_c7_svr":
    descr => "condor_c7_svr",
    baseurl => "http://map2.ph.liv.ac.uk/yum/pub/research.cs.wisc.edu/htcondor/yum/stable/rhel7",
    protect => 1,
    priority => 5,
    enabled => 1,
    gpgcheck => 0,
  }

  # - PACKAGES

  package { 'condor':   ensure => $condor_c7_svr_ensure }

  # - FILES

  file { "/etc/ld.so.conf.d/condor.conf":
    source => "puppet:///modules/condor_c7_svr/condor.conf",
    mode => "644",
  }
  exec { "/sbin/ldconfig":
    command => "/sbin/ldconfig",
    refreshonly => true,
    subscribe => File [ "/etc/ld.so.conf.d/condor.conf"]
  }

  file { "/var/lib/condor/spool/history":
    mode => "777",
  }

  # No slots on headnode!
  file { "/etc/condor/config.d/00-headnode_parameters":
    source => "puppet:///modules/condor_c7_svr/00-headnode_parameters",
    mode => "644",
  }

  file { "/etc/condor/config.d/14accounting-groups-map.config":
    source => "puppet:///modules/condor_c7_svr/14accounting-groups-map.config",
    mode => "644",
  }
  file { "/etc/condor/config.d/11fairshares.config":
    source => "puppet:///modules/condor_c7_svr/11fairshares.config",
    mode => "644",
  }

  file {'/etc/condor/config.d/00personal_condor.config': ensure => absent, }

  file { "/var/lib/condor/persistent_config_dir": ensure => "directory", mode => "700",owner => "root", }

  
  file { '/etc/condor/condor_config.local':
    require => Package['condor'],
    content => template('condor_c7_svr/condor_config.local.erb'),
  }
  
  # Condor
  file { '/etc/condor/config.d': ensure  => directory, mode    => '755', }
  file { "/etc/condor/pool_password": source => "puppet:///modules/condor_c7_svr/pool_password" ,  mode    => '400', }


  # SERVICES

  # EXECS
  # 

  exec {"condor_c7_svr/etc/condor":
    command => "/bin/mkdir /etc/condor; chmod 755 /etc/condor",
    onlyif => "/usr/bin/test ! -d /etc/condor",
  }
  exec {"condor_c7_svr/var/lib/condor":
    command => "/bin/mkdir /var/lib/condor; chmod 755 /var/lib/condor",
    onlyif => "/usr/bin/test ! -d /var/lib/condor",
  }

  # OTHERSTUFF

  cron { "condor_jobs_running":
    command => "/usr/bin/condor_q -constraint 'JobStatus==2' -autoformat x509UserProxyVOName | sort | uniq -c > /var/local/condor_jobs_running",
    user => root,
    minute   => "*/10",
    hour     => "*", monthday => "*", month    => "*", weekday  => "*",
  }

  cron { "condor_jobs_idle":
    command => "/usr/bin/condor_q -constraint 'JobStatus==1' -autoformat x509UserProxyVOName | sort | uniq -c > /var/local/condor_jobs_idle",
    user => root,
    minute   => "*/10",
    hour     => "*", monthday => "*", month    => "*", weekday  => "*",
  }
}
