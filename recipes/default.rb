#
# Cookbook Name:: scalr
# Recipe:: default
#
# Copyright 2011, Example Com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "mysql"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"

include_recipe "bind9"
include_recipe "php"

%w{chkconfig libssh2 net-snmp }.each do |pkg|
  package pkg do
    action :install
  end
end

# Fetch remote file and extract it to the directory path /var/www/scalr
tarball = node[:scalr][:tarball]

remote_file "/tmp/#{tarball}" do
  source "#{node[:scalr][:tarball_url]}"
  mode "0644"
  checksum "#{node[:scalr][:tarball_checksum]}"
end

execute "tar" do
  user "#{node[:scalr][:user]}"
  group "#{node[:scalr][:group]}"
  
  installation_path = "#{node[:scalr][:installation_path]}"
  cwd installation_path
  command "tar zxf /tmp/#{tarball}"
  creates installation_path + "/" + node[:scalr][:dirname]
  action :run
end

# Define web path
web_path = "#{node[:scalr][:web_path]}"

# Copy the contents of the app/ directory to /var/www/scalr
remote_directory web_path + "/" + node[:scalr][:dirname] do
    source node[:scalr][:installation_path] + "/" + node[:scalr][:dirname]
    files_backup 0
    path web_path + "/" + node[:scalr][:dirname]
    user "#{node[:scalr][:user]}"
    group "#{node[:scalr][:group]}"
    mode "0644"
end