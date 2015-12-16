# for rspec-puppet documentation - see http://rspec-puppet.com/tutorial/
require_relative '../spec_helper'
# install
describe package('httpd') do
  it { should be_installed }
end
describe package('fping') do
  it { should be_installed }
end

# start
describe service('httpd') do
  it { should be_enabled }
  it { should be_running }
end
describe service('smokeping') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end


