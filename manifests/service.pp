class ds_389::service (
){
  $directory_service = $ds_389::site::service
  #service { 'ds_389::service::dirsrv' :
  service { 'dirsrv' :
    ensure  => running,
    name    => 'dirsrv',
    enable  => true,
    restart => "/sbin/service dirsrv restart ${directory_service}",
    #require => [
    #  Package['389-ds-base'],
    #],
  }
}
