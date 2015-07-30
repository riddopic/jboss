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
    # A resource used to manages the log handlers.
    #
    # @provides :jboss_log_handler
    # @action create
    # @action remove
    # @action flush
    #
    class JBossLogHandler < Chef::Resource
      include JBoss

      # Chef attributes
      identity_attr :name
      provides      :jboss_log_handler
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
      #   The logger's type.
      #   @return [String]
      attribute :type,
        kind_of: String,
        equal_to: %w[
          async-handler console-handler custom-handler file-handler
          size-rotating-file-handler periodic-rotating-file-handler
        ]
      # @!attribute handler_name
      #   The handler's name.
      #   @return[String]
      attribute :handler_name,
        kind_of: String
      # @!attribute formatter
      #   The format to use.
      #   @return [String]
      attribute :formatter,
        kind_of: String,
        default: "%d{dd/MM/yyy HH:mm:ss,SSS} %-5p [%c#] (%t) %s%E%n"
      # @!attribute level
      #   The level to use for logging.
      #   @return [String]
      attribute :level,
        kind_of: String
      # @!attribute custom_options
      #   A list of additional options specific to the handler.
      #   @return [Array]
      attribute :custom_options,
        kind_of: Array

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
    class JBossLogHandler < Chef::Provider
      include JBoss

      # Shortcut to new_resource.
      alias_method :r, :new_resource
      # Shortcut to current_resource.
      alias_method :c, :current_resource

      def initialize(new_resource, run_context)
        super
        @path = "/subsystem=logging/#{r.type}=#{r.handler_name}"
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
          Chef::Log.debug "#{r.name}' the log handlers already configured"
        else
          converge_by "Configure '#{r.name}' log handlers" do
            add_attributes @path, @current_attributes, attributes_to_add
          end
          r.updated_by_last_action(true)
        end
      end

      def action_remove
        if @current_resource.exists?
          converge_by "Remove '#{r.name}' log handlers" do
            exec_cmd @path, :remove
          end
          r.updated_by_last_action(true)
        else
          Chef::Log.debug "'#{r.name}' log handlers is not configured"
        end
      end

      def action_flush
        if @current_resource.exists?
          Chef::Log.debug "'#{r.name}' log handlers is not configured"
        else
          converge_by "Flush '#{r.name}' log handlers" do
            update_attributes @path, @current_attributes, attributes_to_add
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
        @current_attributes = exec_cmd @path, 'read-resource', 'recursive=true'
        true
      rescue Mixlib::ShellOut::ShellCommandFailed
        false
      end

      def attributes_to_add
        attrs = { 'level' => r.level, 'formatter' => r.formatter }
        attrs.merge(r.custom_options) if r.custom_options
        if r.custom_options && r.custom_options.file
          attrs['file'] = FlatHash.new r.custom_options.file
        end
        if r.custom_options && r.custom_options.append
          attrs['append'] = to_boolean r.custom_options.append
        end

        attrs
      end
    end
  end
end
