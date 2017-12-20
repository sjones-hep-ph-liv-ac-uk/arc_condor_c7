class liv_gridcerts(){

	file { "/etc/grid-security":
		ensure => directory,
		owner => root,
		group => root,
		mode => 0755,
	}

	file { "/etc/grid-security/hostcert.pem":
		source => $hostname ? {
			default => "puppet:///modules/liv_gridcerts/hostcert_$hostname.pem",
		},
		owner => root,
		group => root,
		mode => 0444,
		require => File["/etc/grid-security"],
	}

	file { "/etc/grid-security/hostkey.pem":
                source => $hostname ? {
                        default => "puppet:///modules/liv_gridcerts/hostkey_$hostname.pem",
                },
		owner => root,
		group => root,
		mode => 0400,
		require => File["/etc/grid-security"],
	}


}
