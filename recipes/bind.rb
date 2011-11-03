include_recipe "bind9"

execute "update-named-conf" do 
  command "cat  >> /named.conf"
  action :run
end

directory "/var/named/etc/namedb/client_zones" do
  owner node['scalr']['user']
  group node['scalr']['group']
  mode "0755"
  action :create
  recursive true
end

execute "create-zone-file" do
  command "touch /var/named/etc/namedb/client_zones/zones.include"
  action :run
end