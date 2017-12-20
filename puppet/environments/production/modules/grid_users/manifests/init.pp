class grid_users(
  $ensure = $grid_users::params::ensure,
  $version = $grid_users::params::version,
) inherits grid_users::params {

  # PARAMETER INITIALISATION / CHECKING
  # set local variables as appropriate
  if $ensure == 'absent' {
    $grid_users_ensure = 'absent'
    $config_ensure = 'absent'
  } else {
    $grid_users_ensure = $version
    $config_ensure = 'file'
  }

  # INCLUDES / REQUIRES

  # RESOURCES

  # - REPOS

  # - PACKAGES

  # - FILES

  # 
  file { "/root/scripts/makeNewUsers.pl": source  => 'puppet:///modules/grid_users/makeNewUsers.pl', mode => "700", require => File['/root/scripts'], }
  file { "/root/scripts/users.conf": source  => 'puppet:///modules/grid_users/users.conf', mode => "600", require => File['/root/scripts'], }

  # CRONS

  # SERVICES

  # EXECS

  exec { "/root/scripts/makeNewUsers.pl":
    require => [File["/root/scripts/makeNewUsers.pl"],File["/root/scripts/users.conf"]],
    command => "/root/scripts/makeNewUsers.pl /root/scripts/users.conf > /root/scripts/done-makeNewUsers.pl",
    onlyif => "/usr/bin/test ! -f /root/scripts/done-makeNewUsers.pl",
  }
}

