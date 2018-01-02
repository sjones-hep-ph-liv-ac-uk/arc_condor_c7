class arc_condor_c7_extras(
) inherits arc_condor_c7_extras::params {

  # Security
  file { "/etc/grid-security/grid-mapfile": source => "puppet:///modules/arc_condor_c7_extras/grid-mapfile", mode => "644", }

  # ARC/Condor services 
  service { "condor": ensure => running, enable => true, hasstatus => true }
  service { "a-rex": ensure => running, enable => true, hasstatus => true }
  service { "nordugrid-arc-bdii":  enable => false, hasstatus => true }
  service { "nordugrid-arc-inforeg":  enable => false, hasstatus => true }
  service { "nordugrid-arc-slapd":  enable => false, hasstatus => true }

  # Scripts to work above
  file { "/root/scripts/arcServicesStop.sh": source => "puppet:///modules/arc_condor_c7_extras/arcServicesStop.sh", mode => "755", }
  file { "/root/scripts/arcServicesStart.sh": source => "puppet:///modules/arc_condor_c7_extras/arcServicesStart.sh", mode => "755", }
  file { "/root/scripts/arcServicesStatus.sh": source => "puppet:///modules/arc_condor_c7_extras/arcServicesStatus.sh", mode => "755", }
  file { "/root/scripts/arcServicesMakeSure.sh": source => "puppet:///modules/arc_condor_c7_extras/arcServicesMakeSure.sh", mode => "755", }
  exec { "arcServicesMakeSure.sh":
    command => "/root/scripts/arcServicesMakeSure.sh",
  }

  # Some dir that arc needs (why does it not make it itself form the rpm?)
  file { '/var/spool/arc/grid': ensure  => directory, mode    => '755', }

  # The scripts dir
  file { '/root/scripts': ensure  => directory, mode    => '755', }

  # Restart slapd now and again due to mem leak (it sems to help)
  cron { "fixslapd":
    command => "/etc/init.d/nordugrid-arc-slapd restart",
    user    => root, hour    => "*/8", minute  => "25"
  }

  # Boost memory limit to stop jobs getting killed
  file { "/root/scripts/boostJobMemoryLimit.pl": source => "puppet:///modules/arc_condor_c7_extras/boostJobMemoryLimit.pl", mode => "755", }
  cron { "boostJobMemoryLimit.pl":
    command => "/root/scripts/boostJobMemoryLimit.pl 3.0 >> /root/scripts/boostJobMemoryLimit.log",
    user    => root, 
    minute   => "*/5", hour     => "*", monthday => "*", month    => "*", weekday  => "*", 
  }

  # A little system to do some file cleanup
  file { "/root/scripts/cleanJobstatusDirs.sh": source => "puppet:///modules/arc_condor_c7_extras/cleanJobstatusDirs.sh", mode => "755", }
  cron { "cleanJobstatusDirs.sh":
    command => "/root/scripts/cleanJobstatusDirs.sh >> /root/scripts/cleanJobstatusDirs.log",
    user    => root, 
    minute => '30', hour => '13', month => '*', weekday => '*', 
  }

  # Make it an acr client as well
  ###package { "nordugrid-arc-client-tools": ensure => installed }


  # A fetch CRL procedure
  package { "fetch-crl": ensure => installed }
  service { "fetch-crl-cron": ensure => running, enable => true, hasstatus => true, require   => Package [ "fetch-crl"] }
  exec { "fetch-crl":
    command => "/usr/sbin/fetch-crl -a 24 -r 20 >> /var/log/fetch-crl-cron.log 2>&1",
    path => ["/sbin", "/bin", "/usr/sbin", "/usr/bin"],
    refreshonly => true,
    timeout => "600",
    subscribe => Package["lcg-CA"]
  }

  # A little system I wrote to log how the system gets used
  package { "usageLogger": ensure => installed }
  service { "usagelogger": require => Package["usageLogger"],ensure => running, enable => true, hasstatus => true, }
  #package { "Utilisation": ensure => installed , }

  # A little systemn to monitor the grid-manager heartbeat file; it gets stuck sometimes.
  file { "/root/scripts/gmmon.py":
    ensure => present,
    source => "puppet:///modules/arc_condor_c7_extras/gmmon.py",
    mode => "755"
  }
  cron { "gmmon":
    command => "/root/scripts/gmmon.py",
    user    => root, minute  => "*/7"
  }

  # Something to let the accounting work (TODO might need SSL flag setting)
  file { "/usr/libexec/arc/jura_dummy":
    source => "puppet:///modules/arc_condor_c7_extras//jura_dummy",
    owner => "root",
    mode => "755",
  }
  package { "apel-client": ensure => installed , }
  file { "/root/scripts/send_accounting_data.sh": source => "puppet:///modules/arc_condor_c7_extras/send_accounting_data.sh", owner => "root", mode => "755", }
  cron { "send_accounting_data.sh":
    ensure => absent,
    command => "/root/scripts/send_accounting_data.sh",
    require => File["/root/scripts/send_accounting_data.sh"],
    user => root, hour => 6, minute => 16
  }

  # Any file or dir that is even suspected of being needed ...
  file { "/root/glitecfg/": ensure => "directory", mode => "755" }
  file { "/root/glitecfg/services": ensure => "directory", mode => "755" }
  file { "/var/spool/arc/debugging": ensure => "directory", mode => "755" }
  file { "/usr/etc/globus-user-env.sh": ensure => present, mode   => "755", content => "", }

  # A bunch of tools that I use a fair bit
  file { "/root/scripts/beef_up_mcore_userprio.sh": source => "puppet:///modules/arc_condor_c7_extras/beef_up_mcore_userprio.sh", owner => "root", mode => "755", }
  file { "/root/scripts/show_spares.pl": source => "puppet:///modules/arc_condor_c7_extras/show_spares.pl", owner => "root", mode => "755", }
  file { "/root/scripts/show_all_spares.sh": source => "puppet:///modules/arc_condor_c7_extras/show_all_spares.sh", owner => "root", mode => "755", }
  file { "/root/scripts/listUglySisters.pl": source => "puppet:///modules/arc_condor_c7_extras/listUglySisters.pl", owner => "root", mode => "755", }
  file { "/root/scripts/condor_q_cores.pl": source => "puppet:///modules/arc_condor_c7_extras/condor_q_cores.pl", owner => "root", mode => "755", }
  file { "/root/scripts/nodes.sh": source => "puppet:///modules/arc_condor_c7_extras/nodes.sh", owner => "root", mode => "755", }
  file { "/root/scripts/startJobsOff.sh": source => "puppet:///modules/arc_condor_c7_extras/startJobsOff.sh", owner => "root", mode => "755", }
  file { "/root/scripts/startJobsOn.sh": source => "puppet:///modules/arc_condor_c7_extras/startJobsOn.sh", owner => "root", mode => "755", }
  file { "/root/scripts/startJobsShow.sh": source => "puppet:///modules/arc_condor_c7_extras/startJobsShow.sh", owner => "root", mode => "755", }
  file { "/root/scripts/startJobsShowAll.sh": source => "puppet:///modules/arc_condor_c7_extras/startJobsShowAll.sh", owner => "root", mode => "755", }
  file { "/root/scripts/onlyMulticoreOff.sh": source => "puppet:///modules/arc_condor_c7_extras/onlyMulticoreOff.sh", owner => "root", mode => "755", }
  file { "/root/scripts/onlyMulticoreOn.sh": source => "puppet:///modules/arc_condor_c7_extras/onlyMulticoreOn.sh", owner => "root", mode => "755", }
  file { "/root/scripts/onlyMulticoreShow.sh": source => "puppet:///modules/arc_condor_c7_extras/onlyMulticoreShow.sh", owner => "root", mode => "755", }
  file { "/root/scripts/onlyMulticoreShowAll.sh": source => "puppet:///modules/arc_condor_c7_extras/onlyMulticoreShowAll.sh", owner => "root", mode => "755", }
  file { "/root/scripts/restart": source => "puppet:///modules/arc_condor_c7_extras/restart", owner => "root", mode => "755", }
  file { "/root/scripts/removeUglySisters.sh": source => "puppet:///modules/arc_condor_c7_extras/removeUglySisters.sh", owner => "root", mode => "755", }

  # Some BDII fixes; sooner the better it is gone.
  exec { "MendCpuTime":
    command => "/bin/sed -i -e 's/JobCpuLimit \= \$maxcputime/JobCpuLimit \= \$joboption_cputime/' /usr/share/arc/submit-condor-job",
    require => Package [ "condor"],
    onlyif => "/bin/grep 'JobCpuLimit \= \$maxcputime' /usr/share/arc/submit-condor-job",
  }

  exec { "MendBdiiBreaker":
    command => "/bin/sed -i -e 's/\$lrms_jobs{\$id}{nodes} \= \"\"\;/\$lrms_jobs\{\$id\}\{nodes\} \= \[\]\;/' /usr/share/arc/Condor.pm ",
    require => Package [ "condor"],
    onlyif => "/bin/grep  '\$lrms_jobs{\$id}{nodes} \= \"\"' /usr/share/arc/Condor.pm",
  }

  file { "/usr/share/arc/glue-generator.pl":
    source => "puppet:///modules/arc_condor_c7_extras//glue-generator.pl",
    owner => "root", 
    mode => "755",
  }

  # All the voms coordinates
  yumrepo { "RPMS.voms":
    descr => "RPMS.voms",
    baseurl => "http://hep.ph.liv.ac.uk/~sjones/RPMS.voms/",
    priority => 99 ,
    enabled => 1,
    gpgcheck => 0,
  }
  package { "gridpp-voms-alice": ensure => installed , }
  package { "gridpp-voms-atlas": ensure => installed , }
  package { "gridpp-voms-biomed": ensure => installed , }
  package { "gridpp-voms-calice": ensure => installed , }
  package { "gridpp-voms-cernatschool.org": ensure => installed , }
  package { "gridpp-voms-cms": ensure => installed , }
  package { "gridpp-voms-dteam": ensure => installed , }
  package { "gridpp-voms-enmr.eu": ensure => installed , }
  package { "gridpp-voms-epic.vo.gridpp.ac.uk": ensure => installed , }
  package { "gridpp-voms-esr": ensure => installed , }
  package { "gridpp-voms-fermilab": ensure => installed , }
  package { "gridpp-voms-geant4": ensure => installed , }
  package { "gridpp-voms-gridpp": ensure => installed , }
  package { "gridpp-voms-hyperk.org": ensure => installed , }
  package { "gridpp-voms-icecube": ensure => installed , }
  package { "gridpp-voms-ilc": ensure => installed , }
  package { "gridpp-voms-ipv6.hepix.org": ensure => installed , }
  package { "gridpp-voms-lhcb": ensure => installed , }
  package { "gridpp-voms-lsst": ensure => installed , }
  package { "gridpp-voms-lz": ensure => installed , }
  package { "gridpp-voms-magic": ensure => installed , }
  package { "gridpp-voms-mice": ensure => installed , }
  package { "gridpp-voms-na62.vo.gridpp.ac.uk": ensure => installed , }
  package { "gridpp-voms-ops": ensure => installed , }
  package { "gridpp-voms-pheno": ensure => installed , }
  package { "gridpp-voms-planck": ensure => installed , }
  package { "gridpp-voms-skatelescope.eu": ensure => installed , }
  package { "gridpp-voms-snoplus.snolab.ca": ensure => installed , }
  package { "gridpp-voms-supernemo.vo.eu-egee.org": ensure => installed , }
  package { "gridpp-voms-t2k.org": ensure => installed , }
  package { "gridpp-voms-vo.landslides.mossaic.org": ensure => installed , }
  package { "gridpp-voms-vo.moedal.org": ensure => installed , }
  package { "gridpp-voms-vo.northgrid.ac.uk": ensure => installed , }
  package { "gridpp-voms-vo.southgrid.ac.uk": ensure => installed , }
  package { "gridpp-voms-zeus": ensure => installed , }

  # Interface tools for ARC/Condor integration
  file { "/usr/local/bin/scaling_factors_plugin.py":
    source => "puppet:///modules/arc_condor_c7_extras/scaling_factors_plugin.py",
    mode => "755",
  }
  file { "/usr/local/bin/debugging_rte_plugin.py":
    source => "puppet:///modules/arc_condor_c7_extras/debugging_rte_plugin.py",
    require => File ["/var/spool/arc/debugging"],
    mode => "755",
  }
  file { "/usr/local/bin/default_rte_plugin.py":
    source => "puppet:///modules/arc_condor_c7_extras/default_rte_plugin.py",
    owner => "root",
    mode => "755",
  }

  # Service that I want to stop because it spoils things
  service { "yum-cron": ensure => stopped, enable => false  }

  # Various packages that I have learned we need. Fallow does the draining for mcore.
  yumrepo { "pub-tools":
    descr => "pub-tools",
    baseurl => "http://map2.ph.liv.ac.uk/yum/pub/tools/rpms",
    priority => 99 ,
    enabled => 1,
    gpgcheck => 0,
  }
  package { 'lcg-CA': ensure => latest,  }
  package { 'lfc-python.x86_64': ensure => latest,  }
  package { 'HEP_OSlibs': ensure => latest,  }
  package { 'git' : ensure => latest, }
  package { 'xorg-x11-xauth': ensure => latest, }
  package { 'xeyes': ensure => latest, }
  package { "fallow": ensure => installed }
  package { "globus-gsi-callback": ensure => installed , }
  package { "globus-ftp-control": ensure => installed , }
  service { "gridftpd": ensure => running, enable => true, hasstatus => true, }
  package { 'VomsSnooper': ensure => latest,  }

}
