# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @param peadm_pxp_agent_bin_dir [String] The directory where the puppet agent binary will be moved to.
# @param peadm_pxp_agent_conf_dir [String] The directory where the puppet agent configuration files will be moved to.
#
# @example
#   include peadm_bootstrap::isolate_pxp_agent
class peadm_bootstrap::isolate_pxp_agent (
  String $peadm_pxp_agent_bin_dir = '/opt/peadm/puppet/bin/',
  String $peadm_pxp_agent_conf_dir = '/etc/peadm/puppet/',
) {
  $pxp_agent_bin = '/opt/puppetlabs/puppet/bin/puppet'
  $pxp_agent_conf = '/etc/puppetlabs/puppet/puppet.conf'
  $peadm_pxp_agent_service = 'peadm.pxp.service'
  $pxp_conf_dir = '/etc/puppetlabs/puppet/'

  if !defined(File[$peadm_pxp_agent_bin_dir]) {
    file { $peadm_pxp_agent_bin_dir:
      ensure => directory,
    }
  }

  if !defined(File[$peadm_pxp_agent_conf_dir]) {
    file { $peadm_pxp_agent_conf_dir:
      ensure => directory,
    }
  }

  # Remove to test? not included facter?
  # exec { 'copy puppet agent binary':
  #   command => "cp ${puppet_agent_bin} ${peadm_puppet_agent_bin_dir}/puppet",
  #   onlyif  => "test -e ${puppet_agent_bin}",
  #   unless  => "test -e ${peadm_puppet_agent_bin_dir}/puppet",
  #   require => File[$peadm_puppet_agent_bin_dir],
  # }

  exec { 'copy puppet directory pxp agent':
    command => "cp -r ${pxp_conf_dir} ${peadm_pxp_agent_conf_dir}",
    onlyif  => "test -e ${pxp_conf_dir}",
    unless  => "test -e ${peadm_pxp_agent_conf_dir}",
    require => File[$peadm_pxp_agent_conf_dir],
  }

  file { "/usr/lib/systemd/system/${peadm_pxp_agent_service}":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => epp('peadm_bootstrap/peadm.pxp.service.epp', {
        'peadm_pxp_agent_bin_dir' => '/opt/puppetlabs/puppet/bin/',
    'peadm_pxp_agent_conf_dir'    => $peadm_pxp_agent_conf_dir }),
    notify  => Exec['rrefresh_systemctl_daemon_pxp'],
  }

  service { $peadm_pxp_agent_service:
    ensure => running,
    enable => true,
  }

  exec { 'refresh_systemctl_daemon_pxp':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
