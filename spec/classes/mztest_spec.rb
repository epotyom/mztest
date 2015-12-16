# for rspec-puppet documentation - see http://rspec-puppet.com/tutorial/
require_relative '../spec_helper'

describe 'mztest' do
  let(:title) { 'retrieve_smokeping' }
  it { should contain_exec('yum_install_devtools') }
  it { should contain_exec('retrieve_smokeping') }
  it { should contain_exec('untar_smokeping') }
  it { should contain_exec('install_smokeping') }
  it { should contain_file('/opt/smokeping') }
  it { should contain_exec('cp_opts_smokeping') }
  it { should contain_exec('run_configure_smokeping') }
  it { should contain_file('/opt/smokeping/etc/config') }
  it { should contain_file('/opt/smokeping/etc/basepage.html') }
  it do
    should contain_file('/opt/smokeping/etc/smokeping_secrets').with({
      'mode' => '0600'
    })
  end
  it do
    should contain_file('/opt/smokeping/etc/smokeping_secrets.dist').with({
      'mode' => '0600'
    })
  end
  it { should contain_file('/etc/httpd/conf/httpd.conf') }
  it { should contain_file('/etc/httpd/conf.d/smokeping.conf') }
  it { should contain_file('/etc/init.d/smokeping') }
  it { should contain_file('/etc/firewalld/zones/public.xml') }
  it { should contain_file('/opt/smokeping/htdocs/smokeping.fcgi') }
  it { should contain_file('/opt/smokeping/img') }
  it { should contain_file('/opt/smokeping/data') }
  it { should contain_file('/opt/smokeping/var') }
  it { should contain_file('/opt/smokeping/cache') }
  it { should contain_file('/var/www/html/smokeping') }
  it { should contain_file('/var/www/html/smokeping/htdocs') }
  it { should contain_file('/var/www/html/smokeping/htdocs/img') }
  it { should contain_file('/var/www/html/smokeping/htdocs/cache') }
end
