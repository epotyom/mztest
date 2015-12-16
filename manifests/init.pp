# machinzone test task
# install and configure smokeping
class mztest (
  # variables
  # https://en.wikipedia.org/wiki/List_of_most_popular_websites
  $ssites = {
  }

) {
  # install depend-s
  $enhancers = [ 'epel-release', 'mod_fcgid', 'httpd', 'httpd-devel', 'rrdtool', 'perl-CGI-SpeedyCGI', 'fping', 'rrdtool-perl', 'perl', 'perl-Sys-Syslog', 'perl-CPAN', 'perl-local-lib', 'perl-Time-HiRes' ]
  package { $enhancers:
    ensure => 'installed',
    allow_virtual => false;
  }
  
  # install dev tools to make
  #  Not very elegant, but it's a work around
  exec { 'yum_install_devtools':
    unless  => '/usr/bin/yum grouplist "Development tools" | /bin/grep "^Installed Groups"',
    command => '/usr/bin/yum -y groupinstall "Development tools"',
  }

exec{'retrieve_smokeping':
  command => '/usr/bin/wget -q http://oss.oetiker.ch/smokeping/pub/smokeping-2.6.9.tar.gz -O /usr/src/smokeping-2.6.9.tar.gz',
  creates => '/usr/src/smokeping-2.6.9.tar.gz',
  require => Exec['yum_install_devtools'],
}

exec{'untar_smokeping':
  command => '/usr/bin/tar xzvf /usr/src/smokeping-2.6.9.tar.gz',
  creates => '/usr/src/smokeping-2.6.9',
  cwd     => '/usr/src',
  require => Exec['retrieve_smokeping'],
}

exec{'install_smokeping':
  command => '/usr/src/smokeping-2.6.9/setup/build-perl-modules.sh',
  cwd     => '/usr/src/smokeping-2.6.9/setup',
  timeout => 1800,
  require => Exec['untar_smokeping'],
}

file { '/opt/smokeping':
  ensure  => 'directory',
  require => Exec['install_smokeping'],
}

exec{'cp_opts_smokeping':
  command => '/usr/bin/cp -r thirdparty /opt/smokeping/',
  cwd     => '/usr/src/smokeping-2.6.9',
  require => File['/opt/smokeping'],
}
exec{'run_configure_smokeping':
  command => '/usr/src/smokeping-2.6.9/configure --prefix=/opt/smokeping',
  cwd     => '/usr/src/smokeping-2.6.9',
  require => Exec['cp_opts_smokeping'],
}
#exec{'make_install_smokeping':
#  command => '/usr/bin/make install || /usr/bin/make install',
#  cwd     => '/usr/src/smokeping-2.6.9',
#  require => Exec['run_configure_smokeping'],
#}
### config 
# extract default configs
file {
  '/opt/smokeping/etc/config':
    content => template('mztest/config.erb');
  '/opt/smokeping/etc/basepage.html':
    content => template('mztest/basepage.html');
  '/opt/smokeping/etc/smokeping_secrets':
    content => template('mztest/smokeping_secrets'),
    mode => '0600';
  '/opt/smokeping/etc/smokeping_secrets.dist':
    content => template('mztest/smokeping_secrets.dist'),
    mode => '0600',
    require => Exec['run_configure_smokeping'];
  '/etc/httpd/conf/httpd.conf':
    content => template('mztest/httpd.conf');
  '/etc/httpd/conf.d/smokeping.conf':
    content => template('mztest/smokeping.conf');
  '/etc/init.d/smokeping':
    content => template('mztest/smokeping-start-script'),
    mode => '0755';
  '/etc/firewalld/zones/public.xml':
    notify  => Service['firewalld'],
    content => template('mztest/public.xml');
  '/opt/smokeping/htdocs/smokeping.fcgi':
    content => template('mztest/smokeping.fcgi'),
    mode => '0755';
}
file {
  '/opt/smokeping/img':
    ensure => 'directory',
    owner  => 'apache',
    group  => 'apache';
  '/opt/smokeping/data':
    ensure => 'directory';
  '/opt/smokeping/var':
    ensure => 'directory';
  '/opt/smokeping/cache':
    ensure => 'directory',
    owner  => 'apache',
    group  => 'apache';
  '/var/www/html/smokeping':
    ensure => 'directory';
  '/var/www/html/smokeping/htdocs':
    ensure => 'link',
    target => '/opt/smokeping/htdocs';
  '/var/www/html/smokeping/htdocs/img':
    ensure => 'link',
    target => '/opt/smokeping/img';
  '/var/www/html/smokeping/htdocs/cache':
    ensure => 'link',
    target => '/opt/smokeping/cache';
}

## start
service {
  'httpd':
    ensure   => true,
    enable   => true;
  'smokeping':
    ensure   => true,
    enable   => true;
  'firewalld':
    ensure   => true,
    enable   => true;
}
}
