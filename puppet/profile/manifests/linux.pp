class profile::linux(
  Hash[String, Hash] $ssh_keys = {},
) {
  include ntp
  include vagrantenv

  if $facts['os']['family'] == 'Debian' {
    include apt

    # $_sources = lookup('apt::sources', Hash[String, Hash], 'hash', {}).each |$_title, $_config| {
    #   apt::source { $_title:
    #     * => $_config,
    #   }
    # }
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
