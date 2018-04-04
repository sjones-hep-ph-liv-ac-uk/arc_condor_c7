class arc_arguscli_c7(

) inherits arc_arguscli_c7::params {

  # INCLUDES / REQUIRES

  # RESOURCES

  # - REPOS

  # - PACKAGES

  package { "lcmaps-plugins-voms": ensure => installed , require => Yumrepo ["yum_umd_4_centos7_x86_64_updates"], }
  package { "lcmaps-plugins-verify-proxy": ensure => installed , require => Yumrepo ["yum_umd_4_centos7_x86_64_updates"], }
  package { "lcmaps-plugins-c-pep": ensure => installed , require => Yumrepo ["yum_umd_4_centos7_x86_64_updates"], }
  package { "lcmaps-plugins-basic": ensure => installed , require => Yumrepo ["yum_umd_4_centos7_x86_64_updates"], }
  package { "lcas": ensure => installed , require => Yumrepo ["yum_umd_4_centos7_x86_64_updates"], }
  package { "lcas-plugins-voms": ensure => installed , require => Yumrepo ["yum_umd_4_centos7_x86_64_updates"], }
  package { "lcas-plugins-basic": ensure => installed , require => Yumrepo ["yum_umd_4_centos7_x86_64_updates"], }
  package { "lcmaps": ensure => installed , require => Yumrepo ["yum_umd_4_centos7_x86_64_updates"], }

  # - FILES
  file { "/etc/lcmaps/":
    ensure => "directory",
    mode => "755",
  }

  file { "/etc/lcmaps/lcmaps.db": content => template('arc_arguscli_c7/lcmaps.db.erb'), owner => "root", mode => "644", require => File["/etc/lcmaps/"], }


  # - OTHER (e.g. mounts, cron jobs)

  # SERVICES

  # 

  # EXECS
  # 

}

