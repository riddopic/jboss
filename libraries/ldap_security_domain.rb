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
    # A resource used to manages the JaaS Security Domain.
    #
    # @provides :ldap_security_domain
    # @action create
    # @action remove
    #
    class JBossLDAPSecurityDomain < Chef::Resource
      include JBoss

      # Chef attributes
      identity_attr :name
      provides      :ldap_security_domain
      state_attrs   :exists

      # Actions
      actions        :create, :remove
      default_action :add

      # @!attribute name
      #   Contains the name of a JAAS Security-manager which handles
      #   authentication.
      #   @return [String]
      attribute :name,
        kind_of: String
      # @!attribute flag
      #   Flags for security modules.
      #   @return[String]
      attribute :flag,
        kind_of: String
      # @!attribute code
      #   Code...
      #   @return [String]
      attribute :code,
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
    class JBossLDAPSecurityDomain < Chef::Provider
      include JBoss

      # Shortcut to new_resource.
      alias_method :r, :new_resource
      # Shortcut to current_resource.
      alias_method :c, :current_resource

      def initialize(new_resource, run_context)
        super
        @path = "/corecore-service=management/ldap-connection=" \
                "#{r.connection_name}"
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
        @current_resource ||= Chef::Resource::JBossLDAPConnection.new(r.name)
        @current_resource.exists = exists?
      end

      def action_create
        if @current_resource.exists?
          Chef::Log.debug "#{r.base_dn}' LDAP connection already configured"
        else
          converge_by "Configure '#{r.base_dn}' LDAP connection" do
            params  = "url=\"#{r.url}\","
            params += "search-dn=\"#{r.search_dn}\","
            params += "search-credential=\"#{r.search_credential}\""
            exec_command(@path, :add, params)
          end
          r.updated_by_last_action(true)
        end
      end

      def action_remove
        if @current_resource.exists?
          converge_by "Remove '#{r.base_dn}' LDAP connection" do
            exec_command(@path, :remove)
          end
          r.updated_by_last_action(true)
        else
          Chef::Log.debug "'#{r.base_dn}' LDAP connection is not configured"
        end
      end

      def action_flush
        if @current_resource.exists?
          Chef::Log.debug "'#{r.base_dn}' LDAP connection is not configured"
        else
          converge_by "Flush '#{r.base_dn}' LDAP connection" do
            update_attributes(@path, @current_attrs, {})
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
        @current_attrs = exec_command(@path, 'read-resource', 'recursive=true')
        true
      rescue Mixlib::ShellOut::ShellCommandFailed
        false
      end
    end
  end
end
