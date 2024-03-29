class profile::linux(
  Hash[String, Hash] $ssh_keys = {},
  $yumrepos                    = {},
  $zypprepos                   = {},
) {
  include vagrantenv

  $osfamily = $facts['os']['family']
  case $osfamily {
    /Debian/: {
      include apt
    }
    /RedHat/: {
      $yumrepos.each |$name, $config| {
        yumrepo { $name:
          * => $config,
        }
      }
    }
    /Suse/: {
      include zypprepo
      $zypprepos.each |$name, $config| {
        zypprepo { $name:
          * => $config,
        }
      }
    }
    default: {
      fail("Unknown os ${facts['os']}")
      # ignored for now
    }
  }

  $_root_ssh_keys = prefix($ssh_keys, 'root-')

  create_resources('ssh_authorized_key', $ssh_keys, {
    user => 'vagrant',
    type => 'ssh-rsa',
  })

  create_resources('ssh_authorized_key', $_root_ssh_keys, {
    user => 'root',
    type => 'ssh-rsa',
  })

  $files = lookup('files', Hash, 'hash', {})
  create_resources('file', $files, {
    user  => 'root',
    group => 'root',
    mode  => '0644',
  })
}
