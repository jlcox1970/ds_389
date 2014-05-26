class ds_389::install {
  file { '/etc/dirsrv' :
    ensure => directory,
  } ->
  file { '/etc/openldap/cacerts':
    ensure => directory,
  } ->
  package { '389-ds-base':
    ensure => present,
  }
}
