class condor_c7_umd4_wn(
  $ensure = $condor_c7_umd4_wn::params::ensure,
  $version = $condor_c7_umd4_wn::params::version,
  $space = $condor_c7_umd4_wn::params::space,

) inherits condor_c7_umd4_wn::params {

  # PARAMETER INITIALISATION / CHECKING
  # set local variables as appropriate
  if $ensure == 'absent' {
    $condor_c7_umd4_wn_ensure = 'absent'
    $config_ensure = 'absent'
  } else {
    $condor_c7_umd4_wn_ensure = $version
    $config_ensure = 'file'
  }

  if $service == 'running' {
    $service_ensure = 'running'
    $service_enable = true
  } else {
    $service_ensure = 'stopped'
    $service_enable = false
  }
    

  # INCLUDES / REQUIRES


  ## USERS

  # RESOURCES

  # - REPOS
  yumrepo {"sysadmin.hep.ac.uk":
    descr => "sysadmin.hep.ac.uk",
    baseurl => "http://map2.ph.liv.ac.uk/yum/pub/www.sysadmin.hep.ac.uk/rpms/fabric-management/RPMS.vomstools/",
    enabled => 1,
    gpgcheck=>0,
    priority=>99 ,
  }
  yumrepo { "CA":
    descr => "CA",
    baseurl => "http://map2.ph.liv.ac.uk/yum/EGI-CAs/current",
    #baseurl => "https://egi-igtf.ndpf.info/distribution/egi-1.87-1/ca-policy-egi-core-1.87-1/",
    protect => 1,
    priority => 5,
    enabled => 1,
    gpgcheck => 0,
  }
  yumrepo { "condor_c7_umd4_wn":
    descr => "condor_c7_umd4_wn",
    baseurl => "http://map2.ph.liv.ac.uk/yum/pub/research.cs.wisc.edu/htcondor/yum/stable/rhel7",
    protect => 1,
    priority => 5,
    enabled => 1,
    gpgcheck => 0,
  }
  yumrepo { "wlcg_repository":
    descr => "wlcg_repository",
    baseurl => "http://linuxsoft.cern.ch/wlcg/sl6/x86_64/",
    enabled => 1,
    protect => 1,
    priority => 1,
    gpgcheck => 0,
  }

  yumrepo { "yum_umd_4_centos7_x86_64_base":
    descr => "/yum/umd/4/centos7/x86_64/base",
    baseurl => "http://map2.ph.liv.ac.uk//yum/umd/4/centos7/x86_64/base",
    enabled => 1,
    gpgcheck => 0,
  }
  yumrepo { "yum_umd_4_centos7_x86_64_updates":
    descr => "/yum/umd/4/centos7/x86_64/updates",
    baseurl => "http://map2.ph.liv.ac.uk//yum/umd/4/centos7/x86_64/updates",
    enabled => 1,
    gpgcheck => 0,
  }

  # - PACKAGES
  package { 'condor':   ensure => $condor_c7_umd4_wn_ensure }
  package { 'voms-clients-java': ensure => latest,  }
  package { 'voms-clients-cpp': ensure => latest,  }
  package { 'fetch-crl': ensure => latest,  }
  package { 'lcg-CA': ensure => latest,  }
  package { 'wn': ensure => latest,  }
  package { 'mjf-htcondor': ensure => latest,  }
  package { 'lfc-python.x86_64': ensure => latest,  }
  package { 'HEP_OSlibs': ensure => latest,  }
  package { 'libXft-devel.x86_64': ensure => latest,  }
  package { 'libxml2-devel.x86_64': ensure => latest,  }
  package { 'libXpm-devel.x86_64': ensure => latest,  }
  package { 'bzip2-devel.x86_64': ensure => latest,  }
  package { 'gcc-c++.x86_64': ensure => latest,  }
  package { 'gcc-gfortran.x86_64': ensure => latest,  }
  package { 'gmp-devel.x86_64': ensure => latest,  }
  package { 'imake.x86_64': ensure => latest,  }
  package { 'ipmitool.x86_64': ensure => latest,  }
  package { 'libgfortran.x86_64': ensure => latest,  }
  package { 'liblockfile-devel.x86_64': ensure => latest,  }
  package { 'ncurses-devel.x86_64': ensure => latest,  }
  package { 'git' : ensure => latest, }
  package { 'xorg-x11-xauth': ensure => latest, }
  package { 'xeyes': ensure => latest, }

  # - FILES

  file { "/etc/sudoers":
    source => "puppet:///modules/condor_c7_umd4_wn/sudoers",
    mode => 440,
    owner => "root",
    group => "root",
  }

  file {'/etc/condor/config.d/00personal_condor.config': ensure => absent, }

  # Build this file up as per nodetype
  file { '/etc/condor/config.d/00-node_parameters':
    require => Package['condor'],
    ensure  => $config_ensure,
    content => template('condor_c7_umd4_wn/00-node_parameters.erb'),
  }

  # Build this file up as per nodetype
  file { '/etc/condor/config.d/condor_config.local':
    require => Package['condor'],
    ensure  => $config_ensure,
    content => template('condor_c7_umd4_wn/condor_config.local.erb'),
  }

  # Control group config
  file { "/etc/cgconfig.conf": source => "puppet:///modules/condor_c7_umd4_wn/cgconfig.conf", mode => "644"}

  # Various data dirs
  file { '/root/scripts': ensure  => directory, mode    => '755', }
  file { "/data/": ensure => "directory", mode => "1777" }
  file { "/data/home": ensure => "directory", mode => "1777" }
  file { "/data/tmp": ensure => "directory", mode => "1777" }
  file { '/data/condor_pool': ensure  => directory, mode    => '755', owner => "condor", group => "condor"}
  file { "/data2/": ensure => "directory", mode => "1777" }
  file { "/data2/tmp": ensure => "directory", mode => "1777" }

  # Condor
  file { '/etc/condor/config.d': ensure  => directory, mode    => '755', }
  file { "/etc/condor/pool_password": source => "puppet:///modules/condor_c7_umd4_wn/pool_password" ,  mode    => '400', }
  file { '/etc/condor/ral': ensure  => directory, mode    => '755', }
  file { "/etc/profile.d/liv-lcg-env.csh": source => "puppet:///modules/condor_c7_umd4_wn/liv-lcg-env.csh" ,  mode    => '755', }
  file { "/etc/profile.d/liv-lcg-env.sh": source => "puppet:///modules/condor_c7_umd4_wn/liv-lcg-env.sh" ,  mode    => '755', }
  file { "/usr/etc/globus-user-env.sh": ensure => present, content => "", mode => "755", }


  # Mount points 
  file { "/opt/exp_soft_sl5/": ensure  => directory, mode    => '755',  }
  file { "/scratch/": ensure => "directory" }
  file { "/home": ensure => "directory", mode => "1777" }

  # ARC runtime files
  file { '/etc/arc': ensure  => directory, mode    => '755', }
  file { '/etc/arc/runtime': ensure  => directory, mode    => '755', }
  file { '/etc/arc/runtime/ENV': ensure  => directory, mode    => '755', }
  file { "/etc/arc/runtime/ENV/GLITE": source => "puppet:///modules/condor_c7_umd4_wn/GLITE", require => File ["/etc/arc/runtime/ENV"], mode => "755", }
  file { "/etc/arc/runtime/ENV/PROXY": ensure => present, content => "", }
  file { "/etc/arc/runtime/GLITE-3_0_0": ensure => present, content => "", }
  file { "/etc/arc/runtime/GLITE-3_1_0": ensure => present, content => "", }
  file { "/etc/arc/runtime/HYDRA-CLIENT-3_1": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2_1_0": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2_1_1": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2_2_0": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2_3_0": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2_3_1": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2_4_0": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2_5_0": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2_6_0": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2_7_0": ensure => present, content => "", }
  file { "/etc/arc/runtime/LCG-2": ensure => present, content => "", }
  file { "/etc/arc/runtime/R-GMA": ensure => present, content => "", }
  file { "/etc/arc/runtime/VO-biomed-CVMFS": ensure => present, content => "", }
  file { "/etc/arc/runtime/VO-lhcb-pilot": ensure => present, content => "", }
  file { "/etc/arc/runtime/VO-snoplus.snolab.ca-cvmfs": ensure => present, content => "", }
  file { "/etc/arc/runtime/VO-t2k.org-ND280-v10r11p25": ensure => present, content => "", }
  file { "/etc/arc/runtime/VO-t2k.org-ND280-v10r11p29": ensure => present, content => "", }
  file { "/etc/arc/runtime/VO-t2k.org-ND280-v11r21": ensure => present, content => "", }


  ssh_authorized_key { "root@hepgrid2":
    ensure => "present",
    name => "root@hepgrid5.ph.liv.ac.uk",
    key => "SSHKEYHERE",
    user => "root",
    type => "ssh-rsa",
  }

  # MOUNTS

  # File systems
  mount { "/scratch":
    require => [ File["/scratch"] ],
    name => "/scratch",
    device => "192.168.48.112:/scratch",
    ensure => "mounted",
    atboot => "true",
    fstype => "nfs",
    options => "rw,tcp,rsize=32768,wsize=32768,nfsvers=3,async,intr"
  }
  mount { "/home":
    require => [ File["/data/home"], File["/home"] ],
    name => "/home",
    device => "/data/home",
    ensure => "mounted",
    atboot => "true",
    fstype => "none",
    options => "bind",
    before => Exec ["/root/scripts/makeNewUsers.pl"],
  }
  mount { "/opt/exp_soft_sl5":
    require => File["/opt/exp_soft_sl5"],
    name => "/opt/exp_soft_sl5",
    device => "ihepsoft1:/software/exp_soft_sl5",
    ensure => "mounted",
    atboot => "true",
    fstype => "nfs",
    options => $rack ? {
      22 => "rw,tcp,rsize=32768,wsize=32768,nfsvers=3,async,intr",
      16 => "rw,tcp,rsize=32768,wsize=32768,nfsvers=3,async,intr",
      default => "rw,tcp,rsize=1048576,wsize=1048576,nfsvers=3,async,intr,ac,actimeo=600",
    },
  }


  # SERVICES
  service { "condor": ensure => running, } 
  service { "cgconfig": ensure => running,  require => File    [ "/etc/cgconfig.conf"]}
  service { "fetch-crl-cron": ensure => running, enable => true, hasstatus => true, require   => Package [ "fetch-crl"], subscribe => Exec ["fetch-crl"] }


  # EXECS
  # 
  exec { "enable_ksm":
    command =>  "/bin/echo 1 > /sys/kernel/mm/ksm/run",
    unless => "/bin/grep ^1$ /sys/kernel/mm/ksm/run",
    timeout => "86400"
  }

  exec { "fetch-crl":
    command => "/usr/sbin/fetch-crl -a 24 -r 20 >> /var/log/fetch-crl-cron.log 2>&1",
    path => ["/sbin", "/bin", "/usr/sbin", "/usr/bin"],
    refreshonly => true,
    timeout => "600",
    subscribe => Package["lcg-CA"]
  }

  # OTHERSTUFF

}
