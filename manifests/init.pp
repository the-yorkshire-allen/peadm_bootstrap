# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include peadm_bootstrap
class peadm_bootstrap {
  exec { 'refresh_systemctl_daemon':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
