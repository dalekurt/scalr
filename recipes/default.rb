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
include_recipe "mysql::server"
include_recipe "mysql::client"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_ssl"
include_recipe "bind9"
include_recipe "php"
include_recipe "php::module_curl"
include_recipe "php::module_mysql"

%w{chkconfig libssh2 net-snmp openssl }.each do |pkg|
  package pkg do
    action :install
  end
end

# Fetch remote file and extract it to the directory path /var/www/scalr

remote_file "#{Chef::Config[:file_cache_path]}/scalr-#{node['scalr']['version']}.tar.gz" do
  checksum node['scalr']['checksum']
  source "http://scalr.googlecode.com/files/scalr-#{node['scalr']['version']}.tar.gz"
  mode "0644"
end

directory "#{node['scalr']['dir']}" do
  owner node['scalr']['user']
  group node['scalr']['group']
  mode "0755"
  action :create
  recursive true
end

execute "untar-scalr" do
  cwd node['scalr']['dir']
  command "tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/scalr-#{node['scalr']['version']}.tar.gz"
end

execute "mysql-install-scalr-privileges" do
  command "/usr/bin/mysql -u root -p#{node['mysql']['server_root_password']} < #{node['mysql']['conf_dir']}/scalr-grants.sql"
  action :nothing
end

template "#{node['mysql']['conf_dir']}/scalr-grants.sql" do
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node['scalr']['db']['user'],
    :password => node['scalr']['db']['password'],
    :database => node['scalr']['db']['database']
  )
  notifies :run, "execute[mysql-install-scalr-privileges]", :immediately
end

execute "create #{node['scalr']['db']['database']} database" do
  command "/usr/bin/mysqladmin -u root -p#{node['mysql']['server_root_password']} create #{node['scalr']['db']['database']}"
  not_if do
    require 'mysql'
    m = Mysql.new("localhost", "root", node['mysql']['server_root_password'])
    m.list_dbs.include?(node['scalr']['db']['database'])
  end
  notifies :create, "ruby_block[save node data]", :immediately
  command "/usr/bin/mysql -u root -p#{node['mysql']['server_root_password']} < #{node['scalr']['dir']}/sql/scalr-2.2-structure.sql"
  command "/usr/bin/mysql -u root -p#{node['mysql']['server_root_password']} < #{node['scalr']['dir']}/sql/scalr-2.2-data.sql"
  
end

# save node data after writing the MYSQL root password, so that a failed chef-client run that gets this far doesn't cause an unknown password to get applied to the box without being saved in the node data.
ruby_block "save node data" do
  block do
    node.save
  end
  action :create
end

log "Navigate to 'http://#{server_fqdn}' to complete scalr installation" do
  action :nothing
end

template "#{node['scalr']['dir']}/etc/config.ini" do
  source "config.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :database        => node['scalr']['db']['database'],
    :user            => node['scalr']['db']['user'],
    :password        => node['scalr']['db']['password'],
  )
  notifies :write, "log[Navigate to 'http://#{server_fqdn}' to complete scalr installation]"
end

apache_site "000-default" do
  enable false
end

web_app "scalr" do
  template "scalr.conf.erb"
  docroot "#{node['scalr']['dir']}"
  server_name server_fqdn
  server_aliases node['fqdn']
end
