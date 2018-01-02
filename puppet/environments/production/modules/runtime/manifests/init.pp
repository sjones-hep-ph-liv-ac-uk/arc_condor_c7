class runtime(
) inherits runtime::params {

  # Some dirs and files that simulate software tags in ARC
  file { "/etc/arc": ensure => "directory", mode => "755", }
  file { "/etc/arc/runtime":
    ensure => "directory",
    mode => "755",
    require => File ["/etc/arc"],
  }

  file { '/etc/arc/runtime/ENV': ensure  => directory, mode    => '755', }
  file { "/etc/arc/runtime/ENV/GLITE": source => "puppet:///modules/runtime/GLITE", require => File ["/etc/arc/runtime/ENV"], mode => "755", }
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

}

