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
    # A resource used to add and remove modules to the JBoss instance.
    #
    # When a module is added, the corresponding to the module name directory
    # structure will be created in the JBoss EAP 6 module repository. The JAR
    # files specified as resources will be copied to the module's directory.
    # A module.xml file will also be automatically generated.
    #
    # When a module is removed, its module.xml and other resources will be
    # removed from the module repository as well as its directory structure up
    # to the point where other modules met.
    #
    # @note
    #   The command can generate only simple module.xml files. More
    #   specifically, it supports:
    #     - resources-root elements that point to files;
    #     - modules dependencies as simple module names;
    #     - module's main-class;
    #     - module properties.
    #
    # @provides jboss_module
    #
    # @action add
    #   Adds a module to the host. The directory structure will be created in
    #   the JBoss EAP 6 module repository. The JAR files specified as resources
    #   will be copied to the module's directory and a module.xml file created.
    #
    # @action remove
    #   Removes the module from the When a module is removed, its module.xml
    #   and other resources will be removed from the module repository as well
    #   as its directory structure up to the point where other modules met.
    #
    # @example
    #   jboss_module 'com.oracle.jdbc' do
    #     resource_url 'http://repo.example.com/jboss/ojdbc6.jar'
    #     dependencies 'javax.api,javax.transaction.api'
    #   end
    #
    class JbossModule < Chef::Resource
      include JBoss

      # Chef attributes
      identity_attr :name
      provides      :jboss_module
      state_attrs   :exists

      # Actions
      actions        :add, :remove
      default_action :add

      # @!attribute name
      #   The name of the module to be added or removed.
      #   @return [String]
      attribute :name,
        kind_of: String
      # @!attribute dependencies
      #   A comma-separated list of module names that the current module being
      #   added depends on.
      #   @return [Array]
      attribute :dependencies,
        kind_of: [String, Array]
      # @!attribute resource_url
      #   A list of filesystem paths (usually jar files) separated by a
      #   filesystem-specific path separator. The file(s) specified will be
      #   copied  to the created module's directory.
      #   @return [Array]
      attribute :resource_url,
        kind_of: [String, Array]

      # @!attribute [rw] exists
      #   @return [Boolean] True if resource exists.
      attr_accessor :exists

      # Determine if the property exists in the server config. This value is
      # set by the provider when the current resource is loaded.
      #
      # @see Chef::Provider::JbossModule#has_driver?
      #
      # @return [Boolean]
      #
      def exists?
        !@exists.nil? && @exists
      end
    end
  end

  class Provider
    class JbossModule < Chef::Provider
      include Chef::Mixin::ShellOut
      include JBoss

      # Shortcut to new_resource.
      alias_method :r, :new_resource
      # Shortcut to current_resource.
      alias_method :c, :current_resource

      def initialize(new_resource, run_context)
        super
        @jar = ::File.join('/tmp', ::File.basename(new_resource.resource_url))
        @path = '/subsystem=datasources'
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
        @current_resource ||= Chef::Resource::JbossModule.new(r.name)
        @current_resource.exists = has_driver?
        @current_resource
      end

      # Adds a module to the host. The directory structure will be created in
      # the JBoss EAP 6 module repository. The JAR files specified as resources
      # will be copied to the module's directory and a module.xml file created.
      #
      def action_add
        if @current_resource.exists?
          Chef::Log.debug "'#{r.name}' already exists - nothing to do"
        else
          converge_by "Setting attribute '#{r.name}'" do
            add_module
          end
          r.updated_by_last_action(true)
        end
      end

      # Removes the module from the When a module is removed, its module.xml
      # and other resources will be removed from the module repository as well
      # as its directory structure up to the point where other modules met.
      #
      def action_remove
        if @current_resource.exists?
          converge_by "Removing '#{r.name}' module" do
            remove_module
          end
          r.updated_by_last_action(true)
        else
          Chef::Log.debug "'#{r.name}' does not exists - nothing to do"
        end
      end

      private

      # Boolean, true if the module is already installed, otherwise false.
      #
      # @return [Boolean]
      #
      def has_driver?
        shell_out(
          "#{jboss_cli} '#{@path}:installed-drivers-list'", cli_options
        ).stdout.include? r.name
      end

      # Copies the remote module to be installed.
      #
      # @return [undefined]
      #
      def copy_module
        f ||= Chef::Resource::RemoteFile.new(@jar, run_context)
        f.source r.resource_url
        f.run_action :create
      end

      # Adds a module to the JBoss instance.
      #
      # @return [undefined]
      #
      def add_module
        copy_module
        run "module add --name=#{r.name} --resources=#{@jar} " \
            "--dependencies=\"#{r.dependencies}\""
      end

      # Remove a module to the JBoss instance.
      #
      # @return [undefined]
      #
      def remove_module
        run "module remove --name=#{r.name}"
      end
    end
  end
end
