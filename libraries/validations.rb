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

module JBoss
  module Resource
    # Provides validations for the resource.
    #
    module Validations
      # @!classmethods
      module ClassMethods
        # Callback for connection URL validation.
        #
        # @return [Proc]
        #
        def connection_url_callbacks
          { 'Connection URL is invalid' => ->(url) {
            if url.match(/^jdbc:oracle:\w*:@[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}:[0-9a-zA-Z]+$/) ||
              url.match(/^jdbc:db2:\/\/[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}\/[0-9a-zA-Z]+$/) ||
              url.match(/^jdbc:sqlserver:\/\/[0-9a-zA-Z]+([\-.][0-9a-zA-Z]+)*:\d{1,}\/[0-9a-zA-Z]+$/) ||
              url.match(/^jdbc:h2:/)
              true
            else
              false
            end
          }}
        end

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
  end
end
