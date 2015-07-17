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
    # A resource used to manages the logging subsystem.
    #
    # @provides :jboss_log_handler
    # @action create
    # @action remove
    # @action flush
    #
    class JBossLogger < Chef::Resource
      include JBoss

      # Chef attributes
      identity_attr :name
      provides      :jboss_logger
      state_attrs   :exists

      # Actions
      actions        :create, :remove
      default_action :add

      # @!attribute name
      #   The name of the management realm.
      #   @return [String]
      attribute :name,
        kind_of: String
      # @!attribute type
      #   The level to use for logging.
      #   @return [Symbol, String]
      attribute :level,
        kind_of: [Symbol, String],
        equal_to: [
          'ALL', 'FINEST', 'FINER', 'TRACE', 'DEBUG', 'FINE', 'CONFIG', 'INFO',
          'WARN', 'WARNING', 'ERROR', 'FATAL', 'OFF', :all, :finest, :finer,
          :trace, :debug, :fine, :config, :info, :warn, :warning, :error,
          :fatal, :off
        ],
        default: :info
      # @!attribute handlers
      #   An array containing the handlers handling this logger.
      #   @return [Array]
      attribute :handlers,
        kind_of: Array
      # @!attribute use_parent_handlers
      #   Does this logger also log in parent handlers?
      #   @return [Boolean]
      attribute :use_parent_handlers,
        kind_of: [TrueClass, FalseClass],
        default: false

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
    class JBossLogger < Chef::Provider
      include JBoss

      # Shortcut to new_resource.
      alias_method :r, :new_resource
      # Shortcut to current_resource.
      alias_method :c, :current_resource

      def initialize(new_resource, run_context)
        super
        @path = "/subsystem=logging/logger=#{r.logger_name}"
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
        @current_resource ||= Chef::Resource::JBossLogHandler.new(r.name)
        @current_resource.exists = exists?
      end

      def action_create
        if @current_resource.exists?
          Chef::Log.debug "#{r.name}' the logger already configured"
        else
          converge_by "Configure '#{r.name}' logger" do
            add_attributes(@path, @current_attrs, attrs_to_add)
          end
          r.updated_by_last_action(true)
        end
      end

      def action_remove
        if @current_resource.exists?
          converge_by "Remove '#{r.name}' logger" do
            exec_command(@path, :remove)
          end
          r.updated_by_last_action(true)
        else
          Chef::Log.debug "'#{r.name}' logger is not configured"
        end
      end

      def action_flush
        if @current_resource.exists?
          Chef::Log.debug "'#{r.name}' logger is not configured"
        else
          converge_by "Flush '#{r.name}' logger" do
            write_attributes(@path, @current_attrs, attrs_to_add)
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

      def attrs_to_add
        attrs = {
          'level'               => r.level,
          'handlers'            => r.handlers,
          'use-parent-handlers' => r.use_parent_handlers
        }
      end
    end
  end
end
