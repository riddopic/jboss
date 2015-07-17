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

require_relative 'cli'
require 'fileutils'

module Jboss
  module Helpers
    #
    # Invoke the action block in a separate run context and if any resources
    # are modified within the sub context then mark this node as updated.
    #
    # @example
    #   notifying_action :run do
    #     template '/some/template' do
    #       action :create
    #     end
    #   end
    #
    def notifying_action(key, &block)
      action key do
        cached_new_resource = new_resource
        cached_current_resource = current_resource
        sub_run_context = @run_context.dup
        sub_run_context.resource_collection = Chef::ResourceCollection.new

        begin
          original_run_context, @run_context = @run_context, sub_run_context
          instance_eval(&block)
        ensure
          @run_context = original_run_context
        end

        begin
          Chef::Runner.new(sub_run_context).converge
        ensure
          if sub_run_context.resource_collection.any?(&:updated?)
            new_resource.updated_by_last_action(true)
          end
        end
      end
    end
  end
  # A set of methods for using encrypted data bags or Chef Vault.
  #
  module Passwords
    # Library routine that returns an encrypted data bag value for a supplied
    # string. The key used in decrypting the encrypted value should be
    # located at `node[:jboss][:secret][:key_path]`.
    #
    # @param [String] bag_name
    #   Name of the data bag to lookup.
    #
    # @param [String] index
    #   The name of the key containing the encrypted item.
    #
    def secret(bag_name, index)
      case node[:jboss][:databag_type]
      when :encrypted
        encrypted_secret(bag_name, index)
      when :standard
        standard_secret(bag_name, index)
      when :vault
        vault_secret('vault_' + bag_name, index)
      else
        Chef::Log.error "Unsupported value for 'node[:jboss][:databag_type]'"
      end
    end

    # Helper to lookup encrypted secrets.
    #
    # @param [String] bag_name
    #   Name of the data bag to lookup.
    #
    # @param [String] index
    #   The name of the key containing the encrypted item.
    #
    def encrypted_secret(bag_name, index)
      key_path = node[:jboss][:secret][:key_path]
      Chef::Log.info "Loading encrypted databag #{bag_name}.#{index} " \
                     "using key at #{key_path}"
      secret = Chef::EncryptedDataBagItem.load_secret key_path
      Chef::EncryptedDataBagItem.load(bag_name, index, secret)[index]
    end

    # Helper to lookup standard secrets.
    #
    # @param [String] bag_name
    #   Name of the data bag to lookup.
    #
    # @param [String] index
    #   The name of the key containing the encrypted item.
    #
    def standard_secret(bag_name, index)
      Chef::Log.info "Loading databag #{bag_name}.#{index}"
      Chef::DataBagItem.load(bag_name, index)[index]
    end

    # Helper to lookup vault secrets.
    #
    # @param [String] bag_name
    #   Name of the data bag to lookup.
    #
    # @param [String] index
    #   The name of the key containing the encrypted item.
    #
    def vault_secret(bag_name, index)
      begin
        require 'chef-vault'
      rescue LoadError
        Chef::Log.warn "Missing gem 'chef-vault'"
      end
      Chef::Log.info "Loading vault secret #{index} from #{bag_name}"
      ChefVault::Item.load(bag_name, index)[index]
    end

    # Return a password using either data bags or attributes for storage. The
    # storage mechanism used is determined by the node[:jboss][:use_databags]
    # attribute.
    #
    # @param [String] type
    #   The type of password, one of 'user', 'service', 'db' or 'token'.
    #
    # @param [String] key
    #   The identifier of the password (usually the component name, but can
    #   also be a token name.
    #
    def get_password(type, key)
      unless %w(db user service token).include?(type)
        Chef::Log.error "Unsupported type for get_password: #{type}"
        return
      end

      if node[:jboss][:use_databags]
        if type == 'token'
          secret node[:jboss][:secret][:secrets_data_bag], key
        else
          secret node[:jboss][:secret]["#{type}_passwords_data_bag"], key
        end
      else
        node[:jboss][:secret][key][type]
      end
    end
  end
end

# An subclass of Hash to manage cli conversion for some types
class FlatHash < Hash
  include JBoss::CLI

  def initialize(hash = {})
    super
    self.merge!(hash)
  end

  def to_s
    # Converts a hash into its equivalent respecting CLI syntax.
    # Supports nested hashes.
    #
    result = ''
    self.each do |key, value|
      result += "\"#{key}\"=>" + to_cli_value(value) + ','
    end
    result = '{' + result.chomp(',') + '}'
  end
end
