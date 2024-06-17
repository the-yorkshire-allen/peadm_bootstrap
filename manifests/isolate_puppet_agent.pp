# @summary Move the binary and configuration files for the puppet agent to a new location
#
# The class requires a puppet agent to move on the target node. The class will move the puppet agent 
# binary and configuration into the specified directory. The class will also update the systemd service 
# file to point to the new location of the puppet agent binary.
#
# @param peadm_puppet_agent_bin_dir [String] The directory where the puppet agent binary will be moved to.
# @param peadm_puppet_agent_conf_dir [String] The directory where the puppet agent configuration files will be moved to.
#
# @example
#   include peadm_bootstrap::isolate_puppet_agent
class peadm_bootstrap::isolate_puppet_agent (
  String $peadm_puppet_agent_bin_dir = '/opt/peadm/puppet/bin/',
  String $peadm_puppet_agent_conf_dir = '/etc/peadm/puppet/',
) {
  $puppet_agent_bin = '/opt/puppetlabs/puppet/bin/puppet'
  $puppet_agent_conf = '/etc/puppetlabs/puppet/puppet.conf'
  $peadm_puppet_agent_service = 'peadm.puppet.service'
  $puppet_conf_dir = '/etc/puppetlabs/puppet/'

  if !defined(File[$peadm_puppet_agent_bin_dir]) {
    file { $peadm_puppet_agent_bin_dir:
      ensure => directory,
    }
  }

  if !defined(File[$peadm_puppet_agent_conf_dir]) {
    file { $peadm_puppet_agent_conf_dir:
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

  exec { 'copy puppet directory puppet agent':
    command => "cp -r ${puppet_conf_dir} ${peadm_puppet_agent_conf_dir}",
    onlyif  => "test -e ${puppet_conf_dir}",
    unless  => "test -e ${peadm_puppet_agent_conf_dir}",
    require => File[$peadm_puppet_agent_conf_dir],
  }

  file { "/usr/lib/systemd/system/${peadm_puppet_agent_service}":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => epp('peadm_bootstrap/peadm.puppet.service.epp', {
        'peadm_puppet_agent_bin_dir' => '/opt/puppetlabs/puppet/bin/',
    'peadm_puppet_agent_conf_dir'    => $peadm_puppet_agent_conf_dir }),
    notify  => Exec['peadm_boostrap::refresh_systectl_daemon'],
  }

  service { $peadm_puppet_agent_service:
    ensure => running,
    enable => true,
  }
}
