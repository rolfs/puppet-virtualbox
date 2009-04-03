
class virtualbox {
	# Depending on http://github.com/ctrlaltdel/puppet-apt/tree/master
	# cd /etc/puppet/modules && git clone git://github.com/ctrlaltdel/puppet-apt.git && mv puppet-apt apt
	# Note: it will make the server do unattended updates
	include apt

	# Install suns virtualbox apt key-file: http://download.virtualbox.org/virtualbox/debian/sun_vbox.asc
	apt::key {"6DFBCBAE":
		source => "http://download.virtualbox.org/virtualbox/debian/sun_vbox.asc",
	}

	# Put content to /etc/apt/sources.d/virtualbox_sources.list
	apt::sources_list {"virtualbox_sources":
		ensure  => present,
		content => $lsbdistcodename ? {
			intrepid => "deb http://download.virtualbox.org/virtualbox/debian intrepid non-free",
			hardy => "deb http://download.virtualbox.org/virtualbox/debian hardy non-free",
			gusty => "deb http://download.virtualbox.org/virtualbox/debian gutsy non-free",
			dapper => "deb http://download.virtualbox.org/virtualbox/debian dapper non-free",
			lenny => "deb http://download.virtualbox.org/virtualbox/debian lenny non-free",
			etch => "deb http://download.virtualbox.org/virtualbox/debian etch non-free",
			sarge => "deb http://download.virtualbox.org/virtualbox/debian sarge non-free",
			"xandros4.0-xn" => "deb http://download.virtualbox.org/virtualbox/debian xandros4.0-xn non-free",
			default => "",
		}
	}

	package { "virtualbox-2.1": 
		name => "virtualbox-2.1",
		ensure => present,
	}	
}

# Install virtual machine from template: startup-virtualbox-name.sh.erb
define virtualbox::box (name=$name , runas=$runas, macaddress=$macaddress, ram="512MB", disksize="6005", ostype="Ubuntu", dvd="none", vrdpport="3360", boot1="disk", boot2="none", boot3="none", boot4="none" ) {
	file { "sysv_vbox_$name":
		path => "/etc/init.d/virtualbox-$name",
		owner => root,
		group => 0,
		mode => 655,
		content => template ("virtualbox/startup-virtualbox-name.sh.erb"),
	        notify => Service["virtualbox-$name"],

	}
	service { "virtualbox-$name":
		name => "virtualbox-$name",
		enable => true,
		hasstatus => true,
		hasrestart => true,
		subscribe => File["sysv_vbox_$name"],
	}
}
