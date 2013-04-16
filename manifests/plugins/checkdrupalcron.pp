# == Class: icinga::plugins::checkdrupalcron
#
# This class provides a checkdrupalcron plugin.
#
# Warning and Critical expressed in seconds.  3600sec = 1h, 7200sec = 2h
define icinga::plugins::checkdrupalcron (
  $pkgname                = 'nagios-plugins-drupalcron',
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $warning                = '3600',
  $critical               = '7200',
  $uri                    = '',
  $root                   = '',
) {

  require icinga

  if $icinga::client {
    
    if ! defined(Package[$pkgname]) {
      package{$pkgname:
       ensure => 'installed',
      }
    }

    file{"${::icinga::includedir_client}/check_drupal_cron_${title}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_drupal_cron]=${::icinga::plugindir}/check_drupal_cron -u ${uri} -r ${root} -w ${warning} -c ${critical}\n",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service{"check_drupal_cron_${host_name}":
      check_command         => 'check_nrpe_command!check_drupal_cron',
      service_description   => "Check Drupal Cron ${title}",
      host_name             => $host_name,
      use                   => 'generic-service',
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${host_name}.cfg",
    }
  }
}