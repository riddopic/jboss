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

require 'chef/mixin/shell_out'

module JBoss
  # Provider mixin for the JBoss-CLI.
  #
  module CLI
    include JBoss

    # Run a single JBoss-CLI command.
    #
    # @param [String] path
    #   The path represents the address of the target resource (or the
    #   node) against which the operation should be invoked consisting of
    #   `node_type=node_name` pairs separated by a comma.
    #
    # @param [Symbol, String] operation
    #   The operation consists of an operation name and an optional list of
    #   parameters and is always preceded by a colon which serves as a
    #   separator between the path and the operation.
    #
    # @param [String] parameters
    #   The parameter list consists of `parameter_name=parameter_value`
    #   pairs separated by commas.
    #
    # @return [self]
    #   Returns `#stdout`, `#stderr`, `#status`, and `#exitstatus` will be
    #   populated with results of the command.
    #
    def run_cli_command(path, operation, params = nil)
      run "#{path}:#{operation}\(#{params}\)"
    end

    # Run multiple JBoss-CLI commands.
    #
    # @param [Array] commands
    #   A list of JBoss-CLI command in the format of CLI path + CLI operation
    #   name + CLI parameters.
    #
    # @return [self]
    #   Returns `#stdout`, `#stderr`, `#status`, and `#exitstatus` will be
    #   populated with results of the command.
    #
    def run_cli_commands(commands)
      commands.each { |line| run line }
    rescue Mixlib::ShellOut::ShellCommandFailed
      false
    end

    # Run the given JBoss CLI command on the given JBoss instance and
    # parses CLI command output to extract a map of results.
    #
    # @param [String] path
    #   The path represents the address of the target resource (or the
    #   node) against which the operation should be invoked consisting of
    #   `node_type=node_name` pairs separated by a comma.
    #
    # @param [Symbol, String] operation
    #   The operation consists of an operation name and an optional list of
    #   parameters and is always preceded by a colon which serves as a
    #   separator between the path and the operation.
    #
    # @param [String] parameters
    #   The parameter list consists of `parameter_name=parameter_value`
    #   pairs separated by commas.
    #
    # @return [Hash]
    #   A coerced Hash containing a JBoss CLI command output, where each
    #   entry is one of:
    #     * key: nil if the key is undefined.
    #     * key: String
    #     * key: Integer
    #     * key: Boolean (true/false)
    #     * key: Hash
    #
    def exec_command(path, command, params = nil)
      output = run_cli_command(path, command, params)
      parse_cli_result_as_map(output)
    end

    # Adds attributes.
    #
    def add_attributes(path, current_attrs = nil, attrs_to_write = {})
      Chef::Log.debug "Adding attributes, current attributes: " \
                      "#{current_attrs.inspect}"
      Chef::Log.debug "Adding attributes, expected attributes: " \
                      "#{attrs_to_write.inspect}"
      params = ''
      attrs_to_write.each do |key, value|
        if value.is_a?(Hash) && !value.is_a?(FlatHash)
          next
        elsif value != nil
          params << ',' unless params.empty?
          params << "#{key}=#{to_cli_value(value)}"
        end
      end

      begin
        unless params.blank? && current_attrs.blank?
          run_cli_command(path, :remove)
        end
      rescue Mixlib::ShellOut::ShellCommandFailed
      end

      begin
        unless params.blank? || (params.blank? && current_attrs.blank?)
          run_cli_command(path, :add, params)
        end
      rescue Mixlib::ShellOut::ShellCommandFailed
      end

      attrs_to_write.each do |nested_key, nested_value|
        if nested_value.is_a?(Hash) && !nested_value.is_a?(FlatHash)
          add_nested_hash(
            path,
            nested_key,
            current_attrs.nil? ? nil : current_attrs[nested_key],
            nested_value
          )
        end
      end
    end

    def add_nested_hash(path, nested_path, current_attrs={}, attrs_to_write={})
      attrs_to_write.each do |key, value|
        add_attributes(
          path + "/#{nested_path}=#{key}",
          current_attrs.nil? ? nil : current_attrs[key],
          value
        )
      end
    end

    # Write given attributes to the given JBoss instance using JBoss
    # CLI commands. Perform a diff between current and expected attributes, and
    # apply the delta.
    #
    # @param [String] path
    #   The path represents the address of the target resource (or the
    #   node) against which the operation should be invoked consisting of
    #   `node_type=node_name` pairs separated by a comma.
    #
    # @param [Hash] current_attrs
    #   A Hash, which contains the current attributes values.
    #
    # @param [Hash] attrs_to_write
    #   A Hash, which contains the expected attributes names/values.
    #
    def update_attributes(path, current_attrs = {}, attrs_to_write = {})
      Chef::Log.debug "Adding attributes, current attributes: " \
                      "#{current_attrs.inspect}"
      Chef::Log.debug "Adding attributes, expected attributes: " \
                      "#{attrs_to_write.inspect}"
      cmds = []
      attrs_to_write.each do |key, value|
        if value.nil && current_attrs.has_key?(key) && !current_attrs[key].nil
          cmds << path + ":undefine-attribute(name=#{key})"
        elsif !current_attrs.has_key?(key) || current_attrs[key] != value
          cmds << path +
            ":write-attribute(name=#{key},value=#{to_cli_value(value)})"
        end
      end
      run_cli_commands cmds
    end

    alias_method :write_attributes, :update_attributes
  end
end
