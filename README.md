machinzone-test

Description
===========

machinzone-test - TODO: Write a module description

Requirements
============

Vagrant
-------
1) wget https://releases.hashicorp.com/vagrant/1.7.4/vagrant_1.7.4_x86_64.deb
2) sudo dpkg --install vagrant_1.7.4_x86_64.deb
3) vagrant plugin install vagrant-vbguest

RVM install and use
-------------------

1) gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
2) \curl -sSL https://get.rvm.io | bash -s stable
3) source ~/.rvm/scripts/rvm
4) rvm install 2.1

Virtualbox
----------

1) wget http://download.virtualbox.org/virtualbox/5.0.10/virtualbox-5.0_5.0.10-104061~Ubuntu~trusty_amd64.deb
2) sudo dpkg --install virtualbox-5.0_5.0.10-104061~Ubuntu~trusty_amd64.deb

Magnum (to create vagrant initial project)
------------------------------------------

1) wget https://github.com/tehmaspc/magnum.git
2) bundle install && bundle exec rake install

Tests
=====

Puppet module syntax test:
```
bundle exec rake lint
```

Spec unit tests (spec/classes/mztest_spec.rb):
```
bundle exec rake unit
```




