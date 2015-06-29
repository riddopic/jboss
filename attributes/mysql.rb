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

default[:jboss][:mysql].tap do |mysql|
  #
  # MySQL Database Configuration
  #
  mysql[:enabled] = false

  # MySQL Connector/J JDBC Module Name
  #
  mysql[:mod_name] = 'com.mysql'

  # MySQL Connector/J Module Dependencies
  #
  mysql[:mod_deps] = ['javax.api', 'javax.transaction.api']

  # Pool values are # of connections, which are kept open until they time out.
  # Timeout is in minutes. Make sure the timeout values in the MySQL DB are
  # higher than the ones listed here.
  #
  mysql[:jndi][:datasources] = [
    {
      jndi_name: 'java:jboss/datasources/test',
      server:    '127.0.0.1',
      port:       3306,
      db_name:   'test',
      db_user:   'test_user',
      db_pass:   'test_pass',
      pool_min:   5,
      pool_max:   20,
      timeout:    5
    },
    {
      jndi_name: 'java:jboss/datasources/test2',
      server:    '127.0.0.1',
      port:       3306,
      db_name:   'test2',
      db_user:   'test_user',
      db_pass:   'test_pass',
      pool_min:   5,
      pool_max:   20,
      timeout:    5
    }
  ]

  # Download location of MySQL Connector/J
  #
  mysql[:url] = 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.34.tar.gz'

  # SHA-256 checksum of MySQL Connector/J
  #
  mysql[:checksum] = 'eb33f5e77bab05b6b27f709da3060302bf1d960fad5ddaaa68c199a72102cc5f'
end
