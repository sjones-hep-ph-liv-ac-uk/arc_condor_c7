class condor_wn_c7::params(
  $ensure         = 'present',
  #$version        = '8.6.0-1.el7',
  $version        = 'present',
  $factories      = '$::fqdn',

  # Silly default values
  $ral_node_label =  "NONE",
  $ral_scaling =  "1.0",
  $num_slots =  "1",
  $slot_type_1 =  "cpus=8,mem=auto,disk=auto",
  $num_slots_type_1 =  "1",
  $slot_type_1_partitionable =  "TRUE",
  $processors = "8",
  $numberOfCpus =  "2",
  $central_manager    =  "igrid5",
  $theCEs = 'condor_pool@ph.liv.ac.uk/igrid5',

) {

  # Parameters which are not automatically looked up are looked up here
  # e.g. via hiera() or hiera_hash():
  #$manual_hash_example = hiera_hash('template::params::manual_hash_example', [])

  # parameter checking can be carried out here
  # e.g. checking a string for particular content:
  if ! ($ensure in [ "present", "absent" ]) {
    fail("ensure parameter must be absent or present")
  }

  # should check whether version is 'present', 'latest', or version number

}

