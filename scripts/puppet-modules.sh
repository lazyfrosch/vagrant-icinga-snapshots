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

module_install puppetlabs-stdlib -v 6.1.0
module_install puppetlabs-translate -v 2.0.0
module_install puppetlabs-concat -v 6.1.0

module_install puppet-alternatives -v 2.1.0
module_install lazyfrosch-vagrantenv -v 0.2.1

module_install puppetlabs-apt -v 7.2.0
module_install puppetlabs-apache -v 5.2.0
module_install puppetlabs-ntp -v 8.1.0
module_install puppetlabs-mysql -v 10.2.1
module_install puppetlabs-yumrepo_core -v 1.0.4

module_install puppet-zypprepo -v 2.2.2

module_install icinga-icinga2 -v 2.3.0
module_install icinga-icingaweb2 -v 2.3.1

symlink_module /vagrant/puppet/profile
symlink_module /vagrant/puppet/role
