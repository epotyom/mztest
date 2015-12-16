# machinzone test task
# install and configure smokeping
class mztest (
  # variables
  # https://en.wikipedia.org/wiki/List_of_most_popular_websites
  $ssites = {
  }

) {

  # 1.0.1 puppetlab centos version is not smart enough
  #exec { 'yum_update':
  #  command => '/bin/yum -y -q update',
  #}
  # install depend-s
  package { 'epel-release':
    ensure        => 'installed',
    allow_virtual => false;
  }
  $enhancers = [ 'mod_fcgid', 'httpd', 'httpd-devel', 'rrdtool', 'perl-CGI-SpeedyCGI', 'fping', 'rrdtool-perl', 'perl', 'perl-Sys-Syslog', 'perl-CPAN', 'perl-local-lib', 'perl-Time-HiRes' ]
  package { $enhancers:
    ensure        => 'installed',
    require       => Package['epel-release'],
    allow_virtual => false;
  }
  
  # install dev tools to make
  #  Not very elegant, but it's a work around
  exec { 'yum_install_devtools':
    unless  => '/usr/bin/yum grouplist "Development tools" | /bin/grep "^Installed Groups"',
    command => '/usr/bin/yum -y -q groupinstall "Development tools"',
    timeout => 1800,
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
exec{'make_install_smokeping':
  command => '/usr/bin/make install || /usr/bin/make install',
  cwd     => '/usr/src/smokeping-2.6.9',
  require => Exec['run_configure_smokeping'],
}
### config 
# extract default configs
file {
  '/opt/smokeping/etc/config':
    require => Exec['make_install_smokeping'],
    content => template('mztest/config.erb');
  '/opt/smokeping/etc/basepage.html':
    require => Exec['make_install_smokeping'],
    content => template('mztest/basepage.html');
  '/opt/smokeping/etc/smokeping_secrets':
    require => Exec['make_install_smokeping'],
    content => template('mztest/smokeping_secrets'),
    mode    => '0600';
  '/opt/smokeping/etc/smokeping_secrets.dist':
    content => template('mztest/smokeping_secrets.dist'),
    mode    => '0600',
    require => Exec['make_install_smokeping'];
  '/etc/httpd/conf/httpd.conf':
    require => Exec['make_install_smokeping'],
    content => template('mztest/httpd.conf');
  '/etc/httpd/conf.d/smokeping.conf':
    require => Exec['make_install_smokeping'],
    content => template('mztest/smokeping.conf');
  '/etc/init.d/smokeping':
    content => template('mztest/smokeping-start-script'),
    require => Exec['make_install_smokeping'],
    mode    => '0755';
  '/etc/firewalld/zones/public.xml':
    require => Exec['make_install_smokeping'],
    notify  => Service['firewalld'],
    content => template('mztest/public.xml');
  '/opt/smokeping/htdocs/smokeping.fcgi':
    require => Exec['make_install_smokeping'],
    content => template('mztest/smokeping.fcgi'),
    mode    => '0755';
}
file {
  '/opt/smokeping/img':
    require => Exec['make_install_smokeping'],
    ensure  => 'directory',
    owner   => 'apache',
    group   => 'apache';
  '/opt/smokeping/data':
    require => Exec['make_install_smokeping'],
    ensure  => 'directory';
  '/opt/smokeping/var':
    require => Exec['make_install_smokeping'],
    ensure  => 'directory';
  '/opt/smokeping/cache':
    require => Exec['make_install_smokeping'],
    ensure  => 'directory',
    owner   => 'apache',
    group   => 'apache';
  '/var/www/html/smokeping':
    require => Package['httpd'],
    ensure  => 'directory';
  '/var/www/html/smokeping/htdocs':
    require => File['/var/www/html/smokeping'],
    ensure  => 'link',
    target  => '/opt/smokeping/htdocs';
  '/var/www/html/smokeping/htdocs/img':
    require => File['/var/www/html/smokeping/htdocs'],
    ensure  => 'link',
    target  => '/opt/smokeping/img';
  '/var/www/html/smokeping/htdocs/cache':
    require => File['/var/www/html/smokeping/htdocs'],
    ensure  => 'link',
    target  => '/opt/smokeping/cache';
}

## start
service {
  'httpd':
    require  => [ File['/etc/httpd/conf.d/smokeping.conf'], File['/var/www/html/smokeping/htdocs'] , File['/etc/httpd/conf/httpd.conf'] ],
    ensure   => true,
    enable   => true;
  'smokeping':
    require  => [ Package['fping'], File['/opt/smokeping/etc/config'], File['/opt/smokeping/etc/basepage.html'] , File['/opt/smokeping/etc/smokeping_secrets'], File['/opt/smokeping/etc/smokeping_secrets.dist'] ],
    ensure   => true,
    enable   => true;
  'firewalld':
    require  => File['/etc/firewalld/zones/public.xml'],
    ensure   => true,
    enable   => true;
}
}
