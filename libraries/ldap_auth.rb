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

require_relative 'jboss'

class Chef
  class Resource
    # A resource used to configure LDAP authentication.
    #
    # @provides :ldap_auth
    # @action create
    # @action remove
    #
    class JBossLDAPAuth < Chef::Resource
      include JBoss

      # Chef attributes
      identity_attr :name
      provides      :ldap_authentication
      state_attrs   :exists

      # Actions
      actions        :create, :remove
      default_action :add

      # @!attribute name
      #   The name of the management realm.
      #   @return [String]
      attribute :name,
        kind_of: String
      # @!attribute ldap_connection_name
      #   The name of the ldap connection to use.
      #   @return [Array]
      attribute :ldap_connection_name,
        kind_of: String
      # @!attribute url
      #   The LDAP server URL.
      #   @return[String]
      attribute :url,
        kind_of: String
      # @!attribute search_dn
      #   The dn (username) used to connect to the LDAP and perform the search.
      #   @return [String]
      attribute :search_dn,
        kind_of: String
      # @!attribute search_credential
      #   The password or credentials associated with the dn used to connect
      #   and search the LDAP. VAULT expressions are supported.
      #   @return [String]
      attribute :search_credential,
        kind_of: String
      # @!attribute base_dn
      #   Starts the search within this base.
      #   @return [String]
      attribute :base_dn,
        kind_of: String
      # @!attribute advanced_filter
      #   The LDAP filter used to refine users.
      #   @return [String]
      attribute :advanced_filter,
        kind_of: String

      # @!attribute [rw] :exists
      #   @return [Boolean] true if resource exists.
      attr_accessor :exists

      # Determine if the property exists in the server config. This value is
      # set by the provider when the current resource is loaded.
      #
      # @return [Boolean]
      #
      def exists?
        !@exists.nil? && @exists
      end
    end
  end

  class Provider
    class JBossLDAPAuth < Chef::Provider
      include JBoss

      # Shortcut to new_resource.
      alias_method :r, :new_resource
      # Shortcut to current_resource.
      alias_method :c, :current_resource

      def initialize(new_resource, run_context)
        super
        @path = "/core-service=management/security-realm=" \
                "#{r.name}/authentication=ldap"
      end

      # Boolean indicating if WhyRun is supported by this provider.
      #
      # @return [Boolean]
      #
      def whyrun_supported?
        true
      end

      # Load and return the current state of the resource.
      #
      # @return [Chef::Resource]
      #
      def load_current_resource
        @current_resource ||= Chef::Resource::JBossLDAPAuth.new(r.name)
        @current_resource.exists = exists?
      end

      def action_create
        if @current_resource.exists?
          Chef::Log.debug "#{r.base_dn}' LDAP authentication already configured"
        else
          converge_by "Configure '#{r.base_dn}' LDAP authentication" do
            params  = "connection=#{r.ldap_connection_name},"
            params += "recursive=true,"
            params += "base-dn=\"#{r.base_dn}\,"
            params += "advanced-filter=\"#{r.advanced_filter}\""
            exec_cmd(@path, :add, params)
          end
          r.updated_by_last_action(true)
        end
      end

      def action_remove
        if @current_resource.exists?
          converge_by "Remove '#{r.base_dn}' LDAP authentication" do
            exec_cmd(@path, :remove)
          end
          r.updated_by_last_action(true)
        else
          Chef::Log.debug "'#{r.base_dn}' LDAP authentication is not configured"
        end
      end

      def action_flush
        if @current_resource.exists?
          Chef::Log.debug "'#{r.base_dn}' LDAP authentication is not configured"
        else
          converge_by "Flush '#{r.base_dn}' LDAP authentication" do
            update_attributes(@path, @current_attributes, {})
          end
          r.updated_by_last_action(true)
        end
      end

      private

      # Boolean, true when it can read the current attributes from @path,
      # false if the @path does not exist.
      #
      # @return [Hash, FalseClass]
      #
      def exists?
        @current_attributes = exec_cmd(@path, 'read-resource', 'recursive=true')
        true
      rescue Mixlib::ShellOut::ShellCommandFailed
        false
      end
    end
  end
end
