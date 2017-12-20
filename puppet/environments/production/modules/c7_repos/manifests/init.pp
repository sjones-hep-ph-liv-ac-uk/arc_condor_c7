class c7_repos() inherits c7_repos::params 
{

  # PARAMETER INITIALISATION / CHECKING

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


  # SERVICES

  # EXECS
  # 

  # OTHERSTUFF

}
