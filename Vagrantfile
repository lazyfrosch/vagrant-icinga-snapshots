# -*- mode: ruby -*-
# vi: set ft=ruby :

DOMAIN_NAME = 'icinga.local'.freeze

Vagrant.configure('2') do |config|
  config.vm.box_check_update = false

  # Disable updates of vbguest tools
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')

  new_linux_vm config, 'debian-10', '192.168.33.51', 'bento/debian-10'
  new_linux_vm config, 'centos-7', '192.168.33.52', 'bento/centos-7'

  config.vm.provider 'virtualbox' do |vb|
    vb.memory = '512'
  end

  config.vm.provision :hosts, sync_hosts: true
end

def new_vm(config, name, ip, box)
  config.vm.define name do |host|
    host.vm.box = box
    host.vm.hostname = "#{name}.#{DOMAIN_NAME}"

    host.vm.network 'private_network', ip: ip

    host.vm.provider 'virtualbox' do |vb|
      vb.customize [
        'modifyvm',  :id,
        '--groups',  '/Icinga Snapshots',
        '--audio',   'none',
        '--usb',     'on',
        '--usbehci', 'off'
      ]
    end

    yield(host) if block_given?
  end
end

def new_linux_vm(config, name, ip, box)
  new_vm config, name, ip, box do |host|
    host.vm.provision 'shell', path: 'scripts/bootstrap.sh'
    host.vm.provision 'shell', path: 'scripts/puppet-modules.sh'

    provision_puppet host

    yield(host) if block_given?
  end
end

def provision_puppet(host)
  host.vm.provision 'puppet' do |puppet|
    # Note: only works with vboxsf
    puppet.manifests_path = ['vm', '/vagrant/puppet']
    puppet.options = '--show_diff --hiera_config /vagrant/puppet/hiera.yaml'
  end
end
