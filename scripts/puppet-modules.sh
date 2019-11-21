#!/bin/bash

set -eu

PATH="/opt/puppetlabs/bin:${PATH}"

module_path="$(puppet config print modulepath | cut -d: -f1)"

module_install() {
  if ! puppet module list | grep -q "$1"; then
    puppet module install --ignore-dependencies "$@"
  fi
}

symlink_module() {
  target="$1"
  module_name="$(basename "$target")"

  if [ ! -e "${module_path}/${module_name}" ]; then
    echo "Creating symlink at ${module_path}/${module_name}"
    ln -svf "${target}" "${module_path}/${module_name}"
  fi
}

module_install puppetlabs-stdlib
module_install puppetlabs-concat
module_install puppetlabs-translate

module_install lazyfrosch-vagrantenv

module_install puppetlabs-apt
module_install puppetlabs-apache
module_install puppetlabs-ntp
module_install puppetlabs-mysql
module_install puppetlabs-yumrepo_core

module_install puppet-alternatives
module_install puppet-zypprepo

module_install icinga-icinga2
module_install icinga-icingaweb2

symlink_module /vagrant/puppet/profile
symlink_module /vagrant/puppet/role
