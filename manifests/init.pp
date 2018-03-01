# ::outlyer_agent - provision outlyer agent
class outlyer_agent(
  $install_opts = $::outlyer_agent::repo::install_options,
  $solo       = 'no',
  $docker     = 'no',
  $debug      = 'no',
  $agent_key  = 'changeme',
  $server     = 'wss://agent.outlyer.com',
  $version    = 'latest',
  $name       = false,
  $home_dir   = '/etc/outlyer',
  $config_dir = '/etc/outlyer/conf.d',
  $plugin_dir = '/etc/outlyer/plugins',
  ) inherits ::outlyer_agent::repo {

  contain ::outlyer_agent::repo

  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'SL', 'SLC', 'Ascendos',
    'CloudLinux', 'PSBM', 'OracleLinux', 'OVS', 'OEL', 'Amazon', 'XenServer': {
      package { 'outlyer-agent':
        ensure          => $agent_version,
        install_options => $install_opts,
        require         => Class['outlyer_agent::repo'],
      }
      service { 'outlyer-agent':
        ensure => running,
        enable => true,
      }
    }
    'Debian', 'Ubuntu': {
      package { 'outlyer-agent':
        ensure          => $agent_version,
        install_options => $install_opts,
        require         => [ Exec['apt_update'], Apt::Source['outlyer'] ],
      }
      service { 'outlyer-agent':
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
      }
    }
    default: {
      warning("Module ${module_name} is not supported on ${::lsbdistid}")
    }
  }

  file { '/etc/outlyer/agent.yaml':
    ensure  => 'present',
    content => template('outlyer_agent/agent.yaml.erb'),
    owner   => 'root',
    group   => 'outlyer',
    mode    => '0640',
    notify  => Service['outlyer-agent'],
    require => Package['outlyer-agent'],
  }
}
