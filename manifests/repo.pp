# ::outlyer_agent::repo - configure outlyer agent repositories
class outlyer_agent::repo(
  $gpg_key_url = 'http://packages.outlyer.com/outlyer-pubkey.gpg',
  $release = 'stable',
  ) {

  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'SL', 'SLC', 'Ascendos',
    'CloudLinux', 'PSBM', 'OracleLinux', 'OVS', 'OEL', 'XenServer': {
  
      yumrepo { 'outlyer':
        baseurl  => "http://packages.outlyer.com/${release}/el\$releasever/${::architecture}",
        descr    => 'Outlyer Repository',
        enabled  => 1,
        gpgkey   => $gpg_key_url,
        gpgcheck => 1,
      }

      exec { 'clean_yum_metadata':
        command     => '/usr/bin/yum clean metadata',
        refreshonly => true,
        require     => Yumrepo['outlyer'],
      }

    }
    'Amazon': {
  
      yumrepo { 'outlyer':
        baseurl  => "http://packages.outlyer.com/${release}/el6/${::architecture}",
        descr    => 'Outlyer Repository',
        enabled  => 1,
        gpgkey   => $gpg_key_url,
        gpgcheck => 1,
      }

      exec { 'clean_yum_metadata':
        command     => '/usr/bin/yum clean metadata',
        refreshonly => true,
        require     => Yumrepo['outlyer'],
      }

    }
    'Debian', 'Ubuntu': {
      require ::apt
      apt::key { 'outlyer_agent':
        id     => '700CA36B54AD05D747A3FA50B4683EBDACB6D967',
        source => $gpg_key_url,
      }
      apt::source { 'outlyer':
        location => 'http://packages.outlyer.com/deb',
        release  => $release,
        repos    => 'main',
        require  => Apt::Key['outlyer'],
      }
    }
    default: {
      warning("Module ${module_name} is not supported on ${::lsbdistid}")
    }
  }

}

