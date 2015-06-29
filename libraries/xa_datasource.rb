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
    # A resource used to add and remove XA data-sources to the JBoss
    # instance.
    #
    # @provides jboss_xa_datasource
    #
    # @action add
    #   Add a new data-source.
    #
    # @action remove
    #   Removes the data-source.
    #
    # @action flush
    #   Flushes the data-source.
    #
    class JBossXADatasource < Chef::Resource
      include JBoss

      # Chef attributes
      identity_attr :name
      provides      :jboss_xa_datasource
      state_attrs   :exists

      # Actions
      actions        :add, :remove, :flush
      default_action :add

      # @!attribute name
      #   The datasource name.
      #   @return [String]
      attribute :name,
        kind_of: String
      # @!attribute jndi_name
      #   Specifies the JNDI name for the datasource.
      #   @return [String]
      attribute :jndi_name,
        kind_of: String,
        regex: /^java(:|:jboss)\/([\/\-_0-9a-zA-Z]+)$/
      # @!attribute driver_name
      #   The JDBC driver the datasource should use. Note that the JDBC Driver
      #   with the must exists.
      #   @return [String]
      attribute :driver_name,
        kind_of: String
      # @!attribute connection_url
      #   The Connection URL of this datasource. The given string must repect a
      #   specific format, regarding refered JDBC Driver.
      #   @return[String]
      attribute :connection_url,
        kind_of: String
        # callbacks: connection_url_callbacks
      # @!attribute user_name
      #   Specify the user name used when creating a new connection.
      #   @return [String]
      attribute :user_name,
        kind_of: String
      # @!attribute password
      #   Specifies the password used when creating a new connection.
      #   @return [String]
      attribute :password,
        kind_of: String
      # @!attribute min_pool_size
      #   The min-pool-size element specifies the minimum number of connections
      #   for a pool.
      #   @return [String]
      attribute :min_pool_size,
        kind_of: Integer,
        default: 0
      # @!attribute max_pool_size
      #   The max-pool-size element specifies the maximum number of connections
      #   for a pool. No more connections will be created in each sub-pool.
      #   @return [Integer]
      attribute :max_pool_size,
        kind_of: Integer,
        default: 20
      #   Should the pool be prefilled. Changing this value can be done only on
      #   disabled datasource, requires a server restart otherwise.
      #   @return [Boolean]
      attribute :pool_prefill,
        kind_of: [TrueClass, FalseClass],
        default: true
      # @!attribute pool_use_strict_min
      #   Specifies if the min-pool-size should be considered strictly.
      #   @return [Boolean]
      attribute :pool_use_strict_min,
        kind_of: [TrueClass, FalseClass],
        default: true
      # @!attribute idle_timeout_minutes
      #   The idle-timeout-minutes elements specifies the maximum time, in
      #   minutes, a connection may be idle before being closed. The actual
      #   maximum time depends also on the IdleRemover scan time, which is half
      #   of the smallest idle-timeout-minutes value of any pool. Changing this
      #   value can be done only on disabled datasource, requires a server
      #   restart otherwise.
      #   @return [Integer]
      attribute :idle_timeout_minutes,
        kind_of: Integer
      # @!attribute query_timeout
      #   Any configured query timeout in seconds. If not provided no timeout
      #   will be set.
      #   @return [Integer]
      attribute :query_timeout,
        kind_of: Integer
      # @!attribute prepared_statements_cache_size
      #   The number of prepared statements per connection in an LRU cache.
      #   @return [Integer]
      attribute :prepared_statements_cache_size,
        kind_of: Integer,
        default: 200
      # @!attribute share_prepared_statements
      #   Whether to share prepared statements, i.e. whether asking for same
      #   statement twice without closing uses the same underlying prepared
      #   statement.
      #   @return [Boolean]
      attribute :share_prepared_statements,
        kind_of: [TrueClass, FalseClass],
        default: true
      # @!attribute background_validation
      #   An element to specify that connections should be validated on a
      #   background thread versus being validated prior to use. Changing this
      #   value can be done only on disabled datasource,  requires a server
      #   restart otherwise.
      #   @return [Boolean]
      attribute :background_validation,
        kind_of: [TrueClass, FalseClass],
        default: true
      # @!attribute use_java_context
      #   Setting this to false will bind the datasource into global JNDI.
      #   @return [Boolean]
      attribute :use_java_context,
        kind_of: [TrueClass, FalseClass],
        default: true
      # @!attribute valid_connection_checker_class_name
      #   An org.jboss.jca.adapters.jdbc.ValidConnectionChecker that provides
      #   an isValidConnection(Connection) method to validate a connection. If
      #   an exception is returned that means the connection is invalid. This
      #   overrides the check-valid-connection-sql .
      #   @return [String]
      attribute :valid_connection_checker_class_name,
        kind_of: String
        # default: connection_checker_class_name
      # @!attribute no_tx_separate_pool
      #   Oracle does not like XA connections getting used both inside and
      #   outside a JTA transaction. To workaround the problem you can create
      #   separate sub-pools for the different contexts.
      #   @return [Boolean]
      attribute :no_tx_separate_pool,
        kind_of: [TrueClass, FalseClass],
        default: true
      # @!attribute server_name
      #   The server name.
      #   @return [String]
      attribute :server_name,
        kind_of: [TrueClass, FalseClass],
        default: true
      # @!attribute server_port
      #   The server name.
      #   @return [Integer]
      attribute :server_port,
        kind_of: Integer
        # default: 50301 if driver_name =~ /^db2$/
      # @!attribute driver_type
      #   The driver type.
      #   @return [Integer]
      attribute :driver_type,
        kind_of: Integer
        # default: 4 if driver_name =~ /^(db2|sqlserver)$/
      # @!attribute database_name
      #   The database name.
      #   @return [String]
      attribute :database_name,
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

      # Returns a default connection checker class name if none is specified.
      #
      # @return [String]
      #
      def connection_checker_class_name
        name = case driver_name
               when /^db2$/
                 '.db2.DB2ValidConnectionChecker'
               when /^oracle-ojdbc6$/
                 '.oracle.OracleValidConnectionChecker'
               when /^sqlserver$/
                 '.mssql.MSSQLValidConnectionChecker'
               else
                 nil
               end
        'org.jboss.jca.adapters.jdbc.extensions' + name_specific
      end
    end
  end

  class Provider
    class JBossXADatasource < Chef::Provider
      include JBoss

      # Shortcut to new_resource.
      alias_method :r, :new_resource
      # Shortcut to current_resource.
      alias_method :c, :current_resource

      def initialize(new_resource, run_context)
        super
        @path = "/subsystem=datasources/xa-data-source=#{r.name}"
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
        @current_resource ||= Chef::Resource::JBossXADatasource.new(r.name)
        @current_resource.exists = exists?
      end

      def action_add
        if @current_resource.exists?
          Chef::Log.debug "The data-source '#{r.name}' already exists"
        else
          converge_by "Add the '#{r.name}' data-source" do
            add_attributes(@path, @current_attrs, attrs_to_add)
          end
          r.updated_by_last_action(true)
        end
      end

      def action_remove
        if @current_resource.exists?
          converge_by "Removing the '#{r.name}' data-source" do
            exec_command(@path, :remove)
          end
          r.updated_by_last_action(true)
        else
          Chef::Log.debug "The data-source '#{r.name}' does not exists"
        end
      end

      def action_flush
        if @current_resource.exists?
          Chef::Log.debug "The data-source '#{r.name}' already exists"
        else
          converge_by "Add the '#{r.name}' data-source" do
            update_attributes(@path, @current_attrs, attrs_to_add)
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
        @current_attrs = exec_command(@path, :read_resource)
        true
      rescue Mixlib::ShellOut::ShellCommandFailed
        false
      end

      def attrs_to_add
        attrs = {
          'jndi-name' => r.driver_name,
          'driver-name' => r.driver_name,
          'connection-url' => r.connection_url,
          'user-name' => r.user_name,
          'password' => r.password,
          'xa-datasource-properties' => {
            'URL' => {
              'value' => r.connection_url
            }
          },
          'xa-datasource-properties' => {
            'User' => {
              'value' => r.user_name
            }
          },
          'xa-datasource-properties' => {
            'Password' => {
              'value' => r.password
            }
          }
        }
        # attrs['xa-datasource-properties']['URL'] = {}
        # attrs['xa-datasource-properties']['URL']['value'] = r.connection_url
        # attrs['xa-datasource-properties']['User'] = {}
        # attrs['xa-datasource-properties']['User']['value'] = r.user_name
        # attrs['xa-datasource-properties']['Password'] = {}
        # attrs['xa-datasource-properties']['Password']['value'] = r.password

        attrs['min-pool-size'] = r.min_pool_size if r.min_pool_size
        attrs['max-pool-size'] = r.max_pool_size if r.max_pool_size
        attrs['pool-prefill'] = r.pool_prefill if r.pool_prefill
        attrs['pool-use-strict-min'] = r.pool_use_strict_min if r.pool_use_strict_min
        attrs['idle-timeout-minutes'] = r.idle_timeout_minutes if r.idle_timeout_minutes
        attrs['query-timeout'] = r.query_timeout if r.query_timeout
        attrs['prepared-statements-cache-size'] = r.prepared_statements_cache_size if r.prepared_statements_cache_size
        attrs['share-prepared-statements'] = r.share_prepared_statements if r.share_prepared_statements
        attrs['background-validation'] = r.background_validation if r.background_validation
        attrs['use-java-context'] = r.use_java_context if r.use_java_context
        attrs['valid-connection-checker-class-name'] = r.valid_connection_checker_class_name if r.valid_connection_checker_class_name

        attrs['xa-datasource-properties']['DriverType'] = {}
        attrs['xa-datasource-properties']['DriverType']['value'] = r.driver_type if r.driver_type
        attrs['xa-datasource-properties']['ServerName'] = {}
        attrs['xa-datasource-properties']['ServerName']['value'] = r.server_name if r.server_name
        attrs['xa-datasource-properties']['PortNumber'] = {}
        attrs['xa-datasource-properties']['PortNumber']['value'] = r.server_port if server_port
        attrs['xa-datasource-properties']['DatabaseName'] = {}
        attrs['xa-datasource-properties']['DatabaseName']['value'] = r.database_name if database_name

        attrs
      end
    end
  end
end
