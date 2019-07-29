class profile::apache(
  $default_redirect = '/icingaweb2',
) {
  class { 'apache':
    mpm_module => 'prefork',
  }

  include apache::mod::proxy
  include apache::mod::proxy_fcgi
  include apache::mod::rewrite

  if $default_redirect {
    apache::custom_config { 'redirect':
      content => "RedirectMatch ^/$ ${default_redirect}",
    }
  }
}
