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

require_relative 'validations'
require_relative 'formatters'
require_relative 'helpers'
require_relative 'cli'

module JBoss
  # Extend Resource with class and instance methods.
  #
  module Resource
    include Validations

    # @!classmethods
    module ClassMethods
      # Hook called when module is included.
      #
      # @param [Module] descendant
      #   The including module or class.
      #
      # @return [self]
      #
      # @api private
      def included(descendant)
        super
        descendant.extend ClassMethods
      end
    end

    extend ClassMethods
  end

  # Extend Providers with class and instance methods for working with the
  # JBoss-CLI.
  #
  module Provider
    include Chef::Mixin::ShellOut
    include Chef::DSL::Recipe
    include JBoss::Formatters
    include JBoss::CLI

    # Helper method for returning the JBoss CLI.
    #
    # @return [String]
    #
    def jboss_cli
      'bin/jboss-cli.sh -c'
    end

    # A list of options passed to shell_out.
    #
    # @return [Hash]
    #
    def options
      { returns: [0],
        user: node[:jboss][:user],
        cwd:  node[:jboss][:home]
      }
    end

    # Run the command, writing the command's standard out and standard
    # error to stdout and stderr, and saving its exit status object to
    # status.
    #
    # @see Mixlib::ShellOut#run_command
    #
    # @param [String, Array] cmd
    #   A single command, or a list of command fragments to execute.
    #
    # @raise Errno::EACCES
    #   When you are not privileged to execute the command.
    #
    # @raise Errno::ENOENT
    #   When the command is not available on the system (or not in the
    #   current $PATH).
    #
    # @raise CommandTimeout
    #   When the command does not complete within timeout seconds (default:
    #   timeout is 600s).
    #
    # @return [self]
    #   Returns `#stdout`, `#stderr`, `#status`, and `#exitstatus` will be
    #   populated with results of the command.
    #
    def run(cmd)
      shell_out! "#{jboss_cli} '#{cmd}'", options
    end

    # Provide a common Monitor to all providers for locking.
    #
    # @return [Class<Monitor>]
    #
    # @api private
    def lock
      @@lock ||= Monitor.new
    end

    # Wraps shell_out in a monitor for thread safety.
    #
    # @api private
    __shell_out__ = instance_method(:shell_out!)
    define_method(:shell_out!) do |*args, &_block|
      lock.synchronize { __shell_out__.bind(self).call(*args) }
    end
  end

  # Extends a descendant with class and instance methods.
  #
  # @param [Class] descendant
  #   The including module or class.
  #
  # @return [undefined]
  #
  # @api private
  def self.included(descendant)
    super
    if descendant < Chef::Resource
      descendant.class_exec { include Garcon }
    elsif descendant < Chef::Provider
      descendant.class_exec { include Garcon }
      descendant.class_exec { include JBoss::Provider }
    end
  end
  private_class_method :included
end
