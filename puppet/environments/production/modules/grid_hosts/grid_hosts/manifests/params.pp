class grid_hosts::params(
  $ensure         = 'present',
  $version        = 'present',
) {

  # Parameters which are not automatically looked up are looked up here
  # e.g. via hiera() or hiera_hash():
  #$manual_hash_example = hiera_hash('template::params::manual_hash_example', [])

  # parameter checking can be carried out here
  # e.g. checking a string for particular content:
  if ! ($ensure in [ "present", "absent" ]) {
    fail("grid_hosts ensure parameter must be absent or present")
  }

  # should check whether version is 'present', 'latest', or version number

}
