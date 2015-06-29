# encoding: UTF-8
#
# Author:    Stefano Harding <riddopic@gmail.com>
# License:   Apache License, Version 2.0
# Copyright: (C) 2014-2015 Stefano Harding
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

if platform_family?('debian')
  include_recipe 'apt::default'
end

include_recipe 'ark::default'
include_recipe 'java::default'

Chef::Recipe.send(:include, Garcon)

chef_gem 'rboss' do
  compile_time(false) if respond_to?(:compile_time)
  not_if  { gem_installed?('rboss') }
  action   :install
end

group node[:jboss][:group] do
  system node[:jboss][:system_account]
end

user node[:jboss][:user] do
  comment 'JBoss System User'
  shell   '/sbin/nologin'
  home     node[:jboss][:home]
  gid      node[:jboss][:group]
  system   node[:jboss][:system_account]
  action [:create, :lock]
end

package 'libaio' do
  package_name value_for_platform_family(
    'rhel'   => 'libaio',
    'debian' => 'libaio1'
  )
end

ark 'jboss' do
  url         node[:jboss][:url]
  home_dir    node[:jboss][:home]
  owner       node[:jboss][:user]
  group       node[:jboss][:group]
  checksum    node[:jboss][:checksum]
  version     node[:jboss][:version]
  prefix_root ::File.dirname node[:jboss][:home]
end

template '/etc/init.d/jboss' do
  source value_for_platform_family(
    'rhel'   => 'jboss-init-redhat.sh.erb',
    'debian' => 'jboss-init-debian.sh.erb'
  )
  user  'root'
  group 'root'
  mode   00755
end

template '/etc/default/jboss.conf' do
  user   'root'
  group  'root'
  mode    00644
end

config_dir = ::File.join(node[:jboss][:home], 'standalone', 'configuration')

template ::File.join(config_dir, node[:jboss][:standalone_conf]) do
  source "#{node[:jboss][:standalone_conf]}.erb"
  user      node[:jboss][:user]
  group     node[:jboss][:group]
  mode      00600
  variables(
    port_binding_offset:  node[:jboss][:port_binding_offset],
    mgmt_int:             node[:jboss][:mgmt_bind_addr],
    native_mgmt_port:     node[:jboss][:native_mgmt_port],
    http_mgmt_port:       node[:jboss][:http_mgmt_port],
    https_mgmt_port:      node[:jboss][:https_mgmt_port],
    pub_int:              node[:jboss][:pub_bind_addr],
    pub_http_port:        node[:jboss][:http_port],
    pub_https_port:       node[:jboss][:https_port],
    wsdl_host:            node[:jboss][:wsdl_host],
    ajp_port:             node[:jboss][:ajp_port],
    smtp_host:            node[:jboss][:smtp][:host],
    smtp_port:            node[:jboss][:smtp][:port],
    smtp_ssl:             node[:jboss][:smtp][:ssl],
    smtp_user:            node[:jboss][:smtp][:username],
    smtp_pass:            node[:jboss][:smtp][:password],
    acp:                  node[:jboss][:acp],
    s3_access_key:        node[:jboss][:aws][:s3_access_key],
    s3_secret_access_key: node[:jboss][:aws][:s3_secret_access_key],
    s3_bucket:            node[:jboss][:aws][:s3_bucket]
  )
  notifies :restart, 'service[jboss]'
  only_if {
    node[:jboss][:enforce_config] || !::File.exist?(
      ::File.join(node[:jboss][:home], '.chef_deployed')
    )
  }
end

template ::File.join(config_dir, 'mgmt-users.properties') do
  user      node[:jboss][:user]
  group     node[:jboss][:group]
  mode      00600
  variables mgmt_users: node[:jboss][:users][:mgmt]
end

template ::File.join(config_dir, 'application-users.properties') do
  user      node[:jboss][:user]
  group     node[:jboss][:group]
  mode      00600
  variables app_users: node[:jboss][:users][:app]
end

template ::File.join(config_dir, 'application-roles.properties') do
  user      node[:jboss][:user]
  group     node[:jboss][:group]
  mode      00600
  variables app_roles: node[:jboss][:roles][:app]
end

template ::File.join(node[:jboss][:home], 'bin', 'standalone.conf') do
  user      node[:jboss][:user]
  group     node[:jboss][:group]
  mode      00644
  variables java_opts: node[:jboss][:java_opts]
  notifies :restart, 'service[jboss]'
end

template ::File.join(node[:jboss][:home], 'bin', 'domain.conf') do
  user      node[:jboss][:user]
  group     node[:jboss][:group]
  mode      00644
  variables java_opts: node[:jboss][:java_opts]
  notifies :restart, 'service[jboss]'
  only_if { node[:jboss][:mode] == 'domain' }
end

logrotate_app 'jboss' do
  cookbook 'logrotate'
  path   [::File.join(node[:jboss][:log][:dir], '*.log')]
  frequency node[:jboss][:log][:frequency]
  rotate    node[:jboss][:log][:rotate]
  create   "644 #{node[:jboss][:user]} #{node[:jboss][:group]}"
  only_if { node[:jboss][:log][:rotation] }
end

file ::File.join(node[:jboss][:home], '.chef_deployed') do
  owner   node[:jboss][:user]
  group   node[:jboss][:group]
  action :create_if_missing
end

service 'jboss' do
  action [:enable, :start]
end
