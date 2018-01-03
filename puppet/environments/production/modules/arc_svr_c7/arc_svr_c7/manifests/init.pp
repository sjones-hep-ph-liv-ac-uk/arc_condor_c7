class arc_svr_c7() inherits arc_svr_c7::params 
{

  # PARAMETER INITIALISATION / CHECKING

  # INCLUDES / REQUIRES

  ## USERS

  # RESOURCES

  # - REPOS

  yumrepo { "nordugrid5":
    name => "nordugrid5",
    baseurl => "http://map2.ph.liv.ac.uk/yum/pub/download.nordugrid.org/repos/15.03/centos/el7/x86_64/base",
    enabled => "1",
    gpgcheck => "1",
    gpgkey => "http://download.nordugrid.org/RPM-GPG-KEY-nordugrid",
    require  => Package["yum-plugin-priorities"],
    priority => "15",
  }

  yumrepo { "nordugrid5-updates":
    name => "nordugrid5-updates",
    baseurl => "http://map2.ph.liv.ac.uk/yum/pub/download.nordugrid.org/repos/15.03/centos/el7/x86_64/updates",
    enabled => "1",
    gpgcheck => "1",
    gpgkey => "http://download.nordugrid.org/RPM-GPG-KEY-nordugrid",
    require  => Package["yum-plugin-priorities"],
    priority => "15",
  }


  # - PACKAGES

  package { "nordugrid-arc-compute-element": ensure => installed }

  file { "/var/log/arc/diagfiles":
    ensure => "directory",
    require => Package["nordugrid-arc-compute-element"],
    mode => "755",
  }
  file { "/var/urs": ensure => "directory", mode => "755", }
  #file { "/etc/a rc": ensure => "directory", mode => "755", }
  #file { "/etc/a rc/ru ntime":
  #  ensure => "directory",
  #  mode => "755",
  #  require => File ["/etc/arc"],
  #}

  file { '/etc/arc.conf':
    require => Package['nordugrid-arc-compute-element'],
    content => template('arc_svr_c7/arc.conf.erb'),
  }

  # SERVICES

  # EXECS
  # 
  exec { "enable_ksm":
    command =>  "/bin/echo 1 > /sys/kernel/mm/ksm/run",
    unless => "/bin/grep ^1$ /sys/kernel/mm/ksm/run",
    timeout => "86400"
  }

  # OTHERSTUFF

}
