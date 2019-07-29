class profile::icingaweb2 (
  $db_dbname    = 'icingaweb2',
  $db_username  = 'icingaweb2',
  $db_password  = 'icingaweb2',
  $ido_dbname   = 'icinga2',
  $ido_username = 'icinga2',
  $ido_password = 'icinga2',
  $api_username = 'root',
  $api_password = 'root',
  $php_mode     = 'mod_php',
  $fpm_service  = 'php-fpm',
) {
  include profile::apache

  mysql::db { $db_dbname:
    user     => $db_username,
    password => $db_password,
    grant    => ['ALL'],
  }

  -> class { 'icingaweb2':
    import_schema => true,
    db_type       => 'mysql',
    db_host       => 'localhost',
    db_username   => $db_username,
    db_password   => $db_password,
    db_name       => $db_dbname,
  }

  class { 'icingaweb2::module::monitoring':
    ido_type          => 'mysql',
    ido_host          => 'localhost',
    ido_db_username   => $ido_username,
    ido_db_password   => $ido_password,
    ido_db_name       => $ido_dbname,
    commandtransports => {
      icinga2 => {
        transport => 'api',
        username  => $api_username,
        password  => $api_password,
      },
    },
  }

  Class['icinga2::repo'] -> Class['icingaweb2']

  apache::custom_config { 'icingaweb2':
    content  => epp('profile/icingaweb2.conf', {
      php_mode => $php_mode,
    }),
  }

  if $php_mode == 'mod_php' {
    include apache::mod::php
  } elsif $php_mode == 'fpm' {
    if $fpm_service {
      service { $fpm_service:
        ensure  => running,
        enable  => true,
        require => Package['icingaweb2'],
      }
    }
  } else {
    fail("php_mode ${php_mode} not implemented!")
  }
}
