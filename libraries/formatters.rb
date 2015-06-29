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

require 'multi_json'

module JBoss
  # Provider mixin for the JBoss-CLI formatters.
  #
  module Formatters
    # Converts the given Typed value into the JBoss-CLI specific format.
    # Currently, provides support for boolean (true/false) types, Fixnum,
    # String, Hash and nil.
    #
    # @return [String]
    #   Returns a String containing JBoss-CLI compatable format and types.
    #
    def to_cli_value(value)
      case value
      when nil
        'undefined'
      when false
        'false'
      when true
        'true'
      when Fixnum
        "#{value}"
      when FlatHash
        value.to_s
      when Array
        array_to_string(value)
      when Hash
        raise "CLI values must be set inside a FlatHash instead of Hash " \
              "to be converted to their CLI equivalent."
      else
        "\"#{value}\""
      end
    end

    # Converts an Array to a JBoss-CLI type of array.
    #
    # @param [Array] value
    #   The array to convert.
    #
    # @return [String]
    #   A JBoss-CLI compatable array.
    #
    def array_to_string(value)
      result = ''
      value.each { |value| result += to_cli_value(value) + ',' }
      result = '[' + result.chomp(',') + ']'
    end

    # Converts an Boolean to a JBoss-CLI type of boolean.
    #
    # @param [Boolean] value
    #   The boolean to convert.
    #
    # @return [Symbol]
    #   A JBoss-CLI compatable boolean.
    #
    def to_cli_boolean(value)
      case value
      when true
        :true
      else
        :false
      end
    end

    # Converts a JBoss-CLI boolean to a Boolean.
    #
    # @param [String] value
    #   The JBoss-CLI boolean to convert.
    #
    # @return [Boolean]
    #
    def to_boolean(value)
      case value
      when :true, 'true'
        true
      else
        false
      end
    end

    # Parses CLI command output to extract a map of results.
    #
    # @param [String] value
    #   The JBoss-CLI boolean to convert.
    #
    # @return [Hash]
    #   A Hash containing a JBoss CLI command output.
    #
    def parse_cli_result_as_map(cli)
      cli = cli.gsub(/=> ([0-9]+)L(,|\s*\})/,'=> \1\2')
      cli = cli.gsub(/=> undefined(,|\s*\})/,'=> "__undefined__"\1')
      cli = cli.gsub(/\[(\s*\([^\(\)\[\]]*\)(,\s*\([^\(\)\[\]]*\))*\s*)\]/m) do
        array_group = $1
        result = array_group.gsub(/\(([^\(\)]*)\)/) do
          key_group = $1
        end
        '{' + result + '}'
      end
      failure = cli.gsub(/.*("failure-description" => ".*[^\\]",).*/m,'\1')
      oneline_failure = failure.gsub(/[\r\n]/,'')
      cli  = cli.gsub(failure, oneline_failure)
      cli  = cli.gsub('=>',':')
      hash = MultiJson.decode(cli)
      if hash['outcome'] == 'failed'
        raise "JBoss-CLI failure: '#{hash['failure-description']}'"
      end
      to_strongly_typed_hash hash['result']
    end

    # Convert cli raw values in the given hash to strongly typed values.
    # If the value is an Hash, convert it (recurs call).
    #
    # @param [String] cli_hash
    #   The JBoss-CLI hash to convert.
    #
    # @return [Hash]
    #   A Hash containing a JBoss CLI command output.
    #
    def to_strongly_typed_hash(cli_hash)
      nil if cli_hash.nil?
      cli_hash.each do |key, value|
        case value
        when "__undefined__"
          cli_hash[key] = nil
        when true
          cli_hash[key] = true
        when false
          cli_hash[key] = false
        when Hash
          cli_hash[key] = to_strongly_typed_hash(value)
        end
      end
      cli_hash
    end
  end
end
