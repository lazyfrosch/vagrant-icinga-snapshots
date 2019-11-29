#!/bin/bash

set -e

fail() {
  echo "$@" >&2
  exit 1
}

if [ ! -e /etc/os-release ]; then
  fail "I need /etc/os-release to work!"
fi

. /etc/os-release

GPG_KEY="6F6B15509CF8E59E6E469F327F438280EF8D349F"

case "${ID}" in
  debian|ubuntu)
    if [ -z "${VERSION_CODENAME}" ]; then
      fail "I need VERSION_CODENAME on Debian!"
    fi

    if [ "$(apt-key finger "${GPG_KEY}")" = "" ]; then
      echo "Installating GPG Key for Puppet"
      apt-key adv --keyserver pool.sks-keyservers.net --recv-key "${GPG_KEY}"
    fi

    if [ ! -e /etc/apt/sources.list.d/puppet6.list ]; then
      echo "Installating Puppet Repository"
      if [ "${VERSION_CODENAME}" = buster ]; then
        codename=stretch
      else
        codename="${VERSION_CODENAME}"
      fi
      echo "deb http://apt.puppetlabs.com ${codename} puppet6" >/etc/apt/sources.list.d/puppet6.list
      apt-get update || (rm -f /etc/apt/sources.list.d/puppet6.list; false)
    fi

    if ! dpkg -s puppet-agent &>/dev/null; then
      echo "Installing puppet-agent"
      apt-get install -y puppet-agent
    fi
    ;;
  redhat|centos)
    if [ -z "${VERSION_ID}" ]; then
      fail "I need VERSION_ID on RHEL!"
    fi

    if ! rpm -q puppet6-release &>/dev/null && ! rpm -q puppet-release &>/dev/null; then
      echo "Adding Puppet 6 Repository"
      yum install -y https://yum.puppetlabs.com/puppet6-release-el-"${VERSION_ID}".noarch.rpm
    fi

    if ! rpm -q epel-release &>/dev/null; then
      echo "Installing EPEL Repository"
      if [ "${ID}" = centos ]; then
        yum install -y epel-release
      else
        yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-"${VERSION_ID}".noarch.rpm
      fi
    fi

    # TODO: non centos?
    if [ "${VERSION_ID}" -eq 7 ] ; then
      if ! rpm -q centos-release-scl-rh &>/dev/null; then
        echo "Installing CentOS SCL rh"
        yum install -y centos-release-scl-rh
      fi
    fi

    if ! rpm -q puppet-agent &>/dev/null; then
      echo "Installing Puppet Agent"
      yum install -y puppet-agent
    fi
    ;;
  opensuse*|suse*)
    version="$(echo "${VERSION}" | cut -d. -f1)"

    if ! rpm -q puppet6-release &>/dev/null; then
      echo "Installing puppet repository"
      curl -o /tmp/puppet-release.rpm https://yum.puppetlabs.com/puppet6-release-sles-"${version}".noarch.rpm
      rpm -Uvh /tmp/puppet-release.rpm
    fi

    if ! rpm -q puppet-agent &>/dev/null; then
      echo "Installing Puppet Agent"
      zypper --gpg-auto-import-keys install -y puppet-agent
    fi

    bindir=/usr/bin
    if [ ! -e $bindir/puppet ]; then
      ln -s /opt/puppetlabs/bin/puppet $bindir/puppet
      ln -s /opt/puppetlabs/bin/facter $bindir/facter
      ln -s /opt/puppetlabs/bin/hiera $bindir/hiera
    fi

    # Remove lock for bash-completion
    # TODO: I don't know where this lock comes from
    zypper removelock bash-completion

    # Import Icinga GPG key
    # TODO: should be handled by puppet...
    if ! rpm -q gpg-pubkey-34410682-5287ce4e &>/dev/null; then
      rpm --import https://packages.icinga.com/icinga.key
    fi
    ;;
  *)
    fail "System ID ${ID} is not supported!"
    ;;
esac
