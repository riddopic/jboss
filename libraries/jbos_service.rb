# # encoding: UTF-8
# #
# # Author:    Stefano Harding <riddopic@gmail.com>
# # License:   Apache License, Version 2.0
# # Copyright: (C) 2014-2015 Stefano Harding
# #
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #     http://www.apache.org/licenses/LICENSE-2.0
# #
# # Unless required by applicable law or agreed to in writing, software
# # distributed under the License is distributed on an "AS IS" BASIS,
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# # See the License for the specific language governing permissions and
# # limitations under the License.
# #
#
# require_relative 'jboss'
#
# class Chef
#   class Resource
#     # A resource used to install and configure JBoss.
#     #
#     # @provides :jboss_service
#     # @action create
#     # @action delete
#     # @action restart
#     # @action reload
#     #
#     class JBossService < Chef::Resource
#       include JBoss
#
#       # Chef attributes
#       identity_attr :name
#       provides      :jboss_service
#       state_attrs   :exists
#
#       # Actions
#       actions        :create, :delete, :restart, :reload
#       default_action :create
#
#       # @!attribute name
#       #   The name of the management realm.
#       #   @return [String]
#       attribute :name,
#         kind_of: String
#       # @!attribute version
#       #   The version of JBoss to install. This can be a specific package
#       #   version (zip or tar.gz), or the version of the war file to download
#       #   from the JBoss mirror.
#       #   @return [String]
#       attribute :version,
#         kind_of: String,
#         required: true,
#         regex: /^\d+(\.\d+)+$/
#       # @!attribute source
#       #   The mirror to download the JBoss package or war file. Note: You can
#       #   not download directly from the JBoss site, you will need to provide a
#       #   location where the file can be downloaded from.
#       #   @return[String]
#       attribute :source,
#         kind_of: String,
#         required: true,
#         regex: /^(file|http|https?):\/\/.*(gz|tar.gz|tgz|bin|zip)$/
#       # @!attribute checksum
#       #   The SHA-256 checksum of the JBoss package or war file. This is use to
#       #   verify that the remote file has not been tampered with. If you leave
#       #   this attribute set to nil, no validation will be performed. If set to
#       #   the wrong MD5 checksum, the Chef Client run will fail.
#       #   @return [String]
#       attribute :checksum,
#         kind_of: String,
#         regex: /^[0-9a-f]{32}$|^[a-zA-Z0-9]{40,64}$/
#       # @!attribute user
#       #   The username of the user who will own and run the JBoss process. You
#       #   can change this to any user on the system. Chef will automatically
#       #   create the user if it does not exist.
#       #   @return [String]
#       attribute :user,
#         kind_of: String,
#         default: 'jboss',
#         regex: Chef::Config[:user_valid_regex]
#       # @!attribute group
#       #   The group under which JBoss is running. JBoss doesn't actually use or
#       #   honor this attribute - it is used for file permission purposes.
#       #   @return [String]
#       attribute :group,
#         kind_of: String,
#         default: 'jboss',
#         regex: Chef::Config[:group_valid_regex]
#       # @!attribute system_account
#       #   The JBoss user and group will be created as `system` accounts. The
#       #   default of `true` will ensure that **new** JBoss user accounts are
#       #   created in the system ID range, exisitng users will not be modified.
#       #   @return [Boolean]
#       attribute :system_account,
#         kind_of: [TrueClass, FalseClass],
#         default: true
#       # @!attribute home
#       #   The path to the JBoss install location. This will also become the
#       #   value of $JBOSS_HOME. By default, this is the directory where JBoss
#       #   stores its configuration and build artifacts. You should ensure this
#       #   directory resides on a volume with adequate disk space.
#       #   @return [String]
#       attribute :home,
#         kind_of: String,
#         default: '/opt/jboss'
#
#       # @!attribute [rw] :exists
#       #   @return [Boolean] true if resource exists.
#       attr_accessor :exists
#
#       # Determine if the property exists in the server config. This value is
#       # set by the provider when the current resource is loaded.
#       #
#       # @return [Boolean]
#       #
#       def exists?
#         !@exists.nil? && @exists
#       end
#     end
#   end
#
#   class Provider
#     class JBossService < Chef::Provider
#       include JBoss
#
#       # Shortcut to new_resource.
#       alias_method :r, :new_resource
#       # Shortcut to current_resource.
#       alias_method :c, :current_resource
#
#       # Boolean indicating if WhyRun is supported by this provider.
#       #
#       # @return [Boolean]
#       #
#       def whyrun_supported?
#         true
#       end
#
#       # Load and return the current state of the resource.
#       #
#       # @return [Chef::Resource]
#       #
#       def load_current_resource
#         @current_resource ||= Chef::Resource::JBossService.new(r.name)
#         @current_resource.exists = exists?
#       end
#
#       def action_create
#         chef_gem 'rboss' do
#           compile_time(false) if respond_to?(:compile_time)
#           action   :install
#         end
#
#         group r.group do
#           system r.system_account
#         end
#
#         user r.user] do
#           comment 'JBoss System User'
#           shell   '/sbin/nologin'
#           home     r.home
#           gid      r.group
#           system   r.system_account
#           action [:create, :lock]
#         end
#
#         package 'libaio' do
#           package_name value_for_platform_family(
#             'rhel'   => 'libaio',
#             'debian' => 'libaio1'
#           )
#         end
#
#         ark 'jboss' do
#           url         r.url
#           home_dir    r.home
#           owner       r.user
#           group       r.group
#           checksum    r.checksum if r.checksum
#           version     r.version
#           prefix_root ::File.dirname r.home
#         end
#
#         template '/etc/init.d/jboss' do
#           source value_for_platform_family(
#             'rhel'   => 'jboss-init-redhat.sh.erb',
#             'debian' => 'jboss-init-debian.sh.erb'
#           )
#           user  'root'
#           group 'root'
#           mode   00755
#         end
#
#         template '/etc/default/jboss.conf' do
#           user   'root'
#           group  'root'
#           mode    00644
#         end
#
#         config_dir = ::File.join(r.home, 'standalone', 'configuration')
#
#         template ::File.join(config_dir, 'mgmt-users.properties') do
#           user      r.user
#           group     r.group
#           mode      00600
#           variables mgmt_users: node[:users][:mgmt]
#         end
#
#         template ::File.join(config_dir, 'application-users.properties') do
#           user      r.user
#           group     r.group
#           mode      00600
#           variables app_users: node[:users][:app]
#         end
#
#         template ::File.join(config_dir, 'application-roles.properties') do
#           user      r.user
#           group     r.group
#           mode      00600
#           variables app_roles: node[:roles][:app]
#         end
#
#         template ::File.join(r.home, 'bin', 'standalone.conf') do
#           user      r.user
#           group     r.group
#           mode      00644
#           variables java_opts: node[:java_opts]
#           notifies :restart, 'service[jboss]'
#         end
#
#         template ::File.join(r.home], 'bin', 'domain.conf') do
#           user      r.user
#           group     r.group
#           mode      00644
#           variables java_opts: node[:java_opts]
#           notifies :restart, 'service[jboss]'
#           only_if { r.mode] == 'domain' }
#         end
#
#         logrotate_app 'jboss' do
#           cookbook 'logrotate'
#           path   [::File.join(r.log][:dir], '*.log')]
#           frequency r.log][:frequency]
#           rotate    r.log][:rotate]
#           create   "644 #{r.user]} #{r.group]}"
#           only_if { r.log][:rotation] }
#         end
#
#         file ::File.join(r.home], '.chef_deployed') do
#           owner   r.user
#           group   r.group
#           action :create_if_missing
#         end
#
#         service 'jboss' do
#           action [:enable, :start]
#         end
#       end
#
#       def action_delete
#       end
#
#       def action_restart
#       end
#
#       def action_reload
#       end
#     end
#   end
# end
