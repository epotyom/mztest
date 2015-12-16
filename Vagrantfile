# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.6.5"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Using Puppet Labs official vagrant boxes, from: https://vagrantcloud.com/puppetlabs
  #config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
  config.vm.box = "puppetlabs/centos-7.0-64-puppet"
  config.vm.box_version = "1.0.1"

  config.vm.provision :shell, :path => "./.vagrant_puppet/init.sh"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "./.vagrant_puppet"
    puppet.manifest_file  = "init.pp"
    puppet.options = "--verbose --debug"
    #puppet.environment = 'test'
    #puppet.environment_path = 'environments'
    #puppet.module_path = "modules"
  end
  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.network "forwarded_port", guest: 80, host: 8073

end
