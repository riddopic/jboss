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
